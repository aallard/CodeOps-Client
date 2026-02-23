/// A single tab chip widget for the Scribe tab bar.
///
/// Displays the tab title, dirty indicator, close button, and active
/// highlight. Right-click opens the [ScribeTabContextMenu].
library;

import 'package:flutter/material.dart';

import '../../models/scribe_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import 'scribe_tab_context_menu.dart';

/// A single tab chip in the Scribe tab bar.
///
/// Shows the tab [tab] title with a dirty dot indicator when modified,
/// a close button, and an active underline when [isActive]. Right-click
/// opens the enhanced context menu via [ScribeTabContextMenu].
class ScribeTabItem extends StatelessWidget {
  /// The tab data to display.
  final ScribeTab tab;

  /// Whether this tab is the currently active tab.
  final bool isActive;

  /// Callback when the tab is clicked (selected).
  final VoidCallback onSelected;

  /// Callback when the close button is clicked.
  final VoidCallback onClosed;

  /// Callback to close all other tabs.
  final VoidCallback? onCloseOthers;

  /// Callback to close all tabs.
  final VoidCallback? onCloseAll;

  /// Callback to close tabs to the right of this one.
  final VoidCallback? onCloseToRight;

  /// Callback to close all saved (non-dirty) tabs.
  final VoidCallback? onCloseSaved;

  /// Callback to copy the file path to clipboard.
  final VoidCallback? onCopyFilePath;

  /// Callback to reveal the file in Finder.
  final VoidCallback? onRevealInFinder;

  /// Callback to start a comparison with this tab.
  final VoidCallback? onCompareWith;

  /// Whether there are other tabs available for comparison.
  final bool hasOtherTabs;

  /// Creates a [ScribeTabItem].
  const ScribeTabItem({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onSelected,
    required this.onClosed,
    this.onCloseOthers,
    this.onCloseAll,
    this.onCloseToRight,
    this.onCloseSaved,
    this.onCopyFilePath,
    this.onRevealInFinder,
    this.onCompareWith,
    this.hasOtherTabs = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      onSecondaryTapUp: (details) => _showContextMenu(context, details),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppConstants.scribeTabMinWidth,
          maxWidth: AppConstants.scribeTabMaxWidth,
        ),
        height: AppConstants.scribeTabBarHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? CodeOpsColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                tab.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? CodeOpsColors.textPrimary
                      : CodeOpsColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (tab.isDirty) ...[
              const SizedBox(width: 4),
              const Text(
                '\u25CF',
                style: TextStyle(
                  fontSize: 8,
                  color: CodeOpsColors.warning,
                ),
              ),
            ],
            const SizedBox(width: 4),
            SizedBox(
              width: 16,
              height: 16,
              child: IconButton(
                icon: const Icon(Icons.close, size: 12),
                onPressed: onClosed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: CodeOpsColors.textTertiary,
                tooltip: 'Close tab',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the enhanced context menu on right-click.
  void _showContextMenu(BuildContext context, TapUpDetails details) {
    ScribeTabContextMenu.show(
      context,
      position: details.globalPosition,
      filePath: tab.filePath,
      onClose: onClosed,
      onCloseOthers: onCloseOthers,
      onCloseAll: onCloseAll,
      onCloseToRight: onCloseToRight,
      onCloseSaved: onCloseSaved,
      onCopyFilePath: onCopyFilePath,
      onRevealInFinder: onRevealInFinder,
      onCompareWith: onCompareWith,
      hasOtherTabs: hasOtherTabs,
    );
  }
}
