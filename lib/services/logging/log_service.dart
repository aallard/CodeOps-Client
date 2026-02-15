/// Singleton structured logging service for the CodeOps application.
///
/// Provides six leveled methods ([v], [d], [i], [w], [e], [f]) that emit
/// consistently formatted, tagged messages to the console and optionally to
/// daily rotated log files.
///
/// **Sensitive-data contract:** Callers MUST NOT pass tokens, passwords,
/// credentials, or personally-identifiable information in the [message]
/// parameter. Log output is considered non-secret.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'log_config.dart';
import 'log_level.dart';

/// Top-level convenience getter for the [LogService] singleton.
///
/// Usage:
/// ```dart
/// import 'package:codeops/services/logging/log_service.dart';
///
/// log.i('MyTag', 'Something happened');
/// ```
final LogService log = LogService();

/// Structured, leveled logging service.
///
/// Obtain the singleton via [log] or `LogService()`.
class LogService {
  static final LogService _instance = LogService._internal();

  /// Returns the singleton [LogService] instance.
  factory LogService() => _instance;

  LogService._internal();

  // ANSI color codes for console output.
  static const _reset = '\x1B[0m';
  static const _grey = '\x1B[90m';
  static const _blue = '\x1B[34m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
  static const _redBold = '\x1B[1;31m';

  /// Logs a [LogLevel.verbose] message.
  void v(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.verbose, tag, message, error, stackTrace);

  /// Logs a [LogLevel.debug] message.
  void d(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.debug, tag, message, error, stackTrace);

  /// Logs a [LogLevel.info] message.
  void i(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.info, tag, message, error, stackTrace);

  /// Logs a [LogLevel.warning] message.
  void w(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.warning, tag, message, error, stackTrace);

  /// Logs a [LogLevel.error] message.
  void e(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, tag, message, error, stackTrace);

  /// Logs a [LogLevel.fatal] message.
  void f(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.fatal, tag, message, error, stackTrace);

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _log(
    LogLevel level,
    String tag,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Level gate.
    if (level.index < LogConfig.minimumLevel.index) return;

    // Tag gate.
    if (LogConfig.mutedTags.contains(tag)) return;

    final now = DateTime.now();
    final timestamp = _formatTime(now);
    final label = _levelLabel(level);

    final buffer = StringBuffer('[$timestamp] [$label] [$tag] $message');
    if (error != null) {
      buffer.write('\n  Error: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n  StackTrace: $stackTrace');
    }

    final plain = buffer.toString();

    // Console output.
    if (kDebugMode) {
      if (LogConfig.enableConsoleColors) {
        final color = _levelColor(level);
        // ignore: avoid_print
        print('$color$plain$_reset');
      } else {
        // ignore: avoid_print
        print(plain);
      }
    }

    // File output.
    if (LogConfig.enableFileLogging) {
      _writeToFile(plain, now);
    }
  }

  String _formatTime(DateTime t) =>
      '${_pad2(t.hour)}:${_pad2(t.minute)}:${_pad2(t.second)}'
      '.${_pad3(t.millisecond)}';

  static String _pad2(int n) => n.toString().padLeft(2, '0');
  static String _pad3(int n) => n.toString().padLeft(3, '0');

  String _levelLabel(LogLevel level) => switch (level) {
        LogLevel.verbose => 'VERBOSE',
        LogLevel.debug => 'DEBUG',
        LogLevel.info => 'INFO',
        LogLevel.warning => 'WARN',
        LogLevel.error => 'ERROR',
        LogLevel.fatal => 'FATAL',
      };

  String _levelColor(LogLevel level) => switch (level) {
        LogLevel.verbose => _grey,
        LogLevel.debug => _blue,
        LogLevel.info => _green,
        LogLevel.warning => _yellow,
        LogLevel.error => _red,
        LogLevel.fatal => _redBold,
      };

  // ---------------------------------------------------------------------------
  // File logging
  // ---------------------------------------------------------------------------

  void _writeToFile(String line, DateTime now) {
    final dir = LogConfig.logDirectory;
    if (dir == null) return;

    try {
      final logDir = Directory(dir);
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      final date =
          '${now.year}-${_pad2(now.month)}-${_pad2(now.day)}';
      final file = File('$dir${Platform.pathSeparator}codeops-$date.log');
      file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);

      // Purge files older than 7 days.
      _purgeOldLogs(logDir, now);
    } on Object {
      // File I/O failure must never crash the app.
    }
  }

  void _purgeOldLogs(Directory logDir, DateTime now) {
    try {
      final cutoff = now.subtract(const Duration(days: 7));
      for (final entity in logDir.listSync()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = entity.statSync();
          if (stat.modified.isBefore(cutoff)) {
            entity.deleteSync();
          }
        }
      }
    } on Object {
      // Purge failure is non-critical.
    }
  }
}
