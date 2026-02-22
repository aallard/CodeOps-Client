// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registry_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceRegistrationResponse _$ServiceRegistrationResponseFromJson(
        Map<String, dynamic> json) =>
    ServiceRegistrationResponse(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      serviceType:
          const ServiceTypeConverter().fromJson(json['serviceType'] as String),
      description: json['description'] as String?,
      repoUrl: json['repoUrl'] as String?,
      repoFullName: json['repoFullName'] as String?,
      defaultBranch: json['defaultBranch'] as String?,
      techStack: json['techStack'] as String?,
      status: const ServiceStatusConverter().fromJson(json['status'] as String),
      healthCheckUrl: json['healthCheckUrl'] as String?,
      healthCheckIntervalSeconds:
          (json['healthCheckIntervalSeconds'] as num?)?.toInt(),
      lastHealthStatus: _$JsonConverterFromJson<String, HealthStatus>(
          json['lastHealthStatus'], const HealthStatusConverter().fromJson),
      lastHealthCheckAt: json['lastHealthCheckAt'] == null
          ? null
          : DateTime.parse(json['lastHealthCheckAt'] as String),
      environmentsJson: json['environmentsJson'] as String?,
      metadataJson: json['metadataJson'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      portCount: (json['portCount'] as num?)?.toInt(),
      dependencyCount: (json['dependencyCount'] as num?)?.toInt(),
      solutionCount: (json['solutionCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServiceRegistrationResponseToJson(
        ServiceRegistrationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'slug': instance.slug,
      'serviceType': const ServiceTypeConverter().toJson(instance.serviceType),
      'description': instance.description,
      'repoUrl': instance.repoUrl,
      'repoFullName': instance.repoFullName,
      'defaultBranch': instance.defaultBranch,
      'techStack': instance.techStack,
      'status': const ServiceStatusConverter().toJson(instance.status),
      'healthCheckUrl': instance.healthCheckUrl,
      'healthCheckIntervalSeconds': instance.healthCheckIntervalSeconds,
      'lastHealthStatus': _$JsonConverterToJson<String, HealthStatus>(
          instance.lastHealthStatus, const HealthStatusConverter().toJson),
      'lastHealthCheckAt': instance.lastHealthCheckAt?.toIso8601String(),
      'environmentsJson': instance.environmentsJson,
      'metadataJson': instance.metadataJson,
      'createdByUserId': instance.createdByUserId,
      'portCount': instance.portCount,
      'dependencyCount': instance.dependencyCount,
      'solutionCount': instance.solutionCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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

ServiceIdentityResponse _$ServiceIdentityResponseFromJson(
        Map<String, dynamic> json) =>
    ServiceIdentityResponse(
      service: ServiceRegistrationResponse.fromJson(
          json['service'] as Map<String, dynamic>),
      ports: (json['ports'] as List<dynamic>)
          .map(
              (e) => PortAllocationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      upstreamDependencies: (json['upstreamDependencies'] as List<dynamic>)
          .map((e) =>
              ServiceDependencyResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      downstreamDependencies: (json['downstreamDependencies'] as List<dynamic>)
          .map((e) =>
              ServiceDependencyResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      routes: (json['routes'] as List<dynamic>)
          .map((e) => ApiRouteResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      infraResources: (json['infraResources'] as List<dynamic>)
          .map((e) => InfraResourceResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      environmentConfigs: (json['environmentConfigs'] as List<dynamic>)
          .map((e) =>
              EnvironmentConfigResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServiceIdentityResponseToJson(
        ServiceIdentityResponse instance) =>
    <String, dynamic>{
      'service': instance.service,
      'ports': instance.ports,
      'upstreamDependencies': instance.upstreamDependencies,
      'downstreamDependencies': instance.downstreamDependencies,
      'routes': instance.routes,
      'infraResources': instance.infraResources,
      'environmentConfigs': instance.environmentConfigs,
    };

ServiceHealthResponse _$ServiceHealthResponseFromJson(
        Map<String, dynamic> json) =>
    ServiceHealthResponse(
      serviceId: json['serviceId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      healthStatus: const HealthStatusConverter()
          .fromJson(json['healthStatus'] as String),
      lastCheckAt: json['lastCheckAt'] == null
          ? null
          : DateTime.parse(json['lastCheckAt'] as String),
      healthCheckUrl: json['healthCheckUrl'] as String?,
      responseTimeMs: (json['responseTimeMs'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$ServiceHealthResponseToJson(
        ServiceHealthResponse instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'name': instance.name,
      'slug': instance.slug,
      'healthStatus':
          const HealthStatusConverter().toJson(instance.healthStatus),
      'lastCheckAt': instance.lastCheckAt?.toIso8601String(),
      'healthCheckUrl': instance.healthCheckUrl,
      'responseTimeMs': instance.responseTimeMs,
      'errorMessage': instance.errorMessage,
    };

SolutionResponse _$SolutionResponseFromJson(Map<String, dynamic> json) =>
    SolutionResponse(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      category: const SolutionCategoryConverter()
          .fromJson(json['category'] as String),
      status:
          const SolutionStatusConverter().fromJson(json['status'] as String),
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
      documentationUrl: json['documentationUrl'] as String?,
      metadataJson: json['metadataJson'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SolutionResponseToJson(SolutionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category': const SolutionCategoryConverter().toJson(instance.category),
      'status': const SolutionStatusConverter().toJson(instance.status),
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'ownerUserId': instance.ownerUserId,
      'repositoryUrl': instance.repositoryUrl,
      'documentationUrl': instance.documentationUrl,
      'metadataJson': instance.metadataJson,
      'createdByUserId': instance.createdByUserId,
      'memberCount': instance.memberCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SolutionDetailResponse _$SolutionDetailResponseFromJson(
        Map<String, dynamic> json) =>
    SolutionDetailResponse(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      category: const SolutionCategoryConverter()
          .fromJson(json['category'] as String),
      status:
          const SolutionStatusConverter().fromJson(json['status'] as String),
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
      documentationUrl: json['documentationUrl'] as String?,
      metadataJson: json['metadataJson'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      members: (json['members'] as List<dynamic>)
          .map(
              (e) => SolutionMemberResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SolutionDetailResponseToJson(
        SolutionDetailResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category': const SolutionCategoryConverter().toJson(instance.category),
      'status': const SolutionStatusConverter().toJson(instance.status),
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'ownerUserId': instance.ownerUserId,
      'repositoryUrl': instance.repositoryUrl,
      'documentationUrl': instance.documentationUrl,
      'metadataJson': instance.metadataJson,
      'createdByUserId': instance.createdByUserId,
      'members': instance.members,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SolutionMemberResponse _$SolutionMemberResponseFromJson(
        Map<String, dynamic> json) =>
    SolutionMemberResponse(
      id: json['id'] as String,
      solutionId: json['solutionId'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String?,
      serviceSlug: json['serviceSlug'] as String?,
      serviceType: _$JsonConverterFromJson<String, ServiceType>(
          json['serviceType'], const ServiceTypeConverter().fromJson),
      serviceStatus: _$JsonConverterFromJson<String, ServiceStatus>(
          json['serviceStatus'], const ServiceStatusConverter().fromJson),
      serviceHealthStatus: _$JsonConverterFromJson<String, HealthStatus>(
          json['serviceHealthStatus'], const HealthStatusConverter().fromJson),
      role:
          const SolutionMemberRoleConverter().fromJson(json['role'] as String),
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$SolutionMemberResponseToJson(
        SolutionMemberResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'solutionId': instance.solutionId,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceSlug': instance.serviceSlug,
      'serviceType': _$JsonConverterToJson<String, ServiceType>(
          instance.serviceType, const ServiceTypeConverter().toJson),
      'serviceStatus': _$JsonConverterToJson<String, ServiceStatus>(
          instance.serviceStatus, const ServiceStatusConverter().toJson),
      'serviceHealthStatus': _$JsonConverterToJson<String, HealthStatus>(
          instance.serviceHealthStatus, const HealthStatusConverter().toJson),
      'role': const SolutionMemberRoleConverter().toJson(instance.role),
      'displayOrder': instance.displayOrder,
      'notes': instance.notes,
    };

SolutionHealthResponse _$SolutionHealthResponseFromJson(
        Map<String, dynamic> json) =>
    SolutionHealthResponse(
      solutionId: json['solutionId'] as String,
      solutionName: json['solutionName'] as String,
      totalServices: (json['totalServices'] as num).toInt(),
      servicesUp: (json['servicesUp'] as num).toInt(),
      servicesDown: (json['servicesDown'] as num).toInt(),
      servicesDegraded: (json['servicesDegraded'] as num).toInt(),
      servicesUnknown: (json['servicesUnknown'] as num).toInt(),
      aggregatedHealth: const HealthStatusConverter()
          .fromJson(json['aggregatedHealth'] as String),
      serviceHealths: (json['serviceHealths'] as List<dynamic>)
          .map((e) => ServiceHealthResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SolutionHealthResponseToJson(
        SolutionHealthResponse instance) =>
    <String, dynamic>{
      'solutionId': instance.solutionId,
      'solutionName': instance.solutionName,
      'totalServices': instance.totalServices,
      'servicesUp': instance.servicesUp,
      'servicesDown': instance.servicesDown,
      'servicesDegraded': instance.servicesDegraded,
      'servicesUnknown': instance.servicesUnknown,
      'aggregatedHealth':
          const HealthStatusConverter().toJson(instance.aggregatedHealth),
      'serviceHealths': instance.serviceHealths,
    };

PortAllocationResponse _$PortAllocationResponseFromJson(
        Map<String, dynamic> json) =>
    PortAllocationResponse(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String?,
      serviceSlug: json['serviceSlug'] as String?,
      environment: json['environment'] as String,
      portType: const PortTypeConverter().fromJson(json['portType'] as String),
      portNumber: (json['portNumber'] as num).toInt(),
      protocol: json['protocol'] as String?,
      description: json['description'] as String?,
      isAutoAllocated: json['isAutoAllocated'] as bool?,
      allocatedByUserId: json['allocatedByUserId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PortAllocationResponseToJson(
        PortAllocationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceSlug': instance.serviceSlug,
      'environment': instance.environment,
      'portType': const PortTypeConverter().toJson(instance.portType),
      'portNumber': instance.portNumber,
      'protocol': instance.protocol,
      'description': instance.description,
      'isAutoAllocated': instance.isAutoAllocated,
      'allocatedByUserId': instance.allocatedByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

PortRangeResponse _$PortRangeResponseFromJson(Map<String, dynamic> json) =>
    PortRangeResponse(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      portType: const PortTypeConverter().fromJson(json['portType'] as String),
      rangeStart: (json['rangeStart'] as num).toInt(),
      rangeEnd: (json['rangeEnd'] as num).toInt(),
      environment: json['environment'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PortRangeResponseToJson(PortRangeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'portType': const PortTypeConverter().toJson(instance.portType),
      'rangeStart': instance.rangeStart,
      'rangeEnd': instance.rangeEnd,
      'environment': instance.environment,
      'description': instance.description,
    };

PortRangeWithAllocationsResponse _$PortRangeWithAllocationsResponseFromJson(
        Map<String, dynamic> json) =>
    PortRangeWithAllocationsResponse(
      portType: const PortTypeConverter().fromJson(json['portType'] as String),
      rangeStart: (json['rangeStart'] as num).toInt(),
      rangeEnd: (json['rangeEnd'] as num).toInt(),
      totalCapacity: (json['totalCapacity'] as num).toInt(),
      allocated: (json['allocated'] as num).toInt(),
      available: (json['available'] as num).toInt(),
      allocations: (json['allocations'] as List<dynamic>)
          .map(
              (e) => PortAllocationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PortRangeWithAllocationsResponseToJson(
        PortRangeWithAllocationsResponse instance) =>
    <String, dynamic>{
      'portType': const PortTypeConverter().toJson(instance.portType),
      'rangeStart': instance.rangeStart,
      'rangeEnd': instance.rangeEnd,
      'totalCapacity': instance.totalCapacity,
      'allocated': instance.allocated,
      'available': instance.available,
      'allocations': instance.allocations,
    };

PortMapResponse _$PortMapResponseFromJson(Map<String, dynamic> json) =>
    PortMapResponse(
      teamId: json['teamId'] as String,
      environment: json['environment'] as String,
      ranges: (json['ranges'] as List<dynamic>)
          .map((e) => PortRangeWithAllocationsResponse.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      totalAllocated: (json['totalAllocated'] as num).toInt(),
      totalAvailable: (json['totalAvailable'] as num).toInt(),
    );

Map<String, dynamic> _$PortMapResponseToJson(PortMapResponse instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'environment': instance.environment,
      'ranges': instance.ranges,
      'totalAllocated': instance.totalAllocated,
      'totalAvailable': instance.totalAvailable,
    };

PortCheckResponse _$PortCheckResponseFromJson(Map<String, dynamic> json) =>
    PortCheckResponse(
      portNumber: (json['portNumber'] as num).toInt(),
      environment: json['environment'] as String,
      available: json['available'] as bool,
      currentOwnerServiceId: json['currentOwnerServiceId'] as String?,
      currentOwnerServiceName: json['currentOwnerServiceName'] as String?,
      currentOwnerPortType: _$JsonConverterFromJson<String, PortType>(
          json['currentOwnerPortType'], const PortTypeConverter().fromJson),
    );

Map<String, dynamic> _$PortCheckResponseToJson(PortCheckResponse instance) =>
    <String, dynamic>{
      'portNumber': instance.portNumber,
      'environment': instance.environment,
      'available': instance.available,
      'currentOwnerServiceId': instance.currentOwnerServiceId,
      'currentOwnerServiceName': instance.currentOwnerServiceName,
      'currentOwnerPortType': _$JsonConverterToJson<String, PortType>(
          instance.currentOwnerPortType, const PortTypeConverter().toJson),
    };

PortConflictResponse _$PortConflictResponseFromJson(
        Map<String, dynamic> json) =>
    PortConflictResponse(
      portNumber: (json['portNumber'] as num).toInt(),
      environment: json['environment'] as String,
      conflictingAllocations: (json['conflictingAllocations'] as List<dynamic>)
          .map(
              (e) => PortAllocationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PortConflictResponseToJson(
        PortConflictResponse instance) =>
    <String, dynamic>{
      'portNumber': instance.portNumber,
      'environment': instance.environment,
      'conflictingAllocations': instance.conflictingAllocations,
    };

ServiceDependencyResponse _$ServiceDependencyResponseFromJson(
        Map<String, dynamic> json) =>
    ServiceDependencyResponse(
      id: json['id'] as String,
      sourceServiceId: json['sourceServiceId'] as String,
      sourceServiceName: json['sourceServiceName'] as String?,
      sourceServiceSlug: json['sourceServiceSlug'] as String?,
      targetServiceId: json['targetServiceId'] as String,
      targetServiceName: json['targetServiceName'] as String?,
      targetServiceSlug: json['targetServiceSlug'] as String?,
      dependencyType: const DependencyTypeConverter()
          .fromJson(json['dependencyType'] as String),
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool?,
      targetEndpoint: json['targetEndpoint'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ServiceDependencyResponseToJson(
        ServiceDependencyResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceServiceId': instance.sourceServiceId,
      'sourceServiceName': instance.sourceServiceName,
      'sourceServiceSlug': instance.sourceServiceSlug,
      'targetServiceId': instance.targetServiceId,
      'targetServiceName': instance.targetServiceName,
      'targetServiceSlug': instance.targetServiceSlug,
      'dependencyType':
          const DependencyTypeConverter().toJson(instance.dependencyType),
      'description': instance.description,
      'isRequired': instance.isRequired,
      'targetEndpoint': instance.targetEndpoint,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

DependencyGraphResponse _$DependencyGraphResponseFromJson(
        Map<String, dynamic> json) =>
    DependencyGraphResponse(
      teamId: json['teamId'] as String,
      nodes: (json['nodes'] as List<dynamic>)
          .map(
              (e) => DependencyNodeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List<dynamic>)
          .map(
              (e) => DependencyEdgeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DependencyGraphResponseToJson(
        DependencyGraphResponse instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'nodes': instance.nodes,
      'edges': instance.edges,
    };

DependencyNodeResponse _$DependencyNodeResponseFromJson(
        Map<String, dynamic> json) =>
    DependencyNodeResponse(
      serviceId: json['serviceId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      serviceType:
          const ServiceTypeConverter().fromJson(json['serviceType'] as String),
      status: const ServiceStatusConverter().fromJson(json['status'] as String),
      healthStatus: const HealthStatusConverter()
          .fromJson(json['healthStatus'] as String),
    );

Map<String, dynamic> _$DependencyNodeResponseToJson(
        DependencyNodeResponse instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'name': instance.name,
      'slug': instance.slug,
      'serviceType': const ServiceTypeConverter().toJson(instance.serviceType),
      'status': const ServiceStatusConverter().toJson(instance.status),
      'healthStatus':
          const HealthStatusConverter().toJson(instance.healthStatus),
    };

DependencyEdgeResponse _$DependencyEdgeResponseFromJson(
        Map<String, dynamic> json) =>
    DependencyEdgeResponse(
      sourceServiceId: json['sourceServiceId'] as String,
      targetServiceId: json['targetServiceId'] as String,
      dependencyType: const DependencyTypeConverter()
          .fromJson(json['dependencyType'] as String),
      isRequired: json['isRequired'] as bool?,
      targetEndpoint: json['targetEndpoint'] as String?,
    );

Map<String, dynamic> _$DependencyEdgeResponseToJson(
        DependencyEdgeResponse instance) =>
    <String, dynamic>{
      'sourceServiceId': instance.sourceServiceId,
      'targetServiceId': instance.targetServiceId,
      'dependencyType':
          const DependencyTypeConverter().toJson(instance.dependencyType),
      'isRequired': instance.isRequired,
      'targetEndpoint': instance.targetEndpoint,
    };

ImpactAnalysisResponse _$ImpactAnalysisResponseFromJson(
        Map<String, dynamic> json) =>
    ImpactAnalysisResponse(
      sourceServiceId: json['sourceServiceId'] as String,
      sourceServiceName: json['sourceServiceName'] as String,
      impactedServices: (json['impactedServices'] as List<dynamic>)
          .map((e) =>
              ImpactedServiceResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAffected: (json['totalAffected'] as num).toInt(),
    );

Map<String, dynamic> _$ImpactAnalysisResponseToJson(
        ImpactAnalysisResponse instance) =>
    <String, dynamic>{
      'sourceServiceId': instance.sourceServiceId,
      'sourceServiceName': instance.sourceServiceName,
      'impactedServices': instance.impactedServices,
      'totalAffected': instance.totalAffected,
    };

ImpactedServiceResponse _$ImpactedServiceResponseFromJson(
        Map<String, dynamic> json) =>
    ImpactedServiceResponse(
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      serviceSlug: json['serviceSlug'] as String,
      depth: (json['depth'] as num).toInt(),
      connectionType: const DependencyTypeConverter()
          .fromJson(json['connectionType'] as String),
      isRequired: json['isRequired'] as bool?,
    );

Map<String, dynamic> _$ImpactedServiceResponseToJson(
        ImpactedServiceResponse instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceSlug': instance.serviceSlug,
      'depth': instance.depth,
      'connectionType':
          const DependencyTypeConverter().toJson(instance.connectionType),
      'isRequired': instance.isRequired,
    };

ApiRouteResponse _$ApiRouteResponseFromJson(Map<String, dynamic> json) =>
    ApiRouteResponse(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String?,
      serviceSlug: json['serviceSlug'] as String?,
      gatewayServiceId: json['gatewayServiceId'] as String?,
      gatewayServiceName: json['gatewayServiceName'] as String?,
      routePrefix: json['routePrefix'] as String,
      httpMethods: json['httpMethods'] as String?,
      environment: json['environment'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ApiRouteResponseToJson(ApiRouteResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceSlug': instance.serviceSlug,
      'gatewayServiceId': instance.gatewayServiceId,
      'gatewayServiceName': instance.gatewayServiceName,
      'routePrefix': instance.routePrefix,
      'httpMethods': instance.httpMethods,
      'environment': instance.environment,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

RouteCheckResponse _$RouteCheckResponseFromJson(Map<String, dynamic> json) =>
    RouteCheckResponse(
      routePrefix: json['routePrefix'] as String,
      environment: json['environment'] as String,
      available: json['available'] as bool,
      conflictingRoutes: (json['conflictingRoutes'] as List<dynamic>)
          .map((e) => ApiRouteResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteCheckResponseToJson(RouteCheckResponse instance) =>
    <String, dynamic>{
      'routePrefix': instance.routePrefix,
      'environment': instance.environment,
      'available': instance.available,
      'conflictingRoutes': instance.conflictingRoutes,
    };

ConfigTemplateResponse _$ConfigTemplateResponseFromJson(
        Map<String, dynamic> json) =>
    ConfigTemplateResponse(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String?,
      serviceName: json['serviceName'] as String?,
      templateType: const ConfigTemplateTypeConverter()
          .fromJson(json['templateType'] as String),
      environment: json['environment'] as String?,
      contentText: json['contentText'] as String?,
      isAutoGenerated: json['isAutoGenerated'] as bool?,
      generatedFrom: json['generatedFrom'] as String?,
      version: (json['version'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ConfigTemplateResponseToJson(
        ConfigTemplateResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'templateType':
          const ConfigTemplateTypeConverter().toJson(instance.templateType),
      'environment': instance.environment,
      'contentText': instance.contentText,
      'isAutoGenerated': instance.isAutoGenerated,
      'generatedFrom': instance.generatedFrom,
      'version': instance.version,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

EnvironmentConfigResponse _$EnvironmentConfigResponseFromJson(
        Map<String, dynamic> json) =>
    EnvironmentConfigResponse(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      environment: json['environment'] as String,
      configKey: json['configKey'] as String,
      configValue: json['configValue'] as String,
      configSource: _$JsonConverterFromJson<String, ConfigSource>(
          json['configSource'], const ConfigSourceConverter().fromJson),
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EnvironmentConfigResponseToJson(
        EnvironmentConfigResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'environment': instance.environment,
      'configKey': instance.configKey,
      'configValue': instance.configValue,
      'configSource': _$JsonConverterToJson<String, ConfigSource>(
          instance.configSource, const ConfigSourceConverter().toJson),
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

InfraResourceResponse _$InfraResourceResponseFromJson(
        Map<String, dynamic> json) =>
    InfraResourceResponse(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      serviceId: json['serviceId'] as String?,
      serviceName: json['serviceName'] as String?,
      serviceSlug: json['serviceSlug'] as String?,
      resourceType: const InfraResourceTypeConverter()
          .fromJson(json['resourceType'] as String),
      resourceName: json['resourceName'] as String,
      environment: json['environment'] as String,
      region: json['region'] as String?,
      arnOrUrl: json['arnOrUrl'] as String?,
      metadataJson: json['metadataJson'] as String?,
      description: json['description'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InfraResourceResponseToJson(
        InfraResourceResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceSlug': instance.serviceSlug,
      'resourceType':
          const InfraResourceTypeConverter().toJson(instance.resourceType),
      'resourceName': instance.resourceName,
      'environment': instance.environment,
      'region': instance.region,
      'arnOrUrl': instance.arnOrUrl,
      'metadataJson': instance.metadataJson,
      'description': instance.description,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

TopologyResponse _$TopologyResponseFromJson(Map<String, dynamic> json) =>
    TopologyResponse(
      teamId: json['teamId'] as String?,
      nodes: (json['nodes'] as List<dynamic>)
          .map((e) => TopologyNodeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List<dynamic>)
          .map(
              (e) => DependencyEdgeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      solutionGroups: (json['solutionGroups'] as List<dynamic>?)
          ?.map(
              (e) => TopologySolutionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      layers: (json['layers'] as List<dynamic>?)
          ?.map(
              (e) => TopologyLayerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: json['stats'] == null
          ? null
          : TopologyStatsResponse.fromJson(
              json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopologyResponseToJson(TopologyResponse instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'nodes': instance.nodes,
      'edges': instance.edges,
      'solutionGroups': instance.solutionGroups,
      'layers': instance.layers,
      'stats': instance.stats,
    };

TopologyNodeResponse _$TopologyNodeResponseFromJson(
        Map<String, dynamic> json) =>
    TopologyNodeResponse(
      serviceId: json['serviceId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      serviceType:
          const ServiceTypeConverter().fromJson(json['serviceType'] as String),
      status: const ServiceStatusConverter().fromJson(json['status'] as String),
      healthStatus: const HealthStatusConverter()
          .fromJson(json['healthStatus'] as String),
      portCount: (json['portCount'] as num?)?.toInt(),
      upstreamDependencyCount:
          (json['upstreamDependencyCount'] as num?)?.toInt(),
      downstreamDependencyCount:
          (json['downstreamDependencyCount'] as num?)?.toInt(),
      solutionIds: (json['solutionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      layer: json['layer'] as String?,
    );

Map<String, dynamic> _$TopologyNodeResponseToJson(
        TopologyNodeResponse instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'name': instance.name,
      'slug': instance.slug,
      'serviceType': const ServiceTypeConverter().toJson(instance.serviceType),
      'status': const ServiceStatusConverter().toJson(instance.status),
      'healthStatus':
          const HealthStatusConverter().toJson(instance.healthStatus),
      'portCount': instance.portCount,
      'upstreamDependencyCount': instance.upstreamDependencyCount,
      'downstreamDependencyCount': instance.downstreamDependencyCount,
      'solutionIds': instance.solutionIds,
      'layer': instance.layer,
    };

TopologySolutionGroup _$TopologySolutionGroupFromJson(
        Map<String, dynamic> json) =>
    TopologySolutionGroup(
      solutionId: json['solutionId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      status:
          const SolutionStatusConverter().fromJson(json['status'] as String),
      memberCount: (json['memberCount'] as num).toInt(),
      serviceIds: (json['serviceIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TopologySolutionGroupToJson(
        TopologySolutionGroup instance) =>
    <String, dynamic>{
      'solutionId': instance.solutionId,
      'name': instance.name,
      'slug': instance.slug,
      'status': const SolutionStatusConverter().toJson(instance.status),
      'memberCount': instance.memberCount,
      'serviceIds': instance.serviceIds,
    };

TopologyLayerResponse _$TopologyLayerResponseFromJson(
        Map<String, dynamic> json) =>
    TopologyLayerResponse(
      layer: json['layer'] as String,
      serviceCount: (json['serviceCount'] as num).toInt(),
      serviceIds: (json['serviceIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TopologyLayerResponseToJson(
        TopologyLayerResponse instance) =>
    <String, dynamic>{
      'layer': instance.layer,
      'serviceCount': instance.serviceCount,
      'serviceIds': instance.serviceIds,
    };

TopologyStatsResponse _$TopologyStatsResponseFromJson(
        Map<String, dynamic> json) =>
    TopologyStatsResponse(
      totalServices: (json['totalServices'] as num).toInt(),
      totalDependencies: (json['totalDependencies'] as num).toInt(),
      totalSolutions: (json['totalSolutions'] as num).toInt(),
      servicesWithNoDependencies:
          (json['servicesWithNoDependencies'] as num).toInt(),
      servicesWithNoConsumers: (json['servicesWithNoConsumers'] as num).toInt(),
      orphanedServices: (json['orphanedServices'] as num).toInt(),
      maxDependencyDepth: (json['maxDependencyDepth'] as num).toInt(),
    );

Map<String, dynamic> _$TopologyStatsResponseToJson(
        TopologyStatsResponse instance) =>
    <String, dynamic>{
      'totalServices': instance.totalServices,
      'totalDependencies': instance.totalDependencies,
      'totalSolutions': instance.totalSolutions,
      'servicesWithNoDependencies': instance.servicesWithNoDependencies,
      'servicesWithNoConsumers': instance.servicesWithNoConsumers,
      'orphanedServices': instance.orphanedServices,
      'maxDependencyDepth': instance.maxDependencyDepth,
    };

TeamHealthSummaryResponse _$TeamHealthSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    TeamHealthSummaryResponse(
      teamId: json['teamId'] as String,
      totalServices: (json['totalServices'] as num).toInt(),
      activeServices: (json['activeServices'] as num).toInt(),
      servicesUp: (json['servicesUp'] as num).toInt(),
      servicesDown: (json['servicesDown'] as num).toInt(),
      servicesDegraded: (json['servicesDegraded'] as num).toInt(),
      servicesUnknown: (json['servicesUnknown'] as num).toInt(),
      servicesNeverChecked: (json['servicesNeverChecked'] as num).toInt(),
      overallHealth: const HealthStatusConverter()
          .fromJson(json['overallHealth'] as String),
      unhealthyServices: (json['unhealthyServices'] as List<dynamic>?)
          ?.map(
              (e) => ServiceHealthResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkedAt: json['checkedAt'] == null
          ? null
          : DateTime.parse(json['checkedAt'] as String),
    );

Map<String, dynamic> _$TeamHealthSummaryResponseToJson(
        TeamHealthSummaryResponse instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'totalServices': instance.totalServices,
      'activeServices': instance.activeServices,
      'servicesUp': instance.servicesUp,
      'servicesDown': instance.servicesDown,
      'servicesDegraded': instance.servicesDegraded,
      'servicesUnknown': instance.servicesUnknown,
      'servicesNeverChecked': instance.servicesNeverChecked,
      'overallHealth':
          const HealthStatusConverter().toJson(instance.overallHealth),
      'unhealthyServices': instance.unhealthyServices,
      'checkedAt': instance.checkedAt?.toIso8601String(),
    };

WorkstationProfileResponse _$WorkstationProfileResponseFromJson(
        Map<String, dynamic> json) =>
    WorkstationProfileResponse(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      solutionId: json['solutionId'] as String?,
      serviceIds: (json['serviceIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) =>
              WorkstationServiceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      startupOrder: (json['startupOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isDefault: json['isDefault'] as bool?,
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkstationProfileResponseToJson(
        WorkstationProfileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'description': instance.description,
      'solutionId': instance.solutionId,
      'serviceIds': instance.serviceIds,
      'services': instance.services,
      'startupOrder': instance.startupOrder,
      'isDefault': instance.isDefault,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

WorkstationServiceEntry _$WorkstationServiceEntryFromJson(
        Map<String, dynamic> json) =>
    WorkstationServiceEntry(
      serviceId: json['serviceId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      serviceType:
          const ServiceTypeConverter().fromJson(json['serviceType'] as String),
      status: const ServiceStatusConverter().fromJson(json['status'] as String),
      healthStatus: const HealthStatusConverter()
          .fromJson(json['healthStatus'] as String),
      startupPosition: (json['startupPosition'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkstationServiceEntryToJson(
        WorkstationServiceEntry instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'name': instance.name,
      'slug': instance.slug,
      'serviceType': const ServiceTypeConverter().toJson(instance.serviceType),
      'status': const ServiceStatusConverter().toJson(instance.status),
      'healthStatus':
          const HealthStatusConverter().toJson(instance.healthStatus),
      'startupPosition': instance.startupPosition,
    };
