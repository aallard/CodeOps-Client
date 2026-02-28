/// Solution profile detail page for the Fleet module.
///
/// Displays a solution profile at `/fleet/solution-profiles/:profileId`
/// with a header showing name, description, default badge, and
/// start/stop/edit/delete actions. The body shows an ordered list of
/// services with add and remove capabilities.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/fleet_models.dart';
import '../../providers/fleet_providers.dart' hide selectedTeamIdProvider;
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/fleet/add_service_dialog.dart';
import '../../widgets/fleet/solution_profile_form.dart';
import '../../widgets/fleet/solution_service_list.dart';
import '../../widgets/shared/confirm_dialog.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The solution profile detail page at `/fleet/solution-profiles/:profileId`.
class SolutionProfileDetailPage extends ConsumerStatefulWidget {
  /// The ID of the solution profile to display.
  final String profileId;

  /// Creates a [SolutionProfileDetailPage].
  const SolutionProfileDetailPage({super.key, required this.profileId});

  @override
  ConsumerState<SolutionProfileDetailPage> createState() =>
      _SolutionProfileDetailPageState();
}

class _SolutionProfileDetailPageState
    extends ConsumerState<SolutionProfileDetailPage> {
  bool _isBusy = false;

  /// Returns the currently selected team ID, or null.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  /// Refreshes the profile detail.
  void _refresh() {
    final teamId = _teamId;
    if (teamId != null) {
      ref.invalidate(fleetSolutionProfileDetailProvider);
    }
  }

  /// Starts all containers in this solution.
  Future<void> _startSolution(FleetSolutionProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.startSolution(teamId, detail.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solution "${detail.name}" started'),
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

  /// Stops all containers in this solution after confirmation.
  Future<void> _stopSolution(FleetSolutionProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Stop Solution',
      message: 'Stop all containers in "${detail.name}"?',
      confirmLabel: 'Stop',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.stopSolution(teamId, detail.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solution "${detail.name}" stopped'),
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

  /// Opens the edit dialog for the current solution profile.
  Future<void> _editProfile(FleetSolutionProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    final result =
        await SolutionProfileFormDialog.show(context, existing: detail);
    if (result == null || result is! UpdateSolutionProfileRequest) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.updateSolutionProfile(teamId, detail.id!, result);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solution profile updated')),
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

  /// Deletes the current solution profile after confirmation.
  Future<void> _deleteProfile(FleetSolutionProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Solution Profile',
      message: 'Delete "${detail.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.deleteSolutionProfile(teamId, detail.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solution profile deleted')),
        );
        context.go('/fleet/solution-profiles');
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

  /// Opens the add service dialog and adds the selected service.
  Future<void> _addService(FleetSolutionProfileDetail detail) async {
    final teamId = _teamId;
    if (teamId == null || detail.id == null) return;

    // Fetch available service profiles for the picker.
    final serviceProfiles =
        await ref.read(fleetServiceProfilesProvider(teamId).future);

    final existingIds = (detail.services ?? [])
        .where((s) => s.serviceProfileId != null)
        .map((s) => s.serviceProfileId!)
        .toSet();

    if (!mounted) return;

    final result = await AddServiceDialog.show(
      context,
      availableProfiles: serviceProfiles,
      existingServiceIds: existingIds,
    );
    if (result == null) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.addServiceToSolution(teamId, detail.id!, result);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added to solution')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add service: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Removes a service from the solution after confirmation.
  Future<void> _removeService(
    FleetSolutionProfileDetail detail,
    FleetSolutionService service,
  ) async {
    final teamId = _teamId;
    if (teamId == null ||
        detail.id == null ||
        service.serviceProfileId == null) {
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Service',
      message:
          'Remove "${service.serviceProfileName}" from this solution?',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final api = ref.read(fleetApiProvider);
      await api.removeServiceFromSolution(
        teamId,
        detail.id!,
        service.serviceProfileId!,
      );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service removed from solution')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove service: $e')),
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
        subtitle: 'Select a team to view solution profiles.',
      );
    }

    final detailAsync = ref.watch(
      fleetSolutionProfileDetailProvider(
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

  /// Builds the full page content with header and service list.
  Widget _buildContent(FleetSolutionProfileDetail detail) {
    return Column(
      children: [
        _buildHeader(detail),
        const Divider(height: 1, color: CodeOpsColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SolutionServiceList(
              services: detail.services ?? [],
              onAdd: () => _addService(detail),
              onRemove: (svc) => _removeService(detail, svc),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the page header with profile name and action buttons.
  Widget _buildHeader(FleetSolutionProfileDetail detail) {
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
            onPressed: () => context.go('/fleet/solution-profiles'),
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

          // Default badge
          if (isDefault) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            onPressed: _isBusy ? null : () => _startSolution(detail),
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
            onPressed: _isBusy ? null : () => _stopSolution(detail),
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
