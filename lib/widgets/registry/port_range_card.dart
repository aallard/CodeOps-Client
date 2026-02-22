/// Card displaying a single port range with utilization bar and allocated ports.
///
/// Shows range type, span, capacity utilization as a color-coded bar,
/// and individual allocations as chips. Conflict ports are highlighted
/// with red borders.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';

/// Card for a single port range with utilization bar and port chips.
///
/// Displays the port type label, range span, capacity utilization bar
/// (green <50%, amber 50-80%, red >80%), and a grid of allocated port
/// chips. Conflict ports get a red border.
class PortRangeCard extends StatelessWidget {
  /// The port range with its allocations.
  final PortRangeWithAllocationsResponse range;

  /// Port numbers that have conflicts.
  final Set<int> conflictPorts;

  /// Callback when a port chip is tapped.
  final ValueChanged<PortAllocationResponse>? onPortTap;

  /// Callback to deallocate a port.
  final ValueChanged<PortAllocationResponse>? onDeallocate;

  /// Creates a [PortRangeCard].
  const PortRangeCard({
    super.key,
    required this.range,
    required this.conflictPorts,
    this.onPortTap,
    this.onDeallocate,
  });

  Color _utilizationColor(double percentage) {
    if (percentage >= 0.8) return CodeOpsColors.error;
    if (percentage >= 0.5) return CodeOpsColors.warning;
    return CodeOpsColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = range.totalCapacity > 0
        ? range.allocated / range.totalCapacity
        : 0.0;
    final color = _utilizationColor(percentage);

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CodeOpsColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    range.portType.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CodeOpsColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${range.rangeStart}\u2013${range.rangeEnd}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${range.allocated}/${range.totalCapacity} allocated',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Utilization bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: CodeOpsColors.surfaceVariant,
                color: color,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Percentage label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(percentage * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Port chips or empty message
          if (range.allocations.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                'No allocations',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: range.allocations.map((alloc) {
                  final isConflict = conflictPorts.contains(alloc.portNumber);
                  return _PortChip(
                    allocation: alloc,
                    isConflict: isConflict,
                    onTap: onPortTap != null ? () => onPortTap!(alloc) : null,
                    onDeallocate: onDeallocate != null
                        ? () => onDeallocate!(alloc)
                        : null,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Individual port allocation chip.
class _PortChip extends StatelessWidget {
  final PortAllocationResponse allocation;
  final bool isConflict;
  final VoidCallback? onTap;
  final VoidCallback? onDeallocate;

  const _PortChip({
    required this.allocation,
    required this.isConflict,
    this.onTap,
    this.onDeallocate,
  });

  @override
  Widget build(BuildContext context) {
    final label = allocation.serviceName ?? allocation.serviceSlug ?? '???';
    final truncated = label.length > 16 ? '${label.substring(0, 14)}\u2026' : label;

    return Tooltip(
      message: '$label \u2014 port ${allocation.portNumber}'
          '${allocation.description != null ? '\n${allocation.description}' : ''}',
      child: InkWell(
        onTap: onTap,
        onLongPress: onDeallocate,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isConflict
                ? CodeOpsColors.error.withValues(alpha: 0.12)
                : CodeOpsColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isConflict
                  ? CodeOpsColors.error
                  : CodeOpsColors.border,
              width: isConflict ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${allocation.portNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: isConflict
                      ? CodeOpsColors.error
                      : CodeOpsColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                truncated,
                style: TextStyle(
                  fontSize: 11,
                  color: isConflict
                      ? CodeOpsColors.error
                      : CodeOpsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
