/// Panel for editing team-level global variables.
///
/// Uses the same key-value table layout as [EnvironmentEditorPanel] but
/// persists via [CourierApiService.batchSaveGlobalVariables]. Global
/// variables are available across all environments.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Editable row in the global variable table.
class _GlobalVarRow {
  /// Controller for the variable key field.
  final TextEditingController keyController;

  /// Controller for the variable value field.
  final TextEditingController valueController;

  /// Whether this variable is secret (value masked).
  bool isSecret;

  /// Whether this variable is enabled.
  bool isEnabled;

  /// Creates a [_GlobalVarRow].
  _GlobalVarRow({
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

/// Editor panel for team-wide global variables.
///
/// Loads variables via [courierGlobalVariablesProvider] and persists
/// changes via [CourierApiService.batchSaveGlobalVariables].
class GlobalVariablesPanel extends ConsumerStatefulWidget {
  /// Creates a [GlobalVariablesPanel].
  const GlobalVariablesPanel({super.key});

  @override
  ConsumerState<GlobalVariablesPanel> createState() =>
      _GlobalVariablesPanelState();
}

class _GlobalVariablesPanelState extends ConsumerState<GlobalVariablesPanel> {
  final List<_GlobalVarRow> _rows = [];
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _disposeRows();
    super.dispose();
  }

  void _disposeRows() {
    for (final r in _rows) {
      r.dispose();
    }
    _rows.clear();
  }

  void _initFromData(List<GlobalVariableResponse> vars) {
    if (_initialized) return;
    _initialized = true;
    _disposeRows();
    for (final v in vars) {
      _rows.add(_GlobalVarRow(
        key: v.variableKey ?? '',
        value: v.variableValue ?? '',
        isSecret: v.isSecret ?? false,
        isEnabled: v.isEnabled ?? true,
      ));
    }
    _rows.add(_GlobalVarRow());
  }

  void _ensureEmptyRow() {
    if (_rows.isEmpty ||
        _rows.last.keyController.text.isNotEmpty ||
        _rows.last.valueController.text.isNotEmpty) {
      setState(() => _rows.add(_GlobalVarRow()));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) return;
      final api = ref.read(courierApiProvider);

      final entries = _rows
          .where((r) => r.keyController.text.isNotEmpty)
          .map((r) => SaveGlobalVariableRequest(
                variableKey: r.keyController.text,
                variableValue: r.valueController.text,
                isSecret: r.isSecret,
                isEnabled: r.isEnabled,
              ))
          .toList();

      await api.batchSaveGlobalVariables(
        teamId,
        BatchSaveGlobalVariablesRequest(variables: entries),
      );

      ref.invalidate(courierGlobalVariablesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Global variables saved')),
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

  @override
  Widget build(BuildContext context) {
    final globalsAsync = ref.watch(courierGlobalVariablesProvider);

    return Container(
      key: const Key('global_variables_panel'),
      color: CodeOpsColors.background,
      child: globalsAsync.when(
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
        data: (vars) {
          _initFromData(vars);
          return _buildEditor();
        },
      ),
    );
  }

  Widget _buildEditor() {
    final nonEmptyCount =
        _rows.where((r) => r.keyController.text.isNotEmpty).length;

    return Column(
      children: [
        // Header
        Container(
          key: const Key('globals_header'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: CodeOpsColors.surface,
          child: Row(
            children: [
              const Icon(Icons.public,
                  size: 16, color: CodeOpsColors.textSecondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Global Variables',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                key: const Key('save_globals_button'),
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
        ),
        const Divider(height: 1, color: CodeOpsColors.border),
        // Info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: CodeOpsColors.surface,
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 14, color: CodeOpsColors.textTertiary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Global variables are available in all environments',
                  style: TextStyle(
                    fontSize: 11,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ),
              Text(
                key: const Key('global_var_count'),
                '$nonEmptyCount variable${nonEmptyCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: CodeOpsColors.border),
        // Variable table
        Expanded(
          child: SingleChildScrollView(
            key: const Key('global_variable_table'),
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
                            color:
                                CodeOpsColors.border.withValues(alpha: 0.5))),
                  ),
                  children: const [
                    _GlobalColumnHeader('KEY'),
                    _GlobalColumnHeader('VALUE'),
                    _GlobalColumnHeader('SECRET'),
                    _GlobalColumnHeader('ON'),
                    SizedBox.shrink(),
                  ],
                ),
                for (int i = 0; i < _rows.length; i++) _buildRow(i),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildRow(int index) {
    final row = _rows[index];
    return TableRow(
      key: ValueKey('global_var_row_$index'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: TextField(
            key: Key('global_key_$index'),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: TextField(
            key: Key('global_value_$index'),
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
        Center(
          child: Checkbox(
            key: Key('global_secret_$index'),
            value: row.isSecret,
            onChanged: (v) => setState(() => row.isSecret = v ?? false),
            side: const BorderSide(color: CodeOpsColors.border),
            activeColor: CodeOpsColors.warning,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Center(
          child: Checkbox(
            key: Key('global_enabled_$index'),
            value: row.isEnabled,
            onChanged: (v) => setState(() => row.isEnabled = v ?? true),
            side: const BorderSide(color: CodeOpsColors.border),
            activeColor: CodeOpsColors.success,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Center(
          child: row.keyController.text.isNotEmpty
              ? InkWell(
                  key: Key('global_delete_$index'),
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

/// Column header label for the global variable table.
class _GlobalColumnHeader extends StatelessWidget {
  /// Header label text.
  final String label;

  /// Creates a [_GlobalColumnHeader].
  const _GlobalColumnHeader(this.label);

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
