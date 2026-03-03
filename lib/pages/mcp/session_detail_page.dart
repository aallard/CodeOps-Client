/// MCP session detail page.
///
/// Displays at `/mcp/sessions/:sessionId` with a header showing session
/// status and metadata, followed by four tabs: Overview, Tool Calls,
/// Results, and Timeline.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/mcp_enums.dart';
import '../../models/mcp_models.dart';
import '../../providers/mcp_providers.dart';
import '../../services/navigation/cross_module_navigator.dart';
import '../../theme/colors.dart';
import '../../widgets/shared/error_panel.dart';

/// The MCP session detail page.
class SessionDetailPage extends ConsumerStatefulWidget {
  /// The session ID to display.
  final String sessionId;

  /// Creates a [SessionDetailPage].
  const SessionDetailPage({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends ConsumerState<SessionDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Refreshes session detail and tool call data.
  void _refresh() {
    ref.invalidate(mcpSessionDetailProvider(widget.sessionId));
    ref.invalidate(mcpSessionToolCallsProvider(widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(mcpSessionDetailProvider(widget.sessionId));

    return detailAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: _refresh,
      ),
      data: (detail) => Column(
        children: [
          // Header
          _SessionHeader(
            detail: detail,
            onRefresh: _refresh,
          ),
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CodeOpsColors.border),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: CodeOpsColors.primary,
              unselectedLabelColor: CodeOpsColors.textTertiary,
              indicatorColor: CodeOpsColors.primary,
              labelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Tool Calls'),
                Tab(text: 'Results'),
                Tab(text: 'Timeline'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(detail: detail),
                _ToolCallsTab(
                  detail: detail,
                  sessionId: widget.sessionId,
                ),
                _ResultsTab(result: detail.result),
                _TimelineTab(toolCalls: detail.toolCalls ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Session Header
// ---------------------------------------------------------------------------

class _SessionHeader extends StatelessWidget {
  final McpSessionDetail detail;
  final VoidCallback onRefresh;

  const _SessionHeader({
    required this.detail,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb + Refresh
          Row(
            children: [
              InkWell(
                onTap: () => context.go('/mcp/sessions'),
                borderRadius: BorderRadius.circular(4),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: CodeOpsColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Sessions',
                      style: TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: onRefresh,
                color: CodeOpsColors.textSecondary,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Session title row
          Row(
            children: [
              Text(
                detail.projectName ?? 'Session',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 12),
              _StatusBadge(status: detail.status),
            ],
          ),
          const SizedBox(height: 8),
          // Metadata chips
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _MetadataChip(
                icon: Icons.person_outline,
                label: detail.developerName ?? 'Unknown',
              ),
              _MetadataChip(
                icon: Icons.cloud_outlined,
                label: detail.environment?.displayName ?? 'Unknown',
              ),
              _MetadataChip(
                icon: Icons.swap_horiz,
                label: detail.transport?.displayName ?? 'Unknown',
              ),
              _MetadataChip(
                icon: Icons.build_outlined,
                label: '${detail.totalToolCalls ?? 0} calls',
              ),
              if (detail.startedAt != null)
                _MetadataChip(
                  icon: Icons.schedule,
                  label: DateFormat('MMM d, HH:mm')
                      .format(detail.startedAt!.toLocal()),
                ),
              if (detail.timeoutMinutes != null)
                _MetadataChip(
                  icon: Icons.timer_outlined,
                  label: '${detail.timeoutMinutes}m timeout',
                ),
            ],
          ),
          if (detail.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CodeOpsColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CodeOpsColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 16, color: CodeOpsColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: CodeOpsColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SessionStatus? status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = status?.displayName ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Returns a color for the given session status.
  static Color _statusColor(SessionStatus? status) {
    return switch (status) {
      SessionStatus.active => CodeOpsColors.success,
      SessionStatus.initializing => CodeOpsColors.success,
      SessionStatus.completing => CodeOpsColors.secondary,
      SessionStatus.completed => const Color(0xFF3B82F6),
      SessionStatus.failed => CodeOpsColors.error,
      SessionStatus.timedOut => CodeOpsColors.warning,
      SessionStatus.cancelled => CodeOpsColors.textTertiary,
      null => CodeOpsColors.textTertiary,
    };
  }
}

// ---------------------------------------------------------------------------
// Overview Tab
// ---------------------------------------------------------------------------

class _OverviewTab extends StatelessWidget {
  final McpSessionDetail detail;

  const _OverviewTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _DetailCard(
            children: [
              _DetailRow(label: 'Session ID', value: detail.id ?? '—'),
              _DetailRow(
                label: 'Status',
                value: detail.status?.displayName ?? '—',
              ),
              _DetailRow(
                label: 'Project',
                value: detail.projectName ?? '—',
              ),
              _DetailRow(
                label: 'Developer',
                value: detail.developerName ?? '—',
              ),
              _DetailRow(
                label: 'Environment',
                value: detail.environment?.displayName ?? '—',
              ),
              _DetailRow(
                label: 'Transport',
                value: detail.transport?.displayName ?? '—',
              ),
              _DetailRow(
                label: 'Total Tool Calls',
                value: '${detail.totalToolCalls ?? 0}',
              ),
              if (detail.timeoutMinutes != null)
                _DetailRow(
                  label: 'Timeout',
                  value: '${detail.timeoutMinutes} minutes',
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Timing',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _DetailCard(
            children: [
              _DetailRow(
                label: 'Started',
                value: _formatDateTime(detail.startedAt),
              ),
              _DetailRow(
                label: 'Completed',
                value: _formatDateTime(detail.completedAt),
              ),
              _DetailRow(
                label: 'Last Activity',
                value: _formatDateTime(detail.lastActivityAt),
              ),
              _DetailRow(
                label: 'Duration',
                value: _formatDuration(detail.startedAt, detail.completedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime for display.
  static String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('MMM d, yyyy HH:mm:ss').format(dt.toLocal());
  }

  /// Formats the duration between two DateTimes.
  static String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null) return '—';
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
  }
}

// ---------------------------------------------------------------------------
// Tool Calls Tab
// ---------------------------------------------------------------------------

class _ToolCallsTab extends ConsumerWidget {
  final McpSessionDetail detail;
  final String sessionId;

  const _ToolCallsTab({
    required this.detail,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolCalls = detail.toolCalls ?? [];
    final summaryAsync = ref.watch(mcpSessionToolCallsProvider(sessionId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aggregated summary
          Text(
            'Tool Call Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          summaryAsync.when(
            loading: () => const SizedBox(
              height: 48,
              child: Center(
                child:
                    CircularProgressIndicator(color: CodeOpsColors.primary),
              ),
            ),
            error: (_, __) => const Text(
              'Failed to load summary',
              style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 12),
            ),
            data: (summaries) {
              if (summaries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No tool call summary available',
                    style: TextStyle(
                      color: CodeOpsColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final s in summaries)
                    Chip(
                      label: Text(
                        '${s.toolName ?? "unknown"}: ${s.callCount ?? 0}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: CodeOpsColors.surface,
                      side: const BorderSide(color: CodeOpsColors.border),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Individual tool calls
          Text(
            'Individual Calls (${toolCalls.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (toolCalls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No tool calls recorded',
                style: TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            )
          else
            _DetailCard(
              children: [
                for (var i = 0; i < toolCalls.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 16,
                      color: CodeOpsColors.border,
                    ),
                  _ToolCallRow(call: toolCalls[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ToolCallRow extends StatelessWidget {
  final SessionToolCall call;

  const _ToolCallRow({required this.call});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (call.status) {
      ToolCallStatus.success => CodeOpsColors.success,
      ToolCallStatus.failure => CodeOpsColors.error,
      ToolCallStatus.timeout => CodeOpsColors.warning,
      ToolCallStatus.unauthorized => CodeOpsColors.error,
      null => CodeOpsColors.textTertiary,
    };

    final categoryRoute = call.toolCategory != null
        ? CrossModuleNavigator.routeForModule(call.toolCategory!, '')
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            call.status == ToolCallStatus.success
                ? Icons.check_circle_outline
                : Icons.error_outline,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.toolName ?? 'Unknown tool',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                if (call.toolCategory != null)
                  MouseRegion(
                    cursor: categoryRoute != null
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap: categoryRoute != null
                          ? () => context.go(categoryRoute)
                          : null,
                      child: Text(
                        call.toolCategory!,
                        style: TextStyle(
                          fontSize: 11,
                          color: categoryRoute != null
                              ? CodeOpsColors.primary
                              : CodeOpsColors.textTertiary,
                          decoration: categoryRoute != null
                              ? TextDecoration.underline
                              : null,
                          decorationColor: categoryRoute != null
                              ? CodeOpsColors.primary
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (call.durationMs != null)
            Text(
              '${call.durationMs}ms',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: CodeOpsColors.textSecondary,
              ),
            ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              call.status?.displayName ?? 'Unknown',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Results Tab
// ---------------------------------------------------------------------------

class _ResultsTab extends StatelessWidget {
  final SessionResult? result;

  const _ResultsTab({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No results available',
            style: TextStyle(color: CodeOpsColors.textTertiary),
          ),
        ),
      );
    }

    final r = result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r.summary != null) ...[
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CodeOpsColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CodeOpsColors.border),
              ),
              child: Text(
                r.summary!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Metrics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                label: 'Lines Added',
                value: '${r.linesAdded ?? 0}',
                color: CodeOpsColors.success,
              ),
              _MetricCard(
                label: 'Lines Removed',
                value: '${r.linesRemoved ?? 0}',
                color: CodeOpsColors.error,
              ),
              _MetricCard(
                label: 'Tests Added',
                value: '${r.testsAdded ?? 0}',
                color: CodeOpsColors.secondary,
              ),
              if (r.testCoverage != null)
                _MetricCard(
                  label: 'Coverage',
                  value: '${r.testCoverage!.toStringAsFixed(1)}%',
                  color: CodeOpsColors.primary,
                ),
              if (r.durationMinutes != null)
                _MetricCard(
                  label: 'Duration',
                  value: '${r.durationMinutes}m',
                  color: CodeOpsColors.warning,
                ),
              if (r.tokenUsage != null)
                _MetricCard(
                  label: 'Tokens',
                  value: '${r.tokenUsage}',
                  color: CodeOpsColors.textSecondary,
                ),
            ],
          ),
          if (r.commitHashesJson != null) ...[
            const SizedBox(height: 24),
            _DetailCard(
              children: [
                _DetailRow(label: 'Commits', value: r.commitHashesJson!),
              ],
            ),
          ],
          if (r.filesChangedJson != null) ...[
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(label: 'Files Changed', value: r.filesChangedJson!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline Tab
// ---------------------------------------------------------------------------

class _TimelineTab extends StatelessWidget {
  final List<SessionToolCall> toolCalls;

  const _TimelineTab({required this.toolCalls});

  @override
  Widget build(BuildContext context) {
    if (toolCalls.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No timeline data available',
            style: TextStyle(color: CodeOpsColors.textTertiary),
          ),
        ),
      );
    }

    // Sort by calledAt ascending for chronological order
    final sorted = List.of(toolCalls)
      ..sort((a, b) {
        final aTime = a.calledAt ?? a.createdAt ?? DateTime(2000);
        final bTime = b.calledAt ?? b.createdAt ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline (${sorted.length} calls)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < sorted.length; i++)
            _TimelineEntry(
              call: sorted[i],
              index: i,
              isLast: i == sorted.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final SessionToolCall call;
  final int index;
  final bool isLast;

  const _TimelineEntry({
    required this.call,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (call.status) {
      ToolCallStatus.success => CodeOpsColors.success,
      ToolCallStatus.failure => CodeOpsColors.error,
      ToolCallStatus.timeout => CodeOpsColors.warning,
      ToolCallStatus.unauthorized => CodeOpsColors.error,
      null => CodeOpsColors.textTertiary,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: CodeOpsColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CodeOpsColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CodeOpsColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        call.toolName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CodeOpsColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (call.calledAt != null)
                        Text(
                          DateFormat('HH:mm:ss')
                              .format(call.calledAt!.toLocal()),
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          call.status?.displayName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (call.durationMs != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${call.durationMs}ms',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      ],
                      if (call.toolCategory != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          call.toolCategory!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (call.errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      call.errorMessage!,
                      style: TextStyle(
                        fontSize: 11,
                        color: CodeOpsColors.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Detail Widgets
// ---------------------------------------------------------------------------

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
