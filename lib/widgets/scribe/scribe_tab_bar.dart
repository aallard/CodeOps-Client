/// A horizontal scrollable tab bar for the Scribe editor.
///
/// Displays open file tabs with dirty indicators, close buttons,
/// context menus, drag-to-reorder, a sidebar toggle, and a "+"
/// button to create new tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scribe_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import 'scribe_tab_item.dart';

/// A horizontal scrollable tab bar for the Scribe editor.
///
/// Supports tab selection, closing, right-click context menus with
/// 7 actions, drag-to-reorder, and sidebar toggle.
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

  /// Callback to close all tabs except the specified one.
  final ValueChanged<String>? onCloseOthers;

  /// Callback to close all tabs.
  final VoidCallback? onCloseAll;

  /// Callback to close all tabs to the right of the specified one.
  final ValueChanged<String>? onCloseToRight;

  /// Callback to close all saved (non-dirty) tabs.
  final VoidCallback? onCloseSaved;

  /// Callback to copy the file path of the specified tab.
  final ValueChanged<String>? onCopyFilePath;

  /// Callback to reveal the specified tab's file in Finder.
  final ValueChanged<String>? onRevealInFinder;

  /// Callback to start a comparison with the specified tab.
  final ValueChanged<String>? onCompareWith;

  /// Callback when tabs are reordered via drag-drop.
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Callback to toggle the sidebar.
  final VoidCallback? onToggleSidebar;

  /// Whether the sidebar is currently visible.
  final bool sidebarVisible;

  /// Callback to open the New File dialog (long-press on "+" button).
  final VoidCallback? onNewFileDialog;

  /// Callback to open the URL dialog (long-press on "+" button).
  final VoidCallback? onOpenUrl;

  /// Creates a [ScribeTabBar].
  const ScribeTabBar({
    super.key,
    required this.tabs,
    this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
    this.onCloseOthers,
    this.onCloseAll,
    this.onCloseToRight,
    this.onCloseSaved,
    this.onCopyFilePath,
    this.onRevealInFinder,
    this.onCompareWith,
    this.onReorder,
    this.onToggleSidebar,
    this.sidebarVisible = false,
    this.onNewFileDialog,
    this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: AppConstants.scribeTabBarHeight,
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          if (onToggleSidebar != null)
            _SidebarToggle(
              isOpen: sidebarVisible,
              onPressed: onToggleSidebar!,
            ),
          Expanded(
            child: _buildTabList(),
          ),
          _NewTabButton(
            onPressed: onNewTab,
            onNewFileDialog: onNewFileDialog,
            onOpenUrl: onOpenUrl,
          ),
        ],
      ),
    );
  }

  /// Builds a [ScribeTabItem] for the given [tab].
  ScribeTabItem _buildTabItem(ScribeTab tab) {
    return ScribeTabItem(
      tab: tab,
      isActive: tab.id == activeTabId,
      onSelected: () => onTabSelected(tab.id),
      onClosed: () => onTabClosed(tab.id),
      onCloseOthers:
          onCloseOthers != null ? () => onCloseOthers!(tab.id) : null,
      onCloseAll: onCloseAll,
      onCloseToRight:
          onCloseToRight != null ? () => onCloseToRight!(tab.id) : null,
      onCloseSaved: onCloseSaved,
      onCopyFilePath:
          onCopyFilePath != null ? () => onCopyFilePath!(tab.id) : null,
      onRevealInFinder:
          onRevealInFinder != null ? () => onRevealInFinder!(tab.id) : null,
      onCompareWith:
          onCompareWith != null ? () => onCompareWith!(tab.id) : null,
      hasOtherTabs: tabs.length > 1,
    );
  }

  /// Builds the tab list with optional drag-to-reorder support.
  Widget _buildTabList() {
    if (onReorder != null) {
      return ReorderableListView(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        onReorder: onReorder!,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 4,
            color: Colors.transparent,
            child: child,
          );
        },
        children: [
          for (var i = 0; i < tabs.length; i++)
            ReorderableDragStartListener(
              key: ValueKey(tabs[i].id),
              index: i,
              child: _buildTabItem(tabs[i]),
            ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) _buildTabItem(tab),
        ],
      ),
    );
  }
}

/// Toggle button for the sidebar visibility.
class _SidebarToggle extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onPressed;

  const _SidebarToggle({
    required this.isOpen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.scribeTabBarHeight,
      height: AppConstants.scribeTabBarHeight,
      child: IconButton(
        icon: Icon(
          Icons.vertical_split,
          size: 16,
          color: isOpen ? CodeOpsColors.primary : CodeOpsColors.textSecondary,
        ),
        onPressed: onPressed,
        tooltip: isOpen ? 'Hide sidebar' : 'Show sidebar',
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// The "+" button at the end of the tab bar.
///
/// Tap to create a new untitled tab. Long-press to show a popup menu
/// with "New File..." and "Open from URL..." options.
class _NewTabButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onNewFileDialog;
  final VoidCallback? onOpenUrl;

  const _NewTabButton({
    required this.onPressed,
    this.onNewFileDialog,
    this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (onNewFileDialog != null || onOpenUrl != null)
          ? (details) => _showMenu(context, details.globalPosition)
          : null,
      child: SizedBox(
        width: AppConstants.scribeTabBarHeight,
        height: AppConstants.scribeTabBarHeight,
        child: IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: onPressed,
          color: CodeOpsColors.textSecondary,
          tooltip: 'New tab (long-press for more)',
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: CodeOpsColors.surface,
      items: [
        if (onNewFileDialog != null)
          const PopupMenuItem<String>(
            value: 'newFile',
            child: Text(
              'New File...',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        if (onOpenUrl != null)
          const PopupMenuItem<String>(
            value: 'openUrl',
            child: Text(
              'Open from URL...',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
      ],
    ).then((value) {
      if (value == 'newFile') {
        onNewFileDialog?.call();
      } else if (value == 'openUrl') {
        onOpenUrl?.call();
      }
    });
  }
}
