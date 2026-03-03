/// Dialog for sharing a collection with team members.
///
/// Allows searching team members, setting permission levels (Viewer/Editor),
/// viewing current shares, and removing shares. Uses the sharing API
/// endpoints under `/courier/collections/{id}/shares`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_enums.dart';
import '../../models/courier_models.dart';
import '../../models/team.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Dialog for managing collection shares.
///
/// Shows current shares and provides a form to add new shares with permission
/// level selection. Opened from the collection context menu.
class ShareCollectionDialog extends ConsumerStatefulWidget {
  /// The collection ID to share.
  final String collectionId;

  /// The collection name (for display).
  final String collectionName;

  /// Creates a [ShareCollectionDialog].
  const ShareCollectionDialog({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  ConsumerState<ShareCollectionDialog> createState() =>
      _ShareCollectionDialogState();
}

class _ShareCollectionDialogState
    extends ConsumerState<ShareCollectionDialog> {
  String _searchQuery = '';
  SharePermission _selectedPermission = SharePermission.viewer;
  String? _selectedUserId;
  bool _sharing = false;
  String? _error;

  Future<void> _shareWithUser() async {
    if (_selectedUserId == null) return;
    setState(() {
      _sharing = true;
      _error = null;
    });

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) throw Exception('No team selected');
      final api = ref.read(courierApiProvider);
      await api.shareCollection(
        teamId,
        widget.collectionId,
        ShareCollectionRequest(
          sharedWithUserId: _selectedUserId!,
          permission: _selectedPermission,
        ),
      );
      ref.invalidate(courierCollectionSharesProvider(widget.collectionId));
      setState(() {
        _sharing = false;
        _selectedUserId = null;
        _searchQuery = '';
      });
    } catch (e) {
      setState(() {
        _sharing = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _removeShare(String userId) async {
    final teamId = ref.read(selectedTeamIdProvider);
    if (teamId == null) return;
    final api = ref.read(courierApiProvider);
    await api.removeShare(teamId, widget.collectionId, userId);
    ref.invalidate(courierCollectionSharesProvider(widget.collectionId));
  }

  void _copyLink() {
    Clipboard.setData(
      ClipboardData(text: 'codeops://collection/${widget.collectionId}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: CodeOpsColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharesAsync =
        ref.watch(courierCollectionSharesProvider(widget.collectionId));
    final membersAsync = ref.watch(teamMembersProvider);

    return Dialog(
      key: const Key('share_collection_dialog'),
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.share, color: CodeOpsColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Share "${widget.collectionName}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CodeOpsColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: CodeOpsColors.textTertiary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── User search + permission ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: membersAsync.when(
                      data: (members) => _UserSearchField(
                        key: const Key('share_user_search'),
                        members: members,
                        query: _searchQuery,
                        selectedUserId: _selectedUserId,
                        onQueryChanged: (q) => setState(() => _searchQuery = q),
                        onUserSelected: (id) =>
                            setState(() => _selectedUserId = id),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text(
                        'Failed to load members',
                        style: TextStyle(color: CodeOpsColors.error, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<SharePermission>(
                    key: const Key('share_permission_selector'),
                    value: _selectedPermission,
                    dropdownColor: CodeOpsColors.surfaceVariant,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.textPrimary,
                    ),
                    underline: const SizedBox.shrink(),
                    items: [SharePermission.viewer, SharePermission.editor]
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedPermission = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('share_button'),
                    onPressed:
                        _selectedUserId == null || _sharing ? null : _shareWithUser,
                    style: FilledButton.styleFrom(
                      backgroundColor: CodeOpsColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: _sharing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Share', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style:
                        const TextStyle(fontSize: 12, color: CodeOpsColors.error)),
              ],
              const SizedBox(height: 20),

              // ── Current shares ────────────────────────────────────
              const Text(
                'Shared with',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              sharesAsync.when(
                data: (shares) => shares.isEmpty
                    ? const Padding(
                        key: Key('shares_empty'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Not shared with anyone yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      )
                    : Column(
                        key: const Key('current_shares_list'),
                        children: shares
                            .map((s) => _ShareRow(
                                  share: s,
                                  onRemove: () =>
                                      _removeShare(s.sharedWithUserId ?? ''),
                                ))
                            .toList(),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const Text(
                  'Failed to load shares',
                  style: TextStyle(color: CodeOpsColors.error, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // ── Copy link ─────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: const Key('copy_link_button'),
                  onPressed: _copyLink,
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Copy Link', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _UserSearchField extends StatelessWidget {
  final List<TeamMember> members;
  final String query;
  final String? selectedUserId;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onUserSelected;

  const _UserSearchField({
    super.key,
    required this.members,
    required this.query,
    required this.selectedUserId,
    required this.onQueryChanged,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? <TeamMember>[]
        : members
            .where((m) =>
                (m.displayName ?? '').toLowerCase().contains(query.toLowerCase()) ||
                (m.email ?? '').toLowerCase().contains(query.toLowerCase()))
            .take(5)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          style: const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search team members...',
            hintStyle: const TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
            filled: true,
            fillColor: CodeOpsColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: CodeOpsColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: CodeOpsColors.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            prefixIcon:
                const Icon(Icons.search, size: 18, color: CodeOpsColors.textTertiary),
          ),
          onChanged: onQueryChanged,
        ),
        if (filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: CodeOpsColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: CodeOpsColors.border),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: filtered
                  .map((m) => ListTile(
                        dense: true,
                        selected: m.userId == selectedUserId,
                        selectedTileColor:
                            CodeOpsColors.primary.withValues(alpha: 0.1),
                        title: Text(
                          m.displayName ?? m.email ?? m.userId,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CodeOpsColors.textPrimary,
                          ),
                        ),
                        subtitle: m.email != null
                            ? Text(
                                m.email!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CodeOpsColors.textTertiary,
                                ),
                              )
                            : null,
                        onTap: () => onUserSelected(m.userId),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  final CollectionShareResponse share;
  final VoidCallback onRemove;

  const _ShareRow({required this.share, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 16, color: CodeOpsColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              share.sharedWithUserId ?? 'Unknown',
              style:
                  const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: CodeOpsColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              share.permission?.displayName ?? 'Viewer',
              style:
                  const TextStyle(fontSize: 11, color: CodeOpsColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const Key('remove_share_button'),
            icon: const Icon(Icons.close, size: 14),
            color: CodeOpsColors.textTertiary,
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}
