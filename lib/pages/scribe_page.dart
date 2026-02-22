/// The Scribe page — a multi-tab code and text editor integrated into
/// the CodeOps desktop application.
///
/// Scribe provides syntax-highlighted editing for 30+ languages with
/// tabbed file management, session persistence, an optional sidebar,
/// and a status bar showing cursor position, language mode, and encoding.
///
/// This page is the standalone Scribe experience at the `/scribe` route.
/// The underlying [ScribeEditor] widget is also consumed by other Control
/// Plane modules (Courier, DataLens, Logger, Registry, Vault).
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scribe_models.dart';
import '../providers/scribe_providers.dart';
import '../theme/colors.dart';
import '../widgets/scribe/scribe_editor.dart';
import '../widgets/scribe/scribe_empty_state.dart';
import '../widgets/scribe/scribe_language.dart';
import '../widgets/scribe/scribe_sidebar.dart';
import '../widgets/scribe/scribe_status_bar.dart';
import '../widgets/scribe/scribe_tab_bar.dart';

/// The Scribe page — multi-tab code editor at `/scribe`.
class ScribePage extends ConsumerStatefulWidget {
  /// Creates a [ScribePage].
  const ScribePage({super.key});

  @override
  ConsumerState<ScribePage> createState() => _ScribePageState();
}

class _ScribePageState extends ConsumerState<ScribePage> {
  int _cursorLine = 0;
  int _cursorColumn = 0;

  @override
  void initState() {
    super.initState();
    // Trigger session restoration.
    Future.microtask(() => ref.read(scribeInitProvider));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(scribeTabsProvider);
    final activeTab = ref.watch(activeScribeTabProvider);
    final sidebarVisible = ref.watch(scribeSidebarVisibleProvider);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _handleNewTab,
        const SingleActivator(LogicalKeyboardKey.keyO, control: true):
            _handleOpenFile,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            if (tabs.isNotEmpty)
              ScribeTabBar(
                tabs: tabs,
                activeTabId: activeTab?.id,
                onTabSelected: _handleTabSelected,
                onTabClosed: _handleTabClosed,
                onNewTab: _handleNewTab,
                onCloseOthers: _handleCloseOtherTabs,
                onCloseAll: _handleCloseAllTabs,
                onReorder: _handleReorderTabs,
                onToggleSidebar: _handleToggleSidebar,
                sidebarVisible: sidebarVisible,
              ),
            if (tabs.isNotEmpty && activeTab != null)
              Expanded(
                child: Row(
                  children: [
                    if (sidebarVisible)
                      ScribeSidebar(
                        tabs: tabs,
                        activeTabId: activeTab.id,
                        onTabSelected: _handleTabSelected,
                      ),
                    if (sidebarVisible)
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: CodeOpsColors.border,
                      ),
                    Expanded(
                      child: _EditorArea(
                        key: ValueKey(activeTab.id),
                        tab: activeTab,
                        settings: ref.watch(scribeSettingsProvider),
                        onChanged: (value) =>
                            _handleContentChanged(activeTab, value),
                        onCursorChanged: _handleCursorChanged,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ScribeEmptyState(
                  onNewFile: _handleNewTab,
                  onOpenFile: _handleOpenFile,
                ),
              ),
            if (tabs.isNotEmpty && activeTab != null)
              ScribeStatusBar(
                cursorLine: _cursorLine,
                cursorColumn: _cursorColumn,
                language: activeTab.language,
                onLanguageChanged: (lang) =>
                    _handleLanguageChanged(activeTab, lang),
              ),
          ],
        ),
      ),
    );
  }

  /// Creates a new untitled tab.
  void _handleNewTab() {
    final counter = ref.read(scribeUntitledCounterProvider);
    ref.read(scribeUntitledCounterProvider.notifier).state = counter + 1;
    ref.read(scribeTabsProvider.notifier).openTab(
          title: 'Untitled-$counter',
        );
  }

  /// Opens a file picker and creates a tab from the selected file.
  Future<void> _handleOpenFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final content = await File(path).readAsString();
    final lastSlash = path.lastIndexOf('/');
    final fileName = lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
    final language = ScribeLanguage.fromFileName(path);

    ref.read(scribeTabsProvider.notifier).openTab(
          title: fileName,
          content: content,
          language: language,
          filePath: path,
        );
  }

  /// Switches to the selected tab.
  void _handleTabSelected(String tabId) {
    ref.read(activeScribeTabIdProvider.notifier).state = tabId;
    final tab =
        ref.read(scribeTabsProvider).where((t) => t.id == tabId).firstOrNull;
    if (tab != null) {
      setState(() {
        _cursorLine = tab.cursorLine;
        _cursorColumn = tab.cursorColumn;
      });
    }
  }

  /// Closes a tab via the notifier.
  void _handleTabClosed(String tabId) {
    ref.read(scribeTabsProvider.notifier).closeTab(tabId);
  }

  /// Closes all tabs except the specified one.
  void _handleCloseOtherTabs(String tabId) {
    ref.read(scribeTabsProvider.notifier).closeOtherTabs(tabId);
  }

  /// Closes all tabs.
  void _handleCloseAllTabs() {
    ref.read(scribeTabsProvider.notifier).closeAllTabs();
  }

  /// Reorders tabs via drag-drop.
  void _handleReorderTabs(int oldIndex, int newIndex) {
    ref.read(scribeTabsProvider.notifier).reorderTabs(oldIndex, newIndex);
  }

  /// Toggles the sidebar visibility.
  void _handleToggleSidebar() {
    ref.read(scribeSidebarVisibleProvider.notifier).state =
        !ref.read(scribeSidebarVisibleProvider);
  }

  /// Handles content changes from the editor.
  void _handleContentChanged(ScribeTab tab, String newContent) {
    ref.read(scribeTabsProvider.notifier).updateContent(tab.id, newContent);
  }

  /// Handles cursor position changes from the editor.
  void _handleCursorChanged(int line, int column) {
    setState(() {
      _cursorLine = line;
      _cursorColumn = column;
    });
  }

  /// Handles language mode changes from the status bar.
  void _handleLanguageChanged(ScribeTab tab, String newLanguage) {
    ref.read(scribeTabsProvider.notifier).updateLanguage(tab.id, newLanguage);
  }
}

/// The editor area that renders a [ScribeEditor] for the active tab.
class _EditorArea extends StatefulWidget {
  final ScribeTab tab;
  final ScribeSettings settings;
  final ValueChanged<String> onChanged;
  final void Function(int line, int column) onCursorChanged;

  const _EditorArea({
    super.key,
    required this.tab,
    required this.settings,
    required this.onChanged,
    required this.onCursorChanged,
  });

  @override
  State<_EditorArea> createState() => _EditorAreaState();
}

class _EditorAreaState extends State<_EditorArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.background,
      child: ScribeEditor(
        content: widget.tab.content,
        language: widget.tab.language,
        fontSize: widget.settings.fontSize,
        tabSize: widget.settings.tabSize,
        insertSpaces: widget.settings.insertSpaces,
        wordWrap: widget.settings.wordWrap,
        showLineNumbers: widget.settings.showLineNumbers,
        showMinimap: widget.settings.showMinimap,
        onChanged: widget.onChanged,
      ),
    );
  }
}
