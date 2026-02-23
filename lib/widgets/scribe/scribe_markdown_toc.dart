/// Dropdown-based Table of Contents (TOC) for Markdown files.
///
/// Parses headings from the current Markdown content and presents
/// them in an indented dropdown menu. Clicking a heading navigates
/// both the editor and preview to the corresponding line.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/markdown_heading_parser.dart';

/// A dropdown button that shows a table of contents parsed from Markdown.
///
/// Headings are indented by level (h1 at root, h2 indented, h3 further).
/// Selecting a heading fires [onHeadingSelected] with the heading's
/// 0-based line index.
///
/// Usage:
/// ```dart
/// ScribeMarkdownToc(
///   content: markdownSource,
///   currentLine: 42,
///   onHeadingSelected: (line) => scrollToLine(line),
/// )
/// ```
class ScribeMarkdownToc extends StatelessWidget {
  /// The raw Markdown source to parse headings from.
  final String content;

  /// The current editor cursor line (0-based), used to highlight the
  /// active heading in the dropdown.
  final int currentLine;

  /// Called when the user selects a heading. Receives the heading's
  /// 0-based line index.
  final ValueChanged<int> onHeadingSelected;

  /// Creates a [ScribeMarkdownToc].
  const ScribeMarkdownToc({
    super.key,
    required this.content,
    required this.currentLine,
    required this.onHeadingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final headings = parseMarkdownHeadings(content);

    if (headings.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine the currently active heading (the last heading whose
    // line is at or before the cursor position).
    final activeHeading = _findActiveHeading(headings, currentLine);

    return PopupMenuButton<int>(
      onSelected: onHeadingSelected,
      tooltip: 'Table of Contents',
      offset: const Offset(0, 32),
      constraints: const BoxConstraints(maxHeight: 400, maxWidth: 320),
      color: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      itemBuilder: (_) {
        return headings.map((heading) {
          final isActive = activeHeading != null &&
              heading.line == activeHeading.line;
          final indent = (heading.level - 1) * 12.0;

          return PopupMenuItem<int>(
            value: heading.line,
            height: 32,
            padding: EdgeInsets.only(left: 12 + indent, right: 12),
            child: Text(
              heading.title,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list,
            size: 16,
            color: CodeOpsColors.textTertiary,
          ),
          SizedBox(width: 4),
          Text(
            'TOC',
            style: TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: 14,
            color: CodeOpsColors.textTertiary,
          ),
        ],
      ),
    );
  }

  /// Finds the heading that is closest to (at or before) [currentLine].
  MarkdownHeading? _findActiveHeading(
    List<MarkdownHeading> headings,
    int currentLine,
  ) {
    MarkdownHeading? active;
    for (final heading in headings) {
      if (heading.line <= currentLine) {
        active = heading;
      } else {
        break;
      }
    }
    return active;
  }
}
