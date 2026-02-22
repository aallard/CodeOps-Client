// Tests for all 11 Registry enums.
//
// Verifies toJson(), fromJson() round-trips, displayName, converter,
// and invalid input handling for every enum value.
import 'package:flutter_test/flutter_test.dart';
import 'package:codeops/models/registry_enums.dart';

void main() {
  group('ServiceType', () {
    test('toJson returns correct server strings', () {
      expect(ServiceType.springBootApi.toJson(), 'SPRING_BOOT_API');
      expect(ServiceType.flutterDesktop.toJson(), 'FLUTTER_DESKTOP');
      expect(ServiceType.library_.toJson(), 'LIBRARY');
      expect(ServiceType.mcpServer.toJson(), 'MCP_SERVER');
      expect(ServiceType.other.toJson(), 'OTHER');
    });

    test('fromJson round-trips all values', () {
      for (final v in ServiceType.values) {
        expect(ServiceType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(ServiceType.springBootApi.displayName, 'Spring Boot API');
      expect(ServiceType.library_.displayName, 'Library');
      expect(ServiceType.mcpServer.displayName, 'MCP Server');
    });

    test('fromJson throws on invalid input', () {
      expect(() => ServiceType.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = ServiceTypeConverter();
      for (final v in ServiceType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });

    test('has 20 values', () {
      expect(ServiceType.values, hasLength(20));
    });
  });

  group('ServiceStatus', () {
    test('toJson returns correct server strings', () {
      expect(ServiceStatus.active.toJson(), 'ACTIVE');
      expect(ServiceStatus.inactive.toJson(), 'INACTIVE');
      expect(ServiceStatus.deprecated.toJson(), 'DEPRECATED');
      expect(ServiceStatus.archived.toJson(), 'ARCHIVED');
    });

    test('fromJson round-trips all values', () {
      for (final v in ServiceStatus.values) {
        expect(ServiceStatus.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(ServiceStatus.active.displayName, 'Active');
      expect(ServiceStatus.deprecated.displayName, 'Deprecated');
    });

    test('fromJson throws on invalid input', () {
      expect(() => ServiceStatus.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = ServiceStatusConverter();
      for (final v in ServiceStatus.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  group('HealthStatus', () {
    test('toJson returns correct server strings', () {
      expect(HealthStatus.up.toJson(), 'UP');
      expect(HealthStatus.down.toJson(), 'DOWN');
      expect(HealthStatus.degraded.toJson(), 'DEGRADED');
      expect(HealthStatus.unknown.toJson(), 'UNKNOWN');
    });

    test('fromJson round-trips all values', () {
      for (final v in HealthStatus.values) {
        expect(HealthStatus.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(HealthStatus.up.displayName, 'Up');
      expect(HealthStatus.degraded.displayName, 'Degraded');
    });

    test('fromJson throws on invalid input', () {
      expect(() => HealthStatus.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = HealthStatusConverter();
      for (final v in HealthStatus.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  group('SolutionCategory', () {
    test('toJson returns correct server strings', () {
      expect(SolutionCategory.platform.toJson(), 'PLATFORM');
      expect(SolutionCategory.librarySuite.toJson(), 'LIBRARY_SUITE');
      expect(SolutionCategory.infrastructure.toJson(), 'INFRASTRUCTURE');
    });

    test('fromJson round-trips all values', () {
      for (final v in SolutionCategory.values) {
        expect(SolutionCategory.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(SolutionCategory.platform.displayName, 'Platform');
      expect(SolutionCategory.librarySuite.displayName, 'Library Suite');
    });

    test('fromJson throws on invalid input', () {
      expect(() => SolutionCategory.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = SolutionCategoryConverter();
      for (final v in SolutionCategory.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  group('SolutionStatus', () {
    test('toJson returns correct server strings', () {
      expect(SolutionStatus.active.toJson(), 'ACTIVE');
      expect(SolutionStatus.inDevelopment.toJson(), 'IN_DEVELOPMENT');
      expect(SolutionStatus.deprecated.toJson(), 'DEPRECATED');
      expect(SolutionStatus.archived.toJson(), 'ARCHIVED');
    });

    test('fromJson round-trips all values', () {
      for (final v in SolutionStatus.values) {
        expect(SolutionStatus.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(SolutionStatus.inDevelopment.displayName, 'In Development');
    });

    test('fromJson throws on invalid input', () {
      expect(() => SolutionStatus.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = SolutionStatusConverter();
      for (final v in SolutionStatus.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  group('SolutionMemberRole', () {
    test('toJson returns correct server strings', () {
      expect(SolutionMemberRole.core.toJson(), 'CORE');
      expect(SolutionMemberRole.supporting.toJson(), 'SUPPORTING');
      expect(SolutionMemberRole.infrastructure.toJson(), 'INFRASTRUCTURE');
      expect(
          SolutionMemberRole.externalDependency.toJson(), 'EXTERNAL_DEPENDENCY');
    });

    test('fromJson round-trips all values', () {
      for (final v in SolutionMemberRole.values) {
        expect(SolutionMemberRole.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(SolutionMemberRole.externalDependency.displayName,
          'External Dependency');
    });

    test('fromJson throws on invalid input', () {
      expect(
          () => SolutionMemberRole.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = SolutionMemberRoleConverter();
      for (final v in SolutionMemberRole.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  group('PortType', () {
    test('toJson returns correct server strings', () {
      expect(PortType.httpApi.toJson(), 'HTTP_API');
      expect(PortType.frontendDev.toJson(), 'FRONTEND_DEV');
      expect(PortType.database.toJson(), 'DATABASE');
      expect(PortType.kafkaInternal.toJson(), 'KAFKA_INTERNAL');
      expect(PortType.grpc.toJson(), 'GRPC');
    });

    test('fromJson round-trips all values', () {
      for (final v in PortType.values) {
        expect(PortType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(PortType.httpApi.displayName, 'HTTP API');
      expect(PortType.grpc.displayName, 'gRPC');
      expect(PortType.websocket.displayName, 'WebSocket');
    });

    test('fromJson throws on invalid input', () {
      expect(() => PortType.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = PortTypeConverter();
      for (final v in PortType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });

    test('has 12 values', () {
      expect(PortType.values, hasLength(12));
    });
  });

  group('DependencyType', () {
    test('toJson returns correct server strings', () {
      expect(DependencyType.httpRest.toJson(), 'HTTP_REST');
      expect(DependencyType.grpc.toJson(), 'GRPC');
      expect(DependencyType.kafkaTopic.toJson(), 'KAFKA_TOPIC');
      expect(DependencyType.databaseShared.toJson(), 'DATABASE_SHARED');
      expect(DependencyType.library_.toJson(), 'LIBRARY');
    });

    test('fromJson round-trips all values', () {
      for (final v in DependencyType.values) {
        expect(DependencyType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(DependencyType.httpRest.displayName, 'HTTP REST');
      expect(DependencyType.library_.displayName, 'Library');
    });

    test('fromJson throws on invalid input', () {
      expect(() => DependencyType.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = DependencyTypeConverter();
      for (final v in DependencyType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });

    test('has 10 values', () {
      expect(DependencyType.values, hasLength(10));
    });
  });

  group('ConfigTemplateType', () {
    test('toJson returns correct server strings', () {
      expect(ConfigTemplateType.dockerCompose.toJson(), 'DOCKER_COMPOSE');
      expect(ConfigTemplateType.applicationYml.toJson(), 'APPLICATION_YML');
      expect(ConfigTemplateType.claudeCodeHeader.toJson(), 'CLAUDE_CODE_HEADER');
      expect(ConfigTemplateType.dockerfile.toJson(), 'DOCKERFILE');
    });

    test('fromJson round-trips all values', () {
      for (final v in ConfigTemplateType.values) {
        expect(ConfigTemplateType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(ConfigTemplateType.dockerCompose.displayName, 'Docker Compose');
      expect(ConfigTemplateType.applicationYml.displayName, 'application.yml');
      expect(ConfigTemplateType.envFile.displayName, '.env File');
    });

    test('fromJson throws on invalid input', () {
      expect(
          () => ConfigTemplateType.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = ConfigTemplateTypeConverter();
      for (final v in ConfigTemplateType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });

    test('has 12 values', () {
      expect(ConfigTemplateType.values, hasLength(12));
    });
  });

  group('InfraResourceType', () {
    test('toJson returns correct server strings', () {
      expect(InfraResourceType.s3Bucket.toJson(), 'S3_BUCKET');
      expect(InfraResourceType.sqsQueue.toJson(), 'SQS_QUEUE');
      expect(InfraResourceType.rdsInstance.toJson(), 'RDS_INSTANCE');
      expect(InfraResourceType.dockerNetwork.toJson(), 'DOCKER_NETWORK');
      expect(InfraResourceType.lambdaFunction.toJson(), 'LAMBDA_FUNCTION');
    });

    test('fromJson round-trips all values', () {
      for (final v in InfraResourceType.values) {
        expect(InfraResourceType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(InfraResourceType.s3Bucket.displayName, 'S3 Bucket');
      expect(InfraResourceType.cloudwatchLogGroup.displayName,
          'CloudWatch Log Group');
      expect(InfraResourceType.dockerNetwork.displayName, 'Docker Network');
    });

    test('fromJson throws on invalid input', () {
      expect(
          () => InfraResourceType.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = InfraResourceTypeConverter();
      for (final v in InfraResourceType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });

    test('has 20 values', () {
      expect(InfraResourceType.values, hasLength(20));
    });
  });

  group('ConfigSource', () {
    test('toJson returns correct server strings', () {
      expect(ConfigSource.autoGenerated.toJson(), 'AUTO_GENERATED');
      expect(ConfigSource.manual.toJson(), 'MANUAL');
      expect(ConfigSource.inherited.toJson(), 'INHERITED');
      expect(ConfigSource.registryDerived.toJson(), 'REGISTRY_DERIVED');
    });

    test('fromJson round-trips all values', () {
      for (final v in ConfigSource.values) {
        expect(ConfigSource.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(ConfigSource.autoGenerated.displayName, 'Auto-Generated');
      expect(ConfigSource.registryDerived.displayName, 'Registry Derived');
    });

    test('fromJson throws on invalid input', () {
      expect(() => ConfigSource.fromJson('INVALID'), throwsArgumentError);
    });

    test('converter round-trips', () {
      const converter = ConfigSourceConverter();
      for (final v in ConfigSource.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });
}
