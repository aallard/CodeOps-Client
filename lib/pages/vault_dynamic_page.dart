/// Vault Dynamic Secrets page with lease management.
///
/// Left panel shows secrets filtered to [SecretType.dynamic_].
/// Right panel shows active leases, lease statistics, create/revoke
/// actions, and paginated lease history for the selected secret.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_snapshot.dart';
import '../models/vault_enums.dart';
import '../models/vault_models.dart';
import '../providers/vault_providers.dart';
import '../theme/colors.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/error_panel.dart';
import '../widgets/shared/loading_overlay.dart';
import '../widgets/vault/create_lease_dialog.dart';
import '../widgets/vault/lease_table.dart';

/// UI-state provider for the selected dynamic secret ID.
final selectedDynamicSecretIdProvider = StateProvider<String?>((ref) => null);

/// Fetches secrets filtered to DYNAMIC type for this page.
final dynamicSecretsProvider =
    FutureProvider<PageResponse<SecretResponse>>((ref) {
  final api = ref.watch(vaultApiProvider);
  final page = ref.watch(dynamicSecretsPageProvider);
  return api.listSecrets(
    type: SecretType.dynamic_,
    activeOnly: true,
    page: page,
    size: 20,
  );
});

/// Page index for the dynamic secrets list.
final dynamicSecretsPageProvider = StateProvider<int>((ref) => 0);

/// The Vault Dynamic Secrets page with master-detail layout.
class VaultDynamicPage extends ConsumerStatefulWidget {
  /// Creates a [VaultDynamicPage].
  const VaultDynamicPage({super.key});

  @override
  ConsumerState<VaultDynamicPage> createState() => _VaultDynamicPageState();
}

class _VaultDynamicPageState extends ConsumerState<VaultDynamicPage> {
  @override
  Widget build(BuildContext context) {
    final secretsAsync = ref.watch(dynamicSecretsProvider);
    final selectedId = ref.watch(selectedDynamicSecretIdProvider);
    final activeCountAsync = ref.watch(vaultActiveLeaseCountProvider);

    return Column(
      children: [
        // Header
        _buildHeader(activeCountAsync),
        // Content
        Expanded(
          child: _buildContent(secretsAsync, selectedId),
        ),
      ],
    );
  }

  Widget _buildHeader(AsyncValue<int> activeCountAsync) {
    final count = activeCountAsync.whenOrNull(data: (c) => c) ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.divider),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Dynamic Secrets',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CodeOpsColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 14, color: CodeOpsColors.secondary),
                const SizedBox(width: 4),
                Text(
                  'Active Leases: $count',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<PageResponse<SecretResponse>> secretsAsync,
    String? selectedId,
  ) {
    return secretsAsync.when(
      loading: () =>
          const LoadingOverlay(message: 'Loading dynamic secrets...'),
      error: (e, _) => ErrorPanel.fromException(
        e,
        onRetry: () => ref.invalidate(dynamicSecretsProvider),
      ),
      data: (page) {
        final secrets = page.content;

        if (secrets.isEmpty) {
          return const EmptyState(
            icon: Icons.refresh_outlined,
            title: 'No dynamic secrets found',
            subtitle: 'Create a DYNAMIC type secret to generate leases.',
          );
        }

        // Find the selected secret
        SecretResponse? selected;
        if (selectedId != null) {
          for (final s in secrets) {
            if (s.id == selectedId) {
              selected = s;
              break;
            }
          }
        }

        return Row(
          children: [
            // Secret list
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: secrets.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: CodeOpsColors.border),
                      itemBuilder: (context, index) {
                        final secret = secrets[index];
                        final isActive = secret.id == selectedId;
                        return _DynamicSecretListItem(
                          secret: secret,
                          isSelected: isActive,
                          onTap: () {
                            ref
                                .read(selectedDynamicSecretIdProvider.notifier)
                                .state = secret.id;
                          },
                        );
                      },
                    ),
                  ),
                  _buildPagination(page),
                ],
              ),
            ),
            // Detail panel
            if (selected != null)
              _LeaseManagementPanel(
                secret: selected,
                onClose: () => ref
                    .read(selectedDynamicSecretIdProvider.notifier)
                    .state = null,
              ),
          ],
        );
      },
    );
  }

  Widget _buildPagination(PageResponse<SecretResponse> page) {
    final currentPage = ref.watch(dynamicSecretsPageProvider);
    final totalPages = page.totalPages;
    final totalElements = page.totalElements;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$totalElements secrets',
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.first_page, size: 18),
            onPressed: currentPage > 0 ? () => _goToPage(0) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            onPressed:
                currentPage > 0 ? () => _goToPage(currentPage - 1) : null,
          ),
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            onPressed: currentPage < totalPages - 1
                ? () => _goToPage(currentPage + 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page, size: 18),
            onPressed: currentPage < totalPages - 1
                ? () => _goToPage(totalPages - 1)
                : null,
          ),
        ],
      ),
    );
  }

  void _goToPage(int page) {
    ref.read(dynamicSecretsPageProvider.notifier).state = page;
  }
}

