/// Tool call audit log providers for the MCP module.
///
/// Assembles cross-session tool call data, manages filter state,
/// computes aggregation statistics, and exposes filtered/sorted
/// views for the audit log page.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mcp_enums.dart';
import '../models/mcp_models.dart';
import 'mcp_providers.dart';
import 'team_providers.dart' show selectedTeamIdProvider;

// ─────────────────────────────────────────────────────────────────────────────
// Enriched Tool Call Model
// ─────────────────────────────────────────────────────────────────────────────

/// A tool call enriched with its parent session metadata.
class AuditToolCall {
  /// The underlying tool call.
  final SessionToolCall toolCall;

  /// Developer name from the session.
  final String? developerName;

  /// Session ID.
  final String? sessionId;

  /// Project name from the session.
  final String? projectName;

  /// Creates an [AuditToolCall].
  const AuditToolCall({
    required this.toolCall,
    this.developerName,
    this.sessionId,
    this.projectName,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Developer name filter.
final auditDeveloperFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Tool name text filter.
final auditToolNameFilterProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Category filter (multi-select).
final auditCategoryFilterProvider =
    StateProvider.autoDispose<Set<String>>((ref) => {});

/// Status filter (multi-select).
final auditStatusFilterProvider =
    StateProvider.autoDispose<Set<ToolCallStatus>>((ref) => {});

/// Session ID text filter.
final auditSessionIdFilterProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Duration threshold filter (ms). Null = no filter.
final auditDurationThresholdProvider =
    StateProvider.autoDispose<int?>((ref) => null);

/// Date range filter start.
final auditDateStartProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

/// Date range filter end.
final auditDateEndProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

/// Expanded row ID for payload inspector.
final auditExpandedRowProvider =
    StateProvider.autoDispose<String?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Data Assembly Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Assembles tool calls across all recent sessions for the current team.
///
/// 1. Loads recent sessions via getMySessions
/// 2. For each session, loads full detail (which includes toolCalls)
/// 3. Flattens into a sorted list of [AuditToolCall]
final toolCallAuditProvider =
    FutureProvider.autoDispose<List<AuditToolCall>>((ref) async {
  final teamId = ref.watch(selectedTeamIdProvider);
  if (teamId == null) return [];

  final api = ref.watch(mcpApiProvider);

  // Load recent sessions (first page)
  final sessionsPage = await api.getMySessions(teamId: teamId, size: 50);
  final sessions = sessionsPage.content;

  if (sessions.isEmpty) return [];

  // Load full detail for each session to get tool calls
  final allCalls = <AuditToolCall>[];
  for (final session in sessions) {
    if (session.id == null) continue;
    try {
      final detail = await api.getSession(session.id!);
      if (detail.toolCalls != null) {
        for (final tc in detail.toolCalls!) {
          allCalls.add(AuditToolCall(
            toolCall: tc,
            developerName: detail.developerName,
            sessionId: detail.id,
            projectName: detail.projectName,
          ));
        }
      }
    } catch (_) {
      // Skip sessions that fail to load
    }
  }

  // Sort by calledAt descending (most recent first)
  allCalls.sort((a, b) {
    final aTime = a.toolCall.calledAt ?? DateTime(2000);
    final bTime = b.toolCall.calledAt ?? DateTime(2000);
    return bTime.compareTo(aTime);
  });

  return allCalls;
});

// ─────────────────────────────────────────────────────────────────────────────
// Filtered Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Applies all active filters to the audit tool call list.
final filteredAuditCallsProvider =
    Provider.autoDispose<List<AuditToolCall>>((ref) {
  final callsAsync = ref.watch(toolCallAuditProvider);
  final calls =
      callsAsync.whenOrNull(data: (d) => d) ?? <AuditToolCall>[];

  final developer = ref.watch(auditDeveloperFilterProvider);
  final toolName = ref.watch(auditToolNameFilterProvider).toLowerCase();
  final categories = ref.watch(auditCategoryFilterProvider);
  final statuses = ref.watch(auditStatusFilterProvider);
  final sessionId = ref.watch(auditSessionIdFilterProvider).toLowerCase();
  final durationThreshold = ref.watch(auditDurationThresholdProvider);
  final dateStart = ref.watch(auditDateStartProvider);
  final dateEnd = ref.watch(auditDateEndProvider);

  return calls.where((entry) {
    final tc = entry.toolCall;

    // Developer filter
    if (developer != null && entry.developerName != developer) return false;

    // Tool name filter
    if (toolName.isNotEmpty) {
      final name = (tc.toolName ?? '').toLowerCase();
      if (!name.contains(toolName)) return false;
    }

    // Category filter
    if (categories.isNotEmpty) {
      if (tc.toolCategory == null || !categories.contains(tc.toolCategory)) {
        return false;
      }
    }

    // Status filter
    if (statuses.isNotEmpty) {
      if (tc.status == null || !statuses.contains(tc.status)) return false;
    }

    // Session ID filter
    if (sessionId.isNotEmpty) {
      final sid = (entry.sessionId ?? '').toLowerCase();
      if (!sid.contains(sessionId)) return false;
    }

    // Duration threshold
    if (durationThreshold != null) {
      if (tc.durationMs == null || tc.durationMs! < durationThreshold) {
        return false;
      }
    }

    // Date range
    if (dateStart != null && tc.calledAt != null) {
      if (tc.calledAt!.isBefore(dateStart)) return false;
    }
    if (dateEnd != null && tc.calledAt != null) {
      if (tc.calledAt!.isAfter(dateEnd)) return false;
    }

    return true;
  }).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Aggregation Stats
// ─────────────────────────────────────────────────────────────────────────────

/// Aggregation statistics for the audit log.
class AuditStats {
  /// Total filtered tool calls.
  final int filteredCount;

  /// Total unfiltered tool calls.
  final int totalCount;

  /// Success rate as a percentage (0-100).
  final double successRate;

  /// Average duration in milliseconds.
  final double avgDuration;

  /// Most frequently called tool name.
  final String? mostCalledTool;

  /// Count of the most called tool.
  final int mostCalledCount;

  /// Slowest tool by average duration.
  final String? slowestTool;

  /// Average duration of the slowest tool.
  final double slowestAvgDuration;

  /// Creates an [AuditStats].
  const AuditStats({
    required this.filteredCount,
    required this.totalCount,
    required this.successRate,
    required this.avgDuration,
    this.mostCalledTool,
    required this.mostCalledCount,
    this.slowestTool,
    required this.slowestAvgDuration,
  });
}

/// Computes aggregation statistics from filtered and total tool calls.
final auditStatsProvider = Provider.autoDispose<AuditStats>((ref) {
  final allAsync = ref.watch(toolCallAuditProvider);
  final all = allAsync.whenOrNull(data: (d) => d) ?? <AuditToolCall>[];
  final filtered = ref.watch(filteredAuditCallsProvider);

  if (all.isEmpty) {
    return const AuditStats(
      filteredCount: 0,
      totalCount: 0,
      successRate: 0,
      avgDuration: 0,
      mostCalledCount: 0,
      slowestAvgDuration: 0,
    );
  }

  // Success rate from filtered
  final successCount =
      filtered.where((e) => e.toolCall.status == ToolCallStatus.success).length;
  final successRate =
      filtered.isEmpty ? 0.0 : (successCount / filtered.length) * 100;

  // Average duration from filtered
  final durations = filtered
      .where((e) => e.toolCall.durationMs != null)
      .map((e) => e.toolCall.durationMs!)
      .toList();
  final avgDuration =
      durations.isEmpty ? 0.0 : durations.reduce((a, b) => a + b) / durations.length;

  // Most called tool from filtered
  final toolCounts = <String, int>{};
  for (final e in filtered) {
    final name = e.toolCall.toolName;
    if (name != null) toolCounts[name] = (toolCounts[name] ?? 0) + 1;
  }
  String? mostCalled;
  int mostCalledCount = 0;
  for (final entry in toolCounts.entries) {
    if (entry.value > mostCalledCount) {
      mostCalled = entry.key;
      mostCalledCount = entry.value;
    }
  }

  // Slowest tool by average duration from filtered
  final toolDurations = <String, List<int>>{};
  for (final e in filtered) {
    final name = e.toolCall.toolName;
    final dur = e.toolCall.durationMs;
    if (name != null && dur != null) {
      toolDurations.putIfAbsent(name, () => []).add(dur);
    }
  }
  String? slowest;
  double slowestAvg = 0;
  for (final entry in toolDurations.entries) {
    final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
    if (avg > slowestAvg) {
      slowest = entry.key;
      slowestAvg = avg;
    }
  }

  return AuditStats(
    filteredCount: filtered.length,
    totalCount: all.length,
    successRate: successRate,
    avgDuration: avgDuration,
    mostCalledTool: mostCalled,
    mostCalledCount: mostCalledCount,
    slowestTool: slowest,
    slowestAvgDuration: slowestAvg,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived — Known Values for Autocomplete
// ─────────────────────────────────────────────────────────────────────────────

/// Distinct developer names from loaded audit data.
final auditKnownDevelopersProvider =
    Provider.autoDispose<List<String>>((ref) {
  final calls =
      ref.watch(toolCallAuditProvider).whenOrNull(data: (d) => d) ?? [];
  final names = <String>{};
  for (final e in calls) {
    if (e.developerName != null) names.add(e.developerName!);
  }
  return names.toList()..sort();
});

/// Distinct tool categories from loaded audit data.
final auditKnownCategoriesProvider =
    Provider.autoDispose<List<String>>((ref) {
  final calls =
      ref.watch(toolCallAuditProvider).whenOrNull(data: (d) => d) ?? [];
  final categories = <String>{};
  for (final e in calls) {
    if (e.toolCall.toolCategory != null) {
      categories.add(e.toolCall.toolCategory!);
    }
  }
  return categories.toList()..sort();
});
