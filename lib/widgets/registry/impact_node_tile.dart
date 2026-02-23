/// Tile widget for an impacted service in the impact analysis tree.
///
/// Displays service name, depth-based severity coloring, connection type,
/// and required/optional badge. Supports expand/collapse for tree children.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';

/// Depth-based severity color for impact analysis.
///
/// Returns progressively lighter colors as depth increases:
/// - 0: Red (source)
/// - 1: Orange (critical)
/// - 2: Amber (high)
/// - 3: Yellow (medium)
/// - 4+: Light yellow (low)
Color impactDepthColor(int depth) => switch (depth) {
      0 => const Color(0xFFF44336),
      1 => const Color(0xFFFF9800),
      2 => const Color(0xFFFFC107),
      3 => const Color(0xFFFFEB3B),
      _ => const Color(0xFFFFF9C4),
    };

/// Severity label for a given depth.
String impactSeverityLabel(int depth) => switch (depth) {
      0 => 'SOURCE',
      1 => 'CRITICAL',
      2 => 'HIGH',
      3 => 'MEDIUM',
      _ => 'LOW',
    };

/// Tile representing an impacted service in the BFS tree.
///
/// Shows service name, depth indicator with severity color, connection type
/// badge, and required/optional distinction. Indentation is based on depth.
/// An optional expand/collapse chevron is shown when [hasChildren] is true.
class ImpactNodeTile extends StatelessWidget {
  /// The impacted service data.
  final ImpactedServiceResponse service;

  /// Whether this tile has child nodes (shows expand chevron).
  final bool hasChildren;

  /// Whether the children are currently expanded.
  final bool isExpanded;

  /// Callback when the expand/collapse chevron is tapped.
  final VoidCallback? onToggle;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Creates an [ImpactNodeTile].
  const ImpactNodeTile({
    super.key,
    required this.service,
    this.hasChildren = false,
    this.isExpanded = false,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = impactDepthColor(service.depth);
    final severity = impactSeverityLabel(service.depth);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: service.depth * 24.0,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CodeOpsColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            // Expand/collapse chevron
            if (hasChildren)
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              )
            else
              const SizedBox(width: 22),
            // Severity indicator dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Service name
            Expanded(
              child: Text(
                service.serviceName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Severity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                severity,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Connection type
            Text(
              service.connectionType.displayName,
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            // Required/Optional badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (service.isRequired == true
                        ? CodeOpsColors.error
                        : CodeOpsColors.textTertiary)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                service.isRequired == true ? 'Required' : 'Optional',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: service.isRequired == true
                      ? CodeOpsColors.error
                      : CodeOpsColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
