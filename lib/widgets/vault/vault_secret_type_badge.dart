/// Reusable badge widget displaying a secret's [SecretType].
///
/// Shows the type label with a color-coded background derived from
/// [CodeOpsColors.secretTypeColors]. Used in the secret list items,
/// detail panels, and anywhere a compact type indicator is needed.
library;

import 'package:flutter/material.dart';

import '../../models/vault_enums.dart';
import '../../theme/colors.dart';

/// A compact badge that displays a [SecretType] label with color coding.
///
/// The badge background and text color are derived from the
/// [CodeOpsColors.secretTypeColors] map. Each type renders with its
/// associated icon:
/// - **Static** (`key_outlined`) — primary purple
/// - **Dynamic** (`refresh_outlined`) — cyan secondary
/// - **Reference** (`link_outlined`) — amber warning
///
/// Usage:
/// ```dart
/// VaultSecretTypeBadge(type: SecretType.static_)
/// VaultSecretTypeBadge(type: SecretType.dynamic_, showIcon: true)
/// ```
class VaultSecretTypeBadge extends StatelessWidget {
  /// The secret type to display.
  final SecretType type;

  /// Whether to show the type icon alongside the label. Defaults to `false`.
  final bool showIcon;

  /// Creates a [VaultSecretTypeBadge].
  const VaultSecretTypeBadge({
    super.key,
    required this.type,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        CodeOpsColors.secretTypeColors[type] ?? CodeOpsColors.textTertiary;
    final icon = switch (type) {
      SecretType.static_ => Icons.key_outlined,
      SecretType.dynamic_ => Icons.refresh_outlined,
      SecretType.reference => Icons.link_outlined,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            type.displayName,
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
