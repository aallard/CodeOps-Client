// Tests for MCP session-specific providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/providers/mcp_dashboard_providers.dart';
import 'package:codeops/providers/mcp_session_providers.dart';
import 'package:codeops/providers/team_providers.dart' show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';

  final sessions = [
    McpSession(
      id: 's1',
      status: SessionStatus.active,
      projectName: 'Alpha',
      developerName: 'Adam',
      environment: McpEnvironment.local,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      totalToolCalls: 10,
    ),
    McpSession(
      id: 's2',
      status: SessionStatus.initializing,
      projectName: 'Beta',
      developerName: 'Claude',
      environment: McpEnvironment.development,
      startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      totalToolCalls: 0,
    ),
    McpSession(
      id: 's3',
      status: SessionStatus.completed,
      projectName: 'Alpha',
      developerName: 'Adam',
      environment: McpEnvironment.local,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalToolCalls: 25,
    ),
    McpSession(
      id: 's4',
      status: SessionStatus.failed,
      projectName: 'Gamma',
      developerName: 'Bot',
      environment: McpEnvironment.staging,
      startedAt: DateTime.now().subtract(const Duration(days: 1)),
      totalToolCalls: 3,
    ),
  ];

  final sessionsPage = PageResponse<McpSession>(
    content: sessions,
    page: 0,
    size: 50,
    totalElements: 4,
    totalPages: 1,
    isLast: true,
  );

  ProviderContainer createContainer({
    SessionStatus? statusFilter,
    McpEnvironment? envFilter,
    String searchQuery = '',
    bool ascending = false,
    int page = 0,
  }) {
    return ProviderContainer(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => teamId),
        mcpDashboardSessionsProvider.overrideWith(
          (ref) => Future.value(sessionsPage),
        ),
        if (statusFilter != null)
          sessionStatusFilterProvider.overrideWith((ref) => statusFilter),
        if (envFilter != null)
          sessionEnvironmentFilterProvider.overrideWith((ref) => envFilter),
        if (searchQuery.isNotEmpty)
          sessionSearchQueryProvider.overrideWith((ref) => searchQuery),
        if (ascending)
          sessionSortAscendingProvider.overrideWith((ref) => true),
        if (page > 0)
          sessionPageProvider.overrideWith((ref) => page),
      ],
    );
  }

  group('mcpActiveSessionsProvider', () {
    test('returns active and initializing sessions', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final active = container.read(mcpActiveSessionsProvider);
      expect(active.length, 2);
      expect(active.map((s) => s.id), containsAll(['s1', 's2']));
    });
  });

  group('mcpFilteredSessionsProvider', () {
    test('returns all sessions when no filters', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.length, 4);
    });

    test('filters by status', () async {
      final container = createContainer(statusFilter: SessionStatus.completed);
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 's3');
    });

    test('filters by environment', () async {
      final container = createContainer(envFilter: McpEnvironment.local);
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.length, 2);
      expect(filtered.map((s) => s.id), containsAll(['s1', 's3']));
    });

    test('filters by search query on project name', () async {
      final container = createContainer(searchQuery: 'alpha');
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.length, 2);
      expect(filtered.every((s) => s.projectName == 'Alpha'), isTrue);
    });

    test('filters by search query on developer name', () async {
      final container = createContainer(searchQuery: 'claude');
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.developerName, 'Claude');
    });

    test('sorts ascending (oldest first)', () async {
      final container = createContainer(ascending: true);
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.first.id, 's4'); // oldest
      expect(filtered.last.id, 's2'); // newest
    });

    test('sorts descending (newest first) by default', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final filtered = container.read(mcpFilteredSessionsProvider);
      expect(filtered.first.id, 's2'); // newest
      expect(filtered.last.id, 's4'); // oldest
    });
  });

  group('mcpSessionPageCountProvider', () {
    test('returns correct page count', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final pageCount = container.read(mcpSessionPageCountProvider);
      // 4 sessions / 10 per page = 1 page
      expect(pageCount, 1);
    });
  });

  group('mcpPagedSessionsProvider', () {
    test('returns sessions for current page', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final paged = container.read(mcpPagedSessionsProvider);
      expect(paged.length, 4);
    });

    test('returns empty list for out-of-bounds page', () async {
      final container = createContainer(page: 5);
      addTearDown(container.dispose);

      await container.read(mcpDashboardSessionsProvider.future);

      final paged = container.read(mcpPagedSessionsProvider);
      expect(paged, isEmpty);
    });
  });
}
