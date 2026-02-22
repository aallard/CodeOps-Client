/// Registry dashboard page.
///
/// Landing page at `/registry` providing an at-a-glance overview of the
/// Registry system: service count, solution count, ecosystem stats,
/// health summary, and quick navigation to sub-pages.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/registry_providers.dart';
import '../theme/colors.dart';

/// The Registry dashboard page.
class RegistryDashboardPage extends ConsumerWidget {
  /// Creates a [RegistryDashboardPage].
  const RegistryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(registryEcosystemStatsProvider);
    final healthAsync = ref.watch(registryTeamHealthSummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Registry Dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Service registry, dependency graphs, port management, and infrastructure tracking.',
            style: TextStyle(
              fontSize: 14,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          statsAsync.when(
            data: (stats) {
              if (stats == null) {
                return const _EmptyTeamBanner();
              }
              return _StatsRow(
                totalServices: stats.totalServices,
                totalSolutions: stats.totalSolutions,
                totalDependencies: stats.totalDependencies,
                orphanedServices: stats.orphanedServices,
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => _ErrorBanner(message: e.toString()),
          ),
          const SizedBox(height: 24),

          // Health summary
          healthAsync.when(
            data: (health) {
              if (health == null) return const SizedBox.shrink();
              return _HealthSummaryCard(
                totalServices: health.totalServices,
                healthyCount: health.servicesUp,
                degradedCount: health.servicesDegraded,
                downCount: health.servicesDown,
                unknownCount: health.servicesUnknown,
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats Row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final int totalServices;
  final int totalSolutions;
  final int totalDependencies;
  final int orphanedServices;

  const _StatsRow({
    required this.totalServices,
    required this.totalSolutions,
    required this.totalDependencies,
    required this.orphanedServices,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Services',
            value: totalServices.toString(),
            icon: Icons.dns_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Solutions',
            value: totalSolutions.toString(),
            icon: Icons.category_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Dependencies',
            value: totalDependencies.toString(),
            icon: Icons.account_tree_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Orphaned',
            value: orphanedServices.toString(),
            icon: Icons.cloud_outlined,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: CodeOpsColors.primary),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Health Summary Card
// ---------------------------------------------------------------------------

class _HealthSummaryCard extends StatelessWidget {
  final int totalServices;
  final int healthyCount;
  final int degradedCount;
  final int downCount;
  final int unknownCount;

  const _HealthSummaryCard({
    required this.totalServices,
    required this.healthyCount,
    required this.degradedCount,
    required this.downCount,
    required this.unknownCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Health',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HealthChip(
                label: 'Healthy',
                count: healthyCount,
                color: CodeOpsColors.success,
              ),
              const SizedBox(width: 16),
              _HealthChip(
                label: 'Degraded',
                count: degradedCount,
                color: CodeOpsColors.warning,
              ),
              const SizedBox(width: 16),
              _HealthChip(
                label: 'Down',
                count: downCount,
                color: CodeOpsColors.error,
              ),
              const SizedBox(width: 16),
              _HealthChip(
                label: 'Unknown',
                count: unknownCount,
                color: CodeOpsColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _HealthChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty Team Banner
// ---------------------------------------------------------------------------

class _EmptyTeamBanner extends StatelessWidget {
  const _EmptyTeamBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: CodeOpsColors.textTertiary),
          SizedBox(width: 12),
          Text(
            'Select a team to view registry data.',
            style: TextStyle(
              fontSize: 14,
              color: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error Banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CodeOpsColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: CodeOpsColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
