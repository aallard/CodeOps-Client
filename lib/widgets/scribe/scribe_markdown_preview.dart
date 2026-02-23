/// Standalone Markdown preview widget for the Scribe editor.
///
/// Renders Markdown content with CodeOps dark theme styling, GFM support
/// (tables, task lists, fenced code, strikethrough), and debounced
/// rendering. Consumed by [ScribeMarkdownSplit] for the live preview
/// pane.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/constants.dart';

/// A reusable Markdown preview widget styled for the CodeOps dark theme.
///
/// Renders GFM-flavored Markdown with syntax-highlighted code blocks,
/// tables, task lists, and links. Content updates are debounced by
/// [AppConstants.scribeMarkdownPreviewDebounceMs] milliseconds to avoid
/// excessive re-renders during rapid typing.
///
/// Usage:
/// ```dart
/// ScribeMarkdownPreview(
///   content: '# Hello\n\nWorld',
///   scrollController: myController,
/// )
/// ```
class ScribeMarkdownPreview extends StatefulWidget {
  /// The raw Markdown content to render.
  final String content;

  /// Optional scroll controller for synchronized scrolling.
  final ScrollController? scrollController;

  /// Creates a [ScribeMarkdownPreview].
  const ScribeMarkdownPreview({
    super.key,
    required this.content,
    this.scrollController,
  });

  @override
  State<ScribeMarkdownPreview> createState() => _ScribeMarkdownPreviewState();
}

class _ScribeMarkdownPreviewState extends State<ScribeMarkdownPreview> {
  Timer? _debounceTimer;
  String _renderedContent = '';

  @override
  void initState() {
    super.initState();
    _renderedContent = widget.content;
  }

  @override
  void didUpdateWidget(covariant ScribeMarkdownPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(
          milliseconds: AppConstants.scribeMarkdownPreviewDebounceMs,
        ),
        () {
          if (mounted) {
            setState(() => _renderedContent = widget.content);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.background,
      child: Markdown(
        data: _renderedContent,
        controller: widget.scrollController,
        selectable: true,
        padding: const EdgeInsets.all(16),
        onTapLink: (text, href, title) => _openLink(href),
        styleSheet: _buildStyleSheet(),
        builders: {
          'code': _ScribeCodeBlockBuilder(),
        },
      ),
    );
  }

  /// Builds a [MarkdownStyleSheet] matching the CodeOps dark theme.
  MarkdownStyleSheet _buildStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontSize: 14,
        height: 1.6,
      ),
      h1: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h3: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h4: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h5: const TextStyle(
        color: CodeOpsColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h6: const TextStyle(
        color: CodeOpsColors.textTertiary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      del: const TextStyle(decoration: TextDecoration.lineThrough),
      code: TextStyle(
        color: CodeOpsColors.secondary,
        backgroundColor: CodeOpsColors.surfaceVariant,
        fontFamily: CodeOpsTypography.codeFontFamily,
        fontFamilyFallback: CodeOpsTypography.codeFontFallback,
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      blockquote: const TextStyle(
        color: CodeOpsColors.textSecondary,
        fontSize: 14,
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: CodeOpsColors.primary.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      listBullet: const TextStyle(
        color: CodeOpsColors.textSecondary,
        fontSize: 14,
      ),
      checkbox: const TextStyle(color: CodeOpsColors.primary),
      tableHead: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      tableBody: const TextStyle(
        color: CodeOpsColors.textSecondary,
        fontSize: 13,
      ),
      tableBorder: TableBorder.all(
        color: CodeOpsColors.border,
        width: 1,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CodeOpsColors.divider,
            width: 1,
          ),
        ),
      ),
      a: const TextStyle(
        color: CodeOpsColors.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }

  /// Opens a URL in the system browser.
  Future<void> _openLink(String? href) async {
    if (href == null) return;
    final uri = Uri.tryParse(href);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Custom code block builder with syntax highlighting.
class _ScribeCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final textContent = element.textContent;

    // Detect language from class attribute (e.g., "language-dart").
    String? language;
    if (element.attributes.containsKey('class')) {
      final cls = element.attributes['class']!;
      if (cls.startsWith('language-')) {
        language = cls.substring(9);
      }
    }

    // Apply syntax highlighting for fenced code blocks (multi-line).
    if (textContent.contains('\n')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: HighlightView(
            textContent,
            language: language ?? 'plaintext',
            theme: monokaiSublimeTheme,
            padding: const EdgeInsets.all(12),
            textStyle: TextStyle(
              fontFamily: CodeOpsTypography.codeFontFamily,
              fontFamilyFallback: CodeOpsTypography.codeFontFallback,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    return null;
  }
}
