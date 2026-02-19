/// Paginated rotation history table for a secret.
///
/// Shows rotation entries with version transition, success/fail badge,
/// duration, strategy badge, trigger source, and error details for
/// failed rotations in an expandable row.
library;

import 'package:flutter/material.dart';

import '../../models/vault_models.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';

/// Displays a list of [RotationHistoryResponse] entries with status
/// badges, version transitions, and expandable error messages.
class RotationHistoryTable extends StatefulWidget {
  /// The rotation history entries to display.
  final List<RotationHistoryResponse> entries;

  /// Creates a [RotationHistoryTable].
  const RotationHistoryTable({super.key, required this.entries});

  @override
  State<RotationHistoryTable> createState() => _RotationHistoryTableState();
}

class _RotationHistoryTableState extends State<RotationHistoryTable> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No rotation history',
            style: TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
          ),
        ),
      );
    }

    return Column(
      children: widget.entries.map((entry) => _buildRow(entry)).toList(),
    );
  }

  Widget _buildRow(RotationHistoryResponse entry) {
    final isExpanded = _expandedId == entry.id;
    final strategyColor =
        CodeOpsColors.rotationStrategyColors[entry.strategy] ??
            CodeOpsColors.textTertiary;

    return Column(
      children: [
        InkWell(
          onTap: entry.errorMessage != null
              ? () => setState(() {
                    _expandedId = isExpanded ? null : entry.id;
                  })
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                // Success/Fail icon
                Icon(
                  entry.success
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 16,
                  color: entry.success
                      ? CodeOpsColors.success
                      : CodeOpsColors.error,
                ),
                const SizedBox(width: 8),
                // Version transition
                Text(
                  entry.success
                      ? 'v${entry.previousVersion ?? '?'}\u2192v${entry.newVersion ?? '?'}'
                      : 'v${entry.previousVersion ?? '?'}\u2192FAILED',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: entry.success
                        ? CodeOpsColors.textPrimary
                        : CodeOpsColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                // Duration
                if (entry.durationMs != null)
                  Text(
                    '${entry.durationMs}ms',
                    style: const TextStyle(
                      fontSize: 10,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                const Spacer(),
                // Strategy badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: strategyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    entry.strategy.displayName,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: strategyColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Trigger source
                Text(
                  entry.triggeredByUserId != null ? 'manual' : 'auto',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 6),
                // Timestamp
                Text(
                  formatTimeAgo(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                // Expand icon for errors
                if (entry.errorMessage != null)
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                    color: CodeOpsColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
        // Expanded error message
        if (isExpanded && entry.errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: CodeOpsColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.errorMessage!,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: CodeOpsColors.error,
              ),
            ),
          ),
        const Divider(height: 1, color: CodeOpsColors.border),
      ],
    );
  }
}
