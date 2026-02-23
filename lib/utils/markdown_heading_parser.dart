/// Parses headings from Markdown source text.
///
/// Extracts ATX-style headings (`#`, `##`, `###`, etc.) while ignoring
/// headings inside fenced code blocks. Used by the Scribe Table of
/// Contents (TOC) widget to build a navigable heading tree.
library;

/// A single heading extracted from Markdown source.
class MarkdownHeading {
  /// Heading level (1–6).
  final int level;

  /// The heading text (without leading `#` characters and whitespace).
  final String title;

  /// The 0-based line index in the source text.
  final int line;

  /// Creates a [MarkdownHeading].
  const MarkdownHeading({
    required this.level,
    required this.title,
    required this.line,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkdownHeading &&
          level == other.level &&
          title == other.title &&
          line == other.line;

  @override
  int get hashCode => Object.hash(level, title, line);

  @override
  String toString() =>
      'MarkdownHeading(level: $level, title: "$title", line: $line)';
}

/// Parses ATX-style headings from [markdown] source.
///
/// Headings inside fenced code blocks (triple backtick or triple tilde)
/// are excluded. Returns an ordered list of [MarkdownHeading] entries.
///
/// Example:
/// ```dart
/// final headings = parseMarkdownHeadings('# Title\n## Section\n');
/// // [MarkdownHeading(level: 1, title: "Title", line: 0),
/// //  MarkdownHeading(level: 2, title: "Section", line: 1)]
/// ```
List<MarkdownHeading> parseMarkdownHeadings(String markdown) {
  if (markdown.isEmpty) return const [];

  final lines = markdown.split('\n');
  final headings = <MarkdownHeading>[];
  var inCodeBlock = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trimLeft();

    // Toggle fenced code block state.
    if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
      inCodeBlock = !inCodeBlock;
      continue;
    }

    if (inCodeBlock) continue;

    // Match ATX headings: 1–6 leading '#' followed by a space.
    if (trimmed.startsWith('#')) {
      final match = _headingPattern.firstMatch(trimmed);
      if (match != null) {
        final hashes = match.group(1)!;
        final title = match.group(2)!.trim();
        if (title.isNotEmpty) {
          headings.add(MarkdownHeading(
            level: hashes.length,
            title: _stripTrailingHashes(title),
            line: i,
          ));
        }
      }
    }
  }

  return headings;
}

/// Matches ATX headings: 1–6 `#` characters followed by a space and text.
final RegExp _headingPattern = RegExp(r'^(#{1,6})\s+(.+)$');

/// Strips optional trailing `#` characters from a heading title.
///
/// For example, `"Section ##"` becomes `"Section"`.
String _stripTrailingHashes(String title) {
  return title.replaceFirst(RegExp(r'\s+#+\s*$'), '');
}
