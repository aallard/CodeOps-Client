/// Quick action buttons for the Fleet dashboard.
///
/// Provides one-click shortcuts for common Fleet operations:
/// start default workstation, stop all containers, sync state, prune images.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Callback signatures for each quick action.
typedef FleetQuickActionCallbacks = ({
  VoidCallback onStartWorkstation,
  VoidCallback onStopAll,
  VoidCallback onSync,
  VoidCallback onPruneImages,
});

/// A grid of quick action buttons for the Fleet dashboard.
class FleetQuickActions extends StatelessWidget {
  /// Callbacks invoked when each action button is tapped.
  final FleetQuickActionCallbacks callbacks;

  /// Whether any action is currently in progress.
  final bool isBusy;

  /// Creates [FleetQuickActions] with the given [callbacks].
  const FleetQuickActions({
    super.key,
    required this.callbacks,
    this.isBusy = false,
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
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                icon: Icons.play_arrow,
                label: 'Start Default Workstation',
                color: CodeOpsColors.success,
                onTap: isBusy ? null : callbacks.onStartWorkstation,
              ),
              _ActionButton(
                icon: Icons.stop,
                label: 'Stop All',
                color: CodeOpsColors.error,
                onTap: isBusy ? null : callbacks.onStopAll,
              ),
              _ActionButton(
                icon: Icons.sync,
                label: 'Sync Containers',
                color: CodeOpsColors.secondary,
                onTap: isBusy ? null : callbacks.onSync,
              ),
              _ActionButton(
                icon: Icons.cleaning_services_outlined,
                label: 'Prune Images',
                color: CodeOpsColors.warning,
                onTap: isBusy ? null : callbacks.onPruneImages,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: onTap != null ? color : null),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: onTap != null ? color : CodeOpsColors.textTertiary,
        side: BorderSide(color: CodeOpsColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
