// Tests for dependency Riverpod providers.
//
// Verifies filter state defaults, filtered vulnerability logic,
// dependency health score calculation, and latest scan provider.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/dependency_scan.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/dependency_providers.dart';
import 'package:codeops/services/analysis/dependency_scanner.dart';

/// Builds a [DependencyVulnerability] with sensible defaults.
DependencyVulnerability _vuln({
  String id = 'v1',
  String scanId = 'scan-1',
  String dependencyName = 'some-lib',
  String? cveId,
  Severity severity = Severity.medium,
  VulnerabilityStatus status = VulnerabilityStatus.open,
  String? currentVersion,
  String? fixedVersion,
  String? description,
}) {
  return DependencyVulnerability(
    id: id,
    scanId: scanId,
    dependencyName: dependencyName,
    cveId: cveId,
    severity: severity,
    status: status,
    currentVersion: currentVersion,
    fixedVersion: fixedVersion,
    description: description,
  );
}

/// Builds a [DependencyScan] with sensible defaults.
DependencyScan _scan({
  String id = 'scan-1',
  String projectId = 'proj-1',
  int? totalDependencies = 50,
  int? outdatedCount = 5,
  int? vulnerableCount = 3,
}) {
  return DependencyScan(
    id: id,
    projectId: projectId,
    totalDependencies: totalDependencies,
    outdatedCount: outdatedCount,
    vulnerableCount: vulnerableCount,
  );
}

/// Creates a [PageResponse] wrapping the given vulnerabilities.
PageResponse<DependencyVulnerability> _vulnPage(
    List<DependencyVulnerability> vulns) {
  return PageResponse<DependencyVulnerability>(
    content: vulns,
    page: 0,
    size: vulns.length,
    totalElements: vulns.length,
    totalPages: 1,
    isLast: true,
  );
}

