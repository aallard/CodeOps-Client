/// API service for the CodeOps-MCP module.
///
/// Provides access to sessions, documents, developer profiles, tokens,
/// activity feeds, and protocol messaging — totaling 27 endpoint methods
/// across 5 controllers.
///
/// All team-scoped endpoints require a `teamId` parameter which is sent
/// as a query parameter.
library;

import '../../models/health_snapshot.dart';
import '../../models/mcp_models.dart';
import 'api_client.dart';

/// API service for CodeOps-MCP.
///
/// Depends on [ApiClient] for HTTP transport with automatic auth and
/// error handling. Uses [ApiClient.dio] directly for all MCP endpoints.
class McpApiService {
  final ApiClient _client;
  static const _base = '/mcp';

  /// Creates a [McpApiService] backed by the given [client].
  McpApiService(this._client);

  // ═══════════════════════════════════════════════════════════════════════════
  // Protocol (1 endpoint — REST only, SSE transport omitted)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sends a JSON-RPC message over HTTP transport.
  ///
  /// POST /api/v1/mcp/protocol/message
  Future<String> sendProtocolMessage(String jsonRpcBody) async {
    final r = await _client.dio.post<String>(
      '$_base/protocol/message',
      data: jsonRpcBody,
    );
    return r.data!;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Sessions (7 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initializes a new MCP session.
  ///
  /// POST /api/v1/mcp/sessions?teamId={teamId}
  Future<McpSessionDetail> initSession({
    required String teamId,
    required Map<String, dynamic> request,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/sessions',
      data: request,
      queryParameters: {'teamId': teamId},
    );
    return McpSessionDetail.fromJson(r.data!);
  }

  /// Completes an active session with writeback results.
  ///
  /// POST /api/v1/mcp/sessions/{sessionId}/complete
  Future<McpSessionDetail> completeSession(
    String sessionId,
    Map<String, dynamic> request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/sessions/$sessionId/complete',
      data: request,
    );
    return McpSessionDetail.fromJson(r.data!);
  }

  /// Gets session detail by ID.
  ///
  /// GET /api/v1/mcp/sessions/{sessionId}
  Future<McpSessionDetail> getSession(String sessionId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/sessions/$sessionId',
    );
    return McpSessionDetail.fromJson(r.data!);
  }

  /// Gets session history for a project.
  ///
  /// GET /api/v1/mcp/sessions/history?projectId={projectId}&limit={limit}
  Future<List<McpSession>> getSessionHistory({
    required String projectId,
    int limit = 10,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/sessions/history',
      queryParameters: {'projectId': projectId, 'limit': limit},
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(McpSession.fromJson)
        .toList();
  }

  /// Gets the current user's sessions (paginated).
  ///
  /// GET /api/v1/mcp/sessions/mine?teamId={teamId}&page={page}&size={size}
  Future<PageResponse<McpSession>> getMySessions({
    required String teamId,
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/sessions/mine',
      queryParameters: {'teamId': teamId, 'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      r.data!,
      (o) => McpSession.fromJson(o as Map<String, dynamic>),
    );
  }

  /// Cancels an active session.
  ///
  /// POST /api/v1/mcp/sessions/{sessionId}/cancel
  Future<McpSession> cancelSession(String sessionId) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/sessions/$sessionId/cancel',
    );
    return McpSession.fromJson(r.data!);
  }

  /// Gets tool call summaries for a session.
  ///
  /// GET /api/v1/mcp/sessions/{sessionId}/tool-calls
  Future<List<ToolCallSummary>> getSessionToolCalls(
    String sessionId,
  ) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/sessions/$sessionId/tool-calls',
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(ToolCallSummary.fromJson)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Documents (9 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new project document.
  ///
  /// POST /api/v1/mcp/documents?projectId={projectId}
  Future<ProjectDocumentDetail> createDocument({
    required String projectId,
    required Map<String, dynamic> request,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/documents',
      data: request,
      queryParameters: {'projectId': projectId},
    );
    return ProjectDocumentDetail.fromJson(r.data!);
  }

  /// Gets all documents for a project.
  ///
  /// GET /api/v1/mcp/documents?projectId={projectId}
  Future<List<ProjectDocument>> getProjectDocuments({
    required String projectId,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/documents',
      queryParameters: {'projectId': projectId},
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(ProjectDocument.fromJson)
        .toList();
  }

  /// Gets a document by project ID and document type.
  ///
  /// GET /api/v1/mcp/documents/by-type?projectId={projectId}&documentType={documentType}
  Future<ProjectDocumentDetail> getDocumentByType({
    required String projectId,
    required String documentType,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/documents/by-type',
      queryParameters: {
        'projectId': projectId,
        'documentType': documentType,
      },
    );
    return ProjectDocumentDetail.fromJson(r.data!);
  }

  /// Updates a document's content and creates a new version.
  ///
  /// PUT /api/v1/mcp/documents/{documentId}
  Future<ProjectDocumentDetail> updateDocument(
    String documentId,
    Map<String, dynamic> request, {
    String? sessionId,
  }) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '$_base/documents/$documentId',
      data: request,
      queryParameters: {
        if (sessionId != null) 'sessionId': sessionId,
      },
    );
    return ProjectDocumentDetail.fromJson(r.data!);
  }

