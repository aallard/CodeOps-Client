// Tests for TableTransferService.
//
// Mocks DatabaseConnectionService, SchemaIntrospectionService, and
// DatabaseDriverAdapter to verify same-connection transfers (INSERT ...
// SELECT), cross-connection transfers (read + batch-insert), WHERE
// filtering, auto-column-mapping, target table creation, truncation, and
// progress callbacks without a real database.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/services/datalens/database_connection_service.dart';
import 'package:codeops/services/datalens/drivers/database_driver.dart';
import 'package:codeops/services/datalens/import/csv_import_service.dart';
import 'package:codeops/services/datalens/import/table_transfer_service.dart';
import 'package:codeops/services/datalens/schema_introspection_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDatabaseConnectionService extends Mock
    implements DatabaseConnectionService {}

class MockSchemaIntrospectionService extends Mock
    implements SchemaIntrospectionService {}

class MockDatabaseDriverAdapter extends Mock
    implements DatabaseDriverAdapter {}

void main() {
  late MockDatabaseConnectionService mockConnService;
  late MockSchemaIntrospectionService mockSchemaService;
  late MockDatabaseDriverAdapter mockSrcDriver;
  late MockDatabaseDriverAdapter mockTgtDriver;
  late TableTransferService service;

  setUp(() {
    mockConnService = MockDatabaseConnectionService();
    mockSchemaService = MockSchemaIntrospectionService();
    mockSrcDriver = MockDatabaseDriverAdapter();
    mockTgtDriver = MockDatabaseDriverAdapter();
    service = TableTransferService(mockConnService, mockSchemaService);

    when(() => mockConnService.getDriver('src')).thenReturn(mockSrcDriver);
    when(() => mockConnService.getDriver('tgt')).thenReturn(mockTgtDriver);
    when(() => mockSrcDriver.dialect).thenReturn(SqlDialect.postgresql);
    when(() => mockTgtDriver.dialect).thenReturn(SqlDialect.postgresql);
  });

  // -------------------------------------------------------------------------
  // Same-connection transfer
  // -------------------------------------------------------------------------

  group('same-connection transfer', () {
    test('executes INSERT ... SELECT with explicit mappings', () async {
      when(() => mockConnService.getDriver('conn-1')).thenReturn(mockSrcDriver);

      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 10),
      );

      final result = await service.transfer(
        sourceConnectionId: 'conn-1',
        sourceSchema: 'public',
        sourceTable: 'src_table',
        targetConnectionId: 'conn-1',
        targetSchema: 'public',
        targetTable: 'tgt_table',
        columnMappings: const [
          ColumnMapping(csvColumn: 'id', dbColumn: 'id'),
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
        ],
      );

      expect(result.rowsTransferred, 10);
      expect(result.rowsFailed, 0);

      final captured =
          verify(() => mockSrcDriver.execute(captureAny())).captured;
      final sql = captured.last as String;
      expect(sql, contains('INSERT INTO'));
      expect(sql, contains('SELECT'));
    });

    test('applies WHERE clause', () async {
      when(() => mockConnService.getDriver('conn-1')).thenReturn(mockSrcDriver);

      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 3),
      );

      await service.transfer(
        sourceConnectionId: 'conn-1',
        sourceSchema: 'public',
        sourceTable: 'src',
        targetConnectionId: 'conn-1',
        targetSchema: 'public',
        targetTable: 'tgt',
        columnMappings: const [
          ColumnMapping(csvColumn: 'id', dbColumn: 'id'),
        ],
        whereClause: 'active = true',
      );

      final captured =
          verify(() => mockSrcDriver.execute(captureAny())).captured;
      final sql = captured.last as String;
      expect(sql, contains('WHERE active = true'));
    });

    test('auto-maps columns by name when no explicit mappings', () async {
      when(() => mockConnService.getDriver('conn-1')).thenReturn(mockSrcDriver);

      when(() => mockSchemaService.getColumns('conn-1', 'public', 'src'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
                ColumnInfo(columnName: 'name', dataType: 'text'),
              ]);
      when(() => mockSchemaService.getColumns('conn-1', 'public', 'tgt'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
                ColumnInfo(columnName: 'name', dataType: 'text'),
                ColumnInfo(columnName: 'extra', dataType: 'text'),
              ]);

      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 5),
      );

      final result = await service.transfer(
        sourceConnectionId: 'conn-1',
        sourceSchema: 'public',
        sourceTable: 'src',
        targetConnectionId: 'conn-1',
        targetSchema: 'public',
        targetTable: 'tgt',
      );

      expect(result.rowsTransferred, 5);
    });
  });

  // -------------------------------------------------------------------------
  // Cross-connection transfer
  // -------------------------------------------------------------------------

  group('cross-connection transfer', () {
    test('reads from source and batch-inserts into target', () async {
      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => DriverQueryResult(
          columnNames: ['id', 'name'],
          columnTypes: ['int4', 'text'],
          rows: [
            [1, 'Alice'],
            [2, 'Bob'],
          ],
          affectedRows: 2,
        ),
      );

      when(() => mockTgtDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 2),
      );

      when(() => mockSchemaService.getColumns('src', 'public', 'src_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
                ColumnInfo(columnName: 'name', dataType: 'text'),
              ]);
      when(() => mockSchemaService.getColumns('tgt', 'public', 'tgt_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
                ColumnInfo(columnName: 'name', dataType: 'text'),
              ]);

      final result = await service.transfer(
        sourceConnectionId: 'src',
        sourceSchema: 'public',
        sourceTable: 'src_table',
        targetConnectionId: 'tgt',
        targetSchema: 'public',
        targetTable: 'tgt_table',
      );

      expect(result.rowsTransferred, 2);
      expect(result.rowsFailed, 0);
    });

    test('creates target table when createTargetIfNotExists is true',
        () async {
      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => DriverQueryResult(
          columnNames: ['id'],
          columnTypes: ['int4'],
          rows: [
            [1],
          ],
          affectedRows: 1,
        ),
      );

      when(() => mockTgtDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 1),
      );

      when(() => mockSchemaService.getColumns('src', 'public', 'src_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
              ]);

      await service.transfer(
        sourceConnectionId: 'src',
        sourceSchema: 'public',
        sourceTable: 'src_table',
        targetConnectionId: 'tgt',
        targetSchema: 'public',
        targetTable: 'new_table',
        createTargetIfNotExists: true,
      );

      // Verify CREATE TABLE was issued on target driver.
      final captured =
          verify(() => mockTgtDriver.execute(captureAny())).captured;
      final createSql = captured.firstWhere(
          (s) => (s as String).contains('CREATE TABLE'),
          orElse: () => '') as String;
      expect(createSql, contains('CREATE TABLE IF NOT EXISTS'));
    });

    test('reports batch failures as errors', () async {
      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => DriverQueryResult(
          columnNames: ['id'],
          columnTypes: ['int4'],
          rows: [
            [1],
            [2],
          ],
          affectedRows: 2,
        ),
      );

      when(() => mockTgtDriver.execute(any()))
          .thenThrow(Exception('insert failed'));

      when(() => mockSchemaService.getColumns('src', 'public', 'src_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
              ]);
      when(() => mockSchemaService.getColumns('tgt', 'public', 'tgt_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
              ]);

      final result = await service.transfer(
        sourceConnectionId: 'src',
        sourceSchema: 'public',
        sourceTable: 'src_table',
        targetConnectionId: 'tgt',
        targetSchema: 'public',
        targetTable: 'tgt_table',
      );

      expect(result.rowsFailed, 2);
      expect(result.errors, isNotEmpty);
    });

    test('invokes progress callback per batch', () async {
      // 5 rows with batch size 2 → 3 batches.
      when(() => mockSrcDriver.execute(any())).thenAnswer(
        (_) async => DriverQueryResult(
          columnNames: ['id'],
          columnTypes: ['int4'],
          rows: [
            [1],
            [2],
            [3],
            [4],
            [5],
          ],
          affectedRows: 5,
        ),
      );

      when(() => mockTgtDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 2),
      );

      when(() => mockSchemaService.getColumns('src', 'public', 'src_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
              ]);
      when(() => mockSchemaService.getColumns('tgt', 'public', 'tgt_table'))
          .thenAnswer((_) async => const [
                ColumnInfo(columnName: 'id', dataType: 'int4'),
              ]);

      final progressCalls = <(int, int)>[];

      await service.transfer(
        sourceConnectionId: 'src',
        sourceSchema: 'public',
        sourceTable: 'src_table',
        targetConnectionId: 'tgt',
        targetSchema: 'public',
        targetTable: 'tgt_table',
        batchSize: 2,
        onProgress: (c, t) => progressCalls.add((c, t)),
      );

      expect(progressCalls, hasLength(3));
      expect(progressCalls.first.$2, 3); // total batches
    });

    test('throws when source connection has no driver', () async {
      when(() => mockConnService.getDriver('bad')).thenReturn(null);

      expect(
        () => service.transfer(
          sourceConnectionId: 'bad',
          sourceSchema: 'public',
          sourceTable: 'src',
          targetConnectionId: 'tgt',
          targetSchema: 'public',
          targetTable: 'tgt',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
