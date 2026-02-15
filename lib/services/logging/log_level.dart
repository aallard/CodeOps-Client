/// Severity levels for structured log output.
///
/// Levels are ordered from most verbose ([verbose]) to most severe ([fatal]).
/// The active [LogConfig.minimumLevel] determines which messages are emitted.
library;

/// Log severity levels, ordered from least to most severe.
enum LogLevel {
  /// Extremely detailed tracing — typically disabled even in debug builds.
  verbose,

  /// Diagnostic information useful during development.
  debug,

  /// Noteworthy runtime events (startup, shutdown, major operations).
  info,

  /// Recoverable problems that deserve attention.
  warning,

  /// Failures that prevent an operation from completing.
  error,

  /// Unrecoverable failures that may crash the application.
  fatal,
}
