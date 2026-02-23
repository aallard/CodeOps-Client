/// Riverpod providers for Scribe editor state management.
///
/// Manages open tabs, active tab selection, editor settings, and
/// session persistence for the Scribe code editor.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/scribe_models.dart';
import '../services/data/scribe_persistence_service.dart';
import '../utils/constants.dart';
import 'auth_providers.dart';

// ---------------------------------------------------------------------------
// Persistence Providers
// ---------------------------------------------------------------------------

/// Scribe persistence service — singleton for saving/loading session state.
final scribePersistenceProvider = Provider<ScribePersistenceService>((ref) {
  final db = ref.watch(databaseProvider);
  return ScribePersistenceService(db);
});

// ---------------------------------------------------------------------------
// State Providers (simple mutable UI state)
// ---------------------------------------------------------------------------

/// The ID of the currently active (visible) tab, or null if no tabs open.
final activeScribeTabIdProvider = StateProvider<String?>((ref) => null);

/// The auto-incrementing counter for "Untitled-N" tab names.
final scribeUntitledCounterProvider = StateProvider<int>((ref) => 1);

/// Whether the Scribe sidebar is visible.
final scribeSidebarVisibleProvider = StateProvider<bool>((ref) => false);

/// Stack of recently closed tabs for Ctrl+Shift+T reopen.
///
/// Capped at [ScribeTabsNotifier.maxClosedHistory] entries.
/// Newest entries are at the end of the list.
final scribeClosedTabHistoryProvider =
    StateProvider<List<ScribeTab>>((ref) => []);

// ---------------------------------------------------------------------------
// StateNotifier Providers (complex state with methods)
// ---------------------------------------------------------------------------

/// Manages the list of open editor tabs with full persistence.
///
/// All mutations are persisted to the local Drift database via
/// [ScribePersistenceService].
final scribeTabsProvider =
    StateNotifierProvider<ScribeTabsNotifier, List<ScribeTab>>((ref) {
  return ScribeTabsNotifier(
    ref.watch(scribePersistenceProvider),
    ref,
  );
});

/// Manages editor settings with persistence.
///
/// Settings are persisted to the local Drift database on every change.
final scribeSettingsProvider =
    StateNotifierProvider<ScribeSettingsNotifier, ScribeSettings>((ref) {
  return ScribeSettingsNotifier(
    ref.watch(scribePersistenceProvider),
  );
});

// ---------------------------------------------------------------------------
// Computed Providers (derived state)
// ---------------------------------------------------------------------------

/// The currently active tab, or null if no tabs are open.
///
/// Derived from [scribeTabsProvider] and [activeScribeTabIdProvider].
final activeScribeTabProvider = Provider<ScribeTab?>((ref) {
  final tabs = ref.watch(scribeTabsProvider);
  final activeId = ref.watch(activeScribeTabIdProvider);
  if (activeId == null || tabs.isEmpty) return null;
  return tabs.where((t) => t.id == activeId).firstOrNull;
});

/// Whether any open tab has unsaved changes.
final scribeHasUnsavedChangesProvider = Provider<bool>((ref) {
  final tabs = ref.watch(scribeTabsProvider);
  return tabs.any((t) => t.isDirty);
});

/// The total number of open tabs.
final scribeTabCountProvider = Provider<int>((ref) {
  return ref.watch(scribeTabsProvider).length;
});

// ---------------------------------------------------------------------------
// Initialization Provider
// ---------------------------------------------------------------------------

/// Loads persisted tabs and settings on first access.
///
/// Used to initialize [scribeTabsProvider] and [scribeSettingsProvider]
/// from the local database on app startup.
final scribeInitProvider = FutureProvider<void>((ref) async {
  await ref.read(scribeTabsProvider.notifier).loadFromPersistence();
  await ref.read(scribeSettingsProvider.notifier).loadFromPersistence();

  final tabs = ref.read(scribeTabsProvider);
  if (tabs.isNotEmpty) {
    ref.read(activeScribeTabIdProvider.notifier).state = tabs.first.id;
    // Set untitled counter to max existing untitled number + 1.
    final maxUntitled = tabs
        .where((t) => t.title.startsWith('Untitled-'))
        .map((t) => int.tryParse(t.title.replaceFirst('Untitled-', '')) ?? 0)
        .fold(0, (int a, int b) => a > b ? a : b);
    ref.read(scribeUntitledCounterProvider.notifier).state = maxUntitled + 1;
  }
});

// ---------------------------------------------------------------------------
// ScribeTabsNotifier
// ---------------------------------------------------------------------------

