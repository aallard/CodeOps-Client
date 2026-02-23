/// Side-by-side diff view for the Scribe diff editor.
///
/// Renders two synchronized panes showing the original (left) and
/// modified (right) documents with line-level and character-level
/// change highlighting.
library;

import 'package:flutter/material.dart';

import '../../models/scribe_diff_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A two-pane side-by-side diff view with synchronized scrolling.
///
/// The left pane shows the original document and the right pane shows
/// the modified document. Lines are aligned so that modifications,
/// additions, and deletions can be visually compared. Change backgrounds
/// and character-level highlighting indicate what changed.
class ScribeDiffSideBySide extends StatefulWidget {
  /// The diff lines to display.
  final List<DiffLine> lines;

  /// Font size for diff content.
  final double fontSize;

  /// Optional scroll controller for external scroll synchronization.
  final ScrollController? scrollController;

  /// Creates a [ScribeDiffSideBySide].
  const ScribeDiffSideBySide({
    super.key,
    required this.lines,
    this.fontSize = 13.0,
    this.scrollController,
  });

  @override
  State<ScribeDiffSideBySide> createState() => _ScribeDiffSideBySideState();
}

class _ScribeDiffSideBySideState extends State<ScribeDiffSideBySide> {
  late ScrollController _scrollController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(covariant ScribeDiffSideBySide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      if (_ownsController) {
        _scrollController.dispose();
      }
      if (widget.scrollController != null) {
        _scrollController = widget.scrollController!;
        _ownsController = false;
      } else {
        _scrollController = ScrollController();
        _ownsController = true;
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left pane (original).
        Expanded(
          child: _DiffPane(
            lines: widget.lines,
            side: _DiffSide.left,
            fontSize: widget.fontSize,
            scrollController: _scrollController,
          ),
        ),
        // Divider.
        Container(
          width: 1,
          color: CodeOpsColors.border,
        ),
        // Right pane (modified).
        Expanded(
          child: _DiffPane(
            lines: widget.lines,
            side: _DiffSide.right,
            fontSize: widget.fontSize,
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }
}

/// Which side of the side-by-side view.
enum _DiffSide { left, right }

/// A single pane in the side-by-side view.
class _DiffPane extends StatelessWidget {
  final List<DiffLine> lines;
  final _DiffSide side;
  final double fontSize;
  final ScrollController scrollController;

  const _DiffPane({
    required this.lines,
    required this.side,
    required this.fontSize,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        return _buildLine(line);
      },
    );
  }

  /// Builds a single diff line for this side.
  Widget _buildLine(DiffLine line) {
    final backgroundColor = _lineBackground(line);
    final lineNumber = side == _DiffSide.left
        ? line.leftLineNumber
        : line.rightLineNumber;
    final displayText = _getDisplayText(line);
    final segments = _getSegments(line);

    return Container(
      height: AppConstants.scribeDiffLineHeight,
      color: backgroundColor,
      child: Row(
        children: [
          // Gutter with line number.
          Container(
            width: AppConstants.scribeDiffGutterWidth,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: CodeOpsColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              lineNumber?.toString() ?? '',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontFamily: 'JetBrains Mono',
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          // Change marker.
          SizedBox(
            width: 20,
            child: Center(
              child: Text(
                _markerChar(line.type),
                style: TextStyle(
                  fontSize: fontSize - 1,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w700,
                  color: _markerColor(line.type),
                ),
              ),
            ),
          ),
          // Content.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: segments.isNotEmpty
                  ? _buildSegmentedText(segments)
                  : Text(
                      displayText,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'JetBrains Mono',
                        color: _textColor(line.type),
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

  /// Gets the display text for this side of a diff line.
  String _getDisplayText(DiffLine line) {
    if (line.type == DiffLineType.padding) return line.text;
    if (line.type == DiffLineType.modified) {
      return side == _DiffSide.left
          ? (line.pairedText ?? line.text)
          : line.text;
    }
    if (line.type == DiffLineType.added && side == _DiffSide.left) return '';
    if (line.type == DiffLineType.removed && side == _DiffSide.right) {
      return '';
    }
    return line.text;
  }

  /// Gets character segments for this side of a modified line.
  List<DiffSegment> _getSegments(DiffLine line) {
    if (line.type != DiffLineType.modified) return [];
    return side == _DiffSide.left ? line.pairedSegments : line.segments;
  }

  /// Builds a rich text widget from character-level diff segments.
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

  /// Returns the background color for a diff line on this side.
  Color? _lineBackground(DiffLine line) {
    return switch (line.type) {
      DiffLineType.added =>
        side == _DiffSide.right ? CodeOpsColors.diffAdded : null,
      DiffLineType.removed =>
        side == _DiffSide.left ? CodeOpsColors.diffRemoved : null,
      DiffLineType.modified => side == _DiffSide.left
          ? CodeOpsColors.diffRemoved
          : CodeOpsColors.diffAdded,
      DiffLineType.padding =>
        CodeOpsColors.surfaceVariant.withValues(alpha: 0.3),
      DiffLineType.unchanged => null,
    };
  }

  /// Returns the marker character for a line type.
  String _markerChar(DiffLineType type) {
    return switch (type) {
      DiffLineType.added => side == _DiffSide.right ? '+' : '',
      DiffLineType.removed => side == _DiffSide.left ? '-' : '',
      DiffLineType.modified => '~',
      _ => '',
    };
  }

  /// Returns the marker color for a line type.
  Color _markerColor(DiffLineType type) {
    return switch (type) {
      DiffLineType.added => CodeOpsColors.diffGutterAdded,
      DiffLineType.removed => CodeOpsColors.diffGutterRemoved,
      DiffLineType.modified => CodeOpsColors.diffGutterModified,
      _ => Colors.transparent,
    };
  }

  /// Returns the text color for a line type.
  Color _textColor(DiffLineType type) {
    return switch (type) {
      DiffLineType.padding => CodeOpsColors.textTertiary,
      _ => CodeOpsColors.textPrimary,
    };
  }
}
