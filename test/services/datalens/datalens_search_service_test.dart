// Tests for DatalensSearchService.
//
// Mocks DatabaseConnectionService and DatabaseDriverAdapter to verify
// SQL generation for PostgreSQL, result mapping to typed search models,
// and performance safeguards (timeout, table limits).
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/datalens_enums.dart';
import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/models/datalens_search_models.dart';
import 'package:codeops/services/datalens/database_connection_service.dart';
import 'package:codeops/services/datalens/datalens_search_service.dart';
import 'package:codeops/services/datalens/drivers/database_driver.dart';

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
  late DatalensSearchService service;

  setUp(() {
    mockConnService = MockDatabaseConnectionService();
    mockDriver = MockDatabaseDriverAdapter();
    service = DatalensSearchService(mockConnService);

    when(() => mockConnService.getDriver('conn-1')).thenReturn(mockDriver);
    when(() => mockDriver.dialect).thenReturn(SqlDialect.postgresql);
  });

  // -------------------------------------------------------------------------
  // searchMetadata
  // -------------------------------------------------------------------------

  group('searchMetadata', () {
    test('searches tables by name', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        final sql = _.positionalArguments[0] as String;
        if (sql.contains('information_schema.tables')) {
          return DriverQueryResult(
            columnNames: ['schema_name', 'object_name', 'parent_name', 'data_type'],
            rows: [
              ['public', 'users', null, null],
              ['public', 'user_settings', null, null],
            ],
          );
        }
        return DriverQueryResult(columnNames: [], rows: []);
      });

      final results = await service.searchMetadata(
        connectionId: 'conn-1',
        query: 'user',
        objectTypes: [MetadataObjectType.table],
      );

      expect(results, hasLength(2));
      expect(results[0].objectType, MetadataObjectType.table);
      expect(results[0].schema, 'public');
      expect(results[0].objectName, 'users');
      expect(results[0].matchHighlight, contains('**user**'));
    });

    test('searches columns with parent table', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        final sql = _.positionalArguments[0] as String;
        if (sql.contains('information_schema.columns')) {
          return DriverQueryResult(
            columnNames: ['schema_name', 'object_name', 'parent_name', 'data_type'],
            rows: [
              ['public', 'email', 'users', 'varchar'],
            ],
          );
        }
        return DriverQueryResult(columnNames: [], rows: []);
      });

      final results = await service.searchMetadata(
        connectionId: 'conn-1',
        query: 'email',
        objectTypes: [MetadataObjectType.column],
      );

      expect(results, hasLength(1));
      expect(results[0].objectType, MetadataObjectType.column);
      expect(results[0].parentName, 'users');
      expect(results[0].dataType, 'varchar');
    });

    test('searches functions', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        final sql = _.positionalArguments[0] as String;
        if (sql.contains('information_schema.routines')) {
          return DriverQueryResult(
            columnNames: ['schema_name', 'object_name', 'parent_name', 'data_type'],
            rows: [
              ['public', 'calculate_total', null, 'FUNCTION'],
            ],
          );
        }
        return DriverQueryResult(columnNames: [], rows: []);
      });

      final results = await service.searchMetadata(
        connectionId: 'conn-1',
        query: 'calc',
        objectTypes: [MetadataObjectType.function_],
      );

      expect(results, hasLength(1));
      expect(results[0].objectType, MetadataObjectType.function_);
      expect(results[0].objectName, 'calculate_total');
    });

    test('searches all types when none specified', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        return DriverQueryResult(
          columnNames: ['schema_name', 'object_name', 'parent_name', 'data_type'],
          rows: [
            ['public', 'test_obj', null, null],
          ],
        );
      });

      final results = await service.searchMetadata(
        connectionId: 'conn-1',
        query: 'test',
      );

      // Should have results from multiple type queries.
      expect(results.length, greaterThan(1));
    });

    test('applies schema filter', () async {
      String? capturedSql;
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        capturedSql = _.positionalArguments[0] as String;
        return DriverQueryResult(columnNames: [], rows: []);
      });

      await service.searchMetadata(
        connectionId: 'conn-1',
        query: 'test',
        schema: 'myschema',
        objectTypes: [MetadataObjectType.table],
      );

      expect(capturedSql, contains("'myschema'"));
    });

    test('returns empty for blank query', () async {
      final results = await service.searchMetadata(
        connectionId: 'conn-1',
        query: '  ',
      );
      expect(results, isEmpty);
    });

    test('throws for missing connection', () async {
      when(() => mockConnService.getDriver('bad')).thenReturn(null);

      expect(
        () => service.searchMetadata(connectionId: 'bad', query: 'x'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // searchData
  // -------------------------------------------------------------------------

  group('searchData', () {
    test('searches text columns and returns matching rows', () async {
      when(() => mockDriver.getTables('public')).thenAnswer(
        (_) async => [
          TableInfo(tableName: 'users', objectType: ObjectType.table),
        ],
      );
      when(() => mockDriver.getColumns('public', 'users')).thenAnswer(
        (_) async => [
          ColumnInfo(columnName: 'name', dataType: 'varchar', udtName: 'varchar'),
          ColumnInfo(columnName: 'age', dataType: 'integer', udtName: 'int4'),
        ],
      );
      when(() => mockDriver.getConstraints('public', 'users')).thenAnswer(
        (_) async => [
          ConstraintInfo(
            constraintName: 'pk',
            constraintType: ConstraintType.primaryKey,
            columns: ['id'],
          ),
        ],
      );
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        return DriverQueryResult(
          columnNames: ['id', 'name'],
          rows: [
            [1, 'John Doe'],
            [2, 'Jane Doe'],
          ],
        );
      });

      final results = await service.searchData(
        connectionId: 'conn-1',
        query: 'Doe',
        schema: 'public',
      );

      expect(results, hasLength(1));
      expect(results[0].table, 'users');
      expect(results[0].column, 'name');
      expect(results[0].rowCount, 2);
      expect(results[0].sampleRows[0].matchedValue, 'John Doe');
    });

    test('respects case sensitive flag', () async {
      String? capturedSql;
      when(() => mockDriver.getTables('public')).thenAnswer(
        (_) async => [
          TableInfo(tableName: 'items', objectType: ObjectType.table),
        ],
      );
      when(() => mockDriver.getColumns('public', 'items')).thenAnswer(
        (_) async => [
          ColumnInfo(columnName: 'title', dataType: 'text', udtName: 'text'),
        ],
      );
      when(() => mockDriver.getConstraints('public', 'items')).thenAnswer(
        (_) async => [],
      );
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        capturedSql = _.positionalArguments[0] as String;
        return DriverQueryResult(columnNames: [], rows: []);
      });

      await service.searchData(
        connectionId: 'conn-1',
        query: 'Test',
        schema: 'public',
        caseSensitive: true,
      );

      // Case-sensitive PostgreSQL uses LIKE not ILIKE.
      expect(capturedSql, isNotNull);
      expect(capturedSql, contains('LIKE'));
      expect(capturedSql, isNot(contains('ILIKE')));
    });

    test('uses regex for PostgreSQL', () async {
      String? capturedSql;
      when(() => mockDriver.getTables('public')).thenAnswer(
        (_) async => [
          TableInfo(tableName: 't1', objectType: ObjectType.table),
        ],
      );
      when(() => mockDriver.getColumns('public', 't1')).thenAnswer(
        (_) async => [
          ColumnInfo(columnName: 'col1', dataType: 'text', udtName: 'text'),
        ],
      );
      when(() => mockDriver.getConstraints('public', 't1')).thenAnswer(
        (_) async => [],
      );
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        capturedSql = _.positionalArguments[0] as String;
        return DriverQueryResult(columnNames: [], rows: []);
      });

      await service.searchData(
        connectionId: 'conn-1',
        query: r'^test.*$',
        schema: 'public',
        regex: true,
      );

      expect(capturedSql, isNotNull);
      expect(capturedSql, contains('~*'));
    });

    test('limits tables searched', () async {
      final tables = List.generate(
        30,
        (i) => TableInfo(tableName: 't$i', objectType: ObjectType.table),
      );
      when(() => mockDriver.getTables('public')).thenAnswer(
        (_) async => tables,
      );
      // We only expect getColumns to be called for maxTables=5 tables.
      when(() => mockDriver.getColumns('public', any())).thenAnswer(
        (_) async => [],
      );

      await service.searchData(
        connectionId: 'conn-1',
        query: 'test',
        schema: 'public',
        maxTables: 5,
      );

      // Verify we didn't try to get columns for tables beyond the limit.
      final calls = verify(
        () => mockDriver.getColumns('public', captureAny()),
      ).captured;
      expect(calls.length, 5);
    });

    test('reports progress via callback', () async {
      when(() => mockDriver.getTables('public')).thenAnswer(
        (_) async => [
          TableInfo(tableName: 'a', objectType: ObjectType.table),
          TableInfo(tableName: 'b', objectType: ObjectType.table),
        ],
      );
      when(() => mockDriver.getColumns('public', any())).thenAnswer(
        (_) async => [
          ColumnInfo(columnName: 'c1', dataType: 'text', udtName: 'text'),
        ],
      );
      when(() => mockDriver.getConstraints('public', any())).thenAnswer(
        (_) async => [],
      );
      when(() => mockDriver.execute(any())).thenAnswer(
        (_) async => DriverQueryResult(columnNames: [], rows: []),
      );

      final progressUpdates = <DataSearchProgress>[];
      await service.searchData(
        connectionId: 'conn-1',
        query: 'x',
        schema: 'public',
        onProgress: progressUpdates.add,
      );

      expect(progressUpdates.length, 2);
      expect(progressUpdates[0].currentTable, 1);
      expect(progressUpdates[0].totalTables, 2);
      expect(progressUpdates[1].currentTable, 2);
    });
  });

  // -------------------------------------------------------------------------
  // searchDdl
  // -------------------------------------------------------------------------

  group('searchDdl', () {
    test('searches view definitions', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        final sql = _.positionalArguments[0] as String;
        if (sql.contains('information_schema.views') &&
            sql.contains('view_definition')) {
          return DriverQueryResult(
            columnNames: ['schema_name', 'object_name', 'definition'],
            rows: [
              ['public', 'active_users', 'SELECT * FROM users WHERE active = true'],
            ],
          );
        }
        return DriverQueryResult(columnNames: [], rows: []);
      });

      final results = await service.searchDdl(
        connectionId: 'conn-1',
        query: 'active',
        objectTypes: [MetadataObjectType.view],
      );

      expect(results, hasLength(1));
      expect(results[0].objectType, MetadataObjectType.view);
      expect(results[0].objectName, 'active_users');
      expect(results[0].ddlSnippet, contains('active'));
    });

    test('searches function definitions', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        final sql = _.positionalArguments[0] as String;
        if (sql.contains('information_schema.routines') &&
            sql.contains('routine_definition')) {
          return DriverQueryResult(
            columnNames: ['schema_name', 'object_name', 'definition', 'routine_type'],
            rows: [
              ['public', 'calc_total', 'BEGIN RETURN a + b; END', 'FUNCTION'],
            ],
          );
        }
        return DriverQueryResult(columnNames: [], rows: []);
      });

      final results = await service.searchDdl(
        connectionId: 'conn-1',
        query: 'RETURN',
        objectTypes: [MetadataObjectType.function_],
      );

      expect(results, hasLength(1));
      expect(results[0].objectType, MetadataObjectType.function_);
      expect(results[0].objectName, 'calc_total');
    });

    test('searches trigger definitions', () async {
      when(() => mockDriver.execute(any())).thenAnswer((_) async {
        final sql = _.positionalArguments[0] as String;
        if (sql.contains('information_schema.triggers') &&
            sql.contains('action_statement')) {
          return DriverQueryResult(
            columnNames: ['schema_name', 'object_name', 'definition'],
            rows: [
              ['public', 'audit_trigger', 'EXECUTE FUNCTION audit_log()'],
            ],
          );
        }
        return DriverQueryResult(columnNames: [], rows: []);
      });

      final results = await service.searchDdl(
        connectionId: 'conn-1',
        query: 'audit',
        objectTypes: [MetadataObjectType.trigger],
      );

      expect(results, hasLength(1));
      expect(results[0].objectType, MetadataObjectType.trigger);
      expect(results[0].objectName, 'audit_trigger');
    });
  });
}
