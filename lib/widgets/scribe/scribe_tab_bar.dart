/// A horizontal scrollable tab bar for the Scribe editor.
///
/// Displays open file tabs with dirty indicators, close buttons, and
/// a "+" button to create new tabs. Supports tab selection and closing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scribe_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A horizontal scrollable tab bar for the Scribe editor.
///
/// Displays open file tabs with dirty indicators, close buttons, and
/// a "+" button to create new tabs. Supports reordering in future
/// (CS-003 will add drag-drop reorder).
class ScribeTabBar extends ConsumerWidget {
  /// The list of open tabs to display.
  final List<ScribeTab> tabs;

  /// The ID of the currently active tab.
  final String? activeTabId;

  /// Callback when a tab is selected.
  final ValueChanged<String> onTabSelected;

  /// Callback when a tab's close button is clicked.
  final ValueChanged<String> onTabClosed;

  /// Callback when the "+" (new tab) button is clicked.
  final VoidCallback onNewTab;

  /// Creates a [ScribeTabBar].
  const ScribeTabBar({
    super.key,
    required this.tabs,
    this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: AppConstants.scribeTabBarHeight,
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tab in tabs)
                    _TabChip(
                      tab: tab,
                      isActive: tab.id == activeTabId,
                      onSelected: () => onTabSelected(tab.id),
                      onClosed: () => onTabClosed(tab.id),
                    ),
                ],
              ),
            ),
          ),
          _NewTabButton(onPressed: onNewTab),
        ],
      ),
    );
  }
}

/// A single tab chip within the tab bar.
class _TabChip extends StatelessWidget {
  final ScribeTab tab;
  final bool isActive;
  final VoidCallback onSelected;
  final VoidCallback onClosed;

  const _TabChip({
    required this.tab,
    required this.isActive,
    required this.onSelected,
    required this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
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
}

/// The "+" button at the end of the tab bar.
class _NewTabButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewTabButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.scribeTabBarHeight,
      height: AppConstants.scribeTabBarHeight,
      child: IconButton(
        icon: const Icon(Icons.add, size: 18),
        onPressed: onPressed,
        color: CodeOpsColors.textSecondary,
        tooltip: 'New tab',
        padding: EdgeInsets.zero,
      ),
    );
  }
}
