/// Vault dashboard page.
///
/// Landing page at `/vault` providing an at-a-glance overview of the
/// Vault system: seal status, secret counts by type, expiring secrets,
/// policy stats, transit key stats, active lease count, quick actions,
/// and recent audit activity.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/vault_enums.dart';
import '../providers/vault_providers.dart';
import '../theme/colors.dart';
import '../widgets/vault/expiring_secrets_list.dart';
import '../widgets/vault/seal_status_badge.dart';
import '../widgets/vault/vault_audit_feed.dart';
import '../widgets/vault/vault_quick_actions.dart';
import '../widgets/vault/vault_stat_card.dart';

/// The Vault dashboard page.
class VaultDashboardPage extends ConsumerWidget {
  /// Creates a [VaultDashboardPage].
  const VaultDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sealAsync = ref.watch(sealStatusProvider);
    final isSealed = sealAsync.whenOrNull(
          data: (s) => s.status == SealStatus.sealed,
        ) ??
        false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and seal badge
          Row(
            children: [
              Text(
                'Vault Dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              const SealStatusBadge(),
            ],
          ),
          const SizedBox(height: 20),

          // Sealed warning banner
          if (isSealed) ...[
            _SealedWarningBanner(),
            const SizedBox(height: 20),
          ],

          // Stat cards grid
          const _StatsGrid(),
          const SizedBox(height: 24),

          // Quick actions
          const VaultQuickActions(),
          const SizedBox(height: 24),

          // Expiring secrets and audit feed side by side
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    const ExpiringSecretsList(),
                    const SizedBox(height: 16),
                    const VaultAuditFeed(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: ExpiringSecretsList()),
                  const SizedBox(width: 16),
                  const Expanded(child: VaultAuditFeed()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats Grid
// ---------------------------------------------------------------------------

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secretsAsync = ref.watch(vaultSecretStatsProvider);
    final policiesAsync = ref.watch(vaultPolicyStatsProvider);
    final transitAsync = ref.watch(vaultTransitStatsProvider);
    final leasesAsync = ref.watch(vaultActiveLeaseCountProvider);

    return Row(
      children: [
        Expanded(
          child: VaultStatCard(
            title: 'Secrets',
            value: secretsAsync.when(
              loading: () => '\u2014',
              error: (_, __) => '\u2014',
              data: (stats) => _sumValues(stats),
            ),
            icon: Icons.key_outlined,
            color: CodeOpsColors.primary,
            onTap: () => context.go('/vault/secrets'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VaultStatCard(
            title: 'Policies',
            value: policiesAsync.when(
              loading: () => '\u2014',
              error: (_, __) => '\u2014',
              data: (stats) => _sumValues(stats),
            ),
            icon: Icons.policy_outlined,
            color: const Color(0xFF3B82F6),
            onTap: () => context.go('/vault/policies'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VaultStatCard(
            title: 'Transit Keys',
            value: transitAsync.when(
              loading: () => '\u2014',
              error: (_, __) => '\u2014',
              data: (stats) => _sumValues(stats),
            ),
            icon: Icons.transform_outlined,
            color: const Color(0xFFA855F7),
            onTap: () => context.go('/vault/transit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VaultStatCard(
            title: 'Active Leases',
            value: leasesAsync.when(
              loading: () => '\u2014',
              error: (_, __) => '\u2014',
              data: (count) => '$count',
            ),
            icon: Icons.autorenew_outlined,
            color: CodeOpsColors.warning,
            onTap: () => context.go('/vault/dynamic'),
          ),
        ),
      ],
    );
  }

  /// Sums all values in a stats map and formats as a string.
  static String _sumValues(Map<String, int> stats) {
    if (stats.isEmpty) return '0';
    final total = stats.values.fold<int>(0, (a, b) => a + b);
    return '$total';
  }
}

// ---------------------------------------------------------------------------
// Sealed Warning Banner
// ---------------------------------------------------------------------------

class _SealedWarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CodeOpsColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CodeOpsColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, size: 20, color: CodeOpsColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vault is sealed. All operations are blocked until it is unsealed.',
              style: TextStyle(
                fontSize: 13,
                color: CodeOpsColors.error.withValues(alpha: 0.9),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/vault/seal'),
            child: const Text('Unseal Vault'),
          ),
        ],
      ),
    );
  }
}
