// Tests for LogConfig environment-aware initialization and configuration.
import 'package:codeops/services/logging/log_config.dart';
import 'package:codeops/services/logging/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // Default values
  // -------------------------------------------------------------------------

  group('defaults', () {
    test('minimumLevel defaults to debug', () {
      // In test (debug) mode, default is debug.
      expect(LogConfig.minimumLevel, LogLevel.debug);
    });

    test('enableFileLogging defaults to false', () {
      expect(LogConfig.enableFileLogging, isFalse);
    });

    test('enableConsoleColors defaults to true', () {
      expect(LogConfig.enableConsoleColors, isTrue);
    });

    test('mutedTags is initially empty', () {
      expect(LogConfig.mutedTags, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Initialization
  // -------------------------------------------------------------------------

  group('initialize', () {
    late LogLevel savedLevel;
    late bool savedFileLogging;
    late bool savedColors;
    late String? savedDir;

    setUp(() {
      savedLevel = LogConfig.minimumLevel;
      savedFileLogging = LogConfig.enableFileLogging;
      savedColors = LogConfig.enableConsoleColors;
      savedDir = LogConfig.logDirectory;
    });

    tearDown(() {
      LogConfig.minimumLevel = savedLevel;
      LogConfig.enableFileLogging = savedFileLogging;
      LogConfig.enableConsoleColors = savedColors;
      LogConfig.logDirectory = savedDir;
      LogConfig.mutedTags.clear();
    });

    test('initialize sets debug-mode defaults in test environment', () async {
      await LogConfig.initialize();

      // Tests run in debug mode (kDebugMode == true).
      expect(LogConfig.minimumLevel, LogLevel.debug);
      expect(LogConfig.enableFileLogging, isFalse);
      expect(LogConfig.enableConsoleColors, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Mutable configuration
  // -------------------------------------------------------------------------

  group('mutable config', () {
    late LogLevel savedLevel;

    setUp(() {
      savedLevel = LogConfig.minimumLevel;
    });

    tearDown(() {
      LogConfig.minimumLevel = savedLevel;
      LogConfig.mutedTags.clear();
    });

    test('minimumLevel can be changed', () {
      LogConfig.minimumLevel = LogLevel.error;
      expect(LogConfig.minimumLevel, LogLevel.error);
    });

    test('mutedTags can be added and removed', () {
      LogConfig.mutedTags.add('NoisyTag');
      expect(LogConfig.mutedTags, contains('NoisyTag'));

      LogConfig.mutedTags.remove('NoisyTag');
      expect(LogConfig.mutedTags, isNot(contains('NoisyTag')));
    });

    test('multiple tags can be muted simultaneously', () {
      LogConfig.mutedTags.addAll(['Tag1', 'Tag2', 'Tag3']);
      expect(LogConfig.mutedTags, containsAll(['Tag1', 'Tag2', 'Tag3']));
    });
  });

  // -------------------------------------------------------------------------
  // Log level ordering
  // -------------------------------------------------------------------------

  group('LogLevel ordering', () {
    test('levels are ordered from verbose to fatal', () {
      expect(LogLevel.verbose.index, lessThan(LogLevel.debug.index));
      expect(LogLevel.debug.index, lessThan(LogLevel.info.index));
      expect(LogLevel.info.index, lessThan(LogLevel.warning.index));
      expect(LogLevel.warning.index, lessThan(LogLevel.error.index));
      expect(LogLevel.error.index, lessThan(LogLevel.fatal.index));
    });

    test('LogLevel has exactly 6 values', () {
      expect(LogLevel.values, hasLength(6));
    });
  });
}
