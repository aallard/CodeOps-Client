/// CPU and memory resource usage gauges for the Fleet dashboard.
///
/// Displays two horizontal linear progress bars with percentage labels.
/// Color changes based on usage thresholds: green (<50%), yellow (50-80%),
/// red (>80%).
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';
import '../../utils/file_utils.dart';

/// A pair of CPU and memory resource usage gauges.
class FleetResourceGauges extends StatelessWidget {
  /// The health summary containing resource usage data.
  final FleetHealthSummary summary;

  /// Creates [FleetResourceGauges] from a [summary].
  const FleetResourceGauges({super.key, required this.summary});

  /// Returns a color based on usage percentage thresholds.
  static Color colorForPercent(double percent) {
    if (percent > 0.8) return CodeOpsColors.error;
    if (percent > 0.5) return CodeOpsColors.warning;
    return CodeOpsColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final cpuPercent = (summary.totalCpuPercent ?? 0) / 100;
    final memBytes = summary.totalMemoryBytes ?? 0;
    final memLimit = summary.totalMemoryLimitBytes ?? 1;
    final memPercent = memLimit > 0 ? memBytes / memLimit : 0.0;

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
          const Text(
            'Resource Usage',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _GaugeRow(
            label: 'CPU',
            percent: cpuPercent,
            detail: '${(summary.totalCpuPercent ?? 0).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
          _GaugeRow(
            label: 'Memory',
            percent: memPercent,
            detail:
                '${formatFileSize(memBytes)} / ${formatFileSize(memLimit)}',
          ),
        ],
      ),
    );
  }
}

class _GaugeRow extends StatelessWidget {
  final String label;
  final double percent;
  final String detail;

  const _GaugeRow({
    required this.label,
    required this.percent,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    final color = FleetResourceGauges.colorForPercent(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              detail,
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8,
            backgroundColor: CodeOpsColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
