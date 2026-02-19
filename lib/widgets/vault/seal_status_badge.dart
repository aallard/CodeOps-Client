/// Colored badge displaying the current Vault seal status.
///
/// SEALED = red + lock icon, UNSEALING = amber + hourglass,
/// UNSEALED = green + lock_open. Tappable to navigate to `/vault/seal`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/vault_enums.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';

/// A badge that shows the current Vault seal status with color and icon.
class SealStatusBadge extends ConsumerWidget {
  /// Creates a [SealStatusBadge].
  const SealStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sealAsync = ref.watch(sealStatusProvider);

    return sealAsync.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => _buildBadge(
        context,
        icon: Icons.error_outline,
        label: 'Unknown',
        color: CodeOpsColors.textTertiary,
      ),
      data: (status) {
        final (icon, label, color) = switch (status.status) {
          SealStatus.sealed => (
              Icons.lock,
              'Sealed',
              CodeOpsColors.error,
            ),
          SealStatus.unsealing => (
              Icons.hourglass_bottom,
              'Unsealing',
              CodeOpsColors.warning,
            ),
          SealStatus.unsealed => (
              Icons.lock_open,
              'Unsealed',
              CodeOpsColors.success,
            ),
        };
        return _buildBadge(context, icon: icon, label: label, color: color);
      },
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/vault/seal'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
