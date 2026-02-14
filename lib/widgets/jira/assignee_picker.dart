/// Search and select a Jira user for assignment.
///
/// Provides a debounced autocomplete search against the Jira user
/// search API, with avatar, display name, and email display.
/// Supports compact mode (avatar + name) and full mode
/// (avatar + name + email).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/jira_models.dart';
import '../../providers/jira_providers.dart';
import '../../theme/colors.dart';

/// Display mode for the assignee picker.
enum AssigneeDisplayMode {
  /// Compact mode: avatar + display name only. Suitable for tables.
  compact,

  /// Full mode: avatar + display name + email. Suitable for dialogs.
  full,
}

/// Jira user picker with debounced search and compact/full display modes.
///
/// Uses [jiraUserSearchProvider] to search Jira users by query string.
/// Search is debounced at 300ms to avoid excessive API calls.
/// An "Unassigned" option is always available at the top of results.
///
/// [displayMode] controls the visual layout:
/// - [AssigneeDisplayMode.compact]: avatar (24px) + display name
/// - [AssigneeDisplayMode.full]: avatar (24px) + display name + email
class AssigneePicker extends ConsumerStatefulWidget {
  /// Called when a user is selected. Passes `null` for "Unassigned".
  final ValueChanged<JiraUser?> onUserSelected;

  /// The currently assigned user, if any.
  final JiraUser? currentAssignee;

  /// Visual display mode for the picker and result items.
  final AssigneeDisplayMode displayMode;

  /// Creates an [AssigneePicker].
  const AssigneePicker({
    super.key,
    required this.onUserSelected,
    this.currentAssignee,
    this.displayMode = AssigneeDisplayMode.full,
  });

  @override
  ConsumerState<AssigneePicker> createState() => _AssigneePickerState();
}

class _AssigneePickerState extends ConsumerState<AssigneePicker> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _searchQuery = '';
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  /// Shows the dropdown when the field gains focus.
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() => _showDropdown = true);
    }
  }

  /// Debounces the search input by 300ms before updating the query.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = value.trim());
      }
    });
  }

  /// Selects a user and closes the dropdown.
  void _selectUser(JiraUser? user) {
    widget.onUserSelected(user);
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _showDropdown = false;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current assignee display
        if (widget.currentAssignee != null ||
            widget.displayMode == AssigneeDisplayMode.full)
          _buildCurrentAssignee(),
        if (widget.currentAssignee != null ||
            widget.displayMode == AssigneeDisplayMode.full)
          const SizedBox(height: 8),
        // Search field
        TapRegion(
          onTapOutside: (_) {
            if (_showDropdown) {
              setState(() => _showDropdown = false);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.person_search,
                      size: 20, color: CodeOpsColors.textTertiary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: CodeOpsColors.textTertiary,
                          onPressed: () {
                            _controller.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: CodeOpsColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.primary),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              if (_showDropdown) _buildDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the current assignee display row.
  Widget _buildCurrentAssignee() {
    final user = widget.currentAssignee;

    if (user == null) {
      return const Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: CodeOpsColors.surfaceVariant,
            child: Icon(Icons.person_outline,
                size: 14, color: CodeOpsColors.textTertiary),
          ),
          SizedBox(width: 8),
          Text(
            'Unassigned',
            style: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildAvatar(user),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.displayName ?? 'Unknown',
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.displayMode == AssigneeDisplayMode.full &&
                  user.emailAddress != null)
                Text(
                  user.emailAddress!,
                  style: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the search results dropdown.
  Widget _buildDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unassigned option always at top
          _buildUserTile(null),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Search results
          if (_searchQuery.isNotEmpty)
            Flexible(child: _buildSearchResults())
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Type to search for users',
                style: TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the search results list from the provider.
  Widget _buildSearchResults() {
    final usersAsync = ref.watch(jiraUserSearchProvider(_searchQuery));

    return usersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: CodeOpsColors.primary,
            ),
          ),
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Failed to search users',
          style: TextStyle(color: CodeOpsColors.error, fontSize: 12),
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No users found',
              style: TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: users.length,
          itemBuilder: (context, index) => _buildUserTile(users[index]),
        );
      },
    );
  }

  /// Builds a single user tile in the dropdown.
  ///
  /// Passing `null` renders the "Unassigned" option.
  Widget _buildUserTile(JiraUser? user) {
    final isCompact = widget.displayMode == AssigneeDisplayMode.compact;

    if (user == null) {
      return InkWell(
        onTap: () => _selectUser(null),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: CodeOpsColors.surfaceVariant,
                child: Icon(Icons.person_off_outlined,
                    size: 14, color: CodeOpsColors.textTertiary),
              ),
              SizedBox(width: 10),
              Text(
                'Unassigned',
                style: TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _selectUser(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _buildAvatar(user),
            const SizedBox(width: 10),
            Expanded(
              child: isCompact
                  ? Text(
                      user.displayName ?? 'Unknown',
                      style: const TextStyle(
                        color: CodeOpsColors.textPrimary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.displayName ?? 'Unknown',
                          style: const TextStyle(
                            color: CodeOpsColors.textPrimary,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.emailAddress != null)
                          Text(
                            user.emailAddress!,
                            style: const TextStyle(
                              color: CodeOpsColors.textTertiary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a circular avatar for a Jira user.
  Widget _buildAvatar(JiraUser user) {
    final avatarUrl = user.avatarUrls?.x24 ?? user.avatarUrls?.x32;

    return CircleAvatar(
      radius: 12,
      backgroundColor: CodeOpsColors.surfaceVariant,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              (user.displayName?.isNotEmpty == true)
                  ? user.displayName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}
