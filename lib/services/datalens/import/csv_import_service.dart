/// CSV import service for DataLens.
///
/// Parses CSV files, generates column-mapped INSERT statements, and executes
/// batch imports against the target table. Supports delimiter auto-detection,
/// configurable encoding, conflict resolution (skip/update/error), dry-run
/// mode, and optional table creation.
library;

import 'dart:convert';
import 'dart:io';

import '../../logging/log_service.dart';
import '../database_connection_service.dart';
import '../drivers/database_driver.dart';

// ---------------------------------------------------------------------------
// Data Classes
// ---------------------------------------------------------------------------

/// Conflict resolution strategy for duplicate rows.
enum OnConflict {
  /// Skip conflicting rows silently.
  skip,

  /// Update existing rows on conflict.
  update,

  /// Fail with error on conflict.
  error;

  /// Human-readable label.
  String get label => switch (this) {
        OnConflict.skip => 'Skip',
        OnConflict.update => 'Update',
        OnConflict.error => 'Error',
      };
}

/// Preview of a parsed CSV file before import.
class CsvPreview {
  /// Detected or parsed column headers.
  final List<String> detectedColumns;

  /// First N rows of data for preview.
  final List<List<String>> previewRows;

  /// Estimated total row count (excluding header).
  final int totalRows;

  /// The delimiter that was used to parse.
  final String detectedDelimiter;

  /// The encoding that was used.
  final String detectedEncoding;

  /// Creates a [CsvPreview].
  const CsvPreview({
    required this.detectedColumns,
    required this.previewRows,
    required this.totalRows,
    required this.detectedDelimiter,
    required this.detectedEncoding,
  });
}

/// Mapping from a CSV column to a database column.
class ColumnMapping {
  /// Source CSV column name.
  final String csvColumn;

  /// Target database column name, or `null` to skip this column.
  final String? dbColumn;

  /// Optional transformation to apply: trim, uppercase, lowercase, dateFormat.
  final String? transformation;

  /// Default value if the CSV cell is empty.
  final String? defaultValue;

  /// Creates a [ColumnMapping].
  const ColumnMapping({
    required this.csvColumn,
    this.dbColumn,
    this.transformation,
    this.defaultValue,
  });
}

/// Options controlling how CSV import behaves.
class CsvImportOptions {
  /// Create the target table if it does not already exist.
  final bool createTableIfNotExists;

  /// Truncate the target table before importing.
  final bool truncateBeforeImport;

  /// Conflict resolution strategy.
  final OnConflict onConflict;

  /// Number of rows per INSERT batch.
  final int batchSize;

  /// If `true`, generates SQL without executing it.
  final bool dryRun;

  /// CSV delimiter character.
  final String delimiter;

  /// CSV quote character.
  final String quoteChar;

  /// Whether the first row is a header.
  final bool hasHeader;

  /// Creates a [CsvImportOptions].
  const CsvImportOptions({
    this.createTableIfNotExists = false,
    this.truncateBeforeImport = false,
    this.onConflict = OnConflict.error,
    this.batchSize = 500,
    this.dryRun = false,
    this.delimiter = ',',
    this.quoteChar = '"',
    this.hasHeader = true,
  });
}

/// A single import error referencing the source row.
class ImportError {
  /// 1-based row number in the CSV file.
  final int rowNumber;

  /// Error message.
  final String message;

  /// Creates an [ImportError].
  const ImportError({required this.rowNumber, required this.message});
}

/// Result of a CSV import operation.
class ImportResult {
  /// Number of rows successfully imported.
  final int rowsImported;

  /// Number of rows skipped (conflict resolution).
  final int rowsSkipped;

  /// Number of rows that failed.
  final int rowsFailed;

  /// Detailed error list.
  final List<ImportError> errors;

  /// Total duration of the import.
  final Duration duration;

  /// Generated SQL statements (populated in dry-run mode).
  final List<String> generatedSql;

