/// Create/edit dialog for rotation policies.
///
/// Shared dialog for creating and editing rotation policies. Shows
/// strategy-specific configuration fields based on the selected
/// [RotationStrategy]. For edit mode, pre-populates all fields.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_enums.dart';
import '../../models/vault_models.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';

/// A dialog for creating or editing a rotation policy.
///
/// When [existingPolicy] is provided, the dialog operates in edit mode
/// and pre-populates all fields from the existing policy.
class RotationPolicyDialog extends ConsumerStatefulWidget {
  /// UUID of the secret this policy is for.
  final String secretId;

  /// Existing policy to edit, or null for create mode.
  final RotationPolicyResponse? existingPolicy;

  /// Creates a [RotationPolicyDialog].
  const RotationPolicyDialog({
    super.key,
    required this.secretId,
    this.existingPolicy,
  });

  @override
  ConsumerState<RotationPolicyDialog> createState() =>
      _RotationPolicyDialogState();
}

class _RotationPolicyDialogState extends ConsumerState<RotationPolicyDialog> {
  final _formKey = GlobalKey<FormState>();
  late RotationStrategy _strategy;
  late TextEditingController _intervalController;
  late TextEditingController _randomLengthController;
  late TextEditingController _randomCharsetController;
  late TextEditingController _apiUrlController;
  late TextEditingController _apiHeadersController;
  late TextEditingController _scriptCommandController;
  late TextEditingController _maxFailuresController;
  bool _isActive = true;
  bool _isLoading = false;
  String? _error;

  bool get _isEdit => widget.existingPolicy != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPolicy;
    _strategy = p?.strategy ?? RotationStrategy.randomGenerate;
    _intervalController =
        TextEditingController(text: p?.rotationIntervalHours.toString() ?? '24');
    _randomLengthController =
        TextEditingController(text: (p?.randomLength ?? 32).toString());
    _randomCharsetController =
        TextEditingController(text: p?.randomCharset ?? 'alphanumeric');
    _apiUrlController =
        TextEditingController(text: p?.externalApiUrl ?? '');
    _apiHeadersController = TextEditingController();
    _scriptCommandController = TextEditingController();
    _maxFailuresController =
        TextEditingController(text: (p?.maxFailures ?? 5).toString());
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _randomLengthController.dispose();
    _randomCharsetController.dispose();
    _apiUrlController.dispose();
    _apiHeadersController.dispose();
    _scriptCommandController.dispose();
    _maxFailuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: Text(_isEdit ? 'Edit Rotation Policy' : 'Set Up Rotation'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Strategy selector
                const Text(
                  'Strategy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                SegmentedButton<RotationStrategy>(
                  segments: RotationStrategy.values.map((s) {
                    return ButtonSegment(
                      value: s,
                      label: Text(
                        s.displayName,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                  selected: {_strategy},
                  onSelectionChanged: (s) =>
                      setState(() => _strategy = s.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return CodeOpsColors.primary;
                      }
                      return CodeOpsColors.surfaceVariant;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // Rotation interval
                TextFormField(
                  controller: _intervalController,
                  decoration: const InputDecoration(
                    labelText: 'Rotation Interval (hours)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return 'Must be at least 1 hour';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Strategy-specific fields
                ..._buildStrategyFields(),
                const SizedBox(height: 12),
                // Max failures
                TextFormField(
                  controller: _maxFailuresController,
                  decoration: const InputDecoration(
                    labelText: 'Max Failures Before Pause',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 100) {
                      return 'Must be 1\u2013100';
                    }
                    return null;
                  },
                ),
                // Active toggle (edit mode only)
                if (_isEdit) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text(
                      'Active',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: _isActive,
                    activeTrackColor: CodeOpsColors.success,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  List<Widget> _buildStrategyFields() {
    switch (_strategy) {
      case RotationStrategy.randomGenerate:
        return [
          TextFormField(
            controller: _randomLengthController,
            decoration: const InputDecoration(
              labelText: 'Random Length (8\u20131024)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n < 8 || n > 1024) {
                return 'Must be 8\u20131024';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _randomCharsetController,
            decoration: const InputDecoration(
              labelText: 'Character Set',
              hintText: 'alphanumeric',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ];
      case RotationStrategy.externalApi:
        return [
          TextFormField(
            controller: _apiUrlController,
            decoration: const InputDecoration(
              labelText: 'API URL',
              hintText: 'https://...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'URL is required';
              final uri = Uri.tryParse(v.trim());
              if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _apiHeadersController,
            decoration: const InputDecoration(
              labelText: 'API Headers (JSON)',
              hintText: '{"Authorization": "Bearer ..."}',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 3,
          ),
        ];
      case RotationStrategy.customScript:
        return [
          TextFormField(
            controller: _scriptCommandController,
            decoration: const InputDecoration(
              labelText: 'Script Command',
              hintText: '/usr/local/bin/rotate.sh',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
          ),
        ];
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(vaultApiProvider);
      final interval = int.parse(_intervalController.text.trim());
      final maxFailures = int.parse(_maxFailuresController.text.trim());

      if (_isEdit) {
        await api.updateRotationPolicy(
          widget.existingPolicy!.id,
          strategy: _strategy,
          rotationIntervalHours: interval,
          randomLength: _strategy == RotationStrategy.randomGenerate
              ? int.tryParse(_randomLengthController.text.trim())
              : null,
          randomCharset: _strategy == RotationStrategy.randomGenerate
              ? _randomCharsetController.text.trim()
              : null,
          externalApiUrl: _strategy == RotationStrategy.externalApi
              ? _apiUrlController.text.trim()
              : null,
          externalApiHeaders: _strategy == RotationStrategy.externalApi
              ? _apiHeadersController.text.trim().isNotEmpty
                  ? _apiHeadersController.text.trim()
                  : null
              : null,
          scriptCommand: _strategy == RotationStrategy.customScript
              ? _scriptCommandController.text.trim()
              : null,
          maxFailures: maxFailures,
          isActive: _isActive,
        );
      } else {
        await api.createOrUpdateRotationPolicy(
          secretId: widget.secretId,
          strategy: _strategy,
          rotationIntervalHours: interval,
          randomLength: _strategy == RotationStrategy.randomGenerate
              ? int.tryParse(_randomLengthController.text.trim())
              : null,
          randomCharset: _strategy == RotationStrategy.randomGenerate
              ? _randomCharsetController.text.trim()
              : null,
          externalApiUrl: _strategy == RotationStrategy.externalApi
              ? _apiUrlController.text.trim()
              : null,
          externalApiHeaders: _strategy == RotationStrategy.externalApi
              ? _apiHeadersController.text.trim().isNotEmpty
                  ? _apiHeadersController.text.trim()
                  : null
              : null,
          scriptCommand: _strategy == RotationStrategy.customScript
              ? _scriptCommandController.text.trim()
              : null,
          maxFailures: maxFailures,
        );
      }

      ref.invalidate(vaultRotationPolicyProvider(widget.secretId));
      ref.invalidate(vaultRotationHistoryProvider(widget.secretId));
      ref.invalidate(vaultRotationStatsProvider(widget.secretId));

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed: $e';
          _isLoading = false;
        });
      }
    }
  }
}
