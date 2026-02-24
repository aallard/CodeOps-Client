/// Reusable badge widget displaying a secret's lifecycle status.
///
/// Shows one of four states: **Active** (green dot), **Inactive** (grey),
/// **Expiring Soon** (amber clock, < 72 h), or **Expiring Urgent**
/// (red clock, < 24 h). Used in the secret list items and detail panels.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// A compact badge indicating a secret's lifecycle status.
///
/// The badge displays:
/// - A green dot with "Active" when the secret is active and not expiring.
/// - An amber clock with "Expiring" when expiry is within 72 hours.
/// - A red clock with "Urgent" when expiry is within 24 hours.
/// - A grey "Inactive" label when the secret is not active.
///
/// Usage:
/// ```dart
/// VaultSecretStatusBadge(isActive: true, expiresAt: someDate)
/// VaultSecretStatusBadge(isActive: false)
/// ```
class VaultSecretStatusBadge extends StatelessWidget {
  /// Whether the secret is currently active.
  final bool isActive;

  /// Optional expiration timestamp for the secret.
  final DateTime? expiresAt;

  /// Creates a [VaultSecretStatusBadge].
  const VaultSecretStatusBadge({
    super.key,
    required this.isActive,
    this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return _buildBadge(
        icon: Icons.cancel_outlined,
        label: 'Inactive',
        color: CodeOpsColors.textTertiary,
      );
    }

    final remaining = expiresAt?.difference(DateTime.now());

    if (remaining != null && remaining.inHours < 24) {
      return _buildBadge(
        icon: Icons.schedule,
        label: 'Urgent',
        color: CodeOpsColors.error,
      );
    }

    if (remaining != null && remaining.inHours < 72) {
      return _buildBadge(
        icon: Icons.schedule,
        label: 'Expiring',
        color: CodeOpsColors.warning,
      );
    }

    return _buildBadge(
      icon: Icons.circle,
      label: 'Active',
      color: CodeOpsColors.success,
      iconSize: 8,
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    double iconSize = 12,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
