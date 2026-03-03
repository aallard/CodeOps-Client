/// MCP session list page.
///
/// Displays at `/mcp/sessions` with an active sessions banner at the top,
/// a filter toolbar (status, environment, search), a paginated history table,
/// and sort controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/mcp_enums.dart';
import '../../models/mcp_models.dart';
import '../../providers/mcp_dashboard_providers.dart';
import '../../providers/mcp_session_providers.dart';
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The MCP session list page.
class SessionListPage extends ConsumerStatefulWidget {
  /// Creates a [SessionListPage].
  const SessionListPage({super.key});

  @override
  ConsumerState<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends ConsumerState<SessionListPage> {
  /// Refreshes all session data.
  void _refresh() {
    ref.invalidate(mcpDashboardSessionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);

    if (teamId == null) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No team selected',
        subtitle: 'Select a team to view sessions.',
      );
    }

    final sessionsAsync = ref.watch(mcpDashboardSessionsProvider);

    return sessionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: _refresh,
      ),
      data: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _HeaderRow(onRefresh: _refresh),
            const SizedBox(height: 20),

            // Active sessions banner
            const _ActiveSessionsBanner(),
            const SizedBox(height: 20),

            // Filter toolbar
            const _FilterToolbar(),
            const SizedBox(height: 16),

            // History table
            const _HistoryTable(),
            const SizedBox(height: 16),

            // Pagination
            const _PaginationBar(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Row
// ---------------------------------------------------------------------------

class _HeaderRow extends StatelessWidget {
  final VoidCallback onRefresh;

  const _HeaderRow({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/mcp'),
          borderRadius: BorderRadius.circular(4),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 18, color: CodeOpsColors.primary),
              SizedBox(width: 4),
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Sessions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: onRefresh,
          color: CodeOpsColors.textSecondary,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Active Sessions Banner
// ---------------------------------------------------------------------------

class _ActiveSessionsBanner extends ConsumerWidget {
  const _ActiveSessionsBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessions = ref.watch(mcpActiveSessionsProvider);

    if (activeSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CodeOpsColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 18,
                color: CodeOpsColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Sessions (${activeSessions.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final session in activeSessions)
            _ActiveSessionRow(session: session),
        ],
      ),
    );
  }
}

class _ActiveSessionRow extends StatelessWidget {
  final McpSession session;

  const _ActiveSessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: session.id != null
          ? () => context.go('/mcp/sessions/${session.id}')
          : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            _StatusDot(status: session.status),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                session.developerName ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                session.projectName ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatDuration(session.startedAt),
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${session.totalToolCalls ?? 0} calls',
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats elapsed duration since startedAt.
  static String _formatDuration(DateTime? startedAt) {
    if (startedAt == null) return '--:--';
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed.inHours > 0) {
      return '${elapsed.inHours}h ${elapsed.inMinutes.remainder(60)}m';
    }
    return '${elapsed.inMinutes}m';
  }
}

