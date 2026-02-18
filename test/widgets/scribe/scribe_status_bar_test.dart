// Tests for ScribeStatusBar widget.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_status_bar.dart';

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('ScribeStatusBar', () {
    testWidgets('displays language name', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'dart',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('displays cursor position as 1-based', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 41,
          cursorColumn: 14,
          language: 'plaintext',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ln 42, Col 15'), findsOneWidget);
    });

    testWidgets('shows UTF-8 encoding', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'plaintext',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('UTF-8'), findsOneWidget);
    });

    testWidgets('shows LF line ending', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'plaintext',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('LF'), findsOneWidget);
    });

    testWidgets('displays JavaScript language name correctly',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'javascript',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('JavaScript'), findsOneWidget);
    });

    testWidgets('displays SQL language name correctly', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'sql',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SQL'), findsOneWidget);
    });

    testWidgets('displays cursor at line 1, col 1 for zero-based 0,0',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'plaintext',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ln 1, Col 1'), findsOneWidget);
    });

    testWidgets('language dropdown shows arrow icon', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeStatusBar(
          cursorLine: 0,
          cursorColumn: 0,
          language: 'dart',
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });
  });
}
