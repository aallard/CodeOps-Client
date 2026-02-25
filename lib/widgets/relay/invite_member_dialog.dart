/// Dialog for inviting a team member to a Relay channel.
///
/// Provides a search field to find team members by name, excludes
/// already-in-channel members, allows role selection, and calls the
/// invite API on submit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../models/team.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Dialog for inviting a team member to a Relay channel.
class InviteMemberDialog extends ConsumerStatefulWidget {
  /// The channel ID to invite members to.
  final String channelId;

  /// The team ID the channel belongs to.
  final String teamId;

  /// Creates an [InviteMemberDialog].
  const InviteMemberDialog({
    required this.channelId,
    required this.teamId,
    super.key,
  });

  @override
  ConsumerState<InviteMemberDialog> createState() =>
      _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  MemberRole _selectedRole = MemberRole.member;
  bool _submitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Invites a team member to the channel.
  Future<void> _inviteMember(TeamMember teamMember) async {
    setState(() => _submitting = true);
    try {
      final api = ref.read(relayApiProvider);
      await api.inviteMember(
        widget.channelId,
        InviteMemberRequest(
          userId: teamMember.userId,
          role: _selectedRole,
        ),
        widget.teamId,
      );
      ref.invalidate(channelMembersProvider(
          (channelId: widget.channelId, teamId: widget.teamId)));
      if (mounted) {
        showToast(
          context,
          message: 'Invited ${teamMember.displayName ?? 'member'}',
          type: ToastType.success,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          message: 'Failed to invite: $e',
          type: ToastType.error,
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamMembersAsync = ref.watch(teamMembersProvider);
    final channelMembersAsync = ref.watch(channelMembersProvider(
        (channelId: widget.channelId, teamId: widget.teamId)));

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.person_add_outlined,
                      size: 20, color: CodeOpsColors.primary),
                  const SizedBox(width: 10),
                  const Text(
                    'Invite Member',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: CodeOpsColors.textTertiary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: CodeOpsColors.border),

            // Search bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.trim().toLowerCase()),
                style: const TextStyle(
                    fontSize: 13, color: CodeOpsColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search team members...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: CodeOpsColors.textTertiary),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: CodeOpsColors.textTertiary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.primary),
                  ),
                  filled: true,
                  fillColor: CodeOpsColors.background,
                ),
              ),
            ),

            // Role selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Role: ',
                    style: TextStyle(
                        fontSize: 12, color: CodeOpsColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<MemberRole>(
                    segments: const [
                      ButtonSegment(
                        value: MemberRole.member,
                        label: Text('Member', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: MemberRole.admin,
                        label: Text('Admin', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedRole = selection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Member list
            Flexible(
              child: _buildMemberList(
                  teamMembersAsync, channelMembersAsync),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the filtered team member list, excluding existing channel members.
  Widget _buildMemberList(
    AsyncValue<List<TeamMember>> teamMembersAsync,
    AsyncValue<List<ChannelMemberResponse>> channelMembersAsync,
  ) {
    return teamMembersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to load members: $e',
            style:
                const TextStyle(fontSize: 13, color: CodeOpsColors.error)),
      ),
      data: (teamMembers) {
        // Get existing channel member user IDs
        final existingIds = <String>{};
        if (channelMembersAsync.hasValue) {
          for (final m in channelMembersAsync.value!) {
            if (m.userId != null) existingIds.add(m.userId!);
          }
        }

        // Filter out existing members and apply search
        var available = teamMembers
            .where((m) => !existingIds.contains(m.userId))
            .toList();

        if (_searchQuery.isNotEmpty) {
          available = available
              .where((m) =>
                  (m.displayName ?? '')
                      .toLowerCase()
                      .contains(_searchQuery) ||
                  (m.email ?? '').toLowerCase().contains(_searchQuery))
              .toList();
        }

        if (available.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No matching members to invite',
                style: TextStyle(
                    fontSize: 13, color: CodeOpsColors.textTertiary),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          itemCount: available.length,
          itemBuilder: (context, index) {
            final member = available[index];
            return _InviteRow(
              member: member,
              submitting: _submitting,
              onInvite: () => _inviteMember(member),
            );
          },
        );
      },
    );
  }
}

/// A single row for a team member who can be invited.
class _InviteRow extends StatelessWidget {
  final TeamMember member;
  final bool submitting;
  final VoidCallback onInvite;

  const _InviteRow({
    required this.member,
    required this.submitting,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CodeOpsColors.primaryVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                (member.displayName ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName ?? 'Unknown',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                Text(
                  member.email ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Invite button
          SizedBox(
            width: 72,
            height: 28,
            child: FilledButton(
              onPressed: submitting ? null : onInvite,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Invite'),
            ),
          ),
        ],
      ),
    );
  }
}
