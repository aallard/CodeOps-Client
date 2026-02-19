/// One-time credential display for dynamic lease creation.
///
/// Shows connection details (username, password, host, port, database)
/// returned from lease creation. Displays a prominent warning that
/// credentials cannot be retrieved again after dismissal.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';

/// Displays one-time connection credentials with copy buttons and a warning.
///
/// The [connectionDetails] map contains backend-specific key-value pairs
/// (e.g., username, password, host, port, database). Each field is shown
/// with a monospace value and a copy-to-clipboard button.
class CredentialDisplay extends StatelessWidget {
  /// Connection details map from lease creation response.
  final Map<String, dynamic> connectionDetails;

  /// Called when the user dismisses the credential display.
  final VoidCallback onDismiss;

  /// Creates a [CredentialDisplay].
  const CredentialDisplay({
    super.key,
    required this.connectionDetails,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CodeOpsColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: CodeOpsColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: CodeOpsColors.error),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Save these credentials now \u2014 '
                    'they cannot be retrieved again',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Credential fields
          ...connectionDetails.entries.map(
            (entry) => _CredentialField(
              label: _formatLabel(entry.key),
              value: entry.value.toString(),
            ),
          ),
          const SizedBox(height: 12),
          // Dismiss button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDismiss,
              child: const Text('Dismiss'),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a camelCase or snake_case key into a human-readable label.
  String _formatLabel(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}

// ---------------------------------------------------------------------------
// Credential Field
// ---------------------------------------------------------------------------

class _CredentialField extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 14),
            tooltip: 'Copy',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }
}
