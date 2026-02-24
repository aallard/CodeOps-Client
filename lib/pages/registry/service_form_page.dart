/// Unified service registration and editing form.
///
/// Create mode (no [serviceId]): shows "Register New Service" title,
/// empty form with defaults, POST on submit.
/// Edit mode ([serviceId] provided): pre-fills form from existing service
/// data, shows "Edit Service" title, PUT on submit.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/registry_enums.dart';
import '../../models/registry_models.dart';
import '../../providers/registry_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/registry/env_config_editor.dart';
import '../../widgets/registry/port_preview_panel.dart';
import '../../widgets/registry/tech_stack_selector.dart';
import '../../widgets/shared/error_panel.dart';
import '../../widgets/shared/notification_toast.dart';

/// Unified service registration and editing form page.
///
/// When [serviceId] is null, operates in create mode. When provided,
/// loads the existing service and operates in edit mode.
class ServiceFormPage extends ConsumerStatefulWidget {
  /// If null, create mode. If provided, edit mode.
  final String? serviceId;

  /// Creates a [ServiceFormPage].
  const ServiceFormPage({super.key, this.serviceId});

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _repoUrlController;
  late final TextEditingController _repoFullNameController;
  late final TextEditingController _defaultBranchController;
  late final TextEditingController _healthCheckUrlController;
  late final TextEditingController _healthCheckIntervalController;

  // State
  ServiceType? _serviceType;
  String _techStack = '';
  String? _environmentsJson;
  String? _metadataJson;
  bool _loading = true;
  bool _saving = false;
  ServiceRegistrationResponse? _existingService;
  List<PortAllocationResponse>? _allocatedPorts;

  bool get _isEditMode => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _repoUrlController = TextEditingController();
    _repoFullNameController = TextEditingController();
    _defaultBranchController = TextEditingController(text: 'main');
    _healthCheckUrlController = TextEditingController();
    _healthCheckIntervalController = TextEditingController(text: '30');
    _loadService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _repoUrlController.dispose();
    _repoFullNameController.dispose();
    _defaultBranchController.dispose();
    _healthCheckUrlController.dispose();
    _healthCheckIntervalController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    if (!_isEditMode) {
      setState(() => _loading = false);
      return;
    }

