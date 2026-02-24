/// Centralized shortcut registry for the Scribe editor.
///
/// Defines all keyboard shortcuts and commands in a single location,
/// providing platform-aware key bindings (Ctrl on Linux/Windows,
/// Cmd/Meta on macOS) and a unified command catalog for the command
/// palette.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A single command in the Scribe command registry.
///
/// Each command has an identifier, display label, category, optional
/// shortcut binding, and an optional description shown in the command
/// palette.
class ScribeCommand {
  /// Unique identifier for this command (e.g., `'file.new'`).
  final String id;

  /// Human-readable label shown in menus and the command palette.
  final String label;

  /// Category for grouping in the shortcuts help overlay.
  final ScribeCommandCategory category;

  /// The keyboard shortcut for this command, or `null` if there is
  /// no shortcut binding.
  final SingleActivator? shortcut;

  /// Optional description shown below the label in the command palette.
  final String? description;

  /// Creates a [ScribeCommand].
  const ScribeCommand({
    required this.id,
    required this.label,
    required this.category,
    this.shortcut,
    this.description,
  });

  /// Returns a human-readable string for the [shortcut], e.g.,
  /// `'Ctrl+Shift+P'` or `'Cmd+Shift+P'` on macOS.
  ///
  /// Returns an empty string if there is no shortcut.
  String get shortcutLabel {
    if (shortcut == null) return '';
    final parts = <String>[];
    if (shortcut!.meta) {
      parts.add('Cmd');
    } else if (shortcut!.control) {
      parts.add('Ctrl');
    }
    if (shortcut!.shift) parts.add('Shift');
    if (shortcut!.alt) parts.add('Alt');

    final keyLabel = _keyLabel(shortcut!.trigger);
    parts.add(keyLabel);
    return parts.join('+');
  }

  static String _keyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.slash) return '?';
    final label = key.keyLabel;
    if (label.length == 1) return label.toUpperCase();
    return label;
  }
}

/// Categories for grouping commands in the shortcuts help overlay.
enum ScribeCommandCategory {
  /// File operations (new, open, save, close).
  file('File'),

  /// Editor operations (find, replace, go to line).
  editor('Editor'),

  /// View operations (sidebar, preview, settings).
  view('View'),

  /// Tab navigation and management.
  tabs('Tabs');

  /// Human-readable display name for this category.
  final String displayName;

  const ScribeCommandCategory(this.displayName);
}

/// Whether the current platform is macOS.
final bool _isMacOS = Platform.isMacOS;

/// Creates a platform-aware [SingleActivator].
///
/// On macOS, maps `control: true` to `meta: true` (Cmd key).
/// On other platforms, uses `control: true` as-is.
SingleActivator _shortcut(
  LogicalKeyboardKey key, {
  bool control = false,
  bool shift = false,
  bool alt = false,
}) {
  return SingleActivator(
    key,
    control: control && !_isMacOS,
    meta: control && _isMacOS,
    shift: shift,
    alt: alt,
  );
}

/// Centralized registry of all Scribe keyboard shortcuts and commands.
///
/// Provides:
/// - A flat list of all commands via [commands].
/// - A map from [SingleActivator] to command ID via [shortcutBindings].
/// - Lookup by ID via [commandById].
/// - Grouped commands by category via [commandsByCategory].
class ScribeShortcutRegistry {
  ScribeShortcutRegistry._();

  // -------------------------------------------------------------------------
  // File commands
  // -------------------------------------------------------------------------

  /// Create a new untitled tab.
  static final newTab = ScribeCommand(
    id: 'file.new',
    label: 'New File',
    category: ScribeCommandCategory.file,
    shortcut: _shortcut(LogicalKeyboardKey.keyN, control: true),
    description: 'Create a new untitled tab',
  );

  /// Open a file from disk.
  static final openFile = ScribeCommand(
    id: 'file.open',
    label: 'Open File',
    category: ScribeCommandCategory.file,
    shortcut: _shortcut(LogicalKeyboardKey.keyO, control: true),
    description: 'Open a file from disk',
  );

  /// Open the New File dialog (with name and language picker).
  static final newFileDialog = ScribeCommand(
    id: 'file.newDialog',
    label: 'New File...',
    category: ScribeCommandCategory.file,
    shortcut: _shortcut(LogicalKeyboardKey.keyN, control: true, shift: true),
    description: 'Create a new file with name and language',
  );

