/// Riverpod providers for dependency scan and vulnerability data.
///
/// Exposes the [DependencyApi] service, scan fetching,
/// vulnerability queries with filters, selection state,
/// and a derived dependency health score.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dependency_scan.dart';
import '../models/enums.dart';
import '../models/health_snapshot.dart';
import '../services/analysis/dependency_scanner.dart';
import '../services/cloud/dependency_api.dart';
import 'auth_providers.dart';

/// Provides [DependencyApi] singleton.
final dependencyApiProvider = Provider<DependencyApi>(
  (ref) => DependencyApi(ref.watch(apiClientProvider)),
);

/// Fetches paginated scans for a project.
final projectScansProvider =
    FutureProvider.family<PageResponse<DependencyScan>, String>(
  (ref, projectId) async {
    final api = ref.watch(dependencyApiProvider);
    return api.getScansForProject(projectId);
  },
);

/// Fetches the latest scan for a project.
final latestScanProvider =
    FutureProvider.family<DependencyScan, String>((ref, projectId) async {
  final api = ref.watch(dependencyApiProvider);
  return api.getLatestScan(projectId);
});

/// Fetches paginated vulnerabilities for a scan.
final scanVulnerabilitiesProvider = FutureProvider.family<
    PageResponse<DependencyVulnerability>, String>((ref, scanId) async {
  final api = ref.watch(dependencyApiProvider);
  return api.getVulnerabilities(scanId);
});

/// Fetches vulnerabilities filtered by severity.
final vulnsBySeverityProvider = FutureProvider.family<
    PageResponse<DependencyVulnerability>,
    ({String scanId, Severity severity})>((ref, params) async {
  final api = ref.watch(dependencyApiProvider);
  return api.getVulnerabilitiesBySeverity(params.scanId, params.severity);
});

/// Fetches open (unresolved) vulnerabilities for a scan.
final openVulnerabilitiesProvider = FutureProvider.family<
    PageResponse<DependencyVulnerability>, String>((ref, scanId) async {
  final api = ref.watch(dependencyApiProvider);
  return api.getOpenVulnerabilities(scanId);
});

/// Currently selected scan for viewing.
final selectedScanProvider =
    StateProvider<DependencyScan?>((ref) => null);

/// Currently selected vulnerability for the detail panel.
final selectedVulnerabilityProvider =
    StateProvider<DependencyVulnerability?>((ref) => null);

/// Search query for filtering vulnerabilities by dependency name or CVE.
final vulnSearchQueryProvider = StateProvider<String>((ref) => '');

/// Severity filter for vulnerabilities.
final vulnSeverityFilterProvider =
    StateProvider<Severity?>((ref) => null);

/// Status filter for vulnerabilities.
final vulnStatusFilterProvider =
    StateProvider<VulnerabilityStatus?>((ref) => null);

/// Derived provider combining all vulnerability filters.
///
/// Watches [scanVulnerabilitiesProvider] and all filter providers,
/// returning a filtered list of [DependencyVulnerability].
final filteredVulnerabilitiesProvider =
    Provider.family<AsyncValue<List<DependencyVulnerability>>, String>(
  (ref, scanId) {
    final vulnsAsync = ref.watch(scanVulnerabilitiesProvider(scanId));
    final query = ref.watch(vulnSearchQueryProvider).toLowerCase();
    final severityFilter = ref.watch(vulnSeverityFilterProvider);
    final statusFilter = ref.watch(vulnStatusFilterProvider);

    return vulnsAsync.whenData((page) {
      var vulns = page.content;

      if (query.isNotEmpty) {
        vulns = vulns.where((v) {
          return v.dependencyName.toLowerCase().contains(query) ||
              (v.cveId?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      if (severityFilter != null) {
        vulns = vulns.where((v) => v.severity == severityFilter).toList();
      }
      if (statusFilter != null) {
        vulns = vulns.where((v) => v.status == statusFilter).toList();
      }

      return vulns;
    });
  },
);

/// Derived provider calculating a dependency health score (0-100).
///
/// Score = 100 - (critical × 25 + high × 10 + medium × 3 + low × 1),
/// clamped to 0-100. Only counts non-RESOLVED vulnerabilities.
final depHealthScoreProvider =
    Provider.family<AsyncValue<int>, String>((ref, projectId) {
  final scanAsync = ref.watch(latestScanProvider(projectId));
  return scanAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (scan) {
      final vulnsAsync =
          ref.watch(scanVulnerabilitiesProvider(scan.id));
      return vulnsAsync.whenData((page) {
        return DependencyScanner.computeDepHealthScore(scan, page.content);
      });
    },
  );
});
