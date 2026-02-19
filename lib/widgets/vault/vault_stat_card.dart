/// Reusable stat card for the Vault overview grid.
///
/// Displays a labeled value with an icon and optional color accent.
/// Tappable to navigate to a related sub-page.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// A single stat card for the Vault dashboard overview grid.
class VaultStatCard extends StatelessWidget {
  /// Card title label.
  final String title;

  /// Formatted stat value.
  final String value;

  /// Leading icon.
  final IconData icon;

  /// Accent color for the icon and value.
  final Color color;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a [VaultStatCard].
  const VaultStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CodeOpsColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CodeOpsColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
