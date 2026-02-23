/// Preview mode toggle controls for Markdown tabs in the Scribe editor.
///
/// Displays a compact 3-state segmented control (Editor / Split / Preview)
/// that is only visible when the active tab's language is `'markdown'`.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// The three preview modes available for Markdown tabs.
enum ScribePreviewMode {
  /// Editor only — no preview pane.
  editor,

  /// Side-by-side editor and preview.
  split,

  /// Preview only — no editor pane.
  preview,
}

/// A compact 3-state toggle for switching between Markdown preview modes.
///
/// Each segment displays an icon and optional label. The active segment
/// is highlighted with the CodeOps primary color.
///
/// Usage:
/// ```dart
/// ScribePreviewControls(
///   mode: ScribePreviewMode.split,
///   onModeChanged: (mode) => updatePreviewMode(mode),
/// )
/// ```
class ScribePreviewControls extends StatelessWidget {
  /// The currently active preview mode.
  final ScribePreviewMode mode;

  /// Called when the user selects a different mode.
  final ValueChanged<ScribePreviewMode> onModeChanged;

  /// Creates [ScribePreviewControls].
  const ScribePreviewControls({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            icon: Icons.edit,
            tooltip: 'Editor only',
            isActive: mode == ScribePreviewMode.editor,
            onTap: () => onModeChanged(ScribePreviewMode.editor),
          ),
          _SegmentButton(
            icon: Icons.vertical_split,
            tooltip: 'Split view',
            isActive: mode == ScribePreviewMode.split,
            onTap: () => onModeChanged(ScribePreviewMode.split),
          ),
          _SegmentButton(
            icon: Icons.visibility,
            tooltip: 'Preview only',
            isActive: mode == ScribePreviewMode.preview,
            onTap: () => onModeChanged(ScribePreviewMode.preview),
          ),
        ],
      ),
    );
  }
}

/// A single segment in the preview mode toggle.
class _SegmentButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? CodeOpsColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 14,
            color: isActive
                ? Colors.white
                : CodeOpsColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
