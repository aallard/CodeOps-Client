// Tests for ScribeTabBar widget.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_tab_bar.dart';

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  final now = DateTime(2026, 2, 17);
  ScribeTab makeTab(int n, {bool isDirty = false}) {
    return ScribeTab(
      id: 'tab-$n',
      title: 'File-$n.dart',
      createdAt: now,
      lastModifiedAt: now,
      isDirty: isDirty,
      language: 'dart',
    );
  }

  group('ScribeTabBar', () {
    testWidgets('renders correct number of tabs', (tester) async {
      final tabs = [makeTab(1), makeTab(2), makeTab(3)];
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: tabs,
          activeTabId: 'tab-1',
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('File-1.dart'), findsOneWidget);
      expect(find.text('File-2.dart'), findsOneWidget);
      expect(find.text('File-3.dart'), findsOneWidget);
    });

    testWidgets('renders new tab button', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: const [],
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('new tab button fires onNewTab', (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: const [],
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () => called = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      expect(called, isTrue);
    });

    testWidgets('tab click fires onTabSelected with correct id',
        (tester) async {
      String? selectedId;
      final tabs = [makeTab(1), makeTab(2)];
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: tabs,
          activeTabId: 'tab-1',
          onTabSelected: (id) => selectedId = id,
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('File-2.dart'));
      expect(selectedId, 'tab-2');
    });

    testWidgets('close button fires onTabClosed with correct id',
        (tester) async {
      String? closedId;
      final tabs = [makeTab(1)];
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: tabs,
          activeTabId: 'tab-1',
          onTabSelected: (_) {},
          onTabClosed: (id) => closedId = id,
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      expect(closedId, 'tab-1');
    });

    testWidgets('dirty indicator shows on dirty tabs', (tester) async {
      final tabs = [makeTab(1, isDirty: true)];
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: tabs,
          activeTabId: 'tab-1',
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // The dirty indicator is a ● character.
      expect(find.text('\u25CF'), findsOneWidget);
    });

    testWidgets('dirty indicator hidden on clean tabs', (tester) async {
      final tabs = [makeTab(1, isDirty: false)];
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: tabs,
          activeTabId: 'tab-1',
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('\u25CF'), findsNothing);
    });

    testWidgets('empty tab list renders only the new tab button',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: const [],
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders with multiple tabs including dirty ones',
        (tester) async {
      final tabs = [
        makeTab(1, isDirty: false),
        makeTab(2, isDirty: true),
        makeTab(3, isDirty: false),
      ];
      await tester.pumpWidget(wrap(
        ScribeTabBar(
          tabs: tabs,
          activeTabId: 'tab-2',
          onTabSelected: (_) {},
          onTabClosed: (_) {},
          onNewTab: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('File-1.dart'), findsOneWidget);
      expect(find.text('File-2.dart'), findsOneWidget);
      expect(find.text('File-3.dart'), findsOneWidget);
      // Only one dirty indicator.
      expect(find.text('\u25CF'), findsOneWidget);
    });
  });
}
