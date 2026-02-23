// Tests for ScribeFileService.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/services/data/scribe_file_service.dart';
import 'package:codeops/services/data/scribe_persistence_service.dart';

class MockScribePersistenceService extends Mock
    implements ScribePersistenceService {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockScribePersistenceService mockPersistence;
  late MockDio mockDio;
  late ScribeFileService service;

  setUp(() {
    mockPersistence = MockScribePersistenceService();
    mockDio = MockDio();
    service = ScribeFileService(mockPersistence, mockDio);
  });

  group('fileNameFromUrl', () {
    test('extracts file name from URL path', () {
      expect(
        ScribeFileService.fileNameFromUrl('https://example.com/path/main.dart'),
        'main.dart',
      );
    });

    test('extracts last segment from deep URL path', () {
      expect(
        ScribeFileService.fileNameFromUrl(
            'https://example.com/a/b/c/config.yaml'),
        'config.yaml',
      );
    });

    test('returns untitled for root URL', () {
      expect(
        ScribeFileService.fileNameFromUrl('https://example.com/'),
        'untitled',
      );
    });

    test('returns untitled for URL with no path', () {
      expect(
        ScribeFileService.fileNameFromUrl('https://example.com'),
        'untitled',
      );
    });

    test('handles URL with query parameters', () {
      expect(
        ScribeFileService.fileNameFromUrl(
            'https://example.com/file.js?v=1'),
        'file.js',
      );
    });
  });

  group('loadRecentFiles', () {
    test('returns empty list when no recent files stored', () async {
      when(() => mockPersistence.loadSettingsValue('recent_files'))
          .thenAnswer((_) async => null);

      final result = await service.loadRecentFiles();
      expect(result, isEmpty);
    });

    test('returns stored file paths', () async {
      final files = ['/path/a.dart', '/path/b.dart'];
      when(() => mockPersistence.loadSettingsValue('recent_files'))
          .thenAnswer((_) async => jsonEncode(files));

      final result = await service.loadRecentFiles();
      expect(result, files);
    });

    test('returns empty list for malformed JSON', () async {
      when(() => mockPersistence.loadSettingsValue('recent_files'))
          .thenAnswer((_) async => 'not json');

      final result = await service.loadRecentFiles();
      expect(result, isEmpty);
    });
  });

  group('addRecentFile', () {
    test('adds file to front of list', () async {
      when(() => mockPersistence.loadSettingsValue('recent_files'))
          .thenAnswer((_) async => jsonEncode(['/old.dart']));
      when(() => mockPersistence.saveSettingsValue(any(), any()))
          .thenAnswer((_) async {});

      await service.addRecentFile('/new.dart');

      final captured = verify(
        () => mockPersistence.saveSettingsValue('recent_files', captureAny()),
      ).captured;
      final saved = jsonDecode(captured.last as String) as List;
      expect(saved.first, '/new.dart');
      expect(saved.last, '/old.dart');
    });

    test('deduplicates by moving existing entry to front', () async {
      when(() => mockPersistence.loadSettingsValue('recent_files'))
          .thenAnswer((_) async => jsonEncode(['/a.dart', '/b.dart']));
      when(() => mockPersistence.saveSettingsValue(any(), any()))
          .thenAnswer((_) async {});

      await service.addRecentFile('/b.dart');

      final captured = verify(
        () => mockPersistence.saveSettingsValue('recent_files', captureAny()),
      ).captured;
      final saved = jsonDecode(captured.last as String) as List;
      expect(saved, ['/b.dart', '/a.dart']);
    });

    test('caps at 20 entries', () async {
      final existing = List.generate(20, (i) => '/file-$i.dart');
      when(() => mockPersistence.loadSettingsValue('recent_files'))
          .thenAnswer((_) async => jsonEncode(existing));
      when(() => mockPersistence.saveSettingsValue(any(), any()))
          .thenAnswer((_) async {});

      await service.addRecentFile('/brand-new.dart');

      final captured = verify(
        () => mockPersistence.saveSettingsValue('recent_files', captureAny()),
      ).captured;
      final saved = jsonDecode(captured.last as String) as List;
      expect(saved, hasLength(20));
      expect(saved.first, '/brand-new.dart');
    });
  });

  group('clearRecentFiles', () {
    test('saves empty list', () async {
      when(() => mockPersistence.saveSettingsValue(any(), any()))
          .thenAnswer((_) async {});

      await service.clearRecentFiles();

      verify(
        () => mockPersistence.saveSettingsValue('recent_files', '[]'),
      ).called(1);
    });
  });

  group('readFromUrl', () {
    test('fetches text content successfully', () async {
      when(() => mockDio.get<String>(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<String>(
            data: 'void main() {}',
            statusCode: 200,
            headers: Headers.fromMap({
              'content-type': ['text/plain'],
            }),
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await service.readFromUrl('https://example.com/main.dart');
      expect(result, 'void main() {}');
    });

    test('accepts application/json content type', () async {
      when(() => mockDio.get<String>(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<String>(
            data: '{"key": "value"}',
            statusCode: 200,
            headers: Headers.fromMap({
              'content-type': ['application/json'],
            }),
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await service.readFromUrl('https://example.com/data.json');
      expect(result, '{"key": "value"}');
    });

    test('throws on binary content type', () async {
      when(() => mockDio.get<String>(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<String>(
            data: null,
            statusCode: 200,
            headers: Headers.fromMap({
              'content-type': ['application/octet-stream'],
            }),
            requestOptions: RequestOptions(path: ''),
          ));

      expect(
        () => service.readFromUrl('https://example.com/file.bin'),
        throwsA(isA<Exception>()),
      );
    });

    test('returns empty string when data is null', () async {
      when(() => mockDio.get<String>(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<String>(
            data: null,
            statusCode: 200,
            headers: Headers.fromMap({
              'content-type': ['text/plain'],
            }),
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await service.readFromUrl('https://example.com/empty');
      expect(result, '');
    });
  });
}
