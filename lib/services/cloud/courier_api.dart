/// API service for the CodeOps-Courier module.
///
/// Provides access to collections, folders, requests, environments,
/// variables, HTTP proxy, GraphQL, runner, import/export, code generation,
/// sharing, and forking — totaling 79 endpoint methods across 13 controllers.
///
/// All team-scoped endpoints require a `teamId` parameter which is sent
/// as the `X-Team-ID` header.
library;

import 'package:dio/dio.dart';

import '../../models/courier_enums.dart';
import '../../models/courier_models.dart';
import '../../models/health_snapshot.dart';
import 'api_client.dart';

/// API service for CodeOps-Courier.
///
/// Depends on [ApiClient] for HTTP transport with automatic auth and
/// error handling. Uses [ApiClient.dio] directly to attach the
/// `X-Team-ID` header required by Courier endpoints.
class CourierApiService {
  final ApiClient _client;

  /// Creates a [CourierApiService] backed by the given [client].
  CourierApiService(this._client);

  /// Builds [Options] with the `X-Team-ID` header.
  Options _teamOpts(String teamId) =>
      Options(headers: {'X-Team-ID': teamId});

  // ═══════════════════════════════════════════════════════════════════════════
  // Collections
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new collection.
  Future<CollectionResponse> createCollection(
    String teamId,
    CreateCollectionRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/collections',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return CollectionResponse.fromJson(r.data!);
  }

  /// Lists all collections for the team.
  Future<List<CollectionSummaryResponse>> getCollections(
      String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/collections',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(CollectionSummaryResponse.fromJson)
        .toList();
  }

  /// Lists collections with pagination.
  Future<PageResponse<CollectionSummaryResponse>> getCollectionsPaged(
    String teamId, {
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/collections/paged',
      queryParameters: {'page': page, 'size': size},
      options: _teamOpts(teamId),
    );
    return PageResponse.fromJson(
        r.data!, (o) => CollectionSummaryResponse.fromJson(o as Map<String, dynamic>));
  }

  /// Searches collections by query string.
  Future<List<CollectionSummaryResponse>> searchCollections(
    String teamId, {
    required String query,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/collections/search',
      queryParameters: {'query': query},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(CollectionSummaryResponse.fromJson)
        .toList();
  }

  /// Gets a collection by ID.
  Future<CollectionResponse> getCollection(
      String teamId, String collectionId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/collections/$collectionId',
      options: _teamOpts(teamId),
    );
    return CollectionResponse.fromJson(r.data!);
  }

  /// Updates a collection.
  Future<CollectionResponse> updateCollection(
    String teamId,
    String collectionId,
    UpdateCollectionRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/collections/$collectionId',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return CollectionResponse.fromJson(r.data!);
  }

  /// Deletes a collection.
  Future<void> deleteCollection(String teamId, String collectionId) async {
    await _client.dio.delete<dynamic>(
      '/courier/collections/$collectionId',
      options: _teamOpts(teamId),
    );
  }

