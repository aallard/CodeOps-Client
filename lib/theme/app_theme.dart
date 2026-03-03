/// CodeOps application theme.
///
/// Builds a complete [ThemeData] from [CodeOpsColors] and [CodeOpsTypography].
library;

import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Provides the CodeOps [ThemeData] for the application.
class AppTheme {
  AppTheme._();

  /// Builds a dark theme with a custom [accentColor].
  static ThemeData darkThemeWith({Color? accentColor}) {
    final primary = accentColor ?? CodeOpsColors.primary;
    return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(primary: primary),
    );
  }

  /// Builds a light theme for the CodeOps desktop app.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: CodeOpsTypography.fontFamily,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: CodeOpsColors.primary,
        onPrimary: Colors.white,
        secondary: CodeOpsColors.secondary,
        onSecondary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1E293B),
        error: CodeOpsColors.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: CodeOpsTypography.headlineLarge.copyWith(color: const Color(0xFF1E293B)),
        headlineMedium: CodeOpsTypography.headlineMedium.copyWith(color: const Color(0xFF1E293B)),
        headlineSmall: CodeOpsTypography.headlineSmall.copyWith(color: const Color(0xFF1E293B)),
        titleLarge: CodeOpsTypography.titleLarge.copyWith(color: const Color(0xFF1E293B)),
        titleMedium: CodeOpsTypography.titleMedium.copyWith(color: const Color(0xFF1E293B)),
        titleSmall: CodeOpsTypography.titleSmall.copyWith(color: const Color(0xFF1E293B)),
        bodyLarge: CodeOpsTypography.bodyLarge.copyWith(color: const Color(0xFF334155)),
        bodyMedium: CodeOpsTypography.bodyMedium.copyWith(color: const Color(0xFF334155)),
        bodySmall: CodeOpsTypography.bodySmall.copyWith(color: const Color(0xFF64748B)),
        labelLarge: CodeOpsTypography.labelLarge.copyWith(color: const Color(0xFF334155)),
        labelMedium: CodeOpsTypography.labelMedium.copyWith(color: const Color(0xFF64748B)),
        labelSmall: CodeOpsTypography.labelSmall.copyWith(color: const Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CodeOpsColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Builds a light theme with a custom [accentColor].
  static ThemeData lightThemeWith({Color? accentColor}) {
    final primary = accentColor ?? CodeOpsColors.primary;
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(primary: primary),
    );
  }

  /// The dark theme used by the CodeOps desktop app.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: CodeOpsTypography.fontFamily,
      scaffoldBackgroundColor: CodeOpsColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CodeOpsColors.primary,
        onPrimary: Colors.white,
        secondary: CodeOpsColors.secondary,
        onSecondary: Colors.black,
        surface: CodeOpsColors.surface,
        onSurface: CodeOpsColors.textPrimary,
        error: CodeOpsColors.error,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: CodeOpsTypography.headlineLarge,
        headlineMedium: CodeOpsTypography.headlineMedium,
        headlineSmall: CodeOpsTypography.headlineSmall,
        titleLarge: CodeOpsTypography.titleLarge,
        titleMedium: CodeOpsTypography.titleMedium,
        titleSmall: CodeOpsTypography.titleSmall,
        bodyLarge: CodeOpsTypography.bodyLarge,
        bodyMedium: CodeOpsTypography.bodyMedium,
        bodySmall: CodeOpsTypography.bodySmall,
        labelLarge: CodeOpsTypography.labelLarge,
        labelMedium: CodeOpsTypography.labelMedium,
        labelSmall: CodeOpsTypography.labelSmall,
      ),
      cardTheme: const CardThemeData(
        color: CodeOpsColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: CodeOpsColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CodeOpsColors.background,
        foregroundColor: CodeOpsColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CodeOpsTypography.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CodeOpsColors.surfaceVariant,
        hintStyle: CodeOpsTypography.bodyMedium
            .copyWith(color: CodeOpsColors.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CodeOpsColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: CodeOpsTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CodeOpsColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: CodeOpsColors.border),
          textStyle: CodeOpsTypography.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: CodeOpsColors.divider,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          CodeOpsColors.textTertiary.withValues(alpha: 0.3),
        ),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}
