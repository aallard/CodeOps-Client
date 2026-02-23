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
import '../widgets/scribe/scribe_save_dialog.dart';
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
        const SingleActivator(LogicalKeyboardKey.keyW, control: true):
            _handleCloseActiveTab,
        const SingleActivator(LogicalKeyboardKey.tab, control: true):
            _handleNextTab,
        const SingleActivator(LogicalKeyboardKey.tab,
            control: true, shift: true): _handlePrevTab,
        const SingleActivator(LogicalKeyboardKey.keyT,
            control: true, shift: true): _handleReopenLastClosed,
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
                onCloseToRight: _handleCloseToRight,
                onCloseSaved: _handleCloseSavedTabs,
                onCopyFilePath: _handleCopyFilePath,
                onRevealInFinder: _handleRevealInFinder,
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

  // ---------------------------------------------------------------------------
  // Tab creation
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Tab selection
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Keyboard shortcuts — tab navigation
  // ---------------------------------------------------------------------------

  /// Cycles to the next tab (wraps around).
  void _handleNextTab() {
    final tabs = ref.read(scribeTabsProvider);
    if (tabs.length < 2) return;

    final activeId = ref.read(activeScribeTabIdProvider);
    final currentIndex = tabs.indexWhere((t) => t.id == activeId);
    final nextIndex = (currentIndex + 1) % tabs.length;
    _handleTabSelected(tabs[nextIndex].id);
  }

  /// Cycles to the previous tab (wraps around).
  void _handlePrevTab() {
    final tabs = ref.read(scribeTabsProvider);
    if (tabs.length < 2) return;

    final activeId = ref.read(activeScribeTabIdProvider);
    final currentIndex = tabs.indexWhere((t) => t.id == activeId);
    final prevIndex = (currentIndex - 1 + tabs.length) % tabs.length;
    _handleTabSelected(tabs[prevIndex].id);
  }

  // ---------------------------------------------------------------------------
  // Tab closing — with save confirmation for dirty tabs
  // ---------------------------------------------------------------------------

  /// Closes the active tab via Ctrl+W.
  void _handleCloseActiveTab() {
    final activeId = ref.read(activeScribeTabIdProvider);
    if (activeId != null) {
      _handleTabClosed(activeId);
    }
  }

  /// Closes a single tab. Shows save confirmation if dirty.
  Future<void> _handleTabClosed(String tabId) async {
    final tab =
        ref.read(scribeTabsProvider).where((t) => t.id == tabId).firstOrNull;
    if (tab == null) return;

    if (tab.isDirty) {
      if (!mounted) return;
      final action = await ScribeSaveDialog.show(context, tab: tab);
      switch (action) {
        case ScribeSaveAction.save:
          await _saveTab(tab);
          ref.read(scribeTabsProvider.notifier).closeTab(tabId);
        case ScribeSaveAction.dontSave:
          ref.read(scribeTabsProvider.notifier).closeTab(tabId);
        case ScribeSaveAction.cancel:
          return;
      }
    } else {
      ref.read(scribeTabsProvider.notifier).closeTab(tabId);
    }
  }

  /// Closes all tabs except the specified one. Shows batch save dialog
  /// if any tabs being removed are dirty.
  Future<void> _handleCloseOtherTabs(String tabId) async {
    final tabs = ref.read(scribeTabsProvider);
    final dirtyOthers =
        tabs.where((t) => t.id != tabId && t.isDirty).toList();

    if (dirtyOthers.isNotEmpty) {
      if (!mounted) return;
      final result = await ScribeSaveDialog.showBatch(
        context,
        dirtyTabs: dirtyOthers,
      );
      switch (result.action) {
        case ScribeSaveAction.save:
          for (final id in result.selectedTabIds) {
            final t = tabs.where((t) => t.id == id).firstOrNull;
            if (t != null) await _saveTab(t);
          }
          ref.read(scribeTabsProvider.notifier).closeOtherTabs(tabId);
        case ScribeSaveAction.dontSave:
          ref.read(scribeTabsProvider.notifier).closeOtherTabs(tabId);
        case ScribeSaveAction.cancel:
          return;
      }
    } else {
      ref.read(scribeTabsProvider.notifier).closeOtherTabs(tabId);
    }
  }

  /// Closes all tabs. Shows batch save dialog if any are dirty.
  Future<void> _handleCloseAllTabs() async {
    final tabs = ref.read(scribeTabsProvider);
    final dirtyTabs = tabs.where((t) => t.isDirty).toList();

    if (dirtyTabs.isNotEmpty) {
      if (!mounted) return;
      final result = await ScribeSaveDialog.showBatch(
        context,
        dirtyTabs: dirtyTabs,
      );
      switch (result.action) {
        case ScribeSaveAction.save:
          for (final id in result.selectedTabIds) {
            final t = tabs.where((t) => t.id == id).firstOrNull;
            if (t != null) await _saveTab(t);
          }
          ref.read(scribeTabsProvider.notifier).closeAllTabs();
        case ScribeSaveAction.dontSave:
          ref.read(scribeTabsProvider.notifier).closeAllTabs();
        case ScribeSaveAction.cancel:
          return;
      }
    } else {
      ref.read(scribeTabsProvider.notifier).closeAllTabs();
    }
  }

  /// Closes all tabs to the right of the specified one.
  Future<void> _handleCloseToRight(String tabId) async {
    final tabs = ref.read(scribeTabsProvider);
    final index = tabs.indexWhere((t) => t.id == tabId);
    if (index < 0 || index >= tabs.length - 1) return;

    final rightTabs = tabs.sublist(index + 1);
    final dirtyRight = rightTabs.where((t) => t.isDirty).toList();

    if (dirtyRight.isNotEmpty) {
      if (!mounted) return;
      final result = await ScribeSaveDialog.showBatch(
        context,
        dirtyTabs: dirtyRight,
      );
      switch (result.action) {
        case ScribeSaveAction.save:
          for (final id in result.selectedTabIds) {
            final t = tabs.where((t) => t.id == id).firstOrNull;
            if (t != null) await _saveTab(t);
          }
          ref.read(scribeTabsProvider.notifier).closeTabsToRight(tabId);
        case ScribeSaveAction.dontSave:
          ref.read(scribeTabsProvider.notifier).closeTabsToRight(tabId);
        case ScribeSaveAction.cancel:
          return;
      }
    } else {
      ref.read(scribeTabsProvider.notifier).closeTabsToRight(tabId);
    }
  }

  /// Closes all saved (non-dirty) tabs. No dialog needed.
  void _handleCloseSavedTabs() {
    ref.read(scribeTabsProvider.notifier).closeSavedTabs();
  }

  /// Reopens the most recently closed tab via Ctrl+Shift+T.
  void _handleReopenLastClosed() {
    ref.read(scribeTabsProvider.notifier).reopenLastClosed();
  }

  // ---------------------------------------------------------------------------
  // File path operations
  // ---------------------------------------------------------------------------

  /// Copies the file path of the given tab to the clipboard.
  void _handleCopyFilePath(String tabId) {
    final tab =
        ref.read(scribeTabsProvider).where((t) => t.id == tabId).firstOrNull;
    if (tab?.filePath == null) return;
    Clipboard.setData(ClipboardData(text: tab!.filePath!));
  }

  /// Reveals the tab's file in Finder (macOS) or file manager.
  void _handleRevealInFinder(String tabId) {
    final tab =
        ref.read(scribeTabsProvider).where((t) => t.id == tabId).firstOrNull;
    if (tab?.filePath == null) return;

    if (Platform.isMacOS) {
      Process.run('open', ['-R', tab!.filePath!]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [File(tab!.filePath!).parent.path]);
    }
  }

  // ---------------------------------------------------------------------------
  // Tab reordering and sidebar
  // ---------------------------------------------------------------------------

  /// Reorders tabs via drag-drop.
  void _handleReorderTabs(int oldIndex, int newIndex) {
    ref.read(scribeTabsProvider.notifier).reorderTabs(oldIndex, newIndex);
  }

  /// Toggles the sidebar visibility.
  void _handleToggleSidebar() {
    ref.read(scribeSidebarVisibleProvider.notifier).state =
        !ref.read(scribeSidebarVisibleProvider);
  }

  // ---------------------------------------------------------------------------
  // Editor callbacks
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Save helper
  // ---------------------------------------------------------------------------

  /// Saves the tab content to its file path, or does nothing for untitled tabs.
  Future<void> _saveTab(ScribeTab tab) async {
    if (tab.filePath == null) return;
    await File(tab.filePath!).writeAsString(tab.content);
    ref.read(scribeTabsProvider.notifier).markClean(tab.id);
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
