/// Sidebar panel showing topologically sorted startup order.
///
/// Lists services in the correct boot sequence based on Kahn's algorithm
/// dependency analysis. Each row shows order number, service name, health
/// indicator, and service type icon.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';
import 'service_status_badge.dart';
import 'service_type_icon.dart';

/// Startup order sidebar panel.
///
/// Renders a numbered list of [DependencyNodeResponse] items in the
/// order they should be started. Provides a copy button to export
/// the order as a text list.
class StartupOrderPanel extends StatelessWidget {
  /// Services in topological startup order.
  final List<DependencyNodeResponse> startupOrder;

  /// Callback when a service row is tapped.
  final ValueChanged<String>? onServiceTap;

  /// Creates a [StartupOrderPanel].
  const StartupOrderPanel({
    super.key,
    required this.startupOrder,
    this.onServiceTap,
  });

  void _copyOrder(BuildContext context) {
    final text = startupOrder
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value.name}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Startup order copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(
          right: BorderSide(color: CodeOpsColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Startup Order',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                  ),
                ),
                if (startupOrder.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy,
                        size: 14, color: CodeOpsColors.textTertiary),
                    onPressed: () => _copyOrder(context),
                    tooltip: 'Copy startup order',
                    constraints:
                        const BoxConstraints.tightFor(width: 28, height: 28),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${startupOrder.length} '
              '${startupOrder.length == 1 ? 'service' : 'services'}',
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: CodeOpsColors.divider),
          // Service list
          Expanded(
            child: startupOrder.isEmpty
                ? const Center(
                    child: Text(
                      'No services',
                      style: TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: startupOrder.length,
                    itemBuilder: (context, index) {
                      final node = startupOrder[index];
                      return _OrderRow(
                        index: index + 1,
                        node: node,
                        onTap: onServiceTap != null
                            ? () => onServiceTap!(node.serviceId)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Single row in the startup order list.
class _OrderRow extends StatelessWidget {
  final int index;
  final DependencyNodeResponse node;
  final VoidCallback? onTap;

  const _OrderRow({
    required this.index,
    required this.node,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            // Order number
            SizedBox(
              width: 24,
              child: Text(
                '$index.',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            ),
            // Health dot
            HealthIndicator(status: node.healthStatus, showLabel: false),
            const SizedBox(width: 6),
            // Service name
            Expanded(
              child: Text(
                node.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Type icon
            ServiceTypeIcon(type: node.serviceType, size: 14),
          ],
        ),
      ),
    );
  }
}
