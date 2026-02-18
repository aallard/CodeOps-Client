/// Riverpod providers for Scribe editor state management.
///
/// Manages open tabs, active tab selection, editor settings, and
/// session persistence for the Scribe code editor.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scribe_models.dart';
import '../services/data/scribe_persistence_service.dart';
import 'auth_providers.dart';

// ---------------------------------------------------------------------------
// State Providers (mutable UI state)
// ---------------------------------------------------------------------------

/// The list of currently open tabs.
///
/// Initialized empty; populated from Drift on first access via
/// [scribeInitProvider].
final scribeTabsProvider = StateProvider<List<ScribeTab>>((ref) => []);

/// The ID of the currently active (visible) tab, or null if no tabs open.
final activeScribeTabIdProvider = StateProvider<String?>((ref) => null);

/// The auto-incrementing counter for "Untitled-N" tab names.
final scribeUntitledCounterProvider = StateProvider<int>((ref) => 1);

/// Editor settings (font size, tab size, word wrap, etc.).
///
/// Persisted to Drift on change via [ScribePersistenceService].
final scribeSettingsProvider = StateProvider<ScribeSettings>((ref) {
  return const ScribeSettings();
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
// Persistence Providers
// ---------------------------------------------------------------------------

/// Scribe persistence service — singleton for saving/loading session state.
final scribePersistenceProvider = Provider<ScribePersistenceService>((ref) {
  final db = ref.watch(databaseProvider);
  return ScribePersistenceService(db);
});

/// Loads persisted tabs and settings on first access.
///
/// Used to initialize [scribeTabsProvider] and [scribeSettingsProvider]
/// from the local database on app startup.
final scribeInitProvider = FutureProvider<void>((ref) async {
  final persistence = ref.read(scribePersistenceProvider);
  final tabs = await persistence.loadTabs();
  final settings = await persistence.loadSettings();

  if (tabs.isNotEmpty) {
    ref.read(scribeTabsProvider.notifier).state = tabs;
    ref.read(activeScribeTabIdProvider.notifier).state = tabs.first.id;
    // Set untitled counter to max existing untitled number + 1.
    final maxUntitled = tabs
        .where((t) => t.title.startsWith('Untitled-'))
        .map((t) => int.tryParse(t.title.replaceFirst('Untitled-', '')) ?? 0)
        .fold(0, (int a, int b) => a > b ? a : b);
    ref.read(scribeUntitledCounterProvider.notifier).state = maxUntitled + 1;
  }

  ref.read(scribeSettingsProvider.notifier).state = settings;
});