  /// Open a file from a URL.
  static final openUrl = ScribeCommand(
    id: 'file.openUrl',
    label: 'Open from URL...',
    category: ScribeCommandCategory.file,
    description: 'Open a file from a remote URL',
  );

  /// Save the active tab.
  static final save = ScribeCommand(
    id: 'file.save',
    label: 'Save',
    category: ScribeCommandCategory.file,
    shortcut: _shortcut(LogicalKeyboardKey.keyS, control: true),
    description: 'Save the active file',
  );

  /// Save the active tab to a new path.
  static final saveAs = ScribeCommand(
    id: 'file.saveAs',
    label: 'Save As...',
    category: ScribeCommandCategory.file,
    shortcut: _shortcut(LogicalKeyboardKey.keyS, control: true, shift: true),
    description: 'Save the active file to a new location',
  );

  /// Save all dirty tabs.
  static final saveAll = ScribeCommand(
    id: 'file.saveAll',
    label: 'Save All',
    category: ScribeCommandCategory.file,
    shortcut: _shortcut(LogicalKeyboardKey.keyS, control: true, alt: true),
    description: 'Save all modified files',
  );

  // -------------------------------------------------------------------------
  // Editor commands
  // -------------------------------------------------------------------------

  /// Open the Find panel.
  static final find = ScribeCommand(
    id: 'editor.find',
    label: 'Find',
    category: ScribeCommandCategory.editor,
    shortcut: _shortcut(LogicalKeyboardKey.keyF, control: true),
    description: 'Find text in the current file',
  );

  /// Open the Find & Replace panel.
  static final findAndReplace = ScribeCommand(
    id: 'editor.findReplace',
    label: 'Find and Replace',
    category: ScribeCommandCategory.editor,
    shortcut: _shortcut(LogicalKeyboardKey.keyH, control: true),
    description: 'Find and replace text in the current file',
  );

  /// Open the Go to Line dialog.
  static final goToLine = ScribeCommand(
    id: 'editor.goToLine',
    label: 'Go to Line...',
    category: ScribeCommandCategory.editor,
    shortcut: _shortcut(LogicalKeyboardKey.keyG, control: true),
    description: 'Jump to a specific line number',
  );

  // -------------------------------------------------------------------------
  // View commands
  // -------------------------------------------------------------------------

  /// Toggle the sidebar.
  static final toggleSidebar = ScribeCommand(
    id: 'view.sidebar',
    label: 'Toggle Sidebar',
    category: ScribeCommandCategory.view,
    shortcut: _shortcut(LogicalKeyboardKey.keyB, control: true),
    description: 'Show or hide the file sidebar',
  );

  /// Toggle the markdown preview.
  static final togglePreview = ScribeCommand(
    id: 'view.preview',
    label: 'Toggle Preview',
    category: ScribeCommandCategory.view,
    shortcut: _shortcut(LogicalKeyboardKey.keyV, control: true, shift: true),
    description: 'Cycle editor/split/preview for markdown',
  );

  /// Toggle the recent files panel.
  static final toggleRecentFiles = ScribeCommand(
    id: 'view.recentFiles',
    label: 'Recent Files',
    category: ScribeCommandCategory.view,
    shortcut:
        _shortcut(LogicalKeyboardKey.keyO, control: true, shift: true),
    description: 'Show or hide the recent files panel',
  );

  /// Open the quick-open overlay.
  static final quickOpen = ScribeCommand(
    id: 'view.quickOpen',
    label: 'Quick Open',
    category: ScribeCommandCategory.view,
    shortcut: _shortcut(LogicalKeyboardKey.keyP, control: true),
    description: 'Quickly open a file by name',
  );

  /// Open the command palette.
  static final commandPalette = ScribeCommand(
    id: 'view.commandPalette',
    label: 'Command Palette',
    category: ScribeCommandCategory.view,
    shortcut: _shortcut(LogicalKeyboardKey.keyP, control: true, shift: true),
    description: 'Search and run any command',
  );

  /// Toggle the settings panel.
  static final toggleSettings = ScribeCommand(
    id: 'view.settings',
    label: 'Toggle Settings',
    category: ScribeCommandCategory.view,
    description: 'Show or hide the editor settings panel',
  );

