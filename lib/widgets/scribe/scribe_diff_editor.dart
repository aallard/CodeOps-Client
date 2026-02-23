/// Main container widget for the Scribe diff editor.
///
/// Provides a reusable diff comparison view that combines the summary
/// bar, view mode toggle, change navigation, collapse controls, and
/// either the side-by-side or inline diff view. Consumed by the Scribe
/// standalone page and other Control Plane modules (CVF-003, CMF-004,
/// CLF-004).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/scribe_diff_models.dart';
import '../../theme/colors.dart';
import 'scribe_diff_inline.dart';
import 'scribe_diff_side_by_side.dart';
import 'scribe_diff_summary_bar.dart';

/// A reusable diff editor container widget.
///
/// Accepts a [DiffState] and renders the complete diff comparison UI
/// including the summary bar with statistics and navigation, and the
/// diff view in either side-by-side or inline mode.
///
/// Usage:
/// ```dart
/// ScribeDiffEditor(
///   diffState: diffState,
///   viewMode: DiffViewMode.sideBySide,
///   collapseUnchanged: true,
///   collapsedLines: collapsedLines,
///   onViewModeChanged: (mode) => setState(() => _mode = mode),
///   onCollapseChanged: (value) => setState(() => _collapse = value),
/// )
/// ```
class ScribeDiffEditor extends StatefulWidget {
  /// The diff state containing lines, summary, and change indices.
  final DiffState diffState;

  /// The current diff view mode.
  final DiffViewMode viewMode;

  /// Whether unchanged regions are collapsed.
  final bool collapseUnchanged;

  /// The diff lines to display (already collapsed if applicable).
  final List<DiffLine> displayLines;

  /// Callback when the view mode is changed.
  final ValueChanged<DiffViewMode> onViewModeChanged;

  /// Callback when collapse unchanged is toggled.
  final ValueChanged<bool> onCollapseChanged;

  /// Optional left pane title (e.g., tab name).
  final String? leftTitle;

  /// Optional right pane title (e.g., tab name).
  final String? rightTitle;

  /// Font size for diff content.
  final double fontSize;

  /// Creates a [ScribeDiffEditor].
  const ScribeDiffEditor({
    super.key,
    required this.diffState,
    required this.viewMode,
    required this.collapseUnchanged,
    required this.displayLines,
    required this.onViewModeChanged,
    required this.onCollapseChanged,
    this.leftTitle,
    this.rightTitle,
    this.fontSize = 13.0,
  });

  @override
  State<ScribeDiffEditor> createState() => _ScribeDiffEditorState();
}

class _ScribeDiffEditorState extends State<ScribeDiffEditor> {
  final ScrollController _scrollController = ScrollController();
  int _currentChangeIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = widget.diffState.changeIndices.isNotEmpty;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
            _goToPreviousChange,
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            _goToNextChange,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            // Pane headers (side-by-side only).
            if (widget.viewMode == DiffViewMode.sideBySide &&
                (widget.leftTitle != null || widget.rightTitle != null))
              _buildPaneHeaders(),
            // Summary bar.
            ScribeDiffSummaryBar(
              summary: widget.diffState.summary,
              viewMode: widget.viewMode,
              onViewModeChanged: widget.onViewModeChanged,
              onPreviousChange: hasChanges ? _goToPreviousChange : null,
              onNextChange: hasChanges ? _goToNextChange : null,
              collapseUnchanged: widget.collapseUnchanged,
              onCollapseChanged: widget.onCollapseChanged,
            ),
            // Diff content.
            Expanded(
              child: widget.viewMode == DiffViewMode.sideBySide
                  ? ScribeDiffSideBySide(
                      lines: widget.displayLines,
                      fontSize: widget.fontSize,
                      scrollController: _scrollController,
                    )
                  : ScribeDiffInline(
                      lines: widget.displayLines,
                      fontSize: widget.fontSize,
                      scrollController: _scrollController,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the pane header row showing left/right titles.
  Widget _buildPaneHeaders() {
    return Container(
      height: 28,
      color: CodeOpsColors.surfaceVariant,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.leftTitle ?? 'Original',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(width: 1, color: CodeOpsColors.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.rightTitle ?? 'Modified',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to the previous change in the diff.
  void _goToPreviousChange() {
    final indices = widget.diffState.changeIndices;
    if (indices.isEmpty) return;

    if (_currentChangeIndex <= 0) {
      _currentChangeIndex = indices.length - 1;
    } else {
      _currentChangeIndex--;
    }
    _scrollToChange(_currentChangeIndex);
  }

  /// Navigates to the next change in the diff.
  void _goToNextChange() {
    final indices = widget.diffState.changeIndices;
    if (indices.isEmpty) return;

    if (_currentChangeIndex >= indices.length - 1) {
      _currentChangeIndex = 0;
    } else {
      _currentChangeIndex++;
    }
    _scrollToChange(_currentChangeIndex);
  }

  /// Scrolls to the change at the given index in [changeIndices].
  void _scrollToChange(int changeIdx) {
    final indices = widget.diffState.changeIndices;
    if (changeIdx < 0 || changeIdx >= indices.length) return;

    final lineIndex = indices[changeIdx];
    final offset = lineIndex * 22.0; // AppConstants.scribeDiffLineHeight
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
