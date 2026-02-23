// Tests for ScribeMarkdownSplit widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_markdown_split.dart';
import 'package:codeops/widgets/scribe/scribe_preview_controls.dart';

void main() {
  const testContent = '# Hello\n\nSome markdown content.';

  Widget createWidget({
    ScribePreviewMode mode = ScribePreviewMode.split,
    double splitRatio = 0.5,
    ValueChanged<double>? onSplitRatioChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: ScribeMarkdownSplit(
            editor: const Center(child: Text('Editor Pane')),
            content: testContent,
            mode: mode,
            splitRatio: splitRatio,
            onSplitRatioChanged: onSplitRatioChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('ScribeMarkdownSplit', () {
    testWidgets('shows only editor in editor mode', (tester) async {
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.editor,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editor Pane'), findsOneWidget);
      // Preview content should not be rendered.
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('shows only preview in preview mode', (tester) async {
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.preview,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editor Pane'), findsNothing);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows both panes in split mode', (tester) async {
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.split,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editor Pane'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('divider is draggable in split mode', (tester) async {
      double? lastRatio;
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.split,
        splitRatio: 0.5,
        onSplitRatioChanged: (r) => lastRatio = r,
      ));
      await tester.pumpAndSettle();

      // Find the divider — it's a Container with the resize cursor.
      // The divider is between the two panes; we'll find it by its
      // MouseRegion with resizeColumn cursor.
      final mouseRegions = find.byType(MouseRegion);
      expect(mouseRegions, findsWidgets);

      // Drag the divider to the right.
      final dividerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion &&
            widget.cursor == SystemMouseCursors.resizeColumn,
      );
      expect(dividerFinder, findsOneWidget);

      await tester.drag(dividerFinder, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(lastRatio, isNotNull);
      expect(lastRatio!, greaterThan(0.5));
    });

    testWidgets('double-tap divider resets to 50/50', (tester) async {
      double? lastRatio;
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.split,
        splitRatio: 0.7,
        onSplitRatioChanged: (r) => lastRatio = r,
      ));
      await tester.pumpAndSettle();

      final dividerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion &&
            widget.cursor == SystemMouseCursors.resizeColumn,
      );

      await tester.tap(dividerFinder);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(dividerFinder);
      await tester.pumpAndSettle();

      expect(lastRatio, 0.5);
    });
  });
}
