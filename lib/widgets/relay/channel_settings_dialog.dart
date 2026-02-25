/// Dialog for viewing and editing Relay channel settings.
///
/// Shows channel info, member list, and management actions.
/// Edit capability depends on user's role (OWNER/ADMIN).
/// Contains two tabs: Overview and Members.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import '../shared/notification_toast.dart';
import 'invite_member_dialog.dart';

/// Dialog for viewing and editing Relay channel settings.
///
/// Shows channel info, member list, and management actions.
/// Edit capability depends on user's role (OWNER/ADMIN).
class ChannelSettingsDialog extends ConsumerStatefulWidget {
  /// The channel ID to display settings for.
  final String channelId;

  /// The team ID the channel belongs to.
  final String teamId;

  /// Creates a [ChannelSettingsDialog].
  const ChannelSettingsDialog({
    required this.channelId,
    required this.teamId,
    super.key,
  });

  @override
  ConsumerState<ChannelSettingsDialog> createState() =>
      _ChannelSettingsDialogState();
}

class _ChannelSettingsDialogState extends ConsumerState<ChannelSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _topicController = TextEditingController();

  bool _nameEdited = false;
  bool _descriptionEdited = false;
  bool _topicEdited = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  /// Initializes text controllers from channel data.
  void _initFromChannel(ChannelResponse channel) {
    if (!_nameEdited) _nameController.text = channel.name ?? '';
    if (!_descriptionEdited) {
      _descriptionController.text = channel.description ?? '';
    }
    if (!_topicEdited) _topicController.text = channel.topic ?? '';
  }

  /// Whether the user has edit permissions.
  bool _canEdit(MemberRole? role) {
    return role == MemberRole.owner || role == MemberRole.admin;
  }

  /// Whether the user is the channel owner.
  bool _isOwner(MemberRole? role) {
    return role == MemberRole.owner;
  }

  /// Saves channel name and description updates.
  Future<void> _saveNameAndDescription() async {
    setState(() => _saving = true);
    try {
      final api = ref.read(relayApiProvider);
      await api.updateChannel(
        widget.channelId,
        UpdateChannelRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
        widget.teamId,
      );
      ref.invalidate(channelDetailProvider(
          (channelId: widget.channelId, teamId: widget.teamId)));
      ref.invalidate(teamChannelsProvider(widget.teamId));
      if (mounted) {
        showToast(context,
            message: 'Channel updated', type: ToastType.success);
        setState(() {
          _nameEdited = false;
          _descriptionEdited = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to update: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Saves topic changes.
  Future<void> _saveTopic() async {
    setState(() => _saving = true);
    try {
      final api = ref.read(relayApiProvider);
      await api.updateTopic(
        widget.channelId,
        UpdateChannelTopicRequest(
          topic: _topicController.text.trim().isEmpty
              ? null
              : _topicController.text.trim(),
        ),
        widget.teamId,
      );
      ref.invalidate(channelDetailProvider(
          (channelId: widget.channelId, teamId: widget.teamId)));
      if (mounted) {
        showToast(context,
            message: 'Topic updated', type: ToastType.success);
        setState(() => _topicEdited = false);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to update topic: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Archives the channel.
  Future<void> _archiveChannel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CodeOpsColors.surface,
        title: const Text('Archive Channel'),
        content: const Text(
            'Are you sure you want to archive this channel? '
            'Members will no longer be able to send messages.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Archive')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final api = ref.read(relayApiProvider);
      await api.archiveChannel(widget.channelId, widget.teamId);
      ref.invalidate(teamChannelsProvider(widget.teamId));
      if (mounted) {
        showToast(context,
            message: 'Channel archived', type: ToastType.success);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to archive: $e', type: ToastType.error);
      }
    }
  }

  /// Deletes the channel.
  Future<void> _deleteChannel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CodeOpsColors.surface,
        title: const Text('Delete Channel'),
        content: const Text(
            'This action cannot be undone. All messages and files '
            'in this channel will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: CodeOpsColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final api = ref.read(relayApiProvider);
      await api.deleteChannel(widget.channelId, widget.teamId);
      ref.invalidate(teamChannelsProvider(widget.teamId));
      if (mounted) {
        showToast(context,
            message: 'Channel deleted', type: ToastType.success);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to delete: $e', type: ToastType.error);
      }
    }
  }

  /// Removes a member from the channel.
  Future<void> _removeMember(ChannelMemberResponse member) async {
    if (member.userId == null) return;
    try {
      final api = ref.read(relayApiProvider);
      await api.removeMember(
          widget.channelId, member.userId!, widget.teamId);
      ref.invalidate(channelMembersProvider(
          (channelId: widget.channelId, teamId: widget.teamId)));
      if (mounted) {
        showToast(context,
            message:
                'Removed ${member.userDisplayName ?? 'member'}',
            type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to remove member: $e',
            type: ToastType.error);
      }
    }
  }

  /// Updates a member's role.
  Future<void> _updateMemberRole(
      ChannelMemberResponse member, MemberRole newRole) async {
    if (member.userId == null) return;
    try {
      final api = ref.read(relayApiProvider);
      await api.updateMemberRole(
        widget.channelId,
        member.userId!,
        UpdateMemberRoleRequest(role: newRole),
        widget.teamId,
      );
      ref.invalidate(channelMembersProvider(
          (channelId: widget.channelId, teamId: widget.teamId)));
      if (mounted) {
        showToast(context,
            message:
                '${member.userDisplayName ?? 'Member'} updated to ${newRole.displayName}',
            type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to update role: $e',
            type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelAsync = ref.watch(channelDetailProvider(
        (channelId: widget.channelId, teamId: widget.teamId)));
    final roleAsync = ref.watch(currentUserChannelRoleProvider(
        (channelId: widget.channelId, teamId: widget.teamId)));

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
        child: channelAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load channel: $e',
                style:
                    const TextStyle(fontSize: 13, color: CodeOpsColors.error)),
          ),
          data: (channel) {
            _initFromChannel(channel);
            final role = roleAsync.valueOrNull;
            final canEdit = _canEdit(role);
            final isOwner = _isOwner(role);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      Icon(
                        channel.channelType == ChannelType.private
                            ? Icons.lock_outline
                            : Icons.tag,
                        size: 20,
                        color: CodeOpsColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          channel.name ?? 'Channel Settings',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CodeOpsColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: CodeOpsColors.textTertiary),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // Tab bar
                TabBar(
                  controller: _tabController,
                  labelColor: CodeOpsColors.primary,
                  unselectedLabelColor: CodeOpsColors.textTertiary,
                  indicatorColor: CodeOpsColors.primary,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Members'),
                  ],
                ),

                // Tab content
                Flexible(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(channel, canEdit, isOwner),
                      _buildMembersTab(canEdit, isOwner),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the Overview tab with channel info fields.
  Widget _buildOverviewTab(
      ChannelResponse channel, bool canEdit, bool isOwner) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          TextField(
            controller: _nameController,
            enabled: canEdit,
            onChanged: (_) => setState(() => _nameEdited = true),
            decoration: const InputDecoration(
              labelText: 'Name',
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            enabled: canEdit,
            onChanged: (_) => setState(() => _descriptionEdited = true),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              isDense: true,
            ),
          ),

          if (_nameEdited || _descriptionEdited)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _saving ? null : _saveNameAndDescription,
                  child: _saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Topic — editable by any member
          TextField(
            controller: _topicController,
            onChanged: (_) => setState(() => _topicEdited = true),
            decoration: const InputDecoration(
              labelText: 'Topic',
              hintText: 'Set a topic for discussion',
              isDense: true,
            ),
          ),

          if (_topicEdited)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _saving ? null : _saveTopic,
                  child: const Text('Save Topic'),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Channel info
          _buildInfoRow('Type', channel.channelType?.displayName ?? '—'),
          _buildInfoRow('Created', formatDateTime(channel.createdAt)),
          _buildInfoRow('Members', '${channel.memberCount ?? 0}'),

          const SizedBox(height: 24),

          // Management actions
          if (canEdit)
            OutlinedButton.icon(
              onPressed: _archiveChannel,
              icon: const Icon(Icons.archive_outlined,
                  size: 16, color: CodeOpsColors.warning),
              label: const Text('Archive Channel',
                  style: TextStyle(color: CodeOpsColors.warning)),
            ),
          if (isOwner) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _deleteChannel,
              icon: const Icon(Icons.delete_outline,
                  size: 16, color: CodeOpsColors.error),
              label: const Text('Delete Channel',
                  style: TextStyle(color: CodeOpsColors.error)),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a read-only info row.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: CodeOpsColors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, color: CodeOpsColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Members tab with list and invite button.
  Widget _buildMembersTab(bool canEdit, bool isOwner) {
    final membersAsync = ref.watch(channelMembersProvider(
        (channelId: widget.channelId, teamId: widget.teamId)));

    return Column(
      children: [
        // Invite button
        if (canEdit)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => InviteMemberDialog(
                      channelId: widget.channelId,
                      teamId: widget.teamId,
                    ),
                  ).then((_) {
                    ref.invalidate(channelMembersProvider(
                        (channelId: widget.channelId, teamId: widget.teamId)));
                  });
                },
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Invite Member'),
              ),
            ),
          ),

        // Member list
        Expanded(
          child: membersAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load members: $e',
                  style: const TextStyle(
                      fontSize: 13, color: CodeOpsColors.error)),
            ),
            data: (members) {
              if (members.isEmpty) {
                return const Center(
                  child: Text('No members',
                      style: TextStyle(
                          fontSize: 13,
                          color: CodeOpsColors.textTertiary)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return _MemberRow(
                    member: member,
                    canManage: canEdit,
                    isOwner: isOwner,
                    onRemove: () => _removeMember(member),
                    onChangeRole: (role) =>
                        _updateMemberRole(member, role),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A single member row in the members tab.
class _MemberRow extends StatelessWidget {
  final ChannelMemberResponse member;
  final bool canManage;
  final bool isOwner;
  final VoidCallback onRemove;
  final ValueChanged<MemberRole> onChangeRole;

  const _MemberRow({
    required this.member,
    required this.canManage,
    required this.isOwner,
    required this.onRemove,
    required this.onChangeRole,
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
                (member.userDisplayName ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: Text(
              member.userDisplayName ?? 'Unknown',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),

          // Role badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _roleColor(member.role).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              member.role?.displayName ?? 'Member',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _roleColor(member.role),
              ),
            ),
          ),

          // Actions
          if (canManage && member.role != MemberRole.owner) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 16, color: CodeOpsColors.textTertiary),
              color: CodeOpsColors.surface,
              itemBuilder: (_) => [
                if (isOwner) ...[
                  const PopupMenuItem(
                      value: 'make_admin',
                      child: Text('Make Admin',
                          style: TextStyle(fontSize: 13))),
                  const PopupMenuItem(
                      value: 'make_member',
                      child: Text('Make Member',
                          style: TextStyle(fontSize: 13))),
                ],
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove',
                      style: TextStyle(
                          fontSize: 13, color: CodeOpsColors.error)),
                ),
              ],
              onSelected: (action) {
                switch (action) {
                  case 'make_admin':
                    onChangeRole(MemberRole.admin);
                  case 'make_member':
                    onChangeRole(MemberRole.member);
                  case 'remove':
                    onRemove();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Returns the color for a member role badge.
  Color _roleColor(MemberRole? role) {
    return switch (role) {
      MemberRole.owner => CodeOpsColors.warning,
      MemberRole.admin => CodeOpsColors.secondary,
      _ => CodeOpsColors.textTertiary,
    };
  }
}
