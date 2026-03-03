// Widget tests for SessionDetailPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/pages/mcp/session_detail_page.dart';
import 'package:codeops/providers/mcp_providers.dart';

void main() {
  const sessionId = 'session-123';

  final toolCalls = [
    SessionToolCall(
      id: 'tc1',
      toolName: 'registry.listServices',
      toolCategory: 'registry',
      status: ToolCallStatus.success,
      durationMs: 120,
      calledAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    SessionToolCall(
      id: 'tc2',
      toolName: 'fleet.deployContainer',
      toolCategory: 'fleet',
      status: ToolCallStatus.failure,
      durationMs: 340,
      errorMessage: 'Container limit exceeded',
      calledAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  final sessionResult = SessionResult(
    id: 'r1',
    summary: 'Added authentication module with JWT support.',
    linesAdded: 450,
    linesRemoved: 30,
    testsAdded: 12,
    testCoverage: 87.5,
    durationMinutes: 25,
    tokenUsage: 15000,
    commitHashesJson: '["abc123", "def456"]',
    filesChangedJson: '["auth.dart", "router.dart"]',
  );

  final sessionDetail = McpSessionDetail(
    id: sessionId,
    status: SessionStatus.completed,
    projectName: 'CodeOps-Server',
    developerName: 'Adam',
    environment: McpEnvironment.local,
    transport: McpTransport.http,
    startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    completedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    lastActivityAt: DateTime.now().subtract(const Duration(minutes: 6)),
    timeoutMinutes: 60,
    totalToolCalls: 2,
    toolCalls: toolCalls,
    result: sessionResult,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final toolCallSummaries = [
    ToolCallSummary(toolName: 'registry.listServices', callCount: 1),
    ToolCallSummary(toolName: 'fleet.deployContainer', callCount: 1),
  ];

  Widget createWidget({
    McpSessionDetail? detail,
    bool detailLoading = false,
    bool detailError = false,
    List<ToolCallSummary>? summaries,
  }) {
    return ProviderScope(
      overrides: [
        mcpSessionDetailProvider.overrideWith((ref, id) {
          if (detailLoading) {
            return Completer<McpSessionDetail>().future;
          }
          if (detailError) {
            return Future<McpSessionDetail>.error('Server error');
          }
          return Future.value(detail ?? sessionDetail);
        }),
        mcpSessionToolCallsProvider.overrideWith((ref, id) {
          return Future.value(summaries ?? toolCallSummaries);
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SessionDetailPage(sessionId: sessionId)),
      ),
    );
  }

  group('SessionDetailPage', () {
    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(createWidget(detailLoading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(detailError: true));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders session header with project name', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('CodeOps-Server'), findsWidgets);
    });

    testWidgets('renders status badge in header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsWidgets);
    });

    testWidgets('renders metadata chips', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Adam'), findsWidgets);
      expect(find.text('Local'), findsWidgets);
      expect(find.text('HTTP'), findsWidgets);
      expect(find.text('2 calls'), findsOneWidget);
    });

    testWidgets('renders four tabs', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Tool Calls'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
    });

    testWidgets('overview tab shows session details', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Overview is the first tab, shown by default
      expect(find.text('Session Details'), findsOneWidget);
      expect(find.text('Timing'), findsOneWidget);
      expect(find.text('Session ID'), findsOneWidget);
    });

    testWidgets('tool calls tab shows summary chips', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap Tool Calls tab
      await tester.tap(find.text('Tool Calls'));
      await tester.pumpAndSettle();

      expect(find.text('Tool Call Summary'), findsOneWidget);
      expect(find.text('registry.listServices: 1'), findsOneWidget);
      expect(find.text('fleet.deployContainer: 1'), findsOneWidget);
    });

    testWidgets('tool calls tab shows individual calls', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tool Calls'));
      await tester.pumpAndSettle();

      expect(find.text('Individual Calls (2)'), findsOneWidget);
      expect(find.text('registry.listServices'), findsWidgets);
      expect(find.text('fleet.deployContainer'), findsWidgets);
      expect(find.text('120ms'), findsOneWidget);
      expect(find.text('340ms'), findsOneWidget);
    });

    testWidgets('results tab shows summary and metrics', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Results'));
      await tester.pumpAndSettle();

      expect(find.text('Summary'), findsOneWidget);
      expect(
        find.text('Added authentication module with JWT support.'),
        findsOneWidget,
      );
      expect(find.text('Metrics'), findsOneWidget);
      expect(find.text('450'), findsOneWidget); // lines added
      expect(find.text('30'), findsOneWidget); // lines removed
      expect(find.text('12'), findsOneWidget); // tests added
      expect(find.text('87.5%'), findsOneWidget); // coverage
    });

    testWidgets('timeline tab shows chronological entries', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      expect(find.text('Timeline (2 calls)'), findsOneWidget);
      // Both tool calls visible
      expect(find.text('registry.listServices'), findsWidgets);
      expect(find.text('fleet.deployContainer'), findsWidgets);
    });

    testWidgets('renders error message when session has error',
        (tester) async {
      final errorDetail = McpSessionDetail(
        id: sessionId,
        status: SessionStatus.failed,
        projectName: 'FailProject',
        errorMessage: 'Connection timed out',
        totalToolCalls: 0,
        toolCalls: [],
      );

      await tester.pumpWidget(createWidget(detail: errorDetail));
      await tester.pumpAndSettle();

      expect(find.text('Connection timed out'), findsOneWidget);
    });

    testWidgets('results tab shows no results message when null',
        (tester) async {
      final noResultDetail = McpSessionDetail(
        id: sessionId,
        status: SessionStatus.active,
        projectName: 'ActiveProject',
        totalToolCalls: 0,
        toolCalls: [],
      );

      await tester.pumpWidget(createWidget(detail: noResultDetail));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Results'));
      await tester.pumpAndSettle();

      expect(find.text('No results available'), findsOneWidget);
    });

    testWidgets('breadcrumb back to sessions is visible', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sessions'), findsWidgets);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('refresh button is visible', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
