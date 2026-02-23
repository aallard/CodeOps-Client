/// Summary bar for the Scribe diff editor.
///
/// Displays change statistics (added, removed, modified) and provides
/// navigation controls (previous/next change) and a view mode toggle.
library;

import 'package:flutter/material.dart';

import '../../models/scribe_diff_models.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A horizontal bar showing diff summary statistics and navigation.
///
/// Displays counts of added (+N), removed (-N), and modified (~N) lines.
/// Provides previous/next change buttons and a side-by-side/inline toggle.
class ScribeDiffSummaryBar extends StatelessWidget {
  /// The diff summary statistics to display.
  final DiffSummary summary;

  /// The current diff view mode.
  final DiffViewMode viewMode;

  /// Callback when the view mode is changed.
  final ValueChanged<DiffViewMode> onViewModeChanged;

  /// Callback to navigate to the previous change.
  final VoidCallback? onPreviousChange;

  /// Callback to navigate to the next change.
  final VoidCallback? onNextChange;

  /// Whether collapse unchanged is active.
  final bool collapseUnchanged;

  /// Callback when collapse unchanged is toggled.
  final ValueChanged<bool> onCollapseChanged;

  /// Creates a [ScribeDiffSummaryBar].
  const ScribeDiffSummaryBar({
    super.key,
    required this.summary,
    required this.viewMode,
    required this.onViewModeChanged,
    this.onPreviousChange,
    this.onNextChange,
    required this.collapseUnchanged,
    required this.onCollapseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.scribeDiffSummaryBarHeight,
      color: CodeOpsColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Change statistics.
          _StatChip(
            label: '+${summary.addedLines}',
            color: CodeOpsColors.diffGutterAdded,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: '-${summary.removedLines}',
            color: CodeOpsColors.diffGutterRemoved,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: '~${summary.modifiedLines}',
            color: CodeOpsColors.diffGutterModified,
          ),

          const SizedBox(width: 16),

          // Navigation buttons.
          _NavButton(
            icon: Icons.keyboard_arrow_up,
            tooltip: 'Previous change (Alt+Up)',
            onPressed: onPreviousChange,
          ),
          _NavButton(
            icon: Icons.keyboard_arrow_down,
            tooltip: 'Next change (Alt+Down)',
            onPressed: onNextChange,
          ),

          const Spacer(),

          // Collapse toggle.
          Tooltip(
            message: 'Collapse unchanged regions',
            child: SizedBox(
              height: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Collapse',
                    style: TextStyle(
                      fontSize: 11,
                      color: collapseUnchanged
                          ? CodeOpsColors.textPrimary
                          : CodeOpsColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 28,
                    height: 16,
                    child: Switch(
                      value: collapseUnchanged,
                      onChanged: onCollapseChanged,
                      activeThumbColor: CodeOpsColors.primary,
                      activeTrackColor:
                          CodeOpsColors.primary.withValues(alpha: 0.3),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // View mode toggle.
          _ViewModeToggle(
            viewMode: viewMode,
            onChanged: onViewModeChanged,
          ),
        ],
      ),
    );
  }
}

/// A small colored chip showing a diff statistic.
class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// A small navigation button (up/down arrow).
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      color: onPressed != null
          ? CodeOpsColors.textSecondary
          : CodeOpsColors.textTertiary,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      splashRadius: 14,
    );
  }
}

/// Toggle button group for side-by-side vs. inline view mode.
class _ViewModeToggle extends StatelessWidget {
  final DiffViewMode viewMode;
  final ValueChanged<DiffViewMode> onChanged;

  const _ViewModeToggle({
    required this.viewMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeButton(
            label: 'Side by Side',
            mode: DiffViewMode.sideBySide,
          ),
          _modeButton(
            label: 'Inline',
            mode: DiffViewMode.inline,
          ),
        ],
      ),
    );
  }

  Widget _modeButton({required String label, required DiffViewMode mode}) {
    final isActive = viewMode == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? CodeOpsColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive
                ? CodeOpsColors.textPrimary
                : CodeOpsColors.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
