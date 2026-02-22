// Tests for StartupOrderPanel widget.
//
// Verifies numbered list rendering, service names, health dots,
// and tap callbacks.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/widgets/registry/startup_order_panel.dart';

const _testOrder = [
  DependencyNodeResponse(
    serviceId: 'svc-1',
    name: 'PostgreSQL',
    slug: 'postgresql',
    serviceType: ServiceType.databaseService,
    status: ServiceStatus.active,
    healthStatus: HealthStatus.up,
  ),
  DependencyNodeResponse(
    serviceId: 'svc-2',
    name: 'Redis',
    slug: 'redis',
    serviceType: ServiceType.cacheService,
    status: ServiceStatus.active,
    healthStatus: HealthStatus.up,
  ),
  DependencyNodeResponse(
    serviceId: 'svc-3',
    name: 'CodeOps Server',
    slug: 'codeops-server',
    serviceType: ServiceType.springBootApi,
    status: ServiceStatus.active,
    healthStatus: HealthStatus.degraded,
  ),
];

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildPanel({
  List<DependencyNodeResponse> startupOrder = _testOrder,
  ValueChanged<String>? onServiceTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Row(
        children: [
          StartupOrderPanel(
            startupOrder: startupOrder,
            onServiceTap: onServiceTap,
          ),
        ],
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StartupOrderPanel', () {
    testWidgets('renders numbered list', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPanel());
      await tester.pumpAndSettle();

      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('renders service names', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPanel());
      await tester.pumpAndSettle();

      expect(find.text('PostgreSQL'), findsOneWidget);
      expect(find.text('Redis'), findsOneWidget);
      expect(find.text('CodeOps Server'), findsOneWidget);
    });

    testWidgets('renders header with count', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPanel());
      await tester.pumpAndSettle();

      expect(find.text('Startup Order'), findsOneWidget);
      expect(find.text('3 services'), findsOneWidget);
    });

    testWidgets('tap service calls callback', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? tappedId;
      await tester.pumpWidget(_buildPanel(
        onServiceTap: (id) => tappedId = id,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('PostgreSQL'));
      expect(tappedId, 'svc-1');
    });
  });
}
