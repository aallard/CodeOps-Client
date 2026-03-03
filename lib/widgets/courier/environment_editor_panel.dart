/// Right-side panel for editing an environment's metadata and variables.
///
/// Displays the environment name, description, active toggle, and a variable
/// table with key/value/secret/enabled columns. Supports inline editing with
/// auto-add of empty rows. Saves variables via the
/// [CourierApiService.setEnvironmentVariables] endpoint.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Editable row in the variable table.
class _VariableRow {
  /// Controller for the variable key field.
  final TextEditingController keyController;

  /// Controller for the variable value field.
  final TextEditingController valueController;

  /// Whether this variable is secret (value masked).
  bool isSecret;

  /// Whether this variable is enabled.
  bool isEnabled;

  /// Creates a [_VariableRow].
  _VariableRow({
    String key = '',
    String value = '',
    this.isSecret = false,
    this.isEnabled = true,
  })  : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  /// Disposes controllers.
  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

/// Editor panel for a single environment's variables and metadata.
///
/// Loads variables via [courierEnvironmentVariablesProvider] and persists
/// changes via [CourierApiService.setEnvironmentVariables]. The name and
/// description are saved via [CourierApiService.updateEnvironment].
class EnvironmentEditorPanel extends ConsumerStatefulWidget {
  /// ID of the environment to edit.
  final String environmentId;

  /// Creates an [EnvironmentEditorPanel].
  const EnvironmentEditorPanel({
    super.key,
    required this.environmentId,
  });

  @override
  ConsumerState<EnvironmentEditorPanel> createState() =>
      _EnvironmentEditorPanelState();
}

class _EnvironmentEditorPanelState
    extends ConsumerState<EnvironmentEditorPanel> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final List<_VariableRow> _rows = [];
  bool _initialized = false;
  bool _saving = false;
  bool _bulkEdit = false;
  final _bulkController = TextEditingController();

  @override
  void didUpdateWidget(covariant EnvironmentEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environmentId != widget.environmentId) {
      _initialized = false;
      _disposeRows();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _bulkController.dispose();
    _disposeRows();
    super.dispose();
  }

  void _disposeRows() {
    for (final r in _rows) {
      r.dispose();
    }
    _rows.clear();
  }

