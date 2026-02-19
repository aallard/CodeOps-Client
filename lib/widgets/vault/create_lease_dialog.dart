/// Dialog for creating a dynamic secret lease.
///
/// Provides a TTL input with preset duration buttons (1h, 4h, 8h, 24h)
/// and a slider. On successful creation, displays connection credentials
/// via [CredentialDisplay] — these are shown only once and cannot be
/// retrieved after the dialog is closed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vault_models.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';
import 'credential_display.dart';

/// A dialog that creates a dynamic lease and displays one-time credentials.
///
/// The [secretId] and [secretName] identify which dynamic secret to
/// generate credentials from. TTL is constrained to 60–86400 seconds.
class CreateLeaseDialog extends ConsumerStatefulWidget {
  /// UUID of the dynamic secret.
  final String secretId;

  /// Name of the dynamic secret (for display).
  final String secretName;

  /// Creates a [CreateLeaseDialog].
  const CreateLeaseDialog({
    super.key,
    required this.secretId,
    required this.secretName,
  });

  @override
  ConsumerState<CreateLeaseDialog> createState() => _CreateLeaseDialogState();
}

class _CreateLeaseDialogState extends ConsumerState<CreateLeaseDialog> {
  int _ttlSeconds = 3600; // Default 1 hour
  bool _isLoading = false;
  String? _error;
  DynamicLeaseResponse? _createdLease;

  static const _presets = [
    (label: '1h', seconds: 3600),
    (label: '4h', seconds: 14400),
    (label: '8h', seconds: 28800),
    (label: '24h', seconds: 86400),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: Text(
        _createdLease != null ? 'Lease Created' : 'Create Lease',
      ),
      content: SizedBox(
        width: 480,
        child: _createdLease != null
            ? _buildCredentialView()
            : _buildForm(),
      ),
      actions: _createdLease != null
          ? [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Done'),
              ),
            ]
          : [
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
                    : const Text('Create Lease'),
              ),
            ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secret: ${widget.secretName}',
          style: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // TTL label
        Row(
          children: [
            const Text(
              'TTL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTtl(_ttlSeconds),
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Preset buttons
        Row(
          children: _presets.map((p) {
            final isSelected = _ttlSeconds == p.seconds;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(p.label, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (_) => setState(() => _ttlSeconds = p.seconds),
                selectedColor: CodeOpsColors.primary,
                backgroundColor: CodeOpsColors.surfaceVariant,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : CodeOpsColors.textSecondary,
                ),
                side: const BorderSide(color: CodeOpsColors.border),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Slider
        Slider(
          value: _ttlSeconds.toDouble(),
          min: 60,
          max: 86400,
          divisions: 1438, // (86400-60)/60 ≈ every 60 seconds
          activeColor: CodeOpsColors.primary,
          inactiveColor: CodeOpsColors.border,
          onChanged: (v) => setState(() => _ttlSeconds = v.round()),
        ),
        // Min/Max labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 min',
                style: TextStyle(fontSize: 10, color: CodeOpsColors.textTertiary)),
            Text('24 hours',
                style: TextStyle(fontSize: 10, color: CodeOpsColors.textTertiary)),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(fontSize: 12, color: CodeOpsColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildCredentialView() {
    final details = _createdLease!.connectionDetails;
    if (details == null || details.isEmpty) {
      return const Text(
        'Lease created but no connection details were returned.',
        style: TextStyle(fontSize: 13, color: CodeOpsColors.textSecondary),
      );
    }
    return CredentialDisplay(
      connectionDetails: details,
      onDismiss: () => Navigator.of(context).pop(true),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(vaultApiProvider);
      final lease = await api.createDynamicLease(
        secretId: widget.secretId,
        ttlSeconds: _ttlSeconds,
      );
      ref.invalidate(vaultLeasesProvider(widget.secretId));
      ref.invalidate(vaultLeaseStatsProvider(widget.secretId));
      ref.invalidate(vaultActiveLeaseCountProvider);
      if (mounted) {
        setState(() {
          _createdLease = lease;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to create lease: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Formats seconds into a human-readable TTL string.
  String _formatTtl(int seconds) {
    final d = Duration(seconds: seconds);
    if (d.inHours >= 1) {
      final m = d.inMinutes.remainder(60);
      return m > 0 ? '${d.inHours}h ${m}m' : '${d.inHours}h';
    }
    return '${d.inMinutes}m';
  }
}
