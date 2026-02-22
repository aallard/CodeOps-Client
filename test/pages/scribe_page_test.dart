// Tests for ScribePage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/pages/scribe_page.dart';
import 'package:codeops/providers/scribe_providers.dart';
import 'package:codeops/services/data/scribe_persistence_service.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_sidebar.dart';

class MockScribePersistenceService extends Mock
    implements ScribePersistenceService {}

void main() {
  setUpAll(() {
    registerFallbackValue(<ScribeTab>[]);
    registerFallbackValue(const ScribeSettings());
  });

  final now = DateTime(2026, 2, 17);

  ScribeTab makeTab(int n, {String content = '', String language = 'dart'}) {
    return ScribeTab(
      id: 'tab-$n',
      title: 'File-$n.dart',
      content: content,
      language: language,
      createdAt: now,
      lastModifiedAt: now,
    );
  }

  Widget createWidget({
    List<ScribeTab> tabs = const [],
    String? activeTabId,
    ScribeSettings settings = const ScribeSettings(),
  }) {
    final mockPersistence = MockScribePersistenceService();
    when(() => mockPersistence.loadTabs()).thenAnswer((_) async => tabs);
    when(() => mockPersistence.loadSettings())
        .thenAnswer((_) async => settings);
    when(() => mockPersistence.saveTabs(any())).thenAnswer((_) async {});
    when(() => mockPersistence.saveSettings(any())).thenAnswer((_) async {});

    return ProviderScope(
      overrides: [
        scribePersistenceProvider.overrideWithValue(mockPersistence),
        scribeInitProvider.overrideWith((ref) async {
          await ref.read(scribeTabsProvider.notifier).loadFromPersistence();
          await ref
              .read(scribeSettingsProvider.notifier)
              .loadFromPersistence();
          final loadedTabs = ref.read(scribeTabsProvider);
          if (activeTabId != null) {
            ref.read(activeScribeTabIdProvider.notifier).state = activeTabId;
          } else if (loadedTabs.isNotEmpty) {
            ref.read(activeScribeTabIdProvider.notifier).state =
                loadedTabs.first.id;
          }
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: ScribePage()),
      ),
    );
  }

  group('ScribePage', () {
    testWidgets('renders empty state when no tabs are open', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Scribe'), findsOneWidget);
      expect(find.text('Code & text editor'), findsOneWidget);
      expect(find.text('New File'), findsOneWidget);
      expect(find.text('Open File'), findsOneWidget);
    });

    testWidgets('renders tab bar when tabs exist', (tester) async {
      final tabs = [makeTab(1), makeTab(2)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.text('File-1.dart'), findsOneWidget);
      expect(find.text('File-2.dart'), findsOneWidget);
    });

    testWidgets('renders editor when active tab exists', (tester) async {
      final tabs = [makeTab(1, content: 'void main() {}')];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScribePage), findsOneWidget);
    });

    testWidgets('renders status bar when tabs exist', (tester) async {
      final tabs = [makeTab(1, language: 'dart')];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Ln 1, Col 1'), findsOneWidget);
      expect(find.text('UTF-8'), findsOneWidget);
      expect(find.text('LF'), findsOneWidget);
    });

    testWidgets('status bar shows correct language for SQL tab',
        (tester) async {
      final tabs = [makeTab(1, language: 'sql')];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.text('SQL'), findsOneWidget);
    });

    testWidgets('new tab button creates an untitled tab', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Click "New File" in empty state.
      await tester.tap(find.text('New File'));
      await tester.pumpAndSettle();

      // After creating a tab, the tab bar should show.
      expect(find.text('Untitled-1'), findsOneWidget);
    });

    testWidgets('renders new tab button in tab bar', (tester) async {
      final tabs = [makeTab(1)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('hides empty state when tabs exist', (tester) async {
      final tabs = [makeTab(1)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Code & text editor'), findsNothing);
    });

    testWidgets('switches tab when tab title clicked', (tester) async {
      final tabs = [makeTab(1), makeTab(2)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      // Tap second tab title.
      await tester.tap(find.text('File-2.dart'));
      await tester.pumpAndSettle();

      // The tab should now be active (but both tabs still visible).
      expect(find.text('File-1.dart'), findsOneWidget);
      expect(find.text('File-2.dart'), findsOneWidget);
    });

    testWidgets('closes tab when close button clicked', (tester) async {
      final tabs = [makeTab(1), makeTab(2)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      // Find close buttons (one per tab).
      final closeButtons = find.byIcon(Icons.close);
      expect(closeButtons, findsNWidgets(2));

      // Tap first close button.
      await tester.tap(closeButtons.first);
      await tester.pumpAndSettle();

      // First tab should be removed.
      expect(find.text('File-1.dart'), findsNothing);
      expect(find.text('File-2.dart'), findsOneWidget);
    });

    testWidgets('shows dirty indicator when tab is dirty', (tester) async {
      final dirtyTab = makeTab(1).copyWith(isDirty: true);
      await tester.pumpWidget(createWidget(
        tabs: [dirtyTab],
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      // Dirty indicator is the Unicode bullet \u25CF.
      expect(find.text('\u25CF'), findsOneWidget);
    });

    testWidgets('no dirty indicator on clean tab', (tester) async {
      final cleanTab = makeTab(1);
      await tester.pumpWidget(createWidget(
        tabs: [cleanTab],
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      // The bullet should NOT appear.
      expect(find.text('\u25CF'), findsNothing);
    });

    testWidgets('sidebar toggle button is present when tabs exist',
        (tester) async {
      final tabs = [makeTab(1)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.vertical_split), findsOneWidget);
    });

    testWidgets('sidebar is hidden by default', (tester) async {
      final tabs = [makeTab(1)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScribeSidebar), findsNothing);
    });

    testWidgets('sidebar appears when toggle clicked', (tester) async {
      final tabs = [makeTab(1)];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      // Click sidebar toggle.
      await tester.tap(find.byIcon(Icons.vertical_split));
      await tester.pumpAndSettle();

      expect(find.byType(ScribeSidebar), findsOneWidget);
      expect(find.text('OPEN FILES'), findsOneWidget);
    });
  });
}