  /// Show the keyboard shortcuts help overlay.
  static final showShortcutsHelp = ScribeCommand(
    id: 'view.shortcutsHelp',
    label: 'Keyboard Shortcuts',
    category: ScribeCommandCategory.view,
    shortcut: _shortcut(LogicalKeyboardKey.slash, control: true, shift: true),
    description: 'Show all keyboard shortcuts',
  );

  // -------------------------------------------------------------------------
  // Tab commands
  // -------------------------------------------------------------------------

  /// Close the active tab.
  static final closeTab = ScribeCommand(
    id: 'tabs.close',
    label: 'Close Tab',
    category: ScribeCommandCategory.tabs,
    shortcut: _shortcut(LogicalKeyboardKey.keyW, control: true),
    description: 'Close the active tab',
  );

  /// Switch to the next tab.
  static final nextTab = ScribeCommand(
    id: 'tabs.next',
    label: 'Next Tab',
    category: ScribeCommandCategory.tabs,
    shortcut: _shortcut(LogicalKeyboardKey.tab, control: true),
    description: 'Switch to the next tab',
  );

  /// Switch to the previous tab.
  static final prevTab = ScribeCommand(
    id: 'tabs.prev',
    label: 'Previous Tab',
    category: ScribeCommandCategory.tabs,
    shortcut: _shortcut(LogicalKeyboardKey.tab, control: true, shift: true),
    description: 'Switch to the previous tab',
  );

  /// Reopen the last closed tab.
  static final reopenClosed = ScribeCommand(
    id: 'tabs.reopen',
    label: 'Reopen Closed Tab',
    category: ScribeCommandCategory.tabs,
    shortcut: _shortcut(LogicalKeyboardKey.keyT, control: true, shift: true),
    description: 'Reopen the most recently closed tab',
  );

  /// Close all tabs.
  static final closeAllTabs = ScribeCommand(
    id: 'tabs.closeAll',
    label: 'Close All Tabs',
    category: ScribeCommandCategory.tabs,
    description: 'Close all open tabs',
  );

  /// Close saved (non-dirty) tabs.
  static final closeSavedTabs = ScribeCommand(
    id: 'tabs.closeSaved',
    label: 'Close Saved Tabs',
    category: ScribeCommandCategory.tabs,
    description: 'Close all tabs without unsaved changes',
  );

  // -------------------------------------------------------------------------
  // Aggregated lists
  // -------------------------------------------------------------------------

  /// All registered commands.
  static final List<ScribeCommand> commands = [
    // File
    newTab,
    openFile,
    newFileDialog,
    openUrl,
    save,
    saveAs,
    saveAll,
    // Editor
    find,
    findAndReplace,
    goToLine,
    // View
    toggleSidebar,
    togglePreview,
    toggleRecentFiles,
    quickOpen,
    commandPalette,
    toggleSettings,
    showShortcutsHelp,
    // Tabs
    closeTab,
    nextTab,
    prevTab,
    reopenClosed,
    closeAllTabs,
    closeSavedTabs,
  ];

  /// Map from command ID to [ScribeCommand].
  static final Map<String, ScribeCommand> _byId = {
    for (final cmd in commands) cmd.id: cmd,
  };

  /// Looks up a command by its [id].
  ///
  /// Returns `null` if no command with that ID exists.
  static ScribeCommand? commandById(String id) => _byId[id];

  /// Returns all commands that have a keyboard shortcut.
  static List<ScribeCommand> get shortcutCommands =>
      commands.where((c) => c.shortcut != null).toList();

  /// Returns commands grouped by [ScribeCommandCategory].
  static Map<ScribeCommandCategory, List<ScribeCommand>>
      get commandsByCategory {
    final map = <ScribeCommandCategory, List<ScribeCommand>>{};
    for (final cmd in commands) {
      map.putIfAbsent(cmd.category, () => []).add(cmd);
    }
    return map;
  }

  /// Builds a [CallbackShortcuts]-compatible bindings map.
  ///
  /// Maps each command's [SingleActivator] to the corresponding
  /// callback from [handlers]. Commands without shortcuts or
  /// without handlers are skipped.
  static Map<ShortcutActivator, VoidCallback> buildBindings(
    Map<String, VoidCallback> handlers,
  ) {
    final bindings = <ShortcutActivator, VoidCallback>{};
    for (final cmd in commands) {
      if (cmd.shortcut != null && handlers.containsKey(cmd.id)) {
        bindings[cmd.shortcut!] = handlers[cmd.id]!;
      }
    }
    return bindings;
  }
}
