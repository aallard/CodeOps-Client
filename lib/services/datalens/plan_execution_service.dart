/// Service for executing EXPLAIN plans and parsing them into a common model.
///
/// Supports PostgreSQL (EXPLAIN FORMAT JSON), MySQL (EXPLAIN FORMAT=JSON),
/// SQLite (EXPLAIN QUERY PLAN), and SQL Server (informational only).
/// Parses each format into a common [PlanNode] tree for visualization.
///
/// DataLens is 100% client-side — plans are fetched by running EXPLAIN
/// via the [DatabaseDriverAdapter].
library;

import 'dart:convert';

import '../../models/datalens_enums.dart';
import '../logging/log_service.dart';
import 'database_connection_service.dart';
import 'drivers/database_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlanNode Model
// ─────────────────────────────────────────────────────────────────────────────

/// A single node in a query execution plan tree.
///
/// Maps to the common fields across PostgreSQL, MySQL, and SQLite plan
/// output. Fields that are only available with EXPLAIN ANALYZE (actual
/// rows, actual time, actual loops) are nullable.
class PlanNode {
  /// Node type (e.g., Seq Scan, Index Scan, Hash Join, Sort, Aggregate).
  final String nodeType;

  /// Relationship to parent (e.g., Outer, Inner, Subquery).
  final String? relationship;

  /// Total estimated cost.
  final double totalCost;

  /// Startup cost (cost before first row is returned).
  final double startupCost;

  /// Estimated number of rows.
  final double planRows;

  /// Estimated average row width in bytes.
  final int planWidth;

  /// Actual rows returned (ANALYZE only).
  final double? actualRows;

  /// Actual time in milliseconds (ANALYZE only).
  final double? actualTime;

  /// Actual number of loops (ANALYZE only).
  final int? actualLoops;

  /// Child plan nodes.
  final List<PlanNode> children;

  /// Filter condition applied at this node.
  final String? filter;

  /// Index name (for index scans).
  final String? indexName;

  /// Table name (for scan nodes).
  final String? tableName;

  /// Schema name (for scan nodes).
  final String? schemaName;

  /// Join type (for join nodes).
  final String? joinType;

  /// Sort key (for sort nodes).
  final List<String>? sortKey;

  /// Hash condition (for hash join nodes).
  final String? hashCondition;

  /// Output columns.
  final List<String>? output;

  /// Alias for the table/subquery.
  final String? alias;

  /// Scan direction (Forward, Backward).
  final String? scanDirection;

  /// Index condition (for index scans).
  final String? indexCondition;

  /// Rows removed by filter.
  final double? rowsRemovedByFilter;

  /// Actual startup time in ms (ANALYZE only).
  final double? actualStartupTime;

  /// Actual total time in ms (ANALYZE only).
  final double? actualTotalTime;

