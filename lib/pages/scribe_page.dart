/// The Scribe page — a multi-tab code and text editor integrated into
/// the CodeOps desktop application.
///
/// Scribe provides syntax-highlighted editing for 30+ languages with
/// tabbed file management, session persistence, and a status bar showing
/// cursor position, language mode, and encoding.
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
              ),
            if (tabs.isNotEmpty && activeTab != null)
              Expanded(
                child: _EditorArea(
                  key: ValueKey(activeTab.id),
                  tab: activeTab,
                  settings: ref.watch(scribeSettingsProvider),
                  onChanged: (value) => _handleContentChanged(activeTab, value),
                  onCursorChanged: _handleCursorChanged,
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
    final tab = ScribeTab.untitled(counter);
    ref.read(scribeUntitledCounterProvider.notifier).state = counter + 1;

    final tabs = [...ref.read(scribeTabsProvider), tab];
    ref.read(scribeTabsProvider.notifier).state = tabs;
    ref.read(activeScribeTabIdProvider.notifier).state = tab.id;

    _persistTabs(tabs);
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
    final tab = ScribeTab.fromFile(filePath: path, content: content);

    final tabs = [...ref.read(scribeTabsProvider), tab];
    ref.read(scribeTabsProvider.notifier).state = tabs;
    ref.read(activeScribeTabIdProvider.notifier).state = tab.id;

    _persistTabs(tabs);
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

  /// Closes a tab and updates the active tab.
  void _handleTabClosed(String tabId) {
    final tabs = ref.read(scribeTabsProvider);
    final index = tabs.indexWhere((t) => t.id == tabId);
    if (index < 0) return;

    final newTabs = [...tabs]..removeAt(index);
    ref.read(scribeTabsProvider.notifier).state = newTabs;

    // Update active tab if the closed tab was active.
    final activeId = ref.read(activeScribeTabIdProvider);
    if (activeId == tabId) {
      if (newTabs.isEmpty) {
        ref.read(activeScribeTabIdProvider.notifier).state = null;
      } else {
        final newIndex = index.clamp(0, newTabs.length - 1);
        ref.read(activeScribeTabIdProvider.notifier).state =
            newTabs[newIndex].id;
      }
    }

    _persistTabs(newTabs);
  }

  /// Handles content changes from the editor.
  void _handleContentChanged(ScribeTab tab, String newContent) {
    final tabs = ref.read(scribeTabsProvider);
    final index = tabs.indexWhere((t) => t.id == tab.id);
    if (index < 0) return;

    final updated = tab.copyWith(
      content: newContent,
      isDirty: true,
      lastModifiedAt: DateTime.now(),
    );
    final newTabs = [...tabs]..[index] = updated;
    ref.read(scribeTabsProvider.notifier).state = newTabs;
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
    final tabs = ref.read(scribeTabsProvider);
    final index = tabs.indexWhere((t) => t.id == tab.id);
    if (index < 0) return;

    final updated = tab.copyWith(language: newLanguage);
    final newTabs = [...tabs]..[index] = updated;
    ref.read(scribeTabsProvider.notifier).state = newTabs;

    _persistTabs(newTabs);
  }

  /// Persists tabs to the database.
  void _persistTabs(List<ScribeTab> tabs) {
    final persistence = ref.read(scribePersistenceProvider);
    persistence.saveTabs(tabs);
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
