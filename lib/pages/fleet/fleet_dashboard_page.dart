/// Fleet dashboard page.
///
/// Landing page at `/fleet` providing an at-a-glance overview of the
/// Fleet system: container status counts, CPU/memory resource gauges,
/// quick actions (start workstation, stop all, sync, prune), and a
/// list of the most recent containers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/fleet_models.dart';
import '../../providers/fleet_providers.dart' hide selectedTeamIdProvider;
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../widgets/fleet/fleet_quick_actions.dart';
import '../../widgets/fleet/fleet_recent_containers.dart';
import '../../widgets/fleet/fleet_resource_gauges.dart';
import '../../widgets/fleet/fleet_status_cards.dart';
import '../../widgets/shared/confirm_dialog.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The Fleet dashboard page.
class FleetDashboardPage extends ConsumerStatefulWidget {
  /// Creates a [FleetDashboardPage].
  const FleetDashboardPage({super.key});

  @override
  ConsumerState<FleetDashboardPage> createState() =>
      _FleetDashboardPageState();
}

class _FleetDashboardPageState extends ConsumerState<FleetDashboardPage> {
  bool _isBusy = false;

  /// Returns the currently selected team ID, or null.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  /// Refreshes all Fleet dashboard data.
  void _refresh() {
    final teamId = _teamId;
    if (teamId == null) return;
    ref.invalidate(fleetHealthSummaryProvider);
    ref.invalidate(fleetContainersProvider);
    ref.invalidate(fleetWorkstationProfilesProvider);
  }

  /// Starts the default workstation profile.
  Future<void> _startDefaultWorkstation() async {
    final teamId = _teamId;
    if (teamId == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      final profiles = await api.listWorkstationProfiles(teamId);
      final defaultProfile = profiles
          .where((p) => p.isDefault == true)
          .firstOrNull;

      if (defaultProfile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No default workstation profile found')),
          );
        }
        return;
      }

      await api.startWorkstation(teamId, defaultProfile.id!);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workstation started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start workstation: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Stops all running containers after confirmation.
  Future<void> _stopAll() async {
    final teamId = _teamId;
    if (teamId == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Stop All Containers',
      message: 'This will stop all running containers. Are you sure?',
      confirmLabel: 'Stop All',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      final containers = await api.listContainers(teamId);
      for (final c in containers) {
        if (c.status?.toJson() == 'RUNNING' && c.id != null) {
          await api.stopContainer(teamId, c.id!);
        }
      }
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All containers stopped')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop containers: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Syncs container state with Docker daemon.
  Future<void> _syncContainers() async {
    final teamId = _teamId;
    if (teamId == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.syncContainers(teamId);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Containers synced')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Prunes unused Docker images after confirmation.
  Future<void> _pruneImages() async {
    final teamId = _teamId;
    if (teamId == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Prune Images',
      message: 'This will remove all unused Docker images. Continue?',
      confirmLabel: 'Prune',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.pruneImages(teamId);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images pruned')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prune images: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);

    if (teamId == null) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No team selected',
        subtitle: 'Select a team to view Fleet dashboard.',
      );
    }

    final healthAsync = ref.watch(fleetHealthSummaryProvider(teamId));
    final containersAsync = ref.watch(fleetContainersProvider(teamId));

    return healthAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: _refresh,
      ),
      data: (summary) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  'Fleet Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: _isBusy ? null : _refresh,
                  color: CodeOpsColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status cards
            FleetStatusCards(summary: summary),
            const SizedBox(height: 16),

            // Resource gauges
            FleetResourceGauges(summary: summary),
            const SizedBox(height: 16),

            // Quick actions
            FleetQuickActions(
              isBusy: _isBusy,
              callbacks: (
                onStartWorkstation: _startDefaultWorkstation,
                onStopAll: _stopAll,
                onSync: _syncContainers,
                onPruneImages: _pruneImages,
              ),
            ),
            const SizedBox(height: 16),

            // Recent containers
            containersAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: CodeOpsColors.primary),
              ),
              error: (error, _) => ErrorPanel.fromException(
                error,
                onRetry: _refresh,
              ),
              data: (containers) {
                final recent = containers.take(5).toList();
                return FleetRecentContainers(
                  containers: recent,
                  onViewAll: () => context.go('/fleet/containers'),
                  onTap: (c) {
                    if (c.id != null) {
                      context.go('/fleet/containers/${c.id}');
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
