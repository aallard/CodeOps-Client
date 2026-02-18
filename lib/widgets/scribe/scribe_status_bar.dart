/// A status bar displayed at the bottom of the Scribe editor page.
///
/// Shows the current language mode, cursor position, encoding, and
/// line ending indicator. The language mode is a clickable dropdown
/// that allows changing the syntax highlighting language.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';
import 'scribe_language.dart';

/// A status bar for the Scribe editor showing language, cursor, and encoding.
///
/// Displays the current language mode as a dropdown, cursor position
/// (Ln/Col), encoding (UTF-8), and line ending indicator (LF).
class ScribeStatusBar extends ConsumerWidget {
  /// Current cursor line (0-based, displayed as 1-based).
  final int cursorLine;

  /// Current cursor column (0-based, displayed as 1-based).
  final int cursorColumn;

  /// Current language identifier.
  final String language;

  /// Callback when user selects a different language from the dropdown.
  final ValueChanged<String> onLanguageChanged;

  /// Creates a [ScribeStatusBar].
  const ScribeStatusBar({
    super.key,
    required this.cursorLine,
    required this.cursorColumn,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: AppConstants.scribeStatusBarHeight,
      color: const Color(0xFF1E1F36),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Language dropdown
          _LanguageDropdown(
            language: language,
            onChanged: onLanguageChanged,
          ),
          const Spacer(),
          // Cursor position
          _StatusText('Ln ${cursorLine + 1}, Col ${cursorColumn + 1}'),
          const _StatusDivider(),
          // Encoding
          const _StatusText('UTF-8'),
          const _StatusDivider(),
          // Line ending
          const _StatusText('LF'),
        ],
      ),
    );
  }
}

/// The language mode dropdown in the status bar.
class _LanguageDropdown extends StatelessWidget {
  final String language;
  final ValueChanged<String> onChanged;

  const _LanguageDropdown({
    required this.language,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      tooltip: 'Change language mode',
      offset: const Offset(0, -200),
      constraints: const BoxConstraints(maxHeight: 300),
      color: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      itemBuilder: (_) {
        return ScribeLanguage.supportedLanguages.map((lang) {
          return PopupMenuItem<String>(
            value: lang,
            height: 32,
            child: Text(
              ScribeLanguage.displayName(lang),
              style: TextStyle(
                fontSize: 12,
                color: lang == language
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textPrimary,
                fontWeight:
                    lang == language ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ScribeLanguage.displayName(language),
            style: const TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_up,
            size: 14,
            color: CodeOpsColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

/// A small text widget used in the status bar.
class _StatusText extends StatelessWidget {
  final String text;

  const _StatusText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: CodeOpsColors.textSecondary,
      ),
    );
  }
}

/// A subtle vertical divider between status bar sections.
class _StatusDivider extends StatelessWidget {
  const _StatusDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 1,
        height: 14,
        color: CodeOpsColors.border,
      ),
    );
  }
}
