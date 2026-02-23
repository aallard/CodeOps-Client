/// Right-click context menu for Scribe tab items.
///
/// Provides 7 actions: Close, Close Others, Close All, Close to the Right,
/// Close Saved, Copy File Path, and Reveal in Finder.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Right-click context menu for a Scribe tab.
///
/// Shows a popup menu with close actions, file path operations, and
/// keyboard shortcut hints. Use the static [show] method to display.
class ScribeTabContextMenu {
  ScribeTabContextMenu._();

  /// Displays the tab context menu at the given [position].
  ///
  /// [filePath] controls whether "Copy File Path" and "Reveal in Finder"
  /// are enabled. Actions are dispatched via the provided callbacks.
  static Future<void> show(
    BuildContext context, {
    required Offset position,
    required VoidCallback onClose,
    VoidCallback? onCloseOthers,
    VoidCallback? onCloseAll,
    VoidCallback? onCloseToRight,
    VoidCallback? onCloseSaved,
    VoidCallback? onCopyFilePath,
    VoidCallback? onRevealInFinder,
    VoidCallback? onCompareWith,
    String? filePath,
    bool hasOtherTabs = false,
  }) async {
    final hasFilePath = filePath != null;

    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      items: [
        _menuItem('close', 'Close', shortcut: 'Ctrl+W'),
        if (onCloseOthers != null)
          _menuItem('closeOthers', 'Close Others'),
        if (onCloseAll != null) _menuItem('closeAll', 'Close All'),
        if (onCloseToRight != null)
          _menuItem('closeToRight', 'Close to the Right'),
        if (onCloseSaved != null) _menuItem('closeSaved', 'Close Saved'),
        const PopupMenuDivider(height: 8),
        _menuItem(
          'copyPath',
          'Copy File Path',
          enabled: hasFilePath,
        ),
        _menuItem(
          'revealInFinder',
          'Reveal in Finder',
          enabled: hasFilePath,
        ),
        if (onCompareWith != null) ...[
          const PopupMenuDivider(height: 8),
          _menuItem(
            'compareWith',
            'Compare with...',
            enabled: hasOtherTabs,
          ),
        ],
      ],
    );

    switch (value) {
      case 'close':
        onClose();
      case 'closeOthers':
        onCloseOthers?.call();
      case 'closeAll':
        onCloseAll?.call();
      case 'closeToRight':
        onCloseToRight?.call();
      case 'closeSaved':
        onCloseSaved?.call();
      case 'copyPath':
        onCopyFilePath?.call();
      case 'revealInFinder':
        onRevealInFinder?.call();
      case 'compareWith':
        onCompareWith?.call();
    }
  }

  /// Creates a styled [PopupMenuItem] with an optional shortcut hint.
  static PopupMenuItem<String> _menuItem(
    String value,
    String label, {
    String? shortcut,
    bool enabled = true,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 32,
      enabled: enabled,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: enabled
                  ? CodeOpsColors.textPrimary
                  : CodeOpsColors.textTertiary,
            ),
          ),
          if (shortcut != null)
            Text(
              shortcut,
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
