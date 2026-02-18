// Tests for ScribeEmptyState widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_empty_state.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeEmptyState', () {
    testWidgets('renders code icon', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('renders Scribe title', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Scribe'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Code & text editor'), findsOneWidget);
    });

    testWidgets('renders New File button', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('New File'), findsOneWidget);
    });

    testWidgets('renders Open File button', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Open File'), findsOneWidget);
    });

    testWidgets('New File button fires onNewFile', (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () => called = true,
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New File'));
      expect(called, isTrue);
    });

    testWidgets('Open File button fires onOpenFile', (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () => called = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open File'));
      expect(called, isTrue);
    });

    testWidgets('renders keyboard shortcut hints', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeEmptyState(
          onNewFile: () {},
          onOpenFile: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Ctrl+N'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Ctrl+O'),
        findsOneWidget,
      );
    });
  });
}
