// Tests for ScribeTabContextMenu.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_tab_context_menu.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeTabContextMenu', () {
    testWidgets('renders all 7 menu items', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              filePath: '/some/path.dart',
              onClose: () {},
              onCloseOthers: () {},
              onCloseAll: () {},
              onCloseToRight: () {},
              onCloseSaved: () {},
              onCopyFilePath: () {},
              onRevealInFinder: () {},
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Close Others'), findsOneWidget);
      expect(find.text('Close All'), findsOneWidget);
      expect(find.text('Close to the Right'), findsOneWidget);
      expect(find.text('Close Saved'), findsOneWidget);
      expect(find.text('Copy File Path'), findsOneWidget);
      expect(find.text('Reveal in Finder'), findsOneWidget);
    });

    testWidgets('Close action fires onClose callback', (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              onClose: () => closeCalled = true,
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    testWidgets('Close Others action fires onCloseOthers callback',
        (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              onClose: () {},
              onCloseOthers: () => called = true,
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close Others'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('Close to the Right fires onCloseToRight callback',
        (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              onClose: () {},
              onCloseToRight: () => called = true,
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close to the Right'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('Close Saved fires onCloseSaved callback', (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              onClose: () {},
              onCloseSaved: () => called = true,
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close Saved'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('Copy File Path disabled when filePath is null',
        (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              filePath: null,
              onClose: () {},
              onCopyFilePath: () => called = true,
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      // The item should render but be disabled.
      expect(find.text('Copy File Path'), findsOneWidget);

      // Tapping a disabled item should not fire the callback.
      await tester.tap(find.text('Copy File Path'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('Reveal in Finder disabled when filePath is null',
        (tester) async {
      var called = false;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              filePath: null,
              onClose: () {},
              onRevealInFinder: () => called = true,
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      expect(find.text('Reveal in Finder'), findsOneWidget);

      await tester.tap(find.text('Reveal in Finder'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('shows Ctrl+W shortcut hint on Close item', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () => ScribeTabContextMenu.show(
              context,
              position: const Offset(100, 100),
              onClose: () {},
            ),
            child: const Text('open menu'),
          );
        }),
      ));

      await tester.tap(find.text('open menu'));
      await tester.pumpAndSettle();

      expect(find.text('Ctrl+W'), findsOneWidget);
    });
  });
}
