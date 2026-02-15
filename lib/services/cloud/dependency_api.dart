/// API service for dependency scan and vulnerability endpoints.
///
/// Wraps all DependencyController endpoints with typed methods.
/// Base path: `/dependencies`.
library;

import '../../models/dependency_scan.dart';
import '../../models/enums.dart';
import '../../models/health_snapshot.dart';
import 'api_client.dart';

/// Dio-based client for DependencyController endpoints.
///
/// Provides operations for dependency scans (create, get, list, latest)
/// and vulnerabilities (create, list, filter, status update).
class DependencyApi {
  final ApiClient _client;

  /// Creates a [DependencyApi] backed by the given [client].
  DependencyApi(this._client);

  /// Creates a new dependency scan record.
  ///
  /// POST `/dependencies/scans`
  /// Required: [projectId].
  /// Returns the created [DependencyScan].
  Future<DependencyScan> createScan({
    required String projectId,
    String? jobId,
    String? manifestFile,
    int? totalDependencies,
    int? outdatedCount,
    int? vulnerableCount,
    String? scanDataJson,
  }) async {
    final body = <String, dynamic>{
      'projectId': projectId,
    };
    if (jobId != null) body['jobId'] = jobId;
    if (manifestFile != null) body['manifestFile'] = manifestFile;
    if (totalDependencies != null) {
      body['totalDependencies'] = totalDependencies;
    }
    if (outdatedCount != null) body['outdatedCount'] = outdatedCount;
    if (vulnerableCount != null) body['vulnerableCount'] = vulnerableCount;
    if (scanDataJson != null) body['scanDataJson'] = scanDataJson;

    final response = await _client.post<Map<String, dynamic>>(
      '/dependencies/scans',
      data: body,
    );
    return DependencyScan.fromJson(response.data!);
  }

  /// Fetches a single scan by [scanId].
  ///
  /// GET `/dependencies/scans/{scanId}`
  Future<DependencyScan> getScan(String scanId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dependencies/scans/$scanId',
    );
    return DependencyScan.fromJson(response.data!);
  }

  /// Fetches paginated scans for a project.
  ///
  /// GET `/dependencies/scans/project/{projectId}?page={page}&size={size}`
  Future<PageResponse<DependencyScan>> getScansForProject(
    String projectId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dependencies/scans/project/$projectId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) => DependencyScan.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches the most recent scan for a project.
  ///
  /// GET `/dependencies/scans/project/{projectId}/latest`
  /// Returns a single [DependencyScan] (not paginated).
  Future<DependencyScan> getLatestScan(String projectId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dependencies/scans/project/$projectId/latest',
    );
    return DependencyScan.fromJson(response.data!);
  }

  /// Adds a single vulnerability to a scan.
  ///
  /// POST `/dependencies/vulnerabilities`
  /// Required: [scanId], [dependencyName], [severity].
  /// Returns the created [DependencyVulnerability].
  Future<DependencyVulnerability> addVulnerability({
    required String scanId,
    required String dependencyName,
    required Severity severity,
    String? currentVersion,
    String? fixedVersion,
    String? cveId,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'scanId': scanId,
      'dependencyName': dependencyName,
      'severity': severity.toJson(),
    };
    if (currentVersion != null) body['currentVersion'] = currentVersion;
    if (fixedVersion != null) body['fixedVersion'] = fixedVersion;
    if (cveId != null) body['cveId'] = cveId;
    if (description != null) body['description'] = description;

    final response = await _client.post<Map<String, dynamic>>(
      '/dependencies/vulnerabilities',
      data: body,
    );
    return DependencyVulnerability.fromJson(response.data!);
  }

  /// Adds multiple vulnerabilities in batch.
  ///
  /// POST `/dependencies/vulnerabilities/batch`
  /// Returns a list of created [DependencyVulnerability]s.
  Future<List<DependencyVulnerability>> addVulnerabilities(
    List<Map<String, dynamic>> vulnerabilities,
  ) async {
    final response = await _client.post<List<dynamic>>(
      '/dependencies/vulnerabilities/batch',
      data: vulnerabilities,
    );
    return response.data!
        .map(
          (e) =>
              DependencyVulnerability.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  /// Fetches paginated vulnerabilities for a scan.
  ///
  /// GET `/dependencies/vulnerabilities/scan/{scanId}?page={page}&size={size}`
  Future<PageResponse<DependencyVulnerability>> getVulnerabilities(
    String scanId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dependencies/vulnerabilities/scan/$scanId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) =>
          DependencyVulnerability.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches paginated vulnerabilities filtered by [severity].
  ///
  /// GET `/dependencies/vulnerabilities/scan/{scanId}/severity/{severity}?page={page}&size={size}`
  Future<PageResponse<DependencyVulnerability>> getVulnerabilitiesBySeverity(
    String scanId,
    Severity severity, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dependencies/vulnerabilities/scan/$scanId/severity/${severity.toJson()}',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) =>
          DependencyVulnerability.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches paginated open (unresolved) vulnerabilities for a scan.
  ///
  /// GET `/dependencies/vulnerabilities/scan/{scanId}/open?page={page}&size={size}`
  Future<PageResponse<DependencyVulnerability>> getOpenVulnerabilities(
    String scanId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dependencies/vulnerabilities/scan/$scanId/open',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (json) =>
          DependencyVulnerability.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Updates a vulnerability's status.
  ///
  /// PUT `/dependencies/vulnerabilities/{vulnerabilityId}/status?status={status}`
  /// Note: status is sent as a **query parameter**, not request body.
  Future<DependencyVulnerability> updateVulnerabilityStatus(
    String vulnerabilityId,
    VulnerabilityStatus status,
  ) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/dependencies/vulnerabilities/$vulnerabilityId/status',
      queryParameters: {'status': status.toJson()},
    );
    return DependencyVulnerability.fromJson(response.data!);
  }
}