  /// Duplicates a collection.
  Future<CollectionResponse> duplicateCollection(
      String teamId, String collectionId) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/collections/$collectionId/duplicate',
      options: _teamOpts(teamId),
    );
    return CollectionResponse.fromJson(r.data!);
  }

  /// Gets the folder tree for a collection.
  Future<List<FolderTreeResponse>> getCollectionTree(
      String teamId, String collectionId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/collections/$collectionId/tree',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FolderTreeResponse.fromJson)
        .toList();
  }

  /// Exports a collection in the specified format.
  Future<ExportCollectionResponse> exportCollection(
    String teamId,
    String collectionId, {
    required String format,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/collections/$collectionId/export/$format',
      options: _teamOpts(teamId),
    );
    return ExportCollectionResponse.fromJson(r.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Folders
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new folder.
  Future<FolderResponse> createFolder(
    String teamId,
    CreateFolderRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/folders',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return FolderResponse.fromJson(r.data!);
  }

  /// Gets a folder by ID.
  Future<FolderResponse> getFolder(String teamId, String folderId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/folders/$folderId',
      options: _teamOpts(teamId),
    );
    return FolderResponse.fromJson(r.data!);
  }

  /// Updates a folder.
  Future<FolderResponse> updateFolder(
    String teamId,
    String folderId,
    UpdateFolderRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/folders/$folderId',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return FolderResponse.fromJson(r.data!);
  }

  /// Deletes a folder.
  Future<void> deleteFolder(String teamId, String folderId) async {
    await _client.dio.delete<dynamic>(
      '/courier/folders/$folderId',
      options: _teamOpts(teamId),
    );
  }

  /// Gets subfolders of a folder.
  Future<List<FolderResponse>> getSubfolders(
      String teamId, String folderId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/folders/$folderId/subfolders',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FolderResponse.fromJson)
        .toList();
  }

  /// Gets requests within a folder.
  Future<List<RequestSummaryResponse>> getFolderRequests(
      String teamId, String folderId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/folders/$folderId/requests',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(RequestSummaryResponse.fromJson)
        .toList();
  }

  /// Reorders folders.
  Future<List<FolderResponse>> reorderFolders(
    String teamId,
    ReorderFolderRequest request,
  ) async {
    final r = await _client.dio.put<List<dynamic>>(
      '/courier/folders/reorder',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(FolderResponse.fromJson)
        .toList();
  }

  /// Moves a folder to a new parent.
  Future<FolderResponse> moveFolder(
    String teamId,
    String folderId, {
    String? newParentFolderId,
  }) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/folders/$folderId/move',
      queryParameters: {
        if (newParentFolderId != null) 'newParentFolderId': newParentFolderId,
      },
      options: _teamOpts(teamId),
    );
    return FolderResponse.fromJson(r.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Requests
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new API request.
  Future<RequestResponse> createRequest(
    String teamId,
    CreateRequestRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/requests',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return RequestResponse.fromJson(r.data!);
  }

  /// Gets a request by ID (includes headers, params, body, auth, scripts).
  Future<RequestResponse> getRequest(
      String teamId, String requestId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/requests/$requestId',
      options: _teamOpts(teamId),
    );
    return RequestResponse.fromJson(r.data!);
  }

  /// Updates a request.
  Future<RequestResponse> updateRequest(
    String teamId,
    String requestId,
    UpdateRequestRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/requests/$requestId',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return RequestResponse.fromJson(r.data!);
  }

  /// Deletes a request.
  Future<void> deleteRequest(String teamId, String requestId) async {
    await _client.dio.delete<dynamic>(
      '/courier/requests/$requestId',
      options: _teamOpts(teamId),
    );
  }

  /// Updates request headers.
  Future<List<RequestHeaderResponse>> updateRequestHeaders(
    String teamId,
    String requestId,
    SaveRequestHeadersRequest request,
  ) async {
    final r = await _client.dio.put<List<dynamic>>(
      '/courier/requests/$requestId/headers',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(RequestHeaderResponse.fromJson)
        .toList();
  }

  /// Updates request query parameters.
  Future<List<RequestParamResponse>> updateRequestParams(
    String teamId,
    String requestId,
    SaveRequestParamsRequest request,
  ) async {
    final r = await _client.dio.put<List<dynamic>>(
      '/courier/requests/$requestId/params',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(RequestParamResponse.fromJson)
        .toList();
  }

  /// Updates request body.
  Future<RequestBodyResponse> updateRequestBody(
    String teamId,
    String requestId,
    SaveRequestBodyRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/requests/$requestId/body',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return RequestBodyResponse.fromJson(r.data!);
  }

  /// Updates request authentication.
  Future<RequestAuthResponse> updateRequestAuth(
    String teamId,
    String requestId,
    SaveRequestAuthRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/requests/$requestId/auth',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return RequestAuthResponse.fromJson(r.data!);
  }

  /// Updates request scripts.
  Future<RequestScriptResponse> updateRequestScripts(
    String teamId,
    String requestId,
    SaveRequestScriptRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/requests/$requestId/scripts',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return RequestScriptResponse.fromJson(r.data!);
  }

  /// Reorders requests within a folder.
  Future<List<RequestSummaryResponse>> reorderRequests(
    String teamId,
    ReorderRequestRequest request,
  ) async {
    final r = await _client.dio.put<List<dynamic>>(
      '/courier/requests/reorder',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(RequestSummaryResponse.fromJson)
        .toList();
  }

  /// Moves a request to a different folder.
  Future<RequestResponse> moveRequest(
    String teamId,
    String requestId, {
    required String targetFolderId,
  }) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/requests/$requestId/move',
      queryParameters: {'targetFolderId': targetFolderId},
      options: _teamOpts(teamId),
    );
    return RequestResponse.fromJson(r.data!);
  }

  /// Duplicates a request.
  Future<RequestResponse> duplicateRequest(
    String teamId,
    String requestId, {
    DuplicateRequestRequest? request,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/requests/$requestId/duplicate',
      data: request?.toJson(),
      options: _teamOpts(teamId),
    );
    return RequestResponse.fromJson(r.data!);
  }

  /// Sends a saved request via the proxy.
  Future<ProxyResponse> sendSavedRequest(
    String teamId,
    String requestId, {
    String? environmentId,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/requests/$requestId/send',
      queryParameters: {
        if (environmentId != null) 'environmentId': environmentId,
      },
      options: _teamOpts(teamId),
    );
    return ProxyResponse.fromJson(r.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Environments
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new environment.
  Future<EnvironmentResponse> createEnvironment(
    String teamId,
    CreateEnvironmentRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/environments',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return EnvironmentResponse.fromJson(r.data!);
  }

  /// Lists all environments for the team.
  Future<List<EnvironmentResponse>> getEnvironments(String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/environments',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(EnvironmentResponse.fromJson)
        .toList();
  }

  /// Gets the active environment.
  Future<EnvironmentResponse?> getActiveEnvironment(String teamId) async {
    final r = await _client.dio.get<Map<String, dynamic>?>(
      '/courier/environments/active',
      options: _teamOpts(teamId),
    );
    if (r.data == null) return null;
    return EnvironmentResponse.fromJson(r.data!);
  }

  /// Gets an environment by ID.
  Future<EnvironmentResponse> getEnvironment(
      String teamId, String environmentId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/environments/$environmentId',
      options: _teamOpts(teamId),
    );
    return EnvironmentResponse.fromJson(r.data!);
  }

  /// Updates an environment.
  Future<EnvironmentResponse> updateEnvironment(
    String teamId,
    String environmentId,
    UpdateEnvironmentRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/environments/$environmentId',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return EnvironmentResponse.fromJson(r.data!);
  }

  /// Deletes an environment.
  Future<void> deleteEnvironment(String teamId, String environmentId) async {
    await _client.dio.delete<dynamic>(
      '/courier/environments/$environmentId',
      options: _teamOpts(teamId),
    );
  }

  /// Activates an environment.
  Future<EnvironmentResponse> activateEnvironment(
      String teamId, String environmentId) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/environments/$environmentId/activate',
      options: _teamOpts(teamId),
    );
    return EnvironmentResponse.fromJson(r.data!);
  }

  /// Clones an environment.
  Future<EnvironmentResponse> cloneEnvironment(
    String teamId,
    String environmentId,
    CloneEnvironmentRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/environments/$environmentId/clone',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return EnvironmentResponse.fromJson(r.data!);
  }

  /// Gets variables for an environment.
  Future<List<EnvironmentVariableResponse>> getEnvironmentVariables(
      String teamId, String environmentId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/environments/$environmentId/variables',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(EnvironmentVariableResponse.fromJson)
        .toList();
  }

  /// Sets environment variables (replaces all).
  Future<List<EnvironmentVariableResponse>> setEnvironmentVariables(
    String teamId,
    String environmentId,
    SaveEnvironmentVariablesRequest request,
  ) async {
    final r = await _client.dio.put<List<dynamic>>(
      '/courier/environments/$environmentId/variables',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(EnvironmentVariableResponse.fromJson)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Global Variables
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists all global variables for the team.
  Future<List<GlobalVariableResponse>> getGlobalVariables(
      String teamId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/variables/global',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(GlobalVariableResponse.fromJson)
        .toList();
  }

  /// Creates or updates a global variable.
  Future<GlobalVariableResponse> saveGlobalVariable(
    String teamId,
    SaveGlobalVariableRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/variables/global',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return GlobalVariableResponse.fromJson(r.data!);
  }

  /// Batch-saves global variables.
  Future<List<GlobalVariableResponse>> batchSaveGlobalVariables(
    String teamId,
    BatchSaveGlobalVariablesRequest request,
  ) async {
    final r = await _client.dio.post<List<dynamic>>(
      '/courier/variables/global/batch',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(GlobalVariableResponse.fromJson)
        .toList();
  }

  /// Deletes a global variable.
  Future<void> deleteGlobalVariable(
      String teamId, String variableId) async {
    await _client.dio.delete<dynamic>(
      '/courier/variables/global/$variableId',
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Proxy
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sends an ad-hoc HTTP request via the proxy.
  Future<ProxyResponse> sendRequest(
    String teamId,
    SendRequestProxyRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/proxy/send',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return ProxyResponse.fromJson(r.data!);
  }

  /// Sends a saved request via the proxy (alternate path).
  Future<ProxyResponse> sendSavedRequestProxy(
    String teamId,
    String requestId, {
    String? environmentId,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/proxy/send/$requestId',
      queryParameters: {
        if (environmentId != null) 'environmentId': environmentId,
      },
      options: _teamOpts(teamId),
    );
    return ProxyResponse.fromJson(r.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // History
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lists request history with pagination.
  Future<PageResponse<RequestHistoryResponse>> getHistory(
    String teamId, {
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/history',
      queryParameters: {'page': page, 'size': size},
      options: _teamOpts(teamId),
    );
    return PageResponse.fromJson(
        r.data!, (o) => RequestHistoryResponse.fromJson(o as Map<String, dynamic>));
  }

  /// Gets a history entry by ID.
  Future<RequestHistoryDetailResponse> getHistoryEntry(
      String teamId, String historyId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/history/$historyId',
      options: _teamOpts(teamId),
    );
    return RequestHistoryDetailResponse.fromJson(r.data!);
  }

  /// Searches request history.
  Future<List<RequestHistoryResponse>> searchHistory(
    String teamId, {
    required String query,
  }) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/history/search',
      queryParameters: {'query': query},
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(RequestHistoryResponse.fromJson)
        .toList();
  }

  /// Gets history filtered by HTTP method.
  Future<PageResponse<RequestHistoryResponse>> getHistoryByMethod(
    String teamId,
    CourierHttpMethod method, {
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/history/method/${method.toJson()}',
      queryParameters: {'page': page, 'size': size},
      options: _teamOpts(teamId),
    );
    return PageResponse.fromJson(
        r.data!, (o) => RequestHistoryResponse.fromJson(o as Map<String, dynamic>));
  }

  /// Gets history filtered by user.
  Future<PageResponse<RequestHistoryResponse>> getHistoryByUser(
    String teamId,
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/history/user/$userId',
      queryParameters: {'page': page, 'size': size},
      options: _teamOpts(teamId),
    );
    return PageResponse.fromJson(
        r.data!, (o) => RequestHistoryResponse.fromJson(o as Map<String, dynamic>));
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String teamId, String historyId) async {
    await _client.dio.delete<dynamic>(
      '/courier/history/$historyId',
      options: _teamOpts(teamId),
    );
  }

  /// Clears request history.
  Future<void> clearHistory(String teamId, {int? daysToRetain}) async {
    await _client.dio.delete<dynamic>(
      '/courier/history',
      queryParameters: {
        if (daysToRetain != null) 'daysToRetain': daysToRetain,
      },
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Sharing
  // ═══════════════════════════════════════════════════════════════════════════

  /// Shares a collection with a user.
  Future<CollectionShareResponse> shareCollection(
    String teamId,
    String collectionId,
    ShareCollectionRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/collections/$collectionId/shares',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return CollectionShareResponse.fromJson(r.data!);
  }

  /// Gets shares for a collection.
  Future<List<CollectionShareResponse>> getCollectionShares(
      String teamId, String collectionId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/collections/$collectionId/shares',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(CollectionShareResponse.fromJson)
        .toList();
  }

  /// Gets collections shared with the current user.
  Future<List<CollectionShareResponse>> getSharedWithMe() async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/shared-with-me',
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(CollectionShareResponse.fromJson)
        .toList();
  }

  /// Updates a share permission.
  Future<CollectionShareResponse> updateSharePermission(
    String teamId,
    String collectionId,
    String sharedWithUserId,
    UpdateSharePermissionRequest request,
  ) async {
    final r = await _client.dio.put<Map<String, dynamic>>(
      '/courier/collections/$collectionId/shares/$sharedWithUserId',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return CollectionShareResponse.fromJson(r.data!);
  }

  /// Removes a share.
  Future<void> removeShare(
    String teamId,
    String collectionId,
    String sharedWithUserId,
  ) async {
    await _client.dio.delete<dynamic>(
      '/courier/collections/$collectionId/shares/$sharedWithUserId',
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Forking
  // ═══════════════════════════════════════════════════════════════════════════

  /// Forks a collection.
  Future<ForkResponse> forkCollection(
    String teamId,
    String collectionId, {
    CreateForkRequest? request,
  }) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/collections/$collectionId/fork',
      data: request?.toJson(),
      options: _teamOpts(teamId),
    );
    return ForkResponse.fromJson(r.data!);
  }

  /// Gets forks of a collection.
  Future<List<ForkResponse>> getCollectionForks(
      String teamId, String collectionId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/collections/$collectionId/forks',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(ForkResponse.fromJson)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Import
  // ═══════════════════════════════════════════════════════════════════════════

  /// Imports a Postman collection.
  Future<ImportResultResponse> importPostman(
    String teamId,
    ImportCollectionRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/import/postman',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return ImportResultResponse.fromJson(r.data!);
  }

  /// Imports an OpenAPI specification.
  Future<ImportResultResponse> importOpenApi(
    String teamId,
    ImportCollectionRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/import/openapi',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return ImportResultResponse.fromJson(r.data!);
  }

  /// Imports a cURL command.
  Future<ImportResultResponse> importCurl(
    String teamId,
    ImportCollectionRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/import/curl',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return ImportResultResponse.fromJson(r.data!);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GraphQL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Executes a GraphQL query.
  Future<GraphQLResponse> executeGraphQL(
    String teamId,
    ExecuteGraphQLRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/graphql/execute',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return GraphQLResponse.fromJson(r.data!);
  }

  /// Introspects a GraphQL schema.
  Future<GraphQLResponse> introspectSchema(
    String teamId,
    IntrospectGraphQLRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/graphql/introspect',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return GraphQLResponse.fromJson(r.data!);
  }

  /// Validates a GraphQL query.
  Future<List<String>> validateGraphQLQuery(
      Map<String, String> request) async {
    final r = await _client.dio.post<List<dynamic>>(
      '/courier/graphql/validate',
      data: request,
    );
    return r.data!.cast<String>();
  }

  /// Formats a GraphQL query.
  Future<Map<String, String>> formatGraphQLQuery(
      Map<String, String> request) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/graphql/format',
      data: request,
    );
    return r.data!.cast<String, String>();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Runner
  // ═══════════════════════════════════════════════════════════════════════════

  /// Starts a collection run.
  Future<RunResultDetailResponse> startRun(
    String teamId,
    StartCollectionRunRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/runner/start',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return RunResultDetailResponse.fromJson(r.data!);
  }

  /// Lists run results with pagination.
  Future<PageResponse<RunResultResponse>> getRunResults(
    String teamId, {
    int page = 0,
    int size = 20,
  }) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/runner/results',
      queryParameters: {'page': page, 'size': size},
      options: _teamOpts(teamId),
    );
    return PageResponse.fromJson(
        r.data!, (o) => RunResultResponse.fromJson(o as Map<String, dynamic>));
  }

  /// Gets a run result by ID.
  Future<RunResultResponse> getRunResult(
      String teamId, String runResultId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/runner/results/$runResultId',
      options: _teamOpts(teamId),
    );
    return RunResultResponse.fromJson(r.data!);
  }

  /// Gets detailed run result with iterations.
  Future<RunResultDetailResponse> getRunResultDetail(
      String teamId, String runResultId) async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/runner/results/$runResultId/detail',
      options: _teamOpts(teamId),
    );
    return RunResultDetailResponse.fromJson(r.data!);
  }

  /// Cancels a running collection run.
  Future<RunResultResponse> cancelRun(
      String teamId, String runResultId) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/runner/results/$runResultId/cancel',
      options: _teamOpts(teamId),
    );
    return RunResultResponse.fromJson(r.data!);
  }

  /// Gets run results for a specific collection.
  Future<List<RunResultResponse>> getRunResultsByCollection(
      String teamId, String collectionId) async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/runner/results/collection/$collectionId',
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(RunResultResponse.fromJson)
        .toList();
  }

  /// Deletes a run result.
  Future<void> deleteRunResult(String teamId, String runResultId) async {
    await _client.dio.delete<dynamic>(
      '/courier/runner/results/$runResultId',
      options: _teamOpts(teamId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Code Generation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gets available code generation languages.
  Future<List<CodeSnippetResponse>> getCodeLanguages() async {
    final r = await _client.dio.get<List<dynamic>>(
      '/courier/codegen/languages',
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(CodeSnippetResponse.fromJson)
        .toList();
  }

  /// Generates a code snippet for a request.
  Future<CodeSnippetResponse> generateCode(
    String teamId,
    GenerateCodeRequest request,
  ) async {
    final r = await _client.dio.post<Map<String, dynamic>>(
      '/courier/codegen/generate',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return CodeSnippetResponse.fromJson(r.data!);
  }

  /// Generates code snippets in all languages for a request.
  Future<List<CodeSnippetResponse>> generateAllCode(
    String teamId,
    GenerateCodeRequest request,
  ) async {
    final r = await _client.dio.post<List<dynamic>>(
      '/courier/codegen/generate/all',
      data: request.toJson(),
      options: _teamOpts(teamId),
    );
    return r.data!
        .cast<Map<String, dynamic>>()
        .map(CodeSnippetResponse.fromJson)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Health
  // ═══════════════════════════════════════════════════════════════════════════

  /// Checks Courier service health.
  Future<Map<String, dynamic>> getHealth() async {
    final r = await _client.dio.get<Map<String, dynamic>>(
      '/courier/health',
    );
    return r.data!;
  }
}
