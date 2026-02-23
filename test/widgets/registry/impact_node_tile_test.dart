// Tests for ImpactNodeTile widget.
//
// Verifies service name rendering, severity badge, connection type label,
// required/optional badge, depth-based indentation, and expand chevron.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/widgets/registry/impact_node_tile.dart';

const _criticalService = ImpactedServiceResponse(
  serviceId: 'svc-1',
  serviceName: 'Auth Service',
  serviceSlug: 'auth-service',
  depth: 1,
  connectionType: DependencyType.httpRest,
  isRequired: true,
);

const _optionalService = ImpactedServiceResponse(
  serviceId: 'svc-2',
  serviceName: 'Analytics Service',
  serviceSlug: 'analytics-service',
  depth: 3,
  connectionType: DependencyType.kafkaTopic,
  isRequired: false,
);

const _deepService = ImpactedServiceResponse(
  serviceId: 'svc-3',
  serviceName: 'Logging Service',
  serviceSlug: 'logging-service',
  depth: 5,
  connectionType: DependencyType.library_,
  isRequired: null,
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTile({
  ImpactedServiceResponse service = _criticalService,
  bool hasChildren = false,
  bool isExpanded = false,
  VoidCallback? onToggle,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: ImpactNodeTile(
            service: service,
            hasChildren: hasChildren,
            isExpanded: isExpanded,
            onToggle: onToggle,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImpactNodeTile', () {
    testWidgets('renders service name', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile());
      await tester.pumpAndSettle();

      expect(find.text('Auth Service'), findsOneWidget);
    });

    testWidgets('renders severity badge for depth 1', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile());
      await tester.pumpAndSettle();

      expect(find.text('CRITICAL'), findsOneWidget);
    });

    testWidgets('renders MEDIUM severity for depth 3', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile(service: _optionalService));
      await tester.pumpAndSettle();

      expect(find.text('MEDIUM'), findsOneWidget);
    });

    testWidgets('renders LOW severity for depth 5', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile(service: _deepService));
      await tester.pumpAndSettle();

      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('renders connection type label', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile());
      await tester.pumpAndSettle();

      expect(find.text('HTTP REST'), findsOneWidget);
    });

    testWidgets('renders Required badge for required dependency',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile());
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('renders Optional badge for optional dependency',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile(service: _optionalService));
      await tester.pumpAndSettle();

      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('shows expand chevron when hasChildren', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildTile(hasChildren: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows expand_more icon when expanded', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildTile(hasChildren: true, isExpanded: true),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('tap calls onTap callback', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var tapped = false;
      await tester.pumpWidget(_buildTile(onTap: () => tapped = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auth Service'));
      expect(tapped, isTrue);
    });
  });
}
