// Widget tests for the plan table (tabular) view.
//
// Verifies flat table rendering with column headers, flattened node rows,
// and ANALYZE columns when available.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/datalens/plan_execution_service.dart';
import 'package:codeops/widgets/datalens/plan_tree_visualizer.dart';

PlanResult _testPlan({bool analyze = false}) {
  final root = PlanNode(
    nodeType: 'Nested Loop',
    totalCost: 100.0,
    planRows: 50,
    actualRows: analyze ? 48 : null,
    actualTime: analyze ? 1.5 : null,
    actualLoops: analyze ? 1 : null,
    children: [
      const PlanNode(
        nodeType: 'Index Scan',
        tableName: 'users',
        indexName: 'users_pkey',
        totalCost: 8.29,
        planRows: 1,
      ),
      const PlanNode(
        nodeType: 'Seq Scan',
        tableName: 'orders',
        totalCost: 35.0,
        planRows: 1000,
      ),
    ],
  );

  return PlanResult(
    root: root,
    rawOutput: '{}',
    isAnalyze: analyze,
  );
}

Widget _createWidget({bool analyze = false}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1400,
        height: 800,
        child: PlanVisualizer(planResult: _testPlan(analyze: analyze)),
      ),
    ),
  );
}

void main() {
  group('Plan Table View', () {
    testWidgets('renders table column headers', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      // Switch to Table sub-tab.
      await tester.tap(find.text('Table'));
      await tester.pumpAndSettle();

      expect(find.text('Node Type'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Rows Est'), findsOneWidget);
    });

    testWidgets('renders flattened node rows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Table'));
      await tester.pumpAndSettle();

      // All three nodes should appear as rows.
      expect(find.text('Nested Loop'), findsWidgets);
      expect(find.text('Index Scan'), findsWidgets);
      expect(find.text('Seq Scan'), findsWidgets);
      expect(find.text('users'), findsWidgets);
      expect(find.text('orders'), findsWidgets);
    });

    testWidgets('renders ANALYZE columns when available', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(analyze: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Table'));
      await tester.pumpAndSettle();

      expect(find.text('Rows Act'), findsOneWidget);
      expect(find.text('Time (ms)'), findsOneWidget);
    });

    testWidgets('does not render ANALYZE columns for non-ANALYZE plan',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(analyze: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Table'));
      await tester.pumpAndSettle();

      expect(find.text('Rows Act'), findsNothing);
      expect(find.text('Time (ms)'), findsNothing);
    });
  });
}
