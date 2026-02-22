/// Warning banner shown when circular dependencies are detected.
///
/// Displays an amber/red banner with service names involved in cycles.
/// Supports expanding to show all affected services when more than
/// three are involved.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';

/// Cycle detection warning banner.
///
/// Resolves service IDs to names via [allNodes] and displays a
/// descriptive warning with the count and names of affected services.
class CycleWarningBanner extends StatefulWidget {
  /// Service IDs involved in dependency cycles.
  final List<String> cycleServiceIds;

  /// All nodes in the graph for name resolution.
  final List<DependencyNodeResponse> allNodes;

  /// Creates a [CycleWarningBanner].
  const CycleWarningBanner({
    super.key,
    required this.cycleServiceIds,
    required this.allNodes,
  });

  @override
  State<CycleWarningBanner> createState() => _CycleWarningBannerState();
}

class _CycleWarningBannerState extends State<CycleWarningBanner> {
  bool _expanded = false;

  List<String> get _resolvedNames {
    final nodeMap = {
      for (final n in widget.allNodes) n.serviceId: n.name,
    };
    return widget.cycleServiceIds
        .map((id) => nodeMap[id] ?? id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cycleServiceIds.isEmpty) return const SizedBox.shrink();

    final names = _resolvedNames;
    final count = names.length;
    final preview = count <= 3
        ? names.join(', ')
        : '${names.take(3).join(', ')} +${count - 3} more';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0x33F59E0B), // amber at 20% alpha
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.warning),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: count > 3 ? () => setState(() => _expanded = !_expanded) : null,
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: CodeOpsColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Circular dependencies detected involving $count '
                    '${count == 1 ? 'service' : 'services'}: $preview',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CodeOpsColors.warning,
                    ),
                  ),
                ),
                if (count > 3)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: CodeOpsColors.warning,
                  ),
              ],
            ),
          ),
          if (_expanded && count > 3) ...[
            const SizedBox(height: 6),
            Text(
              names.join(', '),
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
