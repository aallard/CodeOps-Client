// Tests for Fleet model classes.
//
// Verifies const constructors, field assignment, and type identity
// for all 31 Fleet model classes (19 response + 12 request).
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_enums.dart';
import 'package:codeops/models/fleet_models.dart';

void main() {
  // ══════════════════════════════════════════════════════════════
  //  CONTAINER MODELS
  // ══════════════════════════════════════════════════════════════

  group('FleetContainerInstance', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetContainerInstance();
      expect(instance, isA<FleetContainerInstance>());
    });

    test('constructor with populated fields', () {
      final instance = FleetContainerInstance(
        id: 'id-1',
        containerId: 'container-1',
        containerName: 'my-container',
        serviceName: 'my-service',
        imageName: 'nginx',
        imageTag: 'latest',
        status: ContainerStatus.running,
        healthStatus: HealthStatus.healthy,
        restartPolicy: RestartPolicy.always,
        restartCount: 3,
        cpuPercent: 25.5,
        memoryBytes: 1048576,
        memoryLimitBytes: 2097152,
        startedAt: DateTime.utc(2026),
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetContainerInstance>());
      expect(instance.id, 'id-1');
      expect(instance.containerId, 'container-1');
      expect(instance.containerName, 'my-container');
      expect(instance.serviceName, 'my-service');
      expect(instance.imageName, 'nginx');
      expect(instance.imageTag, 'latest');
      expect(instance.status, ContainerStatus.running);
      expect(instance.healthStatus, HealthStatus.healthy);
      expect(instance.restartPolicy, RestartPolicy.always);
      expect(instance.restartCount, 3);
      expect(instance.cpuPercent, 25.5);
      expect(instance.memoryBytes, 1048576);
      expect(instance.memoryLimitBytes, 2097152);
    });
  });

  group('FleetContainerDetail', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetContainerDetail();
      expect(instance, isA<FleetContainerDetail>());
    });

    test('constructor with populated fields', () {
      final instance = FleetContainerDetail(
        id: 'id-1',
        containerId: 'container-1',
        containerName: 'my-container',
        serviceName: 'my-service',
        imageName: 'nginx',
        imageTag: 'latest',
        status: ContainerStatus.running,
        healthStatus: HealthStatus.healthy,
        restartPolicy: RestartPolicy.always,
        restartCount: 3,
        exitCode: 0,
        cpuPercent: 25.5,
        memoryBytes: 1048576,
        memoryLimitBytes: 2097152,
        pid: 1234,
        startedAt: DateTime.utc(2026),
        finishedAt: DateTime.utc(2026),
        serviceProfileId: 'sp-1',
        serviceProfileName: 'Nginx Profile',
        teamId: 'team-1',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetContainerDetail>());
      expect(instance.id, 'id-1');
      expect(instance.status, ContainerStatus.running);
      expect(instance.healthStatus, HealthStatus.healthy);
      expect(instance.restartPolicy, RestartPolicy.always);
      expect(instance.exitCode, 0);
      expect(instance.pid, 1234);
      expect(instance.serviceProfileId, 'sp-1');
      expect(instance.teamId, 'team-1');
    });
  });

  group('FleetContainerHealthCheck', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetContainerHealthCheck();
      expect(instance, isA<FleetContainerHealthCheck>());
    });

    test('constructor with populated fields', () {
      final instance = FleetContainerHealthCheck(
        id: 'hc-1',
        status: HealthStatus.healthy,
        output: 'OK',
        exitCode: 0,
        durationMs: 150,
        containerId: 'container-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetContainerHealthCheck>());
      expect(instance.id, 'hc-1');
      expect(instance.status, HealthStatus.healthy);
      expect(instance.output, 'OK');
      expect(instance.exitCode, 0);
      expect(instance.durationMs, 150);
      expect(instance.containerId, 'container-1');
    });
  });

  group('FleetContainerLog', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetContainerLog();
      expect(instance, isA<FleetContainerLog>());
    });

    test('constructor with populated fields', () {
      final instance = FleetContainerLog(
        id: 'log-1',
        stream: 'stdout',
        content: 'Server started on port 8080',
        timestamp: DateTime.utc(2026),
        containerId: 'container-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetContainerLog>());
      expect(instance.id, 'log-1');
      expect(instance.stream, 'stdout');
      expect(instance.content, 'Server started on port 8080');
      expect(instance.containerId, 'container-1');
    });
  });

  group('FleetContainerStats', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetContainerStats();
      expect(instance, isA<FleetContainerStats>());
    });

    test('constructor with populated fields', () {
      final instance = FleetContainerStats(
        containerId: 'container-1',
        containerName: 'my-container',
        cpuPercent: 55.3,
        memoryUsageBytes: 2097152,
        memoryLimitBytes: 4194304,
        networkRxBytes: 1024,
        networkTxBytes: 2048,
        blockReadBytes: 4096,
        blockWriteBytes: 8192,
        pids: 10,
        timestamp: DateTime.utc(2026),
      );
      expect(instance, isA<FleetContainerStats>());
      expect(instance.containerId, 'container-1');
      expect(instance.cpuPercent, 55.3);
      expect(instance.memoryUsageBytes, 2097152);
      expect(instance.networkRxBytes, 1024);
      expect(instance.pids, 10);
    });
  });

  group('FleetHealthSummary', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetHealthSummary();
      expect(instance, isA<FleetHealthSummary>());
    });

    test('constructor with populated fields', () {
      final instance = FleetHealthSummary(
        totalContainers: 10,
        runningContainers: 8,
        stoppedContainers: 1,
        unhealthyContainers: 1,
        restartingContainers: 0,
        totalCpuPercent: 45.0,
        totalMemoryBytes: 8388608,
        totalMemoryLimitBytes: 16777216,
        timestamp: DateTime.utc(2026),
      );
      expect(instance, isA<FleetHealthSummary>());
      expect(instance.totalContainers, 10);
      expect(instance.runningContainers, 8);
      expect(instance.stoppedContainers, 1);
      expect(instance.unhealthyContainers, 1);
      expect(instance.totalCpuPercent, 45.0);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  CONTAINER REQUEST DTOS
  // ══════════════════════════════════════════════════════════════

  group('StartContainerRequest', () {
    test('const constructor with only required fields', () {
      const instance = StartContainerRequest(
        serviceProfileId: 'sp-1',
      );
      expect(instance, isA<StartContainerRequest>());
      expect(instance.serviceProfileId, 'sp-1');
    });

    test('const constructor with all fields populated', () {
      const instance = StartContainerRequest(
        serviceProfileId: 'sp-1',
        containerNameOverride: 'custom-name',
        imageTagOverride: 'v2.0',
        envVarOverrides: {'KEY': 'value'},
        restartPolicyOverride: RestartPolicy.onFailure,
      );
      expect(instance, isA<StartContainerRequest>());
      expect(instance.serviceProfileId, 'sp-1');
      expect(instance.containerNameOverride, 'custom-name');
      expect(instance.imageTagOverride, 'v2.0');
      expect(instance.envVarOverrides, {'KEY': 'value'});
      expect(instance.restartPolicyOverride, RestartPolicy.onFailure);
    });
  });

  group('ContainerExecRequest', () {
    test('const constructor with only required fields', () {
      const instance = ContainerExecRequest(command: 'ls -la');
      expect(instance, isA<ContainerExecRequest>());
      expect(instance.command, 'ls -la');
    });

    test('const constructor with all fields populated', () {
      const instance = ContainerExecRequest(
        command: 'ls -la',
        attachStdout: true,
        attachStderr: false,
      );
      expect(instance, isA<ContainerExecRequest>());
      expect(instance.command, 'ls -la');
      expect(instance.attachStdout, true);
      expect(instance.attachStderr, false);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  SERVICE PROFILE MODELS
  // ══════════════════════════════════════════════════════════════

  group('FleetServiceProfile', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetServiceProfile();
      expect(instance, isA<FleetServiceProfile>());
    });

    test('constructor with populated fields', () {
      final instance = FleetServiceProfile(
        id: 'sp-1',
        serviceName: 'nginx',
        displayName: 'Nginx Web Server',
        imageName: 'nginx',
        imageTag: 'latest',
        restartPolicy: RestartPolicy.always,
        isAutoGenerated: false,
        isEnabled: true,
        startOrder: 1,
        serviceRegistrationId: 'sr-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetServiceProfile>());
      expect(instance.id, 'sp-1');
      expect(instance.serviceName, 'nginx');
      expect(instance.restartPolicy, RestartPolicy.always);
      expect(instance.isAutoGenerated, false);
      expect(instance.isEnabled, true);
    });
  });

  group('FleetServiceProfileDetail', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetServiceProfileDetail();
      expect(instance, isA<FleetServiceProfileDetail>());
    });

    test('constructor with populated fields', () {
      final instance = FleetServiceProfileDetail(
        id: 'sp-1',
        serviceName: 'nginx',
        displayName: 'Nginx Web Server',
        description: 'A reverse proxy',
        imageName: 'nginx',
        imageTag: 'alpine',
        command: 'nginx -g daemon off;',
        workingDir: '/usr/share/nginx',
        envVarsJson: '{"PORT":"80"}',
        portsJson: '["80:80"]',
        healthCheckCommand: 'curl -f http://localhost/',
        healthCheckIntervalSeconds: 30,
        healthCheckTimeoutSeconds: 10,
        healthCheckRetries: 3,
        restartPolicy: RestartPolicy.unlessStopped,
        memoryLimitMb: 512,
        cpuLimit: 1.0,
        isAutoGenerated: false,
        isEnabled: true,
        startOrder: 1,
        serviceRegistrationId: 'sr-1',
        teamId: 'team-1',
        volumes: const [],
        networks: const [],
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetServiceProfileDetail>());
      expect(instance.restartPolicy, RestartPolicy.unlessStopped);
      expect(instance.volumes, isEmpty);
      expect(instance.networks, isEmpty);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  SERVICE PROFILE REQUEST DTOS
  // ══════════════════════════════════════════════════════════════

  group('CreateServiceProfileRequest', () {
    test('const constructor with only required fields', () {
      const instance = CreateServiceProfileRequest(
        serviceName: 'redis',
        imageName: 'redis',
      );
      expect(instance, isA<CreateServiceProfileRequest>());
      expect(instance.serviceName, 'redis');
      expect(instance.imageName, 'redis');
    });

    test('const constructor with all fields populated', () {
      const instance = CreateServiceProfileRequest(
        serviceName: 'redis',
        imageName: 'redis',
        displayName: 'Redis Cache',
        description: 'In-memory data store',
        imageTag: '7-alpine',
        command: 'redis-server',
        workingDir: '/data',
        envVarsJson: '{"REDIS_PASSWORD":"secret"}',
        portsJson: '["6379:6379"]',
        healthCheckCommand: 'redis-cli ping',
        healthCheckIntervalSeconds: 15,
        healthCheckTimeoutSeconds: 5,
        healthCheckRetries: 3,
        restartPolicy: RestartPolicy.always,
        memoryLimitMb: 256,
        cpuLimit: 0.5,
        startOrder: 2,
        serviceRegistrationId: 'sr-2',
      );
      expect(instance, isA<CreateServiceProfileRequest>());
      expect(instance.restartPolicy, RestartPolicy.always);
    });
  });

  group('UpdateServiceProfileRequest', () {
    test('const constructor with all null optional fields', () {
      const instance = UpdateServiceProfileRequest();
      expect(instance, isA<UpdateServiceProfileRequest>());
    });

    test('const constructor with populated fields', () {
      const instance = UpdateServiceProfileRequest(
        displayName: 'Updated Name',
        description: 'Updated description',
        imageName: 'nginx',
        imageTag: 'stable',
        restartPolicy: RestartPolicy.onFailure,
        isEnabled: false,
        startOrder: 3,
      );
      expect(instance, isA<UpdateServiceProfileRequest>());
      expect(instance.restartPolicy, RestartPolicy.onFailure);
      expect(instance.isEnabled, false);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  SOLUTION PROFILE MODELS
  // ══════════════════════════════════════════════════════════════

  group('FleetSolutionProfile', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetSolutionProfile();
      expect(instance, isA<FleetSolutionProfile>());
    });

    test('constructor with populated fields', () {
      final instance = FleetSolutionProfile(
        id: 'sol-1',
        name: 'Web Stack',
        description: 'Full web application stack',
        isDefault: true,
        serviceCount: 5,
        teamId: 'team-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetSolutionProfile>());
      expect(instance.id, 'sol-1');
      expect(instance.name, 'Web Stack');
      expect(instance.isDefault, true);
      expect(instance.serviceCount, 5);
    });
  });

  group('FleetSolutionProfileDetail', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetSolutionProfileDetail();
      expect(instance, isA<FleetSolutionProfileDetail>());
    });

    test('constructor with populated fields', () {
      final instance = FleetSolutionProfileDetail(
        id: 'sol-1',
        name: 'Web Stack',
        description: 'Full web application stack',
        isDefault: false,
        teamId: 'team-1',
        services: const [],
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetSolutionProfileDetail>());
      expect(instance.services, isEmpty);
    });
  });

  group('FleetSolutionService', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetSolutionService();
      expect(instance, isA<FleetSolutionService>());
    });

    test('const constructor with populated fields', () {
      const instance = FleetSolutionService(
        id: 'ss-1',
        startOrder: 1,
        serviceProfileId: 'sp-1',
        serviceProfileName: 'Nginx',
        imageName: 'nginx',
        isEnabled: true,
      );
      expect(instance, isA<FleetSolutionService>());
      expect(instance.startOrder, 1);
      expect(instance.isEnabled, true);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  SOLUTION PROFILE REQUEST DTOS
  // ══════════════════════════════════════════════════════════════

  group('CreateSolutionProfileRequest', () {
    test('const constructor with only required fields', () {
      const instance = CreateSolutionProfileRequest(name: 'My Solution');
      expect(instance, isA<CreateSolutionProfileRequest>());
      expect(instance.name, 'My Solution');
    });

    test('const constructor with all fields populated', () {
      const instance = CreateSolutionProfileRequest(
        name: 'My Solution',
        description: 'A full stack solution',
        isDefault: true,
      );
      expect(instance, isA<CreateSolutionProfileRequest>());
      expect(instance.isDefault, true);
    });
  });

  group('UpdateSolutionProfileRequest', () {
    test('const constructor with all null optional fields', () {
      const instance = UpdateSolutionProfileRequest();
      expect(instance, isA<UpdateSolutionProfileRequest>());
    });

    test('const constructor with all fields populated', () {
      const instance = UpdateSolutionProfileRequest(
        name: 'Renamed Solution',
        description: 'Updated description',
        isDefault: false,
      );
      expect(instance, isA<UpdateSolutionProfileRequest>());
      expect(instance.isDefault, false);
    });
  });

  group('AddSolutionServiceRequest', () {
    test('const constructor with only required fields', () {
      const instance = AddSolutionServiceRequest(serviceProfileId: 'sp-1');
      expect(instance, isA<AddSolutionServiceRequest>());
      expect(instance.serviceProfileId, 'sp-1');
    });

    test('const constructor with all fields populated', () {
      const instance = AddSolutionServiceRequest(
        serviceProfileId: 'sp-1',
        startOrder: 3,
      );
      expect(instance, isA<AddSolutionServiceRequest>());
      expect(instance.startOrder, 3);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  WORKSTATION PROFILE MODELS
  // ══════════════════════════════════════════════════════════════

  group('FleetWorkstationProfile', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetWorkstationProfile();
      expect(instance, isA<FleetWorkstationProfile>());
    });

    test('constructor with populated fields', () {
      final instance = FleetWorkstationProfile(
        id: 'ws-1',
        name: 'Dev Workstation',
        description: 'Development environment',
        isDefault: true,
        solutionCount: 3,
        userId: 'user-1',
        teamId: 'team-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetWorkstationProfile>());
      expect(instance.name, 'Dev Workstation');
      expect(instance.isDefault, true);
      expect(instance.solutionCount, 3);
    });
  });

  group('FleetWorkstationProfileDetail', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetWorkstationProfileDetail();
      expect(instance, isA<FleetWorkstationProfileDetail>());
    });

    test('constructor with populated fields', () {
      final instance = FleetWorkstationProfileDetail(
        id: 'ws-1',
        name: 'Dev Workstation',
        description: 'Development environment',
        isDefault: false,
        userId: 'user-1',
        teamId: 'team-1',
        solutions: const [],
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetWorkstationProfileDetail>());
      expect(instance.solutions, isEmpty);
    });
  });

  group('FleetWorkstationSolution', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetWorkstationSolution();
      expect(instance, isA<FleetWorkstationSolution>());
    });

    test('const constructor with populated fields', () {
      const instance = FleetWorkstationSolution(
        id: 'wss-1',
        startOrder: 2,
        overrideEnvVarsJson: '{"DEBUG":"true"}',
        solutionProfileId: 'sol-1',
        solutionProfileName: 'Web Stack',
      );
      expect(instance, isA<FleetWorkstationSolution>());
      expect(instance.startOrder, 2);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  WORKSTATION PROFILE REQUEST DTOS
  // ══════════════════════════════════════════════════════════════

  group('CreateWorkstationProfileRequest', () {
    test('const constructor with only required fields', () {
      const instance = CreateWorkstationProfileRequest(
        name: 'My Workstation',
      );
      expect(instance, isA<CreateWorkstationProfileRequest>());
      expect(instance.name, 'My Workstation');
    });

    test('const constructor with all fields populated', () {
      const instance = CreateWorkstationProfileRequest(
        name: 'My Workstation',
        description: 'Custom dev environment',
        isDefault: true,
      );
      expect(instance, isA<CreateWorkstationProfileRequest>());
      expect(instance.isDefault, true);
    });
  });

  group('UpdateWorkstationProfileRequest', () {
    test('const constructor with all null optional fields', () {
      const instance = UpdateWorkstationProfileRequest();
      expect(instance, isA<UpdateWorkstationProfileRequest>());
    });

    test('const constructor with all fields populated', () {
      const instance = UpdateWorkstationProfileRequest(
        name: 'Renamed Workstation',
        description: 'Updated description',
        isDefault: false,
      );
      expect(instance, isA<UpdateWorkstationProfileRequest>());
      expect(instance.isDefault, false);
    });
  });

  group('AddWorkstationSolutionRequest', () {
    test('const constructor with only required fields', () {
      const instance = AddWorkstationSolutionRequest(
        solutionProfileId: 'sol-1',
      );
      expect(instance, isA<AddWorkstationSolutionRequest>());
      expect(instance.solutionProfileId, 'sol-1');
    });

    test('const constructor with all fields populated', () {
      const instance = AddWorkstationSolutionRequest(
        solutionProfileId: 'sol-1',
        startOrder: 1,
        overrideEnvVarsJson: '{"ENV":"staging"}',
      );
      expect(instance, isA<AddWorkstationSolutionRequest>());
      expect(instance.startOrder, 1);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  DOCKER RESOURCE MODELS
  // ══════════════════════════════════════════════════════════════

  group('FleetDockerImage', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetDockerImage();
      expect(instance, isA<FleetDockerImage>());
    });

    test('constructor with populated fields', () {
      final instance = FleetDockerImage(
        id: 'sha256:abc123',
        repoTags: const ['nginx:latest', 'nginx:1.25'],
        sizeBytes: 187000000,
        created: DateTime.utc(2026),
      );
      expect(instance, isA<FleetDockerImage>());
      expect(instance.id, 'sha256:abc123');
      expect(instance.repoTags, ['nginx:latest', 'nginx:1.25']);
      expect(instance.sizeBytes, 187000000);
    });
  });

  group('FleetDockerVolume', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetDockerVolume();
      expect(instance, isA<FleetDockerVolume>());
    });

    test('constructor with populated fields', () {
      final instance = FleetDockerVolume(
        name: 'my-volume',
        driver: 'local',
        mountpoint: '/var/lib/docker/volumes/my-volume/_data',
        labels: const {'project': 'codeops'},
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<FleetDockerVolume>());
      expect(instance.name, 'my-volume');
      expect(instance.driver, 'local');
      expect(instance.labels, {'project': 'codeops'});
    });
  });

  group('FleetDockerNetwork', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetDockerNetwork();
      expect(instance, isA<FleetDockerNetwork>());
    });

    test('const constructor with populated fields', () {
      const instance = FleetDockerNetwork(
        id: 'net-1',
        name: 'my-network',
        driver: 'bridge',
        subnet: '172.18.0.0/16',
        gateway: '172.18.0.1',
        connectedContainers: ['c1', 'c2'],
      );
      expect(instance, isA<FleetDockerNetwork>());
      expect(instance.id, 'net-1');
      expect(instance.name, 'my-network');
      expect(instance.connectedContainers, ['c1', 'c2']);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  VOLUME & NETWORK CONFIG MODELS
  // ══════════════════════════════════════════════════════════════

  group('FleetVolumeMount', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetVolumeMount();
      expect(instance, isA<FleetVolumeMount>());
    });

    test('const constructor with populated fields', () {
      const instance = FleetVolumeMount(
        id: 'vm-1',
        hostPath: '/host/data',
        containerPath: '/container/data',
        volumeName: 'data-vol',
        isReadOnly: true,
      );
      expect(instance, isA<FleetVolumeMount>());
      expect(instance.hostPath, '/host/data');
      expect(instance.containerPath, '/container/data');
      expect(instance.isReadOnly, true);
    });
  });

  group('FleetNetworkConfig', () {
    test('const constructor with all null optional fields', () {
      const instance = FleetNetworkConfig();
      expect(instance, isA<FleetNetworkConfig>());
    });

    test('const constructor with populated fields', () {
      const instance = FleetNetworkConfig(
        id: 'nc-1',
        networkName: 'app-network',
        aliases: 'web,frontend',
        ipAddress: '172.18.0.5',
      );
      expect(instance, isA<FleetNetworkConfig>());
      expect(instance.networkName, 'app-network');
      expect(instance.aliases, 'web,frontend');
      expect(instance.ipAddress, '172.18.0.5');
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  VOLUME & NETWORK REQUEST DTOS
  // ══════════════════════════════════════════════════════════════

  group('CreateVolumeMountRequest', () {
    test('const constructor with only required fields', () {
      const instance = CreateVolumeMountRequest(containerPath: '/app/data');
      expect(instance, isA<CreateVolumeMountRequest>());
      expect(instance.containerPath, '/app/data');
    });

    test('const constructor with all fields populated', () {
      const instance = CreateVolumeMountRequest(
        containerPath: '/app/data',
        hostPath: '/host/data',
        volumeName: 'app-data',
        isReadOnly: false,
      );
      expect(instance, isA<CreateVolumeMountRequest>());
      expect(instance.isReadOnly, false);
    });
  });

  group('CreateNetworkConfigRequest', () {
    test('const constructor with only required fields', () {
      const instance = CreateNetworkConfigRequest(networkName: 'backend-net');
      expect(instance, isA<CreateNetworkConfigRequest>());
      expect(instance.networkName, 'backend-net');
    });

    test('const constructor with all fields populated', () {
      const instance = CreateNetworkConfigRequest(
        networkName: 'backend-net',
        aliases: 'api,backend',
        ipAddress: '172.19.0.10',
      );
      expect(instance, isA<CreateNetworkConfigRequest>());
      expect(instance.aliases, 'api,backend');
    });
  });
}
