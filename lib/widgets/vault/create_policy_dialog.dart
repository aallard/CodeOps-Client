/// Dialog for creating a new Vault access policy.
///
/// Validates required fields (name, pathPattern, at least one permission),
/// path format (must start with `/`), and provides a multi-select permission
/// picker and deny-policy toggle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_enums.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';

/// A modal dialog for creating a new access policy.
class CreatePolicyDialog extends ConsumerStatefulWidget {
  /// Creates a [CreatePolicyDialog].
  const CreatePolicyDialog({super.key});

  @override
  ConsumerState<CreatePolicyDialog> createState() =>
      _CreatePolicyDialogState();
}

class _CreatePolicyDialogState extends ConsumerState<CreatePolicyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pathPatternController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<PolicyPermission> _selectedPermissions = {};
  bool _isDenyPolicy = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pathPatternController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: const Text('Create Policy'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'read-only-db-secrets',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLength: 200,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Path Pattern
                TextFormField(
                  controller: _pathPatternController,
                  decoration: const InputDecoration(
                    labelText: 'Path Pattern *',
                    hintText: '/services/*/db-*',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Path pattern is required';
                    }
                    if (!v.startsWith('/')) {
                      return 'Path must start with /';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                // Permissions
                const Text(
                  'Permissions *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                FormField<Set<PolicyPermission>>(
                  initialValue: _selectedPermissions,
                  validator: (_) {
                    if (_selectedPermissions.isEmpty) {
                      return 'Select at least one permission';
                    }
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: PolicyPermission.values.map((p) {
                            final selected = _selectedPermissions.contains(p);
                            final color =
                                CodeOpsColors.policyPermissionColors[p] ??
                                    CodeOpsColors.textTertiary;
                            return FilterChip(
                              label: Text(
                                p.displayName,
                                style: TextStyle(fontSize: 11, color: color),
                              ),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _selectedPermissions.add(p);
                                  } else {
                                    _selectedPermissions.remove(p);
                                  }
                                });
                                field.didChange(_selectedPermissions);
                              },
                              checkmarkColor: color,
                              selectedColor: color.withValues(alpha: 0.15),
                              backgroundColor: CodeOpsColors.background,
                              side: BorderSide(
                                color: selected
                                    ? color.withValues(alpha: 0.5)
                                    : CodeOpsColors.border,
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              field.errorText!,
                              style: const TextStyle(
                                color: CodeOpsColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Deny Policy toggle
                Row(
                  children: [
                    Switch(
                      value: _isDenyPolicy,
                      onChanged: (v) => setState(() => _isDenyPolicy = v),
                      activeTrackColor: CodeOpsColors.error,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Deny Policy',
                      style: TextStyle(
                        fontSize: 13,
                        color: CodeOpsColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Tooltip(
                      message:
                          'Deny policies override allow policies for matching paths',
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      await api.createPolicy(
        name: _nameController.text.trim(),
        pathPattern: _pathPatternController.text.trim(),
        permissions: _selectedPermissions.toList(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text.trim(),
        isDenyPolicy: _isDenyPolicy ? true : null,
      );
      ref.invalidate(vaultPoliciesProvider);
      ref.invalidate(vaultPolicyStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Policy created')),
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
