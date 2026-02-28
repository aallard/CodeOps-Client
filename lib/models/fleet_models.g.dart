// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fleet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FleetContainerInstance _$FleetContainerInstanceFromJson(
        Map<String, dynamic> json) =>
    FleetContainerInstance(
      id: json['id'] as String?,
      containerId: json['containerId'] as String?,
      containerName: json['containerName'] as String?,
      serviceName: json['serviceName'] as String?,
      imageName: json['imageName'] as String?,
      imageTag: json['imageTag'] as String?,
      status: _$JsonConverterFromJson<String, ContainerStatus>(
          json['status'], const ContainerStatusConverter().fromJson),
      healthStatus: _$JsonConverterFromJson<String, HealthStatus>(
          json['healthStatus'], const HealthStatusConverter().fromJson),
      restartPolicy: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicy'], const RestartPolicyConverter().fromJson),
      restartCount: (json['restartCount'] as num?)?.toInt(),
      cpuPercent: (json['cpuPercent'] as num?)?.toDouble(),
      memoryBytes: (json['memoryBytes'] as num?)?.toInt(),
      memoryLimitBytes: (json['memoryLimitBytes'] as num?)?.toInt(),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetContainerInstanceToJson(
        FleetContainerInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'containerId': instance.containerId,
      'containerName': instance.containerName,
      'serviceName': instance.serviceName,
      'imageName': instance.imageName,
      'imageTag': instance.imageTag,
      'status': _$JsonConverterToJson<String, ContainerStatus>(
          instance.status, const ContainerStatusConverter().toJson),
      'healthStatus': _$JsonConverterToJson<String, HealthStatus>(
          instance.healthStatus, const HealthStatusConverter().toJson),
      'restartPolicy': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicy, const RestartPolicyConverter().toJson),
      'restartCount': instance.restartCount,
      'cpuPercent': instance.cpuPercent,
      'memoryBytes': instance.memoryBytes,
      'memoryLimitBytes': instance.memoryLimitBytes,
      'startedAt': instance.startedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

FleetContainerDetail _$FleetContainerDetailFromJson(
        Map<String, dynamic> json) =>
    FleetContainerDetail(
      id: json['id'] as String?,
      containerId: json['containerId'] as String?,
      containerName: json['containerName'] as String?,
      serviceName: json['serviceName'] as String?,
      imageName: json['imageName'] as String?,
      imageTag: json['imageTag'] as String?,
      status: _$JsonConverterFromJson<String, ContainerStatus>(
          json['status'], const ContainerStatusConverter().fromJson),
      healthStatus: _$JsonConverterFromJson<String, HealthStatus>(
          json['healthStatus'], const HealthStatusConverter().fromJson),
      restartPolicy: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicy'], const RestartPolicyConverter().fromJson),
      restartCount: (json['restartCount'] as num?)?.toInt(),
      exitCode: (json['exitCode'] as num?)?.toInt(),
      cpuPercent: (json['cpuPercent'] as num?)?.toDouble(),
      memoryBytes: (json['memoryBytes'] as num?)?.toInt(),
      memoryLimitBytes: (json['memoryLimitBytes'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
      serviceProfileId: json['serviceProfileId'] as String?,
      serviceProfileName: json['serviceProfileName'] as String?,
      teamId: json['teamId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FleetContainerDetailToJson(
        FleetContainerDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'containerId': instance.containerId,
      'containerName': instance.containerName,
      'serviceName': instance.serviceName,
      'imageName': instance.imageName,
      'imageTag': instance.imageTag,
      'status': _$JsonConverterToJson<String, ContainerStatus>(
          instance.status, const ContainerStatusConverter().toJson),
      'healthStatus': _$JsonConverterToJson<String, HealthStatus>(
          instance.healthStatus, const HealthStatusConverter().toJson),
      'restartPolicy': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicy, const RestartPolicyConverter().toJson),
      'restartCount': instance.restartCount,
      'exitCode': instance.exitCode,
      'cpuPercent': instance.cpuPercent,
      'memoryBytes': instance.memoryBytes,
      'memoryLimitBytes': instance.memoryLimitBytes,
      'pid': instance.pid,
      'startedAt': instance.startedAt?.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
      'serviceProfileId': instance.serviceProfileId,
      'serviceProfileName': instance.serviceProfileName,
      'teamId': instance.teamId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FleetServiceProfile _$FleetServiceProfileFromJson(Map<String, dynamic> json) =>
    FleetServiceProfile(
      id: json['id'] as String?,
      serviceName: json['serviceName'] as String?,
      displayName: json['displayName'] as String?,
      imageName: json['imageName'] as String?,
      imageTag: json['imageTag'] as String?,
      restartPolicy: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicy'], const RestartPolicyConverter().fromJson),
      isAutoGenerated: json['isAutoGenerated'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      startOrder: (json['startOrder'] as num?)?.toInt(),
      serviceRegistrationId: json['serviceRegistrationId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetServiceProfileToJson(
        FleetServiceProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceName': instance.serviceName,
      'displayName': instance.displayName,
      'imageName': instance.imageName,
      'imageTag': instance.imageTag,
      'restartPolicy': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicy, const RestartPolicyConverter().toJson),
      'isAutoGenerated': instance.isAutoGenerated,
      'isEnabled': instance.isEnabled,
      'startOrder': instance.startOrder,
      'serviceRegistrationId': instance.serviceRegistrationId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

FleetServiceProfileDetail _$FleetServiceProfileDetailFromJson(
        Map<String, dynamic> json) =>
    FleetServiceProfileDetail(
      id: json['id'] as String?,
      serviceName: json['serviceName'] as String?,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      imageName: json['imageName'] as String?,
      imageTag: json['imageTag'] as String?,
      command: json['command'] as String?,
      workingDir: json['workingDir'] as String?,
      envVarsJson: json['envVarsJson'] as String?,
      portsJson: json['portsJson'] as String?,
      healthCheckCommand: json['healthCheckCommand'] as String?,
      healthCheckIntervalSeconds:
          (json['healthCheckIntervalSeconds'] as num?)?.toInt(),
      healthCheckTimeoutSeconds:
          (json['healthCheckTimeoutSeconds'] as num?)?.toInt(),
      healthCheckRetries: (json['healthCheckRetries'] as num?)?.toInt(),
      restartPolicy: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicy'], const RestartPolicyConverter().fromJson),
      memoryLimitMb: (json['memoryLimitMb'] as num?)?.toInt(),
      cpuLimit: (json['cpuLimit'] as num?)?.toDouble(),
      isAutoGenerated: json['isAutoGenerated'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      startOrder: (json['startOrder'] as num?)?.toInt(),
      serviceRegistrationId: json['serviceRegistrationId'] as String?,
      teamId: json['teamId'] as String?,
      volumes: (json['volumes'] as List<dynamic>?)
          ?.map((e) => FleetVolumeMount.fromJson(e as Map<String, dynamic>))
          .toList(),
      networks: (json['networks'] as List<dynamic>?)
          ?.map((e) => FleetNetworkConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FleetServiceProfileDetailToJson(
        FleetServiceProfileDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceName': instance.serviceName,
      'displayName': instance.displayName,
      'description': instance.description,
      'imageName': instance.imageName,
      'imageTag': instance.imageTag,
      'command': instance.command,
      'workingDir': instance.workingDir,
      'envVarsJson': instance.envVarsJson,
      'portsJson': instance.portsJson,
      'healthCheckCommand': instance.healthCheckCommand,
      'healthCheckIntervalSeconds': instance.healthCheckIntervalSeconds,
      'healthCheckTimeoutSeconds': instance.healthCheckTimeoutSeconds,
      'healthCheckRetries': instance.healthCheckRetries,
      'restartPolicy': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicy, const RestartPolicyConverter().toJson),
      'memoryLimitMb': instance.memoryLimitMb,
      'cpuLimit': instance.cpuLimit,
      'isAutoGenerated': instance.isAutoGenerated,
      'isEnabled': instance.isEnabled,
      'startOrder': instance.startOrder,
      'serviceRegistrationId': instance.serviceRegistrationId,
      'teamId': instance.teamId,
      'volumes': instance.volumes?.map((e) => e.toJson()).toList(),
      'networks': instance.networks?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FleetSolutionProfile _$FleetSolutionProfileFromJson(
        Map<String, dynamic> json) =>
    FleetSolutionProfile(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
      serviceCount: (json['serviceCount'] as num?)?.toInt(),
      teamId: json['teamId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetSolutionProfileToJson(
        FleetSolutionProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
      'serviceCount': instance.serviceCount,
      'teamId': instance.teamId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

FleetSolutionProfileDetail _$FleetSolutionProfileDetailFromJson(
        Map<String, dynamic> json) =>
    FleetSolutionProfileDetail(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
      teamId: json['teamId'] as String?,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => FleetSolutionService.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FleetSolutionProfileDetailToJson(
        FleetSolutionProfileDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
      'teamId': instance.teamId,
      'services': instance.services?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FleetSolutionService _$FleetSolutionServiceFromJson(
        Map<String, dynamic> json) =>
    FleetSolutionService(
      id: json['id'] as String?,
      startOrder: (json['startOrder'] as num?)?.toInt(),
      serviceProfileId: json['serviceProfileId'] as String?,
      serviceProfileName: json['serviceProfileName'] as String?,
      imageName: json['imageName'] as String?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$FleetSolutionServiceToJson(
        FleetSolutionService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startOrder': instance.startOrder,
      'serviceProfileId': instance.serviceProfileId,
      'serviceProfileName': instance.serviceProfileName,
      'imageName': instance.imageName,
      'isEnabled': instance.isEnabled,
    };

FleetWorkstationProfile _$FleetWorkstationProfileFromJson(
        Map<String, dynamic> json) =>
    FleetWorkstationProfile(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
      solutionCount: (json['solutionCount'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      teamId: json['teamId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetWorkstationProfileToJson(
        FleetWorkstationProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
      'solutionCount': instance.solutionCount,
      'userId': instance.userId,
      'teamId': instance.teamId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

FleetWorkstationProfileDetail _$FleetWorkstationProfileDetailFromJson(
        Map<String, dynamic> json) =>
    FleetWorkstationProfileDetail(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
      userId: json['userId'] as String?,
      teamId: json['teamId'] as String?,
      solutions: (json['solutions'] as List<dynamic>?)
          ?.map((e) =>
              FleetWorkstationSolution.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FleetWorkstationProfileDetailToJson(
        FleetWorkstationProfileDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
      'userId': instance.userId,
      'teamId': instance.teamId,
      'solutions': instance.solutions?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FleetWorkstationSolution _$FleetWorkstationSolutionFromJson(
        Map<String, dynamic> json) =>
    FleetWorkstationSolution(
      id: json['id'] as String?,
      startOrder: (json['startOrder'] as num?)?.toInt(),
      overrideEnvVarsJson: json['overrideEnvVarsJson'] as String?,
      solutionProfileId: json['solutionProfileId'] as String?,
      solutionProfileName: json['solutionProfileName'] as String?,
    );

Map<String, dynamic> _$FleetWorkstationSolutionToJson(
        FleetWorkstationSolution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startOrder': instance.startOrder,
      'overrideEnvVarsJson': instance.overrideEnvVarsJson,
      'solutionProfileId': instance.solutionProfileId,
      'solutionProfileName': instance.solutionProfileName,
    };

FleetHealthSummary _$FleetHealthSummaryFromJson(Map<String, dynamic> json) =>
    FleetHealthSummary(
      totalContainers: (json['totalContainers'] as num?)?.toInt(),
      runningContainers: (json['runningContainers'] as num?)?.toInt(),
      stoppedContainers: (json['stoppedContainers'] as num?)?.toInt(),
      unhealthyContainers: (json['unhealthyContainers'] as num?)?.toInt(),
      restartingContainers: (json['restartingContainers'] as num?)?.toInt(),
      totalCpuPercent: (json['totalCpuPercent'] as num?)?.toDouble(),
      totalMemoryBytes: (json['totalMemoryBytes'] as num?)?.toInt(),
      totalMemoryLimitBytes: (json['totalMemoryLimitBytes'] as num?)?.toInt(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$FleetHealthSummaryToJson(FleetHealthSummary instance) =>
    <String, dynamic>{
      'totalContainers': instance.totalContainers,
      'runningContainers': instance.runningContainers,
      'stoppedContainers': instance.stoppedContainers,
      'unhealthyContainers': instance.unhealthyContainers,
      'restartingContainers': instance.restartingContainers,
      'totalCpuPercent': instance.totalCpuPercent,
      'totalMemoryBytes': instance.totalMemoryBytes,
      'totalMemoryLimitBytes': instance.totalMemoryLimitBytes,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

FleetContainerHealthCheck _$FleetContainerHealthCheckFromJson(
        Map<String, dynamic> json) =>
    FleetContainerHealthCheck(
      id: json['id'] as String?,
      status: _$JsonConverterFromJson<String, HealthStatus>(
          json['status'], const HealthStatusConverter().fromJson),
      output: json['output'] as String?,
      exitCode: (json['exitCode'] as num?)?.toInt(),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      containerId: json['containerId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetContainerHealthCheckToJson(
        FleetContainerHealthCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$JsonConverterToJson<String, HealthStatus>(
          instance.status, const HealthStatusConverter().toJson),
      'output': instance.output,
      'exitCode': instance.exitCode,
      'durationMs': instance.durationMs,
      'containerId': instance.containerId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

FleetContainerLog _$FleetContainerLogFromJson(Map<String, dynamic> json) =>
    FleetContainerLog(
      id: json['id'] as String?,
      stream: json['stream'] as String?,
      content: json['content'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      containerId: json['containerId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetContainerLogToJson(FleetContainerLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stream': instance.stream,
      'content': instance.content,
      'timestamp': instance.timestamp?.toIso8601String(),
      'containerId': instance.containerId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

FleetContainerStats _$FleetContainerStatsFromJson(Map<String, dynamic> json) =>
    FleetContainerStats(
      containerId: json['containerId'] as String?,
      containerName: json['containerName'] as String?,
      cpuPercent: (json['cpuPercent'] as num?)?.toDouble(),
      memoryUsageBytes: (json['memoryUsageBytes'] as num?)?.toInt(),
      memoryLimitBytes: (json['memoryLimitBytes'] as num?)?.toInt(),
      networkRxBytes: (json['networkRxBytes'] as num?)?.toInt(),
      networkTxBytes: (json['networkTxBytes'] as num?)?.toInt(),
      blockReadBytes: (json['blockReadBytes'] as num?)?.toInt(),
      blockWriteBytes: (json['blockWriteBytes'] as num?)?.toInt(),
      pids: (json['pids'] as num?)?.toInt(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$FleetContainerStatsToJson(
        FleetContainerStats instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'containerName': instance.containerName,
      'cpuPercent': instance.cpuPercent,
      'memoryUsageBytes': instance.memoryUsageBytes,
      'memoryLimitBytes': instance.memoryLimitBytes,
      'networkRxBytes': instance.networkRxBytes,
      'networkTxBytes': instance.networkTxBytes,
      'blockReadBytes': instance.blockReadBytes,
      'blockWriteBytes': instance.blockWriteBytes,
      'pids': instance.pids,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

FleetDockerImage _$FleetDockerImageFromJson(Map<String, dynamic> json) =>
    FleetDockerImage(
      id: json['id'] as String?,
      repoTags: (json['repoTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
    );

Map<String, dynamic> _$FleetDockerImageToJson(FleetDockerImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'repoTags': instance.repoTags,
      'sizeBytes': instance.sizeBytes,
      'created': instance.created?.toIso8601String(),
    };

FleetDockerVolume _$FleetDockerVolumeFromJson(Map<String, dynamic> json) =>
    FleetDockerVolume(
      name: json['name'] as String?,
      driver: json['driver'] as String?,
      mountpoint: json['mountpoint'] as String?,
      labels: (json['labels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FleetDockerVolumeToJson(FleetDockerVolume instance) =>
    <String, dynamic>{
      'name': instance.name,
      'driver': instance.driver,
      'mountpoint': instance.mountpoint,
      'labels': instance.labels,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

FleetDockerNetwork _$FleetDockerNetworkFromJson(Map<String, dynamic> json) =>
    FleetDockerNetwork(
      id: json['id'] as String?,
      name: json['name'] as String?,
      driver: json['driver'] as String?,
      subnet: json['subnet'] as String?,
      gateway: json['gateway'] as String?,
      connectedContainers: (json['connectedContainers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FleetDockerNetworkToJson(FleetDockerNetwork instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'driver': instance.driver,
      'subnet': instance.subnet,
      'gateway': instance.gateway,
      'connectedContainers': instance.connectedContainers,
    };

FleetVolumeMount _$FleetVolumeMountFromJson(Map<String, dynamic> json) =>
    FleetVolumeMount(
      id: json['id'] as String?,
      hostPath: json['hostPath'] as String?,
      containerPath: json['containerPath'] as String?,
      volumeName: json['volumeName'] as String?,
      isReadOnly: json['isReadOnly'] as bool?,
    );

Map<String, dynamic> _$FleetVolumeMountToJson(FleetVolumeMount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hostPath': instance.hostPath,
      'containerPath': instance.containerPath,
      'volumeName': instance.volumeName,
      'isReadOnly': instance.isReadOnly,
    };

FleetNetworkConfig _$FleetNetworkConfigFromJson(Map<String, dynamic> json) =>
    FleetNetworkConfig(
      id: json['id'] as String?,
      networkName: json['networkName'] as String?,
      aliases: json['aliases'] as String?,
      ipAddress: json['ipAddress'] as String?,
    );

Map<String, dynamic> _$FleetNetworkConfigToJson(FleetNetworkConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'networkName': instance.networkName,
      'aliases': instance.aliases,
      'ipAddress': instance.ipAddress,
    };

StartContainerRequest _$StartContainerRequestFromJson(
        Map<String, dynamic> json) =>
    StartContainerRequest(
      serviceProfileId: json['serviceProfileId'] as String,
      containerNameOverride: json['containerNameOverride'] as String?,
      imageTagOverride: json['imageTagOverride'] as String?,
      envVarOverrides: (json['envVarOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      restartPolicyOverride: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicyOverride'],
          const RestartPolicyConverter().fromJson),
    );

Map<String, dynamic> _$StartContainerRequestToJson(
        StartContainerRequest instance) =>
    <String, dynamic>{
      'serviceProfileId': instance.serviceProfileId,
      'containerNameOverride': instance.containerNameOverride,
      'imageTagOverride': instance.imageTagOverride,
      'envVarOverrides': instance.envVarOverrides,
      'restartPolicyOverride': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicyOverride,
          const RestartPolicyConverter().toJson),
    };

ContainerExecRequest _$ContainerExecRequestFromJson(
        Map<String, dynamic> json) =>
    ContainerExecRequest(
      command: json['command'] as String,
      attachStdout: json['attachStdout'] as bool?,
      attachStderr: json['attachStderr'] as bool?,
    );

Map<String, dynamic> _$ContainerExecRequestToJson(
        ContainerExecRequest instance) =>
    <String, dynamic>{
      'command': instance.command,
      'attachStdout': instance.attachStdout,
      'attachStderr': instance.attachStderr,
    };

CreateServiceProfileRequest _$CreateServiceProfileRequestFromJson(
        Map<String, dynamic> json) =>
    CreateServiceProfileRequest(
      serviceName: json['serviceName'] as String,
      imageName: json['imageName'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      imageTag: json['imageTag'] as String?,
      command: json['command'] as String?,
      workingDir: json['workingDir'] as String?,
      envVarsJson: json['envVarsJson'] as String?,
      portsJson: json['portsJson'] as String?,
      healthCheckCommand: json['healthCheckCommand'] as String?,
      healthCheckIntervalSeconds:
          (json['healthCheckIntervalSeconds'] as num?)?.toInt(),
      healthCheckTimeoutSeconds:
          (json['healthCheckTimeoutSeconds'] as num?)?.toInt(),
      healthCheckRetries: (json['healthCheckRetries'] as num?)?.toInt(),
      restartPolicy: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicy'], const RestartPolicyConverter().fromJson),
      memoryLimitMb: (json['memoryLimitMb'] as num?)?.toInt(),
      cpuLimit: (json['cpuLimit'] as num?)?.toDouble(),
      startOrder: (json['startOrder'] as num?)?.toInt(),
      serviceRegistrationId: json['serviceRegistrationId'] as String?,
    );

Map<String, dynamic> _$CreateServiceProfileRequestToJson(
        CreateServiceProfileRequest instance) =>
    <String, dynamic>{
      'serviceName': instance.serviceName,
      'imageName': instance.imageName,
      'displayName': instance.displayName,
      'description': instance.description,
      'imageTag': instance.imageTag,
      'command': instance.command,
      'workingDir': instance.workingDir,
      'envVarsJson': instance.envVarsJson,
      'portsJson': instance.portsJson,
      'healthCheckCommand': instance.healthCheckCommand,
      'healthCheckIntervalSeconds': instance.healthCheckIntervalSeconds,
      'healthCheckTimeoutSeconds': instance.healthCheckTimeoutSeconds,
      'healthCheckRetries': instance.healthCheckRetries,
      'restartPolicy': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicy, const RestartPolicyConverter().toJson),
      'memoryLimitMb': instance.memoryLimitMb,
      'cpuLimit': instance.cpuLimit,
      'startOrder': instance.startOrder,
      'serviceRegistrationId': instance.serviceRegistrationId,
    };

UpdateServiceProfileRequest _$UpdateServiceProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateServiceProfileRequest(
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      imageName: json['imageName'] as String?,
      imageTag: json['imageTag'] as String?,
      command: json['command'] as String?,
      workingDir: json['workingDir'] as String?,
      envVarsJson: json['envVarsJson'] as String?,
      portsJson: json['portsJson'] as String?,
      healthCheckCommand: json['healthCheckCommand'] as String?,
      healthCheckIntervalSeconds:
          (json['healthCheckIntervalSeconds'] as num?)?.toInt(),
      healthCheckTimeoutSeconds:
          (json['healthCheckTimeoutSeconds'] as num?)?.toInt(),
      healthCheckRetries: (json['healthCheckRetries'] as num?)?.toInt(),
      restartPolicy: _$JsonConverterFromJson<String, RestartPolicy>(
          json['restartPolicy'], const RestartPolicyConverter().fromJson),
      memoryLimitMb: (json['memoryLimitMb'] as num?)?.toInt(),
      cpuLimit: (json['cpuLimit'] as num?)?.toDouble(),
      isEnabled: json['isEnabled'] as bool?,
      startOrder: (json['startOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateServiceProfileRequestToJson(
        UpdateServiceProfileRequest instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'description': instance.description,
      'imageName': instance.imageName,
      'imageTag': instance.imageTag,
      'command': instance.command,
      'workingDir': instance.workingDir,
      'envVarsJson': instance.envVarsJson,
      'portsJson': instance.portsJson,
      'healthCheckCommand': instance.healthCheckCommand,
      'healthCheckIntervalSeconds': instance.healthCheckIntervalSeconds,
      'healthCheckTimeoutSeconds': instance.healthCheckTimeoutSeconds,
      'healthCheckRetries': instance.healthCheckRetries,
      'restartPolicy': _$JsonConverterToJson<String, RestartPolicy>(
          instance.restartPolicy, const RestartPolicyConverter().toJson),
      'memoryLimitMb': instance.memoryLimitMb,
      'cpuLimit': instance.cpuLimit,
      'isEnabled': instance.isEnabled,
      'startOrder': instance.startOrder,
    };

CreateSolutionProfileRequest _$CreateSolutionProfileRequestFromJson(
        Map<String, dynamic> json) =>
    CreateSolutionProfileRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$CreateSolutionProfileRequestToJson(
        CreateSolutionProfileRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
    };

UpdateSolutionProfileRequest _$UpdateSolutionProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateSolutionProfileRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$UpdateSolutionProfileRequestToJson(
        UpdateSolutionProfileRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
    };

AddSolutionServiceRequest _$AddSolutionServiceRequestFromJson(
        Map<String, dynamic> json) =>
    AddSolutionServiceRequest(
      serviceProfileId: json['serviceProfileId'] as String,
      startOrder: (json['startOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AddSolutionServiceRequestToJson(
        AddSolutionServiceRequest instance) =>
    <String, dynamic>{
      'serviceProfileId': instance.serviceProfileId,
      'startOrder': instance.startOrder,
    };

CreateWorkstationProfileRequest _$CreateWorkstationProfileRequestFromJson(
        Map<String, dynamic> json) =>
    CreateWorkstationProfileRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$CreateWorkstationProfileRequestToJson(
        CreateWorkstationProfileRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
    };

UpdateWorkstationProfileRequest _$UpdateWorkstationProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateWorkstationProfileRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$UpdateWorkstationProfileRequestToJson(
        UpdateWorkstationProfileRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'isDefault': instance.isDefault,
    };

AddWorkstationSolutionRequest _$AddWorkstationSolutionRequestFromJson(
        Map<String, dynamic> json) =>
    AddWorkstationSolutionRequest(
      solutionProfileId: json['solutionProfileId'] as String,
      startOrder: (json['startOrder'] as num?)?.toInt(),
      overrideEnvVarsJson: json['overrideEnvVarsJson'] as String?,
    );

Map<String, dynamic> _$AddWorkstationSolutionRequestToJson(
        AddWorkstationSolutionRequest instance) =>
    <String, dynamic>{
      'solutionProfileId': instance.solutionProfileId,
      'startOrder': instance.startOrder,
      'overrideEnvVarsJson': instance.overrideEnvVarsJson,
    };

CreateVolumeMountRequest _$CreateVolumeMountRequestFromJson(
        Map<String, dynamic> json) =>
    CreateVolumeMountRequest(
      containerPath: json['containerPath'] as String,
      hostPath: json['hostPath'] as String?,
      volumeName: json['volumeName'] as String?,
      isReadOnly: json['isReadOnly'] as bool?,
    );

Map<String, dynamic> _$CreateVolumeMountRequestToJson(
        CreateVolumeMountRequest instance) =>
    <String, dynamic>{
      'containerPath': instance.containerPath,
      'hostPath': instance.hostPath,
      'volumeName': instance.volumeName,
      'isReadOnly': instance.isReadOnly,
    };

CreateNetworkConfigRequest _$CreateNetworkConfigRequestFromJson(
        Map<String, dynamic> json) =>
    CreateNetworkConfigRequest(
      networkName: json['networkName'] as String,
      aliases: json['aliases'] as String?,
      ipAddress: json['ipAddress'] as String?,
    );

Map<String, dynamic> _$CreateNetworkConfigRequestToJson(
        CreateNetworkConfigRequest instance) =>
    <String, dynamic>{
      'networkName': instance.networkName,
      'aliases': instance.aliases,
      'ipAddress': instance.ipAddress,
    };
