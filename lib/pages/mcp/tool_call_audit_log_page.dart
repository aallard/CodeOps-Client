/// MCP tool call audit log page.
///
/// Displays at `/mcp/audit-log` with a filterable, searchable table
/// of tool calls aggregated across all sessions. Includes payload
/// inspection, aggregation stats, and CSV/JSON export.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/mcp_enums.dart';
import '../../providers/mcp_audit_providers.dart';
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../widgets/shared/empty_state.dart';

/// The MCP tool call audit log page.
class ToolCallAuditLogPage extends ConsumerWidget {
  /// Creates a [ToolCallAuditLogPage].
  const ToolCallAuditLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(selectedTeamIdProvider);

    if (teamId == null) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No team selected',
        subtitle: 'Select a team to view audit logs.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 16),
          const _StatsBar(),
          const SizedBox(height: 16),
          const _FilterBar(),
          const SizedBox(height: 16),
          const _AuditTable(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.go('/mcp'),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tool Call Audit Log',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Export buttons
        PopupMenuButton<String>(
          icon: const Icon(Icons.download_outlined,
              color: CodeOpsColors.textSecondary),
          tooltip: 'Export',
          color: CodeOpsColors.surface,
          onSelected: (format) => _export(context, ref, format),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'csv', child: Text('Export CSV')),
            PopupMenuItem(value: 'json', child: Text('Export JSON')),
          ],
        ),
        IconButton(
          onPressed: () => ref.invalidate(toolCallAuditProvider),
          icon: const Icon(Icons.refresh, color: CodeOpsColors.textSecondary),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  void _export(BuildContext context, WidgetRef ref, String format) {
    final filtered = ref.read(filteredAuditCallsProvider);
    final String content;
    if (format == 'csv') {
      final buf = StringBuffer();
      buf.writeln(
          'Timestamp,Developer,Session ID,Tool Name,Category,Status,Duration (ms),Error');
      for (final e in filtered) {
        final tc = e.toolCall;
        buf.writeln([
          tc.calledAt?.toIso8601String() ?? '',
          e.developerName ?? '',
          e.sessionId ?? '',
          tc.toolName ?? '',
          tc.toolCategory ?? '',
          tc.status?.displayName ?? '',
          tc.durationMs?.toString() ?? '',
          tc.errorMessage ?? '',
        ].map((s) => '"${s.replaceAll('"', '""')}"').join(','));
      }
      content = buf.toString();
    } else {
      content = const JsonEncoder.withIndent('  ').convert(
        filtered
            .map((e) => {
                  'calledAt': e.toolCall.calledAt?.toIso8601String(),
                  'developer': e.developerName,
                  'sessionId': e.sessionId,
                  'toolName': e.toolCall.toolName,
                  'category': e.toolCall.toolCategory,
                  'status': e.toolCall.status?.displayName,
                  'durationMs': e.toolCall.durationMs,
                  'error': e.toolCall.errorMessage,
                })
            .toList(),
      );
    }

    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${format.toUpperCase()} copied to clipboard (${filtered.length} rows)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Bar
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBar extends ConsumerWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(auditStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Total Calls',
            value: '${stats.filteredCount} / ${stats.totalCount}',
            icon: Icons.functions,
          ),
          const SizedBox(width: 24),
          _StatChip(
            label: 'Success Rate',
            value: '${stats.successRate.toStringAsFixed(1)}%',
            icon: Icons.check_circle_outline,
            valueColor: stats.successRate >= 90
                ? CodeOpsColors.success
                : stats.successRate >= 70
                    ? CodeOpsColors.warning
                    : CodeOpsColors.error,
          ),
          const SizedBox(width: 24),
          _StatChip(
            label: 'Avg Duration',
            value: '${stats.avgDuration.toStringAsFixed(0)} ms',
            icon: Icons.timer_outlined,
          ),
          const SizedBox(width: 24),
          _StatChip(
            label: 'Most Called',
            value: stats.mostCalledTool != null
                ? '${_shortToolName(stats.mostCalledTool!)} (${stats.mostCalledCount})'
                : '—',
            icon: Icons.trending_up,
          ),
          const SizedBox(width: 24),
          _StatChip(
            label: 'Slowest',
            value: stats.slowestTool != null
                ? '${_shortToolName(stats.slowestTool!)} (${stats.slowestAvgDuration.toStringAsFixed(0)} ms)'
                : '—',
            icon: Icons.speed,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: CodeOpsColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? CodeOpsColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bar
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final developers = ref.watch(auditKnownDevelopersProvider);
    final categories = ref.watch(auditKnownCategoriesProvider);
    final selectedDev = ref.watch(auditDeveloperFilterProvider);
    final selectedStatuses = ref.watch(auditStatusFilterProvider);
    final toolNameFilter = ref.watch(auditToolNameFilterProvider);
    final sessionIdFilter = ref.watch(auditSessionIdFilterProvider);
    final durationThreshold = ref.watch(auditDurationThresholdProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Developer filter
          SizedBox(
            width: 160,
            child: DropdownButton<String?>(
              value: selectedDev,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Developer',
                  style: TextStyle(
                      fontSize: 12, color: CodeOpsColors.textSecondary)),
              style: const TextStyle(
                  fontSize: 12, color: CodeOpsColors.textPrimary),
              dropdownColor: CodeOpsColors.surface,
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All Developers')),
                for (final dev in developers)
                  DropdownMenuItem(value: dev, child: Text(dev)),
              ],
              onChanged: (v) =>
                  ref.read(auditDeveloperFilterProvider.notifier).state = v,
            ),
          ),
          // Tool name filter
          SizedBox(
            width: 180,
            child: TextField(
              style:
                  const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tool name...',
                hintStyle: const TextStyle(
                    fontSize: 12, color: CodeOpsColors.textSecondary),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                suffixIcon: toolNameFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 14),
                        onPressed: () => ref
                            .read(auditToolNameFilterProvider.notifier)
                            .state = '',
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(auditToolNameFilterProvider.notifier).state = v,
            ),
          ),
          // Status filter chips
          for (final status in ToolCallStatus.values)
            FilterChip(
              label: Text(status.displayName,
                  style: const TextStyle(fontSize: 10)),
              selected: selectedStatuses.contains(status),
              onSelected: (sel) {
                final current =
                    ref.read(auditStatusFilterProvider.notifier).state;
                ref.read(auditStatusFilterProvider.notifier).state = sel
                    ? {...current, status}
                    : ({...current}..remove(status));
              },
              selectedColor: _statusColor(status).withValues(alpha: 0.2),
              backgroundColor: CodeOpsColors.surface,
              side: BorderSide(
                color: selectedStatuses.contains(status)
                    ? _statusColor(status)
                    : CodeOpsColors.border,
              ),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          // Category chips
          for (final cat in categories)
            FilterChip(
              label: Text(cat, style: const TextStyle(fontSize: 10)),
              selected:
                  ref.watch(auditCategoryFilterProvider).contains(cat),
              onSelected: (sel) {
                final current =
                    ref.read(auditCategoryFilterProvider.notifier).state;
                ref.read(auditCategoryFilterProvider.notifier).state = sel
                    ? {...current, cat}
                    : ({...current}..remove(cat));
              },
              selectedColor:
                  CodeOpsColors.primary.withValues(alpha: 0.2),
              backgroundColor: CodeOpsColors.surface,
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          // Session ID filter
          SizedBox(
            width: 160,
            child: TextField(
              style:
                  const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Session ID...',
                hintStyle: const TextStyle(
                    fontSize: 12, color: CodeOpsColors.textSecondary),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                suffixIcon: sessionIdFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 14),
                        onPressed: () => ref
                            .read(auditSessionIdFilterProvider.notifier)
                            .state = '',
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(auditSessionIdFilterProvider.notifier).state = v,
            ),
          ),
          // Duration threshold
          SizedBox(
            width: 130,
            child: TextField(
              style:
                  const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Min ms...',
                hintStyle: const TextStyle(
                    fontSize: 12, color: CodeOpsColors.textSecondary),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                suffixIcon: durationThreshold != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 14),
                        onPressed: () => ref
                            .read(auditDurationThresholdProvider.notifier)
                            .state = null,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = int.tryParse(v);
                ref.read(auditDurationThresholdProvider.notifier).state =
                    parsed;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audit Table
// ─────────────────────────────────────────────────────────────────────────────

class _AuditTable extends ConsumerWidget {
  const _AuditTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(toolCallAuditProvider);

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: auditAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: CodeOpsColors.primary),
          ),
        ),
        error: (e, _) => SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Failed to load audit data',
                    style: TextStyle(
                        color: CodeOpsColors.error, fontSize: 13)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(toolCallAuditProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (_) {
          final filtered = ref.watch(filteredAuditCallsProvider);

          if (filtered.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text('No tool calls found',
                    style: TextStyle(
                        color: CodeOpsColors.textTertiary, fontSize: 13)),
              ),
            );
          }

          return Column(
            children: [
              // Header row
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('Timestamp',
                            style: _headerStyle)),
                    Expanded(
                        flex: 2,
                        child:
                            Text('Developer', style: _headerStyle)),
                    Expanded(
                        flex: 2,
                        child:
                            Text('Session', style: _headerStyle)),
                    Expanded(
                        flex: 3,
                        child:
                            Text('Tool Name', style: _headerStyle)),
                    Expanded(
                        flex: 2,
                        child:
                            Text('Category', style: _headerStyle)),
                    Expanded(
                        flex: 1,
                        child: Text('Status', style: _headerStyle)),
                    Expanded(
                        flex: 1,
                        child: Text('Duration',
                            style: _headerStyle)),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              const Divider(height: 1, color: CodeOpsColors.border),
              // Data rows
              for (final entry in filtered) ...[
                _AuditRow(entry: entry),
                if (ref.watch(auditExpandedRowProvider) ==
                    entry.toolCall.id)
                  _PayloadInspector(entry: entry),
              ],
            ],
          );
        },
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: CodeOpsColors.textSecondary,
);

