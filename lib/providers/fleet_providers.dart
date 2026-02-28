/// Riverpod providers for the Fleet module.
///
/// Manages state, exposes API data, and provides the reactive layer
/// between [FleetApiService] and the UI pages.
/// Follows the same patterns as [relay_providers.dart]:
/// [Provider] for singletons, [FutureProvider] for async data,
/// [FutureProvider.family] for parameterized queries.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/fleet_models.dart';
import '../services/cloud/fleet_api.dart';
import 'auth_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core Singleton Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the [FleetApiService] singleton for all Fleet API calls.
///
/// Uses [apiClientProvider] from [auth_providers.dart] since Fleet
/// is a module within the consolidated CodeOps-Server.
final fleetApiProvider = Provider<FleetApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return FleetApiService(client);
});

// ─────────────────────────────────────────────────────────────────────────────
// Health — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches the fleet-wide health summary for a team.
final fleetHealthSummaryProvider =
    FutureProvider.autoDispose.family<FleetHealthSummary, String>(
        (ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.getHealthSummary(teamId);
});

/// Fetches health check history for a container.
final fleetHealthCheckHistoryProvider = FutureProvider.autoDispose
    .family<List<FleetContainerHealthCheck>, String>((ref, containerId) async {
  final api = ref.watch(fleetApiProvider);
  final teamId = ref.watch(selectedTeamIdProvider);
  if (teamId == null) return [];
  return api.getHealthCheckHistory(teamId, containerId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Containers — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all containers for a team.
final fleetContainersProvider = FutureProvider.autoDispose
    .family<List<FleetContainerInstance>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listContainers(teamId);
});

/// Fetches container detail by ID.
final fleetContainerDetailProvider = FutureProvider.autoDispose.family<
    FleetContainerDetail,
    ({String teamId, String containerId})>((ref, params) {
  final api = ref.watch(fleetApiProvider);
  return api.getContainer(params.teamId, params.containerId);
});

/// Fetches container logs by ID.
final fleetContainerLogsProvider = FutureProvider.autoDispose.family<
    List<FleetContainerLog>,
    ({String teamId, String containerId})>((ref, params) {
  final api = ref.watch(fleetApiProvider);
  return api.getContainerLogs(params.teamId, params.containerId);
});

/// Fetches real-time container stats by ID.
final fleetContainerStatsProvider = FutureProvider.autoDispose.family<
    FleetContainerStats,
    ({String teamId, String containerId})>((ref, params) {
  final api = ref.watch(fleetApiProvider);
  return api.getContainerStats(params.teamId, params.containerId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Service Profiles — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all service profiles for a team.
final fleetServiceProfilesProvider = FutureProvider.autoDispose
    .family<List<FleetServiceProfile>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listServiceProfiles(teamId);
});

/// Fetches service profile detail by ID.
final fleetServiceProfileDetailProvider = FutureProvider.autoDispose.family<
    FleetServiceProfileDetail,
    ({String teamId, String profileId})>((ref, params) {
  final api = ref.watch(fleetApiProvider);
  return api.getServiceProfile(params.teamId, params.profileId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Solution Profiles — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all solution profiles for a team.
final fleetSolutionProfilesProvider = FutureProvider.autoDispose
    .family<List<FleetSolutionProfile>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listSolutionProfiles(teamId);
});

/// Fetches solution profile detail by ID.
final fleetSolutionProfileDetailProvider = FutureProvider.autoDispose.family<
    FleetSolutionProfileDetail,
    ({String teamId, String profileId})>((ref, params) {
  final api = ref.watch(fleetApiProvider);
  return api.getSolutionProfile(params.teamId, params.profileId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Workstation Profiles — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all workstation profiles for a team.
final fleetWorkstationProfilesProvider = FutureProvider.autoDispose
    .family<List<FleetWorkstationProfile>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listWorkstationProfiles(teamId);
});

/// Fetches workstation profile detail by ID.
final fleetWorkstationProfileDetailProvider = FutureProvider.autoDispose
    .family<FleetWorkstationProfileDetail,
        ({String teamId, String profileId})>((ref, params) {
  final api = ref.watch(fleetApiProvider);
  return api.getWorkstationProfile(params.teamId, params.profileId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Docker Resources — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all Docker images for a team.
final fleetImagesProvider = FutureProvider.autoDispose
    .family<List<FleetDockerImage>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listImages(teamId);
});

/// Fetches all Docker volumes for a team.
final fleetVolumesProvider = FutureProvider.autoDispose
    .family<List<FleetDockerVolume>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listVolumes(teamId);
});

/// Fetches all Docker networks for a team.
final fleetNetworksProvider = FutureProvider.autoDispose
    .family<List<FleetDockerNetwork>, String>((ref, teamId) {
  final api = ref.watch(fleetApiProvider);
  return api.listNetworks(teamId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Internal helper — selected team ID
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the currently selected team ID from secure storage.
///
/// Used internally by providers that need the team ID without
/// it being passed as a parameter.
final selectedTeamIdProvider = StateProvider<String?>((ref) => null);
