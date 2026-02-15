/// API service for compliance specification and compliance item endpoints.
///
/// Wraps 7 ComplianceController endpoints for creating/fetching specifications,
/// compliance items, and summary data.
library;

import '../../models/compliance_item.dart';
import '../../models/enums.dart';
import '../../models/health_snapshot.dart';
import '../../models/specification.dart';
import 'api_client.dart';

/// API service for compliance specification and item endpoints.
///
/// Provides typed methods for creating and retrieving specifications,
/// compliance items (single and batch), filtering by status, and
/// fetching compliance summaries.
class ComplianceApi {
  final ApiClient _client;

  /// Creates a [ComplianceApi] backed by the given [client].
  ComplianceApi(this._client);

  /// Creates a specification record for a compliance job.
  ///
  /// Returns the created [Specification].
  Future<Specification> createSpecification({
    required String jobId,
    required String name,
    required String s3Key,
    SpecType? specType,
  }) async {
    final body = <String, dynamic>{
      'jobId': jobId,
      'name': name,
      's3Key': s3Key,
    };
    if (specType != null) {
      body['specType'] = specType.toJson();
    }
    final response = await _client.post<Map<String, dynamic>>(
      '/compliance/specs',
      data: body,
    );
    return Specification.fromJson(response.data!);
  }

  /// Fetches paginated specifications for a job.
  Future<PageResponse<Specification>> getSpecificationsForJob(
    String jobId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/compliance/specs/job/$jobId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => Specification.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Creates a single compliance item.
  ///
  /// Returns the created [ComplianceItem].
  Future<ComplianceItem> createComplianceItem({
    required String jobId,
    required String requirement,
    required ComplianceStatus status,
    String? specId,
    String? evidence,
    AgentType? agentType,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'jobId': jobId,
      'requirement': requirement,
      'status': status.toJson(),
    };
    if (specId != null) body['specId'] = specId;
    if (evidence != null) body['evidence'] = evidence;
    if (agentType != null) body['agentType'] = agentType.toJson();
    if (notes != null) body['notes'] = notes;

    final response = await _client.post<Map<String, dynamic>>(
      '/compliance/items',
      data: body,
    );
    return ComplianceItem.fromJson(response.data!);
  }

  /// Creates multiple compliance items in a single batch request.
  ///
  /// Returns the list of created [ComplianceItem]s.
  Future<List<ComplianceItem>> createComplianceItems(
    List<Map<String, dynamic>> items,
  ) async {
    final response = await _client.post<List<dynamic>>(
      '/compliance/items/batch',
      data: items,
    );
    return response.data!
        .map((json) => ComplianceItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches paginated compliance items for a job.
  Future<PageResponse<ComplianceItem>> getComplianceItemsForJob(
    String jobId, {
    int page = 0,
    int size = 50,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/compliance/items/job/$jobId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => ComplianceItem.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches paginated compliance items for a job filtered by status.
  Future<PageResponse<ComplianceItem>> getComplianceItemsByStatus(
    String jobId,
    ComplianceStatus status, {
    int page = 0,
    int size = 50,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/compliance/items/job/$jobId/status/${status.toJson()}',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => ComplianceItem.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches the compliance summary for a job.
  ///
  /// Returns a map with keys like `met`, `partial`, `missing`,
  /// `notApplicable`, and `total`.
  Future<Map<String, dynamic>> getComplianceSummary(String jobId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/compliance/summary/job/$jobId',
    );
    return response.data!;
  }
}
