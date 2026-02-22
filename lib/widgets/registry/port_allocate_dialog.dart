/// Dialog for allocating ports — auto or manual.
///
/// Auto mode: select service, port type, environment — API auto-assigns port.
/// Manual mode: same fields plus exact port number with availability check.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/registry_enums.dart';
import '../../models/registry_models.dart';
import '../../providers/registry_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Dialog for allocating ports via auto or manual mode.
///
/// Auto mode calls `POST /ports/auto-allocate` with service, port type,
/// and environment. Manual mode adds a port number field and validates
/// availability before submission.
class PortAllocateDialog extends ConsumerStatefulWidget {
  /// Pre-selected service ID (if opened from a service context).
  final String? preselectedServiceId;

  /// Creates a [PortAllocateDialog].
  const PortAllocateDialog({super.key, this.preselectedServiceId});

  @override
  ConsumerState<PortAllocateDialog> createState() =>
      _PortAllocateDialogState();
}

class _PortAllocateDialogState extends ConsumerState<PortAllocateDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Shared fields
  String? _selectedServiceId;
  PortType? _selectedPortType;
  late final TextEditingController _environmentController;
  late final TextEditingController _descriptionController;

  // Manual mode fields
  late final TextEditingController _portNumberController;
  PortCheckResponse? _portCheck;
  bool _checkingPort = false;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedServiceId = widget.preselectedServiceId;
    _environmentController = TextEditingController(
      text: ref.read(registryPortEnvironmentProvider),
    );
    _descriptionController = TextEditingController();
    _portNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _environmentController.dispose();
    _descriptionController.dispose();
    _portNumberController.dispose();
    super.dispose();
  }

  Future<void> _checkPortAvailability() async {
    final portNum = int.tryParse(_portNumberController.text.trim());
    final env = _environmentController.text.trim();
    final teamId = ref.read(selectedTeamIdProvider);
    if (portNum == null || env.isEmpty || teamId == null) return;

    setState(() {
      _checkingPort = true;
      _portCheck = null;
    });

    try {
      final api = ref.read(registryApiProvider);
      final result = await api.checkPortAvailability(
        teamId,
        portNumber: portNum,
        environment: env,
      );
      if (mounted) setState(() => _portCheck = result);
    } catch (_) {
      // Availability check failed — allow submit anyway
    } finally {
      if (mounted) setState(() => _checkingPort = false);
    }
  }

  Future<void> _submitAutoAllocate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final api = ref.read(registryApiProvider);
      final result = await api.autoAllocatePort(
        serviceId: _selectedServiceId!,
        environment: _environmentController.text.trim(),
        portType: _selectedPortType!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      _refreshAndClose(result);
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Auto-allocate failed: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitManualAllocate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final api = ref.read(registryApiProvider);
      final result = await api.manualAllocatePort(
        serviceId: _selectedServiceId!,
        environment: _environmentController.text.trim(),
        portType: _selectedPortType!,
        portNumber: int.parse(_portNumberController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      _refreshAndClose(result);
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Manual allocate failed: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _refreshAndClose(PortAllocationResponse result) {
    ref.invalidate(registryPortMapProvider);
    ref.invalidate(registryPortConflictsProvider);
    if (mounted) {
      showToast(context,
          message: 'Port ${result.portNumber} allocated to '
              '${result.serviceName ?? 'service'}',
          type: ToastType.success);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(registryServicesProvider);
    final services = servicesAsync.valueOrNull?.content ?? [];

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.dns_outlined,
                      size: 20, color: CodeOpsColors.primary),
                  const SizedBox(width: 10),
                  const Text(
                    'Allocate Port',
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
            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: CodeOpsColors.primary,
              labelColor: CodeOpsColors.primary,
              unselectedLabelColor: CodeOpsColors.textSecondary,
              tabs: const [
                Tab(text: 'Auto-Allocate'),
                Tab(text: 'Manual'),
              ],
            ),
            const Divider(height: 1, color: CodeOpsColors.border),
            // Tab content
            Flexible(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAutoTab(services),
                    _buildManualTab(services),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoTab(List<ServiceRegistrationResponse> services) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceDropdown(services),
          const SizedBox(height: 16),
          _buildPortTypeDropdown(),
          const SizedBox(height: 16),
          _buildEnvironmentField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 24),
          _buildSubmitButton('Auto-Allocate', _submitAutoAllocate),
        ],
      ),
    );
  }

  Widget _buildManualTab(List<ServiceRegistrationResponse> services) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceDropdown(services),
          const SizedBox(height: 16),
          _buildPortTypeDropdown(),
          const SizedBox(height: 16),
          _buildEnvironmentField(),
          const SizedBox(height: 16),
          // Port number with availability check
          TextFormField(
            controller: _portNumberController,
            decoration: InputDecoration(
              labelText: 'Port Number *',
              hintText: '8090',
              isDense: true,
              suffixIcon: _checkingPort
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _portCheck != null
                      ? Icon(
                          _portCheck!.available
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 18,
                          color: _portCheck!.available
                              ? CodeOpsColors.success
                              : CodeOpsColors.error,
                        )
                      : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _checkPortAvailability(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Port number required';
              final n = int.tryParse(v.trim());
              if (n == null || n < 1 || n > 65535) {
                return 'Enter a valid port (1\u201365535)';
              }
              return null;
            },
          ),
          if (_portCheck != null && !_portCheck!.available)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'In use by ${_portCheck!.currentOwnerServiceName ?? 'another service'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 24),
          _buildSubmitButton('Allocate', _submitManualAllocate),
        ],
      ),
    );
  }

  Widget _buildServiceDropdown(List<ServiceRegistrationResponse> services) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedServiceId,
      decoration: const InputDecoration(
        labelText: 'Service *',
        isDense: true,
      ),
      isExpanded: true,
      dropdownColor: CodeOpsColors.surface,
      items: services.map((svc) {
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
      onChanged: (value) => setState(() => _selectedServiceId = value),
      validator: (v) => v == null ? 'Select a service' : null,
    );
  }

  Widget _buildPortTypeDropdown() {
    return DropdownButtonFormField<PortType>(
      initialValue: _selectedPortType,
      decoration: const InputDecoration(
        labelText: 'Port Type *',
        isDense: true,
      ),
      isExpanded: true,
      dropdownColor: CodeOpsColors.surface,
      items: PortType.values.map((pt) {
        return DropdownMenuItem(
          value: pt,
          child: Text(
            pt.displayName,
            style: const TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedPortType = value),
      validator: (v) => v == null ? 'Select a port type' : null,
    );
  }

  Widget _buildEnvironmentField() {
    return TextFormField(
      controller: _environmentController,
      decoration: const InputDecoration(
        labelText: 'Environment *',
        hintText: 'local',
        isDense: true,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Environment is required';
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Optional description',
        isDense: true,
      ),
      maxLength: 200,
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _submitting ? null : onPressed,
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
            : Text(label),
      ),
    );
  }
}

/// Shows the [PortAllocateDialog].
Future<void> showPortAllocateDialog(
  BuildContext context, {
  String? preselectedServiceId,
}) {
  return showDialog(
    context: context,
    builder: (_) =>
        PortAllocateDialog(preselectedServiceId: preselectedServiceId),
  );
}
