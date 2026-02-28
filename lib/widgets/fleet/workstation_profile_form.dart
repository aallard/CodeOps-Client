/// Create / edit form dialog for a workstation profile.
///
/// Collects workstation name, description, and default toggle.
/// Returns a [CreateWorkstationProfileRequest] for create mode or an
/// [UpdateWorkstationProfileRequest] for edit mode.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';

/// A dialog that collects workstation profile configuration.
///
/// When [existing] is provided, the form is pre-populated for editing
/// and returns an [UpdateWorkstationProfileRequest]. Otherwise returns a
/// [CreateWorkstationProfileRequest].
class WorkstationProfileFormDialog extends StatefulWidget {
  /// Existing detail for edit mode; null for create mode.
  final FleetWorkstationProfileDetail? existing;

  /// Creates a [WorkstationProfileFormDialog].
  const WorkstationProfileFormDialog({super.key, this.existing});

  /// Shows the dialog and returns the result.
  ///
  /// Returns a [CreateWorkstationProfileRequest] for create or
  /// [UpdateWorkstationProfileRequest] for edit, or `null` if cancelled.
  static Future<Object?> show(
    BuildContext context, {
    FleetWorkstationProfileDetail? existing,
  }) {
    return showDialog<Object>(
      context: context,
      builder: (_) => WorkstationProfileFormDialog(existing: existing),
    );
  }

  @override
  State<WorkstationProfileFormDialog> createState() =>
      _WorkstationProfileFormDialogState();
}

class _WorkstationProfileFormDialogState
    extends State<WorkstationProfileFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late bool _isDefault;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// Validates and submits the form.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEdit) {
      final request = UpdateWorkstationProfileRequest(
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        isDefault: _isDefault,
      );
      Navigator.of(context).pop(request);
    } else {
      final request = CreateWorkstationProfileRequest(
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        isDefault: _isDefault,
      );
      Navigator.of(context).pop(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: Text(
          _isEdit ? 'Edit Workstation Profile' : 'Create Workstation Profile'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Workstation Name *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration:
                    const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Default Workstation'),
                subtitle: const Text(
                  'Default workstations are offered on the dashboard quick action',
                  style: TextStyle(
                      color: CodeOpsColors.textTertiary, fontSize: 12),
                ),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
