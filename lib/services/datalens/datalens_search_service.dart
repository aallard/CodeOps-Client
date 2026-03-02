/// Search service for DataLens.
///
/// Provides three search modes: metadata search (object names), full-text
/// data search (row values), and DDL search (object definitions). Uses
/// the driver abstraction to generate database-specific SQL for PostgreSQL,
/// MySQL/MariaDB, SQLite, and SQL Server.
library;

import '../../models/datalens_enums.dart';
import '../../models/datalens_search_models.dart';
import '../logging/log_service.dart';
import 'database_connection_service.dart';
import 'drivers/database_driver.dart';

/// Service for searching database metadata, data, and DDL.
///
/// Delegates to the active [DatabaseDriverAdapter] for raw SQL execution
/// and translates [DriverQueryResult] rows into typed search models.
class DatalensSearchService {
  static const String _tag = 'DatalensSearchService';

  final DatabaseConnectionService _connectionService;

  /// Creates a [DatalensSearchService].
  DatalensSearchService(this._connectionService);

  // -------------------------------------------------------------------------
  // Metadata Search
  // -------------------------------------------------------------------------

  /// Searches database metadata (object names) across system catalogs.
  ///
  /// Supports searching table names, view names, column names, function names,
  /// sequence names, index names, constraint names, and trigger names.
  Future<List<MetadataSearchResult>> searchMetadata({
    required String connectionId,
    required String query,
    String? schema,
    List<MetadataObjectType>? objectTypes,
    int limit = 100,
  }) async {
    log.d(_tag, 'searchMetadata($connectionId, "$query", schema=$schema)');
    if (query.trim().isEmpty) return [];

    final driver = _requireDriver(connectionId);
    final dialect = driver.dialect;
    final results = <MetadataSearchResult>[];
    final types = objectTypes ?? MetadataObjectType.values;
    final escapedQuery = _escapeSql(query);

    for (final type in types) {
      if (results.length >= limit) break;

      final sql = _metadataSearchSql(dialect, type, escapedQuery, schema);
      if (sql == null) continue;

      try {
        final result = await driver.execute(sql);
        for (final row in result.rows) {
          if (results.length >= limit) break;
          final m = _rowMap(result.columnNames, row);
          results.add(MetadataSearchResult(
            objectType: type,
            schema: _toStr(m['schema_name']) ?? '',
            objectName: _toStr(m['object_name']) ?? '',
            parentName: _toStr(m['parent_name']),
            dataType: _toStr(m['data_type']),
            matchHighlight: _highlight(
              _toStr(m['object_name']) ?? '',
              query,
            ),
          ));
        }
      } catch (e) {
        log.w(_tag, 'Metadata search for $type failed: $e');
      }
    }

    return results;
  }

  // -------------------------------------------------------------------------
  // Data Search
  // -------------------------------------------------------------------------

