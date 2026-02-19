/// Detail panel for a Vault access policy.
///
/// Displays policy metadata (name, path pattern, permissions, deny/active
/// status), action buttons (Edit, Delete, Toggle Active, Add Binding),
/// and a list of associated bindings with delete capability.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_models.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import '../shared/confirm_dialog.dart';
import '../shared/error_panel.dart';
import 'create_binding_dialog.dart';
import 'permission_badge.dart';

/// Displays full detail for an [AccessPolicyResponse] with bindings list.
class PolicyDetailPanel extends ConsumerWidget {
  /// The policy to display.
  final AccessPolicyResponse policy;

  /// Called when the panel should close.
  final VoidCallback? onClose;

  /// Called after a mutation so the parent can refresh.
  final VoidCallback? onMutated;

  /// Creates a [PolicyDetailPanel].
  const PolicyDetailPanel({
    super.key,
    required this.policy,
    this.onClose,
    this.onMutated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindingsAsync = ref.watch(vaultPolicyBindingsProvider(policy.id));

    return Container(
      width: 420,
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(left: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        children: [
          _buildHeader(context, ref),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoSection(),
                const SizedBox(height: 16),
                _buildPermissionsSection(),
                const SizedBox(height: 16),
                const Divider(height: 1, color: CodeOpsColors.border),
                const SizedBox(height: 16),
                _buildBindingsSection(context, ref, bindingsAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        policy.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CodeOpsColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (policy.isDenyPolicy) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CodeOpsColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: CodeOpsColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'DENY',
                          style: TextStyle(
                            color: CodeOpsColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
            ],
          ),
          Text(
            policy.pathPattern,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: CodeOpsColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ActionButton(
                label: policy.isActive ? 'Deactivate' : 'Activate',
                icon: policy.isActive
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: policy.isActive
                    ? CodeOpsColors.warning
                    : CodeOpsColors.success,
                onPressed: () => _toggleActive(context, ref),
              ),
              _ActionButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                color: CodeOpsColors.error,
                onPressed: () => _deletePolicy(context, ref),
              ),
              _ActionButton(
                label: 'Add Binding',
                icon: Icons.link,
                onPressed: () => _addBinding(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Name', policy.name),
        _field('Path Pattern', policy.pathPattern),
        if (policy.description != null)
          _field('Description', policy.description!),
        _field('Type', policy.isDenyPolicy ? 'Deny' : 'Allow'),
        _field('Active', policy.isActive ? 'Yes' : 'No'),
        _field('Bindings', '${policy.bindingCount}'),
        if (policy.createdByUserId != null)
          _field('Created By', policy.createdByUserId!.substring(0, 8)),
        _field('Created', formatDateTime(policy.createdAt)),
        _field('Updated', formatDateTime(policy.updatedAt)),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permissions',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: policy.permissions
              .map((p) => PermissionBadge(permission: p))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBindingsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PolicyBindingResponse>> bindingsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bindings',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        bindingsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, _) => ErrorPanel.fromException(
            error,
            onRetry: () =>
                ref.invalidate(vaultPolicyBindingsProvider(policy.id)),
          ),
          data: (bindings) {
            if (bindings.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No bindings',
                    style: TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: bindings
                  .map((b) => _BindingRow(
                        binding: b,
                        onDelete: () => _deleteBinding(context, ref, b),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    try {
      final api = ref.read(vaultApiProvider);
      await api.updatePolicy(policy.id, isActive: !policy.isActive);
      ref.invalidate(vaultPoliciesProvider);
      ref.invalidate(vaultPolicyDetailProvider(policy.id));
      onMutated?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              policy.isActive ? 'Policy deactivated' : 'Policy activated',
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

  Future<void> _deletePolicy(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Policy',
      message:
          'Are you sure you want to delete "${policy.name}"? '
          'All bindings will also be removed.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final api = ref.read(vaultApiProvider);
      await api.deletePolicy(policy.id);
      ref.invalidate(vaultPoliciesProvider);
      ref.invalidate(vaultPolicyStatsProvider);
      onMutated?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Policy deleted')),
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

  Future<void> _addBinding(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateBindingDialog(policyId: policy.id),
    );
    if (result == true) {
      ref.invalidate(vaultPolicyBindingsProvider(policy.id));
      ref.invalidate(vaultPoliciesProvider);
      onMutated?.call();
    }
  }

  Future<void> _deleteBinding(
    BuildContext context,
    WidgetRef ref,
    PolicyBindingResponse binding,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Binding',
      message:
          'Remove ${binding.bindingType.displayName} binding '
          '"${binding.bindingTargetId.substring(0, 8)}..."?',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final api = ref.read(vaultApiProvider);
      await api.deleteBinding(binding.id);
      ref.invalidate(vaultPolicyBindingsProvider(policy.id));
      ref.invalidate(vaultPoliciesProvider);
      onMutated?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Binding removed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
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

// ---------------------------------------------------------------------------
// Binding Row
// ---------------------------------------------------------------------------

class _BindingRow extends StatelessWidget {
  final PolicyBindingResponse binding;
  final VoidCallback onDelete;

  const _BindingRow({required this.binding, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final typeColor = CodeOpsColors.bindingTypeColors[binding.bindingType] ??
        CodeOpsColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Binding type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: typeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              binding.bindingType.toJson(),
              style: TextStyle(
                color: typeColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Target ID
          Expanded(
            child: Text(
              binding.bindingTargetId,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: CodeOpsColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Created date
          Text(
            formatTimeAgo(binding.createdAt),
            style: const TextStyle(
              fontSize: 10,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          const SizedBox(width: 4),
          // Delete button
          IconButton(
            icon: const Icon(Icons.close, size: 14),
            tooltip: 'Remove binding',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
