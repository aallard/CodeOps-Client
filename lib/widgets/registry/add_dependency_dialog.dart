/// Dialog for creating a new service dependency.
///
/// Provides dropdowns for source and target services, dependency type,
/// a required checkbox, and optional description and endpoint fields.
/// Validates that source and target are different.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/registry_enums.dart';
import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Dialog for creating a directed dependency between two services.
///
/// Watches [registryServicesProvider] for the service dropdown options.
/// On submit, calls [RegistryApi.createDependency] and refreshes the
/// dependency graph, startup order, and cycle detection providers.
class AddDependencyDialog extends ConsumerStatefulWidget {
  /// Optional pre-selected source service ID.
  final String? preselectedSourceId;

  /// Creates an [AddDependencyDialog].
  const AddDependencyDialog({super.key, this.preselectedSourceId});

  @override
  ConsumerState<AddDependencyDialog> createState() =>
      _AddDependencyDialogState();
}

class _AddDependencyDialogState extends ConsumerState<AddDependencyDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _sourceServiceId;
  String? _targetServiceId;
  DependencyType _dependencyType = DependencyType.httpRest;
  bool _isRequired = true;
  late final TextEditingController _descriptionController;
  late final TextEditingController _endpointController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _sourceServiceId = widget.preselectedSourceId;
    _descriptionController = TextEditingController();
    _endpointController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final api = ref.read(registryApiProvider);
      await api.createDependency(
        sourceServiceId: _sourceServiceId!,
        targetServiceId: _targetServiceId!,
        dependencyType: _dependencyType,
        isRequired: _isRequired,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetEndpoint: _endpointController.text.trim().isEmpty
            ? null
            : _endpointController.text.trim(),
      );
      ref.invalidate(registryDependencyGraphProvider);
      ref.invalidate(registryStartupOrderProvider);
      ref.invalidate(registryCyclesProvider);
      if (mounted) {
        showToast(context,
            message: 'Dependency created', type: ToastType.success);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to create dependency: $e',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(registryServicesProvider);
    final allServices = servicesAsync.valueOrNull?.content ?? [];

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    const Icon(Icons.link,
                        size: 20, color: CodeOpsColors.primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Add Dependency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CodeOpsColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: CodeOpsColors.textTertiary),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: CodeOpsColors.border),
              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source service
                      DropdownButtonFormField<String>(
                        initialValue: _sourceServiceId,
                        decoration: const InputDecoration(
                          labelText: 'Source Service *',
                          isDense: true,
                        ),
                        isExpanded: true,
                        dropdownColor: CodeOpsColors.surface,
                        items: allServices.map((svc) {
                          return DropdownMenuItem(
                            value: svc.id,
                            child: Text(
                              svc.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CodeOpsColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _sourceServiceId = v),
                        validator: (v) =>
                            v == null ? 'Select source service' : null,
                      ),
                      const SizedBox(height: 16),
                      // Target service
                      DropdownButtonFormField<String>(
                        initialValue: _targetServiceId,
                        decoration: const InputDecoration(
                          labelText: 'Target Service *',
                          isDense: true,
                        ),
                        isExpanded: true,
                        dropdownColor: CodeOpsColors.surface,
                        items: allServices
                            .where((s) => s.id != _sourceServiceId)
                            .map((svc) {
                          return DropdownMenuItem(
                            value: svc.id,
                            child: Text(
                              svc.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CodeOpsColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _targetServiceId = v),
                        validator: (v) =>
                            v == null ? 'Select target service' : null,
                      ),
                      const SizedBox(height: 16),
                      // Dependency type
                      DropdownButtonFormField<DependencyType>(
                        initialValue: _dependencyType,
                        decoration: const InputDecoration(
                          labelText: 'Dependency Type *',
                          isDense: true,
                        ),
                        isExpanded: true,
                        dropdownColor: CodeOpsColors.surface,
                        items: DependencyType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.displayName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CodeOpsColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _dependencyType = v);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Is required checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _isRequired,
                            onChanged: (v) =>
                                setState(() => _isRequired = v ?? true),
                          ),
                          const Text(
                            'Required dependency',
                            style: TextStyle(
                              fontSize: 13,
                              color: CodeOpsColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional description',
                          isDense: true,
                        ),
                        maxLength: 500,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      // Target endpoint
                      TextFormField(
                        controller: _endpointController,
                        decoration: const InputDecoration(
                          labelText: 'Target Endpoint',
                          hintText: 'e.g., /api/v1/users',
                          isDense: true,
                        ),
                        maxLength: 500,
                      ),
                      const SizedBox(height: 24),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Add Dependency'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the [AddDependencyDialog].
Future<void> showAddDependencyDialog(
  BuildContext context, {
  String? preselectedSourceId,
}) {
  return showDialog(
    context: context,
    builder: (_) => AddDependencyDialog(
      preselectedSourceId: preselectedSourceId,
    ),
  );
}
