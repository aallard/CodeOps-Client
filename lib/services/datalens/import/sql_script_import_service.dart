/// SQL script import service for DataLens.
///
/// Parses SQL scripts into individual statements, respecting semicolons inside
/// quoted strings and comments, then executes them sequentially against a
/// database connection. Supports stop-on-error and transaction wrapping.
library;

import '../../logging/log_service.dart';
import '../database_connection_service.dart';
import '../drivers/database_driver.dart';

// ---------------------------------------------------------------------------
// Data Classes
// ---------------------------------------------------------------------------

/// Result of executing a single SQL statement from a script.
class StatementResult {
  /// The SQL text that was executed.
  final String sql;

  /// Whether this statement succeeded.
  final bool success;

  /// Number of rows affected (for DML).
  final int rowsAffected;

  /// Error message if the statement failed.
  final String? error;

  /// Execution time for this statement.
  final Duration duration;

  /// Creates a [StatementResult].
  const StatementResult({
    required this.sql,
    required this.success,
    this.rowsAffected = 0,
    this.error,
    this.duration = Duration.zero,
  });
}

/// Aggregate result of executing an entire SQL script.
class ScriptResult {
  /// Total number of statements that were executed (or attempted).
  final int statementsExecuted;

  /// Number of statements that succeeded.
  final int statementsSucceeded;

  /// Number of statements that failed.
  final int statementsFailed;

  /// Total rows affected across all DML statements.
  final int rowsAffected;

  /// Per-statement results.
  final List<StatementResult> details;

  /// Total duration for the entire script.
  final Duration duration;

  /// Creates a [ScriptResult].
  const ScriptResult({
    this.statementsExecuted = 0,
    this.statementsSucceeded = 0,
    this.statementsFailed = 0,
    this.rowsAffected = 0,
    this.details = const [],
    this.duration = Duration.zero,
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service for importing and executing SQL scripts against a connection.
///
/// Parses multi-statement SQL text, handling semicolons inside quotes and
/// comments, then executes sequentially with optional stop-on-error and
/// transaction wrapping.
class SqlScriptImportService {
  static const String _tag = 'SqlScriptImportService';

  final DatabaseConnectionService _connectionService;

  /// Creates a [SqlScriptImportService].
  SqlScriptImportService(this._connectionService);

  // -------------------------------------------------------------------------
  // Parse
  // -------------------------------------------------------------------------

  /// Splits a SQL script into individual statements.
  ///
  /// Respects semicolons inside single-quoted strings, double-quoted
  /// identifiers, and `--` line comments. Blank statements are omitted.
  List<String> parseStatements(String script) {
    final statements = <String>[];
    final buf = StringBuffer();
    var inSingleQuote = false;
    var inDoubleQuote = false;
    var inLineComment = false;

    final chars = script.split('');

    for (var i = 0; i < chars.length; i++) {
      final ch = chars[i];
      final next = (i + 1 < chars.length) ? chars[i + 1] : '';

      // Handle line comments.
      if (inLineComment) {
        if (ch == '\n') {
          inLineComment = false;
          buf.write(ch);
        }
        continue;
      }

      // Detect start of line comment.
      if (!inSingleQuote && !inDoubleQuote && ch == '-' && next == '-') {
        inLineComment = true;
        continue;
      }

      // Toggle single-quote state.
      if (ch == "'" && !inDoubleQuote) {
        // Escaped single quote ('').
        if (inSingleQuote && next == "'") {
          buf.write("''");
          i++;
          continue;
        }
        inSingleQuote = !inSingleQuote;
        buf.write(ch);
        continue;
      }

      // Toggle double-quote state.
      if (ch == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
        buf.write(ch);
        continue;
      }

      // Statement separator.
      if (ch == ';' && !inSingleQuote && !inDoubleQuote) {
        final stmt = buf.toString().trim();
        if (stmt.isNotEmpty) {
          statements.add(stmt);
        }
        buf.clear();
        continue;
      }

      buf.write(ch);
    }

    // Trailing statement without semicolon.
    final trailing = buf.toString().trim();
    if (trailing.isNotEmpty) {
      statements.add(trailing);
    }

    return statements;
  }

  // -------------------------------------------------------------------------
  // Execute
  // -------------------------------------------------------------------------

  /// Executes a SQL script against the specified connection.
  ///
  /// Each statement is executed sequentially. If [stopOnError] is `true`,
  /// execution halts at the first failure. If [wrapInTransaction] is `true`,
  /// the entire script is wrapped in BEGIN / COMMIT (or ROLLBACK on failure).
  Future<ScriptResult> executeScript({
    required String connectionId,
    required String script,
    bool stopOnError = true,
    bool wrapInTransaction = false,
    void Function(int current, int total)? onProgress,
  }) async {
    log.i(_tag, 'executeScript(${script.length} chars, stopOnError=$stopOnError, txn=$wrapInTransaction)');

    final driver = _requireDriver(connectionId);
    final statements = parseStatements(script);

    if (statements.isEmpty) {
      return const ScriptResult();
    }

    final stopwatch = Stopwatch()..start();
    final details = <StatementResult>[];
    var succeeded = 0;
    var failed = 0;
    var totalRows = 0;

    if (wrapInTransaction) {
      await driver.execute('BEGIN');
    }

    try {
      for (var i = 0; i < statements.length; i++) {
        final sql = statements[i];
        final stmtWatch = Stopwatch()..start();

        onProgress?.call(i + 1, statements.length);

        try {
          final result = await driver.execute(sql);
          stmtWatch.stop();

          final affected = result.affectedRows;
          totalRows += affected;
          succeeded++;

          details.add(StatementResult(
            sql: sql,
            success: true,
            rowsAffected: affected,
            duration: stmtWatch.elapsed,
          ));
        } catch (e) {
          stmtWatch.stop();
          failed++;

          details.add(StatementResult(
            sql: sql,
            success: false,
            error: e.toString(),
            duration: stmtWatch.elapsed,
          ));

          if (stopOnError) break;
        }
      }

      if (wrapInTransaction) {
        if (failed > 0) {
          await driver.execute('ROLLBACK');
        } else {
          await driver.execute('COMMIT');
        }
      }
    } catch (e) {
      log.e(_tag, 'Script execution error: $e');
      if (wrapInTransaction) {
        try {
          await driver.execute('ROLLBACK');
        } catch (_) {
          // Best effort rollback.
        }
      }
    }

    stopwatch.stop();
    log.i(_tag,
        'Script complete: $succeeded succeeded, $failed failed, $totalRows rows in ${stopwatch.elapsed}');

    return ScriptResult(
      statementsExecuted: details.length,
      statementsSucceeded: succeeded,
      statementsFailed: failed,
      rowsAffected: totalRows,
      details: details,
      duration: stopwatch.elapsed,
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
