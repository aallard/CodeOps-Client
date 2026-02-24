// Tests for ScribeShortcutsHelp overlay.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_shortcuts_help.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeShortcutsHelp', () {
    testWidgets('displays title and keyboard icon', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeShortcutsHelp(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      // Title in header + the "Keyboard Shortcuts" command entry.
      expect(find.text('Keyboard Shortcuts'), findsNWidgets(2));
      expect(find.byIcon(Icons.keyboard), findsOneWidget);
    });

    testWidgets('displays category headers', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeShortcutsHelp(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('File'), findsOneWidget);
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Tabs'), findsOneWidget);
    });

    testWidgets('displays command labels with shortcuts', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeShortcutsHelp(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      // Should show commands that have shortcuts.
      expect(find.text('New File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Find'), findsOneWidget);
      expect(find.text('Close Tab'), findsOneWidget);
    });

    testWidgets('close button fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(wrap(
        ScribeShortcutsHelp(onClose: () => closed = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('does not show commands without shortcuts', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeShortcutsHelp(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      // "Open from URL..." has no shortcut, should not appear.
      expect(find.text('Open from URL...'), findsNothing);
    });
  });
}