  /// Creates a [PlanNode].
  const PlanNode({
    required this.nodeType,
    this.relationship,
    this.totalCost = 0,
    this.startupCost = 0,
    this.planRows = 0,
    this.planWidth = 0,
    this.actualRows,
    this.actualTime,
    this.actualLoops,
    this.children = const [],
    this.filter,
    this.indexName,
    this.tableName,
    this.schemaName,
    this.joinType,
    this.sortKey,
    this.hashCondition,
    this.output,
    this.alias,
    this.scanDirection,
    this.indexCondition,
    this.rowsRemovedByFilter,
    this.actualStartupTime,
    this.actualTotalTime,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Result
// ─────────────────────────────────────────────────────────────────────────────

/// Complete execution plan result with summary statistics.
class PlanResult {
  /// Root node of the plan tree.
  final PlanNode root;

  /// Planning time in ms (ANALYZE only).
  final double? planningTime;

  /// Execution time in ms (ANALYZE only).
  final double? executionTime;

  /// Raw JSON/text output for the Raw tab.
  final String rawOutput;

  /// Whether this plan includes ANALYZE (actual) data.
  final bool isAnalyze;

  /// The total number of nodes in the plan tree.
  int get nodeCount => _countNodes(root);

  /// Total cost of the root node.
  double get totalCost => root.totalCost;

  /// Estimated total rows from the root node.
  double get estimatedRows => root.planRows;

  /// Returns the most expensive node by total cost.
  PlanNode get mostExpensiveNode => _findMostExpensive(root);

  /// Creates a [PlanResult].
  const PlanResult({
    required this.root,
    this.planningTime,
    this.executionTime,
    required this.rawOutput,
    this.isAnalyze = false,
  });

  static int _countNodes(PlanNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNodes(child);
    }
    return count;
  }

  static PlanNode _findMostExpensive(PlanNode node) {
    var most = node;
    for (final child in node.children) {
      final childMost = _findMostExpensive(child);
      if (childMost.totalCost > most.totalCost) {
        most = childMost;
      }
    }
    return most;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Execution Service
// ─────────────────────────────────────────────────────────────────────────────

/// Executes EXPLAIN plans and parses them into [PlanResult] trees.
///
/// Uses [DatabaseConnectionService] to obtain the active driver and
/// constructs the appropriate EXPLAIN syntax for each database engine.
class PlanExecutionService {
  static const String _tag = 'PlanExecutionService';

  /// The connection service for obtaining active drivers.
  final DatabaseConnectionService _connectionService;

  /// Creates a [PlanExecutionService].
  PlanExecutionService(this._connectionService);

  /// Executes EXPLAIN (FORMAT JSON) and returns a parsed [PlanResult].
  ///
  /// Throws [StateError] if no active connection for [connectionId].
  Future<PlanResult> executeExplain(
    String connectionId,
    String sql,
  ) async {
    log.d(_tag, 'executeExplain($connectionId)');
    final driver = _requireDriver(connectionId);
    return _executeAndParse(driver, sql, analyze: false);
  }

  /// Executes EXPLAIN (ANALYZE, FORMAT JSON) and returns a parsed [PlanResult].
  ///
  /// **Warning:** ANALYZE actually executes the query. DML statements
  /// will modify data.
  ///
  /// Throws [StateError] if no active connection for [connectionId].
  Future<PlanResult> executeExplainAnalyze(
    String connectionId,
    String sql,
  ) async {
    log.d(_tag, 'executeExplainAnalyze($connectionId)');
    final driver = _requireDriver(connectionId);
    return _executeAndParse(driver, sql, analyze: true);
  }

  /// Parses a JSON plan string (from PostgreSQL format) into a [PlanResult].
  ///
  /// Exposed for testing.
  static PlanResult parseJsonPlan(String json, {bool isAnalyze = false}) {
    return _parsePostgresqlJsonPlan(json, isAnalyze: isAnalyze);
  }

  /// Parses a plan node map into a [PlanNode] tree.
  ///
  /// Exposed for testing.
  static PlanNode parseNodeTree(Map<String, dynamic> map) {
    return _parsePlanNodeMap(map);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal
  // ─────────────────────────────────────────────────────────────────────────

  /// Obtains the active driver or throws [StateError].
  DatabaseDriverAdapter _requireDriver(String connectionId) {
    final driver = _connectionService.getDriver(connectionId);
    if (driver == null) {
      throw StateError('No active connection for $connectionId');
    }
    return driver;
  }

  /// Runs EXPLAIN with the correct syntax for the driver and parses.
  Future<PlanResult> _executeAndParse(
    DatabaseDriverAdapter driver,
    String sql, {
    required bool analyze,
  }) async {
    final rawOutput = await _executeExplainRaw(driver, sql, analyze: analyze);
    return _parsePlan(driver.driverType, rawOutput, isAnalyze: analyze);
  }

  /// Runs the EXPLAIN command with engine-specific syntax.
  Future<String> _executeExplainRaw(
    DatabaseDriverAdapter driver,
    String sql, {
    required bool analyze,
  }) async {
    switch (driver.driverType) {
      case DatabaseDriver.postgresql:
        final prefix = analyze
            ? 'EXPLAIN (ANALYZE, FORMAT JSON)'
            : 'EXPLAIN (FORMAT JSON)';
        final result = await driver.execute('$prefix $sql');
        // PostgreSQL returns JSON plan as a single row/column.
        if (result.rows.isNotEmpty && result.rows.first.isNotEmpty) {
          return result.rows.first.first.toString();
        }
        return '[]';

      case DatabaseDriver.mysql:
      case DatabaseDriver.mariadb:
        final prefix =
            analyze ? 'EXPLAIN ANALYZE' : 'EXPLAIN FORMAT=JSON';
        final result = await driver.execute('$prefix $sql');
        if (result.rows.isNotEmpty && result.rows.first.isNotEmpty) {
          return result.rows.first.first.toString();
        }
        return '{}';

      case DatabaseDriver.sqlite:
        final result =
            await driver.execute('EXPLAIN QUERY PLAN $sql');
        // SQLite returns tabular rows: selectid | order | from | detail
        final lines = <String>[];
        for (final row in result.rows) {
          lines.add(row.map((v) => v.toString()).join(' | '));
        }
        return lines.join('\n');

      case DatabaseDriver.sqlServer:
        return 'EXPLAIN is not supported for SQL Server connections. '
            'Use SSMS or Azure Data Studio to view execution plans.';
    }
  }

  /// Routes parsing to the appropriate engine-specific parser.
  static PlanResult _parsePlan(
    DatabaseDriver driver,
    String rawOutput, {
    required bool isAnalyze,
  }) {
    switch (driver) {
      case DatabaseDriver.postgresql:
        return _parsePostgresqlJsonPlan(rawOutput, isAnalyze: isAnalyze);
      case DatabaseDriver.mysql:
      case DatabaseDriver.mariadb:
        return _parseMysqlJsonPlan(rawOutput, isAnalyze: isAnalyze);
      case DatabaseDriver.sqlite:
        return _parseSqlitePlan(rawOutput);
      case DatabaseDriver.sqlServer:
        return PlanResult(
          root: const PlanNode(nodeType: 'Unsupported'),
          rawOutput: rawOutput,
        );
    }
  }

  /// Parses PostgreSQL EXPLAIN (FORMAT JSON) output.
  static PlanResult _parsePostgresqlJsonPlan(
    String raw, {
    bool isAnalyze = false,
  }) {
    try {
      final decoded = jsonDecode(raw);
      final List<dynamic> plans;
      if (decoded is List) {
        plans = decoded;
      } else {
        plans = [decoded];
      }

      if (plans.isEmpty) {
        return PlanResult(
          root: const PlanNode(nodeType: 'Empty Plan'),
          rawOutput: raw,
          isAnalyze: isAnalyze,
        );
      }

      final planMap = plans.first as Map<String, dynamic>;
      final planBody =
          planMap['Plan'] as Map<String, dynamic>? ?? planMap;

      final root = _parsePlanNodeMap(planBody);

      return PlanResult(
        root: root,
        planningTime: _toDouble(planMap['Planning Time']),
        executionTime: _toDouble(planMap['Execution Time']),
        rawOutput: raw,
        isAnalyze: isAnalyze,
      );
    } on Object catch (e) {
      log.w(_tag, 'Failed to parse PostgreSQL plan: $e');
      return PlanResult(
        root: PlanNode(nodeType: 'Parse Error: $e'),
        rawOutput: raw,
        isAnalyze: isAnalyze,
      );
    }
  }

  /// Parses MySQL EXPLAIN FORMAT=JSON output.
  static PlanResult _parseMysqlJsonPlan(
    String raw, {
    bool isAnalyze = false,
  }) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final queryBlock =
          decoded['query_block'] as Map<String, dynamic>? ?? decoded;

      final root = _parseMysqlNode(queryBlock);

      return PlanResult(
        root: root,
        rawOutput: raw,
        isAnalyze: isAnalyze,
      );
    } on Object catch (e) {
      log.w(_tag, 'Failed to parse MySQL plan: $e');
      return PlanResult(
        root: PlanNode(nodeType: 'Parse Error: $e'),
        rawOutput: raw,
        isAnalyze: isAnalyze,
      );
    }
  }

  /// Parses SQLite EXPLAIN QUERY PLAN output.
  static PlanResult _parseSqlitePlan(String raw) {
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      return PlanResult(
        root: const PlanNode(nodeType: 'Empty Plan'),
        rawOutput: raw,
      );
    }

    // SQLite plan lines: "selectid | order | from | detail"
    final children = <PlanNode>[];
    for (final line in lines) {
      final parts = line.split('|').map((s) => s.trim()).toList();
      final detail = parts.length >= 4 ? parts[3] : line;
      children.add(PlanNode(
        nodeType: _extractSqliteNodeType(detail),
        tableName: _extractSqliteTableName(detail),
        filter: detail,
      ));
    }

    final root = PlanNode(
      nodeType: 'Query Plan',
      children: children,
    );

    return PlanResult(root: root, rawOutput: raw);
  }

  /// Recursively parses a PostgreSQL plan node from a JSON map.
  static PlanNode _parsePlanNodeMap(Map<String, dynamic> map) {
    final children = <PlanNode>[];
    final plans = map['Plans'] as List<dynamic>?;
    if (plans != null) {
      for (final child in plans) {
        if (child is Map<String, dynamic>) {
          children.add(_parsePlanNodeMap(child));
        }
      }
    }

    return PlanNode(
      nodeType: map['Node Type'] as String? ?? 'Unknown',
      relationship: map['Parent Relationship'] as String?,
      totalCost: _toDouble(map['Total Cost']) ?? 0,
      startupCost: _toDouble(map['Startup Cost']) ?? 0,
      planRows: _toDouble(map['Plan Rows']) ?? 0,
      planWidth: (map['Plan Width'] as int?) ?? 0,
      actualRows: _toDouble(map['Actual Rows']),
      actualTime: _toDouble(map['Actual Total Time']),
      actualLoops: map['Actual Loops'] as int?,
      children: children,
      filter: map['Filter'] as String?,
      indexName: map['Index Name'] as String?,
      tableName: map['Relation Name'] as String?,
      schemaName: map['Schema'] as String?,
      joinType: map['Join Type'] as String?,
      sortKey: (map['Sort Key'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      hashCondition: map['Hash Cond'] as String?,
      output: (map['Output'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      alias: map['Alias'] as String?,
      scanDirection: map['Scan Direction'] as String?,
      indexCondition: map['Index Cond'] as String?,
      rowsRemovedByFilter: _toDouble(map['Rows Removed by Filter']),
      actualStartupTime: _toDouble(map['Actual Startup Time']),
      actualTotalTime: _toDouble(map['Actual Total Time']),
    );
  }

  /// Parses a MySQL query_block node.
  static PlanNode _parseMysqlNode(Map<String, dynamic> map) {
    final children = <PlanNode>[];

    // MySQL nests tables in various keys.
    final table = map['table'] as Map<String, dynamic>?;
    if (table != null) {
      children.add(PlanNode(
        nodeType: table['access_type'] as String? ?? 'Table Access',
        tableName: table['table_name'] as String?,
        indexName: table['key'] as String?,
        planRows: _toDouble(table['rows_examined_per_scan']) ?? 0,
        filter: table['attached_condition'] as String?,
      ));
    }

    // Nested tables in ordering/grouping operations.
    final nestedLoop = map['nested_loop'] as List<dynamic>?;
    if (nestedLoop != null) {
      for (final entry in nestedLoop) {
        if (entry is Map<String, dynamic>) {
          final innerTable = entry['table'] as Map<String, dynamic>?;
          if (innerTable != null) {
            children.add(PlanNode(
              nodeType:
                  innerTable['access_type'] as String? ?? 'Table Access',
              tableName: innerTable['table_name'] as String?,
              indexName: innerTable['key'] as String?,
              planRows:
                  _toDouble(innerTable['rows_examined_per_scan']) ?? 0,
              filter: innerTable['attached_condition'] as String?,
            ));
          }
        }
      }
    }

    final costInfo = map['cost_info'] as Map<String, dynamic>?;
    final totalCost = _toDouble(costInfo?['query_cost']) ?? 0;

    return PlanNode(
      nodeType: 'Query Block',
      totalCost: totalCost,
      planRows: _toDouble(map['select_id']) ?? 1,
      children: children,
    );
  }

  /// Extracts node type from a SQLite EXPLAIN QUERY PLAN detail string.
  static String _extractSqliteNodeType(String detail) {
    final upper = detail.toUpperCase();
    if (upper.contains('USING INDEX')) return 'Index Scan';
    if (upper.contains('SCAN')) return 'Seq Scan';
    if (upper.contains('SEARCH')) return 'Index Search';
    if (upper.contains('COMPOUND')) return 'Compound';
    return 'Scan';
  }

  /// Extracts table name from a SQLite EXPLAIN QUERY PLAN detail string.
  static String? _extractSqliteTableName(String detail) {
    // "SCAN users" or "SEARCH users USING INDEX ..."
    final match = RegExp(r'(?:SCAN|SEARCH)\s+(\w+)', caseSensitive: false)
        .firstMatch(detail);
    return match?.group(1);
  }

  /// Safely converts a value to [double].
  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }
}
