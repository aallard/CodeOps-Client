/// BFS tree visualization for impact analysis results.
///
/// Renders impacted services as an expandable/collapsible tree,
/// organized by depth with severity-based coloring.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';
import 'impact_node_tile.dart';
import 'impact_summary_card.dart';

/// Displays impact analysis results as a BFS tree.
///
/// The tree shows the source service at the top with impacted services
/// organized by depth. Each depth level can be expanded or collapsed.
/// A summary card on the right shows aggregated statistics.
class ImpactTreeView extends StatefulWidget {
  /// The impact analysis response data.
  final ImpactAnalysisResponse analysis;

  /// Creates an [ImpactTreeView].
  const ImpactTreeView({super.key, required this.analysis});

  @override
  State<ImpactTreeView> createState() => _ImpactTreeViewState();
}

class _ImpactTreeViewState extends State<ImpactTreeView> {
  /// Tracks which depth levels are collapsed.
  final Set<int> _collapsedDepths = {};

  @override
  Widget build(BuildContext context) {
    if (widget.analysis.impactedServices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: CodeOpsColors.success,
            ),
            SizedBox(height: 12),
            Text(
              'No downstream impact',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CodeOpsColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'This service has no downstream dependencies.',
              style: TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tree view (main content)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source service header
                _SourceHeader(
                  sourceName: widget.analysis.sourceServiceName,
                ),
                const SizedBox(height: 8),
                // Tree nodes grouped by depth
                ..._buildTree(),
              ],
            ),
          ),
        ),
        // Summary sidebar
        SizedBox(
          width: 260,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ImpactSummaryCard(analysis: widget.analysis),
          ),
        ),
      ],
    );
  }

  /// Builds the tree by grouping services by depth and rendering
  /// depth headers with expandable sections.
  List<Widget> _buildTree() {
    final services = widget.analysis.impactedServices;

    // Group by depth.
    final depthMap = <int, List<ImpactedServiceResponse>>{};
    for (final s in services) {
      (depthMap[s.depth] ??= []).add(s);
    }

    final sortedDepths = depthMap.keys.toList()..sort();
    final widgets = <Widget>[];

    for (final depth in sortedDepths) {
      final group = depthMap[depth]!;
      final isCollapsed = _collapsedDepths.contains(depth);
      final severity = impactSeverityLabel(depth);
      final color = impactDepthColor(depth);

      // Depth header
      widgets.add(
        GestureDetector(
          onTap: () => setState(() {
            if (isCollapsed) {
              _collapsedDepths.remove(depth);
            } else {
              _collapsedDepths.add(depth);
            }
          }),
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  isCollapsed ? Icons.chevron_right : Icons.expand_more,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Depth $depth — $severity',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.length} service${group.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Service tiles (if expanded)
      if (!isCollapsed) {
        for (final service in group) {
          widgets.add(
            ImpactNodeTile(service: service),
          );
        }
      }
    }

    return widgets;
  }
}

/// Source service header at the top of the tree.
class _SourceHeader extends StatelessWidget {
  final String sourceName;

  const _SourceHeader({required this.sourceName});

  @override
  Widget build(BuildContext context) {
    final color = impactDepthColor(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            sourceName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'SOURCE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
