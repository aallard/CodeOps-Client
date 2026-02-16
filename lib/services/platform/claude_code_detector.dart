/// Detects whether Claude Code CLI is installed, validates version, and
/// reports availability.
///
/// Uses `dart:io` [Process] to probe for the `claude` executable on the
/// system PATH. Cross-platform: runs `which` on macOS/Linux and `where.exe`
/// on Windows.
library;

import 'dart:io';

import '../../utils/constants.dart';
import '../logging/log_service.dart';

// ---------------------------------------------------------------------------
// ClaudeCodeStatus
// ---------------------------------------------------------------------------

/// Availability status of the Claude Code CLI.
enum ClaudeCodeStatus {
  /// The CLI is installed and meets the minimum version requirement.
  available,

  /// The CLI executable was not found on the system PATH.
  notInstalled,

  /// The CLI is installed but its version is below
  /// [AppConstants.minClaudeCodeVersion].
  versionTooOld,

  /// An unexpected error occurred during detection.
  error;

  /// Human-readable display label.
  String get displayName => switch (this) {
        ClaudeCodeStatus.available => 'Available',
        ClaudeCodeStatus.notInstalled => 'Not Installed',
        ClaudeCodeStatus.versionTooOld => 'Version Too Old',
        ClaudeCodeStatus.error => 'Error',
      };
}

// ---------------------------------------------------------------------------
// ClaudeCodeDetector
// ---------------------------------------------------------------------------

/// Detects and validates the local Claude Code CLI installation.
///
/// All methods are safe to call on any platform and will never throw.
/// Errors are captured and reflected via [ClaudeCodeStatus.error] or
/// `null` return values.
class ClaudeCodeDetector {
  /// Creates a [ClaudeCodeDetector].
  const ClaudeCodeDetector();

  /// Common installation paths to check when `which`/`where` fails.
  ///
  /// Desktop apps on macOS don't inherit the user's shell PATH, so
  /// Homebrew and npm-installed binaries won't be found by `which`.
  static final List<String> _fallbackPaths = [
    if (!Platform.isWindows) ...[
      '/opt/homebrew/bin/claude', // Homebrew on Apple Silicon
      '/usr/local/bin/claude', // Homebrew on Intel Mac
      '${Platform.environment['HOME']}/.npm/bin/claude',
      '${Platform.environment['HOME']}/.local/bin/claude',
      '${Platform.environment['HOME']}/.nvm/versions/node/current/bin/claude',
    ],
    if (Platform.isWindows) ...[
      '${Platform.environment['LOCALAPPDATA']}\\Programs\\claude\\claude.exe',
      '${Platform.environment['APPDATA']}\\npm\\claude.cmd',
    ],
  ];

  /// Returns `true` if the `claude` executable is found on the system PATH
  /// or at a known installation location.
  Future<bool> isInstalled() async {
    try {
      final path = await getExecutablePath();
      return path != null;
    } catch (_) {
      return false;
    }
  }

  /// Returns the installed Claude Code CLI version string, or `null` if the
  /// CLI is not installed or the version cannot be determined.
  ///
  /// Runs `claude --version` using the resolved executable path and parses
  /// the first semantic version token from the output.
  Future<String?> getVersion() async {
    try {
      final path = await getExecutablePath();
      if (path == null) return null;

      final result = await Process.run(path, const ['--version']);
      if (result.exitCode != 0) return null;

      final output = (result.stdout as String).trim();
      if (output.isEmpty) return null;

      // Extract the first semver-like token (digits.digits.digits).
      final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(output);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  /// Returns the absolute filesystem path to the `claude` executable, or
  /// `null` if it is not found.
  ///
  /// First tries `which`/`where.exe`, then probes common installation paths.
  Future<String?> getExecutablePath() async {
    // Try system PATH first.
    try {
      final executable = Platform.isWindows ? 'where.exe' : 'which';
      final result = await Process.run(executable, const ['claude']);
      if (result.exitCode == 0) {
        final output = (result.stdout as String).trim();
        if (output.isNotEmpty) {
          final firstLine = output.split('\n').first.trim();
          if (firstLine.isNotEmpty) return firstLine;
        }
      }
    } catch (_) {
      // which/where not available or failed — fall through.
    }

    // Probe common installation paths.
    for (final candidate in _fallbackPaths) {
      try {
        if (await File(candidate).exists()) {
          return candidate;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// Validates the Claude Code CLI installation.
  ///
  /// Returns [ClaudeCodeStatus.available] only when the CLI is installed
  /// **and** its version is at least [AppConstants.minClaudeCodeVersion].
  Future<ClaudeCodeStatus> validate() async {
    try {
      final installed = await isInstalled();
      if (!installed) {
        log.w('ClaudeCodeDetector', 'Claude CLI not found on PATH');
        return ClaudeCodeStatus.notInstalled;
      }

      final version = await getVersion();
      if (version == null) return ClaudeCodeStatus.error;

      final meetsMinimum = _isVersionSufficient(
        version,
        AppConstants.minClaudeCodeVersion,
      );
      if (meetsMinimum) {
        final path = await getExecutablePath();
        log.i('ClaudeCodeDetector', 'CLI detected (path=$path, version=$version)');
      } else {
        log.w('ClaudeCodeDetector', 'CLI version too old ($version < ${AppConstants.minClaudeCodeVersion})');
      }
      return meetsMinimum
          ? ClaudeCodeStatus.available
          : ClaudeCodeStatus.versionTooOld;
    } catch (_) {
      return ClaudeCodeStatus.error;
    }
  }

  /// Compares two semantic version strings and returns `true` if [current]
  /// is greater than or equal to [minimum].
  ///
  /// Both strings must follow the `major.minor.patch` format. If either
  /// string cannot be parsed the method returns `false`.
  static bool _isVersionSufficient(String current, String minimum) {
    final currentParts = _parseVersion(current);
    final minimumParts = _parseVersion(minimum);
    if (currentParts == null || minimumParts == null) return false;

    for (var i = 0; i < 3; i++) {
      if (currentParts[i] > minimumParts[i]) return true;
      if (currentParts[i] < minimumParts[i]) return false;
    }
    return true; // Versions are equal.
  }

  /// Parses a `"major.minor.patch"` string into a three-element list,
  /// or returns `null` on failure.
  static List<int>? _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length != 3) return null;
    try {
      return parts.map(int.parse).toList();
    } catch (_) {
      return null;
    }
  }
}
