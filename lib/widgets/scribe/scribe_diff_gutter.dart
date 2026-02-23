/// Line number gutter with change markers for the Scribe diff view.
///
/// Renders line numbers for left/right panes with colored markers
/// indicating added, removed, or modified lines.
library;

import 'package:flutter/material.dart';

import '../../models/scribe_diff_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A gutter column that displays line numbers and change markers.
///
/// Used in both side-by-side and inline diff views. For side-by-side,
/// one gutter is rendered per pane. For inline, a single gutter shows
/// both left and right line numbers.
class ScribeDiffGutter extends StatelessWidget {
  /// The diff lines to display gutters for.
  final List<DiffLine> lines;

  /// Whether to show left line numbers (original document).
  final bool showLeft;

  /// Whether to show right line numbers (modified document).
  final bool showRight;

  /// Font size for line numbers.
  final double fontSize;

  /// Creates a [ScribeDiffGutter].
  const ScribeDiffGutter({
    super.key,
    required this.lines,
    this.showLeft = true,
    this.showRight = true,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: showLeft && showRight
          ? AppConstants.scribeDiffGutterWidth * 2
          : AppConstants.scribeDiffGutterWidth,
      child: ListView.builder(
        itemCount: lines.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => _buildGutterLine(lines[index]),
      ),
    );
  }

  /// Builds a single gutter line row.
  Widget _buildGutterLine(DiffLine line) {
    final markerColor = _markerColor(line.type);

    return Container(
      height: AppConstants.scribeDiffLineHeight,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: markerColor ?? Colors.transparent,
            width: markerColor != null ? 3 : 0,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showLeft)
            SizedBox(
              width: AppConstants.scribeDiffGutterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  line.leftLineNumber?.toString() ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'JetBrains Mono',
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ),
            ),
          if (showRight)
            SizedBox(
              width: AppConstants.scribeDiffGutterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  line.rightLineNumber?.toString() ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'JetBrains Mono',
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Returns the marker color for the given line type.
  Color? _markerColor(DiffLineType type) {
    return switch (type) {
      DiffLineType.added => CodeOpsColors.diffGutterAdded,
      DiffLineType.removed => CodeOpsColors.diffGutterRemoved,
      DiffLineType.modified => CodeOpsColors.diffGutterModified,
      _ => null,
    };
  }
}
