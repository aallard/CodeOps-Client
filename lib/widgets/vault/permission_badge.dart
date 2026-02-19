/// Colored badge for a [PolicyPermission] value.
///
/// Displays the permission name in a small, colored pill badge.
/// Uses [CodeOpsColors.policyPermissionColors] for consistent theming
/// across policies, bindings, and evaluation results.
library;

import 'package:flutter/material.dart';

import '../../models/vault_enums.dart';
import '../../theme/colors.dart';

/// A small colored badge that displays a [PolicyPermission] label.
class PermissionBadge extends StatelessWidget {
  /// The permission to display.
  final PolicyPermission permission;

  /// Creates a [PermissionBadge].
  const PermissionBadge({super.key, required this.permission});

  @override
  Widget build(BuildContext context) {
    final color =
        CodeOpsColors.policyPermissionColors[permission] ?? CodeOpsColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        permission.toJson(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
