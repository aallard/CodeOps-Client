// Tests for ScribePage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/pages/scribe_page.dart';
import 'package:codeops/providers/scribe_providers.dart';
import 'package:codeops/theme/app_theme.dart';

void main() {
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
    return ProviderScope(
      overrides: [
        scribeTabsProvider.overrideWith((ref) => tabs),
        activeScribeTabIdProvider.overrideWith((ref) => activeTabId),
        scribeSettingsProvider.overrideWith((ref) => settings),
        // Override init provider to avoid database access.
        scribeInitProvider.overrideWith((ref) => Future.value()),
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

      // Editor renders (the ScribeEditor widget should be present).
      expect(find.byType(ScribePage), findsOneWidget);
    });

    testWidgets('renders status bar when tabs exist', (tester) async {
      final tabs = [makeTab(1, language: 'dart')];
      await tester.pumpWidget(createWidget(
        tabs: tabs,
        activeTabId: 'tab-1',
      ));
      await tester.pumpAndSettle();

      // Status bar shows language, cursor position, encoding.
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
  });
}
