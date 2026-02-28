/// Model classes for the CodeOps-Fleet module.
///
/// Maps to response and request DTOs defined in the Fleet controllers.
/// All classes use [JsonSerializable] with generated `fromJson` / `toJson`
/// methods via build_runner.
///
/// Organized by domain:
/// - Container instances (2 classes)
/// - Service profiles (2 classes)
/// - Solution profiles (3 classes)
/// - Workstation profiles (3 classes)
/// - Health (2 classes)
/// - Logs & Stats (2 classes)
/// - Docker resources (3 classes)
/// - Volume & Network config (2 classes)
/// - Request DTOs (12 classes)
library;

import 'package:json_annotation/json_annotation.dart';

import 'fleet_enums.dart';

part 'fleet_models.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Container Instances
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight container instance response for list views.
@JsonSerializable()
class FleetContainerInstance {
  /// Unique identifier (UUID).
  final String? id;

  /// Docker container ID.
  final String? containerId;

  /// Docker container name.
  final String? containerName;

  /// Service name.
  final String? serviceName;

  /// Docker image name.
  final String? imageName;

  /// Docker image tag.
  final String? imageTag;

  /// Container lifecycle status.
  @ContainerStatusConverter()
  final ContainerStatus? status;

  /// Container health check status.
  @HealthStatusConverter()
  final HealthStatus? healthStatus;

  /// Docker restart policy.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicy;

  /// Number of times the container has restarted.
  final int? restartCount;

  /// Current CPU usage percentage.
  final double? cpuPercent;

  /// Current memory usage in bytes.
  final int? memoryBytes;

  /// Memory limit in bytes.
  final int? memoryLimitBytes;

  /// Timestamp when the container was started.
  final DateTime? startedAt;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [FleetContainerInstance].
  const FleetContainerInstance({
    this.id,
    this.containerId,
    this.containerName,
    this.serviceName,
    this.imageName,
    this.imageTag,
    this.status,
    this.healthStatus,
    this.restartPolicy,
    this.restartCount,
    this.cpuPercent,
    this.memoryBytes,
    this.memoryLimitBytes,
    this.startedAt,
    this.createdAt,
  });

  /// Deserializes a [FleetContainerInstance] from a JSON map.
  factory FleetContainerInstance.fromJson(Map<String, dynamic> json) =>
      _$FleetContainerInstanceFromJson(json);

  /// Serializes this [FleetContainerInstance] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetContainerInstanceToJson(this);
}

/// Full container detail response including relationships.
@JsonSerializable()
class FleetContainerDetail {
  /// Unique identifier (UUID).
  final String? id;

  /// Docker container ID.
  final String? containerId;

  /// Docker container name.
  final String? containerName;

  /// Service name.
  final String? serviceName;

  /// Docker image name.
  final String? imageName;

  /// Docker image tag.
  final String? imageTag;

  /// Container lifecycle status.
  @ContainerStatusConverter()
  final ContainerStatus? status;

  /// Container health check status.
  @HealthStatusConverter()
  final HealthStatus? healthStatus;

  /// Docker restart policy.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicy;

  /// Number of times the container has restarted.
  final int? restartCount;

  /// Container exit code.
  final int? exitCode;

  /// Current CPU usage percentage.
  final double? cpuPercent;

  /// Current memory usage in bytes.
  final int? memoryBytes;

  /// Memory limit in bytes.
  final int? memoryLimitBytes;

  /// Container process ID.
  final int? pid;

  /// Timestamp when the container was started.
  final DateTime? startedAt;

  /// Timestamp when the container finished.
  final DateTime? finishedAt;

  /// UUID of the associated service profile.
  final String? serviceProfileId;

  /// Name of the associated service profile.
  final String? serviceProfileName;

