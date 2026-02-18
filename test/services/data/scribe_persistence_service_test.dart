// Tests for ScribePersistenceService.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/database/database.dart' hide ScribeTab;
import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/services/data/scribe_persistence_service.dart';

void main() {
  late CodeOpsDatabase db;
  late ScribePersistenceService service;

  setUp(() {
    db = CodeOpsDatabase(NativeDatabase.memory());
    service = ScribePersistenceService(db);
  });

  tearDown(() async {
    await db.close();
  });

  final now = DateTime(2026, 2, 17, 12, 0, 0);

  ScribeTab makeTab(
    String id, {
    String title = 'test',
    String content = '',
    String language = 'plaintext',
    bool isDirty = false,
    int cursorLine = 0,
    int cursorColumn = 0,
    double scrollOffset = 0.0,
    String? filePath,
  }) {
    return ScribeTab(
      id: id,
      title: title,
      filePath: filePath,
      content: content,
      language: language,
      isDirty: isDirty,
      cursorLine: cursorLine,
      cursorColumn: cursorColumn,
      scrollOffset: scrollOffset,
      createdAt: now,
      lastModifiedAt: now,
    );
  }

  group('ScribePersistenceService — tabs', () {
    test('loadTabs returns empty list when no persisted tabs', () async {
      final tabs = await service.loadTabs();
      expect(tabs, isEmpty);
    });

    test('saveTabs + loadTabs round-trip preserves all tab data', () async {
      final tabs = [
        makeTab('t1',
            title: 'main.dart',
            content: 'void main() {}',
            language: 'dart',
            isDirty: true,
            cursorLine: 5,
            cursorColumn: 10,
            scrollOffset: 42.5,
            filePath: '/src/main.dart'),
        makeTab('t2',
            title: 'schema.sql', content: 'SELECT 1;', language: 'sql'),
      ];

      await service.saveTabs(tabs);
      final loaded = await service.loadTabs();

      expect(loaded, hasLength(2));
      expect(loaded[0].id, 't1');
      expect(loaded[0].title, 'main.dart');
      expect(loaded[0].content, 'void main() {}');
      expect(loaded[0].language, 'dart');
      expect(loaded[0].isDirty, isTrue);
      expect(loaded[0].cursorLine, 5);
      expect(loaded[0].cursorColumn, 10);
      expect(loaded[0].scrollOffset, 42.5);
      expect(loaded[0].filePath, '/src/main.dart');
      expect(loaded[1].id, 't2');
      expect(loaded[1].title, 'schema.sql');
    });

    test('saveTabs replaces all existing tabs', () async {
      await service.saveTabs([makeTab('old')]);
      await service.saveTabs([makeTab('new1'), makeTab('new2')]);

      final loaded = await service.loadTabs();
      expect(loaded, hasLength(2));
      expect(loaded[0].id, 'new1');
      expect(loaded[1].id, 'new2');
    });

    test('saveTab upserts correctly — insert new', () async {
      await service.saveTab(makeTab('t1', title: 'first'), 0);
      final loaded = await service.loadTabs();
      expect(loaded, hasLength(1));
      expect(loaded[0].id, 't1');
      expect(loaded[0].title, 'first');
    });

    test('saveTab upserts correctly — update existing', () async {
      await service.saveTab(makeTab('t1', title: 'original'), 0);
      await service.saveTab(makeTab('t1', title: 'updated'), 0);

      final loaded = await service.loadTabs();
      expect(loaded, hasLength(1));
      expect(loaded[0].title, 'updated');
    });

    test('removeTab deletes the correct tab', () async {
      await service.saveTabs([makeTab('t1'), makeTab('t2'), makeTab('t3')]);
      await service.removeTab('t2');

      final loaded = await service.loadTabs();
      expect(loaded, hasLength(2));
      expect(loaded.map((t) => t.id), containsAll(['t1', 't3']));
      expect(loaded.map((t) => t.id), isNot(contains('t2')));
    });

    test('clearTabs removes all tabs', () async {
      await service.saveTabs([makeTab('t1'), makeTab('t2')]);
      await service.clearTabs();

      final loaded = await service.loadTabs();
      expect(loaded, isEmpty);
    });

    test('tabs loaded in correct displayOrder', () async {
      // Insert in reverse order.
      await service.saveTab(makeTab('c', title: 'third'), 2);
      await service.saveTab(makeTab('a', title: 'first'), 0);
      await service.saveTab(makeTab('b', title: 'second'), 1);

      final loaded = await service.loadTabs();
      expect(loaded[0].title, 'first');
      expect(loaded[1].title, 'second');
      expect(loaded[2].title, 'third');
    });

    test('tabs preserve nullable filePath', () async {
      await service.saveTabs([makeTab('t1', filePath: null)]);
      final loaded = await service.loadTabs();
      expect(loaded[0].filePath, isNull);
    });

    test('tabs preserve timestamps', () async {
      await service.saveTabs([makeTab('t1')]);
      final loaded = await service.loadTabs();
      expect(loaded[0].createdAt, now);
      expect(loaded[0].lastModifiedAt, now);
    });
  });

  group('ScribePersistenceService — settings', () {
    test('loadSettings returns defaults when no persisted settings', () async {
      final settings = await service.loadSettings();
      expect(settings.fontSize, 14.0);
      expect(settings.tabSize, 2);
      expect(settings.insertSpaces, isTrue);
      expect(settings.wordWrap, isFalse);
      expect(settings.showLineNumbers, isTrue);
      expect(settings.showMinimap, isFalse);
    });

    test('saveSettings + loadSettings round-trip preserves all settings',
        () async {
      const settings = ScribeSettings(
        fontSize: 18.0,
        tabSize: 4,
        insertSpaces: false,
        wordWrap: true,
        showLineNumbers: false,
        showMinimap: true,
      );

      await service.saveSettings(settings);
      final loaded = await service.loadSettings();

      expect(loaded.fontSize, 18.0);
      expect(loaded.tabSize, 4);
      expect(loaded.insertSpaces, isFalse);
      expect(loaded.wordWrap, isTrue);
      expect(loaded.showLineNumbers, isFalse);
      expect(loaded.showMinimap, isTrue);
    });

    test('saveSettings overwrites previous settings', () async {
      await service
          .saveSettings(const ScribeSettings(fontSize: 16.0, tabSize: 4));
      await service
          .saveSettings(const ScribeSettings(fontSize: 20.0, tabSize: 8));

      final loaded = await service.loadSettings();
      expect(loaded.fontSize, 20.0);
      expect(loaded.tabSize, 8);
    });
  });
}