void main() {
  group('Filter state providers defaults', () {
    test('vulnSearchQueryProvider defaults to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(vulnSearchQueryProvider), '');
    });

    test('vulnSeverityFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(vulnSeverityFilterProvider), isNull);
    });

    test('vulnStatusFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(vulnStatusFilterProvider), isNull);
    });

    test('selectedScanProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedScanProvider), isNull);
    });

    test('selectedVulnerabilityProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedVulnerabilityProvider), isNull);
    });
  });

  group('filteredVulnerabilitiesProvider', () {
    test('returns all vulns with no filters', () {
      final vulns = [
        _vuln(id: 'v1', severity: Severity.critical),
        _vuln(id: 'v2', severity: Severity.low),
        _vuln(id: 'v3', severity: Severity.medium),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data.length, 3);
      });
    });

    test('filters by severity', () {
      final vulns = [
        _vuln(id: 'v1', severity: Severity.critical),
        _vuln(id: 'v2', severity: Severity.low),
        _vuln(id: 'v3', severity: Severity.critical),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      container.read(vulnSeverityFilterProvider.notifier).state =
          Severity.critical;

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(data.every((v) => v.severity == Severity.critical), isTrue);
      });
    });

    test('filters by status', () {
      final vulns = [
        _vuln(id: 'v1', status: VulnerabilityStatus.open),
        _vuln(id: 'v2', status: VulnerabilityStatus.resolved),
        _vuln(id: 'v3', status: VulnerabilityStatus.open),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      container.read(vulnStatusFilterProvider.notifier).state =
          VulnerabilityStatus.open;

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(
            data.every((v) => v.status == VulnerabilityStatus.open), isTrue);
      });
    });

    test('filters by search on dependency name', () {
      final vulns = [
        _vuln(id: 'v1', dependencyName: 'log4j'),
        _vuln(id: 'v2', dependencyName: 'spring-core'),
        _vuln(id: 'v3', dependencyName: 'log4j-api'),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      container.read(vulnSearchQueryProvider.notifier).state = 'log4j';

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
      });
    });

    test('filters by search on CVE ID', () {
      final vulns = [
        _vuln(id: 'v1', cveId: 'CVE-2021-44228', dependencyName: 'log4j'),
        _vuln(id: 'v2', cveId: 'CVE-2023-1234', dependencyName: 'jackson'),
        _vuln(id: 'v3', cveId: null, dependencyName: 'guava'),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      container.read(vulnSearchQueryProvider.notifier).state = 'CVE-2021';

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.cveId, 'CVE-2021-44228');
      });
    });

    test('combines severity + status + search filters', () {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
        _vuln(
          id: 'v2',
          dependencyName: 'log4j-api',
          severity: Severity.critical,
          status: VulnerabilityStatus.resolved,
        ),
        _vuln(
          id: 'v3',
          dependencyName: 'spring-core',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
        _vuln(
          id: 'v4',
          dependencyName: 'log4j-core',
          severity: Severity.low,
          status: VulnerabilityStatus.open,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      container.read(vulnSearchQueryProvider.notifier).state = 'log4j';
      container.read(vulnSeverityFilterProvider.notifier).state =
          Severity.critical;
      container.read(vulnStatusFilterProvider.notifier).state =
          VulnerabilityStatus.open;

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.id, 'v1');
      });
    });

    test('returns empty list when no vulns match filters', () {
      final vulns = [
        _vuln(
            id: 'v1', severity: Severity.low, dependencyName: 'commons-io'),
      ];

      final container = ProviderContainer(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      );
      addTearDown(container.dispose);

      container.read(vulnSeverityFilterProvider.notifier).state =
          Severity.critical;

      final filtered =
          container.read(filteredVulnerabilitiesProvider('scan-1'));
      filtered.whenData((data) {
        expect(data, isEmpty);
      });
    });
  });

  group('depHealthScoreProvider (via DependencyScanner)', () {
    test('0 vulnerabilities yields score 100', () {
      final scan = _scan();
      final vulns = <DependencyVulnerability>[];
      final score = DependencyScanner.computeDepHealthScore(scan, vulns);
      expect(score, 100);
    });

    test('4 CRITICAL vulns yields score 0', () {
      final scan = _scan();
      final vulns = List.generate(
        4,
        (i) => _vuln(
          id: 'v$i',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      );
      // 4 * 25 = 100, so 100 - 100 = 0
      final score = DependencyScanner.computeDepHealthScore(scan, vulns);
      expect(score, 0);
    });

    test('2 HIGH + 3 MEDIUM yields score 71', () {
      final scan = _scan();
      final vulns = [
        _vuln(id: 'h1', severity: Severity.high, status: VulnerabilityStatus.open),
        _vuln(id: 'h2', severity: Severity.high, status: VulnerabilityStatus.open),
        _vuln(id: 'm1', severity: Severity.medium, status: VulnerabilityStatus.open),
        _vuln(id: 'm2', severity: Severity.medium, status: VulnerabilityStatus.open),
        _vuln(id: 'm3', severity: Severity.medium, status: VulnerabilityStatus.open),
      ];
      // 2*10 + 3*3 = 29, so 100 - 29 = 71
      final score = DependencyScanner.computeDepHealthScore(scan, vulns);
      expect(score, 71);
    });

    test('RESOLVED vulns are excluded from score deduction', () {
      final scan = _scan();
      final vulns = [
        _vuln(
          id: 'v1',
          severity: Severity.critical,
          status: VulnerabilityStatus.resolved,
        ),
        _vuln(
          id: 'v2',
          severity: Severity.critical,
          status: VulnerabilityStatus.resolved,
        ),
      ];
      final score = DependencyScanner.computeDepHealthScore(scan, vulns);
      expect(score, 100);
    });

    test('score clamps at 0 for extreme deductions', () {
      final scan = _scan();
      final vulns = List.generate(
        10,
        (i) => _vuln(
          id: 'v$i',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      );
      // 10 * 25 = 250, clamped to 0
      final score = DependencyScanner.computeDepHealthScore(scan, vulns);
      expect(score, 0);
    });

    test('mixed severities calculate correctly', () {
      final scan = _scan();
      final vulns = [
        _vuln(id: 'c1', severity: Severity.critical, status: VulnerabilityStatus.open),
        _vuln(id: 'h1', severity: Severity.high, status: VulnerabilityStatus.open),
        _vuln(id: 'm1', severity: Severity.medium, status: VulnerabilityStatus.open),
        _vuln(id: 'l1', severity: Severity.low, status: VulnerabilityStatus.open),
      ];
      // 25 + 10 + 3 + 1 = 39, so 100 - 39 = 61
      final score = DependencyScanner.computeDepHealthScore(scan, vulns);
      expect(score, 61);
    });
  });

  group('latestScanProvider', () {
    test('returns a single scan', () async {
      final scan = _scan(id: 'latest-scan');

      final container = ProviderContainer(
        overrides: [
          latestScanProvider('proj-1').overrideWith((ref) async => scan),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(latestScanProvider('proj-1').future);
      expect(result.id, 'latest-scan');
      expect(result.projectId, 'proj-1');
    });
  });
}
