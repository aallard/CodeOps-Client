/// Empty state displayed when no tabs are open in the Scribe editor.
///
/// Shows a centered message with "New File" and "Open File" action buttons
/// plus keyboard shortcut hints.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Empty state for the Scribe editor when no tabs are open.
///
/// Displays a centered code icon, title, subtitle, and two action
/// buttons ("New File" and "Open File") with keyboard shortcut hints.
class ScribeEmptyState extends StatelessWidget {
  /// Callback for the "New File" button.
  final VoidCallback onNewFile;

  /// Callback for the "Open File" button.
  final VoidCallback onOpenFile;

  /// Creates a [ScribeEmptyState].
  const ScribeEmptyState({
    super.key,
    required this.onNewFile,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.code,
            size: 64,
            color: CodeOpsColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Scribe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: CodeOpsColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Code & text editor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CodeOpsColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: onNewFile,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New File'),
                style: FilledButton.styleFrom(
                  backgroundColor: CodeOpsColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onOpenFile,
                icon: const Icon(Icons.folder_open, size: 16),
                label: const Text('Open File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CodeOpsColors.primary,
                  side: const BorderSide(color: CodeOpsColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ctrl+N New File  \u00B7  Ctrl+O Open File',
            style: TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
