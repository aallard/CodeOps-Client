/// Session-specific providers for the MCP session list and detail pages.
///
/// Provides filter state, pagination, and derived views over the session
/// data fetched by [mcpDashboardSessionsProvider].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mcp_enums.dart';
import '../models/mcp_models.dart';
import 'mcp_dashboard_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Selected status filter for the session history table.
final sessionStatusFilterProvider =
    StateProvider.autoDispose<SessionStatus?>((ref) => null);

/// Selected environment filter for the session history table.
final sessionEnvironmentFilterProvider =
    StateProvider.autoDispose<McpEnvironment?>((ref) => null);

/// Text search query for filtering sessions by project or developer name.
final sessionSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Sort direction for the session history table.
///
/// `true` = ascending (oldest first), `false` = descending (newest first).
final sessionSortAscendingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

/// Current page index for the session history table (0-based).
final sessionPageProvider = StateProvider.autoDispose<int>((ref) => 0);

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns sessions in ACTIVE or INITIALIZING state from dashboard data.
final mcpActiveSessionsProvider =
    Provider.autoDispose<List<McpSession>>((ref) {
  final sessionsAsync = ref.watch(mcpDashboardSessionsProvider);
  return sessionsAsync.whenOrNull(
        data: (page) => page.content
            .where((s) =>
                s.status == SessionStatus.active ||
                s.status == SessionStatus.initializing)
            .toList(),
      ) ??
      [];
});

/// Applies status, environment, and search filters to the full session list.
final mcpFilteredSessionsProvider =
    Provider.autoDispose<List<McpSession>>((ref) {
  final sessionsAsync = ref.watch(mcpDashboardSessionsProvider);
  final statusFilter = ref.watch(sessionStatusFilterProvider);
  final envFilter = ref.watch(sessionEnvironmentFilterProvider);
  final query = ref.watch(sessionSearchQueryProvider).toLowerCase();
  final ascending = ref.watch(sessionSortAscendingProvider);

  final allSessions = sessionsAsync.whenOrNull(
        data: (page) => page.content,
      ) ??
      <McpSession>[];

  var filtered = allSessions.where((s) {
    if (statusFilter != null && s.status != statusFilter) return false;
    if (envFilter != null && s.environment != envFilter) return false;
    if (query.isNotEmpty) {
      final matchesProject =
          s.projectName?.toLowerCase().contains(query) ?? false;
      final matchesDeveloper =
          s.developerName?.toLowerCase().contains(query) ?? false;
      if (!matchesProject && !matchesDeveloper) return false;
    }
    return true;
  }).toList();

  filtered.sort((a, b) {
    final aTime = a.startedAt ?? a.createdAt ?? DateTime(2000);
    final bTime = b.startedAt ?? b.createdAt ?? DateTime(2000);
    return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
  });

  return filtered;
});

/// Page size for the session history table.
const sessionPageSize = 10;

/// Returns the total page count for the filtered session list.
final mcpSessionPageCountProvider = Provider.autoDispose<int>((ref) {
  final filtered = ref.watch(mcpFilteredSessionsProvider);
  return (filtered.length / sessionPageSize).ceil().clamp(1, 999);
});

/// Returns the current page of filtered sessions.
final mcpPagedSessionsProvider =
    Provider.autoDispose<List<McpSession>>((ref) {
  final filtered = ref.watch(mcpFilteredSessionsProvider);
  final page = ref.watch(sessionPageProvider);
  final start = page * sessionPageSize;
  if (start >= filtered.length) return [];
  final end = (start + sessionPageSize).clamp(0, filtered.length);
  return filtered.sublist(start, end);
});