  /// Searches actual row data in text/varchar columns.
  ///
  /// Only searches text-like columns, respects per-table and total limits,
  /// and reports progress via [onProgress].
  Future<List<DataSearchResult>> searchData({
    required String connectionId,
    required String query,
    required String schema,
    List<String>? tables,
    bool caseSensitive = false,
    bool regex = false,
    int maxRowsPerTable = 50,
    int maxTables = 20,
    void Function(DataSearchProgress)? onProgress,
  }) async {
    log.d(_tag, 'searchData($connectionId, "$query", $schema)');
    if (query.trim().isEmpty) return [];

    final driver = _requireDriver(connectionId);
    final dialect = driver.dialect;
    final results = <DataSearchResult>[];

    // Get tables to search.
    List<String> tablesToSearch;
    if (tables != null && tables.isNotEmpty) {
      tablesToSearch = tables.take(maxTables).toList();
    } else {
      final tablesResult = await driver.getTables(schema);
      tablesToSearch = tablesResult
          .where((t) => t.objectType == ObjectType.table)
          .map((t) => t.tableName ?? '')
          .where((n) => n.isNotEmpty)
          .take(maxTables)
          .toList();
    }

    final stopwatch = Stopwatch()..start();

    for (var i = 0; i < tablesToSearch.length; i++) {
      // Timeout guard: 30 seconds max.
      if (stopwatch.elapsed.inSeconds > 30) {
        log.w(_tag, 'Data search timed out after 30s');
        break;
      }

      final table = tablesToSearch[i];
      onProgress?.call(DataSearchProgress(
        currentTable: i + 1,
        totalTables: tablesToSearch.length,
        currentTableName: table,
      ));

      try {
        // Get text-like columns for this table.
        final columns = await driver.getColumns(schema, table);
        final textColumns = columns
            .where((c) => _isTextLikeColumn(c.dataType ?? '', c.udtName ?? ''))
            .map((c) => c.columnName ?? '')
            .where((n) => n.isNotEmpty)
            .toList();

        if (textColumns.isEmpty) continue;

        // Get primary key columns.
        final constraints = await driver.getConstraints(schema, table);
        final pkColumns = constraints
            .where((c) => c.constraintType?.name == 'primaryKey')
            .expand((c) => c.columns ?? <String>[])
            .toList();

        // Search each text column.
        for (final column in textColumns) {
          if (stopwatch.elapsed.inSeconds > 30) break;

          final matchExpr = _dataMatchExpr(
            dialect, column, query, caseSensitive, regex,
          );
          if (matchExpr == null) continue;

          final qualifiedTable = dialect.qualifyTable(schema, table);
          final selectCols = [
            ...pkColumns.map((pk) => dialect.quoteIdentifier(pk)),
            dialect.quoteIdentifier(column),
          ];

          final sql = 'SELECT ${selectCols.join(', ')} '
              'FROM $qualifiedTable '
              'WHERE $matchExpr '
              'LIMIT $maxRowsPerTable';

          try {
            final result = await driver.execute(sql);
            if (result.rows.isEmpty) continue;

            final sampleRows = result.rows.map((row) {
              final rowMap = _rowMap(result.columnNames, row);
              final pk = <String, dynamic>{};
              for (final pkCol in pkColumns) {
                pk[pkCol] = rowMap[pkCol];
              }
              final matchedValue = _toStr(rowMap[column]) ?? '';
              return DataSearchRow(
                primaryKey: pk,
                matchedValue: matchedValue,
                matchHighlight: _highlight(matchedValue, query),
              );
            }).toList();

            results.add(DataSearchResult(
              schema: schema,
              table: table,
              column: column,
              rowCount: sampleRows.length,
              sampleRows: sampleRows,
            ));
          } catch (e) {
            log.w(_tag, 'Data search on $schema.$table.$column failed: $e');
          }
        }
      } catch (e) {
        log.w(_tag, 'Data search on $schema.$table failed: $e');
      }
    }

    stopwatch.stop();
    log.i(_tag,
        'Data search complete: ${results.length} results in ${stopwatch.elapsed}');
    return results;
  }

  // -------------------------------------------------------------------------
  // DDL Search
  // -------------------------------------------------------------------------

