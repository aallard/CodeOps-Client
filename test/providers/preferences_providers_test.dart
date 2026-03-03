// Tests for preferences providers.
//
// Verifies default values and state updates for all preference providers,
// enum values, and the accent color palette.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/preferences_providers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Appearance providers
  // ---------------------------------------------------------------------------
  group('Appearance providers', () {
    test('themePreferenceProvider defaults to ThemeMode.dark', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themePreferenceProvider), ThemeMode.dark);
    });

    test('themePreferenceProvider can be changed to light', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themePreferenceProvider.notifier).state = ThemeMode.light;

      expect(container.read(themePreferenceProvider), ThemeMode.light);
    });

    test('accentColorProvider defaults to indigo (0xFF6C63FF)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(accentColorProvider), const Color(0xFF6C63FF));
    });

    test('accentColorProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(accentColorProvider.notifier).state =
          const Color(0xFF3B82F6);

      expect(container.read(accentColorProvider), const Color(0xFF3B82F6));
    });

    test('fontSizePreferenceProvider defaults to medium', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(fontSizePreferenceProvider),
        FontSizePreference.medium,
      );
    });

    test('sidebarPositionProvider defaults to left', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sidebarPositionProvider), SidebarPosition.left);
    });
  });

  // ---------------------------------------------------------------------------
  // Editor providers
  // ---------------------------------------------------------------------------
  group('Editor providers', () {
    test('editorTabSizeProvider defaults to 4', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editorTabSizeProvider), 4);
    });

    test('editorWordWrapProvider defaults to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editorWordWrapProvider), true);
    });

    test('editorLineNumbersProvider defaults to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editorLineNumbersProvider), true);
    });

    test('editorMinimapProvider defaults to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editorMinimapProvider), false);
    });

    test('editorAutoSaveProvider defaults to 15', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editorAutoSaveProvider), 15);
    });

    test('editorDefaultLanguageProvider defaults to plaintext', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editorDefaultLanguageProvider), 'plaintext');
    });
  });

  // ---------------------------------------------------------------------------
  // Navigation providers
  // ---------------------------------------------------------------------------
  group('Navigation providers', () {
    test('sidebarOrderProvider defaults to 8 modules', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = container.read(sidebarOrderProvider);

      expect(order.length, 8);
      expect(order.first, 'vault');
      expect(order.last, 'mcp');
    });

    test('sidebarOrderProvider can be reordered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sidebarOrderProvider.notifier).state = [
        'mcp',
        'vault',
        'registry',
        'fleet',
        'courier',
        'datalens',
        'logger',
        'relay',
      ];

      expect(container.read(sidebarOrderProvider).first, 'mcp');
    });

    test('defaultLandingProvider defaults to /', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(defaultLandingProvider), '/');
    });

    test('openLinksInNewTabProvider defaults to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(openLinksInNewTabProvider), false);
    });
  });

  // ---------------------------------------------------------------------------
  // Notification providers
  // ---------------------------------------------------------------------------
  group('Notification providers', () {
    test('desktopNotificationsProvider defaults to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(desktopNotificationsProvider), true);
    });

    test('notificationSoundProvider defaults to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(notificationSoundProvider), true);
    });

    test('dmNotificationLevelProvider defaults to always', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(dmNotificationLevelProvider),
        DmNotificationLevel.always,
      );
    });

    test('quietHoursEnabledProvider defaults to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(quietHoursEnabledProvider), false);
    });

    test('quietHoursStartProvider defaults to 22', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(quietHoursStartProvider), 22);
    });

    test('quietHoursEndProvider defaults to 7', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(quietHoursEndProvider), 7);
    });
  });

  // ---------------------------------------------------------------------------
  // Module defaults
  // ---------------------------------------------------------------------------
  group('Module default providers', () {
    test('loggerDefaultTimeRangeProvider defaults to 1h', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(loggerDefaultTimeRangeProvider), '1h');
    });

    test('loggerDefaultLevelProvider defaults to ALL', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(loggerDefaultLevelProvider), 'ALL');
    });

    test('courierDefaultEnvProvider defaults to none', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierDefaultEnvProvider), 'none');
    });

    test('fleetAutoStartProvider defaults to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(fleetAutoStartProvider), false);
    });

    test('datalensAutoConnectProvider defaults to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(datalensAutoConnectProvider), false);
    });
  });

  // ---------------------------------------------------------------------------
  // Enums
  // ---------------------------------------------------------------------------
  group('FontSizePreference', () {
    test('bodySize returns correct values', () {
      expect(FontSizePreference.small.bodySize, 12.0);
      expect(FontSizePreference.medium.bodySize, 14.0);
      expect(FontSizePreference.large.bodySize, 16.0);
    });
  });

  group('Accent color palette', () {
    test('contains 10 colors', () {
      expect(accentColorPalette.length, 10);
    });

    test('first color is indigo default', () {
      expect(accentColorPalette.first, const Color(0xFF6C63FF));
    });
  });
}
