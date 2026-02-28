/// Colored dot badge for [ContainerStatus] display.
///
/// Shows a small colored circle followed by the status display name.
/// Color mapping follows Docker conventions: green for running,
/// gray for stopped/exited, red for dead/unhealthy, etc.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_enums.dart';
import '../../theme/colors.dart';

/// A colored dot and label indicating a container's lifecycle status.
class ContainerStatusBadge extends StatelessWidget {
  /// The container status to display.
  final ContainerStatus status;

  /// Optional font size for the label text.
  final double fontSize;

  /// Optional dot size.
  final double dotSize;

  /// Creates a [ContainerStatusBadge].
  const ContainerStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
    this.dotSize = 8,
  });

  /// Maps a [ContainerStatus] to its semantic color.
  static Color colorFor(ContainerStatus status) => switch (status) {
        ContainerStatus.running => CodeOpsColors.success,
        ContainerStatus.created => const Color(0xFF3B82F6),
        ContainerStatus.paused => CodeOpsColors.warning,
        ContainerStatus.restarting => const Color(0xFFF97316),
        ContainerStatus.removing => CodeOpsColors.textTertiary,
        ContainerStatus.exited => CodeOpsColors.textTertiary,
        ContainerStatus.dead => CodeOpsColors.error,
        ContainerStatus.stopped => CodeOpsColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status.displayName,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
