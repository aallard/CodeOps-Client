/// Widget for mapping a Jira project to a CodeOps project.
///
/// Allows the user to select a Jira connection, choose a Jira project,
/// set a default issue type, configure labels and component, then
/// persists the mapping via [ProjectApi.updateProject].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/jira_models.dart';
import '../../models/project.dart';
import '../../providers/jira_providers.dart';
import '../../providers/project_providers.dart' hide jiraConnectionsProvider;
import '../../theme/colors.dart';
import '../shared/empty_state.dart';
import '../shared/loading_overlay.dart';
import '../shared/notification_toast.dart';

/// Maps a CodeOps project to a Jira project with default issue settings.
///
/// Displays dropdowns for connection and project selection, a text field
/// for the default issue type (with suggestions from Jira), chip input
/// for labels, and a text field for component name. Shows the current
/// mapping when one is already configured.
class JiraProjectMapper extends ConsumerStatefulWidget {
  /// The CodeOps project to map.
  final Project project;

  /// Creates a [JiraProjectMapper].
  const JiraProjectMapper({super.key, required this.project});

  @override
  ConsumerState<JiraProjectMapper> createState() => _JiraProjectMapperState();
}

class _JiraProjectMapperState extends ConsumerState<JiraProjectMapper> {
  String? _selectedConnectionId;
  String? _selectedProjectKey;
  String _defaultIssueType = '';
  List<String> _labels = [];
  String _component = '';
  final _labelController = TextEditingController();
  final _issueTypeController = TextEditingController();
  final _componentController = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFromProject();
  }

  /// Pre-fills fields from the existing project Jira mapping.
  void _initializeFromProject() {
    final p = widget.project;
    _selectedConnectionId = p.jiraConnectionId;
    _selectedProjectKey = p.jiraProjectKey;
    _defaultIssueType = p.jiraDefaultIssueType ?? '';
    _labels = List<String>.from(p.jiraLabels ?? []);
    _component = p.jiraComponent ?? '';
    _issueTypeController.text = _defaultIssueType;
    _componentController.text = _component;
    _initialized = true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _issueTypeController.dispose();
    _componentController.dispose();
    super.dispose();
  }

  /// Adds a label from the text field to the labels list.
  void _addLabel() {
    final label = _labelController.text.trim();
    if (label.isNotEmpty && !_labels.contains(label)) {
      setState(() {
        _labels.add(label);
        _labelController.clear();
      });
    }
  }

  /// Removes a label by index.
  void _removeLabel(int index) {
    setState(() => _labels.removeAt(index));
  }

  /// Persists the Jira mapping to the CodeOps project.
  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final projectApi = ref.read(projectApiProvider);
      await projectApi.updateProject(
        widget.project.id,
        jiraConnectionId: _selectedConnectionId,
        jiraProjectKey: _selectedProjectKey,
        jiraDefaultIssueType:
            _defaultIssueType.isNotEmpty ? _defaultIssueType : null,
        jiraLabels: _labels.isNotEmpty ? _labels : null,
        jiraComponent: _component.isNotEmpty ? _component : null,
      );

      ref.invalidate(selectedProjectProvider);
      ref.invalidate(teamProjectsProvider);

      if (!mounted) return;
      showToast(
        context,
        message: 'Jira mapping saved',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showToast(
        context,
        message: 'Failed to save mapping: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jira Project Mapping',
                style: TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Link this project to a Jira project for issue tracking integration.',
                style: TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              _buildConnectionDropdown(),
              const SizedBox(height: 16),
              _buildProjectDropdown(),
              const SizedBox(height: 16),
              _buildIssueTypeField(),
              const SizedBox(height: 16),
              _buildLabelsField(),
              const SizedBox(height: 16),
              _buildComponentField(),
              const SizedBox(height: 24),
              _buildCurrentMapping(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Mapping'),
                ),
              ),
            ],
          ),
        ),
        if (_saving) const LoadingOverlay(message: 'Saving mapping...'),
      ],
    );
  }

  /// Builds the Jira connection dropdown.
  Widget _buildConnectionDropdown() {
    final connectionsAsync = ref.watch(jiraConnectionsProvider);

    return connectionsAsync.when(
      loading: () => _dropdownShell(
        label: 'Jira Connection',
        child: const LinearProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (e, _) => _dropdownShell(
        label: 'Jira Connection',
        child: Text(
          'Failed to load connections',
          style: const TextStyle(color: CodeOpsColors.error, fontSize: 13),
        ),
      ),
      data: (connections) {
        if (connections.isEmpty) {
          return _dropdownShell(
            label: 'Jira Connection',
            child: const Text(
              'No Jira connections configured for this team',
              style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 13),
            ),
          );
        }

        return _dropdownShell(
          label: 'Jira Connection',
          child: DropdownButtonFormField<String>(
            initialValue: connections.any((c) => c.id == _selectedConnectionId)
                ? _selectedConnectionId
                : null,
            dropdownColor: CodeOpsColors.surfaceVariant,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 14,
            ),
            decoration: _inputDecoration('Select a Jira connection'),
            items: connections
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedConnectionId = value;
                _selectedProjectKey = null;
              });
              if (value != null) {
                final conn = connections.firstWhere((c) => c.id == value);
                ref.read(activeJiraConnectionProvider.notifier).state = conn;
              }
            },
          ),
        );
      },
    );
  }

  /// Builds the Jira project dropdown.
  Widget _buildProjectDropdown() {
    if (_selectedConnectionId == null) {
      return _dropdownShell(
        label: 'Jira Project',
        child: const Text(
          'Select a connection first',
          style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 13),
        ),
      );
    }

    final projectsAsync = ref.watch(jiraProjectsProvider);

    return projectsAsync.when(
      loading: () => _dropdownShell(
        label: 'Jira Project',
        child: const LinearProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (e, _) => _dropdownShell(
        label: 'Jira Project',
        child: Text(
          'Failed to load projects',
          style: const TextStyle(color: CodeOpsColors.error, fontSize: 13),
        ),
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return _dropdownShell(
            label: 'Jira Project',
            child: const Text(
              'No projects found in this Jira instance',
              style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 13),
            ),
          );
        }

        return _dropdownShell(
          label: 'Jira Project',
          child: DropdownButtonFormField<String>(
            initialValue: projects.any((p) => p.key == _selectedProjectKey)
                ? _selectedProjectKey
                : null,
            dropdownColor: CodeOpsColors.surfaceVariant,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 14,
            ),
            decoration: _inputDecoration('Select a Jira project'),
            items: projects
                .map((p) => DropdownMenuItem(
                      value: p.key,
                      child: Text('${p.key} - ${p.name}'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedProjectKey = value),
          ),
        );
      },
    );
  }

  /// Builds the default issue type field with suggestions from Jira.
  Widget _buildIssueTypeField() {
    final List<JiraIssueType> issueTypes;
    if (_selectedProjectKey != null) {
      final typesAsync =
          ref.watch(jiraIssueTypesProvider(_selectedProjectKey!));
      issueTypes = typesAsync.valueOrNull ?? [];
    } else {
      issueTypes = [];
    }

    return _dropdownShell(
      label: 'Default Issue Type',
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: _defaultIssueType),
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return issueTypes.map((t) => t.name);
          }
          return issueTypes
              .map((t) => t.name)
              .where((name) => name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (value) {
          setState(() => _defaultIssueType = value);
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          // Sync the autocomplete controller with our state.
          if (controller.text != _defaultIssueType &&
              !focusNode.hasFocus) {
            controller.text = _defaultIssueType;
          }
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 14,
            ),
            decoration: _inputDecoration('e.g. Bug, Task, Story'),
            onChanged: (value) => _defaultIssueType = value,
            onSubmitted: (_) => onSubmitted(),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              color: CodeOpsColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      title: Text(
                        option,
                        style: const TextStyle(
                          color: CodeOpsColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the labels chip input field.
  Widget _buildLabelsField() {
    return _dropdownShell(
      label: 'Labels',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labelController,
                  style: const TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: _inputDecoration('Add a label and press Enter'),
                  onSubmitted: (_) => _addLabel(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addLabel,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: CodeOpsColors.primary,
                tooltip: 'Add label',
              ),
            ],
          ),
          if (_labels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(_labels.length, (index) {
                return Chip(
                  label: Text(
                    _labels[index],
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: CodeOpsColors.surfaceVariant,
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteIconColor: CodeOpsColors.textTertiary,
                  onDeleted: () => _removeLabel(index),
                  side: const BorderSide(color: CodeOpsColors.border),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the component name field.
  Widget _buildComponentField() {
    return _dropdownShell(
      label: 'Component',
      child: TextField(
        controller: _componentController,
        style: const TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 14,
        ),
        decoration: _inputDecoration('e.g. Backend, Frontend'),
        onChanged: (value) => _component = value,
      ),
    );
  }

  /// Displays the current Jira mapping when configured.
  Widget _buildCurrentMapping() {
    final p = widget.project;
    if (p.jiraProjectKey == null && p.jiraConnectionId == null) {
      return const EmptyState(
        icon: Icons.link_off,
        title: 'No Jira Mapping',
        subtitle: 'Configure a mapping above to link this project to Jira.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Mapping',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _mappingRow('Project Key', p.jiraProjectKey ?? 'Not set'),
          const SizedBox(height: 6),
          _mappingRow('Issue Type', p.jiraDefaultIssueType ?? 'Not set'),
          const SizedBox(height: 6),
          _mappingRow(
            'Labels',
            p.jiraLabels?.isNotEmpty == true
                ? p.jiraLabels!.join(', ')
                : 'None',
          ),
          const SizedBox(height: 6),
          _mappingRow('Component', p.jiraComponent ?? 'Not set'),
        ],
      ),
    );
  }

  /// Builds a single key-value row for the current mapping display.
  Widget _mappingRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  /// Wraps a field with a section label.
  Widget _dropdownShell({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CodeOpsColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  /// Returns standard [InputDecoration] for text fields in this widget.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: CodeOpsColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CodeOpsColors.primary),
      ),
    );
  }
}
