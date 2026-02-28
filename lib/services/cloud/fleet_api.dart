/// API service for the CodeOps-Fleet module.
///
/// Provides access to containers, service profiles, solution profiles,
/// workstation profiles, health monitoring, Docker images, volumes,
/// and networks — totaling 53 endpoint methods across 8 controllers.
///
/// All team-scoped endpoints require a `teamId` parameter which is sent
/// as a query parameter.
library;

import 'package:dio/dio.dart';

import '../../models/fleet_enums.dart';
import '../../models/fleet_models.dart';
import 'api_client.dart';

/// API service for CodeOps-Fleet.
///
/// Depends on [ApiClient] for HTTP transport with automatic auth and
/// error handling. Uses [ApiClient.dio] directly to attach the
/// `X-Team-ID` header required by Fleet endpoints.
class FleetApiService {
  final ApiClient _client;
  static const _base = '/fleet';

  /// Creates a [FleetApiService] backed by the given [client].
  FleetApiService(this._client);

  /// Builds [Options] with the `X-Team-ID` header.
  Options _teamOpts(String teamId) =>
      Options(headers: {'X-Team-ID': teamId});

  // ═══════════════════════════════════════════════════════════════════════════
  // Health (5 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gets the fleet-wide health summary.
  Future<FleetHealthSummary> getHealthSummary(String teamId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/health/summary',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetHealthSummary.fromJson(r.data!);
  }

  /// Runs a health check on a single container.
  Future<FleetContainerHealthCheck> checkContainerHealth(
    String teamId,
    String containerId,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/health/containers/$containerId/check',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetContainerHealthCheck.fromJson(r.data!);
  }

  /// Runs health checks on all running containers.
  Future<List<FleetContainerHealthCheck>> checkAllContainerHealth(
    String teamId,
  ) async {
    final r = await _client.dio.post<List<dynamic>>(
      '$_base/health/containers/check-all',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerHealthCheck.fromJson)
        .toList();
  }

  /// Gets health check history for a container.
  Future<List<FleetContainerHealthCheck>> getHealthCheckHistory(
    String teamId,
    String containerId, {
    int limit = 20,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/health/containers/$containerId/history',
      queryParameters: {'teamId': teamId, 'limit': limit},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerHealthCheck.fromJson)
        .toList();
  }

