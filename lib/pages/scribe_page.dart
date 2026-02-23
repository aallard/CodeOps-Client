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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scribe_models.dart';
import '../providers/scribe_providers.dart';
import '../services/logging/log_service.dart';
import '../theme/colors.dart';
import '../widgets/scribe/scribe_drop_target.dart';
import '../widgets/scribe/scribe_editor.dart';
import '../widgets/scribe/scribe_empty_state.dart';
import '../widgets/scribe/scribe_language.dart';
import '../widgets/scribe/scribe_save_dialog.dart';
import '../widgets/scribe/scribe_settings_panel.dart';
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
  static const String _tag = 'ScribePage';

  int _cursorLine = 0;
  int _cursorColumn = 0;

  Timer? _autoSaveTimer;
  bool _autoSaveEnabled = false;
  int _autoSaveIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    // Trigger session restoration.
    Future.microtask(() => ref.read(scribeInitProvider));
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(scribeTabsProvider);
    final activeTab = ref.watch(activeScribeTabProvider);
    final sidebarVisible = ref.watch(scribeSidebarVisibleProvider);
    final settingsPanelVisible =
        ref.watch(scribeSettingsPanelVisibleProvider);
    final settings = ref.watch(scribeSettingsProvider);

    // Manage auto-save timer when settings change.
    _updateAutoSaveTimer(settings);

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
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _handleSave,
        const SingleActivator(LogicalKeyboardKey.keyS,
            control: true, shift: true): _handleSaveAs,
        const SingleActivator(LogicalKeyboardKey.keyS,
            control: true, alt: true): _handleSaveAll,
      },
      child: Focus(
        autofocus: true,
        child: ScribeDropTarget(
          onFilesDropped: _handleFilesDropped,
          child: Column(
            children: [
              if (tabs.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: ScribeTabBar(
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
                    ),
                    _SettingsGearButton(
                      isActive: settingsPanelVisible,
                      onPressed: _handleToggleSettingsPanel,
                    ),
                  ],
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
                          settings: settings,
                          onChanged: (value) =>
                              _handleContentChanged(activeTab, value),
                          onCursorChanged: _handleCursorChanged,
                        ),
                      ),
                      if (settingsPanelVisible) ...[
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: CodeOpsColors.border,
                        ),
                        ScribeSettingsPanel(
                          onClose: _handleToggleSettingsPanel,
                        ),
                      ],
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

  /// Opens a file picker (multi-select) and creates tabs from selected files.
  Future<void> _handleOpenFile() async {
    final fileService = ref.read(scribeFileServiceProvider);
    final tabs = await fileService.openFiles();
    for (final tab in tabs) {
      ref.read(scribeTabsProvider.notifier).openTab(
            title: tab.title,
            content: tab.content,
            language: tab.language,
            filePath: tab.filePath,
          );
      if (tab.filePath != null) {
        await _trackRecentFile(tab.filePath!);
      }
    }
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
  // Save operations (CS-004)
  // ---------------------------------------------------------------------------

  /// Saves the active tab (Ctrl+S).
  ///
  /// If the tab has no file path, triggers Save As instead.
  void _handleSave() {
    final activeTab = ref.read(activeScribeTabProvider);
    if (activeTab == null) return;

    if (activeTab.filePath == null) {
      _handleSaveAs();
    } else {
      _saveTab(activeTab);
    }
  }

  /// Opens a Save As dialog for the active tab (Ctrl+Shift+S).
  void _handleSaveAs() {
    final activeTab = ref.read(activeScribeTabProvider);
    if (activeTab == null) return;
    _saveTabAs(activeTab);
  }

  /// Saves all dirty tabs (Ctrl+Alt+S).
  ///
  /// Tabs without a file path are skipped (they would need Save As).
  void _handleSaveAll() {
    final tabs = ref.read(scribeTabsProvider);
    for (final tab in tabs) {
      if (tab.isDirty && tab.filePath != null) {
        _saveTab(tab);
      }
    }
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
  // Drag and drop (CS-004)
  // ---------------------------------------------------------------------------

  /// Handles files dropped onto the Scribe editor.
  Future<void> _handleFilesDropped(List<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        final content = await file.readAsString();
        final tab = ScribeTab.fromFile(filePath: path, content: content);
        ref.read(scribeTabsProvider.notifier).openTab(
              title: tab.title,
              content: tab.content,
              language: tab.language,
              filePath: tab.filePath,
            );
        await _trackRecentFile(path);
      } on FormatException catch (e) {
        log.w(_tag, 'Skipping binary/unreadable dropped file: $path', e);
      } on FileSystemException catch (e) {
        log.w(_tag, 'Failed to read dropped file: $path', e);
      }
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

  /// Toggles the settings panel visibility.
  void _handleToggleSettingsPanel() {
    ref.read(scribeSettingsPanelVisibleProvider.notifier).state =
        !ref.read(scribeSettingsPanelVisibleProvider);
  }

  // ---------------------------------------------------------------------------
  // Auto-save (CS-005)
  // ---------------------------------------------------------------------------

  /// Updates the auto-save timer when settings change.
  ///
  /// Compares cached values to avoid unnecessary timer recreation.
  void _updateAutoSaveTimer(ScribeSettings settings) {
    if (settings.autoSave == _autoSaveEnabled &&
        settings.autoSaveIntervalSeconds == _autoSaveIntervalSeconds) {
      return;
    }

    _autoSaveEnabled = settings.autoSave;
    _autoSaveIntervalSeconds = settings.autoSaveIntervalSeconds;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;

    if (_autoSaveEnabled) {
      _autoSaveTimer = Timer.periodic(
        Duration(seconds: _autoSaveIntervalSeconds),
        (_) => _handleAutoSave(),
      );
    }
  }

  /// Saves all dirty tabs that have a file path (auto-save tick).
  void _handleAutoSave() {
    final tabs = ref.read(scribeTabsProvider);
    for (final tab in tabs) {
      if (tab.isDirty && tab.filePath != null) {
        _saveTab(tab);
      }
    }
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
  // Save helpers (CS-004)
  // ---------------------------------------------------------------------------

  /// Saves the tab content to its file path.
  ///
  /// If the tab has no file path, triggers Save As. On success, marks
  /// the tab clean and tracks the file in recent files.
  Future<void> _saveTab(ScribeTab tab) async {
    if (tab.filePath == null) {
      await _saveTabAs(tab);
      return;
    }

    final fileService = ref.read(scribeFileServiceProvider);
    final success = await fileService.saveFile(tab);
    if (success) {
      ref.read(scribeTabsProvider.notifier).markClean(tab.id);
      await _trackRecentFile(tab.filePath!);
    }
  }

  /// Opens a Save As dialog for [tab] and writes to the chosen path.
  ///
  /// Updates the tab's file path, title, and language on success.
  Future<void> _saveTabAs(ScribeTab tab) async {
    final fileService = ref.read(scribeFileServiceProvider);
    final newPath = await fileService.saveFileAs(tab);
    if (newPath == null) return;

    // Update tab with new file path and detected language.
    final language = ScribeLanguage.fromFileName(newPath);
    ref.read(scribeTabsProvider.notifier).updateTabFilePath(tab.id, newPath);
    ref.read(scribeTabsProvider.notifier).updateLanguage(tab.id, language);
    await _trackRecentFile(newPath);
  }

  /// Adds a file path to recent files and persists.
  Future<void> _trackRecentFile(String filePath) async {
    final fileService = ref.read(scribeFileServiceProvider);
    await fileService.addRecentFile(filePath);
    final updated = await fileService.loadRecentFiles();
    ref.read(scribeRecentFilesProvider.notifier).state = updated;
  }
}

/// Gear icon button to toggle the settings panel.
class _SettingsGearButton extends StatelessWidget {
  /// Whether the settings panel is currently open.
  final bool isActive;

  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  const _SettingsGearButton({
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(right: 8),
      color: CodeOpsColors.surface,
      child: IconButton(
        icon: Icon(
          Icons.settings,
          size: 16,
          color: isActive
              ? CodeOpsColors.primary
              : CodeOpsColors.textTertiary,
        ),
        onPressed: onPressed,
        splashRadius: 14,
        tooltip: 'Editor settings',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      ),
    );
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
        fontFamily: widget.settings.fontFamily,
        tabSize: widget.settings.tabSize,
        insertSpaces: widget.settings.insertSpaces,
        wordWrap: widget.settings.wordWrap,
        showLineNumbers: widget.settings.showLineNumbers,
        showMinimap: widget.settings.showMinimap,
        themeMode: widget.settings.themeMode,
        highlightActiveLine: widget.settings.highlightActiveLine,
        showBracketMatching: widget.settings.bracketMatching,
        autoCloseBrackets: widget.settings.autoCloseBrackets,
        onChanged: widget.onChanged,
      ),
    );
  }
}
