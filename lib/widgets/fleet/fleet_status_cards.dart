/// Status summary cards for the Fleet dashboard.
///
/// Displays four stat cards showing Running, Stopped, Unhealthy, and Total
/// container counts sourced from [FleetHealthSummary].
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';

/// A row of four status cards: Running, Stopped, Unhealthy, Total.
class FleetStatusCards extends StatelessWidget {
  /// The health summary data to display. Null fields show '\u2014'.
  final FleetHealthSummary summary;

  /// Creates [FleetStatusCards] from a [summary].
  const FleetStatusCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            label: 'Running',
            value: summary.runningContainers,
            color: CodeOpsColors.success,
            icon: Icons.play_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            label: 'Stopped',
            value: summary.stoppedContainers,
            color: CodeOpsColors.textTertiary,
            icon: Icons.stop_circle_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            label: 'Unhealthy',
            value: summary.unhealthyContainers,
            color: CodeOpsColors.error,
            icon: Icons.error_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            label: 'Total',
            value: summary.totalContainers,
            color: CodeOpsColors.primary,
            icon: Icons.dns_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int? value;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '\u2014',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
