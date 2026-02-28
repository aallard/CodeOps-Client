/// Workstation profile list page for the Fleet module.
///
/// Displays all workstation profiles for the current team in a data table
/// at `/fleet/workstation-profiles`. Features tabbed views for "My
/// Workstations" and "Team Workstations", plus create, start/stop,
/// set default, edit, and delete actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/fleet_models.dart';
import '../../providers/auth_providers.dart' show currentUserProvider;
import '../../providers/fleet_providers.dart' hide selectedTeamIdProvider;
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/date_utils.dart';
import '../../widgets/fleet/workstation_profile_form.dart';
import '../../widgets/shared/confirm_dialog.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The workstation profile list page at `/fleet/workstation-profiles`.
class WorkstationProfileListPage extends ConsumerStatefulWidget {
  /// Creates a [WorkstationProfileListPage].
  const WorkstationProfileListPage({super.key});

  @override
  ConsumerState<WorkstationProfileListPage> createState() =>
      _WorkstationProfileListPageState();
}

class _WorkstationProfileListPageState
    extends ConsumerState<WorkstationProfileListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Returns the currently selected team ID, or null.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  /// Returns the current user's ID, or null.
  String? get _currentUserId => ref.read(currentUserProvider)?.id;

  /// Refreshes the workstation profile list.
  void _refresh() {
    final teamId = _teamId;
    if (teamId != null) {
      ref.invalidate(fleetWorkstationProfilesProvider);
    }
  }

  /// Opens the create workstation profile dialog.
  Future<void> _createProfile() async {
    final teamId = _teamId;
    if (teamId == null) return;

    final result = await WorkstationProfileFormDialog.show(context);
    if (result == null || result is! CreateWorkstationProfileRequest) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.createWorkstationProfile(teamId, result);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workstation profile created')),
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

  /// Starts all containers in a workstation.
  Future<void> _startWorkstation(FleetWorkstationProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.startWorkstation(teamId, profile.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workstation "${profile.name}" started'),
          ),
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

  /// Stops all containers in a workstation.
  Future<void> _stopWorkstation(FleetWorkstationProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Stop Workstation',
      message: 'Stop all containers in "${profile.name}"?',
      confirmLabel: 'Stop',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.stopWorkstation(teamId, profile.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workstation "${profile.name}" stopped'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop workstation: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Sets or unsets a workstation as the default.
  Future<void> _toggleDefault(FleetWorkstationProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.updateWorkstationProfile(
        teamId,
        profile.id!,
        UpdateWorkstationProfileRequest(
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

  /// Deletes a workstation profile after confirmation.
  Future<void> _deleteProfile(FleetWorkstationProfile profile) async {
    final teamId = _teamId;
    if (teamId == null || profile.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Workstation Profile',
      message:
          'Delete "${profile.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.deleteWorkstationProfile(teamId, profile.id!);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workstation profile deleted')),
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

  /// Navigates to the workstation profile detail page.
  void _viewDetail(FleetWorkstationProfile profile) {
    if (profile.id != null) {
      context.go('/fleet/workstation-profiles/${profile.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);

    if (teamId == null) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No team selected',
        subtitle: 'Select a team to view workstation profiles.',
      );
    }

    final profilesAsync =
        ref.watch(fleetWorkstationProfilesProvider(teamId));

    return profilesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: _refresh,
      ),
      data: (profiles) => _buildContent(profiles),
    );
  }

  /// Builds the full page content with header, tabs, and table.
  Widget _buildContent(List<FleetWorkstationProfile> profiles) {
    final currentUserId = _currentUserId;
    final myProfiles = currentUserId != null
        ? profiles.where((p) => p.userId == currentUserId).toList()
        : <FleetWorkstationProfile>[];
    final teamProfiles = profiles;

    return Column(
      children: [
        // Header + toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Text(
                'Workstation Profiles',
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
        ),
        const SizedBox(height: 12),

        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: CodeOpsColors.primary,
          unselectedLabelColor: CodeOpsColors.textSecondary,
          indicatorColor: CodeOpsColors.primary,
          tabs: [
            Tab(text: 'My Workstations (${myProfiles.length})'),
            Tab(text: 'Team Workstations (${teamProfiles.length})'),
          ],
        ),
        const Divider(height: 1, color: CodeOpsColors.border),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabBody(myProfiles),
              _buildTabBody(teamProfiles),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the scrollable table body for a tab.
  Widget _buildTabBody(List<FleetWorkstationProfile> profiles) {
    if (profiles.isEmpty) {
      return const EmptyState(
        icon: Icons.computer_outlined,
        title: 'No workstation profiles found',
        subtitle:
            'Create a workstation to define your one-click dev environment.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildTable(profiles),
    );
  }

  /// Builds the workstation profiles data table.
  Widget _buildTable(List<FleetWorkstationProfile> profiles) {
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
          2: FixedColumnWidth(90), // Solutions
          3: FixedColumnWidth(70), // Default
          4: FixedColumnWidth(130), // Created
          5: FixedColumnWidth(180), // Actions
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
              _HeaderCell('Solutions'),
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

  /// Builds a single workstation profile row.
  TableRow _buildRow(FleetWorkstationProfile profile) {
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
            '${profile.solutionCount ?? 0}',
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
                onPressed:
                    _isBusy ? null : () => _startWorkstation(profile),
                tooltip: 'Start Workstation',
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
                onPressed:
                    _isBusy ? null : () => _stopWorkstation(profile),
                tooltip: 'Stop Workstation',
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
                onPressed:
                    _isBusy ? null : () => _toggleDefault(profile),
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
                onPressed:
                    _isBusy ? null : () => _deleteProfile(profile),
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