/// Notifier that manages the list of open editor tabs.
///
/// Handles opening, closing, reordering tabs and persists all changes
/// to the local database via [ScribePersistenceService].
class ScribeTabsNotifier extends StateNotifier<List<ScribeTab>> {
  final ScribePersistenceService _persistence;
  final Ref _ref;

  /// Maximum number of closed tabs retained in history.
  static const int maxClosedHistory = 20;

  /// Creates a [ScribeTabsNotifier].
  ScribeTabsNotifier(this._persistence, this._ref) : super([]);

  /// Loads tabs from the local database.
  Future<void> loadFromPersistence() async {
    state = await _persistence.loadTabs();
  }

  /// Opens a new tab or activates an existing one with the same [filePath].
  ///
  /// Generates a unique ID, sets the new tab as active, and persists.
  void openTab({
    required String title,
    String content = '',
    String language = 'plaintext',
    String? filePath,
  }) {
    // If a tab with the same filePath already exists, activate it.
    if (filePath != null) {
      final existing = state.where((t) => t.filePath == filePath).firstOrNull;
      if (existing != null) {
        _ref.read(activeScribeTabIdProvider.notifier).state = existing.id;
        return;
      }
    }

    final now = DateTime.now();
    final tab = ScribeTab(
      id: const Uuid().v4(),
      title: title,
      filePath: filePath,
      content: content,
      language: language,
      createdAt: now,
      lastModifiedAt: now,
    );

    state = [...state, tab];
    _ref.read(activeScribeTabIdProvider.notifier).state = tab.id;
    _persist();
  }

  /// Closes the tab with the given [tabId].
  ///
  /// Pushes the closed tab onto the closed-tab history stack for
  /// later reopening. If the closed tab was active, activates the
  /// adjacent tab.
  void closeTab(String tabId) {
    final index = state.indexWhere((t) => t.id == tabId);
    if (index < 0) return;

    _pushToClosedHistory([state[index]]);

    final newTabs = [...state]..removeAt(index);
    state = newTabs;

    final activeId = _ref.read(activeScribeTabIdProvider);
    if (activeId == tabId) {
      if (newTabs.isEmpty) {
        _ref.read(activeScribeTabIdProvider.notifier).state = null;
      } else {
        final newIndex = index.clamp(0, newTabs.length - 1);
        _ref.read(activeScribeTabIdProvider.notifier).state =
            newTabs[newIndex].id;
      }
    }

    _persist();
  }

  /// Updates the content of the tab with [tabId] and marks it dirty.
  void updateContent(String tabId, String content) {
    final index = state.indexWhere((t) => t.id == tabId);
    if (index < 0) return;

    final updated = state[index].copyWith(
      content: content,
      isDirty: true,
      lastModifiedAt: DateTime.now(),
    );
    state = [...state]..[index] = updated;
    _persist();
  }

  /// Marks the tab with [tabId] as clean (saved).
  void markClean(String tabId) {
    final index = state.indexWhere((t) => t.id == tabId);
    if (index < 0) return;

    final updated = state[index].copyWith(isDirty: false);
    state = [...state]..[index] = updated;
    _persist();
  }

