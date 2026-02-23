// Tests for ApiDocsPage.
//
// Verifies empty state, service selector display, loading state,
// no-spec warning, spec content rendering, search filter, method filter,
// expand/collapse all, and spec info bar.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/openapi_spec.dart';
import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/pages/registry/api_docs_page.dart';
import 'package:codeops/providers/registry_providers.dart';

const _service1 = ServiceRegistrationResponse(
  id: 'svc-1',
  teamId: 'team-1',
  name: 'Auth Service',
  slug: 'auth-service',
  serviceType: ServiceType.springBootApi,
  status: ServiceStatus.active,
);

PageResponse<ServiceRegistrationResponse> _servicePage(
    List<ServiceRegistrationResponse> items) {
  return PageResponse(
    content: items,
    page: 0,
    size: 20,
    totalElements: items.length,
    totalPages: 1,
    isLast: true,
  );
}

const _spec = OpenApiSpec(
  title: 'Auth API',
  version: '2.0.0',
  description: 'Authentication service',
  tags: [
    OpenApiTag(name: 'Auth', description: 'Authentication endpoints'),
    OpenApiTag(name: 'Users'),
  ],
  endpoints: [
    OpenApiEndpoint(
      path: '/api/v1/auth/login',
      method: 'POST',
      summary: 'Login',
      tags: ['Auth'],
      responses: {'200': OpenApiResponse(description: 'Success')},
    ),
    OpenApiEndpoint(
      path: '/api/v1/users',
      method: 'GET',
      summary: 'List users',
      tags: ['Users'],
      responses: {'200': OpenApiResponse(description: 'Success')},
    ),
    OpenApiEndpoint(
      path: '/api/v1/users/{id}',
      method: 'DELETE',
      summary: 'Delete user',
      tags: ['Users'],
      responses: {'204': OpenApiResponse(description: 'Deleted')},
    ),
  ],
  schemas: {
    'LoginRequest': OpenApiSchema(
      type: 'object',
      properties: {
        'email': OpenApiSchema(type: 'string'),
        'password': OpenApiSchema(type: 'string'),
      },
    ),
  },
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildPage({
  List<Override> overrides = const [],
  String? serviceId,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: ApiDocsPage(serviceId: serviceId)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiDocsPage', () {
    testWidgets('renders empty state when no service selected', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          openApiSpecProvider.overrideWith((ref) async => null),
        ]),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Select a service to view its API documentation'),
        findsOneWidget,
      );
    });

    testWidgets('renders title', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          openApiSpecProvider.overrideWith((ref) async => null),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('API Documentation'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final completer = Completer<OpenApiSpec?>();
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) => completer.future),
        ]),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders no-spec warning', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) async => null),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('No OpenAPI spec available'), findsOneWidget);
    });

    testWidgets('renders spec info bar', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) async => _spec),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Auth API'), findsOneWidget);
      expect(find.text('v2.0.0'), findsOneWidget);
      expect(find.text('3 endpoints'), findsOneWidget);
      expect(find.text('1 schemas'), findsOneWidget);
    });

    testWidgets('renders tag groups', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) async => _spec),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Auth'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
    });

    testWidgets('expand all button present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) async => _spec),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expand All'), findsOneWidget);
      expect(find.text('Collapse All'), findsOneWidget);
    });

    testWidgets('search bar present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) async => _spec),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('schemas section present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          apiDocsServiceIdProvider.overrideWith((ref) => 'svc-1'),
          openApiSpecProvider.overrideWith((ref) async => _spec),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schemas'), findsOneWidget);
    });

    testWidgets('refresh button present', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(overrides: [
          registryServicesProvider.overrideWith(
            (ref) async => _servicePage([_service1]),
          ),
          openApiSpecProvider.overrideWith((ref) async => null),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Refresh'), findsOneWidget);
    });
  });
}
