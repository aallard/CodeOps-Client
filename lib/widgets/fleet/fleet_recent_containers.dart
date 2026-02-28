/// Recent containers list for the Fleet dashboard.
///
/// Shows the most recent containers (up to 5) with status badges and
/// relative timestamps. Includes a "View All" link to navigate to
/// the full container list page.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_enums.dart';
import '../../models/fleet_models.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import 'container_status_badge.dart';

/// Displays the most recent containers with status and age.
class FleetRecentContainers extends StatelessWidget {
  /// The containers to display (limited externally to 5).
  final List<FleetContainerInstance> containers;

  /// Callback invoked when "View All" is tapped.
  final VoidCallback onViewAll;

  /// Callback invoked when a container row is tapped.
  final ValueChanged<FleetContainerInstance> onTap;

  /// Creates [FleetRecentContainers].
  const FleetRecentContainers({
    super.key,
    required this.containers,
    required this.onViewAll,
    required this.onTap,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Containers',
                style: TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'View All \u2192',
                  style: TextStyle(
                    color: CodeOpsColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (containers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No containers found',
                  style: TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...containers.map((c) => _ContainerRow(
                  container: c,
                  onTap: () => onTap(c),
                )),
        ],
      ),
    );
  }
}

class _ContainerRow extends StatelessWidget {
  final FleetContainerInstance container;
  final VoidCallback onTap;

  const _ContainerRow({required this.container, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                container.containerName ?? container.containerId ?? '\u2014',
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ContainerStatusBadge(
              status: container.status ?? ContainerStatus.created,
            ),
            const Spacer(),
            Text(
              formatTimeAgo(container.startedAt ?? container.createdAt),
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