  /// Purges old health check records.
  Future<int> purgeOldHealthChecks(String teamId) async {
    final r = await _client.dio.post<int>(
      '$_base/health/purge',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Containers (11 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all containers for a team.
  Future<List<FleetContainerInstance>> listContainers(String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/containers',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerInstance.fromJson)
        .toList();
  }

  /// Starts a new container from a service profile.
  Future<FleetContainerDetail> startContainer(
    String teamId,
    StartContainerRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/containers',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetContainerDetail.fromJson(r.data!);
  }

  /// Lists containers filtered by status.
  Future<List<FleetContainerInstance>> listContainersByStatus(
    String teamId,
    ContainerStatus status,
  ) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/containers/by-status',
      queryParameters: {'teamId': teamId, 'status': status.toJson()},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerInstance.fromJson)
        .toList();
  }

  /// Syncs local container state with Docker daemon.
  Future<void> syncContainers(String teamId) async {
    await _client.dio.post<dynamic>(
      '$_base/containers/sync',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Inspects a container by ID.
  Future<FleetContainerDetail> getContainer(
    String teamId,
    String containerId,
  ) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/containers/$containerId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetContainerDetail.fromJson(r.data!);
  }

  /// Removes a container.
  Future<void> removeContainer(
    String teamId,
    String containerId, {
    bool force = false,
  }) async {
    await _client.dio.delete<dynamic>(
      '$_base/containers/$containerId',
      queryParameters: {'teamId': teamId, 'force': force},
      options: _teamOpts(teamId),
    );
  }

  /// Stops a running container.
  Future<FleetContainerDetail> stopContainer(
    String teamId,
    String containerId, {
    int timeoutSeconds = 10,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/containers/$containerId/stop',
      queryParameters: {
        'teamId': teamId,
        'timeoutSeconds': timeoutSeconds,
      },
      options: _teamOpts(teamId),
    );
    return FleetContainerDetail.fromJson(r.data!);
  }

  /// Restarts a container.
  Future<FleetContainerDetail> restartContainer(
    String teamId,
    String containerId, {
    int timeoutSeconds = 10,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/containers/$containerId/restart',
      queryParameters: {
        'teamId': teamId,
        'timeoutSeconds': timeoutSeconds,
      },
      options: _teamOpts(teamId),
    );
    return FleetContainerDetail.fromJson(r.data!);
  }

  /// Gets container logs.
  Future<List<FleetContainerLog>> getContainerLogs(
    String teamId,
    String containerId, {
    int tail = 100,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/containers/$containerId/logs',
      queryParameters: {'teamId': teamId, 'tail': tail},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerLog.fromJson)
        .toList();
  }

  /// Gets real-time container stats.
  Future<FleetContainerStats> getContainerStats(
    String teamId,
    String containerId,
  ) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/containers/$containerId/stats',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetContainerStats.fromJson(r.data!);
  }

  /// Executes a command inside a running container.
  Future<String> execInContainer(
    String teamId,
    String containerId,
    ContainerExecRequest request,
  ) async {
    final r = await _client.dio.post<String>(
      '$_base/containers/$containerId/exec',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Service Profiles (6 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all service profiles for a team.
  Future<List<FleetServiceProfile>> listServiceProfiles(
    String teamId,
  ) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/service-profiles',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetServiceProfile.fromJson)
        .toList();
  }

  /// Creates a new service profile.
  Future<FleetServiceProfileDetail> createServiceProfile(
    String teamId,
    CreateServiceProfileRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/service-profiles',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetServiceProfileDetail.fromJson(r.data!);
  }

  /// Gets a service profile by ID.
  Future<FleetServiceProfileDetail> getServiceProfile(
    String teamId,
    String profileId,
  ) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/service-profiles/$profileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetServiceProfileDetail.fromJson(r.data!);
  }

  /// Updates a service profile.
  Future<FleetServiceProfileDetail> updateServiceProfile(
    String teamId,
    String profileId,
    UpdateServiceProfileRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '$_base/service-profiles/$profileId',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetServiceProfileDetail.fromJson(r.data!);
  }

  /// Deletes a service profile.
  Future<void> deleteServiceProfile(
    String teamId,
    String profileId,
  ) async {
    await _client.dio.delete<dynamic>(
      '$_base/service-profiles/$profileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Auto-generates a service profile from a service registration.
  Future<FleetServiceProfileDetail> autoGenerateProfile(
    String teamId,
    String serviceRegistrationId,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/service-profiles/auto-generate',
      queryParameters: {
        'teamId': teamId,
        'serviceRegistrationId': serviceRegistrationId,
      },
      options: _teamOpts(teamId),
    );
    return FleetServiceProfileDetail.fromJson(r.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Solution Profiles (9 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all solution profiles for a team.
  Future<List<FleetSolutionProfile>> listSolutionProfiles(
    String teamId,
  ) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/solution-profiles',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetSolutionProfile.fromJson)
        .toList();
  }

  /// Creates a new solution profile.
  Future<FleetSolutionProfileDetail> createSolutionProfile(
    String teamId,
    CreateSolutionProfileRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/solution-profiles',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetSolutionProfileDetail.fromJson(r.data!);
  }

  /// Gets a solution profile by ID.
  Future<FleetSolutionProfileDetail> getSolutionProfile(
    String teamId,
    String profileId,
  ) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/solution-profiles/$profileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetSolutionProfileDetail.fromJson(r.data!);
  }

  /// Updates a solution profile.
  Future<FleetSolutionProfileDetail> updateSolutionProfile(
    String teamId,
    String profileId,
    UpdateSolutionProfileRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '$_base/solution-profiles/$profileId',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetSolutionProfileDetail.fromJson(r.data!);
  }

  /// Deletes a solution profile.
  Future<void> deleteSolutionProfile(
    String teamId,
    String profileId,
  ) async {
    await _client.dio.delete<dynamic>(
      '$_base/solution-profiles/$profileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Adds a service to a solution profile.
  Future<FleetSolutionService> addServiceToSolution(
    String teamId,
    String profileId,
    AddSolutionServiceRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/solution-profiles/$profileId/services',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetSolutionService.fromJson(r.data!);
  }

  /// Removes a service from a solution profile.
  Future<void> removeServiceFromSolution(
    String teamId,
    String profileId,
    String serviceProfileId,
  ) async {
    await _client.dio.delete<dynamic>(
      '$_base/solution-profiles/$profileId/services/$serviceProfileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Starts all containers defined in a solution profile.
  Future<List<FleetContainerInstance>> startSolution(
    String teamId,
    String profileId,
  ) async {
    final r = await _client.dio.post<List<dynamic>>(
      '$_base/solution-profiles/$profileId/start',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerInstance.fromJson)
        .toList();
  }

  /// Stops all containers defined in a solution profile.
  Future<void> stopSolution(String teamId, String profileId) async {
    await _client.dio.post<dynamic>(
      '$_base/solution-profiles/$profileId/stop',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Workstation Profiles (9 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all workstation profiles for a team.
  Future<List<FleetWorkstationProfile>> listWorkstationProfiles(
    String teamId,
  ) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/workstation-profiles',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetWorkstationProfile.fromJson)
        .toList();
  }

  /// Creates a new workstation profile.
  Future<FleetWorkstationProfileDetail> createWorkstationProfile(
    String teamId,
    CreateWorkstationProfileRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/workstation-profiles',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetWorkstationProfileDetail.fromJson(r.data!);
  }

  /// Gets a workstation profile by ID.
  Future<FleetWorkstationProfileDetail> getWorkstationProfile(
    String teamId,
    String profileId,
  ) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/workstation-profiles/$profileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetWorkstationProfileDetail.fromJson(r.data!);
  }

  /// Updates a workstation profile.
  Future<FleetWorkstationProfileDetail> updateWorkstationProfile(
    String teamId,
    String profileId,
    UpdateWorkstationProfileRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '$_base/workstation-profiles/$profileId',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetWorkstationProfileDetail.fromJson(r.data!);
  }

  /// Deletes a workstation profile.
  Future<void> deleteWorkstationProfile(
    String teamId,
    String profileId,
  ) async {
    await _client.dio.delete<dynamic>(
      '$_base/workstation-profiles/$profileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Adds a solution to a workstation profile.
  Future<FleetWorkstationSolution> addSolutionToWorkstation(
    String teamId,
    String profileId,
    AddWorkstationSolutionRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/workstation-profiles/$profileId/solutions',
      data: request.toJson(),
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return FleetWorkstationSolution.fromJson(r.data!);
  }

  /// Removes a solution from a workstation profile.
  Future<void> removeSolutionFromWorkstation(
    String teamId,
    String profileId,
    String solutionProfileId,
  ) async {
    await _client.dio.delete<dynamic>(
      '$_base/workstation-profiles/$profileId/solutions/$solutionProfileId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Starts all containers defined in a workstation profile.
  Future<List<FleetContainerInstance>> startWorkstation(
    String teamId,
    String profileId,
  ) async {
    final r = await _client.dio.post<List<dynamic>>(
      '$_base/workstation-profiles/$profileId/start',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetContainerInstance.fromJson)
        .toList();
  }

  /// Stops all containers defined in a workstation profile.
  Future<void> stopWorkstation(String teamId, String profileId) async {
    await _client.dio.post<dynamic>(
      '$_base/workstation-profiles/$profileId/stop',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Images (4 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all Docker images.
  Future<List<FleetDockerImage>> listImages(String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/images',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetDockerImage.fromJson)
        .toList();
  }

  /// Pulls a Docker image.
  Future<void> pullImage(
    String teamId,
    String imageName, {
    String tag = 'latest',
  }) async {
    await _client.dio.post<dynamic>(
      '$_base/images/pull',
      queryParameters: {
        'teamId': teamId,
        'imageName': imageName,
        'tag': tag,
      },
      options: _teamOpts(teamId),
    );
  }

  /// Removes a Docker image.
  Future<void> removeImage(
    String teamId,
    String imageId, {
    bool force = false,
  }) async {
    await _client.dio.delete<dynamic>(
      '$_base/images/$imageId',
      queryParameters: {'teamId': teamId, 'force': force},
      options: _teamOpts(teamId),
    );
  }

  /// Prunes unused Docker images.
  Future<void> pruneImages(String teamId) async {
    await _client.dio.post<dynamic>(
      '$_base/images/prune',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Volumes (4 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all Docker volumes.
  Future<List<FleetDockerVolume>> listVolumes(String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/volumes',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetDockerVolume.fromJson)
        .toList();
  }

  /// Creates a new Docker volume.
  Future<FleetDockerVolume> createVolume(
    String teamId,
    String name, {
    String driver = 'local',
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/volumes',
      queryParameters: {
        'teamId': teamId,
        'name': name,
        'driver': driver,
      },
      options: _teamOpts(teamId),
    );
    return FleetDockerVolume.fromJson(r.data!);
  }

  /// Removes a Docker volume.
  Future<void> removeVolume(
    String teamId,
    String name, {
    bool force = false,
  }) async {
    await _client.dio.delete<dynamic>(
      '$_base/volumes/$name',
      queryParameters: {'teamId': teamId, 'force': force},
      options: _teamOpts(teamId),
    );
  }

  /// Prunes unused Docker volumes.
  Future<void> pruneVolumes(String teamId) async {
    await _client.dio.post<dynamic>(
      '$_base/volumes/prune',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Networks (5 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all Docker networks.
  Future<List<FleetDockerNetwork>> listNetworks(String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/networks',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FleetDockerNetwork.fromJson)
        .toList();
  }

  /// Creates a new Docker network.
  Future<FleetDockerNetwork> createNetwork(
    String teamId,
    String name, {
    String driver = 'bridge',
    String? subnet,
    String? gateway,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/networks',
      queryParameters: {
        'teamId': teamId,
        'name': name,
        'driver': driver,
        if (subnet != null) 'subnet': subnet,
        if (gateway != null) 'gateway': gateway,
      },
      options: _teamOpts(teamId),
    );
    return FleetDockerNetwork.fromJson(r.data!);
  }

  /// Removes a Docker network.
  Future<void> removeNetwork(String teamId, String networkId) async {
    await _client.dio.delete<dynamic>(
      '$_base/networks/$networkId',
      queryParameters: {'teamId': teamId},
      options: _teamOpts(teamId),
    );
  }

  /// Connects a container to a network.
  Future<void> connectContainerToNetwork(
    String teamId,
    String networkId,
    String containerId,
  ) async {
    await _client.dio.post<dynamic>(
      '$_base/networks/$networkId/connect',
      queryParameters: {'teamId': teamId, 'containerId': containerId},
      options: _teamOpts(teamId),
    );
  }

  /// Disconnects a container from a network.
  Future<void> disconnectContainerFromNetwork(
    String teamId,
    String networkId,
    String containerId,
  ) async {
    await _client.dio.post<dynamic>(
      '$_base/networks/$networkId/disconnect',
      queryParameters: {'teamId': teamId, 'containerId': containerId},
      options: _teamOpts(teamId),
    );
  }
}