  /// Reorders tabs by moving from [oldIndex] to [newIndex].
  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.length ||
        newIndex < 0 ||
        newIndex > state.length) {
      return;
    }

    final adjustedNew = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final tabs = [...state];
    final tab = tabs.removeAt(oldIndex);
    tabs.insert(adjustedNew, tab);
    state = tabs;
    _persist();
  }

  /// Closes all open tabs.
  ///
  /// All tabs are pushed to the closed-tab history before clearing.
  void closeAllTabs() {
    _pushToClosedHistory(state);
    state = [];
    _ref.read(activeScribeTabIdProvider.notifier).state = null;
    _persist();
  }

  /// Closes all tabs except the one with [tabId].
  ///
  /// Removed tabs are pushed to the closed-tab history.
  void closeOtherTabs(String tabId) {
    final tab = state.where((t) => t.id == tabId).firstOrNull;
    if (tab == null) return;

    final removed = state.where((t) => t.id != tabId).toList();
    _pushToClosedHistory(removed);

    state = [tab];
    _ref.read(activeScribeTabIdProvider.notifier).state = tabId;
    _persist();
  }

  /// Closes all tabs to the right of the tab with [tabId].
  ///
  /// Removed tabs are pushed to the closed-tab history. If [tabId] is
  /// the last tab (or not found), this is a no-op.
  void closeTabsToRight(String tabId) {
    final index = state.indexWhere((t) => t.id == tabId);
    if (index < 0 || index >= state.length - 1) return;

    final removed = state.sublist(index + 1);
    _pushToClosedHistory(removed);

    state = state.sublist(0, index + 1);

    // If the active tab was among those removed, activate the kept tab.
    final activeId = _ref.read(activeScribeTabIdProvider);
    if (activeId != null && !state.any((t) => t.id == activeId)) {
      _ref.read(activeScribeTabIdProvider.notifier).state = state.last.id;
    }

    _persist();
  }

  /// Closes all tabs that are not dirty (have no unsaved changes).
  ///
  /// Removed tabs are pushed to the closed-tab history.
  void closeSavedTabs() {
    final saved = state.where((t) => !t.isDirty).toList();
    if (saved.isEmpty) return;

    _pushToClosedHistory(saved);

    final remaining = state.where((t) => t.isDirty).toList();
    state = remaining;

    final activeId = _ref.read(activeScribeTabIdProvider);
    if (activeId != null && !state.any((t) => t.id == activeId)) {
      _ref.read(activeScribeTabIdProvider.notifier).state =
          state.isNotEmpty ? state.first.id : null;
    }

    _persist();
  }

  /// Reopens the most recently closed tab from history.
  ///
  /// Pops the last entry from [scribeClosedTabHistoryProvider], adds it
  /// back to the tab list, and activates it. No-op if history is empty.
  void reopenLastClosed() {
    final history = _ref.read(scribeClosedTabHistoryProvider);
    if (history.isEmpty) return;

    final tab = history.last;
    _ref.read(scribeClosedTabHistoryProvider.notifier).state =
        history.sublist(0, history.length - 1);

    state = [...state, tab];
    _ref.read(activeScribeTabIdProvider.notifier).state = tab.id;
    _persist();
  }

  /// Pushes [tabs] onto the closed-tab history stack, capped at
  /// [maxClosedHistory].
  void _pushToClosedHistory(List<ScribeTab> tabs) {
    if (tabs.isEmpty) return;
    final history = [..._ref.read(scribeClosedTabHistoryProvider), ...tabs];
    final capped = history.length > maxClosedHistory
        ? history.sublist(history.length - maxClosedHistory)
        : history;
    _ref.read(scribeClosedTabHistoryProvider.notifier).state = capped;
  }

  /// Changes the syntax highlighting language for the tab with [tabId].
  void updateLanguage(String tabId, String language) {
    final index = state.indexWhere((t) => t.id == tabId);
    if (index < 0) return;

    final updated = state[index].copyWith(language: language);
    state = [...state]..[index] = updated;
    _persist();
  }

  void _persist() {
    _persistence.saveTabs(state);
  }
}

// ---------------------------------------------------------------------------
// ScribeSettingsNotifier
// ---------------------------------------------------------------------------

/// Notifier that manages editor settings with persistence.
///
/// All settings changes are persisted to the local Drift database.
class ScribeSettingsNotifier extends StateNotifier<ScribeSettings> {
  final ScribePersistenceService _persistence;

  /// Creates a [ScribeSettingsNotifier].
  ScribeSettingsNotifier(this._persistence) : super(const ScribeSettings());

  /// Loads settings from the local database.
  Future<void> loadFromPersistence() async {
    state = await _persistence.loadSettings();
  }

  /// Updates the font size, clamped to the valid range.
  void updateFontSize(double fontSize) {
    state = state.copyWith(
      fontSize: fontSize.clamp(
        AppConstants.scribeMinFontSize,
        AppConstants.scribeMaxFontSize,
      ),
    );
    _persist();
  }

  /// Sets the tab width (2, 4, or 8).
  void updateTabSize(int tabSize) {
    if (tabSize != 2 && tabSize != 4 && tabSize != 8) return;
    state = state.copyWith(tabSize: tabSize);
    _persist();
  }

  /// Toggles word wrap on/off.
  void toggleWordWrap() {
    state = state.copyWith(wordWrap: !state.wordWrap);
    _persist();
  }

  /// Toggles line numbers on/off.
  void toggleLineNumbers() {
    state = state.copyWith(showLineNumbers: !state.showLineNumbers);
    _persist();
  }

  /// Toggles the minimap on/off.
  void toggleMinimap() {
    state = state.copyWith(showMinimap: !state.showMinimap);
    _persist();
  }

  /// Sets the theme mode ("dark" or "light").
  void setThemeMode(String mode) {
    if (mode != 'dark' && mode != 'light') return;
    state = state.copyWith(themeMode: mode);
    _persist();
  }

  void _persist() {
    _persistence.saveSettings(state);
  }
}
