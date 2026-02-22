// Tests for DependencyGraphPage.
//
// Verifies loading, error, empty, and data states, header elements,
// startup order panel, cycle warning banner, layout selector,
// add dependency button, and sidebar toggle.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/pages/registry/dependency_graph_page.dart';
import 'package:codeops/providers/registry_providers.dart';

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

const _node3 = DependencyNodeResponse(
  serviceId: 'svc-3',
  name: 'Redis',
  slug: 'redis',
  serviceType: ServiceType.cacheService,
  status: ServiceStatus.active,
  healthStatus: HealthStatus.degraded,
);

const _testGraph = DependencyGraphResponse(
  teamId: 'team-1',
  nodes: [_node1, _node2, _node3],
  edges: [
    DependencyEdgeResponse(
      sourceServiceId: 'svc-1',
      targetServiceId: 'svc-2',
      dependencyType: DependencyType.databaseShared,
      isRequired: true,
    ),
    DependencyEdgeResponse(
      sourceServiceId: 'svc-1',
      targetServiceId: 'svc-3',
      dependencyType: DependencyType.redisShared,
      isRequired: false,
    ),
  ],
);

const _emptyGraph = DependencyGraphResponse(
  teamId: 'team-1',
  nodes: [],
  edges: [],
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildPage({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(body: DependencyGraphPage()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DependencyGraphPage', () {
    testWidgets('renders loading state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider.overrideWith(
              (ref) => Completer<DependencyGraphResponse>().future,
            ),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Dependency Graph'), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider.overrideWith(
              (ref) => throw Exception('Network error'),
            ),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to Load Graph'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders empty graph state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _emptyGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => <DependencyNodeResponse>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No dependencies'), findsOneWidget);
    });

    testWidgets('renders graph view with nodes', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CodeOps Server'), findsWidgets);
      expect(find.text('PostgreSQL'), findsWidgets);
      expect(find.text('Redis'), findsWidgets);
    });

    testWidgets('renders startup order panel', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Startup Order'), findsOneWidget);
      expect(find.text('3 services'), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('renders cycle warning banner when cycles exist',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider
                .overrideWith((ref) async => ['svc-1', 'svc-2']),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Circular dependencies detected'),
          findsOneWidget);
      expect(find.textContaining('2 services'), findsWidgets);
    });

    testWidgets('renders no cycle banner when clean', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('add dependency button exists', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Dependency'), findsOneWidget);
    });

    testWidgets('legend is present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Legend'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('sidebar toggle hides panel', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Sidebar visible
      expect(find.text('Startup Order'), findsOneWidget);

      // Tap sidebar toggle (chevron_left icon)
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Sidebar hidden
      expect(find.text('Startup Order'), findsNothing);
    });

    testWidgets('zoom controls are present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryDependencyGraphProvider
                .overrideWith((ref) async => _testGraph),
            registryCyclesProvider.overrideWith((ref) async => <String>[]),
            registryStartupOrderProvider
                .overrideWith((ref) async => [_node2, _node3, _node1]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Zoom in'), findsOneWidget);
      expect(find.byTooltip('Zoom out'), findsOneWidget);
      expect(find.byTooltip('Reset view'), findsOneWidget);
      expect(find.byTooltip('Fit to screen'), findsOneWidget);
    });
  });
}
