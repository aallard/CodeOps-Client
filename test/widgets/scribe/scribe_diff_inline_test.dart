// Tests for ScribeDiffInline widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_diff_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_diff_inline.dart';

void main() {
  Widget createWidget({
    required List<DiffLine> lines,
    double fontSize = 13.0,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: ScribeDiffInline(
            lines: lines,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  group('ScribeDiffInline', () {
    testWidgets('renders unchanged lines with space prefix', (tester) async {
      await tester.pumpWidget(createWidget(
        lines: const [
          DiffLine(
            leftLineNumber: 1,
            rightLineNumber: 1,
            text: 'same line',
            type: DiffLineType.unchanged,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('same line'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2)); // Both gutters show 1.
    });

    testWidgets('renders added lines with + prefix', (tester) async {
      await tester.pumpWidget(createWidget(
        lines: const [
          DiffLine(
            rightLineNumber: 1,
            text: 'new line',
            type: DiffLineType.added,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('new line'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('renders removed lines with - prefix', (tester) async {
      await tester.pumpWidget(createWidget(
        lines: const [
          DiffLine(
            leftLineNumber: 1,
            text: 'old line',
            type: DiffLineType.removed,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('old line'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('expands modified lines into remove+add pair',
        (tester) async {
      await tester.pumpWidget(createWidget(
        lines: const [
          DiffLine(
            leftLineNumber: 1,
            rightLineNumber: 1,
            text: 'world',
            type: DiffLineType.modified,
            pairedText: 'hello',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Modified expands to removed (hello) + added (world).
      expect(find.text('hello'), findsOneWidget);
      expect(find.text('world'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('renders padding line', (tester) async {
      await tester.pumpWidget(createWidget(
        lines: const [
          DiffLine(
            text: '10 unchanged lines',
            type: DiffLineType.padding,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('10 unchanged lines'), findsOneWidget);
    });
  });
}
