/// Visual port map showing all port ranges and their allocations.
///
/// Renders a scrollable column of [PortRangeCard] widgets, one per range
/// from the [PortMapResponse]. Includes a summary row showing total
/// allocated and available counts.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';
import 'port_range_card.dart';

/// Visual port map grid showing all port ranges and their allocations.
///
/// Each range is displayed as a [PortRangeCard] with a utilization bar
/// and port chips. Conflict ports are highlighted across all cards.
class PortMapGrid extends StatelessWidget {
  /// The port map containing all ranges and allocations.
  final PortMapResponse portMap;

  /// Detected port conflicts for highlighting.
  final List<PortConflictResponse> conflicts;

  /// Callback when a port chip is tapped.
  final ValueChanged<PortAllocationResponse>? onPortTap;

  /// Callback to deallocate a port.
  final ValueChanged<PortAllocationResponse>? onDeallocate;

  /// Creates a [PortMapGrid].
  const PortMapGrid({
    super.key,
    required this.portMap,
    required this.conflicts,
    this.onPortTap,
    this.onDeallocate,
  });

  @override
  Widget build(BuildContext context) {
    final conflictPorts = <int>{};
    for (final c in conflicts) {
      conflictPorts.add(c.portNumber);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: CodeOpsColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize_outlined,
                  size: 16, color: CodeOpsColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${portMap.totalAllocated} allocated / '
                '${portMap.totalAvailable} available across '
                '${portMap.ranges.length} '
                '${portMap.ranges.length == 1 ? 'range' : 'ranges'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Range cards
        if (portMap.ranges.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.dns_outlined,
                      size: 48, color: CodeOpsColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text(
                    'No port ranges configured',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CodeOpsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Seed default ranges to get started.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...portMap.ranges.map((range) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PortRangeCard(
                range: range,
                conflictPorts: conflictPorts,
                onPortTap: onPortTap,
                onDeallocate: onDeallocate,
              ),
            );
          }),
      ],
    );
  }
}
