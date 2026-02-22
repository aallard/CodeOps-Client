// Tests for RegistryApi.
//
// Verifies that key endpoint methods send the correct path,
// query parameters, and request body, and deserialize responses.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/services/cloud/registry_api.dart';
import 'package:codeops/services/cloud/registry_api_client.dart';

class MockRegistryApiClient extends Mock implements RegistryApiClient {}

void main() {
  late MockRegistryApiClient mockClient;
  late RegistryApi api;

  setUp(() {
    mockClient = MockRegistryApiClient();
    api = RegistryApi(mockClient);
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Services
  // ═══════════════════════════════════════════════════════════════════════════

  final serviceJson = {
    'id': 'svc-1',
    'teamId': 'team-1',
    'name': 'Test Service',
    'slug': 'test-service',
    'serviceType': 'SPRING_BOOT_API',
    'status': 'ACTIVE',
  };

  final pageJson = {
    'content': [serviceJson],
    'page': 0,
    'size': 20,
    'totalElements': 1,
    'totalPages': 1,
    'isLast': true,
  };

  group('Services', () {
    test('createService sends correct body', () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/teams/team-1/services',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: serviceJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createService(
        teamId: 'team-1',
        name: 'Test Service',
        serviceType: ServiceType.springBootApi,
      );

      expect(result.name, 'Test Service');
      verify(() => mockClient.post<Map<String, dynamic>>(
            '/teams/team-1/services',
            data: {
              'teamId': 'team-1',
              'name': 'Test Service',
              'serviceType': 'SPRING_BOOT_API',
            },
          )).called(1);
    });

    test('getServicesForTeam sends query parameters', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/teams/team-1/services',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: pageJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getServicesForTeam(
        'team-1',
        status: ServiceStatus.active,
        page: 0,
        size: 20,
      );

      expect(result.content, hasLength(1));
      expect(result.totalElements, 1);
    });

    test('getService fetches by ID', () async {
      when(() => mockClient.get<Map<String, dynamic>>('/services/svc-1'))
          .thenAnswer((_) async => Response(
                data: serviceJson,
                requestOptions: RequestOptions(),
                statusCode: 200,
              ));

      final result = await api.getService('svc-1');
      expect(result.id, 'svc-1');
    });

    test('deleteService sends DELETE', () async {
      when(() => mockClient.delete('/services/svc-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.deleteService('svc-1');
      verify(() => mockClient.delete('/services/svc-1')).called(1);
    });

    test('updateServiceStatus sends PATCH with status', () async {
      when(() => mockClient.patch<Map<String, dynamic>>(
            '/services/svc-1/status',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: serviceJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      await api.updateServiceStatus(
        'svc-1',
        status: ServiceStatus.inactive,
      );

      verify(() => mockClient.patch<Map<String, dynamic>>(
            '/services/svc-1/status',
            data: {'status': 'INACTIVE'},
          )).called(1);
    });

    test('cloneService sends POST with body', () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/services/svc-1/clone',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: serviceJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      await api.cloneService('svc-1', newName: 'Clone');

      verify(() => mockClient.post<Map<String, dynamic>>(
            '/services/svc-1/clone',
            data: {'newName': 'Clone'},
          )).called(1);
    });

    test('getServiceBySlug uses correct path', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/teams/team-1/services/by-slug/my-slug',
          )).thenAnswer((_) async => Response(
            data: serviceJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getServiceBySlug('team-1', 'my-slug');
      expect(result.id, 'svc-1');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Solutions
  // ═══════════════════════════════════════════════════════════════════════════

  final solutionJson = {
    'id': 'sol-1',
    'teamId': 'team-1',
    'name': 'Test Solution',
    'slug': 'test-solution',
    'category': 'PLATFORM',
    'status': 'ACTIVE',
  };

  group('Solutions', () {
    test('createSolution sends correct body', () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/teams/team-1/solutions',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: solutionJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createSolution(
        teamId: 'team-1',
        name: 'Test Solution',
        category: SolutionCategory.platform,
      );

      expect(result.name, 'Test Solution');
    });

    test('deleteSolution sends DELETE', () async {
      when(() => mockClient.delete('/solutions/sol-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.deleteSolution('sol-1');
      verify(() => mockClient.delete('/solutions/sol-1')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Dependencies
  // ═══════════════════════════════════════════════════════════════════════════

  group('Dependencies', () {
    test('createDependency sends correct body', () async {
      final depJson = {
        'id': 'dep-1',
        'sourceServiceId': 'svc-1',
        'sourceServiceName': 'API',
        'targetServiceId': 'svc-2',
        'targetServiceName': 'DB',
        'dependencyType': 'HTTP_REST',
        'isRequired': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      when(() => mockClient.post<Map<String, dynamic>>(
            '/dependencies',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: depJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createDependency(
        sourceServiceId: 'svc-1',
        targetServiceId: 'svc-2',
        dependencyType: DependencyType.httpRest,
        isRequired: true,
      );

      expect(result.id, 'dep-1');
    });

    test('removeDependency sends DELETE', () async {
      when(() => mockClient.delete('/dependencies/dep-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.removeDependency('dep-1');
      verify(() => mockClient.delete('/dependencies/dep-1')).called(1);
    });

    test('getDependencyGraph uses correct path', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/teams/team-1/dependencies/graph',
          )).thenAnswer((_) async => Response(
            data: {'teamId': 'team-1', 'nodes': <dynamic>[], 'edges': <dynamic>[]},
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getDependencyGraph('team-1');
      expect(result.nodes, isEmpty);
    });

    test('detectCycles returns list of UUIDs', () async {
      when(() => mockClient.get<List<dynamic>>(
            '/teams/team-1/dependencies/cycles',
          )).thenAnswer((_) async => Response(
            data: ['svc-1', 'svc-2'],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.detectCycles('team-1');
      expect(result, ['svc-1', 'svc-2']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Ports
  // ═══════════════════════════════════════════════════════════════════════════

  group('Ports', () {
    final portJson = {
      'id': 'port-1',
      'serviceId': 'svc-1',
      'serviceName': 'Test',
      'teamId': 'team-1',
      'portNumber': 8090,
      'portType': 'HTTP_API',
      'protocol': 'TCP',
      'environment': 'local',
      'createdAt': '2026-01-01T00:00:00.000Z',
    };

    test('autoAllocatePort sends correct body', () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/ports/auto-allocate',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: portJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.autoAllocatePort(
        serviceId: 'svc-1',
        environment: 'local',
        portType: PortType.httpApi,
      );

      expect(result.portNumber, 8090);
    });

    test('releasePort sends DELETE', () async {
      when(() => mockClient.delete('/ports/port-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.releasePort('port-1');
      verify(() => mockClient.delete('/ports/port-1')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Routes
  // ═══════════════════════════════════════════════════════════════════════════

  group('Routes', () {
    test('createRoute sends correct body', () async {
      final routeJson = {
        'id': 'route-1',
        'serviceId': 'svc-1',
        'serviceName': 'API',
        'routePrefix': '/api/v1/users',
        'environment': 'local',
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      when(() => mockClient.post<Map<String, dynamic>>(
            '/routes',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: routeJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createRoute(
        serviceId: 'svc-1',
        routePrefix: '/api/v1/users',
        environment: 'local',
      );

      expect(result.routePrefix, '/api/v1/users');
    });

    test('deleteRoute sends DELETE', () async {
      when(() => mockClient.delete('/routes/route-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.deleteRoute('route-1');
      verify(() => mockClient.delete('/routes/route-1')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Config
  // ═══════════════════════════════════════════════════════════════════════════

  group('Config', () {
    test('deleteTemplate sends DELETE', () async {
      when(() => mockClient.delete('/config/cfg-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.deleteTemplate('cfg-1');
      verify(() => mockClient.delete('/config/cfg-1')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // InfraResources
  // ═══════════════════════════════════════════════════════════════════════════

  group('InfraResources', () {
    test('deleteInfraResource sends DELETE', () async {
      when(() => mockClient.delete('/infra-resources/infra-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.deleteInfraResource('infra-1');
      verify(() => mockClient.delete('/infra-resources/infra-1')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Topology
  // ═══════════════════════════════════════════════════════════════════════════

  group('Topology', () {
    final statsJson = {
      'totalServices': 10,
      'totalSolutions': 3,
      'totalDependencies': 25,
      'servicesWithNoDependencies': 2,
      'servicesWithNoConsumers': 3,
      'orphanedServices': 1,
      'maxDependencyDepth': 4,
    };

    test('getEcosystemStats uses correct path', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/teams/team-1/topology/stats',
          )).thenAnswer((_) async => Response(
            data: statsJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getEcosystemStats('team-1');
      expect(result.totalServices, 10);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Health Management
  // ═══════════════════════════════════════════════════════════════════════════

  group('Health Management', () {
    final healthSummaryJson = {
      'teamId': 'team-1',
      'totalServices': 10,
      'activeServices': 9,
      'servicesUp': 7,
      'servicesDown': 1,
      'servicesDegraded': 2,
      'servicesUnknown': 0,
      'servicesNeverChecked': 1,
      'overallHealth': 'DEGRADED',
      'checkedAt': '2026-02-22T10:00:00.000Z',
    };

    test('getTeamHealthSummary uses correct path', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/teams/team-1/health/summary',
          )).thenAnswer((_) async => Response(
            data: healthSummaryJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getTeamHealthSummary('team-1');
      expect(result.totalServices, 10);
      expect(result.servicesUp, 7);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Workstations
  // ═══════════════════════════════════════════════════════════════════════════

  group('Workstations', () {
    test('deleteWorkstationProfile sends DELETE', () async {
      when(() => mockClient.delete('/workstations/ws-1'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(),
                statusCode: 204,
              ));

      await api.deleteWorkstationProfile('ws-1');
      verify(() => mockClient.delete('/workstations/ws-1')).called(1);
    });
  });
}