  /// Searches across DDL / object definitions.
  ///
  /// Fetches DDL for views, functions, triggers, and tables, then searches
  /// the text for the query string.
  Future<List<DdlSearchResult>> searchDdl({
    required String connectionId,
    required String query,
    String? schema,
    List<MetadataObjectType>? objectTypes,
    bool caseSensitive = false,
    int limit = 100,
  }) async {
    log.d(_tag, 'searchDdl($connectionId, "$query", schema=$schema)');
    if (query.trim().isEmpty) return [];

    final driver = _requireDriver(connectionId);
    final dialect = driver.dialect;
    final results = <DdlSearchResult>[];
    final types = objectTypes ??
        [
          MetadataObjectType.view,
          MetadataObjectType.function_,
          MetadataObjectType.trigger,
          MetadataObjectType.table,
        ];
    final escapedQuery = _escapeSql(query);

    // Search view definitions.
    if (types.contains(MetadataObjectType.view)) {
      final sql = _ddlViewSearchSql(dialect, escapedQuery, schema, caseSensitive);
      if (sql != null) {
        try {
          final result = await driver.execute(sql);
          for (final row in result.rows) {
            if (results.length >= limit) break;
            final m = _rowMap(result.columnNames, row);
            final ddl = _toStr(m['definition']) ?? '';
            results.add(DdlSearchResult(
              objectType: MetadataObjectType.view,
              schema: _toStr(m['schema_name']) ?? '',
              objectName: _toStr(m['object_name']) ?? '',
              ddlSnippet: _extractSnippet(ddl, query, caseSensitive),
              matchLine: _findMatchLine(ddl, query, caseSensitive),
              matchHighlight: _highlight(
                _toStr(m['object_name']) ?? '', query,
              ),
            ));
          }
        } catch (e) {
          log.w(_tag, 'DDL search for views failed: $e');
        }
      }
    }

    // Search function/procedure definitions.
    if (types.contains(MetadataObjectType.function_) ||
        types.contains(MetadataObjectType.procedure)) {
      final sql =
          _ddlRoutineSearchSql(dialect, escapedQuery, schema, caseSensitive);
      if (sql != null) {
        try {
          final result = await driver.execute(sql);
          for (final row in result.rows) {
            if (results.length >= limit) break;
            final m = _rowMap(result.columnNames, row);
            final ddl = _toStr(m['definition']) ?? '';
            final routineType = _toStr(m['routine_type']) ?? '';
            results.add(DdlSearchResult(
              objectType: routineType.toLowerCase().contains('procedure')
                  ? MetadataObjectType.procedure
                  : MetadataObjectType.function_,
              schema: _toStr(m['schema_name']) ?? '',
              objectName: _toStr(m['object_name']) ?? '',
              ddlSnippet: _extractSnippet(ddl, query, caseSensitive),
              matchLine: _findMatchLine(ddl, query, caseSensitive),
              matchHighlight: _highlight(
                _toStr(m['object_name']) ?? '', query,
              ),
            ));
          }
        } catch (e) {
          log.w(_tag, 'DDL search for routines failed: $e');
        }
      }
    }

    // Search trigger definitions.
    if (types.contains(MetadataObjectType.trigger)) {
      final sql =
          _ddlTriggerSearchSql(dialect, escapedQuery, schema, caseSensitive);
      if (sql != null) {
        try {
          final result = await driver.execute(sql);
          for (final row in result.rows) {
            if (results.length >= limit) break;
            final m = _rowMap(result.columnNames, row);
            final ddl = _toStr(m['definition']) ?? '';
            results.add(DdlSearchResult(
              objectType: MetadataObjectType.trigger,
              schema: _toStr(m['schema_name']) ?? '',
              objectName: _toStr(m['object_name']) ?? '',
              ddlSnippet: _extractSnippet(ddl, query, caseSensitive),
              matchLine: _findMatchLine(ddl, query, caseSensitive),
              matchHighlight: _highlight(
                _toStr(m['object_name']) ?? '', query,
              ),
            ));
          }
        } catch (e) {
          log.w(_tag, 'DDL search for triggers failed: $e');
        }
      }
    }

    // Search table DDL (fetch via driver and search locally).
    if (types.contains(MetadataObjectType.table) && results.length < limit) {
      try {
        final schemas = schema != null
            ? [schema]
            : (await driver.getSchemas()).map((s) => s.name ?? '').toList();

        for (final s in schemas) {
          if (results.length >= limit) break;
          final tables = await driver.getTables(s);
          for (final t in tables) {
            if (results.length >= limit) break;
            if (t.tableName == null) continue;
            try {
              final ddl = await driver.getTableDdl(s, t.tableName!);
              final matches = caseSensitive
                  ? ddl.contains(query)
                  : ddl.toLowerCase().contains(query.toLowerCase());
              if (matches) {
                results.add(DdlSearchResult(
                  objectType: MetadataObjectType.table,
                  schema: s,
                  objectName: t.tableName!,
                  ddlSnippet: _extractSnippet(ddl, query, caseSensitive),
                  matchLine: _findMatchLine(ddl, query, caseSensitive),
                  matchHighlight: _highlight(t.tableName!, query),
                ));
              }
            } catch (e) {
              // Skip tables whose DDL can't be fetched.
            }
          }
        }
      } catch (e) {
        log.w(_tag, 'DDL search for tables failed: $e');
      }
    }

    return results;
  }

  // =========================================================================
  // Metadata Search SQL
  // =========================================================================

  String? _metadataSearchSql(
    SqlDialect dialect,
    MetadataObjectType type,
    String query,
    String? schema,
  ) {
    final schemaFilter = schema != null
        ? _schemaFilterClause(dialect, schema, type)
        : '';
    final likeOp = _likeOp(dialect);

    return switch (type) {
      MetadataObjectType.table => _tableSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.view => _viewSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.column => _columnSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.function_ ||
      MetadataObjectType.procedure => _routineSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.sequence => _sequenceSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.index_ => _indexSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.constraint => _constraintSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.trigger => _triggerSearchSql(dialect, query, likeOp, schemaFilter, schema),
      MetadataObjectType.schema => _schemaSearchSql(dialect, query, likeOp),
    };
  }

