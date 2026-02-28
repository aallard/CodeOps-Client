/// Dialog for adding a solution profile to a workstation.
///
/// Displays the list of available solution profiles and lets the user
/// pick one plus an optional start order and env var overrides.
/// Returns an [AddWorkstationSolutionRequest] on submission.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// A dialog that lets the user pick a solution profile to add.
///
/// Returns an [AddWorkstationSolutionRequest] when submitted,
/// or `null` if cancelled.
class AddSolutionDialog extends StatefulWidget {
  /// Available solution profiles to choose from.
  final List<FleetSolutionProfile> availableProfiles;

  /// Solution profile IDs already in the workstation (to filter out).
  final Set<String> existingSolutionIds;

  /// Creates an [AddSolutionDialog].
  const AddSolutionDialog({
    super.key,
    required this.availableProfiles,
    required this.existingSolutionIds,
  });

  /// Shows the dialog and returns the result.
  static Future<AddWorkstationSolutionRequest?> show(
    BuildContext context, {
    required List<FleetSolutionProfile> availableProfiles,
    required Set<String> existingSolutionIds,
  }) {
    return showDialog<AddWorkstationSolutionRequest>(
      context: context,
      builder: (_) => AddSolutionDialog(
        availableProfiles: availableProfiles,
        existingSolutionIds: existingSolutionIds,
      ),
    );
  }

  @override
  State<AddSolutionDialog> createState() => _AddSolutionDialogState();
}

class _AddSolutionDialogState extends State<AddSolutionDialog> {
  String? _selectedProfileId;
  final _startOrderCtrl = TextEditingController();
  final _envOverrideCtrl = TextEditingController();

  /// Profiles not already in the workstation.
  late final List<FleetSolutionProfile> _filteredProfiles;

  @override
  void initState() {
    super.initState();
    _filteredProfiles = widget.availableProfiles
        .where((p) =>
            p.id != null && !widget.existingSolutionIds.contains(p.id))
        .toList();
  }

  @override
  void dispose() {
    _startOrderCtrl.dispose();
    _envOverrideCtrl.dispose();
    super.dispose();
  }

  /// Validates and submits the form.
  void _submit() {
    if (_selectedProfileId == null) return;

    final order = _startOrderCtrl.text.trim();
    final envOverride = _envOverrideCtrl.text.trim();
    final request = AddWorkstationSolutionRequest(
      solutionProfileId: _selectedProfileId!,
      startOrder: order.isEmpty ? null : int.tryParse(order),
      overrideEnvVarsJson: envOverride.isEmpty ? null : envOverride,
    );
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: const Text('Add Solution'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_filteredProfiles.isEmpty) ...[
              const Text(
                'All available solution profiles are already in this workstation.',
                style: TextStyle(color: CodeOpsColors.textSecondary),
              ),
            ] else ...[
              const Text(
                'Select a solution profile to add:',
                style: TextStyle(color: CodeOpsColors.textSecondary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedProfileId,
                decoration:
                    const InputDecoration(labelText: 'Solution Profile *'),
                dropdownColor: CodeOpsColors.surfaceVariant,
                items: _filteredProfiles
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.name ?? p.id ?? '',
                            style: CodeOpsTypography.bodyMedium,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProfileId = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startOrderCtrl,
                decoration:
                    const InputDecoration(labelText: 'Start Order'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _envOverrideCtrl,
                decoration: const InputDecoration(
                  labelText: 'Env Var Overrides (JSON)',
                  hintText: '{"KEY": "value"}',
                ),
                maxLines: 3,
                style: CodeOpsTypography.code.copyWith(fontSize: 12),
              ),
            ],
          ],
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
        if (_filteredProfiles.isNotEmpty)
          ElevatedButton(
            onPressed: _selectedProfileId != null ? _submit : null,
            child: const Text('Add'),
          ),
      ],
    );
  }
}
