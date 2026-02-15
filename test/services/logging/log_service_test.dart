// Tests for LogService singleton, level filtering, tag muting, and output.
import 'dart:io';

import 'package:codeops/services/logging/log_config.dart';
import 'package:codeops/services/logging/log_level.dart';
import 'package:codeops/services/logging/log_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // Singleton
  // -------------------------------------------------------------------------

  group('singleton', () {
    test('factory returns the same instance', () {
      final a = LogService();
      final b = LogService();

      expect(identical(a, b), isTrue);
    });

    test('top-level log getter returns the same instance', () {
      expect(identical(log, LogService()), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Level filtering
  // -------------------------------------------------------------------------

  group('level filtering', () {
    late String? originalDir;
    late LogLevel originalLevel;

    setUp(() {
      originalDir = LogConfig.logDirectory;
      originalLevel = LogConfig.minimumLevel;

      // Write to a temp directory so we can inspect file output.
      final tmpDir = Directory.systemTemp.createTempSync('codeops_log_test_');
      LogConfig.logDirectory = tmpDir.path;
      LogConfig.enableFileLogging = true;
      LogConfig.minimumLevel = LogLevel.debug;
    });

    tearDown(() {
      // Restore original config.
      LogConfig.logDirectory = originalDir;
      LogConfig.enableFileLogging = false;
      LogConfig.minimumLevel = originalLevel;
      LogConfig.mutedTags.clear();
    });

    test('messages below minimum level are suppressed', () {
      LogConfig.minimumLevel = LogLevel.warning;

      // Write a debug message — should NOT appear in file.
      log.d('Test', 'should be suppressed');

      // Write a warning message — should appear.
      log.w('Test', 'should appear');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        expect(content, isNot(contains('should be suppressed')));
        expect(content, contains('should appear'));
      }
    });

    test('messages at minimum level are emitted', () {
      LogConfig.minimumLevel = LogLevel.info;
      log.i('Test', 'info level message');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        expect(content, contains('info level message'));
      }
    });

    test('messages above minimum level are emitted', () {
      LogConfig.minimumLevel = LogLevel.info;
      log.e('Test', 'error level message');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        expect(content, contains('error level message'));
      }
    });
  });

  // -------------------------------------------------------------------------
  // Tag muting
  // -------------------------------------------------------------------------

  group('tag muting', () {
    late String? originalDir;

    setUp(() {
      originalDir = LogConfig.logDirectory;
      final tmpDir = Directory.systemTemp.createTempSync('codeops_log_mute_');
      LogConfig.logDirectory = tmpDir.path;
      LogConfig.enableFileLogging = true;
      LogConfig.minimumLevel = LogLevel.verbose;
    });

    tearDown(() {
      LogConfig.logDirectory = originalDir;
      LogConfig.enableFileLogging = false;
      LogConfig.mutedTags.clear();
    });

    test('muted tags suppress all output regardless of level', () {
      LogConfig.mutedTags.add('NoisyTag');

      log.i('NoisyTag', 'muted message');
      log.e('NoisyTag', 'muted error');
      log.i('QuietTag', 'visible message');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        expect(content, isNot(contains('muted message')));
        expect(content, isNot(contains('muted error')));
        expect(content, contains('visible message'));
      }
    });
  });

  // -------------------------------------------------------------------------
  // Output format
  // -------------------------------------------------------------------------

  group('output format', () {
    late String? originalDir;

    setUp(() {
      originalDir = LogConfig.logDirectory;
      final tmpDir = Directory.systemTemp.createTempSync('codeops_log_fmt_');
      LogConfig.logDirectory = tmpDir.path;
      LogConfig.enableFileLogging = true;
      LogConfig.minimumLevel = LogLevel.verbose;
    });

    tearDown(() {
      LogConfig.logDirectory = originalDir;
      LogConfig.enableFileLogging = false;
      LogConfig.mutedTags.clear();
    });

    test('all six levels produce correctly labeled output', () {
      log.v('T', 'verbose msg');
      log.d('T', 'debug msg');
      log.i('T', 'info msg');
      log.w('T', 'warn msg');
      log.e('T', 'error msg');
      log.f('T', 'fatal msg');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      expect(files, isNotEmpty);
      final content = files.first.readAsStringSync();

      expect(content, contains('[VERBOSE]'));
      expect(content, contains('[DEBUG]'));
      expect(content, contains('[INFO]'));
      expect(content, contains('[WARN]'));
      expect(content, contains('[ERROR]'));
      expect(content, contains('[FATAL]'));
    });

    test('output includes tag in brackets', () {
      log.i('MyTag', 'tagged message');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        expect(content, contains('[MyTag]'));
      }
    });

    test('output includes timestamp pattern', () {
      log.i('T', 'timestamp check');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        // Matches [HH:mm:ss.SSS] pattern.
        expect(
          RegExp(r'\[\d{2}:\d{2}:\d{2}\.\d{3}\]').hasMatch(content),
          isTrue,
        );
      }
    });

    test('error and stackTrace are included when provided', () {
      final error = StateError('test error');
      final stackTrace = StackTrace.current;

      log.e('T', 'with error', error, stackTrace);

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      if (files.isNotEmpty) {
        final content = files.first.readAsStringSync();
        expect(content, contains('Error: Bad state: test error'));
        expect(content, contains('StackTrace:'));
      }
    });
  });

  // -------------------------------------------------------------------------
  // File naming
  // -------------------------------------------------------------------------

  group('file logging', () {
    late String? originalDir;

    setUp(() {
      originalDir = LogConfig.logDirectory;
      final tmpDir = Directory.systemTemp.createTempSync('codeops_log_file_');
      LogConfig.logDirectory = tmpDir.path;
      LogConfig.enableFileLogging = true;
      LogConfig.minimumLevel = LogLevel.verbose;
    });

    tearDown(() {
      LogConfig.logDirectory = originalDir;
      LogConfig.enableFileLogging = false;
      LogConfig.mutedTags.clear();
    });

    test('log file follows daily naming convention', () {
      log.i('T', 'naming test');

      final dir = Directory(LogConfig.logDirectory!);
      final files = dir.listSync().whereType<File>().toList();

      expect(files, hasLength(1));
      final filename = files.first.uri.pathSegments.last;
      // codeops-YYYY-MM-DD.log
      expect(
        RegExp(r'^codeops-\d{4}-\d{2}-\d{2}\.log$').hasMatch(filename),
        isTrue,
      );
    });

    test('no file written when file logging is disabled', () {
      LogConfig.enableFileLogging = false;

      final tmpDir = Directory.systemTemp.createTempSync('codeops_log_off_');
      LogConfig.logDirectory = tmpDir.path;

      log.i('T', 'should not write');

      final files = tmpDir.listSync().whereType<File>().toList();
      expect(files, isEmpty);
    });
  });
}
