/// API service for all CodeOps-Registry endpoints.
///
/// Covers service registration, solutions, ports, dependencies, routes,
/// config generation, infrastructure resources, topology, health management,
/// and workstation profiles.
/// All 77 endpoints from the CodeOps-Registry controllers are represented here.
library;

import '../../models/health_snapshot.dart';
import '../../models/registry_enums.dart';
import '../../models/registry_models.dart';
import 'registry_api_client.dart';

/// API service for CodeOps-Registry endpoints.
///
/// Provides typed methods for every Registry endpoint, organized by
/// controller: Services, Solutions, Dependencies, Ports, Routes,
/// Config, InfraResources, Topology, Health Management, and Workstations.
class RegistryApi {
  final RegistryApiClient _client;

  /// Creates a [RegistryApi] backed by the given Registry [client].
  RegistryApi(this._client);

  // ═══════════════════════════════════════════════════════════════════════════
  // Services (11 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registers a new service for a team.
  Future<ServiceRegistrationResponse> createService({
    required String teamId,
    required String name,
    required ServiceType serviceType,
    String? slug,
    String? description,
    String? repoUrl,
    String? repoFullName,
    String? defaultBranch,
    String? techStack,
    String? healthCheckUrl,
    int? healthCheckIntervalSeconds,
    String? environmentsJson,
    String? metadataJson,
    List<PortType>? autoAllocatePortTypes,
    String? autoAllocateEnvironment,
  }) async {
    final body = <String, dynamic>{
      'teamId': teamId,
      'name': name,
      'serviceType': serviceType.toJson(),
    };
    if (slug != null) body['slug'] = slug;
    if (description != null) body['description'] = description;
    if (repoUrl != null) body['repoUrl'] = repoUrl;
    if (repoFullName != null) body['repoFullName'] = repoFullName;
    if (defaultBranch != null) body['defaultBranch'] = defaultBranch;
    if (techStack != null) body['techStack'] = techStack;
    if (healthCheckUrl != null) body['healthCheckUrl'] = healthCheckUrl;
    if (healthCheckIntervalSeconds != null) {
      body['healthCheckIntervalSeconds'] = healthCheckIntervalSeconds;
    }
    if (environmentsJson != null) body['environmentsJson'] = environmentsJson;
    if (metadataJson != null) body['metadataJson'] = metadataJson;
    if (autoAllocatePortTypes != null) {
      body['autoAllocatePortTypes'] =
          autoAllocatePortTypes.map((e) => e.toJson()).toList();
    }
    if (autoAllocateEnvironment != null) {
      body['autoAllocateEnvironment'] = autoAllocateEnvironment;
    }

    final response = await _client.post<Map<String, dynamic>>(
      '/teams/$teamId/services',
      data: body,
    );
    return ServiceRegistrationResponse.fromJson(response.data!);
  }