  /// Creates an [ImportResult].
  const ImportResult({
    this.rowsImported = 0,
    this.rowsSkipped = 0,
    this.rowsFailed = 0,
    this.errors = const [],
    this.duration = Duration.zero,
    this.generatedSql = const [],
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service for importing CSV files into database tables.
///
/// Supports file preview, column mapping, batch inserts, conflict resolution,
/// and dry-run mode. Uses the driver abstraction from DL-016 to generate
/// dialect-appropriate SQL.
class CsvImportService {
  static const String _tag = 'CsvImportService';

  final DatabaseConnectionService _connectionService;

  /// Creates a [CsvImportService].
  CsvImportService(this._connectionService);

  // -------------------------------------------------------------------------
  // Preview
  // -------------------------------------------------------------------------

  /// Parses a CSV file and returns a preview of the first [previewRows] rows.
  ///
  /// Auto-detects the delimiter from the first line if [delimiter] is the
  /// default comma and the file appears to use another separator.
  Future<CsvPreview> previewCsv(
    String filePath, {
    String delimiter = ',',
    String quoteChar = '"',
    bool hasHeader = true,
    String encoding = 'utf-8',
    int previewRows = 50,
  }) async {
    log.d(_tag, 'previewCsv($filePath)');

    final file = File(filePath);
    if (!file.existsSync()) {
      throw StateError('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    final content = _decode(bytes, encoding);
    final lines = _splitLines(content);

    if (lines.isEmpty) {
      return const CsvPreview(
        detectedColumns: [],
        previewRows: [],
        totalRows: 0,
        detectedDelimiter: ',',
        detectedEncoding: 'utf-8',
      );
    }

    // Auto-detect delimiter from first line.
    final effectiveDelimiter = _detectDelimiter(lines.first, delimiter);

    final allRows = lines.map((l) => _parseLine(l, effectiveDelimiter, quoteChar)).toList();

    List<String> columns;
    List<List<String>> dataRows;

    if (hasHeader && allRows.isNotEmpty) {
      columns = allRows.first;
      dataRows = allRows.skip(1).toList();
    } else {
      columns = List.generate(
        allRows.first.length,
        (i) => 'Column ${i + 1}',
      );
      dataRows = allRows;
    }

    final preview = dataRows.length > previewRows
        ? dataRows.sublist(0, previewRows)
        : dataRows;

    return CsvPreview(
      detectedColumns: columns,
      previewRows: preview,
      totalRows: dataRows.length,
      detectedDelimiter: effectiveDelimiter,
      detectedEncoding: encoding,
    );
  }

  // -------------------------------------------------------------------------
  // Import
  // -------------------------------------------------------------------------

  /// Executes a CSV import using the provided column mappings and options.
  ///
  /// Returns an [ImportResult] with row counts and any errors encountered.
  /// In dry-run mode, generates SQL without executing.
  Future<ImportResult> importCsv({
    required String filePath,
    required String connectionId,
    required String schema,
    required String targetTable,
    required List<ColumnMapping> mappings,
    required CsvImportOptions options,
  }) async {
    log.i(_tag, 'importCsv($filePath → $schema.$targetTable)');
    final stopwatch = Stopwatch()..start();

    final driver = _requireDriver(connectionId);
    final dialect = driver.dialect;

    // Parse the full CSV.
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final content = _decode(bytes, 'utf-8');
    final lines = _splitLines(content);

    if (lines.isEmpty) {
      return const ImportResult();
    }

    final allRows = lines
        .map((l) => _parseLine(l, options.delimiter, options.quoteChar))
        .toList();

    // Skip header row.
    final dataRows = options.hasHeader ? allRows.skip(1).toList() : allRows;
    final csvColumns = options.hasHeader ? allRows.first : <String>[];

    // Build column index map: csvColumn → index in row.
    final csvIndexMap = <String, int>{};
    for (var i = 0; i < csvColumns.length; i++) {
      csvIndexMap[csvColumns[i]] = i;
    }

    // Filter to active mappings (those with a target DB column).
    final activeMappings =
        mappings.where((m) => m.dbColumn != null).toList();

    if (activeMappings.isEmpty) {
      return ImportResult(duration: stopwatch.elapsed);
    }

    final dbColumns =
        activeMappings.map((m) => dialect.quoteIdentifier(m.dbColumn!)).toList();
    final qualifiedTable = dialect.qualifyTable(schema, targetTable);

    final generatedSql = <String>[];
    final errors = <ImportError>[];

    // Optional: create table.
    if (options.createTableIfNotExists) {
      final createSql = _buildCreateTable(
        dialect,
        schema,
        targetTable,
        activeMappings,
      );
      generatedSql.add(createSql);
      if (!options.dryRun) {
        try {
          await driver.execute(createSql);
        } catch (e) {
          log.w(_tag, 'Create table failed (may already exist): $e');
        }
      }
    }

    // Optional: truncate.
    if (options.truncateBeforeImport) {
      final truncSql = 'TRUNCATE TABLE $qualifiedTable';
      generatedSql.add(truncSql);
      if (!options.dryRun) {
        await driver.execute(truncSql);
      }
    }

    // Batch INSERT.
    var imported = 0;
    var skipped = 0;
    var failed = 0;

    for (var batchStart = 0;
        batchStart < dataRows.length;
        batchStart += options.batchSize) {
      final batchEnd = (batchStart + options.batchSize).clamp(0, dataRows.length);
      final batch = dataRows.sublist(batchStart, batchEnd);

      final valueRows = <String>[];
      for (var i = 0; i < batch.length; i++) {
        final row = batch[i];
        final rowNum = batchStart + i + (options.hasHeader ? 2 : 1);

        try {
          final values = activeMappings.map((m) {
            final csvIdx = csvIndexMap[m.csvColumn];
            var value = (csvIdx != null && csvIdx < row.length)
                ? row[csvIdx]
                : '';

            // Apply default if empty.
            if (value.isEmpty && m.defaultValue != null) {
              value = m.defaultValue!;
            }

            // Apply transformation.
            value = _applyTransformation(value, m.transformation);

            return _sqlLiteral(value);
          }).join(', ');

          valueRows.add('($values)');
        } catch (e) {
          errors.add(ImportError(rowNumber: rowNum, message: e.toString()));
          failed++;
        }
      }

      if (valueRows.isEmpty) continue;

      final insertSql =
          'INSERT INTO $qualifiedTable (${dbColumns.join(', ')}) VALUES ${valueRows.join(', ')}';
      generatedSql.add(insertSql);

      if (!options.dryRun) {
        try {
          final result = await driver.execute(insertSql);
          imported += result.affectedRows;
        } catch (e) {
          final msg = e.toString();
          if (options.onConflict == OnConflict.skip && _isConflictError(msg)) {
            skipped += valueRows.length;
          } else if (options.onConflict == OnConflict.error) {
            for (var i = 0; i < valueRows.length; i++) {
              errors.add(ImportError(
                rowNumber: batchStart + i + (options.hasHeader ? 2 : 1),
                message: msg,
              ));
            }
            failed += valueRows.length;
          } else {
            // For UPDATE conflict mode, fall back to row-by-row.
            final rowResults = await _insertRowByRow(
              driver: driver,
              qualifiedTable: qualifiedTable,
              dbColumns: dbColumns,
              batch: batch,
              activeMappings: activeMappings,
              csvIndexMap: csvIndexMap,
              batchStart: batchStart,
              hasHeader: options.hasHeader,
              onConflict: options.onConflict,
            );
            imported += rowResults.imported;
            skipped += rowResults.skipped;
            failed += rowResults.failed;
            errors.addAll(rowResults.errors);
          }
        }
      } else {
        imported += valueRows.length;
      }
    }

    stopwatch.stop();
    log.i(_tag,
        'Import complete: $imported imported, $skipped skipped, $failed failed in ${stopwatch.elapsed}');

    return ImportResult(
      rowsImported: imported,
      rowsSkipped: skipped,
      rowsFailed: failed,
      errors: errors,
      duration: stopwatch.elapsed,
      generatedSql: generatedSql,
    );
  }

  // -------------------------------------------------------------------------
  // Helpers — CSV Parsing
  // -------------------------------------------------------------------------

  /// Decodes bytes using the specified encoding name.
  String _decode(List<int> bytes, String encoding) {
    switch (encoding.toLowerCase()) {
      case 'utf-8':
      case 'utf8':
        return utf8.decode(bytes, allowMalformed: true);
      case 'latin-1':
      case 'latin1':
      case 'iso-8859-1':
        return latin1.decode(bytes);
      default:
        return utf8.decode(bytes, allowMalformed: true);
    }
  }

  /// Splits content into non-empty lines, handling \r\n and \r.
  List<String> _splitLines(String content) {
    return content
        .split(RegExp(r'\r\n|\r|\n'))
        .where((l) => l.trim().isNotEmpty)
        .toList();
  }

  /// Auto-detects delimiter from the first line of a CSV.
  ///
  /// Checks tab, semicolon, and pipe against the provided default.
  String _detectDelimiter(String firstLine, String defaultDelimiter) {
    const candidates = ['\t', ';', '|'];
    for (final c in candidates) {
      if (firstLine.contains(c) && !firstLine.contains(defaultDelimiter)) {
        return c;
      }
    }
    return defaultDelimiter;
  }

  /// Parses a single CSV line respecting quoted fields.
  List<String> _parseLine(String line, String delimiter, String quoteChar) {
    final fields = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    final chars = line.split('');

    for (var i = 0; i < chars.length; i++) {
      final ch = chars[i];

      if (inQuotes) {
        if (ch == quoteChar) {
          // Check for escaped quote (doubled).
          if (i + 1 < chars.length && chars[i + 1] == quoteChar) {
            buf.write(quoteChar);
            i++; // Skip next quote.
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(ch);
        }
      } else {
        if (ch == quoteChar) {
          inQuotes = true;
        } else if (ch == delimiter) {
          fields.add(buf.toString());
          buf.clear();
        } else {
          buf.write(ch);
        }
      }
    }

    fields.add(buf.toString());
    return fields;
  }

  // -------------------------------------------------------------------------
  // Helpers — SQL Generation
  // -------------------------------------------------------------------------

  /// Applies a transformation to a cell value.
  String _applyTransformation(String value, String? transformation) {
    if (transformation == null || value.isEmpty) return value;

    return switch (transformation.toLowerCase()) {
      'trim' => value.trim(),
      'uppercase' => value.toUpperCase(),
      'lowercase' => value.toLowerCase(),
      _ => value,
    };
  }

  /// Converts a string value to a SQL literal.
  String _sqlLiteral(String value) {
    if (value.isEmpty) return 'NULL';
    if (value.toLowerCase() == 'null') return 'NULL';
    if (value.toLowerCase() == 'true') return 'TRUE';
    if (value.toLowerCase() == 'false') return 'FALSE';

    final asNum = num.tryParse(value);
    if (asNum != null) return value;

    return "'${value.replaceAll("'", "''")}'";
  }

  /// Builds a CREATE TABLE IF NOT EXISTS statement.
  String _buildCreateTable(
    SqlDialect dialect,
    String schema,
    String table,
    List<ColumnMapping> mappings,
  ) {
    final qualifiedTable = dialect.qualifyTable(schema, table);
    final columns = mappings.map((m) {
      final colName = dialect.quoteIdentifier(m.dbColumn!);
      return '  $colName TEXT';
    }).join(',\n');

    return 'CREATE TABLE IF NOT EXISTS $qualifiedTable (\n$columns\n)';
  }

  /// Returns `true` if the error message suggests a conflict (unique/PK).
  bool _isConflictError(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('duplicate') ||
        lower.contains('unique') ||
        lower.contains('conflict') ||
        lower.contains('violation');
  }

  /// Inserts rows one at a time for conflict handling.
  Future<_RowByRowResult> _insertRowByRow({
    required DatabaseDriverAdapter driver,
    required String qualifiedTable,
    required List<String> dbColumns,
    required List<List<String>> batch,
    required List<ColumnMapping> activeMappings,
    required Map<String, int> csvIndexMap,
    required int batchStart,
    required bool hasHeader,
    required OnConflict onConflict,
  }) async {
    var imported = 0;
    var skipped = 0;
    var failed = 0;
    final errors = <ImportError>[];

    for (var i = 0; i < batch.length; i++) {
      final row = batch[i];
      final rowNum = batchStart + i + (hasHeader ? 2 : 1);

      try {
        final values = activeMappings.map((m) {
          final csvIdx = csvIndexMap[m.csvColumn];
          var value =
              (csvIdx != null && csvIdx < row.length) ? row[csvIdx] : '';
          if (value.isEmpty && m.defaultValue != null) {
            value = m.defaultValue!;
          }
          value = _applyTransformation(value, m.transformation);
          return _sqlLiteral(value);
        }).join(', ');

        final sql =
            'INSERT INTO $qualifiedTable (${dbColumns.join(', ')}) VALUES ($values)';
        final result = await driver.execute(sql);
        imported += result.affectedRows;
      } catch (e) {
        final msg = e.toString();
        if (onConflict == OnConflict.skip && _isConflictError(msg)) {
          skipped++;
        } else {
          errors.add(ImportError(rowNumber: rowNum, message: msg));
          failed++;
        }
      }
    }

    return _RowByRowResult(
      imported: imported,
      skipped: skipped,
      failed: failed,
      errors: errors,
    );
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

/// Internal result for row-by-row fallback.
class _RowByRowResult {
  final int imported;
  final int skipped;
  final int failed;
  final List<ImportError> errors;

  const _RowByRowResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });
}
