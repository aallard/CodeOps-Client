/// Dependency update list widget showing actionable updates grouped by dependency.
///
/// Shows vulnerabilities that have a fixedVersion and are OPEN or UPDATING,
/// grouped by dependency name with bulk resolve and export capabilities.
library;

import 'package:flutter/material.dart';

import '../../models/dependency_scan.dart';
import '../../models/enums.dart';
import '../../theme/colors.dart';
import '../shared/empty_state.dart';

/// Displays actionable dependency updates grouped by package name.
///
/// Each group shows current -> fixed version, associated CVEs,
/// and a [Mark Resolved] button for bulk status updates.
class DepUpdateList extends StatelessWidget {
  /// All vulnerabilities for the current scan.
  final List<DependencyVulnerability> vulnerabilities;

  /// Callback when "Mark Resolved" is tapped for a group.
  final void Function(List<DependencyVulnerability> group)? onMarkResolved;

  /// Callback when "Export Update Plan" is tapped.
  final VoidCallback? onExport;

  /// The current scan for report generation.
  final DependencyScan? scan;

  /// Creates a [DepUpdateList].
  const DepUpdateList({
    super.key,
    required this.vulnerabilities,
    this.onMarkResolved,
    this.onExport,
    this.scan,
  });

  @override
  Widget build(BuildContext context) {
    // Filter to actionable: OPEN or UPDATING with fixedVersion
    final actionable = vulnerabilities
        .where(
          (v) =>
              (v.status == VulnerabilityStatus.open ||
                  v.status == VulnerabilityStatus.updating) &&
              v.fixedVersion != null &&
              v.fixedVersion!.isNotEmpty,
        )
        .toList();

    if (actionable.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No actionable updates',
        subtitle: 'All vulnerabilities with fixes have been resolved.',
      );
    }

    // Group by dependency name
    final groups = <String, List<DependencyVulnerability>>{};
    for (final vuln in actionable) {
      groups.putIfAbsent(vuln.dependencyName, () => []).add(vuln);
    }

    return Column(
      children: [
        // Export button
        if (onExport != null)
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export Update Plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CodeOpsColors.primary,
                side: const BorderSide(color: CodeOpsColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                textStyle: const TextStyle(fontSize: 12),
              ),
              onPressed: onExport,
            ),
          ),
        // Grouped list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final depName = groups.keys.elementAt(index);
              final group = groups[depName]!;

              return _UpdateGroup(
                dependencyName: depName,
                vulnerabilities: group,
                onMarkResolved: onMarkResolved,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UpdateGroup extends StatelessWidget {
  final String dependencyName;
  final List<DependencyVulnerability> vulnerabilities;
  final void Function(List<DependencyVulnerability> group)? onMarkResolved;

  const _UpdateGroup({
    required this.dependencyName,
    required this.vulnerabilities,
    this.onMarkResolved,
  });

  @override
  Widget build(BuildContext context) {
    final currentVersion = vulnerabilities.first.currentVersion ?? '—';
    final fixedVersion = vulnerabilities.first.fixedVersion ?? '—';
    final cves = vulnerabilities
        .where((v) => v.cveId != null)
        .map((v) => v.cveId!)
        .toList();

    return Card(
      color: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package name
            Text(
              dependencyName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Version transition
            Row(
              children: [
                Text(
                  currentVersion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                Text(
                  fixedVersion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.success,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // CVEs resolved
            if (cves.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: cves.map((cve) {
                  return Chip(
                    label: Text(
                      cve,
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: CodeOpsColors.surfaceVariant,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            // Mark Resolved button
            OutlinedButton.icon(
              icon: const Icon(Icons.check_circle, size: 16),
              label: Text('Mark Resolved (${vulnerabilities.length})'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CodeOpsColors.success,
                side: const BorderSide(color: CodeOpsColors.success),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                textStyle: const TextStyle(fontSize: 12),
              ),
              onPressed: () => onMarkResolved?.call(vulnerabilities),
            ),
          ],
        ),
      ),
    );
  }
}
