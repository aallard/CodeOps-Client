// Tests for PreferencesService.
//
// Verifies local CRUD operations against an in-memory Drift database.
// Server sync is not tested here (requires mock McpApiService).
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/database/database.dart';
import 'package:codeops/services/cloud/mcp_api.dart';
import 'package:codeops/services/preferences/preferences_service.dart';

class MockMcpApi extends Mock implements McpApiService {}

void main() {
  late CodeOpsDatabase db;
  late MockMcpApi mockApi;
  late PreferencesService service;

  setUp(() {
    db = CodeOpsDatabase(NativeDatabase.memory());
    mockApi = MockMcpApi();
    service = PreferencesService(db: db, mcpApi: mockApi);
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  group('PreferencesService', () {
    test('loadAll returns empty map initially', () async {
      final prefs = await service.loadAll();

      expect(prefs, isEmpty);
    });

    test('set and get a preference', () async {
      await service.set('theme', 'dark');

      final value = await service.get('theme', 'light');

      expect(value, 'dark');
    });

    test('get returns default when key not found', () async {
      final value = await service.get('missing', 'fallback');

      expect(value, 'fallback');
    });

    test('set overwrites existing value', () async {
      await service.set('accent', '#6C63FF');
      await service.set('accent', '#3B82F6');

      final value = await service.get('accent', '');

      expect(value, '#3B82F6');
    });

    test('remove deletes a preference', () async {
      await service.set('fontSize', 'large');
      await service.remove('fontSize');

      final value = await service.get('fontSize', 'medium');

      expect(value, 'medium');
    });

    test('loadAll returns all stored preferences', () async {
      await service.set('a', '1');
      await service.set('b', '2');
      await service.set('c', '3');

      final prefs = await service.loadAll();

      expect(prefs.length, 3);
      expect(prefs['a'], '1');
      expect(prefs['b'], '2');
      expect(prefs['c'], '3');
    });

    test('resetAll clears all preferences', () async {
      await service.set('x', 'y');
      await service.set('z', 'w');

      await service.resetAll();

      final prefs = await service.loadAll();

      expect(prefs, isEmpty);
    });

    test('exportAll returns all prefs as map', () async {
      await service.set('theme', 'dark');
      await service.set('accent', '#FF0000');

      final exported = await service.exportAll();

      expect(exported, isA<Map<String, dynamic>>());
      expect(exported['theme'], 'dark');
      expect(exported['accent'], '#FF0000');
    });

    test('importAll replaces all preferences', () async {
      await service.set('old', 'value');

      await service.importAll({
        'new1': 'a',
        'new2': 'b',
      });

      final prefs = await service.loadAll();

      expect(prefs.containsKey('old'), false);
      expect(prefs['new1'], 'a');
      expect(prefs['new2'], 'b');
    });
  });
}
