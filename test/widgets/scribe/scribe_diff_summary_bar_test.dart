// Tests for ScribeDiffSummaryBar widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_diff_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_diff_summary_bar.dart';

void main() {
  Widget createWidget({
    DiffSummary summary = const DiffSummary(
      addedLines: 5,
      removedLines: 3,
      modifiedLines: 2,
    ),
    DiffViewMode viewMode = DiffViewMode.sideBySide,
    ValueChanged<DiffViewMode>? onViewModeChanged,
    VoidCallback? onPreviousChange,
    VoidCallback? onNextChange,
    bool collapseUnchanged = true,
    ValueChanged<bool>? onCollapseChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ScribeDiffSummaryBar(
          summary: summary,
          viewMode: viewMode,
          onViewModeChanged: onViewModeChanged ?? (_) {},
          onPreviousChange: onPreviousChange,
          onNextChange: onNextChange,
          collapseUnchanged: collapseUnchanged,
          onCollapseChanged: onCollapseChanged ?? (_) {},
        ),
      ),
    );
  }

  group('ScribeDiffSummaryBar', () {
    testWidgets('shows added, removed, modified counts', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('+5'), findsOneWidget);
      expect(find.text('-3'), findsOneWidget);
      expect(find.text('~2'), findsOneWidget);
    });

    testWidgets('shows Side by Side and Inline mode labels', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Side by Side'), findsOneWidget);
      expect(find.text('Inline'), findsOneWidget);
    });

    testWidgets('tapping Inline fires onViewModeChanged', (tester) async {
      DiffViewMode? changedMode;
      await tester.pumpWidget(createWidget(
        viewMode: DiffViewMode.sideBySide,
        onViewModeChanged: (mode) => changedMode = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inline'));
      await tester.pumpAndSettle();

      expect(changedMode, DiffViewMode.inline);
    });

    testWidgets('shows Collapse label', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Collapse'), findsOneWidget);
    });

    testWidgets('navigation buttons present when callbacks provided',
        (tester) async {
      await tester.pumpWidget(createWidget(
        onPreviousChange: () {},
        onNextChange: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('zero counts render correctly', (tester) async {
      await tester.pumpWidget(createWidget(
        summary: const DiffSummary(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('+0'), findsOneWidget);
      expect(find.text('-0'), findsOneWidget);
      expect(find.text('~0'), findsOneWidget);
    });
  });
}
