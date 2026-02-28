/// Workstation profile detail page for the Fleet module.
///
/// Displays a workstation profile at `/fleet/workstation-profiles/:profileId`
/// with a header showing name, description, default badge, owner, and
/// start/stop/edit/delete actions. The body shows an ordered list of
/// solutions with add and remove capabilities.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/fleet_models.dart';
import '../../providers/fleet_providers.dart' hide selectedTeamIdProvider;
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/fleet/add_solution_dialog.dart';
import '../../widgets/fleet/workstation_profile_form.dart';
import '../../widgets/fleet/workstation_solution_list.dart';
import '../../widgets/shared/confirm_dialog.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The workstation profile detail page at
/// `/fleet/workstation-profiles/:profileId`.
class WorkstationProfileDetailPage extends ConsumerStatefulWidget {
  /// The ID of the workstation profile to display.
  final String profileId;

  /// Creates a [WorkstationProfileDetailPage].
  const WorkstationProfileDetailPage({super.key, required this.profileId});

  @override
  ConsumerState<WorkstationProfileDetailPage> createState() =>
      _WorkstationProfileDetailPageState();
}

class _WorkstationProfileDetailPageState
    extends ConsumerState<WorkstationProfileDetailPage> {
  bool _isBusy = false;

  /// Returns the currently selected team ID, or null.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  /// Refreshes the profile detail.
  void _refresh() {
    final teamId = _teamId;
    if (teamId != null) {
      ref.invalidate(fleetWorkstationProfileDetailProvider);
    }
  }

  /// Starts all containers in this workstation.
  Future<void> _startWorkstation(
      FleetWorkstationProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.startWorkstation(teamId, detail.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workstation "${detail.name}" started'),
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

  /// Stops all containers in this workstation after confirmation.
  Future<void> _stopWorkstation(
      FleetWorkstationProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Stop Workstation',
      message: 'Stop all containers in "${detail.name}"?',
      confirmLabel: 'Stop',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.stopWorkstation(teamId, detail.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workstation "${detail.name}" stopped'),
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

  /// Opens the edit dialog for the current workstation profile.
  Future<void> _editProfile(FleetWorkstationProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    final result =
        await WorkstationProfileFormDialog.show(context, existing: detail);
    if (result == null || result is! UpdateWorkstationProfileRequest) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.updateWorkstationProfile(teamId, detail.id!, result);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workstation profile updated')),
        );
      }
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

  /// Deletes the current workstation profile after confirmation.
  Future<void> _deleteProfile(FleetWorkstationProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Workstation Profile',
      message: 'Delete "${detail.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.deleteWorkstationProfile(teamId, detail.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workstation profile deleted')),
        );
        context.go('/fleet/workstation-profiles');
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

  /// Opens the add solution dialog and adds the selected solution.
  Future<void> _addSolution(FleetWorkstationProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    // Fetch available solution profiles for the picker.
    final solutionProfiles =
        await ref.read(fleetSolutionProfilesProvider(teamId).future);

    final existingIds = (detail.solutions ?? [])
        .where((s) => s.solutionProfileId != null)
        .map((s) => s.solutionProfileId!)
        .toSet();

    if (!mounted) return;

    final result = await AddSolutionDialog.show(
      context,
      availableProfiles: solutionProfiles,
      existingSolutionIds: existingIds,
    );
    if (result == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.addSolutionToWorkstation(teamId, detail.id!, result);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solution added to workstation')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add solution: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Removes a solution from the workstation after confirmation.
  Future<void> _removeSolution(
    FleetWorkstationProfileDetail detail,
    FleetWorkstationSolution solution,
  ) async {
    final teamId = _teamId;
    if (teamId == null ||
        detail.id == null ||
        solution.solutionProfileId == null) {
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Solution',
      message:
          'Remove "${solution.solutionProfileName}" from this workstation?',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.removeSolutionFromWorkstation(
        teamId,
        detail.id!,
        solution.solutionProfileId!,
      );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Solution removed from workstation')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove solution: $e')),
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
        subtitle: 'Select a team to view workstation profiles.',
      );
    }

    final detailAsync = ref.watch(
      fleetWorkstationProfileDetailProvider(
        (teamId: teamId, profileId: widget.profileId),
      ),
    );

    return detailAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: _refresh,
      ),
      data: (detail) => _buildContent(detail),
    );
  }

  /// Builds the full page content with header and solution list.
  Widget _buildContent(FleetWorkstationProfileDetail detail) {
    return Column(
      children: [
        _buildHeader(detail),
        const Divider(height: 1, color: CodeOpsColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: WorkstationSolutionList(
              solutions: detail.solutions ?? [],
              onAdd: () => _addSolution(detail),
              onRemove: (sol) => _removeSolution(detail, sol),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the page header with profile name and action buttons.
  Widget _buildHeader(FleetWorkstationProfileDetail detail) {
    final isDefault = detail.isDefault == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            color: CodeOpsColors.textSecondary,
            onPressed: () => context.go('/fleet/workstation-profiles'),
            tooltip: 'Back to list',
          ),
          const SizedBox(width: 12),

          // Profile name and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name ?? 'Unnamed',
                  style: CodeOpsTypography.titleMedium,
                ),
                if (detail.description != null &&
                    detail.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail.description!,
                    style: CodeOpsTypography.bodySmall
                        .copyWith(color: CodeOpsColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Owner badge
          if (detail.userId != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    CodeOpsColors.textTertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Owner: ${detail.userId!.length > 8 ? '${detail.userId!.substring(0, 8)}\u2026' : detail.userId!}',
                style: const TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Default badge
          if (isDefault) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CodeOpsColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  color: CodeOpsColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Start button
          OutlinedButton.icon(
            onPressed:
                _isBusy ? null : () => _startWorkstation(detail),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.success,
              side: const BorderSide(color: CodeOpsColors.success),
            ),
          ),
          const SizedBox(width: 8),

          // Stop button
          OutlinedButton.icon(
            onPressed:
                _isBusy ? null : () => _stopWorkstation(detail),
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Stop'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.warning,
              side: const BorderSide(color: CodeOpsColors.warning),
            ),
          ),
          const SizedBox(width: 8),

          // Edit button
          OutlinedButton.icon(
            onPressed: _isBusy ? null : () => _editProfile(detail),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.primary,
              side: const BorderSide(color: CodeOpsColors.primary),
            ),
          ),
          const SizedBox(width: 8),

          // Delete button
          OutlinedButton.icon(
            onPressed: _isBusy ? null : () => _deleteProfile(detail),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.error,
              side: const BorderSide(color: CodeOpsColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
