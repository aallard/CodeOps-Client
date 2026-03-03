// Widget tests for SessionListPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/pages/mcp/session_list_page.dart';
import 'package:codeops/providers/mcp_dashboard_providers.dart';
import 'package:codeops/providers/mcp_providers.dart';
import 'package:codeops/providers/team_providers.dart' show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';

  final sessionsPage = PageResponse<McpSession>(
    content: [
      McpSession(
        id: 's1',
        status: SessionStatus.active,
        projectName: 'CodeOps-Server',
        developerName: 'Adam',
        environment: McpEnvironment.local,
        transport: McpTransport.http,
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        totalToolCalls: 15,
        createdAt: DateTime.now(),
      ),
      McpSession(
        id: 's2',
        status: SessionStatus.completed,
        projectName: 'CodeOps-Client',
        developerName: 'Claude',
        environment: McpEnvironment.development,
        transport: McpTransport.sse,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        completedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        totalToolCalls: 42,
        createdAt: DateTime.now(),
      ),
      McpSession(
        id: 's3',
        status: SessionStatus.failed,
        projectName: 'CodeOps-Analytics',
        developerName: 'Bot',
        environment: McpEnvironment.staging,
        transport: McpTransport.http,
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        totalToolCalls: 5,
        createdAt: DateTime.now(),
      ),
    ],
    page: 0,
    size: 50,
    totalElements: 3,
    totalPages: 1,
    isLast: true,
  );

  final profiles = [
    DeveloperProfile(id: 'dp-1', isActive: true, teamId: teamId, userId: 'u1'),
  ];

  final activityEntries = <ActivityFeedEntry>[];

  Widget createWidget({
    String? selectedTeamId = teamId,
    PageResponse<McpSession>? sessions,
    bool sessionsLoading = false,
    bool sessionsError = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        mcpDashboardSessionsProvider.overrideWith((ref) {
          if (sessionsLoading) {
            return Completer<PageResponse<McpSession>>().future;
          }
          if (sessionsError) {
            return Future<PageResponse<McpSession>>.error('Server error');
          }
          return Future.value(sessions ?? sessionsPage);
        }),
        mcpRecentActivityProvider.overrideWith((ref) {
          return Future.value(activityEntries);
        }),
        mcpTeamProfilesProvider.overrideWith((ref, tid) {
          return Future.value(profiles);
        }),
      ],
      child: const MaterialApp(home: Scaffold(body: SessionListPage())),
    );
  }

  group('SessionListPage', () {
    testWidgets('renders page header with Sessions title', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('renders active sessions banner', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // s1 is active → banner shown
      expect(find.text('Active Sessions (1)'), findsOneWidget);
    });

    testWidgets('renders table header columns', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Environment'), findsOneWidget);
      expect(find.text('Calls'), findsOneWidget);
      expect(find.text('Started'), findsOneWidget);
    });

    testWidgets('renders session rows', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Adam'), findsWidgets);
      expect(find.text('Claude'), findsWidgets);
      // CodeOps-Server appears in both active banner and table
      expect(find.text('CodeOps-Server'), findsWidgets);
      expect(find.text('CodeOps-Client'), findsOneWidget);
    });

    testWidgets('renders status badges in table', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsWidgets);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('renders empty state when no team selected', (tester) async {
      await tester.pumpWidget(createWidget(selectedTeamId: null));
      await tester.pumpAndSettle();

      expect(find.text('No team selected'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(createWidget(sessionsLoading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(sessionsError: true));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders empty sessions message when no sessions',
        (tester) async {
      await tester.pumpWidget(createWidget(
        sessions: PageResponse<McpSession>.empty(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No sessions found'), findsOneWidget);
    });

    testWidgets('renders breadcrumb back to dashboard', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders refresh button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