// ---------------------------------------------------------------------------
// Dynamic Secret List Item
// ---------------------------------------------------------------------------

class _DynamicSecretListItem extends ConsumerWidget {
  final SecretResponse secret;
  final bool isSelected;
  final VoidCallback onTap;

  const _DynamicSecretListItem({
    required this.secret,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaseStatsAsync = ref.watch(vaultLeaseStatsProvider(secret.id));
    final activeCount = leaseStatsAsync.whenOrNull(
          data: (stats) => stats['active'] ?? 0,
        ) ??
        0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color:
            isSelected ? CodeOpsColors.primary.withValues(alpha: 0.08) : null,
        child: Row(
          children: [
            const Icon(Icons.refresh_outlined,
                size: 18, color: CodeOpsColors.secondary),
            const SizedBox(width: 12),
            // Name + Path
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    secret.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    secret.path,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: CodeOpsColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Active lease count badge
            if (activeCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CodeOpsColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeCount active',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.success,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Active indicator
            if (secret.isActive)
              const Icon(Icons.circle, size: 8, color: CodeOpsColors.success),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lease Management Panel
// ---------------------------------------------------------------------------

class _LeaseManagementPanel extends ConsumerWidget {
  final SecretResponse secret;
  final VoidCallback? onClose;

  const _LeaseManagementPanel({
    required this.secret,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(vaultLeaseStatsProvider(secret.id));
    final leasesAsync = ref.watch(vaultLeasesProvider(secret.id));

    return Container(
      width: 520,
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(left: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        children: [
          _buildPanelHeader(context, ref, statsAsync),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(
            child: _buildLeaseContent(context, ref, leasesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, int>> statsAsync,
  ) {
    final stats = statsAsync.whenOrNull(data: (s) => s) ?? {};
    final active = stats['active'] ?? 0;
    final expired = stats['expired'] ?? 0;
    final revoked = stats['revoked'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  secret.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CodeOpsColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            secret.path,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: CodeOpsColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          // Lease stats
          Row(
            children: [
              _StatChip(label: 'Active', count: active, color: CodeOpsColors.success),
              const SizedBox(width: 6),
              _StatChip(label: 'Expired', count: expired, color: CodeOpsColors.textTertiary),
              const SizedBox(width: 6),
              _StatChip(label: 'Revoked', count: revoked, color: CodeOpsColors.error),
            ],
          ),
          const SizedBox(height: 8),
          // Action buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Create Lease'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CodeOpsColors.primary,
                  side: const BorderSide(color: CodeOpsColors.primary),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                onPressed: () => _showCreateLeaseDialog(context, ref),
              ),
              if (active > 0)
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 14),
                  label: Text('Revoke All ($active)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CodeOpsColors.error,
                    side: const BorderSide(color: CodeOpsColors.error),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () => _revokeAll(context, ref, active),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PageResponse<DynamicLeaseResponse>> leasesAsync,
  ) {
    return leasesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: CodeOpsColors.primary),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Failed to load leases: $e',
          style: const TextStyle(fontSize: 12, color: CodeOpsColors.error),
        ),
      ),
      data: (page) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Lease History',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            LeaseTable(
              leases: page.content,
              onRevoke: (leaseId) => _revokeLease(context, ref, leaseId),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateLeaseDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateLeaseDialog(
        secretId: secret.id,
        secretName: secret.name,
      ),
    );
    if (result == true) {
      ref.invalidate(vaultLeasesProvider(secret.id));
      ref.invalidate(vaultLeaseStatsProvider(secret.id));
      ref.invalidate(vaultActiveLeaseCountProvider);
    }
  }

  Future<void> _revokeAll(
    BuildContext context,
    WidgetRef ref,
    int activeCount,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Revoke All Leases',
      message: 'Revoke all $activeCount active leases for "${secret.name}"? '
          'Associated credentials will stop working immediately.',
      confirmLabel: 'Revoke All',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final api = ref.read(vaultApiProvider);
      final count = await api.revokeAllDynamicLeases(secret.id);
      ref.invalidate(vaultLeasesProvider(secret.id));
      ref.invalidate(vaultLeaseStatsProvider(secret.id));
      ref.invalidate(vaultActiveLeaseCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Revoked $count leases')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke: $e')),
        );
      }
    }
  }

  Future<void> _revokeLease(
    BuildContext context,
    WidgetRef ref,
    String leaseId,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Revoke Lease',
      message: 'Revoke lease "$leaseId"? '
          'The associated credentials will stop working immediately.',
      confirmLabel: 'Revoke',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final api = ref.read(vaultApiProvider);
      await api.revokeDynamicLease(leaseId);
      ref.invalidate(vaultLeasesProvider(secret.id));
      ref.invalidate(vaultLeaseStatsProvider(secret.id));
      ref.invalidate(vaultActiveLeaseCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lease revoked')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Stat Chip
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
