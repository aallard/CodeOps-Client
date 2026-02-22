/// Floating overlay with zoom, pan, and layout controls for the graph.
///
/// Positioned at the bottom-right of the graph canvas. Provides zoom
/// in/out, reset view, fit-to-screen, and layout algorithm selection.
library;

import 'package:flutter/material.dart';

import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';

/// Graph zoom and layout control overlay.
///
/// Renders a vertical column of icon buttons plus a layout dropdown,
/// styled to float over the graph canvas with a semi-transparent background.
class GraphControls extends StatelessWidget {
  /// Callback for zoom in.
  final VoidCallback onZoomIn;

  /// Callback for zoom out.
  final VoidCallback onZoomOut;

  /// Callback to reset the view to default.
  final VoidCallback onReset;

  /// Callback to fit the graph to the visible area.
  final VoidCallback onFitToScreen;

  /// Currently selected layout algorithm.
  final GraphLayoutType currentLayout;

  /// Callback when the layout algorithm is changed.
  final ValueChanged<GraphLayoutType> onLayoutChanged;

  /// Creates a [GraphControls].
  const GraphControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    required this.onFitToScreen,
    required this.currentLayout,
    required this.onLayoutChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(
            icon: Icons.add,
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
          ),
          _ControlButton(
            icon: Icons.remove,
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
          ),
          _ControlButton(
            icon: Icons.refresh,
            tooltip: 'Reset view',
            onPressed: onReset,
          ),
          _ControlButton(
            icon: Icons.fit_screen,
            tooltip: 'Fit to screen',
            onPressed: onFitToScreen,
          ),
          const Divider(height: 8, color: CodeOpsColors.divider),
          // Layout selector
          Tooltip(
            message: 'Layout algorithm',
            child: PopupMenuButton<GraphLayoutType>(
              initialValue: currentLayout,
              onSelected: onLayoutChanged,
              tooltip: '',
              icon: const Icon(Icons.account_tree,
                  size: 18, color: CodeOpsColors.textSecondary),
              color: CodeOpsColors.surface,
              itemBuilder: (_) => GraphLayoutType.values
                  .map((t) => PopupMenuItem(
                        value: t,
                        child: Text(
                          t.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: t == currentLayout
                                ? CodeOpsColors.primary
                                : CodeOpsColors.textPrimary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small icon button for graph controls.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: CodeOpsColors.textSecondary),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
    );
  }
}
