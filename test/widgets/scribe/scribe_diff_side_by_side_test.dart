// Tests for ScribeDiffSideBySide widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_diff_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_diff_side_by_side.dart';

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
          child: ScribeDiffSideBySide(
            lines: lines,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  group('ScribeDiffSideBySide', () {
    testWidgets('renders unchanged lines on both sides', (tester) async {
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

      // Both panes show the text.
      expect(find.text('same line'), findsNWidgets(2));
    });

    testWidgets('renders added line only on right side', (tester) async {
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

      // Right pane shows text, left shows empty.
      expect(find.text('new line'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('renders removed line only on left side', (tester) async {
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

    testWidgets('renders modified line with ~ marker', (tester) async {
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

      expect(find.text('~'), findsNWidgets(2));
    });

    testWidgets('renders padding line with descriptive text', (tester) async {
      await tester.pumpWidget(createWidget(
        lines: const [
          DiffLine(
            text: '5 unchanged lines',
            type: DiffLineType.padding,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('5 unchanged lines'), findsNWidgets(2));
    });
  });
}