  void _initFromData(
      EnvironmentResponse env, List<EnvironmentVariableResponse> vars) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = env.name ?? '';
    _descController.text = env.description ?? '';
    _disposeRows();
    for (final v in vars) {
      _rows.add(_VariableRow(
        key: v.variableKey ?? '',
        value: v.variableValue ?? '',
        isSecret: v.isSecret ?? false,
        isEnabled: v.isEnabled ?? true,
      ));
    }
    // Auto-add empty row
    _rows.add(_VariableRow());
  }

  void _ensureEmptyRow() {
    if (_rows.isEmpty ||
        _rows.last.keyController.text.isNotEmpty ||
        _rows.last.valueController.text.isNotEmpty) {
      setState(() => _rows.add(_VariableRow()));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) return;
      final api = ref.read(courierApiProvider);

      // Save name/description
      await api.updateEnvironment(
        teamId,
        widget.environmentId,
        UpdateEnvironmentRequest(
          name: _nameController.text,
          description: _descController.text,
        ),
      );

      // Save variables (skip empty rows)
      final entries = _rows
          .where((r) => r.keyController.text.isNotEmpty)
          .map((r) => VariableEntry(
                variableKey: r.keyController.text,
                variableValue: r.valueController.text,
                isSecret: r.isSecret,
                isEnabled: r.isEnabled,
              ))
          .toList();

      await api.setEnvironmentVariables(
        teamId,
        widget.environmentId,
        SaveEnvironmentVariablesRequest(variables: entries),
      );

      ref.invalidate(courierEnvironmentsProvider);
      ref.invalidate(
          courierEnvironmentVariablesProvider(widget.environmentId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Environment saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _activateEnvironment() async {
    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) return;
      final api = ref.read(courierApiProvider);
      await api.activateEnvironment(teamId, widget.environmentId);
      ref.invalidate(courierEnvironmentsProvider);
      ref.invalidate(courierActiveEnvironmentProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activation failed: $e')),
        );
      }
    }
  }

  void _toggleBulkEdit() {
    setState(() {
      if (!_bulkEdit) {
        // Serialize rows to text
        final buf = StringBuffer();
        for (final r in _rows) {
          if (r.keyController.text.isEmpty) continue;
          buf.writeln('${r.keyController.text}=${r.valueController.text}');
        }
        _bulkController.text = buf.toString();
      } else {
        // Parse text back to rows
        _disposeRows();
        final lines = _bulkController.text.split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final eqIdx = line.indexOf('=');
          if (eqIdx < 0) {
            _rows.add(_VariableRow(key: line.trim()));
          } else {
            _rows.add(_VariableRow(
              key: line.substring(0, eqIdx).trim(),
              value: line.substring(eqIdx + 1).trim(),
            ));
          }
        }
        _rows.add(_VariableRow());
      }
      _bulkEdit = !_bulkEdit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final envAsync =
        ref.watch(courierEnvironmentDetailProvider(widget.environmentId));
    final varsAsync =
        ref.watch(courierEnvironmentVariablesProvider(widget.environmentId));

    return Container(
      key: const Key('environment_editor_panel'),
      color: CodeOpsColors.background,
      child: envAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style:
                  const TextStyle(color: CodeOpsColors.error, fontSize: 12)),
        ),
        data: (env) {
          final vars = varsAsync.valueOrNull ?? [];
          _initFromData(env, vars);
          return _buildEditor(env);
        },
      ),
    );
  }

  Widget _buildEditor(EnvironmentResponse env) {
    return Column(
      children: [
        // Header
        _buildEditorHeader(env),
        const Divider(height: 1, color: CodeOpsColors.border),
        // Metadata fields
        _buildMetadataFields(env),
        const Divider(height: 1, color: CodeOpsColors.border),
        // Variable toolbar
        _buildVariableToolbar(),
        const Divider(height: 1, color: CodeOpsColors.border),
        // Variable table or bulk editor
        Expanded(
          child: _bulkEdit ? _buildBulkEditor() : _buildVariableTable(),
        ),
      ],
    );
  }

  Widget _buildEditorHeader(EnvironmentResponse env) {
    return Container(
      key: const Key('editor_header'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              env.name ?? 'Unnamed',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
          if (env.isActive != true)
            TextButton.icon(
              key: const Key('activate_button'),
              onPressed: _activateEnvironment,
              icon: const Icon(Icons.check_circle_outline, size: 14),
              label: const Text('Activate', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: CodeOpsColors.success,
              ),
            ),
          if (env.isActive == true)
            Container(
              key: const Key('active_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CodeOpsColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.success,
                ),
              ),
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            key: const Key('save_environment_button'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save, size: 14),
            label: const Text('Save', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataFields(EnvironmentResponse env) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          // Name
          Expanded(
            child: TextField(
              key: const Key('env_name_input'),
              controller: _nameController,
              style: const TextStyle(
                  fontSize: 13, color: CodeOpsColors.textPrimary),
              decoration: _fieldDecoration('Name'),
            ),
          ),
          const SizedBox(width: 12),
          // Description
          Expanded(
            flex: 2,
            child: TextField(
              key: const Key('env_description_input'),
              controller: _descController,
              style: const TextStyle(
                  fontSize: 13, color: CodeOpsColors.textPrimary),
              decoration: _fieldDecoration('Description'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary),
      filled: true,
      fillColor: CodeOpsColors.background,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
    );
  }

  Widget _buildVariableToolbar() {
    final nonEmptyCount =
        _rows.where((r) => r.keyController.text.isNotEmpty).length;
    return Container(
      key: const Key('variable_toolbar'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          Text(
            '$nonEmptyCount variable${nonEmptyCount == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            key: const Key('bulk_edit_toggle'),
            onPressed: _toggleBulkEdit,
            icon: Icon(
              _bulkEdit ? Icons.table_chart : Icons.edit_note,
              size: 14,
            ),
            label: Text(
              _bulkEdit ? 'Table View' : 'Bulk Edit',
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkEditor() {
    return Container(
      key: const Key('bulk_editor'),
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _bulkController,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: CodeOpsColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'KEY=VALUE\nANOTHER_KEY=another_value',
          hintStyle: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: CodeOpsColors.textTertiary,
          ),
          filled: true,
          fillColor: CodeOpsColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildVariableTable() {
    return SingleChildScrollView(
      key: const Key('variable_table'),
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FixedColumnWidth(60),
          3: FixedColumnWidth(60),
          4: FixedColumnWidth(40),
        },
        children: [
          // Column headers
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: CodeOpsColors.border.withValues(alpha: 0.5))),
            ),
            children: const [
              _ColumnHeader('KEY'),
              _ColumnHeader('VALUE'),
              _ColumnHeader('SECRET'),
              _ColumnHeader('ON'),
              SizedBox.shrink(),
            ],
          ),
          // Data rows
          for (int i = 0; i < _rows.length; i++) _buildTableRow(i),
        ],
      ),
    );
  }

  TableRow _buildTableRow(int index) {
    final row = _rows[index];
    return TableRow(
      key: ValueKey('var_row_$index'),
      children: [
        // Key
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: TextField(
            key: Key('var_key_$index'),
            controller: row.keyController,
            onChanged: (_) => _ensureEmptyRow(),
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: CodeOpsColors.textPrimary,
            ),
            decoration: _cellDecoration('Variable name'),
          ),
        ),
        // Value
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: TextField(
            key: Key('var_value_$index'),
            controller: row.valueController,
            obscureText: row.isSecret,
            onChanged: (_) => _ensureEmptyRow(),
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: CodeOpsColors.textPrimary,
            ),
            decoration: _cellDecoration('Value'),
          ),
        ),
        // Secret toggle
        Center(
          child: Checkbox(
            key: Key('var_secret_$index'),
            value: row.isSecret,
            onChanged: (v) => setState(() => row.isSecret = v ?? false),
            side: const BorderSide(color: CodeOpsColors.border),
            activeColor: CodeOpsColors.warning,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        // Enabled toggle
        Center(
          child: Checkbox(
            key: Key('var_enabled_$index'),
            value: row.isEnabled,
            onChanged: (v) => setState(() => row.isEnabled = v ?? true),
            side: const BorderSide(color: CodeOpsColors.border),
            activeColor: CodeOpsColors.success,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        // Delete button
        Center(
          child: row.keyController.text.isNotEmpty
              ? InkWell(
                  key: Key('var_delete_$index'),
                  onTap: () {
                    setState(() {
                      _rows[index].dispose();
                      _rows.removeAt(index);
                      _ensureEmptyRow();
                    });
                  },
                  child: const Icon(Icons.close,
                      size: 14, color: CodeOpsColors.textTertiary),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  InputDecoration _cellDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary),
      filled: true,
      fillColor: CodeOpsColors.surface,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: CodeOpsColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: CodeOpsColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: CodeOpsColors.primary),
      ),
    );
  }
}

/// Column header label for the variable table.
class _ColumnHeader extends StatelessWidget {
  /// Header label text.
  final String label;

  /// Creates a [_ColumnHeader].
  const _ColumnHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: CodeOpsColors.textTertiary,
        ),
      ),
    );
  }
}