  String _likeOp(SqlDialect dialect) {
    return dialect.driver == DatabaseDriver.postgresql ? 'ILIKE' : 'LIKE';
  }

  String _schemaFilterClause(
    SqlDialect dialect,
    String schema,
    MetadataObjectType type,
  ) {
    final col = switch (type) {
      MetadataObjectType.index_ when dialect.driver == DatabaseDriver.postgresql =>
        'schemaname',
      MetadataObjectType.table ||
      MetadataObjectType.view => 'table_schema',
      MetadataObjectType.column => 'table_schema',
      MetadataObjectType.function_ ||
      MetadataObjectType.procedure => 'routine_schema',
      MetadataObjectType.sequence => 'sequence_schema',
      MetadataObjectType.constraint => 'constraint_schema',
      MetadataObjectType.trigger => 'trigger_schema',
      _ => 'table_schema',
    };
    return " AND $col = '$schema'";
  }

  String? _tableSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT table_schema AS schema_name, table_name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_name $likeOp '%$query%'$schemaFilter''',
      DatabaseDriver.sqlite => '''
SELECT '' AS schema_name, name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM sqlite_master WHERE type = 'table' AND name LIKE '%$query%'$schemaFilter''',
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, t.name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _viewSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT table_schema AS schema_name, table_name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM information_schema.views
WHERE table_name $likeOp '%$query%'$schemaFilter''',
      DatabaseDriver.sqlite => '''
SELECT '' AS schema_name, name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM sqlite_master WHERE type = 'view' AND name LIKE '%$query%'$schemaFilter''',
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, v.name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM sys.views v JOIN sys.schemas s ON v.schema_id = s.schema_id
WHERE v.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _columnSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT table_schema AS schema_name, column_name AS object_name,
       table_name AS parent_name, data_type
FROM information_schema.columns
WHERE column_name $likeOp '%$query%'$schemaFilter''',
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, c.name AS object_name,
       t.name AS parent_name, ty.name AS data_type
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE c.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _routineSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT routine_schema AS schema_name, routine_name AS object_name,
       NULL AS parent_name, routine_type AS data_type
FROM information_schema.routines
WHERE routine_name $likeOp '%$query%'${schemaFilter.replaceAll('table_schema', 'routine_schema')}''',
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, o.name AS object_name,
       NULL AS parent_name, o.type_desc AS data_type
FROM sys.objects o JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type IN ('FN', 'IF', 'TF', 'P')
  AND o.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _sequenceSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql => '''
SELECT sequence_schema AS schema_name, sequence_name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM information_schema.sequences
WHERE sequence_name $likeOp '%$query%'${schemaFilter.replaceAll('table_schema', 'sequence_schema')}''',
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb ||
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, seq.name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM sys.sequences seq JOIN sys.schemas s ON seq.schema_id = s.schema_id
WHERE seq.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _indexSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql => '''
SELECT schemaname AS schema_name, indexname AS object_name,
       tablename AS parent_name, NULL AS data_type
FROM pg_indexes
WHERE indexname $likeOp '%$query%'$schemaFilter''',
      DatabaseDriver.mysql || DatabaseDriver.mariadb => '''
SELECT table_schema AS schema_name, index_name AS object_name,
       table_name AS parent_name, NULL AS data_type
FROM information_schema.statistics
WHERE index_name $likeOp '%$query%'$schemaFilter
GROUP BY table_schema, index_name, table_name''',
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, i.name AS object_name,
       t.name AS parent_name, NULL AS data_type
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _constraintSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT constraint_schema AS schema_name, constraint_name AS object_name,
       table_name AS parent_name, constraint_type AS data_type
FROM information_schema.table_constraints
WHERE constraint_name $likeOp '%$query%'${schemaFilter.replaceAll('table_schema', 'constraint_schema')}''',
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, dc.name AS object_name,
       t.name AS parent_name, dc.type_desc AS data_type
FROM sys.objects dc
JOIN sys.tables t ON dc.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE dc.type IN ('PK', 'UQ', 'F', 'C', 'D')
  AND dc.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _triggerSearchSql(
      SqlDialect dialect, String query, String likeOp, String schemaFilter, String? schema) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT trigger_schema AS schema_name, trigger_name AS object_name,
       event_object_table AS parent_name, NULL AS data_type
FROM information_schema.triggers
WHERE trigger_name $likeOp '%$query%'${schemaFilter.replaceAll('table_schema', 'trigger_schema')}''',
      DatabaseDriver.sqlite => '''
SELECT '' AS schema_name, name AS object_name,
       tbl_name AS parent_name, NULL AS data_type
FROM sqlite_master WHERE type = 'trigger' AND name LIKE '%$query%'$schemaFilter''',
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, tr.name AS object_name,
       t.name AS parent_name, NULL AS data_type
FROM sys.triggers tr
JOIN sys.tables t ON tr.parent_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE tr.name LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _schemaSearchSql(SqlDialect dialect, String query, String likeOp) {
    return switch (dialect.driver) {
      DatabaseDriver.postgresql => '''
SELECT schema_name AS schema_name, schema_name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM information_schema.schemata
WHERE schema_name $likeOp '%$query%'
  AND schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')''',
      DatabaseDriver.mysql || DatabaseDriver.mariadb => '''
SELECT schema_name AS schema_name, schema_name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM information_schema.schemata
WHERE schema_name $likeOp '%$query%'
  AND schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')''',
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT name AS schema_name, name AS object_name,
       NULL AS parent_name, NULL AS data_type
FROM sys.schemas
WHERE name LIKE '%$query%'
  AND name NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest')''',
    };
  }

