/// Unified inline diff view for the Scribe diff editor.
///
/// Renders a single-pane view showing changes with +/- prefixes
/// and dual gutter line numbers from both the original and modified
/// documents.
library;

import 'package:flutter/material.dart';

import '../../models/scribe_diff_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A unified inline diff view with +/- prefixes and dual gutters.
///
/// Shows all lines in a single column with line numbers from both
/// the original (left) and modified (right) documents. Added lines
/// are prefixed with "+", removed with "-", and modified with "~".
class ScribeDiffInline extends StatelessWidget {
  /// The diff lines to display.
  final List<DiffLine> lines;

  /// Font size for diff content.
  final double fontSize;

  /// Optional scroll controller for external scroll control.
  final ScrollController? scrollController;

  /// Creates a [ScribeDiffInline].
  const ScribeDiffInline({
    super.key,
    required this.lines,
    this.fontSize = 13.0,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // For inline view, expand modified lines into remove + add pairs.
    final expandedLines = _expandModifiedLines(lines);

    return ListView.builder(
      controller: scrollController,
      itemCount: expandedLines.length,
      itemBuilder: (context, index) {
        final line = expandedLines[index];
        return _buildLine(line);
      },
    );
  }

  /// Expands modified lines into a removed line followed by an added line.
  List<DiffLine> _expandModifiedLines(List<DiffLine> input) {
    final result = <DiffLine>[];
    for (final line in input) {
      if (line.type == DiffLineType.modified) {
        // Show the removed (original) line first.
        result.add(DiffLine(
          leftLineNumber: line.leftLineNumber,
          text: line.pairedText ?? line.text,
          type: DiffLineType.removed,
          segments: line.pairedSegments,
        ));
        // Then the added (modified) line.
        result.add(DiffLine(
          rightLineNumber: line.rightLineNumber,
          text: line.text,
          type: DiffLineType.added,
          segments: line.segments,
        ));
      } else {
        result.add(line);
      }
    }
    return result;
  }

  /// Builds a single inline diff line.
  Widget _buildLine(DiffLine line) {
    final backgroundColor = _lineBackground(line.type);

    return Container(
      height: AppConstants.scribeDiffLineHeight,
      color: backgroundColor,
      child: Row(
        children: [
          // Left gutter (original line number).
          Container(
            width: AppConstants.scribeDiffGutterWidth,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              line.leftLineNumber?.toString() ?? '',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontFamily: 'JetBrains Mono',
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          // Right gutter (modified line number).
          Container(
            width: AppConstants.scribeDiffGutterWidth,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: CodeOpsColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              line.rightLineNumber?.toString() ?? '',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontFamily: 'JetBrains Mono',
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          // Prefix (+/-/~/ ).
          SizedBox(
            width: 20,
            child: Center(
              child: Text(
                _prefix(line.type),
                style: TextStyle(
                  fontSize: fontSize - 1,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w700,
                  color: _prefixColor(line.type),
                ),
              ),
            ),
          ),
          // Content.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: line.segments.isNotEmpty
                  ? _buildSegmentedText(line.segments)
                  : Text(
                      line.text,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'JetBrains Mono',
                        color: line.type == DiffLineType.padding
                            ? CodeOpsColors.textTertiary
                            : CodeOpsColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds rich text from character-level diff segments.
  Widget _buildSegmentedText(List<DiffSegment> segments) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.clip,
      text: TextSpan(
        children: segments.map((seg) {
          Color? bgColor;
          if (seg.isAdded) bgColor = CodeOpsColors.diffAddedHighlight;
          if (seg.isRemoved) bgColor = CodeOpsColors.diffRemovedHighlight;

          return TextSpan(
            text: seg.text,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'JetBrains Mono',
              color: CodeOpsColors.textPrimary,
              backgroundColor: bgColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Returns the line prefix for a line type.
  String _prefix(DiffLineType type) {
    return switch (type) {
      DiffLineType.added => '+',
      DiffLineType.removed => '-',
      DiffLineType.modified => '~',
      _ => ' ',
    };
  }

  /// Returns the prefix color for a line type.
  Color _prefixColor(DiffLineType type) {
    return switch (type) {
      DiffLineType.added => CodeOpsColors.diffGutterAdded,
      DiffLineType.removed => CodeOpsColors.diffGutterRemoved,
      DiffLineType.modified => CodeOpsColors.diffGutterModified,
      _ => Colors.transparent,
    };
  }

  /// Returns the background color for a line type.
  Color? _lineBackground(DiffLineType type) {
    return switch (type) {
      DiffLineType.added => CodeOpsColors.diffAdded,
      DiffLineType.removed => CodeOpsColors.diffRemoved,
      DiffLineType.modified => CodeOpsColors.diffModified,
      DiffLineType.padding =>
        CodeOpsColors.surfaceVariant.withValues(alpha: 0.3),
      DiffLineType.unchanged => null,
    };
  }
}
