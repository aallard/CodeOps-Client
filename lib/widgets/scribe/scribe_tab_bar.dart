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

/// A horizontal scrollable tab bar for the Scribe editor.
///
/// Supports tab selection, closing, right-click context menus,
/// drag-to-reorder, and sidebar toggle.
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

  /// Callback when tabs are reordered via drag-drop.
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Callback to toggle the sidebar.
  final VoidCallback? onToggleSidebar;

  /// Whether the sidebar is currently visible.
  final bool sidebarVisible;

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
    this.onReorder,
    this.onToggleSidebar,
    this.sidebarVisible = false,
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
          _NewTabButton(onPressed: onNewTab),
        ],
      ),
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
              child: _TabChip(
                tab: tabs[i],
                isActive: tabs[i].id == activeTabId,
                onSelected: () => onTabSelected(tabs[i].id),
                onClosed: () => onTabClosed(tabs[i].id),
                onCloseOthers: onCloseOthers != null
                    ? () => onCloseOthers!(tabs[i].id)
                    : null,
                onCloseAll: onCloseAll,
              ),
            ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs)
            _TabChip(
              tab: tab,
              isActive: tab.id == activeTabId,
              onSelected: () => onTabSelected(tab.id),
              onClosed: () => onTabClosed(tab.id),
              onCloseOthers: onCloseOthers != null
                  ? () => onCloseOthers!(tab.id)
                  : null,
              onCloseAll: onCloseAll,
            ),
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

/// A single tab chip within the tab bar.
class _TabChip extends StatelessWidget {
  final ScribeTab tab;
  final bool isActive;
  final VoidCallback onSelected;
  final VoidCallback onClosed;
  final VoidCallback? onCloseOthers;
  final VoidCallback? onCloseAll;

  const _TabChip({
    required this.tab,
    required this.isActive,
    required this.onSelected,
    required this.onClosed,
    this.onCloseOthers,
    this.onCloseAll,
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

  /// Shows the right-click context menu.
  void _showContextMenu(BuildContext context, TapUpDetails details) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      color: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      items: [
        const PopupMenuItem(
          value: 'close',
          height: 32,
          child: Text('Close', style: TextStyle(fontSize: 13)),
        ),
        if (onCloseOthers != null)
          const PopupMenuItem(
            value: 'closeOthers',
            height: 32,
            child: Text('Close Others', style: TextStyle(fontSize: 13)),
          ),
        if (onCloseAll != null)
          const PopupMenuItem(
            value: 'closeAll',
            height: 32,
            child: Text('Close All', style: TextStyle(fontSize: 13)),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'close':
          onClosed();
        case 'closeOthers':
          onCloseOthers?.call();
        case 'closeAll':
          onCloseAll?.call();
      }
    });
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