    try {
      final api = ref.read(registryApiProvider);
      final identity = await api.getServiceIdentity(widget.serviceId!);
      final svc = identity.service;
      if (mounted) {
        setState(() {
          _existingService = svc;
          _nameController.text = svc.name;
          _descriptionController.text = svc.description ?? '';
          _repoUrlController.text = svc.repoUrl ?? '';
          _repoFullNameController.text = svc.repoFullName ?? '';
          _defaultBranchController.text = svc.defaultBranch ?? 'main';
          _serviceType = svc.serviceType;
          _techStack = svc.techStack ?? '';
          _healthCheckUrlController.text = svc.healthCheckUrl ?? '';
          _healthCheckIntervalController.text =
              '${svc.healthCheckIntervalSeconds ?? 30}';
          _environmentsJson = svc.environmentsJson;
          _metadataJson = svc.metadataJson;
          _allocatedPorts = identity.ports;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showToast(context,
            message: 'Failed to load service: $e', type: ToastType.error);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final api = ref.read(registryApiProvider);

      if (_isEditMode) {
        final result = await api.updateService(
          widget.serviceId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          repoUrl: _repoUrlController.text.trim().isEmpty
              ? null
              : _repoUrlController.text.trim(),
          repoFullName: _repoFullNameController.text.trim().isEmpty
              ? null
              : _repoFullNameController.text.trim(),
          defaultBranch: _defaultBranchController.text.trim().isEmpty
              ? null
              : _defaultBranchController.text.trim(),
          techStack: _techStack.isEmpty ? null : _techStack,
          healthCheckUrl: _healthCheckUrlController.text.trim().isEmpty
              ? null
              : _healthCheckUrlController.text.trim(),
          healthCheckIntervalSeconds:
              int.tryParse(_healthCheckIntervalController.text.trim()),
          environmentsJson: _environmentsJson,
          metadataJson: _metadataJson,
        );
        ref.invalidate(registryServiceIdentityProvider(widget.serviceId!));
        ref.invalidate(registryServicesProvider);
        if (mounted) {
          showToast(context,
              message: 'Service "${result.name}" updated',
              type: ToastType.success);
          context.go('/registry/services/${result.id}');
        }
      } else {
        final teamId = ref.read(selectedTeamIdProvider);
        if (teamId == null) {
          showToast(context,
              message: 'No team selected', type: ToastType.error);
          setState(() => _saving = false);
          return;
        }

        final result = await api.createService(
          teamId: teamId,
          name: _nameController.text.trim(),
          serviceType: _serviceType!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          repoUrl: _repoUrlController.text.trim().isEmpty
              ? null
              : _repoUrlController.text.trim(),
          repoFullName: _repoFullNameController.text.trim().isEmpty
              ? null
              : _repoFullNameController.text.trim(),
          defaultBranch: _defaultBranchController.text.trim().isEmpty
              ? null
              : _defaultBranchController.text.trim(),
          techStack: _techStack.isEmpty ? null : _techStack,
          healthCheckUrl: _healthCheckUrlController.text.trim().isEmpty
              ? null
              : _healthCheckUrlController.text.trim(),
          healthCheckIntervalSeconds:
              int.tryParse(_healthCheckIntervalController.text.trim()),
          environmentsJson: _environmentsJson,
          metadataJson: _metadataJson,
        );
        ref.invalidate(registryServicesProvider);
        if (mounted) {
          showToast(context,
              message: 'Service "${result.name}" registered',
              type: ToastType.success);
          context.go('/registry/services/${result.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: '${_isEditMode ? 'Update' : 'Registration'} failed: $e',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CodeOpsColors.divider),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    size: 18, color: CodeOpsColors.textSecondary),
                onPressed: () => context.go(
                  _isEditMode
                      ? '/registry/services/${widget.serviceId}'
                      : '/registry',
                ),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Text(
                _isEditMode ? 'Edit Service' : 'Register New Service',
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (_isEditMode && _existingService == null)
                  ? ErrorPanel(
                      title: 'Service Not Found',
                      message: 'Could not load service data.',
                      onRetry: _loadService,
                    )
                  : _buildForm(),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: 12),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),

                // Repository
                _buildSectionHeader('Repository'),
                const SizedBox(height: 12),
                _buildRepositorySection(),
                const SizedBox(height: 24),

                // Tech Stack
                _buildSectionHeader('Tech Stack'),
                const SizedBox(height: 12),
                TechStackSelector(
                  initialValue: _techStack.isEmpty ? null : _techStack,
                  onChanged: (value) => _techStack = value,
                ),
                const SizedBox(height: 24),

                // Health Check
                _buildSectionHeader('Health Check'),
                const SizedBox(height: 12),
                _buildHealthCheckSection(),
                const SizedBox(height: 24),

                // Port Preview
                PortPreviewPanel(
                  serviceType: _serviceType,
                  allocatedPorts: _isEditMode ? _allocatedPorts : null,
                ),
                const SizedBox(height: 24),

                // Advanced
                _buildSectionHeader('Advanced'),
                const SizedBox(height: 12),
                EnvConfigEditor(
                  label: 'Environments JSON',
                  initialValue: _environmentsJson,
                  onChanged: (value) => _environmentsJson = value,
                  placeholder:
                      '{\n  "dev": { "baseUrl": "http://localhost:8090" },\n'
                      '  "staging": { "baseUrl": "https://staging.example.com" }\n}',
                ),
                const SizedBox(height: 12),
                EnvConfigEditor(
                  label: 'Metadata JSON',
                  initialValue: _metadataJson,
                  onChanged: (value) => _metadataJson = value,
                  placeholder:
                      '{\n  "owner": "team-name",\n  "version": "1.0.0"\n}',
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => context.go(
                                _isEditMode
                                    ? '/registry/services/${widget.serviceId}'
                                    : '/registry',
                              ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: CodeOpsColors.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: CodeOpsColors.textSecondary)),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditMode
                              ? 'Save Changes'
                              : 'Register Service'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CodeOpsColors.textPrimary,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        // Name
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Service Name *',
            hintText: 'e.g., CodeOps Server',
            isDense: true,
          ),
          maxLength: 100,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Name is required';
            if (v.trim().length > 100) return 'Max 100 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Service Type
        DropdownButtonFormField<ServiceType>(
          initialValue: _serviceType,
          decoration: const InputDecoration(
            labelText: 'Service Type *',
            isDense: true,
          ),
          isExpanded: true,
          dropdownColor: CodeOpsColors.surface,
          items: ServiceType.values.map((type) {
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
          onChanged: _isEditMode
              ? null // Service type is immutable in edit mode
              : (value) => setState(() => _serviceType = value),
          validator: (v) {
            if (v == null) return 'Service type is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Brief description of this service',
            isDense: true,
          ),
          maxLines: 3,
          maxLength: 5000,
          validator: (v) {
            if (v != null && v.length > 5000) return 'Max 5000 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRepositorySection() {
    return Column(
      children: [
        TextFormField(
          controller: _repoUrlController,
          decoration: const InputDecoration(
            labelText: 'Repository URL',
            hintText: 'https://github.com/org/repo',
            isDense: true,
          ),
          maxLength: 500,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v != null && v.trim().isNotEmpty) {
              final uri = Uri.tryParse(v.trim());
              if (uri == null || !uri.hasScheme) {
                return 'Enter a valid URL';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _repoFullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'org/repo',
                  isDense: true,
                ),
                maxLength: 200,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _defaultBranchController,
                decoration: const InputDecoration(
                  labelText: 'Default Branch',
                  hintText: 'main',
                  isDense: true,
                ),
                maxLength: 50,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthCheckSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _healthCheckUrlController,
            decoration: const InputDecoration(
              labelText: 'Health Check URL',
              hintText: 'http://localhost:8090/actuator/health',
              isDense: true,
            ),
            maxLength: 500,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v != null && v.trim().isNotEmpty) {
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasScheme) {
                  return 'Enter a valid URL';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _healthCheckIntervalController,
            decoration: const InputDecoration(
              labelText: 'Interval (sec)',
              hintText: '30',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'Must be positive';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
