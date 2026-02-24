// Tests for ScribeGoToLineDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_go_to_line_dialog.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeGoToLineDialog', () {
    testWidgets('displays title and line range', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeGoToLineDialog.show(
              context,
              totalLines: 100,
            ),
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Go to Line'), findsOneWidget);
      expect(find.textContaining('1–100'), findsOneWidget);
    });

    testWidgets('Cancel returns null', (tester) async {
      int? result = -1;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeGoToLineDialog.show(
                context,
                totalLines: 50,
              );
            },
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('valid line number returns 0-based index', (tester) async {
      int? result;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeGoToLineDialog.show(
                context,
                totalLines: 100,
              );
            },
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '42');
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(result, 41); // 0-based.
    });

    testWidgets('shows error for out-of-range line', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeGoToLineDialog.show(
              context,
              totalLines: 10,
            ),
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '99');
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.textContaining('between 1 and 10'), findsOneWidget);
    });

    testWidgets('shows error for empty input', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeGoToLineDialog.show(
              context,
              totalLines: 10,
            ),
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Don't enter anything, just press Go.
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a line number.'), findsOneWidget);
    });

    testWidgets('shows placeholder with current line', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeGoToLineDialog.show(
              context,
              totalLines: 100,
              currentLine: 25,
            ),
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Line 25'), findsOneWidget);
    });
  });
}
