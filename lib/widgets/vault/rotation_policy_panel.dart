/// Rotation policy panel embedded in the secret detail.
///
/// Shows the rotation policy configuration (strategy, interval, countdown
/// to next rotation, failure count), action buttons (rotate now, pause/resume,
/// edit, delete), and a rotation history table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_models.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import '../shared/confirm_dialog.dart';
import 'rotation_history_table.dart';
import 'rotation_policy_dialog.dart';

/// Displays the rotation policy for a secret with actions and history.
///
/// When no policy exists, shows a "Set Up Rotation" prompt. When a policy
/// exists, shows configuration details, a countdown to the next rotation,
/// action buttons, and a paginated rotation history table.
class RotationPolicyPanel extends ConsumerWidget {
  /// UUID of the secret.
  final String secretId;

  /// Called after a mutation so the parent can refresh.
  final VoidCallback? onMutated;

  /// Creates a [RotationPolicyPanel].
  const RotationPolicyPanel({
    super.key,
    required this.secretId,
    this.onMutated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyAsync = ref.watch(vaultRotationPolicyProvider(secretId));
    final historyAsync = ref.watch(vaultRotationHistoryProvider(secretId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Policy section
        policyAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CodeOpsColors.primary,
              ),
            ),
          ),
          error: (e, _) => _buildNoPolicy(context, ref),
          data: (policy) => _buildPolicy(context, ref, policy),
        ),
        const SizedBox(height: 16),
        // History section
        const Text(
          'Rotation History',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        historyAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CodeOpsColors.primary,
              ),
            ),
          ),
          error: (e, _) => Text(
            'Failed to load history: $e',
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.error,
            ),
          ),
          data: (page) => RotationHistoryTable(entries: page.content),
        ),
      ],
    );
  }

  Widget _buildNoPolicy(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.sync_disabled,
              size: 40, color: CodeOpsColors.textTertiary),
          const SizedBox(height: 12),
          const Text(
            'No rotation policy configured',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Set up automatic rotation to keep this secret fresh.',
            style: TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Set Up Rotation'),
            onPressed: () => _showCreateDialog(context, ref),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicy(
    BuildContext context,
    WidgetRef ref,
    RotationPolicyResponse policy,
  ) {
    final strategyColor =
        CodeOpsColors.rotationStrategyColors[policy.strategy] ??
            CodeOpsColors.textTertiary;

    // Compute countdown
    String countdown = '\u2014';
    if (policy.nextRotationAt != null) {
      final remaining = policy.nextRotationAt!.difference(DateTime.now());
      if (remaining.isNegative) {
        countdown = 'Overdue';
      } else {
        countdown = '${formatDuration(remaining)} from now';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Edit
        Row(
          children: [
            const Text(
              'Rotation Policy',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showEditDialog(context, ref, policy),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Fields
        _field('Strategy', policy.strategy.displayName, color: strategyColor),
        _field(
          'Interval',
          'Every ${policy.rotationIntervalHours} hours',
        ),
        _field('Next Rotation', countdown),
        _field('Last Rotated', formatTimeAgo(policy.lastRotatedAt)),
        _field(
          'Failures',
          '${policy.failureCount} / ${policy.maxFailures ?? '\u221e'}',
        ),
        _field(
          'Status',
          policy.isActive ? 'Active' : 'Paused',
          color: policy.isActive ? CodeOpsColors.success : CodeOpsColors.warning,
        ),
        const SizedBox(height: 12),
        // Action buttons
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _ActionButton(
              label: 'Rotate Now',
              icon: Icons.sync,
              onPressed: () => _rotateNow(context, ref),
            ),
            _ActionButton(
              label: policy.isActive ? 'Pause' : 'Resume',
              icon: policy.isActive
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: policy.isActive
                  ? CodeOpsColors.warning
                  : CodeOpsColors.success,
              onPressed: () => _toggleActive(context, ref, policy),
            ),
            _ActionButton(
              label: 'Delete Policy',
              icon: Icons.delete_outline,
              color: CodeOpsColors.error,
              onPressed: () => _deletePolicy(context, ref, policy),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (color != null && label == 'Status')
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.circle, size: 8, color: color),
                  ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: color ?? CodeOpsColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RotationPolicyDialog(secretId: secretId),
    );
    if (result == true) {
      ref.invalidate(vaultRotationPolicyProvider(secretId));
      ref.invalidate(vaultRotationHistoryProvider(secretId));
      onMutated?.call();
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    RotationPolicyResponse policy,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RotationPolicyDialog(
        secretId: secretId,
        existingPolicy: policy,
      ),
    );
    if (result == true) {
      ref.invalidate(vaultRotationPolicyProvider(secretId));
      ref.invalidate(vaultRotationHistoryProvider(secretId));
      onMutated?.call();
    }
  }

  Future<void> _rotateNow(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Rotate Now',
      message: 'Trigger manual rotation for this secret? '
          'A new secret value will be generated immediately.',
      confirmLabel: 'Rotate',
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final api = ref.read(vaultApiProvider);
      await api.rotateSecret(secretId);
      ref.invalidate(vaultRotationPolicyProvider(secretId));
      ref.invalidate(vaultRotationHistoryProvider(secretId));
      ref.invalidate(vaultRotationStatsProvider(secretId));
      onMutated?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Secret rotated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rotate: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    RotationPolicyResponse policy,
  ) async {
    try {
      final api = ref.read(vaultApiProvider);
      await api.updateRotationPolicy(
        policy.id,
        isActive: !policy.isActive,
      );
      ref.invalidate(vaultRotationPolicyProvider(secretId));
      onMutated?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              policy.isActive ? 'Rotation paused' : 'Rotation resumed',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _deletePolicy(
    BuildContext context,
    WidgetRef ref,
    RotationPolicyResponse policy,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Rotation Policy',
      message: 'Delete the rotation policy for this secret? '
          'Automatic rotation will stop. History is preserved.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final api = ref.read(vaultApiProvider);
      await api.deleteRotationPolicy(policy.id);
      ref.invalidate(vaultRotationPolicyProvider(secretId));
      ref.invalidate(vaultRotationStatsProvider(secretId));
      onMutated?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rotation policy deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Action Button
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? CodeOpsColors.primary;
    return OutlinedButton.icon(
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: c),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(fontSize: 11),
      ),
      onPressed: onPressed,
    );
  }
}
