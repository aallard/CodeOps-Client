/// API service for tech debt endpoints.
///
/// Wraps all TechDebtController endpoints with typed methods.
/// Base path: `/tech-debt`.
library;

import '../../models/enums.dart';
import '../../models/health_snapshot.dart';
import '../../models/tech_debt_item.dart';
import 'api_client.dart';

/// Dio-based client for TechDebtController endpoints.
///
/// Provides CRUD operations for tech debt items including batch creation,
/// filtering by status and category, status updates, and summary aggregation.
class TechDebtApi {
  final ApiClient _client;

  /// Creates a [TechDebtApi] backed by the given [client].
  TechDebtApi(this._client);

  /// Creates a single tech debt item.
  ///
  /// POST `/tech-debt`
  /// Required: [projectId], [category], [title].
  /// Returns the created [TechDebtItem].
  Future<TechDebtItem> createTechDebtItem({
    required String projectId,
    required DebtCategory category,
    required String title,
    String? description,
    String? filePath,
    Effort? effortEstimate,
    BusinessImpact? businessImpact,
    String? firstDetectedJobId,
  }) async {
    final body = <String, dynamic>{
      'projectId': projectId,
      'category': category.toJson(),
      'title': title,
    };
    if (description != null) body['description'] = description;
    if (filePath != null) body['filePath'] = filePath;
    if (effortEstimate != null) {
      body['effortEstimate'] = effortEstimate.toJson();
    }
    if (businessImpact != null) {
      body['businessImpact'] = businessImpact.toJson();
    }
    if (firstDetectedJobId != null) {
      body['firstDetectedJobId'] = firstDetectedJobId;
    }

    final response = await _client.post<Map<String, dynamic>>(
      '/tech-debt',
      data: body,
    );
    return TechDebtItem.fromJson(response.data!);
  }

  /// Creates multiple tech debt items in batch.
  ///
  /// POST `/tech-debt/batch`
  /// Returns a list of created [TechDebtItem]s.
  Future<List<TechDebtItem>> createTechDebtItems(
    List<Map<String, dynamic>> items,
  ) async {
    final response = await _client.post<List<dynamic>>(
      '/tech-debt/batch',
      data: items,
    );
    return response.data!
        .map((e) => TechDebtItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single tech debt item by [itemId].
  ///
  /// GET `/tech-debt/{itemId}`
  Future<TechDebtItem> getTechDebtItem(String itemId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tech-debt/$itemId',
    );
    return TechDebtItem.fromJson(response.data!);
  }

  /// Fetches paginated tech debt items for a project.
  ///
  /// GET `/tech-debt/project/{projectId}?page={page}&size={size}`
  Future<PageResponse<TechDebtItem>> getTechDebtForProject(
    String projectId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tech-debt/project/$projectId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => TechDebtItem.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches paginated tech debt items filtered by [status].
  ///
  /// GET `/tech-debt/project/{projectId}/status/{status}?page={page}&size={size}`
  Future<PageResponse<TechDebtItem>> getTechDebtByStatus(
    String projectId,
    DebtStatus status, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tech-debt/project/$projectId/status/${status.toJson()}',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => TechDebtItem.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches paginated tech debt items filtered by [category].
  ///
  /// GET `/tech-debt/project/{projectId}/category/{category}?page={page}&size={size}`
  Future<PageResponse<TechDebtItem>> getTechDebtByCategory(
    String projectId,
    DebtCategory category, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tech-debt/project/$projectId/category/${category.toJson()}',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => TechDebtItem.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Updates the status of a tech debt item.
  ///
  /// PUT `/tech-debt/{itemId}/status`
  /// Required: [status]. Optional: [resolvedJobId] (when resolving).
  Future<TechDebtItem> updateTechDebtStatus(
    String itemId, {
    required DebtStatus status,
    String? resolvedJobId,
  }) async {
    final body = <String, dynamic>{
      'status': status.toJson(),
    };
    if (resolvedJobId != null) body['resolvedJobId'] = resolvedJobId;

    final response = await _client.put<Map<String, dynamic>>(
      '/tech-debt/$itemId/status',
      data: body,
    );
    return TechDebtItem.fromJson(response.data!);
  }

  /// Deletes a tech debt item.
  ///
  /// DELETE `/tech-debt/{itemId}`
  /// Returns void (HTTP 204).
  Future<void> deleteTechDebtItem(String itemId) async {
    await _client.delete('/tech-debt/$itemId');
  }

  /// Fetches the debt summary for a project.
  ///
  /// GET `/tech-debt/project/{projectId}/summary`
  /// Returns a map containing summary aggregation data.
  Future<Map<String, dynamic>> getDebtSummary(String projectId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tech-debt/project/$projectId/summary',
    );
    return response.data!;
  }
}
