/// Collapsible sidebar showing open files in the Scribe editor.
///
/// Displays a list of open tabs with language-based file icons, file
/// names, and dirty indicators. Clicking a file activates it in the
/// editor. Width is ~220px, collapsible to 0 via a toggle in the tab bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scribe_models.dart';
import '../../theme/colors.dart';

/// Collapsible sidebar for the Scribe editor.
///
/// Shows a list of open files with language-based file icons, file names,
/// and dirty indicators. Clicking a file activates it in the editor.
class ScribeSidebar extends ConsumerWidget {
  /// The list of open tabs.
  final List<ScribeTab> tabs;

  /// The ID of the currently active tab.
  final String? activeTabId;

  /// Callback when a tab is selected from the sidebar.
  final ValueChanged<String> onTabSelected;

  /// Creates a [ScribeSidebar].
  const ScribeSidebar({
    super.key,
    required this.tabs,
    this.activeTabId,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 220,
      color: CodeOpsColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: const Text(
              'OPEN FILES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          // File list
          Expanded(
            child: ListView.builder(
              itemCount: tabs.length,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = tab.id == activeTabId;
                return _SidebarFileItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => onTabSelected(tab.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A single file entry in the sidebar.
class _SidebarFileItem extends StatelessWidget {
  final ScribeTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarFileItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: isActive ? const Color(0x1A6C63FF) : null,
        child: Row(
          children: [
            Icon(
              _iconForLanguage(tab.language),
              size: 14,
              color: isActive
                  ? CodeOpsColors.primary
                  : CodeOpsColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
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
            if (tab.isDirty)
              const Text(
                '\u25CF',
                style: TextStyle(fontSize: 8, color: CodeOpsColors.warning),
              ),
          ],
        ),
      ),
    );
  }

  /// Returns an icon based on the language type.
  IconData _iconForLanguage(String language) {
    return switch (language) {
      'dart' => Icons.flutter_dash,
      'html' || 'xml' => Icons.web,
      'css' => Icons.style,
      'json' || 'yaml' || 'toml' => Icons.settings,
      'markdown' => Icons.article,
      'sql' => Icons.storage,
      'shell' || 'bash' => Icons.terminal,
      'dockerfile' => Icons.dns,
      _ => Icons.code,
    };
  }
}
