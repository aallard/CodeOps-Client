// Riverpod providers for user preferences.
//
// Exposes typed StateProviders for every preference, backed by
// the local Drift database via PreferencesService.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/mcp_providers.dart';
import '../services/preferences/preferences_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the [PreferencesService] singleton.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final db = ref.watch(databaseProvider);
  final mcpApi = ref.watch(mcpApiProvider);
  return PreferencesService(db: db, mcpApi: mcpApi);
});

// ─────────────────────────────────────────────────────────────────────────────
// Appearance
// ─────────────────────────────────────────────────────────────────────────────

/// Theme mode preference: system, light, or dark.
final themePreferenceProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Accent color preference.
final accentColorProvider =
    StateProvider<Color>((ref) => const Color(0xFF6C63FF));

/// Font size preference.
final fontSizePreferenceProvider =
    StateProvider<FontSizePreference>((ref) => FontSizePreference.medium);

/// Sidebar position: left or right.
final sidebarPositionProvider =
    StateProvider<SidebarPosition>((ref) => SidebarPosition.left);

// ─────────────────────────────────────────────────────────────────────────────
// Editor (Scribe)
// ─────────────────────────────────────────────────────────────────────────────

/// Editor tab size.
final editorTabSizeProvider = StateProvider<int>((ref) => 4);

/// Whether word wrap is enabled in the editor.
final editorWordWrapProvider = StateProvider<bool>((ref) => true);

/// Whether line numbers are shown in the editor.
final editorLineNumbersProvider = StateProvider<bool>((ref) => true);

/// Whether the minimap is shown in the editor.
final editorMinimapProvider = StateProvider<bool>((ref) => false);

/// Auto-save interval in seconds (0 = off).
final editorAutoSaveProvider = StateProvider<int>((ref) => 15);

/// Default language for new editor tabs.
final editorDefaultLanguageProvider =
    StateProvider<String>((ref) => 'plaintext');

// ─────────────────────────────────────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────────────────────────────────────

/// Sidebar module order (top-level modules only).
final sidebarOrderProvider = StateProvider<List<String>>((ref) {
  return const [
    'vault',
    'registry',
    'fleet',
    'courier',
    'datalens',
    'logger',
    'relay',
    'mcp',
  ];
});

/// Default landing page route.
final defaultLandingProvider = StateProvider<String>((ref) => '/');

/// Link open behavior.
final openLinksInNewTabProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Notifications (Relay)
// ─────────────────────────────────────────────────────────────────────────────

/// Whether desktop notifications are enabled.
final desktopNotificationsProvider = StateProvider<bool>((ref) => true);

/// Whether notification sounds are enabled.
final notificationSoundProvider = StateProvider<bool>((ref) => true);

/// DM notification level.
final dmNotificationLevelProvider =
    StateProvider<DmNotificationLevel>((ref) => DmNotificationLevel.always);

/// Quiet hours start (hour of day, 0-23).
final quietHoursStartProvider = StateProvider<int>((ref) => 22);

/// Quiet hours end (hour of day, 0-23).
final quietHoursEndProvider = StateProvider<int>((ref) => 7);

/// Whether quiet hours are enabled.
final quietHoursEnabledProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Module Defaults
// ─────────────────────────────────────────────────────────────────────────────

/// Logger default time range.
final loggerDefaultTimeRangeProvider =
    StateProvider<String>((ref) => '1h');

/// Logger default log level filter.
final loggerDefaultLevelProvider =
    StateProvider<String>((ref) => 'ALL');

/// Courier default environment.
final courierDefaultEnvProvider =
    StateProvider<String>((ref) => 'none');

/// Whether to auto-start default workstation on app launch.
final fleetAutoStartProvider = StateProvider<bool>((ref) => false);

/// Whether DataLens auto-connects on launch.
final datalensAutoConnectProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Font size options.
enum FontSizePreference {
  /// Smaller text (12px base).
  small,

  /// Default text (14px base).
  medium,

  /// Larger text (16px base).
  large;

  /// Returns the base body font size for this preference.
  double get bodySize => switch (this) {
        FontSizePreference.small => 12.0,
        FontSizePreference.medium => 14.0,
        FontSizePreference.large => 16.0,
      };
}

/// Sidebar position options.
enum SidebarPosition {
  /// Sidebar on the left (default).
  left,

  /// Sidebar on the right.
  right,
}

/// DM notification level options.
enum DmNotificationLevel {
  /// Always notify for DMs.
  always,

  /// Only notify for mentions.
  mentionsOnly,

  /// Never notify for DMs.
  off,
}

/// Predefined accent color palette.
const List<Color> accentColorPalette = [
  Color(0xFF6C63FF), // Indigo (default)
  Color(0xFF3B82F6), // Blue
  Color(0xFF06B6D4), // Cyan
  Color(0xFF14B8A6), // Teal
  Color(0xFF4ADE80), // Green
  Color(0xFFFBBF24), // Amber
  Color(0xFFF97316), // Orange
  Color(0xFFEF4444), // Red
  Color(0xFFA855F7), // Purple
  Color(0xFFEC4899), // Pink
];
