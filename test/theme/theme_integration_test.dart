// Tests for AppTheme light/dark theme generation and accent color.
//
// Verifies that darkTheme, lightTheme, darkThemeWith, and lightThemeWith
// produce correct ThemeData with expected brightness and color scheme.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/theme/colors.dart';

void main() {
  group('AppTheme', () {
    test('darkTheme has dark brightness', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
    });

    test('darkTheme uses CodeOpsColors.primary', () {
      final theme = AppTheme.darkTheme;

      expect(theme.colorScheme.primary, CodeOpsColors.primary);
    });

    test('lightTheme has light brightness', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
    });

    test('lightTheme uses CodeOpsColors.primary', () {
      final theme = AppTheme.lightTheme;

      expect(theme.colorScheme.primary, CodeOpsColors.primary);
    });

    test('darkThemeWith applies custom accent color', () {
      const accent = Color(0xFFEF4444);

      final theme = AppTheme.darkThemeWith(accentColor: accent);

      expect(theme.colorScheme.primary, accent);
      expect(theme.brightness, Brightness.dark);
    });

    test('darkThemeWith with null falls back to default primary', () {
      final theme = AppTheme.darkThemeWith();

      expect(theme.colorScheme.primary, CodeOpsColors.primary);
    });

    test('lightThemeWith applies custom accent color', () {
      const accent = Color(0xFF14B8A6);

      final theme = AppTheme.lightThemeWith(accentColor: accent);

      expect(theme.colorScheme.primary, accent);
      expect(theme.brightness, Brightness.light);
    });

    test('lightThemeWith with null falls back to default primary', () {
      final theme = AppTheme.lightThemeWith();

      expect(theme.colorScheme.primary, CodeOpsColors.primary);
    });
  });
}