// ─────────────────────────────────────────────────────────────────────────────
// Audit Row
// ─────────────────────────────────────────────────────────────────────────────

class _AuditRow extends ConsumerWidget {
  final AuditToolCall entry;

  const _AuditRow({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = entry.toolCall;
    final isExpanded = ref.watch(auditExpandedRowProvider) == tc.id;

    return InkWell(
      onTap: () {
        ref.read(auditExpandedRowProvider.notifier).state =
            isExpanded ? null : tc.id;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isExpanded
            ? CodeOpsColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            // Timestamp
            Expanded(
              flex: 2,
              child: Text(
                tc.calledAt != null
                    ? DateFormat('MMM d HH:mm:ss').format(tc.calledAt!)
                    : '—',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.textPrimary),
              ),
            ),
            // Developer
            Expanded(
              flex: 2,
              child: Text(
                entry.developerName ?? '—',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Session ID (truncated, clickable)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: entry.sessionId != null
                    ? () => context.go('/mcp/sessions/${entry.sessionId}')
                    : null,
                child: Text(
                  entry.sessionId != null
                      ? '${entry.sessionId!.substring(0, entry.sessionId!.length.clamp(0, 8))}...'
                      : '—',
                  style: TextStyle(
                    fontSize: 11,
                    color: entry.sessionId != null
                        ? CodeOpsColors.primary
                        : CodeOpsColors.textTertiary,
                  ),
                ),
              ),
            ),
            // Tool Name
            Expanded(
              flex: 3,
              child: Text(
                tc.toolName ?? '—',
                style: const TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.textPrimary,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Category
            Expanded(
              flex: 2,
              child: Text(
                tc.toolCategory ?? '—',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status badge
            Expanded(
              flex: 1,
              child: _StatusBadge(status: tc.status),
            ),
            // Duration
            Expanded(
              flex: 1,
              child: Text(
                tc.durationMs != null ? '${tc.durationMs} ms' : '—',
                style: const TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Expand icon
            SizedBox(
              width: 40,
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ToolCallStatus? status;

  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status?.displayName ?? 'Pending',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payload Inspector
// ─────────────────────────────────────────────────────────────────────────────

class _PayloadInspector extends StatelessWidget {
  final AuditToolCall entry;

  const _PayloadInspector({required this.entry});

  @override
  Widget build(BuildContext context) {
    final tc = entry.toolCall;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          if (tc.errorMessage != null &&
              (tc.status == ToolCallStatus.failure ||
                  tc.status == ToolCallStatus.timeout)) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CodeOpsColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Error',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: CodeOpsColors.error)),
                  const SizedBox(height: 2),
                  Text(
                    tc.errorMessage!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CodeOpsColors.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Timestamps
          Row(
            children: [
              if (tc.calledAt != null) ...[
                const Text('Called: ',
                    style: TextStyle(
                        fontSize: 10, color: CodeOpsColors.textSecondary)),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss.SSS')
                      .format(tc.calledAt!),
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              if (tc.durationMs != null) ...[
                const SizedBox(width: 16),
                const Text('Duration: ',
                    style: TextStyle(
                        fontSize: 10, color: CodeOpsColors.textSecondary)),
                Text(
                  '${tc.durationMs} ms',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Request JSON
          if (tc.requestJson != null) ...[
            const Text('Request',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CodeOpsColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: CodeOpsColors.border),
              ),
              child: SelectableText(
                _formatJson(tc.requestJson!),
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Response JSON
          if (tc.responseJson != null) ...[
            const Text('Response',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CodeOpsColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: CodeOpsColors.border),
              ),
              child: SelectableText(
                _formatJson(tc.responseJson!),
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a color for a [ToolCallStatus].
Color _statusColor(ToolCallStatus? status) => switch (status) {
      ToolCallStatus.success => CodeOpsColors.success,
      ToolCallStatus.failure => CodeOpsColors.error,
      ToolCallStatus.timeout => CodeOpsColors.warning,
      ToolCallStatus.unauthorized => CodeOpsColors.error,
      null => CodeOpsColors.textTertiary,
    };

/// Truncates a tool name to the last segment after the last dot.
String _shortToolName(String name) {
  final dot = name.lastIndexOf('.');
  return dot >= 0 ? name.substring(dot + 1) : name;
}

/// Attempts to pretty-print a JSON string.
String _formatJson(String raw) {
  try {
    final parsed = jsonDecode(raw);
    return const JsonEncoder.withIndent('  ').convert(parsed);
  } catch (_) {
    return raw;
  }
}
