// Tests for ImpactTreeView widget.
//
// Verifies source header, depth group headers, service tiles,
// collapse/expand behavior, empty state, and summary card.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/widgets/registry/impact_tree_view.dart';

const _testAnalysis = ImpactAnalysisResponse(
  sourceServiceId: 'svc-source',
  sourceServiceName: 'CodeOps Server',
  impactedServices: [
    ImpactedServiceResponse(
      serviceId: 'svc-1',
      serviceName: 'Auth Service',
      serviceSlug: 'auth-service',
      depth: 1,
      connectionType: DependencyType.httpRest,
      isRequired: true,
    ),
    ImpactedServiceResponse(
      serviceId: 'svc-2',
      serviceName: 'User Service',
      serviceSlug: 'user-service',
      depth: 1,
      connectionType: DependencyType.grpc,
      isRequired: true,
    ),
    ImpactedServiceResponse(
      serviceId: 'svc-3',
      serviceName: 'Notification Service',
      serviceSlug: 'notification-service',
      depth: 2,
      connectionType: DependencyType.kafkaTopic,
      isRequired: false,
    ),
  ],
  totalAffected: 3,
);

const _emptyAnalysis = ImpactAnalysisResponse(
  sourceServiceId: 'svc-source',
  sourceServiceName: 'Isolated Service',
  impactedServices: [],
  totalAffected: 0,
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildView({
  ImpactAnalysisResponse analysis = _testAnalysis,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 800,
        child: ImpactTreeView(analysis: analysis),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImpactTreeView', () {
    testWidgets('renders source header', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      expect(find.text('CodeOps Server'), findsWidgets);
      expect(find.text('SOURCE'), findsOneWidget);
    });

    testWidgets('renders depth group headers', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      expect(find.textContaining('Depth 1'), findsOneWidget);
      expect(find.textContaining('CRITICAL'), findsWidgets);
      expect(find.textContaining('Depth 2'), findsOneWidget);
      expect(find.textContaining('HIGH'), findsWidgets);
    });

    testWidgets('renders service tiles', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      expect(find.text('Auth Service'), findsOneWidget);
      expect(find.text('User Service'), findsOneWidget);
      expect(find.text('Notification Service'), findsOneWidget);
    });

    testWidgets('renders summary card', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      expect(find.text('Impact Summary'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // total affected
    });

    testWidgets('renders empty state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView(analysis: _emptyAnalysis));
      await tester.pumpAndSettle();

      expect(find.text('No downstream impact'), findsOneWidget);
      expect(
        find.text('This service has no downstream dependencies.'),
        findsOneWidget,
      );
    });

    testWidgets('collapse depth group hides tiles', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      // Both depth 1 services visible
      expect(find.text('Auth Service'), findsOneWidget);
      expect(find.text('User Service'), findsOneWidget);

      // Tap depth 1 header to collapse
      await tester.tap(find.textContaining('Depth 1'));
      await tester.pumpAndSettle();

      // Depth 1 services hidden
      expect(find.text('Auth Service'), findsNothing);
      expect(find.text('User Service'), findsNothing);

      // Depth 2 still visible
      expect(find.text('Notification Service'), findsOneWidget);
    });

    testWidgets('re-expand depth group shows tiles', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildView());
      await tester.pumpAndSettle();

      // Collapse
      await tester.tap(find.textContaining('Depth 1'));
      await tester.pumpAndSettle();
      expect(find.text('Auth Service'), findsNothing);

      // Re-expand
      await tester.tap(find.textContaining('Depth 1'));
      await tester.pumpAndSettle();
      expect(find.text('Auth Service'), findsOneWidget);
    });
  });
}