class _StatusDot extends StatelessWidget {
  final SessionStatus? status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == SessionStatus.active
        ? CodeOpsColors.success
        : CodeOpsColors.secondary;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter Toolbar
// ---------------------------------------------------------------------------

class _FilterToolbar extends ConsumerWidget {
  const _FilterToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(sessionStatusFilterProvider);
    final envFilter = ref.watch(sessionEnvironmentFilterProvider);
    final ascending = ref.watch(sessionSortAscendingProvider);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Status dropdown
        _FilterDropdown<SessionStatus>(
          label: 'Status',
          value: statusFilter,
          items: SessionStatus.values,
          displayName: (s) => s.displayName,
          onChanged: (v) =>
              ref.read(sessionStatusFilterProvider.notifier).state = v,
        ),
        // Environment dropdown
        _FilterDropdown<McpEnvironment>(
          label: 'Environment',
          value: envFilter,
          items: McpEnvironment.values,
          displayName: (e) => e.displayName,
          onChanged: (v) =>
              ref.read(sessionEnvironmentFilterProvider.notifier).state = v,
        ),
        // Search field
        SizedBox(
          width: 220,
          height: 36,
          child: TextField(
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search project or developer...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
              prefixIcon: const Icon(Icons.search, size: 16),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: CodeOpsColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: CodeOpsColors.border),
              ),
            ),
            onChanged: (v) {
              ref.read(sessionSearchQueryProvider.notifier).state = v;
              ref.read(sessionPageProvider.notifier).state = 0;
            },
          ),
        ),
        // Sort toggle
        IconButton(
          icon: Icon(
            ascending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 18,
          ),
          tooltip: ascending ? 'Oldest first' : 'Newest first',
          onPressed: () {
            ref.read(sessionSortAscendingProvider.notifier).state = !ascending;
            ref.read(sessionPageProvider.notifier).state = 0;
          },
          color: CodeOpsColors.textSecondary,
        ),
        // Clear filters
        if (statusFilter != null || envFilter != null)
          TextButton(
            onPressed: () {
              ref.read(sessionStatusFilterProvider.notifier).state = null;
              ref.read(sessionEnvironmentFilterProvider.notifier).state = null;
              ref.read(sessionSearchQueryProvider.notifier).state = '';
              ref.read(sessionPageProvider.notifier).state = 0;
            },
            child: const Text(
              'Clear Filters',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.primary),
            ),
          ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) displayName;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.displayName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          dropdownColor: CodeOpsColors.surface,
          style: const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
          isDense: true,
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text(
                'All $label',
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ),
            for (final item in items)
              DropdownMenuItem<T?>(
                value: item,
                child: Text(
                  displayName(item),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History Table
// ---------------------------------------------------------------------------

class _HistoryTable extends ConsumerWidget {
  const _HistoryTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(mcpPagedSessionsProvider);
    final allFiltered = ref.watch(mcpFilteredSessionsProvider);

    if (allFiltered.isEmpty) {
      return const EmptyState(
        icon: Icons.history_outlined,
        title: 'No sessions found',
        subtitle: 'Adjust your filters or check back later.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        children: [
          // Table header
          const _TableHeader(),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Table rows
          for (var i = 0; i < sessions.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: CodeOpsColors.border),
            _TableRow(session: sessions[i]),
          ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Developer',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Project',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Environment',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'Calls',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Started',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final McpSession session;

  const _TableRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: session.id != null
          ? () => context.go('/mcp/sessions/${session.id}')
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                session.developerName ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                session.projectName ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 90,
              child: _StatusBadge(status: session.status),
            ),
            SizedBox(
              width: 80,
              child: Text(
                session.environment?.displayName ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${session.totalToolCalls ?? 0}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textPrimary,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                _formatTime(session.startedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.textTertiary,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a timestamp for display.
  static String _formatTime(DateTime? ts) {
    if (ts == null) return '--:--';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (ts.isAfter(today)) {
      return DateFormat.Hm().format(ts.toLocal());
    }
    return DateFormat('MMM d').format(ts.toLocal());
  }
}

// ---------------------------------------------------------------------------
// Status Badge (reusable)
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final SessionStatus? status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = status?.displayName ?? 'Unknown';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
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
// Pagination Bar
// ---------------------------------------------------------------------------

class _PaginationBar extends ConsumerWidget {
  const _PaginationBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(sessionPageProvider);
    final pageCount = ref.watch(mcpSessionPageCountProvider);
    final totalFiltered = ref.watch(mcpFilteredSessionsProvider).length;

    if (totalFiltered <= sessionPageSize) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: page > 0
              ? () => ref.read(sessionPageProvider.notifier).state = page - 1
              : null,
          color: CodeOpsColors.textSecondary,
        ),
        Text(
          'Page ${page + 1} of $pageCount',
          style: const TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textSecondary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: page < pageCount - 1
              ? () => ref.read(sessionPageProvider.notifier).state = page + 1
              : null,
          color: CodeOpsColors.textSecondary,
        ),
      ],
    );
  }
}
