/// Table-to-table transfer service for DataLens.
///
/// Transfers data between tables, including cross-connection transfers.
/// Supports column mapping, WHERE filtering, batch processing, optional
/// target table creation, and truncation.
library;

import '../../logging/log_service.dart';
import '../database_connection_service.dart';
import '../drivers/database_driver.dart';
import '../schema_introspection_service.dart';
import 'csv_import_service.dart';

// ---------------------------------------------------------------------------
// Data Classes
// ---------------------------------------------------------------------------

/// Result of a table-to-table data transfer.
class TransferResult {
  /// Number of rows successfully transferred.
  final int rowsTransferred;

  /// Number of rows that failed.
  final int rowsFailed;

  /// Total duration of the transfer.
  final Duration duration;

  /// Detailed error list.
  final List<ImportError> errors;

  /// Creates a [TransferResult].
  const TransferResult({
    this.rowsTransferred = 0,
    this.rowsFailed = 0,
    this.duration = Duration.zero,
    this.errors = const [],
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service for transferring data between database tables.
///
/// Handles both same-connection transfers (using INSERT ... SELECT) and
/// cross-connection transfers (read from source, batch-insert into target).
class TableTransferService {
  static const String _tag = 'TableTransferService';

  final DatabaseConnectionService _connectionService;
  final SchemaIntrospectionService _schemaService;

  /// Creates a [TableTransferService].
  TableTransferService(this._connectionService, this._schemaService);

  /// Transfers data from a source table to a target table.
  ///
  /// If [sourceConnectionId] and [targetConnectionId] are the same, uses an
  /// optimised INSERT ... SELECT. For cross-connection transfers, reads data
  /// from the source and batch-inserts into the target.
  ///
  /// [columnMappings] maps source columns to target columns. If `null`,
  /// columns are auto-mapped by name (case-insensitive).
  ///
  /// [onProgress] is called with the current batch number and total batches.
  Future<TransferResult> transfer({
    required String sourceConnectionId,
    required String sourceSchema,
    required String sourceTable,
    required String targetConnectionId,
    required String targetSchema,
    required String targetTable,
    List<ColumnMapping>? columnMappings,
    String? whereClause,
    int batchSize = 1000,
    bool createTargetIfNotExists = false,
    bool truncateTarget = false,
    void Function(int current, int total)? onProgress,
  }) async {
    log.i(_tag,
        'transfer($sourceSchema.$sourceTable → $targetSchema.$targetTable)');
    final stopwatch = Stopwatch()..start();

    final sameConnection = sourceConnectionId == targetConnectionId;

    if (sameConnection) {
      final result = await _sameConnectionTransfer(
        connectionId: sourceConnectionId,
        sourceSchema: sourceSchema,
        sourceTable: sourceTable,
        targetSchema: targetSchema,
        targetTable: targetTable,
        columnMappings: columnMappings,
        whereClause: whereClause,
        createTargetIfNotExists: createTargetIfNotExists,
        truncateTarget: truncateTarget,
      );
      stopwatch.stop();
      return TransferResult(
        rowsTransferred: result,
        duration: stopwatch.elapsed,
      );
    }

    return _crossConnectionTransfer(
      sourceConnectionId: sourceConnectionId,
      sourceSchema: sourceSchema,
      sourceTable: sourceTable,
      targetConnectionId: targetConnectionId,
      targetSchema: targetSchema,
      targetTable: targetTable,
      columnMappings: columnMappings,
      whereClause: whereClause,
      batchSize: batchSize,
      createTargetIfNotExists: createTargetIfNotExists,
      truncateTarget: truncateTarget,
      stopwatch: stopwatch,
      onProgress: onProgress,
    );
  }

  // -------------------------------------------------------------------------
  // Same-Connection Transfer
  // -------------------------------------------------------------------------

  /// Performs an INSERT ... SELECT on the same connection.
  Future<int> _sameConnectionTransfer({
    required String connectionId,
    required String sourceSchema,
    required String sourceTable,
    required String targetSchema,
    required String targetTable,
    required List<ColumnMapping>? columnMappings,
    required String? whereClause,
    required bool createTargetIfNotExists,
    required bool truncateTarget,
  }) async {
    final driver = _requireDriver(connectionId);
    final dialect = driver.dialect;

    final srcQualified = dialect.qualifyTable(sourceSchema, sourceTable);
    final tgtQualified = dialect.qualifyTable(targetSchema, targetTable);

    // Resolve column mappings.
    final mappings = await _resolveMappings(
      connectionId: connectionId,
      sourceSchema: sourceSchema,
      sourceTable: sourceTable,
      targetConnectionId: connectionId,
      targetSchema: targetSchema,
      targetTable: targetTable,
      columnMappings: columnMappings,
      createTargetIfNotExists: createTargetIfNotExists,
    );

    if (createTargetIfNotExists) {
      await _maybeCreateTarget(
        driver: driver,
        dialect: dialect,
        targetSchema: targetSchema,
        targetTable: targetTable,
        mappings: mappings,
      );
    }

    if (truncateTarget) {
      await driver.execute('TRUNCATE TABLE $tgtQualified');
    }

    final srcCols = mappings
        .map((m) => dialect.quoteIdentifier(m.csvColumn))
        .join(', ');
    final tgtCols = mappings
        .map((m) => dialect.quoteIdentifier(m.dbColumn!))
        .join(', ');

    final where = (whereClause != null && whereClause.trim().isNotEmpty)
        ? ' WHERE $whereClause'
        : '';

    final sql =
        'INSERT INTO $tgtQualified ($tgtCols) SELECT $srcCols FROM $srcQualified$where';

    log.d(_tag, 'Same-connection transfer: $sql');
    final result = await driver.execute(sql);
    return result.affectedRows;
  }

  // -------------------------------------------------------------------------
  // Cross-Connection Transfer
  // -------------------------------------------------------------------------

  /// Reads from source, batch-inserts into target across different connections.
  Future<TransferResult> _crossConnectionTransfer({
    required String sourceConnectionId,
    required String sourceSchema,
    required String sourceTable,
    required String targetConnectionId,
    required String targetSchema,
    required String targetTable,
    required List<ColumnMapping>? columnMappings,
    required String? whereClause,
    required int batchSize,
    required bool createTargetIfNotExists,
    required bool truncateTarget,
    required Stopwatch stopwatch,
    void Function(int current, int total)? onProgress,
  }) async {
    final srcDriver = _requireDriver(sourceConnectionId);
    final tgtDriver = _requireDriver(targetConnectionId);
    final srcDialect = srcDriver.dialect;
    final tgtDialect = tgtDriver.dialect;

    // Resolve column mappings.
    final mappings = await _resolveMappings(
      connectionId: sourceConnectionId,
      sourceSchema: sourceSchema,
      sourceTable: sourceTable,
      targetConnectionId: targetConnectionId,
      targetSchema: targetSchema,
      targetTable: targetTable,
      columnMappings: columnMappings,
      createTargetIfNotExists: createTargetIfNotExists,
    );

    if (createTargetIfNotExists) {
      await _maybeCreateTarget(
        driver: tgtDriver,
        dialect: tgtDialect,
        targetSchema: targetSchema,
        targetTable: targetTable,
        mappings: mappings,
      );
    }

    final tgtQualified = tgtDialect.qualifyTable(targetSchema, targetTable);

    if (truncateTarget) {
      await tgtDriver.execute('TRUNCATE TABLE $tgtQualified');
    }

    // Read all data from source.
    final srcQualified = srcDialect.qualifyTable(sourceSchema, sourceTable);
    final srcCols = mappings
        .map((m) => srcDialect.quoteIdentifier(m.csvColumn))
        .join(', ');
    final where = (whereClause != null && whereClause.trim().isNotEmpty)
        ? ' WHERE $whereClause'
        : '';

    final selectSql = 'SELECT $srcCols FROM $srcQualified$where';
    final srcResult = await srcDriver.execute(selectSql);

    if (srcResult.rows.isEmpty) {
      stopwatch.stop();
      return TransferResult(duration: stopwatch.elapsed);
    }

    // Batch-insert into target.
    final tgtCols = mappings
        .map((m) => tgtDialect.quoteIdentifier(m.dbColumn!))
        .join(', ');

    var transferred = 0;
    var failed = 0;
    final errors = <ImportError>[];
    final totalBatches = (srcResult.rows.length / batchSize).ceil();

    for (var batchIdx = 0; batchIdx < totalBatches; batchIdx++) {
      final start = batchIdx * batchSize;
      final end = (start + batchSize).clamp(0, srcResult.rows.length);
      final batch = srcResult.rows.sublist(start, end);

      onProgress?.call(batchIdx + 1, totalBatches);

      final valueRows = batch.map((row) {
        final vals = row.map((v) {
          if (v == null) return 'NULL';
          if (v is num) return v.toString();
          if (v is bool) return v ? 'TRUE' : 'FALSE';
          return "'${v.toString().replaceAll("'", "''")}'";
        }).join(', ');
        return '($vals)';
      }).join(', ');

      final insertSql =
          'INSERT INTO $tgtQualified ($tgtCols) VALUES $valueRows';

      try {
        final result = await tgtDriver.execute(insertSql);
        transferred += result.affectedRows;
      } catch (e) {
        errors.add(ImportError(
          rowNumber: start + 1,
          message: 'Batch ${batchIdx + 1} failed: $e',
        ));
        failed += batch.length;
      }
    }

    stopwatch.stop();
    log.i(_tag,
        'Cross-connection transfer: $transferred transferred, $failed failed in ${stopwatch.elapsed}');

    return TransferResult(
      rowsTransferred: transferred,
      rowsFailed: failed,
      duration: stopwatch.elapsed,
      errors: errors,
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Resolves column mappings, either from explicit mappings or auto-mapped.
  Future<List<ColumnMapping>> _resolveMappings({
    required String connectionId,
    required String sourceSchema,
    required String sourceTable,
    required String targetConnectionId,
    required String targetSchema,
    required String targetTable,
    required List<ColumnMapping>? columnMappings,
    required bool createTargetIfNotExists,
  }) async {
    if (columnMappings != null && columnMappings.isNotEmpty) {
      return columnMappings.where((m) => m.dbColumn != null).toList();
    }

    // Auto-map by column name.
    final srcColumns =
        await _schemaService.getColumns(connectionId, sourceSchema, sourceTable);

    if (createTargetIfNotExists) {
      // Use source columns directly.
      return srcColumns
          .map((c) => ColumnMapping(
                csvColumn: c.columnName ?? '',
                dbColumn: c.columnName,
              ))
          .where((m) => m.csvColumn.isNotEmpty)
          .toList();
    }

    final tgtColumns = await _schemaService.getColumns(
        targetConnectionId, targetSchema, targetTable);

    final tgtNameMap = <String, String>{};
    for (final col in tgtColumns) {
      final name = col.columnName ?? '';
      if (name.isNotEmpty) {
        tgtNameMap[name.toLowerCase()] = name;
      }
    }

    return srcColumns
        .where((c) =>
            c.columnName != null &&
            tgtNameMap.containsKey(c.columnName!.toLowerCase()))
        .map((c) => ColumnMapping(
              csvColumn: c.columnName!,
              dbColumn: tgtNameMap[c.columnName!.toLowerCase()],
            ))
        .toList();
  }

  /// Creates the target table if it does not exist.
  Future<void> _maybeCreateTarget({
    required DatabaseDriverAdapter driver,
    required SqlDialect dialect,
    required String targetSchema,
    required String targetTable,
    required List<ColumnMapping> mappings,
  }) async {
    final qualified = dialect.qualifyTable(targetSchema, targetTable);
    final columns = mappings.map((m) {
      final col = dialect.quoteIdentifier(m.dbColumn!);
      return '  $col TEXT';
    }).join(',\n');

    final sql = 'CREATE TABLE IF NOT EXISTS $qualified (\n$columns\n)';
    try {
      await driver.execute(sql);
    } catch (e) {
      log.w(_tag, 'Create target table failed (may exist): $e');
    }
  }

  /// Returns the active [DatabaseDriverAdapter] or throws.
  DatabaseDriverAdapter _requireDriver(String connectionId) {
    final driver = _connectionService.getDriver(connectionId);
    if (driver == null) {
      throw StateError('No active connection for $connectionId');
    }
    return driver;
  }
}
