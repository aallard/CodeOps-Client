// Tests for Scribe providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/providers/scribe_providers.dart';

void main() {
  group('Scribe state providers', () {
    test('scribeTabsProvider initializes empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tabs = container.read(scribeTabsProvider);
      expect(tabs, isEmpty);
    });

    test('activeScribeTabIdProvider initializes null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final activeId = container.read(activeScribeTabIdProvider);
      expect(activeId, isNull);
    });

    test('scribeUntitledCounterProvider initializes to 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final counter = container.read(scribeUntitledCounterProvider);
      expect(counter, 1);
    });

    test('scribeSettingsProvider initializes with defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = container.read(scribeSettingsProvider);
      expect(settings.fontSize, 14.0);
      expect(settings.tabSize, 2);
      expect(settings.insertSpaces, isTrue);
      expect(settings.wordWrap, isFalse);
      expect(settings.showLineNumbers, isTrue);
      expect(settings.showMinimap, isFalse);
    });

    test('scribeTabsProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tab = ScribeTab.untitled(1);
      container.read(scribeTabsProvider.notifier).state = [tab];
      expect(container.read(scribeTabsProvider), hasLength(1));
      expect(container.read(scribeTabsProvider).first.id, tab.id);
    });

    test('activeScribeTabIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeScribeTabIdProvider.notifier).state = 'test-id';
      expect(container.read(activeScribeTabIdProvider), 'test-id');
    });
  });

  group('Scribe computed providers', () {
    test('activeScribeTabProvider returns null when no tabs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(activeScribeTabProvider), isNull);
    });

    test('activeScribeTabProvider returns null when activeId is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tab = ScribeTab.untitled(1);
      container.read(scribeTabsProvider.notifier).state = [tab];
      // activeId remains null.
      expect(container.read(activeScribeTabProvider), isNull);
    });

    test('activeScribeTabProvider returns correct tab when selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tab1 = ScribeTab.untitled(1);
      final tab2 = ScribeTab.untitled(2);
      container.read(scribeTabsProvider.notifier).state = [tab1, tab2];
      container.read(activeScribeTabIdProvider.notifier).state = tab2.id;

      final active = container.read(activeScribeTabProvider);
      expect(active, isNotNull);
      expect(active!.id, tab2.id);
      expect(active.title, 'Untitled-2');
    });

    test('activeScribeTabProvider returns null when id not found', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tab = ScribeTab.untitled(1);
      container.read(scribeTabsProvider.notifier).state = [tab];
      container.read(activeScribeTabIdProvider.notifier).state = 'nonexistent';

      expect(container.read(activeScribeTabProvider), isNull);
    });

    test('scribeHasUnsavedChangesProvider returns false when no dirty tabs',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tab = ScribeTab.untitled(1);
      container.read(scribeTabsProvider.notifier).state = [tab];

      expect(container.read(scribeHasUnsavedChangesProvider), isFalse);
    });

    test('scribeHasUnsavedChangesProvider returns true when any tab is dirty',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tab1 = ScribeTab.untitled(1);
      final tab2 = ScribeTab.untitled(2).copyWith(isDirty: true);
      container.read(scribeTabsProvider.notifier).state = [tab1, tab2];

      expect(container.read(scribeHasUnsavedChangesProvider), isTrue);
    });

    test('scribeHasUnsavedChangesProvider returns false when empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(scribeHasUnsavedChangesProvider), isFalse);
    });

    test('scribeTabCountProvider returns correct count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(scribeTabCountProvider), 0);

      container.read(scribeTabsProvider.notifier).state = [
        ScribeTab.untitled(1),
        ScribeTab.untitled(2),
        ScribeTab.untitled(3),
      ];

      expect(container.read(scribeTabCountProvider), 3);
    });

    test('scribeTabCountProvider returns 0 when empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(scribeTabCountProvider), 0);
    });
  });
}
