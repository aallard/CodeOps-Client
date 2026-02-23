/// Save confirmation dialog for dirty Scribe tabs.
///
/// Provides single-tab and batch-tab dialogs that prompt the user
/// to save, discard, or cancel when closing tabs with unsaved changes.
library;

import 'package:flutter/material.dart';

import '../../models/scribe_models.dart';
import '../../theme/colors.dart';

/// The action chosen by the user in a save confirmation dialog.
enum ScribeSaveAction {
  /// Save the tab(s) before closing.
  save,

  /// Discard changes and close without saving.
  dontSave,

  /// Cancel the close operation.
  cancel,
}

/// Result from a batch save confirmation dialog.
///
/// Contains the chosen [action] and, when [action] is [ScribeSaveAction.save],
/// the list of tab IDs the user selected to save.
class ScribeBatchSaveResult {
  /// The user's chosen action.
  final ScribeSaveAction action;

  /// Tab IDs selected for saving (only meaningful when [action] is `save`).
  final List<String> selectedTabIds;

  /// Creates a [ScribeBatchSaveResult].
  const ScribeBatchSaveResult({
    required this.action,
    this.selectedTabIds = const [],
  });
}

/// Save confirmation dialogs for Scribe dirty tabs.
///
/// Use [show] for a single tab and [showBatch] when closing multiple
/// dirty tabs at once (e.g., Close All, Close Others).
class ScribeSaveDialog {
  ScribeSaveDialog._();

  /// Shows a single-tab save confirmation dialog.
  ///
  /// Returns the [ScribeSaveAction] chosen by the user, or
  /// [ScribeSaveAction.cancel] if dismissed.
  static Future<ScribeSaveAction> show(
    BuildContext context, {
    required ScribeTab tab,
  }) async {
    final result = await showDialog<ScribeSaveAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SingleSaveDialog(tab: tab),
    );
    return result ?? ScribeSaveAction.cancel;
  }

  /// Shows a batch save confirmation dialog for multiple dirty tabs.
  ///
  /// Displays checkboxes for each dirty tab so the user can select
  /// which to save. Returns a [ScribeBatchSaveResult] with the chosen
  /// action and selected tab IDs.
  static Future<ScribeBatchSaveResult> showBatch(
    BuildContext context, {
    required List<ScribeTab> dirtyTabs,
  }) async {
    final result = await showDialog<ScribeBatchSaveResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BatchSaveDialog(dirtyTabs: dirtyTabs),
    );
    return result ??
        const ScribeBatchSaveResult(action: ScribeSaveAction.cancel);
  }
}

/// Dialog for a single dirty tab.
class _SingleSaveDialog extends StatelessWidget {
  final ScribeTab tab;

  const _SingleSaveDialog({required this.tab});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      title: const Text(
        'Unsaved Changes',
        style: TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        "'${tab.title}' has unsaved changes.",
        style: const TextStyle(
          color: CodeOpsColors.textSecondary,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ScribeSaveAction.cancel),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ScribeSaveAction.dontSave),
          child: const Text(
            "Don't Save",
            style: TextStyle(color: CodeOpsColors.error),
          ),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ScribeSaveAction.save),
          style: FilledButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Dialog for multiple dirty tabs with checkboxes.
class _BatchSaveDialog extends StatefulWidget {
  final List<ScribeTab> dirtyTabs;

  const _BatchSaveDialog({required this.dirtyTabs});

  @override
  State<_BatchSaveDialog> createState() => _BatchSaveDialogState();
}

class _BatchSaveDialogState extends State<_BatchSaveDialog> {
  late final Map<String, bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {for (final t in widget.dirtyTabs) t.id: true};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      title: const Text(
        'Unsaved Changes',
        style: TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The following tabs have unsaved changes:',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.dirtyTabs.map((tab) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: CodeOpsColors.primary,
                  checkColor: CodeOpsColors.textPrimary,
                  title: Text(
                    tab.title,
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  value: _selected[tab.id] ?? false,
                  onChanged: (val) {
                    setState(() => _selected[tab.id] = val ?? false);
                  },
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const ScribeBatchSaveResult(action: ScribeSaveAction.cancel),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const ScribeBatchSaveResult(action: ScribeSaveAction.dontSave),
          ),
          child: const Text(
            "Don't Save",
            style: TextStyle(color: CodeOpsColors.error),
          ),
        ),
        FilledButton(
          onPressed: () {
            final selectedIds = _selected.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList();
            Navigator.of(context).pop(
              ScribeBatchSaveResult(
                action: ScribeSaveAction.save,
                selectedTabIds: selectedIds,
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
          ),
          child: const Text('Save Selected'),
        ),
      ],
    );
  }
}
