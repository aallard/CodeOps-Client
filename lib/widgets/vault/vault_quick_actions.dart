/// Quick-action cards for the Vault dashboard.
///
/// Row of hover-animated cards that navigate to primary Vault workflows.
/// Follows the same pattern as [QuickStartCards].
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';

/// A row of quick-action cards for Vault workflows.
class VaultQuickActions extends StatelessWidget {
  /// Creates a [VaultQuickActions] widget.
  const VaultQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionCard(
          icon: Icons.add_circle_outline,
          title: 'New Secret',
          route: '/vault/secrets',
        ),
        const SizedBox(width: 16),
        _ActionCard(
          icon: Icons.enhanced_encryption_outlined,
          title: 'Encrypt Data',
          route: '/vault/transit',
        ),
        const SizedBox(width: 16),
        _ActionCard(
          icon: Icons.policy_outlined,
          title: 'Manage Policies',
          route: '/vault/policies',
        ),
        const SizedBox(width: 16),
        _ActionCard(
          icon: Icons.receipt_long_outlined,
          title: 'View Audit Log',
          route: '/vault/seal',
        ),
        const SizedBox(width: 16),
        _ActionCard(
          icon: Icons.security_outlined,
          title: 'Seal Status',
          route: '/vault/seal',
        ),
      ].map((child) {
        if (child is SizedBox) return child;
        return Expanded(child: child);
      }).toList(),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String route;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CodeOpsColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _hovered ? CodeOpsColors.primary : CodeOpsColors.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color:
                          CodeOpsColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 28,
                color: _hovered
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _hovered
                      ? CodeOpsColors.textPrimary
                      : CodeOpsColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
