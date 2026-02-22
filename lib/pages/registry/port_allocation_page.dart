/// Port allocation management page.
///
/// Displays the visual port map grid with ranges, utilization bars,
/// and allocated port chips. Supports environment switching,
/// auto/manual allocation, conflict detection, range seeding,
/// and port deallocation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/registry_models.dart';
import '../../providers/registry_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/registry/port_allocate_dialog.dart';
import '../../widgets/registry/port_conflict_banner.dart';
import '../../widgets/registry/port_map_grid.dart';
import '../../widgets/shared/error_panel.dart';
import '../../widgets/shared/notification_toast.dart';

/// Port allocation management page.
///
/// Watches [registryPortMapProvider] for the port map data and
/// [registryPortConflictsProvider] for conflict detection. Provides
/// environment switching, auto-allocate, seed ranges, and
/// port deallocation actions.
class PortAllocationPage extends ConsumerWidget {
  /// Creates a [PortAllocationPage].
  const PortAllocationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portMapAsync = ref.watch(registryPortMapProvider);
    final conflictsAsync = ref.watch(registryPortConflictsProvider);
    final environment = ref.watch(registryPortEnvironmentProvider);

    return Column(
      children: [
        // Header bar
        _HeaderBar(environment: environment),
        // Content
        Expanded(
          child: portMapAsync.when(
            data: (portMap) {
              if (portMap == null) {
                return const Center(
                  child: Text(
                    'Select a team to view port allocations.',
                    style: TextStyle(
                      fontSize: 14,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                );
              }
              final conflicts = conflictsAsync.valueOrNull ?? [];
              return _PortMapContent(
                portMap: portMap,
                conflicts: conflicts,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (e, _) => ErrorPanel(
              title: 'Failed to Load Port Map',
              message: e.toString(),
              onRetry: () => ref.invalidate(registryPortMapProvider),
            ),
          ),
        ),
      ],
    );
  }
}

/// Header bar with title, environment selector, and action buttons.
class _HeaderBar extends ConsumerWidget {
  final String environment;

  const _HeaderBar({required this.environment});

  Future<void> _seedRanges(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CodeOpsColors.surface,
        title: const Text('Seed Default Ranges',
            style: TextStyle(color: CodeOpsColors.textPrimary)),
        content: Text(
          'This will create default port ranges for the '
          '"$environment" environment. Continue?',
          style: const TextStyle(color: CodeOpsColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Seed Ranges'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) return;
      final api = ref.read(registryApiProvider);
      await api.seedDefaultRanges(teamId, environment: environment);
      ref.invalidate(registryPortMapProvider);
      ref.invalidate(registryPortRangesProvider);
      if (context.mounted) {
        showToast(context,
            message: 'Default ranges seeded for "$environment"',
            type: ToastType.success);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context,
            message: 'Seed failed: $e', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Port Allocations',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Environment selector
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: environment,
              decoration: const InputDecoration(
                labelText: 'Environment',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dropdownColor: CodeOpsColors.surface,
              items: const [
                DropdownMenuItem(value: 'local', child: Text('local')),
                DropdownMenuItem(value: 'dev', child: Text('dev')),
                DropdownMenuItem(value: 'staging', child: Text('staging')),
                DropdownMenuItem(value: 'prod', child: Text('prod')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(registryPortEnvironmentProvider.notifier).state =
                      value;
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => showPortAllocateDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Allocate'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CodeOpsColors.border),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _seedRanges(context, ref),
            icon: const Icon(Icons.playlist_add, size: 16),
            label: const Text('Seed Ranges'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CodeOpsColors.border),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable content area with conflict banner and port map grid.
class _PortMapContent extends ConsumerWidget {
  final PortMapResponse portMap;
  final List<PortConflictResponse> conflicts;

  const _PortMapContent({required this.portMap, required this.conflicts});

  Future<void> _deallocatePort(
    BuildContext context,
    WidgetRef ref,
    PortAllocationResponse alloc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CodeOpsColors.surface,
        title: const Text('Deallocate Port',
            style: TextStyle(color: CodeOpsColors.textPrimary)),
        content: Text(
          'Release port ${alloc.portNumber} from '
          '${alloc.serviceName ?? 'this service'}?',
          style: const TextStyle(color: CodeOpsColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: CodeOpsColors.error,
            ),
            child: const Text('Deallocate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final api = ref.read(registryApiProvider);
      await api.releasePort(alloc.id);
      ref.invalidate(registryPortMapProvider);
      ref.invalidate(registryPortConflictsProvider);
      if (context.mounted) {
        showToast(context,
            message: 'Port ${alloc.portNumber} released',
            type: ToastType.success);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context,
            message: 'Deallocation failed: $e', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conflict banner
          if (conflicts.isNotEmpty) ...[
            PortConflictBanner(conflicts: conflicts),
            const SizedBox(height: 16),
          ],
          // Port map grid
          PortMapGrid(
            portMap: portMap,
            conflicts: conflicts,
            onDeallocate: (alloc) => _deallocatePort(context, ref, alloc),
          ),
        ],
      ),
    );
  }
}
