/// Dialog for creating a policy binding.
///
/// Binds an access policy to a target entity (user, team, or service)
/// by specifying the [BindingType] and target ID. The policy ID is
/// pre-selected by the calling context.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_enums.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';

/// A modal dialog for creating a new policy binding.
class CreateBindingDialog extends ConsumerStatefulWidget {
  /// UUID of the policy to bind.
  final String policyId;

  /// Creates a [CreateBindingDialog].
  const CreateBindingDialog({super.key, required this.policyId});

  @override
  ConsumerState<CreateBindingDialog> createState() =>
      _CreateBindingDialogState();
}

class _CreateBindingDialogState extends ConsumerState<CreateBindingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetIdController = TextEditingController();

  BindingType _bindingType = BindingType.user;
  bool _submitting = false;

  @override
  void dispose() {
    _targetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: const Text('Create Binding'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Binding Type
              DropdownButtonFormField<BindingType>(
                initialValue: _bindingType,
                decoration: const InputDecoration(
                  labelText: 'Binding Type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: BindingType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.displayName),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _bindingType = v);
                },
                dropdownColor: CodeOpsColors.surface,
              ),
              const SizedBox(height: 12),
              // Target ID
              TextFormField(
                controller: _targetIdController,
                decoration: InputDecoration(
                  labelText: 'Target ID *',
                  hintText: _bindingType == BindingType.user
                      ? 'User UUID'
                      : _bindingType == BindingType.team
                          ? 'Team UUID'
                          : 'Service UUID',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Target ID is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final api = ref.read(vaultApiProvider);
      await api.createBinding(
        policyId: widget.policyId,
        bindingType: _bindingType,
        bindingTargetId: _targetIdController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Binding created')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create: $e')),
        );
      }
    }
  }
}
