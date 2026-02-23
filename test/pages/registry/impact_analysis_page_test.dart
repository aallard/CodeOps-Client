// Tests for ImpactAnalysisPage.
//
// Verifies empty state, loading, error, data states, service selector,
// back button, and summary card rendering.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/pages/registry/impact_analysis_page.dart';
import 'package:codeops/providers/registry_providers.dart';

const _svc1 = ServiceRegistrationResponse(
  id: 'svc-1',
  teamId: 'team-1',
  name: 'CodeOps Server',
  slug: 'codeops-server',
  serviceType: ServiceType.springBootApi,
  status: ServiceStatus.active,
);

const _svc2 = ServiceRegistrationResponse(
  id: 'svc-2',
  teamId: 'team-1',
  name: 'PostgreSQL',
  slug: 'postgresql',
  serviceType: ServiceType.databaseService,
  status: ServiceStatus.active,
);

const _testAnalysis = ImpactAnalysisResponse(
  sourceServiceId: 'svc-1',
  sourceServiceName: 'CodeOps Server',
  impactedServices: [
    ImpactedServiceResponse(
      serviceId: 'svc-2',
      serviceName: 'PostgreSQL',
      serviceSlug: 'postgresql',
      depth: 1,
      connectionType: DependencyType.databaseShared,
      isRequired: true,
    ),
  ],
  totalAffected: 1,
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildPage({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(body: ImpactAnalysisPage()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImpactAnalysisPage', () {
    testWidgets('renders empty state when no service selected',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select a service'), findsOneWidget);
      expect(
        find.text('Choose a source service to analyze its downstream impact.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Impact Analysis title', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Impact Analysis'), findsOneWidget);
      expect(find.text('Source Service:'), findsOneWidget);
    });

    testWidgets('renders loading state when service selected',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => 'svc-1'),
            registryImpactAnalysisProvider.overrideWith(
              (ref, serviceId) =>
                  Completer<ImpactAnalysisResponse>().future,
            ),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => 'svc-1'),
            registryImpactAnalysisProvider.overrideWith(
              (ref, serviceId) => throw Exception('Network error'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to Load Impact Analysis'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders impact tree when data loaded', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => 'svc-1'),
            registryImpactAnalysisProvider.overrideWith(
              (ref, serviceId) async => _testAnalysis,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Source header
      expect(find.text('CodeOps Server'), findsWidgets);
      expect(find.text('SOURCE'), findsOneWidget);
      // Impacted service
      expect(find.text('PostgreSQL'), findsWidgets);
      // Summary card
      expect(find.text('Impact Summary'), findsOneWidget);
    });

    testWidgets('back button is present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back to graph'), findsOneWidget);
    });

    testWidgets('service selector dropdown is present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryServicesProvider.overrideWith(
              (ref) async => PageResponse(
                content: [_svc1, _svc2],
                page: 0,
                size: 20,
                totalElements: 2,
                totalPages: 1,
                isLast: true,
              ),
            ),
            impactServiceIdProvider.overrideWith((ref) => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select a service...'), findsOneWidget);
    });
  });
}
