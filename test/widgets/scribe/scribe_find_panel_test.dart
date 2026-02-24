// Tests for ScribeFindPanel.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_find_panel.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Column(children: [child])),
    );
  }

  group('ScribeFindPanel', () {
    testWidgets('renders find field with placeholder', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Find'), findsOneWidget);
    });

    testWidgets('renders toggle buttons for case, word, regex',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Aa'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('.*'), findsOneWidget);
    });

    testWidgets('renders navigation buttons', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close button fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(wrap(
        ScribeFindPanel(onClose: () => closed = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('replace row hidden by default', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Replace'), findsNothing);
    });

    testWidgets('replace row visible when showReplace is true',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(showReplace: true, onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Replace'), findsOneWidget);
    });

    testWidgets('displays match count when provided', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(
          onClose: () {},
          matchCount: 5,
          currentMatch: 2,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3 of 5 results'), findsOneWidget);
    });

    testWidgets('displays no results when matchCount is 0', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeFindPanel(
          onClose: () {},
          matchCount: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('expand button toggles replace visibility', (tester) async {
      var toggled = false;
      await tester.pumpWidget(wrap(
        ScribeFindPanel(
          onClose: () {},
          onToggleReplace: () => toggled = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_more));
      expect(toggled, isTrue);
    });
  });
}