  // =========================================================================
  // DDL Search SQL
  // =========================================================================

  String? _ddlViewSearchSql(
    SqlDialect dialect,
    String query,
    String? schema,
    bool caseSensitive,
  ) {
    final matchOp = caseSensitive ? 'LIKE' : _likeOp(dialect);
    final schemaClause = schema != null ? " AND table_schema = '$schema'" : '';

    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT table_schema AS schema_name, table_name AS object_name,
       view_definition AS definition
FROM information_schema.views
WHERE view_definition $matchOp '%$query%'$schemaClause''',
      DatabaseDriver.sqlite => '''
SELECT '' AS schema_name, name AS object_name, sql AS definition
FROM sqlite_master WHERE type = 'view' AND sql LIKE '%$query%'$schemaClause''',
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, v.name AS object_name,
       m.definition AS definition
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id
JOIN sys.sql_modules m ON v.object_id = m.object_id
WHERE m.definition LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _ddlRoutineSearchSql(
    SqlDialect dialect,
    String query,
    String? schema,
    bool caseSensitive,
  ) {
    final matchOp = caseSensitive ? 'LIKE' : _likeOp(dialect);
    final schemaClause =
        schema != null ? " AND routine_schema = '$schema'" : '';

    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT routine_schema AS schema_name, routine_name AS object_name,
       routine_definition AS definition, routine_type
FROM information_schema.routines
WHERE routine_definition $matchOp '%$query%'$schemaClause''',
      DatabaseDriver.sqlite => null,
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, o.name AS object_name,
       m.definition AS definition, o.type_desc AS routine_type
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
JOIN sys.sql_modules m ON o.object_id = m.object_id
WHERE o.type IN ('FN', 'IF', 'TF', 'P')
  AND m.definition LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  String? _ddlTriggerSearchSql(
    SqlDialect dialect,
    String query,
    String? schema,
    bool caseSensitive,
  ) {
    final matchOp = caseSensitive ? 'LIKE' : _likeOp(dialect);

    return switch (dialect.driver) {
      DatabaseDriver.postgresql ||
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => '''
SELECT trigger_schema AS schema_name, trigger_name AS object_name,
       action_statement AS definition
FROM information_schema.triggers
WHERE action_statement $matchOp '%$query%'${schema != null ? " AND trigger_schema = '$schema'" : ''}''',
      DatabaseDriver.sqlite => '''
SELECT '' AS schema_name, name AS object_name, sql AS definition
FROM sqlite_master WHERE type = 'trigger' AND sql LIKE '%$query%'$schema''',
      DatabaseDriver.sqlServer => '''
SELECT s.name AS schema_name, tr.name AS object_name,
       m.definition AS definition
FROM sys.triggers tr
JOIN sys.tables t ON tr.parent_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.sql_modules m ON tr.object_id = m.object_id
WHERE m.definition LIKE '%$query%'${schema != null ? " AND s.name = '$schema'" : ''}''',
    };
  }

  // =========================================================================
  // Data Search Helpers
  // =========================================================================

  /// Returns a WHERE clause expression for matching a column's value.
  String? _dataMatchExpr(
    SqlDialect dialect,
    String column,
    String query,
    bool caseSensitive,
    bool regex,
  ) {
    final quoted = dialect.quoteIdentifier(column);
    final escaped = _escapeSql(query);

    if (regex) {
      return switch (dialect.driver) {
        DatabaseDriver.postgresql =>
          caseSensitive
              ? "$quoted::text ~ '$escaped'"
              : "$quoted::text ~* '$escaped'",
        DatabaseDriver.mysql || DatabaseDriver.mariadb =>
          "$quoted REGEXP '$escaped'",
        _ => null,
      };
    }

    if (caseSensitive) {
      return switch (dialect.driver) {
        DatabaseDriver.postgresql => "$quoted::text LIKE '%$escaped%'",
        _ => "$quoted LIKE '%$escaped%'",
      };
    }

    return switch (dialect.driver) {
      DatabaseDriver.postgresql => "$quoted::text ILIKE '%$escaped%'",
      DatabaseDriver.mysql ||
      DatabaseDriver.mariadb => "LOWER($quoted) LIKE LOWER('%$escaped%')",
      DatabaseDriver.sqlite => "$quoted LIKE '%$escaped%'",
      DatabaseDriver.sqlServer => "LOWER(CAST($quoted AS NVARCHAR(MAX))) LIKE LOWER('%$escaped%')",
    };
  }

  /// Returns true if the column data type is text-like (searchable).
  bool _isTextLikeColumn(String dataType, String udtName) {
    final dt = dataType.toLowerCase();
    final udt = udtName.toLowerCase();
    return dt.contains('char') ||
        dt.contains('text') ||
        dt.contains('varchar') ||
        dt.contains('clob') ||
        dt.contains('string') ||
        udt == 'text' ||
        udt == 'varchar' ||
        udt == 'bpchar' ||
        udt == 'name' ||
        udt == 'xml' ||
        udt == 'json' ||
        udt == 'jsonb';
  }

  // =========================================================================
  // Text Helpers
  // =========================================================================

  /// Highlights the matching portion of text by wrapping in **bold** markers.
  String _highlight(String text, String query) {
    if (query.isEmpty) return text;
    final idx = text.toLowerCase().indexOf(query.toLowerCase());
    if (idx == -1) return text;
    return '${text.substring(0, idx)}**${text.substring(idx, idx + query.length)}**${text.substring(idx + query.length)}';
  }

  /// Extracts a context snippet around the first match in DDL text.
  String _extractSnippet(String ddl, String query, bool caseSensitive) {
    final searchDdl = caseSensitive ? ddl : ddl.toLowerCase();
    final searchQuery = caseSensitive ? query : query.toLowerCase();
    final idx = searchDdl.indexOf(searchQuery);
    if (idx == -1) return ddl.length > 100 ? '${ddl.substring(0, 100)}...' : ddl;

    final start = (idx - 40).clamp(0, ddl.length);
    final end = (idx + query.length + 40).clamp(0, ddl.length);
    var snippet = ddl.substring(start, end).replaceAll('\n', ' ');
    if (start > 0) snippet = '...$snippet';
    if (end < ddl.length) snippet = '$snippet...';
    return snippet;
  }

  /// Finds the 1-based line number of the first match in DDL text.
  int _findMatchLine(String ddl, String query, bool caseSensitive) {
    final searchDdl = caseSensitive ? ddl : ddl.toLowerCase();
    final searchQuery = caseSensitive ? query : query.toLowerCase();
    final idx = searchDdl.indexOf(searchQuery);
    if (idx == -1) return 0;
    return ddl.substring(0, idx).split('\n').length;
  }

  // =========================================================================
  // Internal Helpers
  // =========================================================================

  DatabaseDriverAdapter _requireDriver(String connectionId) {
    final driver = _connectionService.getDriver(connectionId);
    if (driver == null) {
      throw StateError('No active connection for $connectionId');
    }
    return driver;
  }

  Map<String, dynamic> _rowMap(List<String> cols, List<dynamic> row) {
    final map = <String, dynamic>{};
    for (var i = 0; i < cols.length && i < row.length; i++) {
      map[cols[i]] = row[i];
    }
    return map;
  }

  String? _toStr(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  /// Escapes single quotes in SQL string literals.
  String _escapeSql(String value) => value.replaceAll("'", "''");
}