  /// Lists services for a team with optional filtering.
  Future<PageResponse<ServiceRegistrationResponse>> getServicesForTeam(
    String teamId, {
    ServiceStatus? status,
    ServiceType? type,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (status != null) params['status'] = status.toJson();
    if (type != null) params['type'] = type.toJson();
    if (search != null) params['search'] = search;

    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/services',
      queryParameters: params,
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => ServiceRegistrationResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  /// Retrieves a single service by ID.
  Future<ServiceRegistrationResponse> getService(String serviceId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/services/$serviceId',
    );
    return ServiceRegistrationResponse.fromJson(response.data!);
  }

  /// Updates a service registration.
  Future<ServiceRegistrationResponse> updateService(
    String serviceId, {
    String? name,
    String? description,
    String? repoUrl,
    String? repoFullName,
    String? defaultBranch,
    String? techStack,
    String? healthCheckUrl,
    int? healthCheckIntervalSeconds,
    String? environmentsJson,
    String? metadataJson,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (repoUrl != null) body['repoUrl'] = repoUrl;
    if (repoFullName != null) body['repoFullName'] = repoFullName;
    if (defaultBranch != null) body['defaultBranch'] = defaultBranch;
    if (techStack != null) body['techStack'] = techStack;
    if (healthCheckUrl != null) body['healthCheckUrl'] = healthCheckUrl;
    if (healthCheckIntervalSeconds != null) {
      body['healthCheckIntervalSeconds'] = healthCheckIntervalSeconds;
    }
    if (environmentsJson != null) body['environmentsJson'] = environmentsJson;
    if (metadataJson != null) body['metadataJson'] = metadataJson;

    final response = await _client.put<Map<String, dynamic>>(
      '/services/$serviceId',
      data: body,
    );
    return ServiceRegistrationResponse.fromJson(response.data!);
  }

  /// Deletes a service registration.
  Future<void> deleteService(String serviceId) async {
    await _client.delete('/services/$serviceId');
  }

  /// Updates a service's lifecycle status.
  Future<ServiceRegistrationResponse> updateServiceStatus(
    String serviceId, {
    required ServiceStatus status,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/services/$serviceId/status',
      data: {'status': status.toJson()},
    );
    return ServiceRegistrationResponse.fromJson(response.data!);
  }

  /// Clones a service under a new name.
  Future<ServiceRegistrationResponse> cloneService(
    String serviceId, {
    required String newName,
    String? newSlug,
  }) async {
    final body = <String, dynamic>{'newName': newName};
    if (newSlug != null) body['newSlug'] = newSlug;

    final response = await _client.post<Map<String, dynamic>>(
      '/services/$serviceId/clone',
      data: body,
    );
    return ServiceRegistrationResponse.fromJson(response.data!);
  }

  /// Assembles the complete service identity.
  Future<ServiceIdentityResponse> getServiceIdentity(
    String serviceId, {
    String? environment,
  }) async {
    final params = <String, dynamic>{};
    if (environment != null) params['environment'] = environment;

    final response = await _client.get<Map<String, dynamic>>(
      '/services/$serviceId/identity',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return ServiceIdentityResponse.fromJson(response.data!);
  }

  /// Checks the health of a single service.
  Future<ServiceHealthResponse> checkServiceHealth(
      String serviceId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/services/$serviceId/health',
    );
    return ServiceHealthResponse.fromJson(response.data!);
  }

  /// Checks health of all active services for a team in parallel.
  Future<List<ServiceHealthResponse>> checkAllServiceHealth(
      String teamId) async {
    final response = await _client.post<List<dynamic>>(
      '/teams/$teamId/services/health',
    );
    return response.data!
        .map((e) =>
            ServiceHealthResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Retrieves a service by team ID and slug.
  Future<ServiceRegistrationResponse> getServiceBySlug(
    String teamId,
    String slug,
  ) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/services/by-slug/$slug',
    );
    return ServiceRegistrationResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Solutions (11 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new solution for a team.
  Future<SolutionResponse> createSolution({
    required String teamId,
    required String name,
    required SolutionCategory category,
    String? slug,
    String? description,
    String? iconName,
    String? colorHex,
    String? ownerUserId,
    String? repositoryUrl,
    String? documentationUrl,
    String? metadataJson,
  }) async {
    final body = <String, dynamic>{
      'teamId': teamId,
      'name': name,
      'category': category.toJson(),
    };
    if (slug != null) body['slug'] = slug;
    if (description != null) body['description'] = description;
    if (iconName != null) body['iconName'] = iconName;
    if (colorHex != null) body['colorHex'] = colorHex;
    if (ownerUserId != null) body['ownerUserId'] = ownerUserId;
    if (repositoryUrl != null) body['repositoryUrl'] = repositoryUrl;
    if (documentationUrl != null) body['documentationUrl'] = documentationUrl;
    if (metadataJson != null) body['metadataJson'] = metadataJson;

    final response = await _client.post<Map<String, dynamic>>(
      '/teams/$teamId/solutions',
      data: body,
    );
    return SolutionResponse.fromJson(response.data!);
  }

  /// Lists solutions for a team with optional filtering.
  Future<PageResponse<SolutionResponse>> getSolutionsForTeam(
    String teamId, {
    SolutionStatus? status,
    SolutionCategory? category,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (status != null) params['status'] = status.toJson();
    if (category != null) params['category'] = category.toJson();

    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/solutions',
      queryParameters: params,
    );
    return PageResponse.fromJson(
      response.data!,
      (json) =>
          SolutionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Retrieves a single solution by ID.
  Future<SolutionResponse> getSolution(String solutionId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/solutions/$solutionId',
    );
    return SolutionResponse.fromJson(response.data!);
  }

  /// Updates a solution.
  Future<SolutionResponse> updateSolution(
    String solutionId, {
    String? name,
    String? description,
    SolutionCategory? category,
    SolutionStatus? status,
    String? iconName,
    String? colorHex,
    String? ownerUserId,
    String? repositoryUrl,
    String? documentationUrl,
    String? metadataJson,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category.toJson();
    if (status != null) body['status'] = status.toJson();
    if (iconName != null) body['iconName'] = iconName;
    if (colorHex != null) body['colorHex'] = colorHex;
    if (ownerUserId != null) body['ownerUserId'] = ownerUserId;
    if (repositoryUrl != null) body['repositoryUrl'] = repositoryUrl;
    if (documentationUrl != null) body['documentationUrl'] = documentationUrl;
    if (metadataJson != null) body['metadataJson'] = metadataJson;

    final response = await _client.put<Map<String, dynamic>>(
      '/solutions/$solutionId',
      data: body,
    );
    return SolutionResponse.fromJson(response.data!);
  }

  /// Deletes a solution.
  Future<void> deleteSolution(String solutionId) async {
    await _client.delete('/solutions/$solutionId');
  }

  /// Retrieves full solution detail including member list.
  Future<SolutionDetailResponse> getSolutionDetail(
      String solutionId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/solutions/$solutionId/detail',
    );
    return SolutionDetailResponse.fromJson(response.data!);
  }

  /// Adds a service as a member of a solution.
  Future<SolutionMemberResponse> addSolutionMember(
    String solutionId, {
    required String serviceId,
    required SolutionMemberRole role,
    int? displayOrder,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'serviceId': serviceId,
      'role': role.toJson(),
    };
    if (displayOrder != null) body['displayOrder'] = displayOrder;
    if (notes != null) body['notes'] = notes;

    final response = await _client.post<Map<String, dynamic>>(
      '/solutions/$solutionId/members',
      data: body,
    );
    return SolutionMemberResponse.fromJson(response.data!);
  }

  /// Updates a solution member's role, display order, or notes.
  Future<SolutionMemberResponse> updateSolutionMember(
    String solutionId,
    String serviceId, {
    SolutionMemberRole? role,
    int? displayOrder,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (role != null) body['role'] = role.toJson();
    if (displayOrder != null) body['displayOrder'] = displayOrder;
    if (notes != null) body['notes'] = notes;

    final response = await _client.put<Map<String, dynamic>>(
      '/solutions/$solutionId/members/$serviceId',
      data: body,
    );
    return SolutionMemberResponse.fromJson(response.data!);
  }

  /// Removes a service from a solution.
  Future<void> removeSolutionMember(
    String solutionId,
    String serviceId,
  ) async {
    await _client.delete('/solutions/$solutionId/members/$serviceId');
  }

  /// Reorders members within a solution.
  Future<List<SolutionMemberResponse>> reorderSolutionMembers(
    String solutionId,
    List<String> orderedServiceIds,
  ) async {
    final response = await _client.put<List<dynamic>>(
      '/solutions/$solutionId/members/reorder',
      data: orderedServiceIds,
    );
    return response.data!
        .map((e) =>
            SolutionMemberResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns aggregated health status for a solution.
  Future<SolutionHealthResponse> getSolutionHealth(
      String solutionId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/solutions/$solutionId/health',
    );
    return SolutionHealthResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Dependencies (6 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a directed dependency edge between two services.
  Future<ServiceDependencyResponse> createDependency({
    required String sourceServiceId,
    required String targetServiceId,
    required DependencyType dependencyType,
    String? description,
    bool? isRequired,
    String? targetEndpoint,
  }) async {
    final body = <String, dynamic>{
      'sourceServiceId': sourceServiceId,
      'targetServiceId': targetServiceId,
      'dependencyType': dependencyType.toJson(),
    };
    if (description != null) body['description'] = description;
    if (isRequired != null) body['isRequired'] = isRequired;
    if (targetEndpoint != null) body['targetEndpoint'] = targetEndpoint;

    final response = await _client.post<Map<String, dynamic>>(
      '/dependencies',
      data: body,
    );
    return ServiceDependencyResponse.fromJson(response.data!);
  }

  /// Removes a dependency edge by ID.
  Future<void> removeDependency(String dependencyId) async {
    await _client.delete('/dependencies/$dependencyId');
  }

  /// Builds the complete dependency graph for a team.
  Future<DependencyGraphResponse> getDependencyGraph(
      String teamId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/dependencies/graph',
    );
    return DependencyGraphResponse.fromJson(response.data!);
  }

  /// Performs BFS impact analysis from a source service.
  Future<ImpactAnalysisResponse> getImpactAnalysis(
      String serviceId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/services/$serviceId/dependencies/impact',
    );
    return ImpactAnalysisResponse.fromJson(response.data!);
  }

  /// Computes topological startup order using Kahn's algorithm.
  Future<List<DependencyNodeResponse>> getStartupOrder(
      String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/dependencies/startup-order',
    );
    return response.data!
        .map((e) =>
            DependencyNodeResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Detects cycles in the team's dependency graph.
  Future<List<String>> detectCycles(String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/dependencies/cycles',
    );
    return response.data!.map((e) => e as String).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Ports (11 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Auto-allocates the next available port from the team's configured range.
  Future<PortAllocationResponse> autoAllocatePort({
    required String serviceId,
    required String environment,
    required PortType portType,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'serviceId': serviceId,
      'environment': environment,
      'portType': portType.toJson(),
    };
    if (description != null) body['description'] = description;

    final response = await _client.post<Map<String, dynamic>>(
      '/ports/auto-allocate',
      data: body,
    );
    return PortAllocationResponse.fromJson(response.data!);
  }

  /// Manually allocates a specific port number to a service.
  Future<PortAllocationResponse> manualAllocatePort({
    required String serviceId,
    required String environment,
    required PortType portType,
    required int portNumber,
    String? protocol,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'serviceId': serviceId,
      'environment': environment,
      'portType': portType.toJson(),
      'portNumber': portNumber,
    };
    if (protocol != null) body['protocol'] = protocol;
    if (description != null) body['description'] = description;

    final response = await _client.post<Map<String, dynamic>>(
      '/ports/allocate',
      data: body,
    );
    return PortAllocationResponse.fromJson(response.data!);
  }

  /// Releases (deletes) a port allocation.
  Future<void> releasePort(String allocationId) async {
    await _client.delete('/ports/$allocationId');
  }

  /// Lists port allocations for a service.
  Future<List<PortAllocationResponse>> getPortsForService(
    String serviceId, {
    String? environment,
  }) async {
    final params = <String, dynamic>{};
    if (environment != null) params['environment'] = environment;

    final response = await _client.get<List<dynamic>>(
      '/services/$serviceId/ports',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return response.data!
        .map((e) =>
            PortAllocationResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lists all port allocations for a team in a specific environment.
  Future<List<PortAllocationResponse>> getPortsForTeam(
    String teamId, {
    required String environment,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/ports',
      queryParameters: {'environment': environment},
    );
    return response.data!
        .map((e) =>
            PortAllocationResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Assembles the structured port map with ranges and their allocations.
  Future<PortMapResponse> getPortMap(
    String teamId, {
    required String environment,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/ports/map',
      queryParameters: {'environment': environment},
    );
    return PortMapResponse.fromJson(response.data!);
  }

  /// Checks whether a specific port number is available.
  Future<PortCheckResponse> checkPortAvailability(
    String teamId, {
    required int portNumber,
    required String environment,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/ports/check',
      queryParameters: {
        'portNumber': portNumber,
        'environment': environment,
      },
    );
    return PortCheckResponse.fromJson(response.data!);
  }

  /// Detects port conflicts within a team.
  Future<List<PortConflictResponse>> detectPortConflicts(
      String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/ports/conflicts',
    );
    return response.data!
        .map((e) =>
            PortConflictResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lists all port ranges configured for a team.
  Future<List<PortRangeResponse>> getPortRanges(String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/ports/ranges',
    );
    return response.data!
        .map((e) =>
            PortRangeResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Seeds default port ranges for a team.
  Future<List<PortRangeResponse>> seedDefaultRanges(
    String teamId, {
    String environment = 'local',
  }) async {
    final response = await _client.post<List<dynamic>>(
      '/teams/$teamId/ports/ranges/seed',
      queryParameters: {'environment': environment},
    );
    return response.data!
        .map((e) =>
            PortRangeResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Updates a port range's start, end, and optional description.
  Future<PortRangeResponse> updatePortRange(
    String rangeId, {
    required int rangeStart,
    required int rangeEnd,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'rangeStart': rangeStart,
      'rangeEnd': rangeEnd,
    };
    if (description != null) body['description'] = description;

    final response = await _client.put<Map<String, dynamic>>(
      '/ports/ranges/$rangeId',
      data: body,
    );
    return PortRangeResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Routes (5 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registers an API route prefix for a service.
  Future<ApiRouteResponse> createRoute({
    required String serviceId,
    required String routePrefix,
    required String environment,
    String? gatewayServiceId,
    String? httpMethods,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'serviceId': serviceId,
      'routePrefix': routePrefix,
      'environment': environment,
    };
    if (gatewayServiceId != null) body['gatewayServiceId'] = gatewayServiceId;
    if (httpMethods != null) body['httpMethods'] = httpMethods;
    if (description != null) body['description'] = description;

    final response = await _client.post<Map<String, dynamic>>(
      '/routes',
      data: body,
    );
    return ApiRouteResponse.fromJson(response.data!);
  }

  /// Deletes an API route registration.
  Future<void> deleteRoute(String routeId) async {
    await _client.delete('/routes/$routeId');
  }

  /// Lists all routes for a service.
  Future<List<ApiRouteResponse>> getRoutesForService(
      String serviceId) async {
    final response = await _client.get<List<dynamic>>(
      '/services/$serviceId/routes',
    );
    return response.data!
        .map((e) =>
            ApiRouteResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lists all routes behind a specific gateway in an environment.
  Future<List<ApiRouteResponse>> getRoutesForGateway(
    String gatewayServiceId, {
    required String environment,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/services/$gatewayServiceId/routes/gateway',
      queryParameters: {'environment': environment},
    );
    return response.data!
        .map((e) =>
            ApiRouteResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Checks whether a route prefix is available.
  Future<RouteCheckResponse> checkRouteAvailability({
    required String gatewayServiceId,
    required String environment,
    required String routePrefix,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/routes/check',
      queryParameters: {
        'gatewayServiceId': gatewayServiceId,
        'environment': environment,
        'routePrefix': routePrefix,
      },
    );
    return RouteCheckResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Config (6 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generates a configuration template for a service.
  Future<ConfigTemplateResponse> generateConfig(
    String serviceId, {
    required ConfigTemplateType type,
    String environment = 'local',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/services/$serviceId/config/generate',
      queryParameters: {
        'type': type.toJson(),
        'environment': environment,
      },
    );
    return ConfigTemplateResponse.fromJson(response.data!);
  }

  /// Generates all three config types for a service in one call.
  Future<List<ConfigTemplateResponse>> generateAllConfigs(
    String serviceId, {
    String environment = 'local',
  }) async {
    final response = await _client.post<List<dynamic>>(
      '/services/$serviceId/config/generate-all',
      queryParameters: {'environment': environment},
    );
    return response.data!
        .map((e) =>
            ConfigTemplateResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Generates a complete docker-compose.yml for an entire solution.
  Future<ConfigTemplateResponse> generateSolutionDockerCompose(
    String solutionId, {
    String environment = 'local',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/solutions/$solutionId/config/docker-compose',
      queryParameters: {'environment': environment},
    );
    return ConfigTemplateResponse.fromJson(response.data!);
  }

  /// Retrieves a previously generated config template.
  Future<ConfigTemplateResponse> getTemplate(
    String serviceId, {
    required ConfigTemplateType type,
    required String environment,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/services/$serviceId/config',
      queryParameters: {
        'type': type.toJson(),
        'environment': environment,
      },
    );
    return ConfigTemplateResponse.fromJson(response.data!);
  }

  /// Retrieves all templates for a service.
  Future<List<ConfigTemplateResponse>> getTemplatesForService(
      String serviceId) async {
    final response = await _client.get<List<dynamic>>(
      '/services/$serviceId/config/all',
    );
    return response.data!
        .map((e) =>
            ConfigTemplateResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Deletes a config template.
  Future<void> deleteTemplate(String templateId) async {
    await _client.delete('/config/$templateId');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // InfraResources (8 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registers an infrastructure resource.
  Future<InfraResourceResponse> createInfraResource({
    required String teamId,
    required InfraResourceType resourceType,
    required String resourceName,
    required String environment,
    String? serviceId,
    String? region,
    String? arnOrUrl,
    String? metadataJson,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'teamId': teamId,
      'resourceType': resourceType.toJson(),
      'resourceName': resourceName,
      'environment': environment,
    };
    if (serviceId != null) body['serviceId'] = serviceId;
    if (region != null) body['region'] = region;
    if (arnOrUrl != null) body['arnOrUrl'] = arnOrUrl;
    if (metadataJson != null) body['metadataJson'] = metadataJson;
    if (description != null) body['description'] = description;

    final response = await _client.post<Map<String, dynamic>>(
      '/teams/$teamId/infra-resources',
      data: body,
    );
    return InfraResourceResponse.fromJson(response.data!);
  }

  /// Lists infrastructure resources for a team with optional filters.
  Future<PageResponse<InfraResourceResponse>> getInfraResourcesForTeam(
    String teamId, {
    InfraResourceType? type,
    String? environment,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (type != null) params['type'] = type.toJson();
    if (environment != null) params['environment'] = environment;

    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/infra-resources',
      queryParameters: params,
    );
    return PageResponse.fromJson(
      response.data!,
      (json) =>
          InfraResourceResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Updates an infrastructure resource.
  Future<InfraResourceResponse> updateInfraResource(
    String resourceId, {
    String? serviceId,
    String? resourceName,
    String? region,
    String? arnOrUrl,
    String? metadataJson,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (serviceId != null) body['serviceId'] = serviceId;
    if (resourceName != null) body['resourceName'] = resourceName;
    if (region != null) body['region'] = region;
    if (arnOrUrl != null) body['arnOrUrl'] = arnOrUrl;
    if (metadataJson != null) body['metadataJson'] = metadataJson;
    if (description != null) body['description'] = description;

    final response = await _client.put<Map<String, dynamic>>(
      '/infra-resources/$resourceId',
      data: body,
    );
    return InfraResourceResponse.fromJson(response.data!);
  }

  /// Deletes an infrastructure resource.
  Future<void> deleteInfraResource(String resourceId) async {
    await _client.delete('/infra-resources/$resourceId');
  }

  /// Lists all infrastructure resources owned by a specific service.
  Future<List<InfraResourceResponse>> getInfraResourcesForService(
      String serviceId) async {
    final response = await _client.get<List<dynamic>>(
      '/services/$serviceId/infra-resources',
    );
    return response.data!
        .map((e) =>
            InfraResourceResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Finds orphaned resources for a team.
  Future<List<InfraResourceResponse>> findOrphanedResources(
      String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/infra-resources/orphans',
    );
    return response.data!
        .map((e) =>
            InfraResourceResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Reassigns an infrastructure resource to a different service.
  Future<InfraResourceResponse> reassignResource(
    String resourceId, {
    required String newServiceId,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/infra-resources/$resourceId/reassign',
      queryParameters: {'newServiceId': newServiceId},
    );
    return InfraResourceResponse.fromJson(response.data!);
  }

  /// Removes service ownership from a resource, making it orphaned/shared.
  Future<InfraResourceResponse> orphanResource(
      String resourceId) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/infra-resources/$resourceId/orphan',
    );
    return InfraResourceResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Topology (4 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Builds a complete ecosystem topology map for a team.
  Future<TopologyResponse> getTopology(String teamId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/topology',
    );
    return TopologyResponse.fromJson(response.data!);
  }

  /// Builds a topology view filtered to a specific solution.
  Future<TopologyResponse> getSolutionTopology(
      String solutionId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/solutions/$solutionId/topology',
    );
    return TopologyResponse.fromJson(response.data!);
  }

  /// Builds a topology view for a service's dependency neighborhood.
  Future<TopologyResponse> getServiceNeighborhood(
    String serviceId, {
    int depth = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/services/$serviceId/topology/neighborhood',
      queryParameters: {'depth': depth},
    );
    return TopologyResponse.fromJson(response.data!);
  }

  /// Computes quick aggregate statistics for a team's ecosystem.
  Future<TopologyStatsResponse> getEcosystemStats(
      String teamId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/topology/stats',
    );
    return TopologyStatsResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Health Management (6 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Aggregates a health summary for all services in a team (cached data).
  Future<TeamHealthSummaryResponse> getTeamHealthSummary(
      String teamId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/health/summary',
    );
    return TeamHealthSummaryResponse.fromJson(response.data!);
  }

  /// Performs live health checks on all active services for a team.
  Future<TeamHealthSummaryResponse> checkTeamHealth(
      String teamId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/teams/$teamId/health/check',
    );
    return TeamHealthSummaryResponse.fromJson(response.data!);
  }

  /// Returns only DOWN or DEGRADED active services.
  Future<List<ServiceHealthResponse>> getUnhealthyServices(
      String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/health/unhealthy',
    );
    return response.data!
        .map((e) =>
            ServiceHealthResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns services that have never been health-checked.
  Future<List<ServiceHealthResponse>> getServicesNeverChecked(
      String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/health/never-checked',
    );
    return response.data!
        .map((e) =>
            ServiceHealthResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Performs live health checks on all services in a solution.
  Future<SolutionHealthResponse> checkSolutionHealth(
      String solutionId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/solutions/$solutionId/health/check',
    );
    return SolutionHealthResponse.fromJson(response.data!);
  }

  /// Returns the current cached health status for a single service.
  Future<ServiceHealthResponse> getServiceHealthCached(
      String serviceId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/services/$serviceId/health/cached',
    );
    return ServiceHealthResponse.fromJson(response.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Workstations (9 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new workstation profile for a team.
  Future<WorkstationProfileResponse> createWorkstationProfile({
    required String teamId,
    required String name,
    String? description,
    String? solutionId,
    List<String>? serviceIds,
    bool isDefault = false,
  }) async {
    final body = <String, dynamic>{
      'teamId': teamId,
      'name': name,
      'isDefault': isDefault,
    };
    if (description != null) body['description'] = description;
    if (solutionId != null) body['solutionId'] = solutionId;
    if (serviceIds != null) body['serviceIds'] = serviceIds;

    final response = await _client.post<Map<String, dynamic>>(
      '/teams/$teamId/workstations',
      data: body,
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }

  /// Lists all workstation profiles for a team.
  Future<List<WorkstationProfileResponse>> getWorkstationProfilesForTeam(
      String teamId) async {
    final response = await _client.get<List<dynamic>>(
      '/teams/$teamId/workstations',
    );
    return response.data!
        .map((e) => WorkstationProfileResponse.fromJson(
            e as Map<String, dynamic>))
        .toList();
  }

  /// Retrieves a single workstation profile.
  Future<WorkstationProfileResponse> getWorkstationProfile(
      String profileId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/workstations/$profileId',
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }

  /// Updates a workstation profile.
  Future<WorkstationProfileResponse> updateWorkstationProfile(
    String profileId, {
    String? name,
    String? description,
    List<String>? serviceIds,
    bool? isDefault,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (serviceIds != null) body['serviceIds'] = serviceIds;
    if (isDefault != null) body['isDefault'] = isDefault;

    final response = await _client.put<Map<String, dynamic>>(
      '/workstations/$profileId',
      data: body,
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }

  /// Deletes a workstation profile.
  Future<void> deleteWorkstationProfile(String profileId) async {
    await _client.delete('/workstations/$profileId');
  }

  /// Retrieves the team's default workstation profile.
  Future<WorkstationProfileResponse> getDefaultWorkstationProfile(
      String teamId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/teams/$teamId/workstations/default',
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }

  /// Sets a workstation profile as the team's default.
  Future<WorkstationProfileResponse> setDefaultWorkstationProfile(
      String profileId) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/workstations/$profileId/set-default',
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }

  /// Quick-creates a workstation profile from a solution's member services.
  Future<WorkstationProfileResponse> createWorkstationFromSolution(
    String solutionId, {
    required String teamId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/solutions/$solutionId/workstations/from-solution',
      queryParameters: {'teamId': teamId},
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }

  /// Recomputes the startup order for a profile.
  Future<WorkstationProfileResponse> refreshStartupOrder(
      String profileId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/workstations/$profileId/refresh-startup-order',
    );
    return WorkstationProfileResponse.fromJson(response.data!);
  }
}