  /// UUID of the owning team.
  final String? teamId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [FleetContainerDetail].
  const FleetContainerDetail({
    this.id,
    this.containerId,
    this.containerName,
    this.serviceName,
    this.imageName,
    this.imageTag,
    this.status,
    this.healthStatus,
    this.restartPolicy,
    this.restartCount,
    this.exitCode,
    this.cpuPercent,
    this.memoryBytes,
    this.memoryLimitBytes,
    this.pid,
    this.startedAt,
    this.finishedAt,
    this.serviceProfileId,
    this.serviceProfileName,
    this.teamId,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [FleetContainerDetail] from a JSON map.
  factory FleetContainerDetail.fromJson(Map<String, dynamic> json) =>
      _$FleetContainerDetailFromJson(json);

  /// Serializes this [FleetContainerDetail] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetContainerDetailToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Profiles
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight service profile response for list views.
@JsonSerializable()
class FleetServiceProfile {
  /// Unique identifier (UUID).
  final String? id;

  /// Service name.
  final String? serviceName;

  /// Human-readable display name.
  final String? displayName;

  /// Docker image name.
  final String? imageName;

  /// Docker image tag.
  final String? imageTag;

  /// Docker restart policy.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicy;

  /// Whether this profile was auto-generated from a service registration.
  final bool? isAutoGenerated;

  /// Whether this profile is enabled.
  final bool? isEnabled;

  /// Start order within a solution.
  final int? startOrder;

  /// UUID of the linked service registration.
  final String? serviceRegistrationId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [FleetServiceProfile].
  const FleetServiceProfile({
    this.id,
    this.serviceName,
    this.displayName,
    this.imageName,
    this.imageTag,
    this.restartPolicy,
    this.isAutoGenerated,
    this.isEnabled,
    this.startOrder,
    this.serviceRegistrationId,
    this.createdAt,
  });

  /// Deserializes a [FleetServiceProfile] from a JSON map.
  factory FleetServiceProfile.fromJson(Map<String, dynamic> json) =>
      _$FleetServiceProfileFromJson(json);

  /// Serializes this [FleetServiceProfile] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetServiceProfileToJson(this);
}

/// Full service profile detail response including volumes and networks.
@JsonSerializable(explicitToJson: true)
class FleetServiceProfileDetail {
  /// Unique identifier (UUID).
  final String? id;

  /// Service name.
  final String? serviceName;

  /// Human-readable display name.
  final String? displayName;

  /// Optional description.
  final String? description;

  /// Docker image name.
  final String? imageName;

  /// Docker image tag.
  final String? imageTag;

  /// Docker command to run.
  final String? command;

  /// Working directory inside the container.
  final String? workingDir;

  /// JSON-encoded environment variables map.
  final String? envVarsJson;

  /// JSON-encoded port mappings.
  final String? portsJson;

  /// Health check command.
  final String? healthCheckCommand;

  /// Health check interval in seconds.
  final int? healthCheckIntervalSeconds;

  /// Health check timeout in seconds.
  final int? healthCheckTimeoutSeconds;

  /// Number of health check retries.
  final int? healthCheckRetries;

  /// Docker restart policy.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicy;

  /// Memory limit in megabytes.
  final int? memoryLimitMb;

  /// CPU limit (fraction of cores).
  final double? cpuLimit;

  /// Whether this profile was auto-generated from a service registration.
  final bool? isAutoGenerated;

  /// Whether this profile is enabled.
  final bool? isEnabled;

  /// Start order within a solution.
  final int? startOrder;

  /// UUID of the linked service registration.
  final String? serviceRegistrationId;

  /// UUID of the owning team.
  final String? teamId;

  /// Volume mounts for this profile.
  final List<FleetVolumeMount>? volumes;

  /// Network configurations for this profile.
  final List<FleetNetworkConfig>? networks;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [FleetServiceProfileDetail].
  const FleetServiceProfileDetail({
    this.id,
    this.serviceName,
    this.displayName,
    this.description,
    this.imageName,
    this.imageTag,
    this.command,
    this.workingDir,
    this.envVarsJson,
    this.portsJson,
    this.healthCheckCommand,
    this.healthCheckIntervalSeconds,
    this.healthCheckTimeoutSeconds,
    this.healthCheckRetries,
    this.restartPolicy,
    this.memoryLimitMb,
    this.cpuLimit,
    this.isAutoGenerated,
    this.isEnabled,
    this.startOrder,
    this.serviceRegistrationId,
    this.teamId,
    this.volumes,
    this.networks,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [FleetServiceProfileDetail] from a JSON map.
  factory FleetServiceProfileDetail.fromJson(Map<String, dynamic> json) =>
      _$FleetServiceProfileDetailFromJson(json);

  /// Serializes this [FleetServiceProfileDetail] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetServiceProfileDetailToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Solution Profiles
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight solution profile response for list views.
@JsonSerializable()
class FleetSolutionProfile {
  /// Unique identifier (UUID).
  final String? id;

  /// Solution name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the default solution.
  final bool? isDefault;

  /// Number of services in this solution.
  final int? serviceCount;

  /// UUID of the owning team.
  final String? teamId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [FleetSolutionProfile].
  const FleetSolutionProfile({
    this.id,
    this.name,
    this.description,
    this.isDefault,
    this.serviceCount,
    this.teamId,
    this.createdAt,
  });

  /// Deserializes a [FleetSolutionProfile] from a JSON map.
  factory FleetSolutionProfile.fromJson(Map<String, dynamic> json) =>
      _$FleetSolutionProfileFromJson(json);

  /// Serializes this [FleetSolutionProfile] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetSolutionProfileToJson(this);
}

/// Full solution profile detail response including services.
@JsonSerializable(explicitToJson: true)
class FleetSolutionProfileDetail {
  /// Unique identifier (UUID).
  final String? id;

  /// Solution name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the default solution.
  final bool? isDefault;

  /// UUID of the owning team.
  final String? teamId;

  /// Services in this solution.
  final List<FleetSolutionService>? services;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [FleetSolutionProfileDetail].
  const FleetSolutionProfileDetail({
    this.id,
    this.name,
    this.description,
    this.isDefault,
    this.teamId,
    this.services,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [FleetSolutionProfileDetail] from a JSON map.
  factory FleetSolutionProfileDetail.fromJson(Map<String, dynamic> json) =>
      _$FleetSolutionProfileDetailFromJson(json);

  /// Serializes this [FleetSolutionProfileDetail] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetSolutionProfileDetailToJson(this);
}

/// Response for a service within a solution profile.
@JsonSerializable()
class FleetSolutionService {
  /// Unique identifier (UUID).
  final String? id;

  /// Start order within the solution.
  final int? startOrder;

  /// UUID of the service profile.
  final String? serviceProfileId;

  /// Name of the service profile.
  final String? serviceProfileName;

  /// Docker image name.
  final String? imageName;

  /// Whether this service is enabled.
  final bool? isEnabled;

  /// Creates a [FleetSolutionService].
  const FleetSolutionService({
    this.id,
    this.startOrder,
    this.serviceProfileId,
    this.serviceProfileName,
    this.imageName,
    this.isEnabled,
  });

  /// Deserializes a [FleetSolutionService] from a JSON map.
  factory FleetSolutionService.fromJson(Map<String, dynamic> json) =>
      _$FleetSolutionServiceFromJson(json);

  /// Serializes this [FleetSolutionService] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetSolutionServiceToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Workstation Profiles
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight workstation profile response for list views.
@JsonSerializable()
class FleetWorkstationProfile {
  /// Unique identifier (UUID).
  final String? id;

  /// Workstation profile name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the default workstation profile.
  final bool? isDefault;

  /// Number of solutions in this workstation.
  final int? solutionCount;

  /// UUID of the owning user.
  final String? userId;

  /// UUID of the owning team.
  final String? teamId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [FleetWorkstationProfile].
  const FleetWorkstationProfile({
    this.id,
    this.name,
    this.description,
    this.isDefault,
    this.solutionCount,
    this.userId,
    this.teamId,
    this.createdAt,
  });

  /// Deserializes a [FleetWorkstationProfile] from a JSON map.
  factory FleetWorkstationProfile.fromJson(Map<String, dynamic> json) =>
      _$FleetWorkstationProfileFromJson(json);

  /// Serializes this [FleetWorkstationProfile] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetWorkstationProfileToJson(this);
}

/// Full workstation profile detail response including solutions.
@JsonSerializable(explicitToJson: true)
class FleetWorkstationProfileDetail {
  /// Unique identifier (UUID).
  final String? id;

  /// Workstation profile name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the default workstation profile.
  final bool? isDefault;

  /// UUID of the owning user.
  final String? userId;

  /// UUID of the owning team.
  final String? teamId;

  /// Solutions in this workstation.
  final List<FleetWorkstationSolution>? solutions;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [FleetWorkstationProfileDetail].
  const FleetWorkstationProfileDetail({
    this.id,
    this.name,
    this.description,
    this.isDefault,
    this.userId,
    this.teamId,
    this.solutions,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [FleetWorkstationProfileDetail] from a JSON map.
  factory FleetWorkstationProfileDetail.fromJson(Map<String, dynamic> json) =>
      _$FleetWorkstationProfileDetailFromJson(json);

  /// Serializes this [FleetWorkstationProfileDetail] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$FleetWorkstationProfileDetailToJson(this);
}

/// Response for a solution within a workstation profile.
@JsonSerializable()
class FleetWorkstationSolution {
  /// Unique identifier (UUID).
  final String? id;

  /// Start order within the workstation.
  final int? startOrder;

  /// JSON-encoded environment variable overrides.
  final String? overrideEnvVarsJson;

  /// UUID of the solution profile.
  final String? solutionProfileId;

  /// Name of the solution profile.
  final String? solutionProfileName;

  /// Creates a [FleetWorkstationSolution].
  const FleetWorkstationSolution({
    this.id,
    this.startOrder,
    this.overrideEnvVarsJson,
    this.solutionProfileId,
    this.solutionProfileName,
  });

  /// Deserializes a [FleetWorkstationSolution] from a JSON map.
  factory FleetWorkstationSolution.fromJson(Map<String, dynamic> json) =>
      _$FleetWorkstationSolutionFromJson(json);

  /// Serializes this [FleetWorkstationSolution] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetWorkstationSolutionToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Health
// ─────────────────────────────────────────────────────────────────────────────

/// Aggregated fleet health summary across all containers in a team.
@JsonSerializable()
class FleetHealthSummary {
  /// Total number of containers.
  final int? totalContainers;

  /// Number of running containers.
  final int? runningContainers;

  /// Number of stopped containers.
  final int? stoppedContainers;

  /// Number of unhealthy containers.
  final int? unhealthyContainers;

  /// Number of restarting containers.
  final int? restartingContainers;

  /// Total CPU usage percentage across all containers.
  final double? totalCpuPercent;

  /// Total memory usage in bytes across all containers.
  final int? totalMemoryBytes;

  /// Total memory limit in bytes across all containers.
  final int? totalMemoryLimitBytes;

  /// Timestamp when the summary was generated.
  final DateTime? timestamp;

  /// Creates a [FleetHealthSummary].
  const FleetHealthSummary({
    this.totalContainers,
    this.runningContainers,
    this.stoppedContainers,
    this.unhealthyContainers,
    this.restartingContainers,
    this.totalCpuPercent,
    this.totalMemoryBytes,
    this.totalMemoryLimitBytes,
    this.timestamp,
  });

  /// Deserializes a [FleetHealthSummary] from a JSON map.
  factory FleetHealthSummary.fromJson(Map<String, dynamic> json) =>
      _$FleetHealthSummaryFromJson(json);

  /// Serializes this [FleetHealthSummary] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetHealthSummaryToJson(this);
}

/// Health check result response for a container instance.
@JsonSerializable()
class FleetContainerHealthCheck {
  /// Unique identifier (UUID).
  final String? id;

  /// Health check result status.
  @HealthStatusConverter()
  final HealthStatus? status;

  /// Health check output text.
  final String? output;

  /// Health check exit code.
  final int? exitCode;

  /// Health check duration in milliseconds.
  final int? durationMs;

  /// UUID of the container that was checked.
  final String? containerId;

  /// Timestamp when the health check was performed.
  final DateTime? createdAt;

  /// Creates a [FleetContainerHealthCheck].
  const FleetContainerHealthCheck({
    this.id,
    this.status,
    this.output,
    this.exitCode,
    this.durationMs,
    this.containerId,
    this.createdAt,
  });

  /// Deserializes a [FleetContainerHealthCheck] from a JSON map.
  factory FleetContainerHealthCheck.fromJson(Map<String, dynamic> json) =>
      _$FleetContainerHealthCheckFromJson(json);

  /// Serializes this [FleetContainerHealthCheck] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetContainerHealthCheckToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Logs & Stats
// ─────────────────────────────────────────────────────────────────────────────

/// Container log entry response.
@JsonSerializable()
class FleetContainerLog {
  /// Unique identifier (UUID).
  final String? id;

  /// Log stream (stdout/stderr).
  final String? stream;

  /// Log content text.
  final String? content;

  /// Timestamp of the log entry.
  final DateTime? timestamp;

  /// UUID of the container.
  final String? containerId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [FleetContainerLog].
  const FleetContainerLog({
    this.id,
    this.stream,
    this.content,
    this.timestamp,
    this.containerId,
    this.createdAt,
  });

  /// Deserializes a [FleetContainerLog] from a JSON map.
  factory FleetContainerLog.fromJson(Map<String, dynamic> json) =>
      _$FleetContainerLogFromJson(json);

  /// Serializes this [FleetContainerLog] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetContainerLogToJson(this);
}

/// Real-time container resource statistics response.
@JsonSerializable()
class FleetContainerStats {
  /// UUID of the container.
  final String? containerId;

  /// Docker container name.
  final String? containerName;

  /// Current CPU usage percentage.
  final double? cpuPercent;

  /// Current memory usage in bytes.
  final int? memoryUsageBytes;

  /// Memory limit in bytes.
  final int? memoryLimitBytes;

  /// Network bytes received.
  final int? networkRxBytes;

  /// Network bytes transmitted.
  final int? networkTxBytes;

  /// Block device bytes read.
  final int? blockReadBytes;

  /// Block device bytes written.
  final int? blockWriteBytes;

  /// Number of running processes.
  final int? pids;

  /// Timestamp of the stats snapshot.
  final DateTime? timestamp;

  /// Creates a [FleetContainerStats].
  const FleetContainerStats({
    this.containerId,
    this.containerName,
    this.cpuPercent,
    this.memoryUsageBytes,
    this.memoryLimitBytes,
    this.networkRxBytes,
    this.networkTxBytes,
    this.blockReadBytes,
    this.blockWriteBytes,
    this.pids,
    this.timestamp,
  });

  /// Deserializes a [FleetContainerStats] from a JSON map.
  factory FleetContainerStats.fromJson(Map<String, dynamic> json) =>
      _$FleetContainerStatsFromJson(json);

  /// Serializes this [FleetContainerStats] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetContainerStatsToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Docker Resources
// ─────────────────────────────────────────────────────────────────────────────

/// Docker image metadata response.
@JsonSerializable()
class FleetDockerImage {
  /// Image ID.
  final String? id;

  /// Repository tags (e.g., ["nginx:latest"]).
  final List<String>? repoTags;

  /// Image size in bytes.
  final int? sizeBytes;

  /// Timestamp when the image was created.
  final DateTime? created;

  /// Creates a [FleetDockerImage].
  const FleetDockerImage({
    this.id,
    this.repoTags,
    this.sizeBytes,
    this.created,
  });

  /// Deserializes a [FleetDockerImage] from a JSON map.
  factory FleetDockerImage.fromJson(Map<String, dynamic> json) =>
      _$FleetDockerImageFromJson(json);

  /// Serializes this [FleetDockerImage] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetDockerImageToJson(this);
}

/// Docker volume metadata response.
@JsonSerializable()
class FleetDockerVolume {
  /// Volume name.
  final String? name;

  /// Volume driver.
  final String? driver;

  /// Volume mountpoint path.
  final String? mountpoint;

  /// Volume labels.
  final Map<String, String>? labels;

  /// Timestamp when the volume was created.
  final DateTime? createdAt;

  /// Creates a [FleetDockerVolume].
  const FleetDockerVolume({
    this.name,
    this.driver,
    this.mountpoint,
    this.labels,
    this.createdAt,
  });

  /// Deserializes a [FleetDockerVolume] from a JSON map.
  factory FleetDockerVolume.fromJson(Map<String, dynamic> json) =>
      _$FleetDockerVolumeFromJson(json);

  /// Serializes this [FleetDockerVolume] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetDockerVolumeToJson(this);
}

/// Docker network metadata response.
@JsonSerializable()
class FleetDockerNetwork {
  /// Network ID.
  final String? id;

  /// Network name.
  final String? name;

  /// Network driver.
  final String? driver;

  /// Subnet CIDR.
  final String? subnet;

  /// Gateway address.
  final String? gateway;

  /// IDs of containers connected to this network.
  final List<String>? connectedContainers;

  /// Creates a [FleetDockerNetwork].
  const FleetDockerNetwork({
    this.id,
    this.name,
    this.driver,
    this.subnet,
    this.gateway,
    this.connectedContainers,
  });

  /// Deserializes a [FleetDockerNetwork] from a JSON map.
  factory FleetDockerNetwork.fromJson(Map<String, dynamic> json) =>
      _$FleetDockerNetworkFromJson(json);

  /// Serializes this [FleetDockerNetwork] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetDockerNetworkToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Volume & Network Config
// ─────────────────────────────────────────────────────────────────────────────

/// Volume mount configuration response.
@JsonSerializable()
class FleetVolumeMount {
  /// Unique identifier (UUID).
  final String? id;

  /// Host path for the volume mount.
  final String? hostPath;

  /// Container path for the volume mount.
  final String? containerPath;

  /// Named volume name.
  final String? volumeName;

  /// Whether the mount is read-only.
  final bool? isReadOnly;

  /// Creates a [FleetVolumeMount].
  const FleetVolumeMount({
    this.id,
    this.hostPath,
    this.containerPath,
    this.volumeName,
    this.isReadOnly,
  });

  /// Deserializes a [FleetVolumeMount] from a JSON map.
  factory FleetVolumeMount.fromJson(Map<String, dynamic> json) =>
      _$FleetVolumeMountFromJson(json);

  /// Serializes this [FleetVolumeMount] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetVolumeMountToJson(this);
}

/// Network configuration response.
@JsonSerializable()
class FleetNetworkConfig {
  /// Unique identifier (UUID).
  final String? id;

  /// Docker network name.
  final String? networkName;

  /// Network aliases.
  final String? aliases;

  /// IP address assignment.
  final String? ipAddress;

  /// Creates a [FleetNetworkConfig].
  const FleetNetworkConfig({
    this.id,
    this.networkName,
    this.aliases,
    this.ipAddress,
  });

  /// Deserializes a [FleetNetworkConfig] from a JSON map.
  factory FleetNetworkConfig.fromJson(Map<String, dynamic> json) =>
      _$FleetNetworkConfigFromJson(json);

  /// Serializes this [FleetNetworkConfig] to a JSON map.
  Map<String, dynamic> toJson() => _$FleetNetworkConfigToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Request DTOs
// ─────────────────────────────────────────────────────────────────────────────

/// Request to start a container from a service profile.
@JsonSerializable()
class StartContainerRequest {
  /// UUID of the service profile to start.
  final String serviceProfileId;

  /// Optional container name override.
  final String? containerNameOverride;

  /// Optional image tag override.
  final String? imageTagOverride;

  /// Optional environment variable overrides.
  final Map<String, String>? envVarOverrides;

  /// Optional restart policy override.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicyOverride;

  /// Creates a [StartContainerRequest].
  const StartContainerRequest({
    required this.serviceProfileId,
    this.containerNameOverride,
    this.imageTagOverride,
    this.envVarOverrides,
    this.restartPolicyOverride,
  });

  /// Deserializes a [StartContainerRequest] from a JSON map.
  factory StartContainerRequest.fromJson(Map<String, dynamic> json) =>
      _$StartContainerRequestFromJson(json);

  /// Serializes this [StartContainerRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$StartContainerRequestToJson(this);
}

/// Request to execute a command inside a running container.
@JsonSerializable()
class ContainerExecRequest {
  /// Command to execute.
  final String command;

  /// Whether to attach stdout.
  final bool? attachStdout;

  /// Whether to attach stderr.
  final bool? attachStderr;

  /// Creates a [ContainerExecRequest].
  const ContainerExecRequest({
    required this.command,
    this.attachStdout,
    this.attachStderr,
  });

  /// Deserializes a [ContainerExecRequest] from a JSON map.
  factory ContainerExecRequest.fromJson(Map<String, dynamic> json) =>
      _$ContainerExecRequestFromJson(json);

  /// Serializes this [ContainerExecRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$ContainerExecRequestToJson(this);
}

/// Request to create a new service profile.
@JsonSerializable()
class CreateServiceProfileRequest {
  /// Service name (required).
  final String serviceName;

  /// Docker image name (required).
  final String imageName;

  /// Human-readable display name.
  final String? displayName;

  /// Optional description.
  final String? description;

  /// Docker image tag.
  final String? imageTag;

  /// Docker command to run.
  final String? command;

  /// Working directory inside the container.
  final String? workingDir;

  /// JSON-encoded environment variables map.
  final String? envVarsJson;

  /// JSON-encoded port mappings.
  final String? portsJson;

  /// Health check command.
  final String? healthCheckCommand;

  /// Health check interval in seconds.
  final int? healthCheckIntervalSeconds;

  /// Health check timeout in seconds.
  final int? healthCheckTimeoutSeconds;

  /// Number of health check retries.
  final int? healthCheckRetries;

  /// Docker restart policy.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicy;

  /// Memory limit in megabytes.
  final int? memoryLimitMb;

  /// CPU limit (fraction of cores).
  final double? cpuLimit;

  /// Start order within a solution.
  final int? startOrder;

  /// UUID of the linked service registration.
  final String? serviceRegistrationId;

  /// Creates a [CreateServiceProfileRequest].
  const CreateServiceProfileRequest({
    required this.serviceName,
    required this.imageName,
    this.displayName,
    this.description,
    this.imageTag,
    this.command,
    this.workingDir,
    this.envVarsJson,
    this.portsJson,
    this.healthCheckCommand,
    this.healthCheckIntervalSeconds,
    this.healthCheckTimeoutSeconds,
    this.healthCheckRetries,
    this.restartPolicy,
    this.memoryLimitMb,
    this.cpuLimit,
    this.startOrder,
    this.serviceRegistrationId,
  });

  /// Deserializes a [CreateServiceProfileRequest] from a JSON map.
  factory CreateServiceProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateServiceProfileRequestFromJson(json);

  /// Serializes this [CreateServiceProfileRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateServiceProfileRequestToJson(this);
}

/// Request to update an existing service profile.
@JsonSerializable()
class UpdateServiceProfileRequest {
  /// Human-readable display name.
  final String? displayName;

  /// Optional description.
  final String? description;

  /// Docker image name.
  final String? imageName;

  /// Docker image tag.
  final String? imageTag;

  /// Docker command to run.
  final String? command;

  /// Working directory inside the container.
  final String? workingDir;

  /// JSON-encoded environment variables map.
  final String? envVarsJson;

  /// JSON-encoded port mappings.
  final String? portsJson;

  /// Health check command.
  final String? healthCheckCommand;

  /// Health check interval in seconds.
  final int? healthCheckIntervalSeconds;

  /// Health check timeout in seconds.
  final int? healthCheckTimeoutSeconds;

  /// Number of health check retries.
  final int? healthCheckRetries;

  /// Docker restart policy.
  @RestartPolicyConverter()
  final RestartPolicy? restartPolicy;

  /// Memory limit in megabytes.
  final int? memoryLimitMb;

  /// CPU limit (fraction of cores).
  final double? cpuLimit;

  /// Whether this profile is enabled.
  final bool? isEnabled;

  /// Start order within a solution.
  final int? startOrder;

  /// Creates an [UpdateServiceProfileRequest].
  const UpdateServiceProfileRequest({
    this.displayName,
    this.description,
    this.imageName,
    this.imageTag,
    this.command,
    this.workingDir,
    this.envVarsJson,
    this.portsJson,
    this.healthCheckCommand,
    this.healthCheckIntervalSeconds,
    this.healthCheckTimeoutSeconds,
    this.healthCheckRetries,
    this.restartPolicy,
    this.memoryLimitMb,
    this.cpuLimit,
    this.isEnabled,
    this.startOrder,
  });

  /// Deserializes an [UpdateServiceProfileRequest] from a JSON map.
  factory UpdateServiceProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateServiceProfileRequestFromJson(json);

  /// Serializes this [UpdateServiceProfileRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$UpdateServiceProfileRequestToJson(this);
}

/// Request to create a new solution profile.
@JsonSerializable()
class CreateSolutionProfileRequest {
  /// Solution name (required).
  final String name;

  /// Optional description.
  final String? description;

  /// Whether this is the default solution.
  final bool? isDefault;

  /// Creates a [CreateSolutionProfileRequest].
  const CreateSolutionProfileRequest({
    required this.name,
    this.description,
    this.isDefault,
  });

  /// Deserializes a [CreateSolutionProfileRequest] from a JSON map.
  factory CreateSolutionProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSolutionProfileRequestFromJson(json);

  /// Serializes this [CreateSolutionProfileRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$CreateSolutionProfileRequestToJson(this);
}

/// Request to update an existing solution profile.
@JsonSerializable()
class UpdateSolutionProfileRequest {
  /// Solution name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the default solution.
  final bool? isDefault;

  /// Creates an [UpdateSolutionProfileRequest].
  const UpdateSolutionProfileRequest({
    this.name,
    this.description,
    this.isDefault,
  });

  /// Deserializes an [UpdateSolutionProfileRequest] from a JSON map.
  factory UpdateSolutionProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSolutionProfileRequestFromJson(json);

  /// Serializes this [UpdateSolutionProfileRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$UpdateSolutionProfileRequestToJson(this);
}

/// Request to add a service profile to a solution profile.
@JsonSerializable()
class AddSolutionServiceRequest {
  /// UUID of the service profile to add.
  final String serviceProfileId;

  /// Start order within the solution.
  final int? startOrder;

  /// Creates an [AddSolutionServiceRequest].
  const AddSolutionServiceRequest({
    required this.serviceProfileId,
    this.startOrder,
  });

  /// Deserializes an [AddSolutionServiceRequest] from a JSON map.
  factory AddSolutionServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$AddSolutionServiceRequestFromJson(json);

  /// Serializes this [AddSolutionServiceRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$AddSolutionServiceRequestToJson(this);
}

/// Request to create a new workstation profile.
@JsonSerializable()
class CreateWorkstationProfileRequest {
  /// Workstation profile name (required).
  final String name;

  /// Optional description.
  final String? description;

  /// Whether this is the default workstation profile.
  final bool? isDefault;

  /// Creates a [CreateWorkstationProfileRequest].
  const CreateWorkstationProfileRequest({
    required this.name,
    this.description,
    this.isDefault,
  });

  /// Deserializes a [CreateWorkstationProfileRequest] from a JSON map.
  factory CreateWorkstationProfileRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CreateWorkstationProfileRequestFromJson(json);

  /// Serializes this [CreateWorkstationProfileRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$CreateWorkstationProfileRequestToJson(this);
}

/// Request to update an existing workstation profile.
@JsonSerializable()
class UpdateWorkstationProfileRequest {
  /// Workstation profile name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the default workstation profile.
  final bool? isDefault;

  /// Creates an [UpdateWorkstationProfileRequest].
  const UpdateWorkstationProfileRequest({
    this.name,
    this.description,
    this.isDefault,
  });

  /// Deserializes an [UpdateWorkstationProfileRequest] from a JSON map.
  factory UpdateWorkstationProfileRequest.fromJson(
          Map<String, dynamic> json) =>
      _$UpdateWorkstationProfileRequestFromJson(json);

  /// Serializes this [UpdateWorkstationProfileRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$UpdateWorkstationProfileRequestToJson(this);
}

/// Request to add a solution profile to a workstation profile.
@JsonSerializable()
class AddWorkstationSolutionRequest {
  /// UUID of the solution profile to add.
  final String solutionProfileId;

  /// Start order within the workstation.
  final int? startOrder;

  /// JSON-encoded environment variable overrides.
  final String? overrideEnvVarsJson;

  /// Creates an [AddWorkstationSolutionRequest].
  const AddWorkstationSolutionRequest({
    required this.solutionProfileId,
    this.startOrder,
    this.overrideEnvVarsJson,
  });

  /// Deserializes an [AddWorkstationSolutionRequest] from a JSON map.
  factory AddWorkstationSolutionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$AddWorkstationSolutionRequestFromJson(json);

  /// Serializes this [AddWorkstationSolutionRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$AddWorkstationSolutionRequestToJson(this);
}

/// Request to create a volume mount for a service profile.
@JsonSerializable()
class CreateVolumeMountRequest {
  /// Container path for the volume mount (required).
  final String containerPath;

  /// Host path for the volume mount.
  final String? hostPath;

  /// Named volume name.
  final String? volumeName;

  /// Whether the mount is read-only.
  final bool? isReadOnly;

  /// Creates a [CreateVolumeMountRequest].
  const CreateVolumeMountRequest({
    required this.containerPath,
    this.hostPath,
    this.volumeName,
    this.isReadOnly,
  });

  /// Deserializes a [CreateVolumeMountRequest] from a JSON map.
  factory CreateVolumeMountRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVolumeMountRequestFromJson(json);

  /// Serializes this [CreateVolumeMountRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateVolumeMountRequestToJson(this);
}

/// Request to create a network configuration for a service profile.
@JsonSerializable()
class CreateNetworkConfigRequest {
  /// Docker network name (required).
  final String networkName;

  /// Network aliases.
  final String? aliases;

  /// IP address assignment.
  final String? ipAddress;

  /// Creates a [CreateNetworkConfigRequest].
  const CreateNetworkConfigRequest({
    required this.networkName,
    this.aliases,
    this.ipAddress,
  });

  /// Deserializes a [CreateNetworkConfigRequest] from a JSON map.
  factory CreateNetworkConfigRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateNetworkConfigRequestFromJson(json);

  /// Serializes this [CreateNetworkConfigRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateNetworkConfigRequestToJson(this);
}
