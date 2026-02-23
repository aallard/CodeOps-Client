// Tests for ScribeDiffEditor container widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_diff_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_diff_editor.dart';

void main() {
  final testDiffState = DiffState(
    leftTabId: 'tab-1',
    rightTabId: 'tab-2',
    lines: const [
      DiffLine(
        leftLineNumber: 1,
        rightLineNumber: 1,
        text: 'same',
        type: DiffLineType.unchanged,
      ),
      DiffLine(
        rightLineNumber: 2,
        text: 'added',
        type: DiffLineType.added,
      ),
      DiffLine(
        leftLineNumber: 2,
        rightLineNumber: 3,
        text: 'same again',
        type: DiffLineType.unchanged,
      ),
    ],
    summary: const DiffSummary(addedLines: 1),
    changeIndices: const [1],
  );

  Widget createWidget({
    DiffState? diffState,
    DiffViewMode viewMode = DiffViewMode.sideBySide,
    bool collapseUnchanged = false,
    List<DiffLine>? displayLines,
    ValueChanged<DiffViewMode>? onViewModeChanged,
    ValueChanged<bool>? onCollapseChanged,
    String? leftTitle,
    String? rightTitle,
  }) {
    final state = diffState ?? testDiffState;
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: ScribeDiffEditor(
            diffState: state,
            viewMode: viewMode,
            collapseUnchanged: collapseUnchanged,
            displayLines: displayLines ?? state.lines,
            onViewModeChanged: onViewModeChanged ?? (_) {},
            onCollapseChanged: onCollapseChanged ?? (_) {},
            leftTitle: leftTitle,
            rightTitle: rightTitle,
          ),
        ),
      ),
    );
  }

  group('ScribeDiffEditor', () {
    testWidgets('renders summary bar with stats', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('+1'), findsOneWidget);
      expect(find.text('-0'), findsOneWidget);
      expect(find.text('~0'), findsOneWidget);
    });

    testWidgets('shows side-by-side view by default', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Side-by-side shows content in both panes.
      expect(find.text('same'), findsNWidgets(2));
    });

    testWidgets('switches to inline view', (tester) async {
      await tester.pumpWidget(createWidget(
        viewMode: DiffViewMode.inline,
      ));
      await tester.pumpAndSettle();

      // Inline shows single pane.
      expect(find.text('same'), findsOneWidget);
    });

    testWidgets('shows pane headers when titles provided', (tester) async {
      await tester.pumpWidget(createWidget(
        leftTitle: 'original.dart',
        rightTitle: 'modified.dart',
      ));
      await tester.pumpAndSettle();

      expect(find.text('original.dart'), findsOneWidget);
      expect(find.text('modified.dart'), findsOneWidget);
    });

    testWidgets('does not show pane headers without titles', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Default titles "Original" / "Modified" should not appear.
      expect(find.text('Original'), findsNothing);
      expect(find.text('Modified'), findsNothing);
    });

    testWidgets('view mode toggle fires callback', (tester) async {
      DiffViewMode? changedMode;
      await tester.pumpWidget(createWidget(
        onViewModeChanged: (mode) => changedMode = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inline'));
      await tester.pumpAndSettle();

      expect(changedMode, DiffViewMode.inline);
    });
  });
}
