// Widget tests for the plan detail panel.
//
// Verifies node property display, ANALYZE actual-vs-estimated comparison,
// access details (table, index, schema), and condition rendering.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/datalens/plan_execution_service.dart';
import 'package:codeops/widgets/datalens/plan_tree_visualizer.dart';

PlanResult _testPlan() {
  final root = PlanNode(
    nodeType: 'Index Scan',
    totalCost: 8.29,
    startupCost: 0.28,
    planRows: 1,
    planWidth: 64,
    tableName: 'users',
    schemaName: 'public',
    alias: 'u',
    indexName: 'users_pkey',
    scanDirection: 'Forward',
    indexCondition: '(id = 42)',
    filter: '(active = true)',
    hashCondition: null,
    actualRows: 1,
    actualTime: 0.022,
    actualLoops: 1,
    actualStartupTime: 0.015,
    actualTotalTime: 0.022,
    rowsRemovedByFilter: 3,
    sortKey: ['name ASC'],
    output: ['id', 'name', 'email'],
  );

  return PlanResult(
    root: root,
    planningTime: 0.05,
    executionTime: 0.035,
    rawOutput: '{}',
    isAnalyze: true,
  );
}

Widget _createWidget() {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 800,
        child: PlanVisualizer(planResult: _testPlan()),
      ),
    ),
  );
}

void main() {
  group('Plan Detail Panel', () {
    testWidgets('renders node properties when node is selected',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Tap the node card to open the detail panel.
      // Tap the node card text (last match — the first match is in the
      // summary bar's "Costliest" metric value).
      await tester.tap(find.text('Index Scan').last);
      await tester.pumpAndSettle();

      // Estimates section.
      expect(find.text('Estimates'), findsOneWidget);
      expect(find.text('8.29'), findsWidgets);
      expect(find.text('0.28'), findsWidgets);
    });

    testWidgets('renders ANALYZE comparison with percentage', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Tap the node card text (last match — the first match is in the
      // summary bar's "Costliest" metric value).
      await tester.tap(find.text('Index Scan').last);
      await tester.pumpAndSettle();

      expect(find.text('Actual vs Estimated'), findsOneWidget);
      expect(find.text('Loops'), findsWidgets);
    });

    testWidgets('renders access details section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Tap the node card text (last match — the first match is in the
      // summary bar's "Costliest" metric value).
      await tester.tap(find.text('Index Scan').last);
      await tester.pumpAndSettle();

      expect(find.text('Access Details'), findsOneWidget);
      expect(find.text('users_pkey'), findsWidgets);
      expect(find.text('Forward'), findsOneWidget);
    });

    testWidgets('renders conditions section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Tap the node card text (last match — the first match is in the
      // summary bar's "Costliest" metric value).
      await tester.tap(find.text('Index Scan').last);
      await tester.pumpAndSettle();

      expect(find.text('Conditions'), findsOneWidget);
      expect(find.text('(active = true)'), findsWidgets);
      expect(find.text('(id = 42)'), findsOneWidget);
    });
  });
}
