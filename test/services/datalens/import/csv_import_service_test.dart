// Tests for CsvImportService.
//
// Mocks DatabaseConnectionService, QueryExecutionService,
// SchemaIntrospectionService, and DatabaseDriverAdapter to verify CSV
// parsing, delimiter detection, header handling, column mapping, batch
// inserts, conflict resolution (skip/update/error), dry-run mode, and
// truncate-before-import without touching the file system or database.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/services/datalens/database_connection_service.dart';
import 'package:codeops/services/datalens/drivers/database_driver.dart';
import 'package:codeops/services/datalens/import/csv_import_service.dart';

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
  late CsvImportService service;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(OnConflict.error);
  });

  setUp(() {
    mockConnService = MockDatabaseConnectionService();
    mockDriver = MockDatabaseDriverAdapter();
    service = CsvImportService(mockConnService);

    when(() => mockConnService.getDriver('conn-1')).thenReturn(mockDriver);
    when(() => mockDriver.dialect).thenReturn(SqlDialect.postgresql);

    tempDir = Directory.systemTemp.createTempSync('csv_import_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // -------------------------------------------------------------------------
  // previewCsv
  // -------------------------------------------------------------------------

  group('previewCsv', () {
    test('parses comma-delimited CSV with header row', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name,age,city\nAlice,30,NYC\nBob,25,LA\n');

      final preview = await service.previewCsv(file.path);

      expect(preview.detectedColumns, ['name', 'age', 'city']);
      expect(preview.previewRows, hasLength(2));
      expect(preview.previewRows[0], ['Alice', '30', 'NYC']);
      expect(preview.previewRows[1], ['Bob', '25', 'LA']);
      expect(preview.totalRows, 2);
      expect(preview.detectedDelimiter, ',');
    });

    test('auto-detects tab delimiter', () async {
      final file = File('${tempDir.path}/test.tsv');
      file.writeAsStringSync('name\tage\tCity\nAlice\t30\tNYC\n');

      final preview = await service.previewCsv(file.path);

      expect(preview.detectedDelimiter, '\t');
      expect(preview.detectedColumns, ['name', 'age', 'City']);
      expect(preview.previewRows, hasLength(1));
    });

    test('handles CSV without header row', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('Alice,30,NYC\nBob,25,LA\n');

      final preview = await service.previewCsv(file.path, hasHeader: false);

      expect(preview.detectedColumns, ['Column 1', 'Column 2', 'Column 3']);
      expect(preview.totalRows, 2);
    });

    test('handles quoted fields with commas', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name,address\n"Smith, John","123 Main St"\n');

      final preview = await service.previewCsv(file.path);

      expect(preview.detectedColumns, ['name', 'address']);
      expect(preview.previewRows[0][0], 'Smith, John');
      expect(preview.previewRows[0][1], '123 Main St');
    });

    test('returns empty preview for empty file', () async {
      final file = File('${tempDir.path}/empty.csv');
      file.writeAsStringSync('');

      final preview = await service.previewCsv(file.path);

      expect(preview.detectedColumns, isEmpty);
      expect(preview.previewRows, isEmpty);
      expect(preview.totalRows, 0);
    });

    test('throws for non-existent file', () async {
      expect(
        () => service.previewCsv('${tempDir.path}/nope.csv'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // importCsv
  // -------------------------------------------------------------------------

  group('importCsv', () {
    test('batch inserts rows and returns result', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name,age\nAlice,30\nBob,25\n');

      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 2),
      );

      final result = await service.importCsv(
        filePath: file.path,
        connectionId: 'conn-1',
        schema: 'public',
        targetTable: 'people',
        mappings: const [
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
          ColumnMapping(csvColumn: 'age', dbColumn: 'age'),
        ],
        options: const CsvImportOptions(),
      );

      expect(result.rowsImported, 2);
      expect(result.rowsFailed, 0);
      expect(result.errors, isEmpty);
    });

    test('skips mappings with null dbColumn', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name,age\nAlice,30\n');

      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 1),
      );

      final result = await service.importCsv(
        filePath: file.path,
        connectionId: 'conn-1',
        schema: 'public',
        targetTable: 'people',
        mappings: const [
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
          ColumnMapping(csvColumn: 'age'), // skipped — no dbColumn
        ],
        options: const CsvImportOptions(),
      );

      expect(result.rowsImported, 1);

      // Verify only one column was in the INSERT.
      final captured = verify(() => mockDriver.execute(captureAny())).captured;
      final sql = captured.first as String;
      expect(sql, contains('"name"'));
      expect(sql, isNot(contains('"age"')));
    });

    test('on conflict skip — skips rows on unique violation', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('id,name\n1,Alice\n2,Bob\n');

      when(() => mockDriver.execute(any()))
          .thenThrow(Exception('duplicate key violates unique constraint'));

      final result = await service.importCsv(
        filePath: file.path,
        connectionId: 'conn-1',
        schema: 'public',
        targetTable: 'people',
        mappings: const [
          ColumnMapping(csvColumn: 'id', dbColumn: 'id'),
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
        ],
        options: const CsvImportOptions(onConflict: OnConflict.skip),
      );

      expect(result.rowsSkipped, 2);
      expect(result.rowsFailed, 0);
    });

    test('on conflict error — records failures', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('id,name\n1,Alice\n2,Bob\n');

      when(() => mockDriver.execute(any()))
          .thenThrow(Exception('duplicate key violates unique constraint'));

      final result = await service.importCsv(
        filePath: file.path,
        connectionId: 'conn-1',
        schema: 'public',
        targetTable: 'people',
        mappings: const [
          ColumnMapping(csvColumn: 'id', dbColumn: 'id'),
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
        ],
        options: const CsvImportOptions(onConflict: OnConflict.error),
      );

      expect(result.rowsFailed, 2);
      expect(result.errors, hasLength(2));
    });

    test('dry run returns generated SQL without executing', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name,age\nAlice,30\n');

      final result = await service.importCsv(
        filePath: file.path,
        connectionId: 'conn-1',
        schema: 'public',
        targetTable: 'people',
        mappings: const [
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
          ColumnMapping(csvColumn: 'age', dbColumn: 'age'),
        ],
        options: const CsvImportOptions(dryRun: true),
      );

      expect(result.rowsImported, 1);
      expect(result.generatedSql, isNotEmpty);
      expect(result.generatedSql.first, contains('INSERT INTO'));

      // Driver should NOT have been called.
      verifyNever(() => mockDriver.execute(any()));
    });

    test('truncates table before import when option is set', () async {
      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name\nAlice\n');

      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => const DriverQueryResult(affectedRows: 1),
      );

      await service.importCsv(
        filePath: file.path,
        connectionId: 'conn-1',
        schema: 'public',
        targetTable: 'people',
        mappings: const [
          ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
        ],
        options: const CsvImportOptions(truncateBeforeImport: true),
      );

      // Verify TRUNCATE was called.
      verify(() => mockDriver.execute('TRUNCATE TABLE "public"."people"'))
          .called(1);
    });

    test('throws when no active connection', () async {
      when(() => mockConnService.getDriver('bad-conn')).thenReturn(null);

      final file = File('${tempDir.path}/test.csv');
      file.writeAsStringSync('name\nAlice\n');

      expect(
        () => service.importCsv(
          filePath: file.path,
          connectionId: 'bad-conn',
          schema: 'public',
          targetTable: 'people',
          mappings: const [
            ColumnMapping(csvColumn: 'name', dbColumn: 'name'),
          ],
          options: const CsvImportOptions(),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
