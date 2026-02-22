/// Visual representation of a service node in the dependency graph.
///
/// Compact card showing service name, type icon, and health indicator.
/// Highlights when selected, uses red border when part of a dependency cycle.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';
import 'service_status_badge.dart';
import 'service_type_icon.dart';

/// Service node card for the dependency graph.
///
/// Renders a ~120x60px card with [ServiceTypeIcon], service name,
/// and [HealthIndicator]. Applies visual states for selection (primary
/// accent border) and cycle membership (red border with glow).
class GraphNodeWidget extends StatelessWidget {
  /// The dependency node data.
  final DependencyNodeResponse node;

  /// Whether this node is currently selected.
  final bool isSelected;

  /// Whether this node is part of a dependency cycle.
  final bool isCycleNode;

  /// Callback when this node is tapped.
  final VoidCallback? onTap;

  /// Creates a [GraphNodeWidget].
  const GraphNodeWidget({
    super.key,
    required this.node,
    this.isSelected = false,
    this.isCycleNode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCycleNode
        ? CodeOpsColors.error
        : isSelected
            ? CodeOpsColors.primary
            : CodeOpsColors.border;
    final borderWidth = (isSelected || isCycleNode) ? 2.0 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: CodeOpsColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            if (isCycleNode)
              BoxShadow(
                color: CodeOpsColors.error.withValues(alpha: 0.25),
                blurRadius: 8,
              ),
            if (isSelected && !isCycleNode)
              BoxShadow(
                color: CodeOpsColors.primary.withValues(alpha: 0.2),
                blurRadius: 6,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service type icon + name
            Row(
              children: [
                ServiceTypeIcon(type: node.serviceType, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    node.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Health indicator
            HealthIndicator(status: node.healthStatus),
          ],
        ),
      ),
    );
  }
}
