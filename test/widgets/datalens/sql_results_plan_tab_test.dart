// Widget tests for the Plan tab in SqlResultsPanel.
//
// Verifies the Plan tab renders, shows an empty state when no plan is
// present, and displays the PlanVisualizer when a PlanResult is provided.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/datalens/plan_execution_service.dart';
import 'package:codeops/widgets/datalens/plan_tree_visualizer.dart';
import 'package:codeops/widgets/datalens/sql_results_panel.dart';

Widget _createWidget({PlanResult? planResult}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 600,
        child: SqlResultsPanel(
          planResult: planResult,
        ),
      ),
    ),
  );
}

void main() {
  group('SqlResultsPanel Plan Tab', () {
    testWidgets('renders Plan tab button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Plan'), findsOneWidget);
    });

    testWidgets('shows empty state when no plan is present', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Switch to Plan tab.
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Run EXPLAIN to see the visual query plan'),
        findsOneWidget,
      );
    });

    testWidgets('shows PlanVisualizer when plan is provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final plan = PlanResult(
        root: const PlanNode(
          nodeType: 'Seq Scan',
          tableName: 'users',
          totalCost: 35.5,
          planRows: 100,
        ),
        rawOutput: '{}',
      );

      await tester.pumpWidget(_createWidget(planResult: plan));
      await tester.pumpAndSettle();

      // Switch to Plan tab.
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();

      // PlanVisualizer should be rendered with summary bar.
      expect(find.byType(PlanVisualizer), findsOneWidget);
      expect(find.text('Total Cost:'), findsOneWidget);
      expect(find.text('Seq Scan'), findsWidgets);
    });
  });
}
