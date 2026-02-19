/// Access evaluation form and result display.
///
/// Allows testing access policies by submitting a user ID (or service ID),
/// path, and permission. Displays the [AccessDecision] result in a
/// color-coded card showing allowed/denied, reason, and deciding policy.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_enums.dart';
import '../../models/vault_models.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';

/// A form + result card for evaluating access policies.
class AccessEvaluator extends ConsumerStatefulWidget {
  /// Creates an [AccessEvaluator].
  const AccessEvaluator({super.key});

  @override
  ConsumerState<AccessEvaluator> createState() => _AccessEvaluatorState();
}

class _AccessEvaluatorState extends ConsumerState<AccessEvaluator> {
  final _formKey = GlobalKey<FormState>();
  final _targetIdController = TextEditingController();
  final _pathController = TextEditingController();

  PolicyPermission _permission = PolicyPermission.read;
  bool _isService = false;
  bool _evaluating = false;
  AccessDecision? _result;

  @override
  void dispose() {
    _targetIdController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Evaluate Access',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Test whether a user or service has permission on a path.',
          style: TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textTertiary,
          ),
        ),
        const SizedBox(height: 20),
        _buildForm(),
        const SizedBox(height: 24),
        if (_result != null) _buildResult(_result!),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CodeOpsColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CodeOpsColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User vs Service toggle
            Row(
              children: [
                ChoiceChip(
                  label: const Text('User', style: TextStyle(fontSize: 11)),
                  selected: !_isService,
                  onSelected: (_) => setState(() => _isService = false),
                  selectedColor: CodeOpsColors.primary,
                  backgroundColor: CodeOpsColors.background,
                  labelStyle: TextStyle(
                    color: !_isService
                        ? Colors.white
                        : CodeOpsColors.textSecondary,
                  ),
                  side: const BorderSide(color: CodeOpsColors.border),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Service', style: TextStyle(fontSize: 11)),
                  selected: _isService,
                  onSelected: (_) => setState(() => _isService = true),
                  selectedColor: CodeOpsColors.primary,
                  backgroundColor: CodeOpsColors.background,
                  labelStyle: TextStyle(
                    color: _isService
                        ? Colors.white
                        : CodeOpsColors.textSecondary,
                  ),
                  side: const BorderSide(color: CodeOpsColors.border),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Target ID
            TextFormField(
              controller: _targetIdController,
              decoration: InputDecoration(
                labelText: _isService ? 'Service ID *' : 'User ID *',
                hintText: 'UUID',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return '${_isService ? "Service" : "User"} ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Path
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                labelText: 'Path *',
                hintText: '/services/my-app/db-password',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Path is required';
                if (!v.startsWith('/')) return 'Path must start with /';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Permission dropdown
            DropdownButtonFormField<PolicyPermission>(
              initialValue: _permission,
              decoration: const InputDecoration(
                labelText: 'Permission',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: PolicyPermission.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.displayName),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _permission = v);
              },
              dropdownColor: CodeOpsColors.surface,
            ),
            const SizedBox(height: 16),
            // Evaluate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _evaluating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.policy_outlined, size: 16),
                label: const Text('Evaluate'),
                onPressed: _evaluating ? null : _evaluate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(AccessDecision decision) {
    final allowed = decision.allowed;
    final color = allowed ? CodeOpsColors.success : CodeOpsColors.error;
    final icon = allowed ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 8),
              Text(
                allowed ? 'ALLOWED' : 'DENIED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          if (decision.reason != null) ...[
            const SizedBox(height: 8),
            Text(
              decision.reason!,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ],
          if (decision.decidingPolicyName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Deciding Policy: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                Text(
                  decision.decidingPolicyName!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          if (decision.decidingPolicyId != null) ...[
            const SizedBox(height: 2),
            Text(
              decision.decidingPolicyId!,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _evaluate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _evaluating = true;
      _result = null;
    });

    try {
      final api = ref.read(vaultApiProvider);
      final AccessDecision decision;
      if (_isService) {
        decision = await api.evaluateServiceAccess(
          serviceId: _targetIdController.text.trim(),
          path: _pathController.text.trim(),
          permission: _permission,
        );
      } else {
        decision = await api.evaluateAccess(
          userId: _targetIdController.text.trim(),
          path: _pathController.text.trim(),
          permission: _permission,
        );
      }
      if (mounted) {
        setState(() {
          _result = decision;
          _evaluating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _evaluating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evaluation failed: $e')),
        );
      }
    }
  }
}
