/// Data models for the Scribe diff editor.
///
/// Contains [DiffLine], [DiffSegment], [DiffSummary], [DiffViewMode],
/// and [DiffState] used by the diff engine and diff view widgets.
library;

/// The type of change a diff line represents.
enum DiffLineType {
  /// Line is unchanged between left and right.
  unchanged,

  /// Line was added (present only on right side).
  added,

  /// Line was removed (present only on left side).
  removed,

  /// Line was modified (present on both sides with differences).
  modified,

  /// Padding line inserted for alignment in side-by-side view.
  padding,
}

/// A segment within a diff line that highlights character-level changes.
///
/// Used to render inline character highlighting within modified lines.
/// Each segment represents a contiguous run of text that is either
/// unchanged, added, or removed.
class DiffSegment {
  /// The text content of this segment.
  final String text;

  /// Whether this segment represents added text.
  final bool isAdded;

  /// Whether this segment represents removed text.
  final bool isRemoved;

  /// Creates a [DiffSegment].
  const DiffSegment({
    required this.text,
    this.isAdded = false,
    this.isRemoved = false,
  });

  /// Whether this segment is unchanged (neither added nor removed).
  bool get isUnchanged => !isAdded && !isRemoved;
}

/// A single line in the diff output.
///
/// Represents one row in the diff view with line numbers from both
/// the left (original) and right (modified) documents, the text content,
/// the type of change, and optional character-level segments.
class DiffLine {
  /// Line number in the left (original) document, or null for added/padding.
  final int? leftLineNumber;

  /// Line number in the right (modified) document, or null for removed/padding.
  final int? rightLineNumber;

  /// The text content of this line (left side for removed, right for added).
  final String text;

  /// The type of change this line represents.
  final DiffLineType type;

  /// Character-level diff segments for modified lines.
  ///
  /// Only populated for [DiffLineType.modified] lines.
  final List<DiffSegment> segments;

  /// The paired line text (left text for modified lines).
  ///
  /// For [DiffLineType.modified], this holds the original (left) text
  /// while [text] holds the modified (right) text.
  final String? pairedText;

  /// Character-level diff segments for the paired (left) text.
  ///
  /// Only populated for [DiffLineType.modified] lines.
  final List<DiffSegment> pairedSegments;

  /// Creates a [DiffLine].
  const DiffLine({
    this.leftLineNumber,
    this.rightLineNumber,
    required this.text,
    required this.type,
    this.segments = const [],
    this.pairedText,
    this.pairedSegments = const [],
  });
}

/// Summary statistics for a diff comparison.
///
/// Provides counts of added, removed, and modified lines for
/// display in the diff summary bar.
class DiffSummary {
  /// Number of lines added.
  final int addedLines;

  /// Number of lines removed.
  final int removedLines;

  /// Number of lines modified.
  final int modifiedLines;

  /// Total number of changes (added + removed + modified).
  int get totalChanges => addedLines + removedLines + modifiedLines;

  /// Creates a [DiffSummary].
  const DiffSummary({
    this.addedLines = 0,
    this.removedLines = 0,
    this.modifiedLines = 0,
  });
}

/// The display mode for the diff view.
enum DiffViewMode {
  /// Side-by-side two-pane view with synchronized scrolling.
  sideBySide,

  /// Unified inline view with +/- prefixes.
  inline,
}

/// The complete state of a diff comparison.
///
/// Holds the source tab identifiers, computed diff lines, summary
/// statistics, and the list of change indices for navigation.
class DiffState {
  /// The ID of the left (original) tab.
  final String leftTabId;

  /// The ID of the right (modified) tab.
  final String rightTabId;

  /// The computed diff lines.
  final List<DiffLine> lines;

  /// Summary statistics for the diff.
  final DiffSummary summary;

  /// Indices into [lines] where changes occur (for Alt+Up/Down navigation).
  final List<int> changeIndices;

  /// Creates a [DiffState].
  const DiffState({
    required this.leftTabId,
    required this.rightTabId,
    required this.lines,
    required this.summary,
    required this.changeIndices,
  });
}
