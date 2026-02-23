/// Summary card displaying impact analysis statistics.
///
/// Shows total affected services, breakdown by depth/severity,
/// and required vs optional counts.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';
import 'impact_node_tile.dart';

/// Summary card for impact analysis results.
///
/// Displays the source service name, total affected count, and a breakdown
/// of impacted services grouped by severity (depth). Shows required vs
/// optional distinction.
class ImpactSummaryCard extends StatelessWidget {
  /// The impact analysis response data.
  final ImpactAnalysisResponse analysis;

  /// Creates an [ImpactSummaryCard].
  const ImpactSummaryCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final requiredCount = analysis.impactedServices
        .where((s) => s.isRequired == true)
        .length;
    final optionalCount = analysis.totalAffected - requiredCount;

    // Group by depth for severity breakdown.
    final depthGroups = <int, int>{};
    for (final s in analysis.impactedServices) {
      depthGroups[s.depth] = (depthGroups[s.depth] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.assessment_outlined,
                size: 18,
                color: CodeOpsColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Impact Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Source service
          _StatRow(
            label: 'Source',
            value: analysis.sourceServiceName,
          ),
          const SizedBox(height: 6),
          // Total affected
          _StatRow(
            label: 'Total Affected',
            value: '${analysis.totalAffected}',
          ),
          const SizedBox(height: 6),
          // Required / Optional
          _StatRow(
            label: 'Required',
            value: '$requiredCount',
            color: CodeOpsColors.error,
          ),
          const SizedBox(height: 4),
          _StatRow(
            label: 'Optional',
            value: '$optionalCount',
            color: CodeOpsColors.textTertiary,
          ),
          const SizedBox(height: 12),
          // Severity breakdown
          const Text(
            'By Severity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ..._buildSeverityRows(depthGroups),
        ],
      ),
    );
  }

  List<Widget> _buildSeverityRows(Map<int, int> depthGroups) {
    final sorted = depthGroups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((entry) {
      final color = impactDepthColor(entry.key);
      final label = impactSeverityLabel(entry.key);
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${entry.value}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

/// A labeled stat row.
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? CodeOpsColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
