// Tests for Scribe providers.
//
// Verifies ScribeTabsNotifier, ScribeSettingsNotifier, and computed providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/providers/scribe_providers.dart';
import 'package:codeops/services/data/scribe_persistence_service.dart';

class MockScribePersistenceService extends Mock
    implements ScribePersistenceService {}

void main() {
  late MockScribePersistenceService mockPersistence;

  setUpAll(() {
    registerFallbackValue(<ScribeTab>[]);
    registerFallbackValue(const ScribeSettings());
  });

  setUp(() {
    mockPersistence = MockScribePersistenceService();
    when(() => mockPersistence.saveTabs(any())).thenAnswer((_) async {});
    when(() => mockPersistence.saveSettings(any())).thenAnswer((_) async {});
    when(() => mockPersistence.loadTabs()).thenAnswer((_) async => []);
    when(() => mockPersistence.loadSettings())
        .thenAnswer((_) async => const ScribeSettings());
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        scribePersistenceProvider.overrideWithValue(mockPersistence),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ScribeTabsNotifier', () {
    test('openTab adds a tab', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(
            title: 'test.dart',
            content: 'void main() {}',
            language: 'dart',
          );

      final tabs = container.read(scribeTabsProvider);
      expect(tabs, hasLength(1));
      expect(tabs.first.title, 'test.dart');
      expect(tabs.first.content, 'void main() {}');
      expect(tabs.first.language, 'dart');
    });

    test('openTab activates duplicate filePath instead of creating new tab',
        () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(
            title: 'file.dart',
            filePath: '/path/to/file.dart',
          );
      final firstId =
          container.read(scribeTabsProvider).first.id;

      container.read(scribeTabsProvider.notifier).openTab(
            title: 'file.dart',
            filePath: '/path/to/file.dart',
          );

      expect(container.read(scribeTabsProvider), hasLength(1));
      expect(container.read(activeScribeTabIdProvider), firstId);
    });

    test('openTab sets new tab as active', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 2');

      final tabs = container.read(scribeTabsProvider);
      final activeId = container.read(activeScribeTabIdProvider);
      expect(activeId, tabs.last.id);
    });

    test('closeTab removes tab', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 2');
      final tabToClose = container.read(scribeTabsProvider).first;

      container.read(scribeTabsProvider.notifier).closeTab(tabToClose.id);

      expect(container.read(scribeTabsProvider), hasLength(1));
      expect(container.read(scribeTabsProvider).first.title, 'Tab 2');
    });

    test('closeTab activates adjacent tab when active tab closed', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 2');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 3');

      final tabs = container.read(scribeTabsProvider);
      // Activate tab 2 (middle).
      container.read(activeScribeTabIdProvider.notifier).state = tabs[1].id;

      // Close tab 2 — should activate tab 3 (next).
      container.read(scribeTabsProvider.notifier).closeTab(tabs[1].id);

      final remaining = container.read(scribeTabsProvider);
      expect(remaining, hasLength(2));
      expect(
        container.read(activeScribeTabIdProvider),
        remaining[1].id,
      );
    });

    test('closeTab sets null when last tab closed', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Only tab');
      final tabId = container.read(scribeTabsProvider).first.id;

      container.read(scribeTabsProvider.notifier).closeTab(tabId);

      expect(container.read(scribeTabsProvider), isEmpty);
      expect(container.read(activeScribeTabIdProvider), isNull);
    });

    test('updateContent marks tab dirty', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Test');
      final tabId = container.read(scribeTabsProvider).first.id;

      container
          .read(scribeTabsProvider.notifier)
          .updateContent(tabId, 'modified content');

      final tab = container.read(scribeTabsProvider).first;
      expect(tab.isDirty, isTrue);
      expect(tab.content, 'modified content');
    });

    test('markClean resets dirty flag', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Test');
      final tabId = container.read(scribeTabsProvider).first.id;

      container
          .read(scribeTabsProvider.notifier)
          .updateContent(tabId, 'changed');
      expect(container.read(scribeTabsProvider).first.isDirty, isTrue);

      container.read(scribeTabsProvider.notifier).markClean(tabId);
      expect(container.read(scribeTabsProvider).first.isDirty, isFalse);
    });

    test('reorderTabs updates order', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'A');
      container.read(scribeTabsProvider.notifier).openTab(title: 'B');
      container.read(scribeTabsProvider.notifier).openTab(title: 'C');

      // Move first tab to end.
      container.read(scribeTabsProvider.notifier).reorderTabs(0, 3);

      final tabs = container.read(scribeTabsProvider);
      expect(tabs[0].title, 'B');
      expect(tabs[1].title, 'C');
      expect(tabs[2].title, 'A');
    });

    test('closeAllTabs clears state', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 2');

      container.read(scribeTabsProvider.notifier).closeAllTabs();

      expect(container.read(scribeTabsProvider), isEmpty);
      expect(container.read(activeScribeTabIdProvider), isNull);
    });

    test('closeOtherTabs keeps only specified tab', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Keep');
      final keepId = container.read(scribeTabsProvider).first.id;
      container.read(scribeTabsProvider.notifier).openTab(title: 'Remove 1');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Remove 2');

      container.read(scribeTabsProvider.notifier).closeOtherTabs(keepId);

      final tabs = container.read(scribeTabsProvider);
      expect(tabs, hasLength(1));
      expect(tabs.first.title, 'Keep');
      expect(container.read(activeScribeTabIdProvider), keepId);
    });

    test('updateLanguage changes language', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(
            title: 'Test',
            language: 'plaintext',
          );
      final tabId = container.read(scribeTabsProvider).first.id;

      container
          .read(scribeTabsProvider.notifier)
          .updateLanguage(tabId, 'python');

      expect(container.read(scribeTabsProvider).first.language, 'python');
    });

    test('loadFromPersistence loads tabs from database', () async {
      final now = DateTime(2026, 2, 20);
      final testTabs = [
        ScribeTab(
          id: 'persisted-1',
          title: 'saved.dart',
          content: 'saved content',
          language: 'dart',
          createdAt: now,
          lastModifiedAt: now,
        ),
      ];
      when(() => mockPersistence.loadTabs())
          .thenAnswer((_) async => testTabs);

      final container = createContainer();
      await container
          .read(scribeTabsProvider.notifier)
          .loadFromPersistence();

      expect(container.read(scribeTabsProvider), hasLength(1));
      expect(container.read(scribeTabsProvider).first.id, 'persisted-1');
    });
  });

  group('ScribeSettingsNotifier', () {
    test('updateFontSize clamps to valid range', () {
      final container = createContainer();

      container.read(scribeSettingsProvider.notifier).updateFontSize(8.0);
      expect(container.read(scribeSettingsProvider).fontSize, 12.0);

      container.read(scribeSettingsProvider.notifier).updateFontSize(30.0);
      expect(container.read(scribeSettingsProvider).fontSize, 24.0);

      container.read(scribeSettingsProvider.notifier).updateFontSize(16.0);
      expect(container.read(scribeSettingsProvider).fontSize, 16.0);
    });

    test('updateTabSize accepts valid values', () {
      final container = createContainer();

      container.read(scribeSettingsProvider.notifier).updateTabSize(4);
      expect(container.read(scribeSettingsProvider).tabSize, 4);

      container.read(scribeSettingsProvider.notifier).updateTabSize(8);
      expect(container.read(scribeSettingsProvider).tabSize, 8);
    });

    test('updateTabSize rejects invalid values', () {
      final container = createContainer();

      container.read(scribeSettingsProvider.notifier).updateTabSize(3);
      expect(container.read(scribeSettingsProvider).tabSize, 2);
    });

    test('toggleWordWrap toggles', () {
      final container = createContainer();

      expect(container.read(scribeSettingsProvider).wordWrap, isFalse);

      container.read(scribeSettingsProvider.notifier).toggleWordWrap();
      expect(container.read(scribeSettingsProvider).wordWrap, isTrue);

      container.read(scribeSettingsProvider.notifier).toggleWordWrap();
      expect(container.read(scribeSettingsProvider).wordWrap, isFalse);
    });

    test('toggleLineNumbers toggles', () {
      final container = createContainer();

      expect(container.read(scribeSettingsProvider).showLineNumbers, isTrue);

      container.read(scribeSettingsProvider.notifier).toggleLineNumbers();
      expect(container.read(scribeSettingsProvider).showLineNumbers, isFalse);
    });

    test('toggleMinimap toggles', () {
      final container = createContainer();

      expect(container.read(scribeSettingsProvider).showMinimap, isFalse);

      container.read(scribeSettingsProvider.notifier).toggleMinimap();
      expect(container.read(scribeSettingsProvider).showMinimap, isTrue);
    });

    test('setThemeMode changes theme', () {
      final container = createContainer();

      container.read(scribeSettingsProvider.notifier).setThemeMode('light');
      expect(container.read(scribeSettingsProvider).themeMode, 'light');

      container.read(scribeSettingsProvider.notifier).setThemeMode('dark');
      expect(container.read(scribeSettingsProvider).themeMode, 'dark');
    });

    test('setThemeMode rejects invalid mode', () {
      final container = createContainer();

      container.read(scribeSettingsProvider.notifier).setThemeMode('neon');
      expect(container.read(scribeSettingsProvider).themeMode, 'dark');
    });

    test('loadFromPersistence loads settings from database', () async {
      final testSettings = const ScribeSettings(
        fontSize: 18.0,
        tabSize: 4,
        wordWrap: true,
      );
      when(() => mockPersistence.loadSettings())
          .thenAnswer((_) async => testSettings);

      final container = createContainer();
      await container
          .read(scribeSettingsProvider.notifier)
          .loadFromPersistence();

      final settings = container.read(scribeSettingsProvider);
      expect(settings.fontSize, 18.0);
      expect(settings.tabSize, 4);
      expect(settings.wordWrap, isTrue);
    });
  });

  group('Computed providers', () {
    test('activeScribeTabProvider returns correct tab', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 2');

      final tabs = container.read(scribeTabsProvider);
      container.read(activeScribeTabIdProvider.notifier).state = tabs.first.id;

      final active = container.read(activeScribeTabProvider);
      expect(active, isNotNull);
      expect(active!.title, 'Tab 1');
    });

    test('activeScribeTabProvider returns null when no tabs', () {
      final container = createContainer();
      expect(container.read(activeScribeTabProvider), isNull);
    });

    test('activeScribeTabProvider returns null when id not found', () {
      final container = createContainer();
      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      container.read(activeScribeTabIdProvider.notifier).state = 'nonexistent';
      expect(container.read(activeScribeTabProvider), isNull);
    });

    test('hasUnsavedChangesProvider detects dirty tabs', () {
      final container = createContainer();

      container.read(scribeTabsProvider.notifier).openTab(title: 'Tab 1');
      expect(container.read(scribeHasUnsavedChangesProvider), isFalse);

      final tabId = container.read(scribeTabsProvider).first.id;
      container
          .read(scribeTabsProvider.notifier)
          .updateContent(tabId, 'changed');
      expect(container.read(scribeHasUnsavedChangesProvider), isTrue);
    });

    test('hasUnsavedChangesProvider returns false when empty', () {
      final container = createContainer();
      expect(container.read(scribeHasUnsavedChangesProvider), isFalse);
    });

    test('scribeTabCountProvider returns correct count', () {
      final container = createContainer();
      expect(container.read(scribeTabCountProvider), 0);

      container.read(scribeTabsProvider.notifier).openTab(title: 'A');
      container.read(scribeTabsProvider.notifier).openTab(title: 'B');
      expect(container.read(scribeTabCountProvider), 2);
    });
  });

  group('State providers', () {
    test('activeScribeTabIdProvider initializes null', () {
      final container = createContainer();
      expect(container.read(activeScribeTabIdProvider), isNull);
    });

    test('scribeUntitledCounterProvider initializes to 1', () {
      final container = createContainer();
      expect(container.read(scribeUntitledCounterProvider), 1);
    });

    test('scribeSidebarVisibleProvider initializes false', () {
      final container = createContainer();
      expect(container.read(scribeSidebarVisibleProvider), isFalse);
    });

    test('scribeSettingsProvider initializes with defaults', () {
      final container = createContainer();
      final settings = container.read(scribeSettingsProvider);
      expect(settings.fontSize, 14.0);
      expect(settings.tabSize, 2);
      expect(settings.insertSpaces, isTrue);
      expect(settings.wordWrap, isFalse);
      expect(settings.showLineNumbers, isTrue);
      expect(settings.showMinimap, isFalse);
      expect(settings.themeMode, 'dark');
    });
  });
}
