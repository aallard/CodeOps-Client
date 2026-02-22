/// Registry response and request model classes.
///
/// Maps to the DTOs defined in CodeOps-Registry-OpenAPI.yaml.
/// All response models use [JsonSerializable] with generated
/// `fromJson` / `toJson` methods via build_runner.
library;

import 'package:json_annotation/json_annotation.dart';

import 'registry_enums.dart';

part 'registry_models.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Service responses
// ═════════════════════════════════════════════════════════════════════════════

/// A registered service in the Registry.
@JsonSerializable()
class ServiceRegistrationResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the owning team.
  final String teamId;

  /// Service display name.
  final String name;

  /// URL-friendly slug.
  final String slug;

  /// Technology type of the service.
  @ServiceTypeConverter()
  final ServiceType serviceType;

  /// Optional description.
  final String? description;

  /// Repository URL.
  final String? repoUrl;

  /// Repository full name (e.g., "org/repo").
  final String? repoFullName;

  /// Default branch name.
  final String? defaultBranch;

  /// Tech stack description.
  final String? techStack;

  /// Lifecycle status of the service.
  @ServiceStatusConverter()
  final ServiceStatus status;

  /// Health check URL.
  final String? healthCheckUrl;

  /// Health check interval in seconds.
  final int? healthCheckIntervalSeconds;

  /// Last known health status.
  @HealthStatusConverter()
  final HealthStatus? lastHealthStatus;

  /// Timestamp of the last health check.
  final DateTime? lastHealthCheckAt;

  /// JSON string of environment configurations.
  final String? environmentsJson;

  /// JSON string of metadata key-value pairs.
  final String? metadataJson;

  /// UUID of the user who created this service.
  final String? createdByUserId;

  /// Number of allocated ports.
  final int? portCount;

  /// Number of dependencies.
  final int? dependencyCount;

  /// Number of solutions this service belongs to.
  final int? solutionCount;

  /// Timestamp when the service was created.
  final DateTime? createdAt;

  /// Timestamp when the service was last updated.
  final DateTime? updatedAt;

  /// Creates a [ServiceRegistrationResponse] instance.
  const ServiceRegistrationResponse({
    required this.id,
    required this.teamId,
    required this.name,
    required this.slug,
    required this.serviceType,
    this.description,
    this.repoUrl,
    this.repoFullName,
    this.defaultBranch,
    this.techStack,
    required this.status,
    this.healthCheckUrl,
    this.healthCheckIntervalSeconds,
    this.lastHealthStatus,
    this.lastHealthCheckAt,
    this.environmentsJson,
    this.metadataJson,
    this.createdByUserId,
    this.portCount,
    this.dependencyCount,
    this.solutionCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory ServiceRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceRegistrationResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ServiceRegistrationResponseToJson(this);
}

/// Full service identity including ports, deps, routes, infra, and configs.
@JsonSerializable()
class ServiceIdentityResponse {
  /// The service registration data.
  final ServiceRegistrationResponse service;

  /// Port allocations for the service.
  final List<PortAllocationResponse> ports;

  /// Services this service depends on.
  final List<ServiceDependencyResponse> upstreamDependencies;

  /// Services that depend on this service.
  final List<ServiceDependencyResponse> downstreamDependencies;

  /// API routes for the service.
  final List<ApiRouteResponse> routes;

  /// Infrastructure resources for the service.
  final List<InfraResourceResponse> infraResources;

  /// Environment configurations for the service.
  final List<EnvironmentConfigResponse> environmentConfigs;

  /// Creates a [ServiceIdentityResponse] instance.
  const ServiceIdentityResponse({
    required this.service,
    required this.ports,
    required this.upstreamDependencies,
    required this.downstreamDependencies,
    required this.routes,
    required this.infraResources,
    required this.environmentConfigs,
  });

  /// Deserializes from a JSON map.
  factory ServiceIdentityResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceIdentityResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ServiceIdentityResponseToJson(this);
}

/// Health status of a single service.
@JsonSerializable()
class ServiceHealthResponse {
  /// UUID of the service.
  final String serviceId;

  /// Service display name.
  final String name;

  /// URL-friendly slug.
  final String slug;

  /// Current health status.
  @HealthStatusConverter()
  final HealthStatus healthStatus;

  /// Timestamp of the last health check.
  final DateTime? lastCheckAt;

  /// Health check URL.
  final String? healthCheckUrl;

  /// Response time in milliseconds.
  final int? responseTimeMs;

  /// Error message if health check failed.
  final String? errorMessage;

  /// Creates a [ServiceHealthResponse] instance.
  const ServiceHealthResponse({
    required this.serviceId,
    required this.name,
    required this.slug,
    required this.healthStatus,
    this.lastCheckAt,
    this.healthCheckUrl,
    this.responseTimeMs,
    this.errorMessage,
  });

  /// Deserializes from a JSON map.
  factory ServiceHealthResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceHealthResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ServiceHealthResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Solution responses
// ═════════════════════════════════════════════════════════════════════════════

/// A solution grouping of services.
@JsonSerializable()
class SolutionResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the owning team.
  final String teamId;

  /// Solution display name.
  final String name;

  /// URL-friendly slug.
  final String slug;

  /// Optional description.
  final String? description;

  /// Solution category.
  @SolutionCategoryConverter()
  final SolutionCategory category;

  /// Lifecycle status.
  @SolutionStatusConverter()
  final SolutionStatus status;

  /// Icon name for UI display.
  final String? iconName;

  /// Hex color code for UI display.
  final String? colorHex;

  /// UUID of the solution owner.
  final String? ownerUserId;

  /// Repository URL.
  final String? repositoryUrl;

  /// Documentation URL.
  final String? documentationUrl;

  /// JSON string of metadata.
  final String? metadataJson;

  /// UUID of the user who created this solution.
  final String? createdByUserId;

  /// Number of members in the solution.
  final int? memberCount;

  /// Timestamp when the solution was created.
  final DateTime? createdAt;

  /// Timestamp when the solution was last updated.
  final DateTime? updatedAt;

  /// Creates a [SolutionResponse] instance.
  const SolutionResponse({
    required this.id,
    required this.teamId,
    required this.name,
    required this.slug,
    this.description,
    required this.category,
    required this.status,
    this.iconName,
    this.colorHex,
    this.ownerUserId,
    this.repositoryUrl,
    this.documentationUrl,
    this.metadataJson,
    this.createdByUserId,
    this.memberCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory SolutionResponse.fromJson(Map<String, dynamic> json) =>
      _$SolutionResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$SolutionResponseToJson(this);
}

/// Detailed solution response including member list.
@JsonSerializable()
class SolutionDetailResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the owning team.
  final String teamId;

  /// Solution display name.
  final String name;

  /// URL-friendly slug.
  final String slug;

  /// Optional description.
  final String? description;

  /// Solution category.
  @SolutionCategoryConverter()
  final SolutionCategory category;

  /// Lifecycle status.
  @SolutionStatusConverter()
  final SolutionStatus status;

  /// Icon name for UI display.
  final String? iconName;

  /// Hex color code for UI display.
  final String? colorHex;

  /// UUID of the solution owner.
  final String? ownerUserId;

  /// Repository URL.
  final String? repositoryUrl;

  /// Documentation URL.
  final String? documentationUrl;

  /// JSON string of metadata.
  final String? metadataJson;

  /// UUID of the user who created this solution.
  final String? createdByUserId;

  /// Member services in the solution.
  final List<SolutionMemberResponse> members;

  /// Timestamp when the solution was created.
  final DateTime? createdAt;

  /// Timestamp when the solution was last updated.
  final DateTime? updatedAt;

  /// Creates a [SolutionDetailResponse] instance.
  const SolutionDetailResponse({
    required this.id,
    required this.teamId,
    required this.name,
    required this.slug,
    this.description,
    required this.category,
    required this.status,
    this.iconName,
    this.colorHex,
    this.ownerUserId,
    this.repositoryUrl,
    this.documentationUrl,
    this.metadataJson,
    this.createdByUserId,
    required this.members,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory SolutionDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$SolutionDetailResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$SolutionDetailResponseToJson(this);
}

/// A service member within a solution.
@JsonSerializable()
class SolutionMemberResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the solution.
  final String solutionId;

  /// UUID of the member service.
  final String serviceId;

  /// Service display name.
  final String? serviceName;

  /// Service URL-friendly slug.
  final String? serviceSlug;

  /// Service technology type.
  @ServiceTypeConverter()
  final ServiceType? serviceType;

  /// Service lifecycle status.
  @ServiceStatusConverter()
  final ServiceStatus? serviceStatus;

  /// Service health status.
  @HealthStatusConverter()
  final HealthStatus? serviceHealthStatus;

  /// Role of the service in the solution.
  @SolutionMemberRoleConverter()
  final SolutionMemberRole role;

  /// Display order in the solution.
  final int? displayOrder;

  /// Optional notes.
  final String? notes;

  /// Creates a [SolutionMemberResponse] instance.
  const SolutionMemberResponse({
    required this.id,
    required this.solutionId,
    required this.serviceId,
    this.serviceName,
    this.serviceSlug,
    this.serviceType,
    this.serviceStatus,
    this.serviceHealthStatus,
    required this.role,
    this.displayOrder,
    this.notes,
  });

  /// Deserializes from a JSON map.
  factory SolutionMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$SolutionMemberResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$SolutionMemberResponseToJson(this);
}

/// Health summary for a solution.
@JsonSerializable()
class SolutionHealthResponse {
  /// UUID of the solution.
  final String solutionId;

  /// Solution display name.
  final String solutionName;

  /// Total services in the solution.
  final int totalServices;

  /// Number of healthy services.
  final int servicesUp;

  /// Number of down services.
  final int servicesDown;

  /// Number of degraded services.
  final int servicesDegraded;

  /// Number of services with unknown health.
  final int servicesUnknown;

  /// Aggregated health status.
  @HealthStatusConverter()
  final HealthStatus aggregatedHealth;

  /// Health status of each service.
  final List<ServiceHealthResponse> serviceHealths;

  /// Creates a [SolutionHealthResponse] instance.
  const SolutionHealthResponse({
    required this.solutionId,
    required this.solutionName,
    required this.totalServices,
    required this.servicesUp,
    required this.servicesDown,
    required this.servicesDegraded,
    required this.servicesUnknown,
    required this.aggregatedHealth,
    required this.serviceHealths,
  });

  /// Deserializes from a JSON map.
  factory SolutionHealthResponse.fromJson(Map<String, dynamic> json) =>
      _$SolutionHealthResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$SolutionHealthResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Port responses
// ═════════════════════════════════════════════════════════════════════════════

/// A port allocation for a service.
@JsonSerializable()
class PortAllocationResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the service.
  final String serviceId;

  /// Service display name.
  final String? serviceName;

  /// Service URL-friendly slug.
  final String? serviceSlug;

  /// Environment name.
  final String environment;

  /// Port type.
  @PortTypeConverter()
  final PortType portType;

  /// Port number.
  final int portNumber;

  /// Protocol (e.g., "TCP").
  final String? protocol;

  /// Optional description.
  final String? description;

  /// Whether the port was auto-allocated.
  final bool? isAutoAllocated;

  /// UUID of the user who allocated this port.
  final String? allocatedByUserId;

  /// Timestamp when the allocation was created.
  final DateTime? createdAt;

  /// Creates a [PortAllocationResponse] instance.
  const PortAllocationResponse({
    required this.id,
    required this.serviceId,
    this.serviceName,
    this.serviceSlug,
    required this.environment,
    required this.portType,
    required this.portNumber,
    this.protocol,
    this.description,
    this.isAutoAllocated,
    this.allocatedByUserId,
    this.createdAt,
  });

  /// Deserializes from a JSON map.
  factory PortAllocationResponse.fromJson(Map<String, dynamic> json) =>
      _$PortAllocationResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$PortAllocationResponseToJson(this);
}

/// A port range definition.
@JsonSerializable()
class PortRangeResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the team.
  final String teamId;

  /// Port type this range covers.
  @PortTypeConverter()
  final PortType portType;

  /// Start of the range (inclusive).
  final int rangeStart;

  /// End of the range (inclusive).
  final int rangeEnd;

  /// Environment name.
  final String? environment;

  /// Optional description.
  final String? description;

  /// Creates a [PortRangeResponse] instance.
  const PortRangeResponse({
    required this.id,
    required this.teamId,
    required this.portType,
    required this.rangeStart,
    required this.rangeEnd,
    this.environment,
    this.description,
  });

  /// Deserializes from a JSON map.
  factory PortRangeResponse.fromJson(Map<String, dynamic> json) =>
      _$PortRangeResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$PortRangeResponseToJson(this);
}

/// A port range with its allocations.
@JsonSerializable()
class PortRangeWithAllocationsResponse {
  /// Port type.
  @PortTypeConverter()
  final PortType portType;

  /// Start of the range (inclusive).
  final int rangeStart;

  /// End of the range (inclusive).
  final int rangeEnd;

  /// Total capacity of the range.
  final int totalCapacity;

  /// Number of allocated ports.
  final int allocated;

  /// Number of available ports.
  final int available;

  /// Port allocations within this range.
  final List<PortAllocationResponse> allocations;

  /// Creates a [PortRangeWithAllocationsResponse] instance.
  const PortRangeWithAllocationsResponse({
    required this.portType,
    required this.rangeStart,
    required this.rangeEnd,
    required this.totalCapacity,
    required this.allocated,
    required this.available,
    required this.allocations,
  });

  /// Deserializes from a JSON map.
  factory PortRangeWithAllocationsResponse.fromJson(
          Map<String, dynamic> json) =>
      _$PortRangeWithAllocationsResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() =>
      _$PortRangeWithAllocationsResponseToJson(this);
}

/// Port map for a team showing ranges and allocations.
@JsonSerializable()
class PortMapResponse {
  /// UUID of the team.
  final String teamId;

  /// Environment name.
  final String environment;

  /// Ranges with allocations.
  final List<PortRangeWithAllocationsResponse> ranges;

  /// Total allocated ports.
  final int totalAllocated;

  /// Total available ports.
  final int totalAvailable;

  /// Creates a [PortMapResponse] instance.
  const PortMapResponse({
    required this.teamId,
    required this.environment,
    required this.ranges,
    required this.totalAllocated,
    required this.totalAvailable,
  });

  /// Deserializes from a JSON map.
  factory PortMapResponse.fromJson(Map<String, dynamic> json) =>
      _$PortMapResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$PortMapResponseToJson(this);
}

/// Result of a port availability check.
@JsonSerializable()
class PortCheckResponse {
  /// Port number checked.
  final int portNumber;

  /// Environment name.
  final String environment;

  /// Whether the port is available.
  final bool available;

  /// UUID of the service currently using the port.
  final String? currentOwnerServiceId;

  /// Name of the service currently using the port.
  final String? currentOwnerServiceName;

  /// Port type of the current allocation.
  @PortTypeConverter()
  final PortType? currentOwnerPortType;

  /// Creates a [PortCheckResponse] instance.
  const PortCheckResponse({
    required this.portNumber,
    required this.environment,
    required this.available,
    this.currentOwnerServiceId,
    this.currentOwnerServiceName,
    this.currentOwnerPortType,
  });

  /// Deserializes from a JSON map.
  factory PortCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$PortCheckResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$PortCheckResponseToJson(this);
}

/// A port conflict between allocations.
@JsonSerializable()
class PortConflictResponse {
  /// Conflicting port number.
  final int portNumber;

  /// Environment name.
  final String environment;

  /// Conflicting allocations on this port.
  final List<PortAllocationResponse> conflictingAllocations;

  /// Creates a [PortConflictResponse] instance.
  const PortConflictResponse({
    required this.portNumber,
    required this.environment,
    required this.conflictingAllocations,
  });

  /// Deserializes from a JSON map.
  factory PortConflictResponse.fromJson(Map<String, dynamic> json) =>
      _$PortConflictResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$PortConflictResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Dependency responses
// ═════════════════════════════════════════════════════════════════════════════

/// A dependency between two services.
@JsonSerializable()
class ServiceDependencyResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the source (dependent) service.
  final String sourceServiceId;

  /// Name of the source service.
  final String? sourceServiceName;

  /// Slug of the source service.
  final String? sourceServiceSlug;

  /// UUID of the target (depended-upon) service.
  final String targetServiceId;

  /// Name of the target service.
  final String? targetServiceName;

  /// Slug of the target service.
  final String? targetServiceSlug;

  /// Type of dependency.
  @DependencyTypeConverter()
  final DependencyType dependencyType;

  /// Optional description.
  final String? description;

  /// Whether the dependency is required.
  final bool? isRequired;

  /// Target endpoint.
  final String? targetEndpoint;

  /// Timestamp when the dependency was created.
  final DateTime? createdAt;

  /// Creates a [ServiceDependencyResponse] instance.
  const ServiceDependencyResponse({
    required this.id,
    required this.sourceServiceId,
    this.sourceServiceName,
    this.sourceServiceSlug,
    required this.targetServiceId,
    this.targetServiceName,
    this.targetServiceSlug,
    required this.dependencyType,
    this.description,
    this.isRequired,
    this.targetEndpoint,
    this.createdAt,
  });

  /// Deserializes from a JSON map.
  factory ServiceDependencyResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceDependencyResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ServiceDependencyResponseToJson(this);
}

/// Dependency graph for a team.
@JsonSerializable()
class DependencyGraphResponse {
  /// UUID of the team.
  final String teamId;

  /// Graph nodes (services).
  final List<DependencyNodeResponse> nodes;

  /// Graph edges (dependencies).
  final List<DependencyEdgeResponse> edges;

  /// Creates a [DependencyGraphResponse] instance.
  const DependencyGraphResponse({
    required this.teamId,
    required this.nodes,
    required this.edges,
  });

  /// Deserializes from a JSON map.
  factory DependencyGraphResponse.fromJson(Map<String, dynamic> json) =>
      _$DependencyGraphResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$DependencyGraphResponseToJson(this);
}

/// A node in the dependency graph.
@JsonSerializable()
class DependencyNodeResponse {
  /// UUID of the service.
  final String serviceId;

  /// Service display name.
  final String name;

  /// Service URL-friendly slug.
  final String slug;

  /// Service technology type.
  @ServiceTypeConverter()
  final ServiceType serviceType;

  /// Service lifecycle status.
  @ServiceStatusConverter()
  final ServiceStatus status;

  /// Service health status.
  @HealthStatusConverter()
  final HealthStatus healthStatus;

  /// Creates a [DependencyNodeResponse] instance.
  const DependencyNodeResponse({
    required this.serviceId,
    required this.name,
    required this.slug,
    required this.serviceType,
    required this.status,
    required this.healthStatus,
  });

  /// Deserializes from a JSON map.
  factory DependencyNodeResponse.fromJson(Map<String, dynamic> json) =>
      _$DependencyNodeResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$DependencyNodeResponseToJson(this);
}

/// An edge in the dependency graph.
@JsonSerializable()
class DependencyEdgeResponse {
  /// UUID of the source service.
  final String sourceServiceId;

  /// UUID of the target service.
  final String targetServiceId;

  /// Dependency type.
  @DependencyTypeConverter()
  final DependencyType dependencyType;

  /// Whether the dependency is required.
  final bool? isRequired;

  /// Target endpoint.
  final String? targetEndpoint;

  /// Creates a [DependencyEdgeResponse] instance.
  const DependencyEdgeResponse({
    required this.sourceServiceId,
    required this.targetServiceId,
    required this.dependencyType,
    this.isRequired,
    this.targetEndpoint,
  });

  /// Deserializes from a JSON map.
  factory DependencyEdgeResponse.fromJson(Map<String, dynamic> json) =>
      _$DependencyEdgeResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$DependencyEdgeResponseToJson(this);
}

/// Impact analysis result for a service.
@JsonSerializable()
class ImpactAnalysisResponse {
  /// UUID of the source service.
  final String sourceServiceId;

  /// Name of the source service.
  final String sourceServiceName;

  /// Services impacted by changes to the source.
  final List<ImpactedServiceResponse> impactedServices;

  /// Total number of affected services.
  final int totalAffected;

  /// Creates an [ImpactAnalysisResponse] instance.
  const ImpactAnalysisResponse({
    required this.sourceServiceId,
    required this.sourceServiceName,
    required this.impactedServices,
    required this.totalAffected,
  });

  /// Deserializes from a JSON map.
  factory ImpactAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$ImpactAnalysisResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ImpactAnalysisResponseToJson(this);
}

/// A service impacted by changes to another service.
@JsonSerializable()
class ImpactedServiceResponse {
  /// UUID of the impacted service.
  final String serviceId;

  /// Name of the impacted service.
  final String serviceName;

  /// Slug of the impacted service.
  final String serviceSlug;

  /// Depth in the dependency chain (1 = direct dependency).
  final int depth;

  /// Type of connection to the source service.
  @DependencyTypeConverter()
  final DependencyType connectionType;

  /// Whether the dependency is required.
  final bool? isRequired;

  /// Creates an [ImpactedServiceResponse] instance.
  const ImpactedServiceResponse({
    required this.serviceId,
    required this.serviceName,
    required this.serviceSlug,
    required this.depth,
    required this.connectionType,
    this.isRequired,
  });

  /// Deserializes from a JSON map.
  factory ImpactedServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$ImpactedServiceResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ImpactedServiceResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Route responses
// ═════════════════════════════════════════════════════════════════════════════

/// An API route registration.
@JsonSerializable()
class ApiRouteResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the service.
  final String serviceId;

  /// Service display name.
  final String? serviceName;

  /// Service URL-friendly slug.
  final String? serviceSlug;

  /// UUID of the gateway service.
  final String? gatewayServiceId;

  /// Gateway service name.
  final String? gatewayServiceName;

  /// Route prefix (e.g., "/api/v1/users").
  final String routePrefix;

  /// Allowed HTTP methods (e.g., "GET,POST,PUT,DELETE").
  final String? httpMethods;

  /// Environment name.
  final String? environment;

  /// Optional description.
  final String? description;

  /// Timestamp when the route was created.
  final DateTime? createdAt;

  /// Creates an [ApiRouteResponse] instance.
  const ApiRouteResponse({
    required this.id,
    required this.serviceId,
    this.serviceName,
    this.serviceSlug,
    this.gatewayServiceId,
    this.gatewayServiceName,
    required this.routePrefix,
    this.httpMethods,
    this.environment,
    this.description,
    this.createdAt,
  });

  /// Deserializes from a JSON map.
  factory ApiRouteResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiRouteResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ApiRouteResponseToJson(this);
}

/// Result of a route prefix availability check.
@JsonSerializable()
class RouteCheckResponse {
  /// Route prefix checked.
  final String routePrefix;

  /// Environment name.
  final String environment;

  /// Whether the route prefix is available.
  final bool available;

  /// Existing routes that conflict.
  final List<ApiRouteResponse> conflictingRoutes;

  /// Creates a [RouteCheckResponse] instance.
  const RouteCheckResponse({
    required this.routePrefix,
    required this.environment,
    required this.available,
    required this.conflictingRoutes,
  });

  /// Deserializes from a JSON map.
  factory RouteCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteCheckResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$RouteCheckResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Config responses
// ═════════════════════════════════════════════════════════════════════════════

/// A generated configuration template.
@JsonSerializable()
class ConfigTemplateResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the service.
  final String? serviceId;

  /// Service display name.
  final String? serviceName;

  /// Template type.
  @ConfigTemplateTypeConverter()
  final ConfigTemplateType templateType;

  /// Environment name.
  final String? environment;

  /// Generated content text.
  final String? contentText;

  /// Whether the config was auto-generated.
  final bool? isAutoGenerated;

  /// Source of generation (e.g., "registry").
  final String? generatedFrom;

  /// Version number.
  final int? version;

  /// Timestamp when the config was created.
  final DateTime? createdAt;

  /// Timestamp when the config was last updated.
  final DateTime? updatedAt;

  /// Creates a [ConfigTemplateResponse] instance.
  const ConfigTemplateResponse({
    required this.id,
    this.serviceId,
    this.serviceName,
    required this.templateType,
    this.environment,
    this.contentText,
    this.isAutoGenerated,
    this.generatedFrom,
    this.version,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory ConfigTemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfigTemplateResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$ConfigTemplateResponseToJson(this);
}

/// An environment configuration key-value pair.
@JsonSerializable()
class EnvironmentConfigResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the service.
  final String serviceId;

  /// Environment name.
  final String environment;

  /// Configuration key.
  final String configKey;

  /// Configuration value.
  final String configValue;

  /// Source of the configuration.
  @ConfigSourceConverter()
  final ConfigSource? configSource;

  /// Optional description.
  final String? description;

  /// Timestamp when the config was created.
  final DateTime? createdAt;

  /// Timestamp when the config was last updated.
  final DateTime? updatedAt;

  /// Creates an [EnvironmentConfigResponse] instance.
  const EnvironmentConfigResponse({
    required this.id,
    required this.serviceId,
    required this.environment,
    required this.configKey,
    required this.configValue,
    this.configSource,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory EnvironmentConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentConfigResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$EnvironmentConfigResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Infrastructure responses
// ═════════════════════════════════════════════════════════════════════════════

/// An infrastructure resource tracked by the Registry.
@JsonSerializable()
class InfraResourceResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the owning team.
  final String teamId;

  /// UUID of the associated service (null if orphaned).
  final String? serviceId;

  /// Service display name.
  final String? serviceName;

  /// Service URL-friendly slug.
  final String? serviceSlug;

  /// Type of infrastructure resource.
  @InfraResourceTypeConverter()
  final InfraResourceType resourceType;

  /// Resource name/identifier.
  final String resourceName;

  /// Environment name.
  final String environment;

  /// AWS region or location.
  final String? region;

  /// ARN or URL of the resource.
  final String? arnOrUrl;

  /// JSON string of metadata.
  final String? metadataJson;

  /// Optional description.
  final String? description;

  /// UUID of the user who created this resource.
  final String? createdByUserId;

  /// Timestamp when the resource was created.
  final DateTime? createdAt;

  /// Timestamp when the resource was last updated.
  final DateTime? updatedAt;

  /// Creates an [InfraResourceResponse] instance.
  const InfraResourceResponse({
    required this.id,
    required this.teamId,
    this.serviceId,
    this.serviceName,
    this.serviceSlug,
    required this.resourceType,
    required this.resourceName,
    required this.environment,
    this.region,
    this.arnOrUrl,
    this.metadataJson,
    this.description,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory InfraResourceResponse.fromJson(Map<String, dynamic> json) =>
      _$InfraResourceResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$InfraResourceResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Topology responses
// ═════════════════════════════════════════════════════════════════════════════

/// Full topology response for visualization.
@JsonSerializable()
class TopologyResponse {
  /// UUID of the team.
  final String? teamId;

  /// Topology nodes (services).
  final List<TopologyNodeResponse> nodes;

  /// Topology edges (dependencies).
  final List<DependencyEdgeResponse> edges;

  /// Solution groupings.
  final List<TopologySolutionGroup>? solutionGroups;

  /// Layer definitions.
  final List<TopologyLayerResponse>? layers;

  /// Topology statistics.
  final TopologyStatsResponse? stats;

  /// Creates a [TopologyResponse] instance.
  const TopologyResponse({
    this.teamId,
    required this.nodes,
    required this.edges,
    this.solutionGroups,
    this.layers,
    this.stats,
  });

  /// Deserializes from a JSON map.
  factory TopologyResponse.fromJson(Map<String, dynamic> json) =>
      _$TopologyResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$TopologyResponseToJson(this);
}

/// A node in the topology visualization.
@JsonSerializable()
class TopologyNodeResponse {
  /// UUID of the service.
  final String serviceId;

  /// Service display name.
  final String name;

  /// Service URL-friendly slug.
  final String slug;

  /// Service technology type.
  @ServiceTypeConverter()
  final ServiceType serviceType;

  /// Service lifecycle status.
  @ServiceStatusConverter()
  final ServiceStatus status;

  /// Service health status.
  @HealthStatusConverter()
  final HealthStatus healthStatus;

  /// Number of allocated ports.
  final int? portCount;

  /// Number of upstream dependencies.
  final int? upstreamDependencyCount;

  /// Number of downstream dependencies.
  final int? downstreamDependencyCount;

  /// UUIDs of solutions this service belongs to.
  final List<String>? solutionIds;

  /// Layer assignment.
  final String? layer;

  /// Creates a [TopologyNodeResponse] instance.
  const TopologyNodeResponse({
    required this.serviceId,
    required this.name,
    required this.slug,
    required this.serviceType,
    required this.status,
    required this.healthStatus,
    this.portCount,
    this.upstreamDependencyCount,
    this.downstreamDependencyCount,
    this.solutionIds,
    this.layer,
  });

  /// Deserializes from a JSON map.
  factory TopologyNodeResponse.fromJson(Map<String, dynamic> json) =>
      _$TopologyNodeResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$TopologyNodeResponseToJson(this);
}

/// A solution grouping in the topology.
@JsonSerializable()
class TopologySolutionGroup {
  /// UUID of the solution.
  final String solutionId;

  /// Solution display name.
  final String name;

  /// Solution URL-friendly slug.
  final String slug;

  /// Solution lifecycle status.
  @SolutionStatusConverter()
  final SolutionStatus status;

  /// Number of member services.
  final int memberCount;

  /// UUIDs of member services.
  final List<String> serviceIds;

  /// Creates a [TopologySolutionGroup] instance.
  const TopologySolutionGroup({
    required this.solutionId,
    required this.name,
    required this.slug,
    required this.status,
    required this.memberCount,
    required this.serviceIds,
  });

  /// Deserializes from a JSON map.
  factory TopologySolutionGroup.fromJson(Map<String, dynamic> json) =>
      _$TopologySolutionGroupFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$TopologySolutionGroupToJson(this);
}

/// A topology layer grouping.
@JsonSerializable()
class TopologyLayerResponse {
  /// Layer name.
  final String layer;

  /// Number of services in this layer.
  final int serviceCount;

  /// UUIDs of services in this layer.
  final List<String> serviceIds;

  /// Creates a [TopologyLayerResponse] instance.
  const TopologyLayerResponse({
    required this.layer,
    required this.serviceCount,
    required this.serviceIds,
  });

  /// Deserializes from a JSON map.
  factory TopologyLayerResponse.fromJson(Map<String, dynamic> json) =>
      _$TopologyLayerResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$TopologyLayerResponseToJson(this);
}

/// Topology statistics.
@JsonSerializable()
class TopologyStatsResponse {
  /// Total number of services.
  final int totalServices;

  /// Total number of dependencies.
  final int totalDependencies;

  /// Total number of solutions.
  final int totalSolutions;

  /// Services with no upstream dependencies.
  final int servicesWithNoDependencies;

  /// Services with no downstream consumers.
  final int servicesWithNoConsumers;

  /// Orphaned services (no dependencies or consumers).
  final int orphanedServices;

  /// Maximum dependency chain depth.
  final int maxDependencyDepth;

  /// Creates a [TopologyStatsResponse] instance.
  const TopologyStatsResponse({
    required this.totalServices,
    required this.totalDependencies,
    required this.totalSolutions,
    required this.servicesWithNoDependencies,
    required this.servicesWithNoConsumers,
    required this.orphanedServices,
    required this.maxDependencyDepth,
  });

  /// Deserializes from a JSON map.
  factory TopologyStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$TopologyStatsResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$TopologyStatsResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Health Management responses
// ═════════════════════════════════════════════════════════════════════════════

/// Team-level health summary.
@JsonSerializable()
class TeamHealthSummaryResponse {
  /// UUID of the team.
  final String teamId;

  /// Total number of services.
  final int totalServices;

  /// Number of active services.
  final int activeServices;

  /// Number of healthy services.
  final int servicesUp;

  /// Number of down services.
  final int servicesDown;

  /// Number of degraded services.
  final int servicesDegraded;

  /// Number of services with unknown health.
  final int servicesUnknown;

  /// Number of services never health-checked.
  final int servicesNeverChecked;

  /// Overall team health status.
  @HealthStatusConverter()
  final HealthStatus overallHealth;

  /// Unhealthy service details.
  final List<ServiceHealthResponse>? unhealthyServices;

  /// Timestamp of the health check.
  final DateTime? checkedAt;

  /// Creates a [TeamHealthSummaryResponse] instance.
  const TeamHealthSummaryResponse({
    required this.teamId,
    required this.totalServices,
    required this.activeServices,
    required this.servicesUp,
    required this.servicesDown,
    required this.servicesDegraded,
    required this.servicesUnknown,
    required this.servicesNeverChecked,
    required this.overallHealth,
    this.unhealthyServices,
    this.checkedAt,
  });

  /// Deserializes from a JSON map.
  factory TeamHealthSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamHealthSummaryResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$TeamHealthSummaryResponseToJson(this);
}

// ═════════════════════════════════════════════════════════════════════════════
// Workstation responses
// ═════════════════════════════════════════════════════════════════════════════

/// A workstation profile for local development.
@JsonSerializable()
class WorkstationProfileResponse {
  /// Unique identifier (UUID).
  final String id;

  /// UUID of the team.
  final String teamId;

  /// Profile display name.
  final String name;

  /// Optional description.
  final String? description;

  /// UUID of the associated solution.
  final String? solutionId;

  /// UUIDs of services in this profile.
  final List<String>? serviceIds;

  /// Service entries with startup order.
  final List<WorkstationServiceEntry>? services;

  /// Startup order (UUIDs of services).
  final List<String>? startupOrder;

  /// Whether this is the default profile.
  final bool? isDefault;

  /// UUID of the user who created this profile.
  final String? createdByUserId;

  /// Timestamp when the profile was created.
  final DateTime? createdAt;

  /// Timestamp when the profile was last updated.
  final DateTime? updatedAt;

  /// Creates a [WorkstationProfileResponse] instance.
  const WorkstationProfileResponse({
    required this.id,
    required this.teamId,
    required this.name,
    this.description,
    this.solutionId,
    this.serviceIds,
    this.services,
    this.startupOrder,
    this.isDefault,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes from a JSON map.
  factory WorkstationProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkstationProfileResponseFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$WorkstationProfileResponseToJson(this);
}

/// A service entry within a workstation profile.
@JsonSerializable()
class WorkstationServiceEntry {
  /// UUID of the service.
  final String serviceId;

  /// Service display name.
  final String name;

  /// Service URL-friendly slug.
  final String slug;

  /// Service technology type.
  @ServiceTypeConverter()
  final ServiceType serviceType;

  /// Service lifecycle status.
  @ServiceStatusConverter()
  final ServiceStatus status;

  /// Service health status.
  @HealthStatusConverter()
  final HealthStatus healthStatus;

  /// Position in startup order.
  final int? startupPosition;

  /// Creates a [WorkstationServiceEntry] instance.
  const WorkstationServiceEntry({
    required this.serviceId,
    required this.name,
    required this.slug,
    required this.serviceType,
    required this.status,
    required this.healthStatus,
    this.startupPosition,
  });

  /// Deserializes from a JSON map.
  factory WorkstationServiceEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkstationServiceEntryFromJson(json);

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => _$WorkstationServiceEntryToJson(this);
}
