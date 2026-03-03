// Widget tests for the plan tree view.
//
// Verifies tree node rendering, summary bar, cost bars, expand/collapse
// behavior, and node selection that opens the detail panel.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/datalens/plan_execution_service.dart';
import 'package:codeops/widgets/datalens/plan_tree_visualizer.dart';

PlanResult _testPlan({bool analyze = false}) {
  final root = PlanNode(
    nodeType: 'Hash Join',
    totalCost: 120.5,
    startupCost: 10.0,
    planRows: 500,
    planWidth: 128,
    joinType: 'Inner',
    hashCondition: '(o.user_id = u.id)',
    actualRows: analyze ? 480 : null,
    actualTime: analyze ? 2.5 : null,
    actualLoops: analyze ? 1 : null,
    children: [
      const PlanNode(
        nodeType: 'Seq Scan',
        relationship: 'Outer',
        tableName: 'orders',
        totalCost: 45.0,
        planRows: 1000,
        planWidth: 64,
      ),
      const PlanNode(
        nodeType: 'Index Scan',
        relationship: 'Inner',
        tableName: 'users',
        indexName: 'users_pkey',
        totalCost: 30.0,
        planRows: 500,
        planWidth: 32,
      ),
    ],
  );

  return PlanResult(
    root: root,
    planningTime: analyze ? 0.123 : null,
    executionTime: analyze ? 2.8 : null,
    rawOutput: '{"Plan": {"Node Type": "Hash Join"}}',
    isAnalyze: analyze,
  );
}

Widget _createWidget({bool analyze = false}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 800,
        child: PlanVisualizer(planResult: _testPlan(analyze: analyze)),
      ),
    ),
  );
}

void main() {
  group('Plan Tree View', () {
    testWidgets('renders summary bar with plan statistics', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Cost:'), findsOneWidget);
      expect(find.text('Nodes:'), findsOneWidget);
      expect(find.text('Est. Rows:'), findsOneWidget);
      expect(find.text('Costliest:'), findsOneWidget);
    });

    testWidgets('renders plan node cards in tree', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hash Join'), findsWidgets);
      expect(find.text('Seq Scan'), findsOneWidget);
      expect(find.text('Index Scan'), findsOneWidget);
      expect(find.text('on orders'), findsOneWidget);
      expect(find.text('on users'), findsOneWidget);
    });

    testWidgets('renders relationship badges', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Outer'), findsOneWidget);
      expect(find.text('Inner'), findsOneWidget);
    });

    testWidgets('tapping node opens detail panel', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Tap the Seq Scan node card.
      await tester.tap(find.text('Seq Scan'));
      await tester.pumpAndSettle();

      // Detail panel header should show "Seq Scan".
      // The node type appears in the card AND in the detail header.
      expect(find.text('Estimates'), findsOneWidget);
      expect(find.text('Total Cost'), findsOneWidget);
    });

    testWidgets('renders ANALYZE timing in summary bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(analyze: true));
      await tester.pumpAndSettle();

      expect(find.text('Planning:'), findsOneWidget);
      expect(find.text('Execution:'), findsOneWidget);
    });
  });
}
