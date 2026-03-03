// Preferences service for local persistence and server sync.
//
// Reads/writes user preferences to the Drift database and
// syncs them to the server via DeveloperProfile.preferencesJson.
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/database.dart';
import '../../services/cloud/mcp_api.dart';
import '../../services/logging/log_service.dart';

/// Service that manages user preferences with local persistence
/// and server synchronization.
///
/// Preferences are stored locally in the Drift [UserPreferencesTable]
/// for instant access. Changes are debounced (2 seconds) before
/// syncing to the server via [DeveloperProfile.preferencesJson].
class PreferencesService {
  final CodeOpsDatabase _db;
  final McpApiService _mcpApi;
  Timer? _syncTimer;
  String? _profileId;
  String? _teamId;

  /// Debounce duration before syncing to server.
  static const syncDebounce = Duration(seconds: 2);

  /// Creates a [PreferencesService] backed by [db] and [mcpApi].
  PreferencesService({
    required CodeOpsDatabase db,
    required McpApiService mcpApi,
  })  : _db = db,
        _mcpApi = mcpApi;

  /// Sets the active team and profile IDs for server sync.
  void setContext({required String? teamId, required String? profileId}) {
    _teamId = teamId;
    _profileId = profileId;
  }

  /// Loads all preferences from the local database.
  Future<Map<String, String>> loadAll() async {
    final rows = await _db.select(_db.userPreferencesTable).get();
    return {for (final r in rows) r.key: r.value};
  }

  /// Gets a single preference value, returning [defaultValue] if not found.
  Future<String> get(String key, String defaultValue) async {
    final row = await (_db.select(_db.userPreferencesTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? defaultValue;
  }

  /// Sets a single preference and schedules server sync.
  Future<void> set(String key, String value) async {
    await _db.into(_db.userPreferencesTable).insertOnConflictUpdate(
          UserPreferencesTableCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
    _scheduleSyncToServer();
  }

  /// Removes a single preference.
  Future<void> remove(String key) async {
    await (_db.delete(_db.userPreferencesTable)
          ..where((t) => t.key.equals(key)))
        .go();
    _scheduleSyncToServer();
  }

  /// Resets all preferences to empty (clears local table).
  Future<void> resetAll() async {
    await _db.delete(_db.userPreferencesTable).go();
    _scheduleSyncToServer();
  }

  /// Exports all preferences as a JSON-serializable map.
  Future<Map<String, dynamic>> exportAll() async {
    final prefs = await loadAll();
    return Map<String, dynamic>.from(prefs);
  }

  /// Imports preferences from a JSON map, replacing all local values.
  Future<void> importAll(Map<String, dynamic> prefs) async {
    await _db.transaction(() async {
      await _db.delete(_db.userPreferencesTable).go();
      final now = DateTime.now();
      for (final entry in prefs.entries) {
        await _db.into(_db.userPreferencesTable).insert(
              UserPreferencesTableCompanion(
                key: Value(entry.key),
                value: Value(entry.value.toString()),
                updatedAt: Value(now),
              ),
            );
      }
    });
    _scheduleSyncToServer();
  }

  /// Pushes all local preferences to the server DeveloperProfile.
  Future<void> syncToServer() async {
    if (_profileId == null) {
      log.w('PreferencesService', 'No profileId — cannot sync to server');
      return;
    }
    try {
      final prefs = await loadAll();
      final json = jsonEncode(prefs);
      await _mcpApi.updateProfile(_profileId!, {'preferencesJson': json});
      log.i('PreferencesService', 'Synced ${prefs.length} prefs to server');
    } catch (e) {
      log.e('PreferencesService', 'Failed to sync to server', e);
    }
  }

  /// Pulls preferences from the server and merges into local.
  ///
  /// Server values overwrite local on first launch.
  Future<void> syncFromServer() async {
    if (_teamId == null) {
      log.w('PreferencesService', 'No teamId — cannot sync from server');
      return;
    }
    try {
      final profile = await _mcpApi.getOrCreateProfile(teamId: _teamId!);
      _profileId = profile.id;
      final jsonStr = profile.preferencesJson;
      if (jsonStr == null || jsonStr.isEmpty) return;

      final serverPrefs = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (serverPrefs.isEmpty) return;

      await importAll(serverPrefs);
      log.i('PreferencesService',
          'Pulled ${serverPrefs.length} prefs from server');
    } catch (e) {
      log.e('PreferencesService', 'Failed to sync from server', e);
    }
  }

  void _scheduleSyncToServer() {
    _syncTimer?.cancel();
    _syncTimer = Timer(syncDebounce, syncToServer);
  }

  /// Cancels any pending sync timer.
  void dispose() {
    _syncTimer?.cancel();
  }
}
