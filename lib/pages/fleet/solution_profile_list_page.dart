/// Solution profile list page for the Fleet module.
///
/// Displays all solution profiles for the current team in a data table
/// at `/fleet/solution-profiles`. Features include create, start/stop
/// solution, set default, edit, and delete actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/fleet_models.dart';
import '../../providers/fleet_providers.dart' hide selectedTeamIdProvider;
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/date_utils.dart';
import '../../widgets/fleet/solution_profile_form.dart';
import '../../widgets/shared/confirm_dialog.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The solution profile list page at `/fleet/solution-profiles`.
class SolutionProfileListPage extends ConsumerStatefulWidget {
  /// Creates a [SolutionProfileListPage].
  const SolutionProfileListPage({super.key});

  @override
  ConsumerState<SolutionProfileListPage> createState() =>
      _SolutionProfileListPageState();
}

class _SolutionProfileListPageState
    extends ConsumerState<SolutionProfileListPage> {
  bool _isBusy = false;

  /// Returns the currently selected team ID, or null.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  /// Refreshes the solution profile list.
  void _refresh() {
    final teamId = _teamId;
    if (teamId != null) {
      ref.invalidate(fleetSolutionProfilesProvider);
    }
  }

  /// Opens the create solution profile dialog.
  Future<void> _createProfile() async {
    final teamId = _teamId;
    if (teamId == null) return;

    final result = await SolutionProfileFormDialog.show(context);
    if (result == null || result is! CreateSolutionProfileRequest) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.createSolutionProfile(teamId, result);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solution profile created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Starts all containers in a solution.
  Future<void> _startSolution(FleetSolutionProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.startSolution(teamId, profile.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Solution "${profile.name}" started'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start solution: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Stops all containers in a solution.
  Future<void> _stopSolution(FleetSolutionProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Stop Solution',
      message: 'Stop all containers in "${profile.name}"?',
      confirmLabel: 'Stop',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.stopSolution(teamId, profile.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Solution "${profile.name}" stopped'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop solution: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Sets or unsets a solution as the default.
  Future<void> _toggleDefault(FleetSolutionProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.updateSolutionProfile(
        teamId,
        profile.id!,
        UpdateSolutionProfileRequest(
          isDefault: !(profile.isDefault ?? false),
        ),
      );
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Deletes a solution profile after confirmation.
  Future<void> _deleteProfile(FleetSolutionProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Solution Profile',
      message:
          'Delete "${profile.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.deleteSolutionProfile(teamId, profile.id!);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solution profile deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Navigates to the solution profile detail page.
  void _viewDetail(FleetSolutionProfile profile) {
    if (profile.id != null) {
      context.go('/fleet/solution-profiles/${profile.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);

    if (teamId == null) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No team selected',
        subtitle: 'Select a team to view solution profiles.',
      );
    }

    final profilesAsync = ref.watch(fleetSolutionProfilesProvider(teamId));

    return profilesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: _refresh,
      ),
      data: (profiles) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Solution Profiles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${profiles.length})',
                    style: const TextStyle(
                      color: CodeOpsColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Toolbar
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isBusy ? null : _createProfile,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    color: CodeOpsColors.textSecondary,
                    onPressed: _isBusy ? null : _refresh,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Table or empty state
              if (profiles.isEmpty)
                const EmptyState(
                  icon: Icons.layers_outlined,
                  title: 'No solution profiles found',
                  subtitle:
                      'Create a solution to group service profiles for orchestrated start/stop.',
                )
              else
                _buildTable(profiles),
            ],
          ),
        );
      },
    );
  }

  /// Builds the solution profiles data table.
  Widget _buildTable(List<FleetSolutionProfile> profiles) {
    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Name
          1: FlexColumnWidth(2.5), // Description
          2: FixedColumnWidth(80), // Services
          3: FixedColumnWidth(70), // Default
          4: FixedColumnWidth(130), // Created
          5: FixedColumnWidth(160), // Actions
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: CodeOpsColors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            children: const [
              _HeaderCell('Name'),
              _HeaderCell('Description'),
              _HeaderCell('Services'),
              _HeaderCell('Default'),
              _HeaderCell('Created'),
              _HeaderCell('Actions'),
            ],
          ),
          ...profiles.map(_buildRow),
        ],
      ),
    );
  }

  /// Builds a single solution profile row.
  TableRow _buildRow(FleetSolutionProfile profile) {
    final isDefault = profile.isDefault == true;

    return TableRow(
      decoration: BoxDecoration(
        color: isDefault
            ? CodeOpsColors.primary.withValues(alpha: 0.05)
            : null,
        border: Border(
          bottom:
              BorderSide(color: CodeOpsColors.border.withValues(alpha: 0.5)),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: InkWell(
            onTap: () => _viewDetail(profile),
            child: Text(
              profile.name ?? '\u2014',
              style: CodeOpsTypography.bodyMedium
                  .copyWith(color: CodeOpsColors.primary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            profile.description ?? '\u2014',
            style: CodeOpsTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            '${profile.serviceCount ?? 0}',
            style: CodeOpsTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: isDefault
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CodeOpsColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: CodeOpsColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            formatDateTime(profile.createdAt),
            style: CodeOpsTypography.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, size: 16),
                color: CodeOpsColors.success,
                onPressed: _isBusy ? null : () => _startSolution(profile),
                tooltip: 'Start Solution',
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.stop, size: 16),
                color: CodeOpsColors.warning,
                onPressed: _isBusy ? null : () => _stopSolution(profile),
                tooltip: 'Stop Solution',
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              IconButton(
                icon: Icon(
                  profile.isDefault == true
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                ),
                color: CodeOpsColors.secondary,
                onPressed: _isBusy ? null : () => _toggleDefault(profile),
                tooltip: profile.isDefault == true
                    ? 'Unset Default'
                    : 'Set as Default',
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                color: CodeOpsColors.error,
                onPressed: _isBusy ? null : () => _deleteProfile(profile),
                tooltip: 'Delete',
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(label, style: CodeOpsTypography.labelMedium),
    );
  }
}
