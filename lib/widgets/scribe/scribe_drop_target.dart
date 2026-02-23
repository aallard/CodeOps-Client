/// Drag-and-drop target wrapper for the Scribe editor.
///
/// Wraps its child with a [DropTarget] from `desktop_drop` that accepts
/// files dragged from the OS file manager and shows a visual overlay
/// while dragging.
library;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// A drag-and-drop zone that accepts files for opening in Scribe.
///
/// Wraps [child] with a [DropTarget] and shows a translucent overlay
/// with a drop hint when files are being dragged over the widget.
///
/// Example:
/// ```dart
/// ScribeDropTarget(
///   onFilesDropped: (paths) => openFiles(paths),
///   child: EditorArea(),
/// )
/// ```
class ScribeDropTarget extends StatefulWidget {
  /// The content to display inside the drop zone.
  final Widget child;

  /// Called with the list of file paths when files are dropped.
  final ValueChanged<List<String>> onFilesDropped;

  /// Creates a [ScribeDropTarget].
  const ScribeDropTarget({
    super.key,
    required this.child,
    required this.onFilesDropped,
  });

  @override
  State<ScribeDropTarget> createState() => _ScribeDropTargetState();
}

class _ScribeDropTargetState extends State<ScribeDropTarget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        final paths = details.files
            .map((f) => f.path)
            .where((p) => p.isNotEmpty)
            .toList();
        if (paths.isNotEmpty) {
          widget.onFilesDropped(paths);
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDragging)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: CodeOpsColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: CodeOpsColors.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_download,
                        size: 48,
                        color: CodeOpsColors.primary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Drop files to open',
                        style: TextStyle(
                          color: CodeOpsColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
