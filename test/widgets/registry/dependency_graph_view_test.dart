// Tests for DependencyGraphView widget.
//
// Verifies node rendering, node tap callbacks, selection highlighting,
// cycle node red border, zoom controls, and empty state.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/providers/registry_providers.dart';
import 'package:codeops/widgets/registry/dependency_graph_view.dart';
import 'package:codeops/widgets/registry/graph_node_widget.dart';

const _node1 = DependencyNodeResponse(
  serviceId: 'svc-1',
  name: 'CodeOps Server',
  slug: 'codeops-server',
  serviceType: ServiceType.springBootApi,
  status: ServiceStatus.active,
  healthStatus: HealthStatus.up,
);

const _node2 = DependencyNodeResponse(
  serviceId: 'svc-2',
  name: 'PostgreSQL',
  slug: 'postgresql',
  serviceType: ServiceType.databaseService,
  status: ServiceStatus.active,
  healthStatus: HealthStatus.up,
);

const _testGraph = DependencyGraphResponse(
  teamId: 'team-1',
  nodes: [_node1, _node2],
  edges: [
    DependencyEdgeResponse(
      sourceServiceId: 'svc-1',
      targetServiceId: 'svc-2',
      dependencyType: DependencyType.databaseShared,
      isRequired: true,
    ),
  ],
);

const _emptyGraph = DependencyGraphResponse(
  teamId: 'team-1',
  nodes: [],
  edges: [],
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildView({
  DependencyGraphResponse graph = _testGraph,
  Set<String> cycleNodeIds = const {},
  GraphLayoutType layoutType = GraphLayoutType.layered,
  ValueChanged<DependencyNodeResponse>? onNodeTap,
  String? selectedNodeId,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 800,
        child: DependencyGraphView(
          graph: graph,
          cycleNodeIds: cycleNodeIds,
          layoutType: layoutType,
          onNodeTap: onNodeTap,
          selectedNodeId: selectedNodeId,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DependencyGraphView', () {
    testWidgets('renders node widgets', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      expect(find.byType(GraphNodeWidget), findsNWidgets(2));
      expect(find.text('CodeOps Server'), findsOneWidget);
      expect(find.text('PostgreSQL'), findsOneWidget);
    });

    testWidgets('node tap calls callback', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      DependencyNodeResponse? tappedNode;
      await tester.pumpWidget(_buildView(
        onNodeTap: (node) => tappedNode = node,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CodeOps Server'));
      expect(tappedNode?.serviceId, 'svc-1');
    });

    testWidgets('renders empty state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView(graph: _emptyGraph));
      await tester.pumpAndSettle();

      expect(find.text('No dependencies'), findsOneWidget);
      expect(find.text('Add dependencies to see the graph.'), findsOneWidget);
    });

    testWidgets('zoom controls present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Zoom in'), findsOneWidget);
      expect(find.byTooltip('Zoom out'), findsOneWidget);
      expect(find.byTooltip('Fit to screen'), findsOneWidget);
    });

    testWidgets('selected node has GraphNodeWidget with isSelected',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView(selectedNodeId: 'svc-1'));
      await tester.pumpAndSettle();

      // Find GraphNodeWidgets and check isSelected
      final widgets = tester
          .widgetList<GraphNodeWidget>(find.byType(GraphNodeWidget))
          .toList();
      final selectedWidget =
          widgets.firstWhere((w) => w.node.serviceId == 'svc-1');
      expect(selectedWidget.isSelected, isTrue);

      final unselectedWidget =
          widgets.firstWhere((w) => w.node.serviceId == 'svc-2');
      expect(unselectedWidget.isSelected, isFalse);
    });

    testWidgets('cycle nodes have isCycleNode set', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
          _buildView(cycleNodeIds: {'svc-1'}));
      await tester.pumpAndSettle();

      final widgets = tester
          .widgetList<GraphNodeWidget>(find.byType(GraphNodeWidget))
          .toList();
      final cycleWidget =
          widgets.firstWhere((w) => w.node.serviceId == 'svc-1');
      expect(cycleWidget.isCycleNode, isTrue);

      final normalWidget =
          widgets.firstWhere((w) => w.node.serviceId == 'svc-2');
      expect(normalWidget.isCycleNode, isFalse);
    });
  });
}
