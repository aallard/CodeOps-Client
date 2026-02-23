// Tests for ScribeMarkdownToc widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_markdown_toc.dart';

void main() {
  Widget createWidget({
    required String content,
    int currentLine = 0,
    ValueChanged<int>? onHeadingSelected,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: ScribeMarkdownToc(
            content: content,
            currentLine: currentLine,
            onHeadingSelected: onHeadingSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('ScribeMarkdownToc', () {
    testWidgets('hides when no headings present', (tester) async {
      await tester.pumpWidget(createWidget(content: 'No headings here'));
      await tester.pumpAndSettle();

      // SizedBox.shrink() renders nothing visible.
      expect(find.text('TOC'), findsNothing);
    });

    testWidgets('shows TOC button when headings exist', (tester) async {
      await tester.pumpWidget(createWidget(
        content: '# Title\n## Section',
      ));
      await tester.pumpAndSettle();

      expect(find.text('TOC'), findsOneWidget);
    });

    testWidgets('opens dropdown showing headings on tap', (tester) async {
      await tester.pumpWidget(createWidget(
        content: '# Title\n## Section\n### Subsection',
      ));
      await tester.pumpAndSettle();

      // Tap the TOC button to open the popup menu.
      await tester.tap(find.text('TOC'));
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Section'), findsOneWidget);
      expect(find.text('Subsection'), findsOneWidget);
    });

    testWidgets('fires onHeadingSelected when heading tapped', (tester) async {
      int? selectedLine;
      await tester.pumpWidget(createWidget(
        content: '# First\n\n## Second',
        onHeadingSelected: (line) => selectedLine = line,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('TOC'));
      await tester.pumpAndSettle();

      // Tap "Second" heading (line 2).
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(selectedLine, 2);
    });
  });
}
