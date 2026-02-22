// Tests for Registry response model classes.
//
// Verifies fromJson with all fields, fromJson with null optionals,
// and toJson round-trip for key models.
import 'package:flutter_test/flutter_test.dart';
import 'package:codeops/models/registry_models.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // ServiceRegistrationResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('ServiceRegistrationResponse', () {
    final fullJson = {
      'id': 'svc-1',
      'teamId': 'team-1',
      'name': 'CodeOps Server',
      'slug': 'codeops-server',
      'serviceType': 'SPRING_BOOT_API',
      'description': 'Main API server',
      'repoUrl': 'https://github.com/org/repo',
      'repoFullName': 'org/repo',
      'defaultBranch': 'main',
      'techStack': 'Java 25, Spring Boot 3.3',
      'status': 'ACTIVE',
      'healthCheckUrl': 'http://localhost:8090/actuator/health',
      'healthCheckIntervalSeconds': 30,
      'lastHealthStatus': 'UP',
      'lastHealthCheckAt': '2026-02-22T10:00:00.000Z',
      'environmentsJson': '{"local":true}',
      'metadataJson': '{"version":"1.0"}',
      'createdByUserId': 'user-1',
      'portCount': 3,
      'dependencyCount': 5,
      'solutionCount': 2,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-02-22T10:00:00.000Z',
    };

    test('fromJson with all fields', () {
      final m = ServiceRegistrationResponse.fromJson(fullJson);
      expect(m.id, 'svc-1');
      expect(m.teamId, 'team-1');
      expect(m.name, 'CodeOps Server');
      expect(m.slug, 'codeops-server');
      expect(m.serviceType.toJson(), 'SPRING_BOOT_API');
      expect(m.status.toJson(), 'ACTIVE');
      expect(m.description, 'Main API server');
      expect(m.portCount, 3);
      expect(m.dependencyCount, 5);
    });

    test('fromJson with null optionals', () {
      final json = {
        'id': 'svc-1',
        'teamId': 'team-1',
        'name': 'Test',
        'slug': 'test',
        'serviceType': 'FLUTTER_DESKTOP',
        'status': 'INACTIVE',
      };
      final m = ServiceRegistrationResponse.fromJson(json);
      expect(m.description, isNull);
      expect(m.repoUrl, isNull);
      expect(m.healthCheckUrl, isNull);
      expect(m.portCount, isNull);
    });

    test('toJson round-trip', () {
      final m = ServiceRegistrationResponse.fromJson(fullJson);
      final json = m.toJson();
      final restored = ServiceRegistrationResponse.fromJson(json);
      expect(restored.id, m.id);
      expect(restored.name, m.name);
      expect(restored.serviceType, m.serviceType);
      expect(restored.status, m.status);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SolutionResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('SolutionResponse', () {
    final fullJson = {
      'id': 'sol-1',
      'teamId': 'team-1',
      'name': 'CodeOps Platform',
      'slug': 'codeops-platform',
      'description': 'Core platform',
      'category': 'PLATFORM',
      'status': 'ACTIVE',
      'iconName': 'terminal',
      'colorHex': '#4CAF50',
      'ownerUserId': 'user-1',
      'repositoryUrl': 'https://github.com/org/platform',
      'documentationUrl': 'https://docs.example.com',
      'metadataJson': '{}',
      'memberCount': 5,
      'createdByUserId': 'user-1',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-02-22T10:00:00.000Z',
    };

    test('fromJson with all fields', () {
      final m = SolutionResponse.fromJson(fullJson);
      expect(m.id, 'sol-1');
      expect(m.name, 'CodeOps Platform');
      expect(m.category.toJson(), 'PLATFORM');
      expect(m.status.toJson(), 'ACTIVE');
      expect(m.memberCount, 5);
      expect(m.colorHex, '#4CAF50');
    });

    test('fromJson with null optionals', () {
      final json = {
        'id': 'sol-1',
        'teamId': 'team-1',
        'name': 'Test',
        'slug': 'test',
        'category': 'APPLICATION',
        'status': 'IN_DEVELOPMENT',
      };
      final m = SolutionResponse.fromJson(json);
      expect(m.description, isNull);
      expect(m.iconName, isNull);
      expect(m.memberCount, isNull);
    });

    test('toJson round-trip', () {
      final m = SolutionResponse.fromJson(fullJson);
      final json = m.toJson();
      final restored = SolutionResponse.fromJson(json);
      expect(restored.id, m.id);
      expect(restored.name, m.name);
      expect(restored.category, m.category);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // PortAllocationResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('PortAllocationResponse', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'port-1',
        'serviceId': 'svc-1',
        'serviceName': 'CodeOps Server',
        'teamId': 'team-1',
        'portNumber': 8090,
        'portType': 'HTTP_API',
        'protocol': 'TCP',
        'environment': 'local',
        'description': 'Main HTTP',
        'allocatedByUserId': 'user-1',
        'createdAt': '2026-01-01T00:00:00.000Z',
      };
      final m = PortAllocationResponse.fromJson(json);
      expect(m.id, 'port-1');
      expect(m.portNumber, 8090);
      expect(m.portType.toJson(), 'HTTP_API');
      expect(m.environment, 'local');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ServiceDependencyResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('ServiceDependencyResponse', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'dep-1',
        'sourceServiceId': 'svc-1',
        'sourceServiceName': 'API',
        'targetServiceId': 'svc-2',
        'targetServiceName': 'DB',
        'dependencyType': 'HTTP_REST',
        'description': 'REST call',
        'isRequired': true,
        'targetEndpoint': '/api/v1/data',
        'createdAt': '2026-01-01T00:00:00.000Z',
      };
      final m = ServiceDependencyResponse.fromJson(json);
      expect(m.id, 'dep-1');
      expect(m.dependencyType.toJson(), 'HTTP_REST');
      expect(m.isRequired, true);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // DependencyGraphResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('DependencyGraphResponse', () {
    test('fromJson with empty graph', () {
      final json = {
        'teamId': 'team-1',
        'nodes': <dynamic>[],
        'edges': <dynamic>[],
      };
      final m = DependencyGraphResponse.fromJson(json);
      expect(m.teamId, 'team-1');
      expect(m.nodes, isEmpty);
      expect(m.edges, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ConfigTemplateResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('ConfigTemplateResponse', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'cfg-1',
        'serviceId': 'svc-1',
        'serviceName': 'CodeOps Server',
        'templateType': 'DOCKER_COMPOSE',
        'environment': 'local',
        'contentText': 'version: "3.8"',
        'isAutoGenerated': true,
        'generatedFrom': 'registry',
        'version': 1,
        'createdAt': '2026-02-22T10:00:00.000Z',
        'updatedAt': '2026-02-22T10:00:00.000Z',
      };
      final m = ConfigTemplateResponse.fromJson(json);
      expect(m.id, 'cfg-1');
      expect(m.templateType.toJson(), 'DOCKER_COMPOSE');
      expect(m.contentText, 'version: "3.8"');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // InfraResourceResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('InfraResourceResponse', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'infra-1',
        'teamId': 'team-1',
        'serviceId': 'svc-1',
        'serviceName': 'CodeOps Server',
        'resourceType': 'S3_BUCKET',
        'resourceName': 'codeops-artifacts',
        'environment': 'production',
        'region': 'us-east-1',
        'arnOrUrl': 'arn:aws:s3:::codeops-artifacts',
        'metadataJson': '{}',
        'description': 'Artifact bucket',
        'createdByUserId': 'user-1',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-02-22T10:00:00.000Z',
      };
      final m = InfraResourceResponse.fromJson(json);
      expect(m.id, 'infra-1');
      expect(m.resourceType.toJson(), 'S3_BUCKET');
      expect(m.resourceName, 'codeops-artifacts');
      expect(m.region, 'us-east-1');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TopologyStatsResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('TopologyStatsResponse', () {
    test('fromJson with all fields', () {
      final json = {
        'totalServices': 10,
        'totalSolutions': 3,
        'totalDependencies': 25,
        'servicesWithNoDependencies': 2,
        'servicesWithNoConsumers': 3,
        'orphanedServices': 1,
        'maxDependencyDepth': 4,
      };
      final m = TopologyStatsResponse.fromJson(json);
      expect(m.totalServices, 10);
      expect(m.totalSolutions, 3);
      expect(m.totalDependencies, 25);
      expect(m.orphanedServices, 1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TeamHealthSummaryResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('TeamHealthSummaryResponse', () {
    test('fromJson with all fields', () {
      final json = {
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
      final m = TeamHealthSummaryResponse.fromJson(json);
      expect(m.totalServices, 10);
      expect(m.servicesUp, 7);
      expect(m.servicesDegraded, 2);
      expect(m.servicesDown, 1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WorkstationProfileResponse
  // ─────────────────────────────────────────────────────────────────────────

  group('WorkstationProfileResponse', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'ws-1',
        'teamId': 'team-1',
        'name': 'Default Workstation',
        'description': 'Default dev setup',
        'isDefault': true,
        'solutionId': 'sol-1',
        'services': <dynamic>[],
        'createdByUserId': 'user-1',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-02-22T10:00:00.000Z',
      };
      final m = WorkstationProfileResponse.fromJson(json);
      expect(m.id, 'ws-1');
      expect(m.name, 'Default Workstation');
      expect(m.isDefault, true);
    });
  });
}
