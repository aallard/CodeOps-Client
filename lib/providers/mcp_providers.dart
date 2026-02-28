/// Riverpod providers for the MCP module.
///
/// Manages state, exposes API data, and provides the reactive layer
/// between [McpApiService] and the UI pages.
/// Follows the same patterns as [fleet_providers.dart]:
/// [Provider] for singletons, [FutureProvider] for async data,
/// [FutureProvider.family] for parameterized queries.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_snapshot.dart';
import '../models/mcp_enums.dart';
import '../models/mcp_models.dart';
import '../services/cloud/mcp_api.dart';
import 'auth_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core Singleton Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the [McpApiService] singleton for all MCP API calls.
///
/// Uses [apiClientProvider] from [auth_providers.dart] since MCP
/// is a module within the consolidated CodeOps-Server.
final mcpApiProvider = Provider<McpApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return McpApiService(client);
});

// ─────────────────────────────────────────────────────────────────────────────
// Developer Profile — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Gets or creates the current user's developer profile for a team.
final mcpProfileProvider = FutureProvider.autoDispose
    .family<DeveloperProfile, String>((ref, teamId) {
  final api = ref.watch(mcpApiProvider);
  return api.getOrCreateProfile(teamId: teamId);
});

/// Fetches all active developer profiles for a team.
final mcpTeamProfilesProvider = FutureProvider.autoDispose
    .family<List<DeveloperProfile>, String>((ref, teamId) {
  final api = ref.watch(mcpApiProvider);
  return api.getTeamProfiles(teamId: teamId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Sessions — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches session history for a project.
final mcpSessionHistoryProvider = FutureProvider.autoDispose
    .family<List<McpSession>, String>((ref, projectId) {
  final api = ref.watch(mcpApiProvider);
  return api.getSessionHistory(projectId: projectId);
});

/// Fetches session detail by ID.
final mcpSessionDetailProvider = FutureProvider.autoDispose
    .family<McpSessionDetail, String>((ref, sessionId) {
  final api = ref.watch(mcpApiProvider);
  return api.getSession(sessionId);
});

/// Fetches the current user's sessions (paginated) for a team.
final mcpMySessionsProvider = FutureProvider.autoDispose
    .family<PageResponse<McpSession>, String>((ref, teamId) {
  final api = ref.watch(mcpApiProvider);
  return api.getMySessions(teamId: teamId);
});

/// Fetches tool call summaries for a session.
final mcpSessionToolCallsProvider = FutureProvider.autoDispose
    .family<List<ToolCallSummary>, String>((ref, sessionId) {
  final api = ref.watch(mcpApiProvider);
  return api.getSessionToolCalls(sessionId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Documents — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all documents for a project.
final mcpProjectDocumentsProvider = FutureProvider.autoDispose
    .family<List<ProjectDocument>, String>((ref, projectId) {
  final api = ref.watch(mcpApiProvider);
  return api.getProjectDocuments(projectId: projectId);
});

/// Fetches a document by type for a project.
final mcpDocumentByTypeProvider = FutureProvider.autoDispose.family<
    ProjectDocumentDetail,
    ({String projectId, String documentType})>((ref, params) {
  final api = ref.watch(mcpApiProvider);
  return api.getDocumentByType(
    projectId: params.projectId,
    documentType: params.documentType,
  );
});

/// Fetches flagged (stale) documents for a project.
final mcpFlaggedDocumentsProvider = FutureProvider.autoDispose
    .family<List<ProjectDocument>, String>((ref, projectId) {
  final api = ref.watch(mcpApiProvider);
  return api.getFlaggedDocuments(projectId: projectId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Activity — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches the team activity feed (paginated).
final mcpTeamFeedProvider = FutureProvider.autoDispose
    .family<PageResponse<ActivityFeedEntry>, String>((ref, teamId) {
  final api = ref.watch(mcpApiProvider);
  return api.getTeamFeed(teamId: teamId);
});

/// Fetches the project activity feed (paginated).
final mcpProjectFeedProvider = FutureProvider.autoDispose
    .family<PageResponse<ActivityFeedEntry>, String>((ref, projectId) {
  final api = ref.watch(mcpApiProvider);
  return api.getProjectFeed(projectId: projectId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Tokens — Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches API tokens for a developer profile.
final mcpTokensProvider = FutureProvider.autoDispose
    .family<List<McpApiToken>, String>((ref, profileId) {
  final api = ref.watch(mcpApiProvider);
  return api.getTokens(profileId);
});

// ─────────────────────────────────────────────────────────────────────────────
// UI State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Selected session ID for detail navigation.
final selectedMcpSessionIdProvider = StateProvider<String?>((ref) => null);

/// Selected document ID for detail navigation.
final selectedMcpDocumentIdProvider = StateProvider<String?>((ref) => null);

/// Selected activity type filter.
final mcpActivityTypeFilterProvider = StateProvider<ActivityType?>((ref) => null);
