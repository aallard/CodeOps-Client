// Tests for SqlScriptImportService.
//
// Mocks DatabaseConnectionService and DatabaseDriverAdapter to verify
// statement parsing (semicolons, quoted strings, comments), single and
// multi-statement execution, stop-on-error behaviour, transaction
// wrapping (BEGIN/COMMIT/ROLLBACK), and progress callback invocation.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/services/datalens/database_connection_service.dart';
import 'package:codeops/services/datalens/drivers/database_driver.dart';
import 'package:codeops/services/datalens/import/sql_script_import_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDatabaseConnectionService extends Mock
    implements DatabaseConnectionService {}

class MockDatabaseDriverAdapter extends Mock
    implements DatabaseDriverAdapter {}

void main() {
  late MockDatabaseConnectionService mockConnService;
  late MockDatabaseDriverAdapter mockDriver;
  late SqlScriptImportService service;

  setUp(() {
    mockConnService = MockDatabaseConnectionService();
    mockDriver = MockDatabaseDriverAdapter();
    service = SqlScriptImportService(mockConnService);

    when(() => mockConnService.getDriver('conn-1')).thenReturn(mockDriver);
    when(() => mockDriver.dialect).thenReturn(SqlDialect.postgresql);
  });

  // -------------------------------------------------------------------------
  // parseStatements
  // -------------------------------------------------------------------------

  group('parseStatements', () {
    test('splits simple statements on semicolons', () {
      final result = service.parseStatements(
        'SELECT 1; SELECT 2; SELECT 3;',
      );

      expect(result, ['SELECT 1', 'SELECT 2', 'SELECT 3']);
    });

    test('handles trailing statement without semicolon', () {
      final result = service.parseStatements('SELECT 1; SELECT 2');

      expect(result, ['SELECT 1', 'SELECT 2']);
    });

    test('ignores semicolons inside single-quoted strings', () {
      final result = service.parseStatements(
        "INSERT INTO t VALUES ('hello; world'); SELECT 1;",
      );

      expect(result, hasLength(2));
      expect(result.first, contains("'hello; world'"));
    });

    test('ignores semicolons inside double-quoted identifiers', () {
      final result = service.parseStatements(
        'SELECT "col;name" FROM t; SELECT 1;',
      );

      expect(result, hasLength(2));
      expect(result.first, contains('"col;name"'));
    });

    test('strips line comments', () {
      final result = service.parseStatements(
        '-- this is a comment\nSELECT 1; SELECT 2;',
      );

      expect(result, hasLength(2));
      expect(result.first, 'SELECT 1');
    });

    test('returns empty list for blank input', () {
      expect(service.parseStatements(''), isEmpty);
      expect(service.parseStatements('   '), isEmpty);
      expect(service.parseStatements(';;'), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // executeScript
  // -------------------------------------------------------------------------

  group('executeScript', () {
    test('executes a single statement', () async {
      when(() => mockDriver.execute('SELECT 1')).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 0),
      );

      final result = await service.executeScript(
        connectionId: 'conn-1',
        script: 'SELECT 1;',
      );

      expect(result.statementsExecuted, 1);
      expect(result.statementsSucceeded, 1);
      expect(result.statementsFailed, 0);
      expect(result.details, hasLength(1));
      expect(result.details.first.success, true);
    });

    test('executes multiple statements and aggregates results', () async {
      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 5),
      );

      final result = await service.executeScript(
        connectionId: 'conn-1',
        script: 'INSERT INTO a VALUES (1); UPDATE b SET x = 1;',
      );

      expect(result.statementsExecuted, 2);
      expect(result.statementsSucceeded, 2);
      expect(result.rowsAffected, 10);
    });

    test('stop on error halts after first failure', () async {
      var callCount = 0;
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 2) throw Exception('syntax error');
        return const DriverQueryResult(affectedRows: 1);
      });

      final result = await service.executeScript(
        connectionId: 'conn-1',
        script: 'SELECT 1; BAD SQL; SELECT 3;',
        stopOnError: true,
      );

      expect(result.statementsSucceeded, 1);
      expect(result.statementsFailed, 1);
      // Third statement should not have been executed.
      expect(result.statementsExecuted, 2);
    });

    test('continues past errors when stopOnError is false', () async {
      var callCount = 0;
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 2) throw Exception('syntax error');
        return const DriverQueryResult(affectedRows: 1);
      });

      final result = await service.executeScript(
        connectionId: 'conn-1',
        script: 'SELECT 1; BAD SQL; SELECT 3;',
        stopOnError: false,
      );

      expect(result.statementsSucceeded, 2);
      expect(result.statementsFailed, 1);
      expect(result.statementsExecuted, 3);
    });

    test('wraps in transaction and commits on success', () async {
      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 1),
      );

      await service.executeScript(
        connectionId: 'conn-1',
        script: 'INSERT INTO t VALUES (1);',
        wrapInTransaction: true,
      );

      verify(() => mockDriver.execute('BEGIN')).called(1);
      verify(() => mockDriver.execute('COMMIT')).called(1);
      verifyNever(() => mockDriver.execute('ROLLBACK'));
    });

    test('wraps in transaction and rolls back on failure', () async {
      when(() => mockDriver.execute('BEGIN')).thenAnswer(
        (_) async => const DriverQueryResult(),
      );
      when(() => mockDriver.execute('BAD SQL')).thenThrow(
        Exception('syntax error'),
      );
      when(() => mockDriver.execute('ROLLBACK')).thenAnswer(
        (_) async => const DriverQueryResult(),
      );

      final result = await service.executeScript(
        connectionId: 'conn-1',
        script: 'BAD SQL;',
        wrapInTransaction: true,
      );

      expect(result.statementsFailed, 1);
      verify(() => mockDriver.execute('ROLLBACK')).called(1);
      verifyNever(() => mockDriver.execute('COMMIT'));
    });

    test('invokes progress callback', () async {
      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 0),
      );

      final progressCalls = <(int, int)>[];

      await service.executeScript(
        connectionId: 'conn-1',
        script: 'SELECT 1; SELECT 2; SELECT 3;',
        onProgress: (current, total) => progressCalls.add((current, total)),
      );

      expect(progressCalls, [(1, 3), (2, 3), (3, 3)]);
    });

    test('throws when no active connection', () async {
      when(() => mockConnService.getDriver('bad-conn')).thenReturn(null);

      expect(
        () => service.executeScript(
          connectionId: 'bad-conn',
          script: 'SELECT 1;',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
