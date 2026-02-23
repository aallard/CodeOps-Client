/// Clear session confirmation dialog for the Scribe editor.
///
/// Prompts the user to confirm clearing all tabs, closed-tab history,
/// and optionally recent files before proceeding.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// The result of the clear session confirmation dialog.
enum ScribeClearSessionAction {
  /// Clear the session.
  clear,

  /// Cancel and keep the session.
  cancel,
}

/// Confirmation dialog for clearing the Scribe session.
///
/// Shows a warning about losing all open tabs and history.
/// Returns [ScribeClearSessionAction.clear] if confirmed, or
/// [ScribeClearSessionAction.cancel] if dismissed.
class ScribeClearSessionDialog {
  ScribeClearSessionDialog._();

  /// Shows the clear session confirmation dialog.
  static Future<ScribeClearSessionAction> show(BuildContext context) async {
    final result = await showDialog<ScribeClearSessionAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _ClearSessionDialogContent(),
    );
    return result ?? ScribeClearSessionAction.cancel;
  }
}

/// The dialog content widget.
class _ClearSessionDialogContent extends StatelessWidget {
  const _ClearSessionDialogContent();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      title: const Text(
        'Clear Session',
        style: TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: const SizedBox(
        width: 320,
        child: Text(
          'This will close all open tabs and clear the closed-tab history. '
          'Unsaved changes will be lost.\n\n'
          'Are you sure you want to continue?',
          style: TextStyle(
            color: CodeOpsColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ScribeClearSessionAction.cancel),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ScribeClearSessionAction.clear),
          style: FilledButton.styleFrom(
            backgroundColor: CodeOpsColors.error,
          ),
          child: const Text('Clear Session'),
        ),
      ],
    );
  }
}
