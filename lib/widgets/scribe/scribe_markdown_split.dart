/// Resizable split view layout for the Scribe Markdown preview.
///
/// Supports three modes: editor-only, side-by-side split, and
/// preview-only. The split divider is draggable with a minimum pane
/// width of 200px, and double-clicking the divider resets the ratio
/// to 50/50.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';
import 'scribe_markdown_preview.dart';
import 'scribe_preview_controls.dart';

/// A resizable split view that places an editor widget beside a Markdown
/// preview pane.
///
/// The [mode] determines which panes are visible:
/// - [ScribePreviewMode.editor]: Only the editor.
/// - [ScribePreviewMode.split]: Editor and preview side-by-side.
/// - [ScribePreviewMode.preview]: Only the preview.
///
/// The [splitRatio] (0.0–1.0) controls the editor's proportion of the
/// available width. Double-clicking the divider resets to 50/50.
///
/// Bidirectional scroll synchronization keeps the editor and preview
/// aligned proportionally, with a cooldown to prevent feedback loops.
class ScribeMarkdownSplit extends StatefulWidget {
  /// The editor widget to display in the left pane.
  final Widget editor;

  /// The raw Markdown content for the preview pane.
  final String content;

  /// The current preview mode.
  final ScribePreviewMode mode;

  /// The current split ratio (0.0–1.0, where 1.0 = editor takes all).
  final double splitRatio;

  /// Called when the user drags the divider. Receives the new ratio.
  final ValueChanged<double> onSplitRatioChanged;

  /// Optional scroll controller for the preview pane (for external
  /// scroll synchronization).
  final ScrollController? previewScrollController;

  /// Creates a [ScribeMarkdownSplit].
  const ScribeMarkdownSplit({
    super.key,
    required this.editor,
    required this.content,
    required this.mode,
    required this.splitRatio,
    required this.onSplitRatioChanged,
    this.previewScrollController,
  });

  @override
  State<ScribeMarkdownSplit> createState() => _ScribeMarkdownSplitState();
}

class _ScribeMarkdownSplitState extends State<ScribeMarkdownSplit> {
  static const double _dividerWidth = 6.0;

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      ScribePreviewMode.editor => widget.editor,
      ScribePreviewMode.preview => ScribeMarkdownPreview(
          content: widget.content,
          scrollController: widget.previewScrollController,
        ),
      ScribePreviewMode.split => LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final minPane = AppConstants.scribeMinSplitPaneWidth;

            // Clamp the ratio so both panes are at least minPane wide.
            final maxEditorWidth = totalWidth - minPane - _dividerWidth;
            final minEditorWidth = minPane;
            final editorWidth = (totalWidth - _dividerWidth) *
                widget.splitRatio;
            final clampedEditorWidth =
                editorWidth.clamp(minEditorWidth, maxEditorWidth);
            final previewWidth =
                totalWidth - clampedEditorWidth - _dividerWidth;

            return Row(
              children: [
                SizedBox(
                  width: clampedEditorWidth,
                  child: widget.editor,
                ),
                _SplitDivider(
                  width: _dividerWidth,
                  onDrag: (dx) => _handleDrag(dx, totalWidth),
                  onDoubleTap: _handleDoubleTap,
                ),
                SizedBox(
                  width: previewWidth,
                  child: ScribeMarkdownPreview(
                    content: widget.content,
                    scrollController: widget.previewScrollController,
                  ),
                ),
              ],
            );
          },
        ),
    };
  }

  /// Handles horizontal drag on the divider.
  void _handleDrag(double dx, double totalWidth) {
    final usableWidth = totalWidth - _dividerWidth;
    if (usableWidth <= 0) return;

    final currentEditorWidth = usableWidth * widget.splitRatio;
    final newEditorWidth = currentEditorWidth + dx;
    final newRatio = (newEditorWidth / usableWidth).clamp(0.0, 1.0);

    // Enforce minimum pane widths.
    final minRatio = AppConstants.scribeMinSplitPaneWidth / usableWidth;
    final maxRatio = 1.0 - minRatio;
    final clampedRatio = newRatio.clamp(minRatio, maxRatio);

    widget.onSplitRatioChanged(clampedRatio);
  }

  /// Resets split ratio to 50/50 on double-tap.
  void _handleDoubleTap() {
    widget.onSplitRatioChanged(AppConstants.scribeDefaultSplitRatio);
  }
}

/// The draggable divider between the editor and preview panes.
class _SplitDivider extends StatefulWidget {
  /// Width of the divider hit area.
  final double width;

  /// Called during horizontal drag with the delta-x.
  final ValueChanged<double> onDrag;

  /// Called on double-tap to reset the split ratio.
  final VoidCallback onDoubleTap;

  const _SplitDivider({
    required this.width,
    required this.onDrag,
    required this.onDoubleTap,
  });

  @override
  State<_SplitDivider> createState() => _SplitDividerState();
}

class _SplitDividerState extends State<_SplitDivider> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          widget.onDrag(details.delta.dx);
        },
        onDoubleTap: widget.onDoubleTap,
        child: Container(
          width: widget.width,
          color: _hovering
              ? CodeOpsColors.primary.withValues(alpha: 0.3)
              : CodeOpsColors.border,
        ),
      ),
    );
  }
}
