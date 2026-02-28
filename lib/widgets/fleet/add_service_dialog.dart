/// Dialog for adding a service profile to a solution.
///
/// Displays the list of available service profiles and lets the user
/// pick one plus an optional start order. Returns an
/// [AddSolutionServiceRequest] on submission.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// A dialog that lets the user pick a service profile to add.
///
/// Returns an [AddSolutionServiceRequest] when submitted,
/// or `null` if cancelled.
class AddServiceDialog extends StatefulWidget {
  /// Available service profiles to choose from.
  final List<FleetServiceProfile> availableProfiles;

  /// Service profile IDs already in the solution (to filter out).
  final Set<String> existingServiceIds;

  /// Creates an [AddServiceDialog].
  const AddServiceDialog({
    super.key,
    required this.availableProfiles,
    required this.existingServiceIds,
  });

  /// Shows the dialog and returns the result.
  static Future<AddSolutionServiceRequest?> show(
    BuildContext context, {
    required List<FleetServiceProfile> availableProfiles,
    required Set<String> existingServiceIds,
  }) {
    return showDialog<AddSolutionServiceRequest>(
      context: context,
      builder: (_) => AddServiceDialog(
        availableProfiles: availableProfiles,
        existingServiceIds: existingServiceIds,
      ),
    );
  }

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  String? _selectedProfileId;
  final _startOrderCtrl = TextEditingController();

  /// Profiles not already in the solution.
  late final List<FleetServiceProfile> _filteredProfiles;

  @override
  void initState() {
    super.initState();
    _filteredProfiles = widget.availableProfiles
        .where((p) =>
            p.id != null && !widget.existingServiceIds.contains(p.id))
        .toList();
  }

  @override
  void dispose() {
    _startOrderCtrl.dispose();
    super.dispose();
  }

  /// Validates and submits the form.
  void _submit() {
    if (_selectedProfileId == null) return;

    final order = _startOrderCtrl.text.trim();
    final request = AddSolutionServiceRequest(
      serviceProfileId: _selectedProfileId!,
      startOrder: order.isEmpty ? null : int.tryParse(order),
    );
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: const Text('Add Service'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_filteredProfiles.isEmpty) ...[
              const Text(
                'All available service profiles are already in this solution.',
                style: TextStyle(color: CodeOpsColors.textSecondary),
              ),
            ] else ...[
              const Text(
                'Select a service profile to add:',
                style: TextStyle(color: CodeOpsColors.textSecondary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedProfileId,
                decoration:
                    const InputDecoration(labelText: 'Service Profile *'),
                dropdownColor: CodeOpsColors.surfaceVariant,
                items: _filteredProfiles
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.displayName ?? p.serviceName ?? p.id ?? '',
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
