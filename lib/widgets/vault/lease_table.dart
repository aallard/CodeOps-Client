/// Paginated lease table for dynamic secret leases.
///
/// Displays leases in a [DataTable] with columns for lease ID, status badge,
/// backend type, TTL, expiry countdown, created timestamp, and a revoke
/// action button for active leases. Expired and revoked rows are dimmed.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/vault_enums.dart';
import '../../models/vault_models.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';

/// A paginated [DataTable] displaying [DynamicLeaseResponse] rows.
///
/// Active leases show a countdown timer and a revoke button.
/// Expired and revoked leases are rendered with dimmed text.
class LeaseTable extends StatefulWidget {
  /// The leases to display.
  final List<DynamicLeaseResponse> leases;

  /// Called when the user taps the revoke button on an active lease.
  final ValueChanged<String>? onRevoke;

  /// Creates a [LeaseTable].
  const LeaseTable({
    super.key,
    required this.leases,
    this.onRevoke,
  });

  @override
  State<LeaseTable> createState() => _LeaseTableState();
}

class _LeaseTableState extends State<LeaseTable> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick every second to update countdown timers on active leases
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.leases.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No leases found',
            style: TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 42,
        columnSpacing: 16,
        headingTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: CodeOpsColors.textSecondary,
        ),
        columns: const [
          DataColumn(label: Text('Lease ID')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Backend')),
          DataColumn(label: Text('TTL')),
          DataColumn(label: Text('Expires')),
          DataColumn(label: Text('Created')),
          DataColumn(label: Text('Actions')),
        ],
        rows: widget.leases.map(_buildRow).toList(),
      ),
    );
  }

  DataRow _buildRow(DynamicLeaseResponse lease) {
    final isDim = lease.status != LeaseStatus.active;
    final textColor =
        isDim ? CodeOpsColors.textTertiary : CodeOpsColors.textPrimary;
    final textStyle = TextStyle(fontSize: 12, color: textColor);
    final monoStyle = TextStyle(
      fontSize: 11,
      fontFamily: 'monospace',
      color: textColor,
    );

    return DataRow(
      cells: [
        // Lease ID (truncated to 12 chars)
        DataCell(
          Tooltip(
            message: lease.leaseId,
            child: Text(
              lease.leaseId.length > 12
                  ? '${lease.leaseId.substring(0, 12)}\u2026'
                  : lease.leaseId,
              style: monoStyle,
            ),
          ),
        ),
        // Status badge
        DataCell(_StatusBadge(status: lease.status)),
        // Backend type
        DataCell(Text(lease.backendType ?? '\u2014', style: textStyle)),
        // TTL
        DataCell(Text(_formatTtl(lease.ttlSeconds), style: textStyle)),
        // Expires countdown
        DataCell(Text(_countdown(lease), style: textStyle)),
        // Created
        DataCell(Text(formatTimeAgo(lease.createdAt), style: textStyle)),
        // Actions
        DataCell(
          lease.status == LeaseStatus.active && widget.onRevoke != null
              ? TextButton(
                  onPressed: () => widget.onRevoke!(lease.leaseId),
                  style: TextButton.styleFrom(
                    foregroundColor: CodeOpsColors.error,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: const Text('Revoke'),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Formats TTL seconds as a human-readable duration.
  String _formatTtl(int seconds) {
    final d = Duration(seconds: seconds);
    if (d.inHours >= 1) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  /// Computes countdown string for active leases.
  String _countdown(DynamicLeaseResponse lease) {
    if (lease.status != LeaseStatus.active || lease.expiresAt == null) {
      return formatDateTime(lease.expiresAt);
    }
    final remaining = lease.expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    return formatDuration(remaining);
  }
}

// ---------------------------------------------------------------------------
// Status Badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final LeaseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color =
        CodeOpsColors.leaseStatusColors[status] ?? CodeOpsColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
