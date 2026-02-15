/// Local analysis service for dependency health computations.
///
/// Provides health score calculation, vulnerability grouping,
/// actionable vulnerability filtering, and markdown report generation.
library;

import '../../models/dependency_scan.dart';
import '../../models/enums.dart';
import '../logging/log_service.dart';

/// Analysis service for computing dependency health metrics.
class DependencyScanner {
  /// Severity score deductions for health score calculation.
  static const Map<Severity, int> _severityDeductions = {
    Severity.critical: 25,
    Severity.high: 10,
    Severity.medium: 3,
    Severity.low: 1,
  };

  /// Computes a dependency health score (0-100).
  ///
  /// Score = 100 - (critical × 25 + high × 10 + medium × 3 + low × 1),
  /// clamped to 0-100. Only counts non-RESOLVED vulnerabilities.
  static int computeDepHealthScore(
    DependencyScan scan,
    List<DependencyVulnerability> vulns,
  ) {
    var deduction = 0;
    for (final vuln in vulns) {
      if (vuln.status == VulnerabilityStatus.resolved) continue;
      deduction += _severityDeductions[vuln.severity] ?? 1;
    }
    final score = (100 - deduction).clamp(0, 100);
    log.i('DependencyScanner', 'Scan results: total=${scan.totalDependencies ?? 0}, outdated=${scan.outdatedCount ?? 0}, vulnerable=${vulns.length}, score=$score');
    return score;
  }

  /// Groups vulnerabilities by [Severity].
  static Map<Severity, List<DependencyVulnerability>> groupBySeverity(
    List<DependencyVulnerability> vulns,
  ) {
    final groups = <Severity, List<DependencyVulnerability>>{
      for (final sev in Severity.values) sev: [],
    };
    for (final vuln in vulns) {
      groups[vuln.severity]!.add(vuln);
    }
    return groups;
  }

  /// Groups vulnerabilities by [VulnerabilityStatus].
  static Map<VulnerabilityStatus, List<DependencyVulnerability>> groupByStatus(
    List<DependencyVulnerability> vulns,
  ) {
    final groups = <VulnerabilityStatus, List<DependencyVulnerability>>{
      for (final status in VulnerabilityStatus.values) status: [],
    };
    for (final vuln in vulns) {
      groups[vuln.status]!.add(vuln);
    }
    return groups;
  }

  /// Filters to OPEN vulnerabilities that have a [fixedVersion] available.
  static List<DependencyVulnerability> getActionableVulns(
    List<DependencyVulnerability> vulns,
  ) {
    return vulns
        .where(
          (v) =>
              v.status == VulnerabilityStatus.open &&
              v.fixedVersion != null &&
              v.fixedVersion!.isNotEmpty,
        )
        .toList();
  }

  /// Generates a markdown dependency health report.
  static String formatDepReport(
    DependencyScan scan,
    List<DependencyVulnerability> vulns,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('# Dependency Health Report');
    buffer.writeln();
    buffer.writeln('## Scan Overview');
    buffer.writeln();
    buffer.writeln('- **Scan ID:** ${scan.id}');
    buffer.writeln('- **Project ID:** ${scan.projectId}');
    if (scan.manifestFile != null) {
      buffer.writeln('- **Manifest:** ${scan.manifestFile}');
    }
    buffer.writeln(
      '- **Total Dependencies:** ${scan.totalDependencies ?? 0}',
    );
    buffer.writeln('- **Outdated:** ${scan.outdatedCount ?? 0}');
    buffer.writeln('- **Vulnerable:** ${scan.vulnerableCount ?? 0}');
    buffer.writeln(
      '- **Health Score:** ${computeDepHealthScore(scan, vulns)}/100',
    );
    if (scan.createdAt != null) {
      buffer.writeln('- **Scanned:** ${scan.createdAt}');
    }
    buffer.writeln();

    // Severity breakdown
    final bySeverity = groupBySeverity(vulns);
    buffer.writeln('## Vulnerability Summary');
    buffer.writeln();
    for (final entry in bySeverity.entries) {
      buffer.writeln(
        '- **${entry.key.displayName}:** ${entry.value.length}',
      );
    }
    buffer.writeln();

    // Actionable updates
    final actionable = getActionableVulns(vulns);
    if (actionable.isNotEmpty) {
      buffer.writeln('## Recommended Updates');
      buffer.writeln();
      buffer.writeln(
        '| Dependency | Current | Fixed | Severity | CVE |',
      );
      buffer.writeln(
        '|------------|---------|-------|----------|-----|',
      );
      for (final vuln in actionable) {
        buffer.writeln(
          '| ${vuln.dependencyName} '
          '| ${vuln.currentVersion ?? '—'} '
          '| ${vuln.fixedVersion ?? '—'} '
          '| ${vuln.severity.displayName} '
          '| ${vuln.cveId ?? '—'} |',
        );
      }
    }

    return buffer.toString();
  }
}
