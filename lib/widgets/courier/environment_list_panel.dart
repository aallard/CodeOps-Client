/// Left-side panel listing all team environments.
///
/// Displays a searchable list of [EnvironmentResponse] items with active
/// indicators, variable counts, and context menus for clone/delete. A
/// "Globals" entry at the top allows editing global variables.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Left panel of the environment manager two-pane layout.
///
/// Shows a search field, a "Globals" shortcut, and the list of environments.
/// Selecting an item notifies the parent via [onSelectEnvironment] or
/// [onSelectGlobals]. The [selectedEnvironmentId] highlights the current row.
class EnvironmentListPanel extends ConsumerStatefulWidget {
  /// ID of the currently selected environment, or null.
  final String? selectedEnvironmentId;

  /// Whether the globals panel is currently shown.
  final bool globalsSelected;

  /// Called when the user taps an environment row.
  final ValueChanged<String> onSelectEnvironment;

  /// Called when the user taps the "Globals" row.
  final VoidCallback onSelectGlobals;

  /// Called when a new environment is created (passes the new ID).
  final ValueChanged<String>? onEnvironmentCreated;

  /// Called when an environment is deleted.
  final ValueChanged<String>? onEnvironmentDeleted;

  /// Creates an [EnvironmentListPanel].
  const EnvironmentListPanel({
    super.key,
    this.selectedEnvironmentId,
    this.globalsSelected = false,
    required this.onSelectEnvironment,
    required this.onSelectGlobals,
    this.onEnvironmentCreated,
    this.onEnvironmentDeleted,
  });

  @override
  ConsumerState<EnvironmentListPanel> createState() =>
      _EnvironmentListPanelState();
}

class _EnvironmentListPanelState extends ConsumerState<EnvironmentListPanel> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createEnvironment() async {
    final name = await _showNameDialog(title: 'New Environment');
    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) return;
      final api = ref.read(courierApiProvider);
      final env = await api.createEnvironment(
        teamId,
        CreateEnvironmentRequest(name: name),
      );
      ref.invalidate(courierEnvironmentsProvider);
      if (env.id != null) {
        widget.onEnvironmentCreated?.call(env.id!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create environment: $e')),
      );
    }
  }

  Future<void> _cloneEnvironment(EnvironmentResponse env) async {
    final name = await _showNameDialog(
      title: 'Clone Environment',
      initialValue: '${env.name ?? "Unnamed"} (Copy)',
    );
    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null || env.id == null) return;
      final api = ref.read(courierApiProvider);
      final cloned = await api.cloneEnvironment(
        teamId,
        env.id!,
        CloneEnvironmentRequest(newName: name),
      );
      ref.invalidate(courierEnvironmentsProvider);
      if (cloned.id != null) {
        widget.onEnvironmentCreated?.call(cloned.id!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clone environment: $e')),
      );
    }
  }

  Future<void> _deleteEnvironment(EnvironmentResponse env) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CodeOpsColors.surfaceVariant,
        title: const Text('Delete Environment',
            style: TextStyle(color: CodeOpsColors.textPrimary)),
        content: Text(
          'Delete "${env.name ?? "Unnamed"}"? This cannot be undone.',
          style: const TextStyle(color: CodeOpsColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: CodeOpsColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null || env.id == null) return;
      final api = ref.read(courierApiProvider);
      await api.deleteEnvironment(teamId, env.id!);
      ref.invalidate(courierEnvironmentsProvider);
      widget.onEnvironmentDeleted?.call(env.id!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete environment: $e')),
      );
    }
  }

  Future<String?> _showNameDialog({
    required String title,
    String initialValue = '',
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CodeOpsColors.surfaceVariant,
        title: Text(title,
            style: const TextStyle(color: CodeOpsColors.textPrimary)),
        content: TextField(
          key: const Key('env_name_field'),
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: CodeOpsColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Environment name',
            hintStyle: const TextStyle(color: CodeOpsColors.textTertiary),
            filled: true,
            fillColor: CodeOpsColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: CodeOpsColors.border),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final envsAsync = ref.watch(courierEnvironmentsProvider);

    return Container(
      key: const Key('environment_list_panel'),
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(right: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Search
          _buildSearchField(),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Globals row
          _buildGlobalsRow(),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Environment list
          Expanded(
            child: envsAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(
                    color: CodeOpsColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
              data: (envs) => _buildList(envs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      key: const Key('env_list_header'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.tune_outlined,
              size: 16, color: CodeOpsColors.textSecondary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Environments',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            key: const Key('new_environment_button'),
            onTap: _createEnvironment,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add, size: 16, color: CodeOpsColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        key: const Key('env_search_field'),
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search environments…',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textTertiary,
          ),
          prefixIcon: const Icon(Icons.search,
              size: 14, color: CodeOpsColors.textTertiary),
          filled: true,
          fillColor: CodeOpsColors.background,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalsRow() {
    final isSelected = widget.globalsSelected;
    return InkWell(
      key: const Key('globals_row'),
      onTap: widget.onSelectGlobals,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.15)
            : null,
        child: Row(
          children: [
            Icon(
              Icons.public,
              size: 14,
              color: isSelected
                  ? CodeOpsColors.primary
                  : CodeOpsColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Globals',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<EnvironmentResponse> envs) {
    final filtered = _searchQuery.isEmpty
        ? envs
        : envs
            .where(
                (e) => (e.name ?? '').toLowerCase().contains(_searchQuery))
            .toList();

    if (filtered.isEmpty) {
      return Center(
        key: const Key('env_list_empty'),
        child: Text(
          _searchQuery.isEmpty ? 'No environments yet' : 'No matches',
          style: const TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textTertiary,
          ),
        ),
      );
    }

    return ListView.builder(
      key: const Key('env_list'),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          _buildEnvironmentRow(filtered[index]),
    );
  }

  Widget _buildEnvironmentRow(EnvironmentResponse env) {
    final isSelected = env.id == widget.selectedEnvironmentId;

    return InkWell(
      key: Key('env_row_${env.id}'),
      onTap: () {
        if (env.id != null) widget.onSelectEnvironment(env.id!);
      },
      onSecondaryTap: () => _showContextMenu(env),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.15)
            : null,
        child: Row(
          children: [
            // Active indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: env.isActive == true
                    ? CodeOpsColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: env.isActive == true
                      ? CodeOpsColors.success
                      : CodeOpsColors.border,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    env.name ?? 'Unnamed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? CodeOpsColors.primary
                          : CodeOpsColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (env.variableCount != null && env.variableCount! > 0)
                    Text(
                      '${env.variableCount} variable${env.variableCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            // Context menu button
            InkWell(
              key: Key('env_menu_${env.id}'),
              onTap: () => _showContextMenu(env),
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_vert,
                    size: 14, color: CodeOpsColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(EnvironmentResponse env) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx + 200, offset.dy + 200, offset.dx + 400, offset.dy + 400),
      color: CodeOpsColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      items: [
        const PopupMenuItem(
          value: 'clone',
          child: Row(
            children: [
              Icon(Icons.copy, size: 14, color: CodeOpsColors.textSecondary),
              SizedBox(width: 8),
              Text('Clone',
                  style: TextStyle(
                      fontSize: 13, color: CodeOpsColors.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 14, color: CodeOpsColors.error),
              SizedBox(width: 8),
              Text('Delete',
                  style: TextStyle(fontSize: 13, color: CodeOpsColors.error)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'clone') _cloneEnvironment(env);
      if (value == 'delete') _deleteEnvironment(env);
    });
  }
}
