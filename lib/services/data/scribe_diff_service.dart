/// Diff engine service for the Scribe editor.
///
/// Computes line-level and character-level diffs between two text
/// documents using the diff_match_patch algorithm. Produces
/// [DiffLine] lists, [DiffSummary] statistics, and change indices
/// for navigation.
library;

import 'package:diff_match_patch/diff_match_patch.dart';

import '../../models/scribe_diff_models.dart';
import '../../utils/constants.dart';

/// Service that computes diffs between two text documents.
///
/// Uses [DiffMatchPatch] for the underlying diff algorithm and
/// builds structured [DiffLine] output suitable for rendering in
/// both side-by-side and inline diff views.
///
/// This service is stateless and can be used as a singleton.
class ScribeDiffService {
  final DiffMatchPatch _dmp = DiffMatchPatch();

  /// Computes a full [DiffState] comparing [leftText] to [rightText].
  ///
  /// The [leftTabId] and [rightTabId] identify the source tabs for
  /// reference. Returns a [DiffState] with diff lines, summary, and
  /// change indices for Alt+Up/Down navigation.
  DiffState computeDiff({
    required String leftTabId,
    required String rightTabId,
    required String leftText,
    required String rightText,
  }) {
    final lines = computeLineDiff(leftText, rightText);
    final summary = computeSummary(lines);
    final changeIndices = _buildChangeIndices(lines);

    return DiffState(
      leftTabId: leftTabId,
      rightTabId: rightTabId,
      lines: lines,
      summary: summary,
      changeIndices: changeIndices,
    );
  }

  /// Computes line-level diff between [leftText] and [rightText].
  ///
  /// Splits both texts into lines, then uses diff_match_patch to
  /// detect insertions, deletions, and modifications. Modified lines
  /// (where a deletion is immediately followed by an insertion) include
  /// character-level [DiffSegment]s for inline highlighting.
  List<DiffLine> computeLineDiff(String leftText, String rightText) {
    final leftLines = leftText.split('\n');
    final rightLines = rightText.split('\n');

    // Convert lines to characters for line-level diffing.
    final result = _linesToChars(leftLines, rightLines);
    final charLeft = result.chars1;
    final charRight = result.chars2;
    final lineArray = result.lineArray;

    final diffs = _dmp.diff(charLeft, charRight);
    _dmp.diffCleanupSemantic(diffs);

    final diffLines = <DiffLine>[];
    var leftNum = 1;
    var rightNum = 1;

    var i = 0;
    while (i < diffs.length) {
      final diff = diffs[i];

      if (diff.operation == DIFF_EQUAL) {
        // Unchanged lines.
        for (var c = 0; c < diff.text.length; c++) {
          final lineIdx = diff.text.codeUnitAt(c);
          final lineText =
              lineIdx < lineArray.length ? lineArray[lineIdx] : '';
          diffLines.add(DiffLine(
            leftLineNumber: leftNum++,
            rightLineNumber: rightNum++,
            text: lineText,
            type: DiffLineType.unchanged,
          ));
        }
      } else if (diff.operation == DIFF_DELETE) {
        // Check if next diff is an insert (modification).
        if (i + 1 < diffs.length &&
            diffs[i + 1].operation == DIFF_INSERT) {
          final insertDiff = diffs[i + 1];
          final removedLines = <String>[];
          final addedLines = <String>[];

          for (var c = 0; c < diff.text.length; c++) {
            final lineIdx = diff.text.codeUnitAt(c);
            removedLines
                .add(lineIdx < lineArray.length ? lineArray[lineIdx] : '');
          }
          for (var c = 0; c < insertDiff.text.length; c++) {
            final lineIdx = insertDiff.text.codeUnitAt(c);
            addedLines
                .add(lineIdx < lineArray.length ? lineArray[lineIdx] : '');
          }

          // Pair up modified lines; overflow is pure add/remove.
          final pairCount =
              removedLines.length < addedLines.length
                  ? removedLines.length
                  : addedLines.length;

          for (var j = 0; j < pairCount; j++) {
            final charSegments =
                _computeCharDiff(removedLines[j], addedLines[j]);
            diffLines.add(DiffLine(
              leftLineNumber: leftNum++,
              rightLineNumber: rightNum++,
              text: addedLines[j],
              type: DiffLineType.modified,
              segments: charSegments.rightSegments,
              pairedText: removedLines[j],
              pairedSegments: charSegments.leftSegments,
            ));
          }

          // Remaining removed lines.
          for (var j = pairCount; j < removedLines.length; j++) {
            diffLines.add(DiffLine(
              leftLineNumber: leftNum++,
              text: removedLines[j],
              type: DiffLineType.removed,
            ));
          }

          // Remaining added lines.
          for (var j = pairCount; j < addedLines.length; j++) {
            diffLines.add(DiffLine(
              rightLineNumber: rightNum++,
              text: addedLines[j],
              type: DiffLineType.added,
            ));
          }

          i++; // Skip the insert diff since we consumed it.
        } else {
          // Pure deletion.
          for (var c = 0; c < diff.text.length; c++) {
            final lineIdx = diff.text.codeUnitAt(c);
            final lineText =
                lineIdx < lineArray.length ? lineArray[lineIdx] : '';
            diffLines.add(DiffLine(
              leftLineNumber: leftNum++,
              text: lineText,
              type: DiffLineType.removed,
            ));
          }
        }
      } else {
        // Pure insertion.
        for (var c = 0; c < diff.text.length; c++) {
          final lineIdx = diff.text.codeUnitAt(c);
          final lineText =
              lineIdx < lineArray.length ? lineArray[lineIdx] : '';
          diffLines.add(DiffLine(
            rightLineNumber: rightNum++,
            text: lineText,
            type: DiffLineType.added,
          ));
        }
      }

      i++;
    }

    return diffLines;
  }

