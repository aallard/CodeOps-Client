/// Service for persisting and restoring Scribe editor session state.
///
/// Manages saving open tabs and settings to the local Drift database
/// so they survive app restarts. All operations are async and non-blocking.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/database.dart' hide ScribeTab;
import '../../database/database.dart' as db show ScribeTab;
import '../../models/scribe_models.dart';

/// Persists and restores Scribe editor session state.
///
/// Saves open tabs and editor settings to the local Drift database.
/// Loaded on app startup to restore the previous editing session.
class ScribePersistenceService {
  /// The Drift database instance.
  final CodeOpsDatabase _database;

  /// Creates a [ScribePersistenceService] with the given [database].
  ScribePersistenceService(CodeOpsDatabase database) : _database = database;

  /// Loads all persisted tabs, ordered by [displayOrder].
  Future<List<ScribeTab>> loadTabs() async {
    final rows = await (_database.select(_database.scribeTabs)
          ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
        .get();
    return rows.map(_rowToTab).toList();
  }

  /// Saves all current tabs (replaces all existing persisted tabs).
  Future<void> saveTabs(List<ScribeTab> tabs) async {
    await _database.transaction(() async {
      await _database.delete(_database.scribeTabs).go();
      for (var i = 0; i < tabs.length; i++) {
        await _database.into(_database.scribeTabs).insert(
              _tabToCompanion(tabs[i], i),
            );
      }
    });
  }

  /// Saves a single tab (upsert by id).
  Future<void> saveTab(ScribeTab tab, int displayOrder) async {
    await _database.into(_database.scribeTabs).insertOnConflictUpdate(
          _tabToCompanion(tab, displayOrder),
        );
  }

  /// Removes a tab from persistence.
  Future<void> removeTab(String tabId) async {
    await (_database.delete(_database.scribeTabs)
          ..where((t) => t.id.equals(tabId)))
        .go();
  }

  /// Clears all persisted tabs.
  Future<void> clearTabs() async {
    await _database.delete(_database.scribeTabs).go();
  }

  /// Loads editor settings, returning defaults if none are persisted.
  Future<ScribeSettings> loadSettings() async {
    final row = await (_database.select(_database.scribeSettings)
          ..where((t) => t.key.equals('editor_settings')))
        .getSingleOrNull();
    if (row == null) return const ScribeSettings();
    return ScribeSettings.fromJson(
      jsonDecode(row.value) as Map<String, dynamic>,
    );
  }

  /// Saves editor settings.
  Future<void> saveSettings(ScribeSettings settings) async {
    await _database.into(_database.scribeSettings).insertOnConflictUpdate(
          ScribeSettingsCompanion.insert(
            key: 'editor_settings',
            value: jsonEncode(settings.toJson()),
          ),
        );
  }

  /// Converts a Drift row to a [ScribeTab].
  ScribeTab _rowToTab(db.ScribeTab row) {
    return ScribeTab(
      id: row.id,
      title: row.title,
      filePath: row.filePath,
      content: row.content,
      language: row.language,
      isDirty: row.isDirty,
      cursorLine: row.cursorLine,
      cursorColumn: row.cursorColumn,
      scrollOffset: row.scrollOffset,
      createdAt: row.createdAt,
      lastModifiedAt: row.lastModifiedAt,
    );
  }

  /// Converts a [ScribeTab] to a Drift companion for insertion.
  ScribeTabsCompanion _tabToCompanion(ScribeTab tab, int displayOrder) {
    return ScribeTabsCompanion.insert(
      id: tab.id,
      title: tab.title,
      filePath: Value(tab.filePath),
      content: tab.content,
      language: tab.language,
      isDirty: Value(tab.isDirty),
      cursorLine: Value(tab.cursorLine),
      cursorColumn: Value(tab.cursorColumn),
      scrollOffset: Value(tab.scrollOffset),
      displayOrder: displayOrder,
      createdAt: tab.createdAt,
      lastModifiedAt: tab.lastModifiedAt,
    );
  }
}