  /// Deletes a document and all its versions.
  ///
  /// DELETE /api/v1/mcp/documents/{documentId}
  Future<void> deleteDocument(String documentId) async {
    await _client.dio.delete<dynamic>(
      '$_base/documents/$documentId',
    );
  }

  /// Gets paginated version history for a document.
  ///
  /// GET /api/v1/mcp/documents/{documentId}/versions
  Future<PageResponse<ProjectDocumentVersion>> getDocumentVersions(
    String documentId, {
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/documents/$documentId/versions',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      r.data!,
      (o) => ProjectDocumentVersion.fromJson(o as Map<String, dynamic>),
    );
  }

  /// Gets a specific version of a document by version number.
  ///
  /// GET /api/v1/mcp/documents/{documentId}/versions/{versionNumber}
  Future<ProjectDocumentVersion> getDocumentVersion(
    String documentId,
    int versionNumber,
  ) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/documents/$documentId/versions/$versionNumber',
    );
    return ProjectDocumentVersion.fromJson(r.data!);
  }

  /// Gets all flagged (stale) documents for a project.
  ///
  /// GET /api/v1/mcp/documents/flagged?projectId={projectId}
  Future<List<ProjectDocument>> getFlaggedDocuments({
    required String projectId,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/documents/flagged',
      queryParameters: {'projectId': projectId},
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(ProjectDocument.fromJson)
        .toList();
  }

  /// Clears the staleness flag on a document.
  ///
  /// POST /api/v1/mcp/documents/{documentId}/clear-flag
  Future<void> clearDocumentFlag(String documentId) async {
    await _client.dio.post<dynamic>(
      '$_base/documents/$documentId/clear-flag',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Developers (7 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gets or creates a developer profile for the current user.
  ///
  /// POST /api/v1/mcp/developers/profile?teamId={teamId}
  Future<DeveloperProfile> getOrCreateProfile({
    required String teamId,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/developers/profile',
      queryParameters: {'teamId': teamId},
    );
    return DeveloperProfile.fromJson(r.data!);
  }

  /// Gets a developer profile by team and user.
  ///
  /// GET /api/v1/mcp/developers/profile?teamId={teamId}&userId={userId}
  Future<DeveloperProfile> getProfile({
    required String teamId,
    required String userId,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/developers/profile',
      queryParameters: {'teamId': teamId, 'userId': userId},
    );
    return DeveloperProfile.fromJson(r.data!);
  }

  /// Lists all active developer profiles for a team.
  ///
  /// GET /api/v1/mcp/developers?teamId={teamId}
  Future<List<DeveloperProfile>> getTeamProfiles({
    required String teamId,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/developers',
      queryParameters: {'teamId': teamId},
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(DeveloperProfile.fromJson)
        .toList();
  }

  /// Updates a developer profile.
  ///
  /// PUT /api/v1/mcp/developers/{profileId}
  Future<DeveloperProfile> updateProfile(
    String profileId,
    Map<String, dynamic> request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '$_base/developers/$profileId',
      data: request,
    );
    return DeveloperProfile.fromJson(r.data!);
  }

  /// Creates an API token for MCP AI agent authentication.
  ///
  /// POST /api/v1/mcp/developers/{profileId}/tokens
  Future<McpApiTokenCreated> createApiToken(
    String profileId,
    Map<String, dynamic> request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '$_base/developers/$profileId/tokens',
      data: request,
    );
    return McpApiTokenCreated.fromJson(r.data!);
  }

  /// Lists all tokens for a developer profile.
  ///
  /// GET /api/v1/mcp/developers/{profileId}/tokens
  Future<List<McpApiToken>> getTokens(String profileId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/developers/$profileId/tokens',
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(McpApiToken.fromJson)
        .toList();
  }

  /// Revokes an API token.
  ///
  /// DELETE /api/v1/mcp/developers/tokens/{tokenId}
  Future<void> revokeToken(String tokenId) async {
    await _client.dio.delete<dynamic>(
      '$_base/developers/tokens/$tokenId',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Activity (3 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gets the team activity feed (paginated).
  ///
  /// GET /api/v1/mcp/activity/team?teamId={teamId}&page={page}&size={size}
  Future<PageResponse<ActivityFeedEntry>> getTeamFeed({
    required String teamId,
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/activity/team',
      queryParameters: {'teamId': teamId, 'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      r.data!,
      (o) => ActivityFeedEntry.fromJson(o as Map<String, dynamic>),
    );
  }

  /// Gets the project activity feed (paginated).
  ///
  /// GET /api/v1/mcp/activity/project?projectId={projectId}&page={page}&size={size}
  Future<PageResponse<ActivityFeedEntry>> getProjectFeed({
    required String projectId,
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '$_base/activity/project',
      queryParameters: {'projectId': projectId, 'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      r.data!,
      (o) => ActivityFeedEntry.fromJson(o as Map<String, dynamic>),
    );
  }

  /// Gets team activity since a timestamp.
  ///
  /// GET /api/v1/mcp/activity/team/since?teamId={teamId}&since={since}
  Future<List<ActivityFeedEntry>> getTeamActivitySince({
    required String teamId,
    required DateTime since,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '$_base/activity/team/since',
      queryParameters: {
        'teamId': teamId,
        'since': since.toUtc().toIso8601String(),
      },
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(ActivityFeedEntry.fromJson)
        .toList();
  }
}