  /// Computes summary statistics from a list of [DiffLine]s.
  DiffSummary computeSummary(List<DiffLine> lines) {
    var added = 0;
    var removed = 0;
    var modified = 0;

    for (final line in lines) {
      switch (line.type) {
        case DiffLineType.added:
          added++;
        case DiffLineType.removed:
          removed++;
        case DiffLineType.modified:
          modified++;
        case DiffLineType.unchanged:
        case DiffLineType.padding:
          break;
      }
    }

    return DiffSummary(
      addedLines: added,
      removedLines: removed,
      modifiedLines: modified,
    );
  }

  /// Collapses unchanged regions, keeping [contextLines] around changes.
  ///
  /// Returns a new list where long runs of unchanged lines are replaced
  /// by a single [DiffLineType.padding] line indicating the number of
  /// hidden lines.
  List<DiffLine> collapseUnchanged(
    List<DiffLine> lines, {
    int contextLines = AppConstants.scribeDiffContextLines,
  }) {
    if (lines.isEmpty) return lines;

    // Identify which lines are "near" a change.
    final keepMask = List.filled(lines.length, false);
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].type != DiffLineType.unchanged) {
        // Mark context lines before and after.
        for (var j = (i - contextLines).clamp(0, lines.length);
            j <= (i + contextLines).clamp(0, lines.length - 1);
            j++) {
          keepMask[j] = true;
        }
      }
    }

    final result = <DiffLine>[];
    var i = 0;
    while (i < lines.length) {
      if (keepMask[i]) {
        result.add(lines[i]);
        i++;
      } else {
        // Count consecutive hidden unchanged lines.
        var hiddenCount = 0;
        while (i < lines.length && !keepMask[i]) {
          hiddenCount++;
          i++;
        }
        result.add(DiffLine(
          text: '$hiddenCount unchanged lines',
          type: DiffLineType.padding,
        ));
      }
    }

    return result;
  }

  /// Computes character-level diff segments between two line strings.
  _CharDiffResult _computeCharDiff(String leftLine, String rightLine) {
    final diffs = _dmp.diff(leftLine, rightLine);
    _dmp.diffCleanupSemantic(diffs);

    final leftSegments = <DiffSegment>[];
    final rightSegments = <DiffSegment>[];

    for (final diff in diffs) {
      switch (diff.operation) {
        case DIFF_EQUAL:
          leftSegments.add(DiffSegment(text: diff.text));
          rightSegments.add(DiffSegment(text: diff.text));
        case DIFF_DELETE:
          leftSegments.add(DiffSegment(text: diff.text, isRemoved: true));
        case DIFF_INSERT:
          rightSegments.add(DiffSegment(text: diff.text, isAdded: true));
      }
    }

    return _CharDiffResult(
      leftSegments: leftSegments,
      rightSegments: rightSegments,
    );
  }

  /// Converts lines to single characters for line-level diffing.
  ///
  /// Each unique line maps to a single Unicode character so that
  /// diff_match_patch can operate on lines instead of characters.
  _LinesToCharsResult _linesToChars(
    List<String> leftLines,
    List<String> rightLines,
  ) {
    final lineArray = <String>[''];
    final lineHash = <String, int>{};

    String encode(List<String> lines) {
      final chars = StringBuffer();
      for (final line in lines) {
        if (lineHash.containsKey(line)) {
          chars.writeCharCode(lineHash[line]!);
        } else {
          lineArray.add(line);
          lineHash[line] = lineArray.length - 1;
          chars.writeCharCode(lineArray.length - 1);
        }
      }
      return chars.toString();
    }

    final chars1 = encode(leftLines);
    final chars2 = encode(rightLines);

    return _LinesToCharsResult(
      chars1: chars1,
      chars2: chars2,
      lineArray: lineArray,
    );
  }

  /// Builds the list of indices into [lines] where changes occur.
  List<int> _buildChangeIndices(List<DiffLine> lines) {
    final indices = <int>[];
    for (var i = 0; i < lines.length; i++) {
      final type = lines[i].type;
      if (type == DiffLineType.added ||
          type == DiffLineType.removed ||
          type == DiffLineType.modified) {
        indices.add(i);
      }
    }
    return indices;
  }
}

/// Result of line-to-char encoding for line-level diffing.
class _LinesToCharsResult {
  final String chars1;
  final String chars2;
  final List<String> lineArray;

  const _LinesToCharsResult({
    required this.chars1,
    required this.chars2,
    required this.lineArray,
  });
}

/// Result of character-level diff between two line strings.
class _CharDiffResult {
  final List<DiffSegment> leftSegments;
  final List<DiffSegment> rightSegments;

  const _CharDiffResult({
    required this.leftSegments,
    required this.rightSegments,
  });
}
