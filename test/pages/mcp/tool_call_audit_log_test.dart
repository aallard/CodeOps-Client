// Widget tests for ToolCallAuditLogPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/pages/mcp/tool_call_audit_log_page.dart';
import 'package:codeops/providers/mcp_audit_providers.dart';
import 'package:codeops/providers/team_providers.dart'
    show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';

  final auditCalls = [
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-1',
        toolName: 'registry.listServices',
        toolCategory: 'registry',
        status: ToolCallStatus.success,
        durationMs: 150,
        requestJson: '{"teamId": "team-1"}',
        responseJson: '{"services": []}',
        calledAt: DateTime(2026, 3, 1, 10, 0),
      ),
      developerName: 'Adam',
      sessionId: 'sess-1234-5678',
      projectName: 'CodeOps-Server',
    ),
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-2',
        toolName: 'fleet.startContainer',
        toolCategory: 'fleet',
        status: ToolCallStatus.failure,
        durationMs: 3200,
        requestJson: '{"containerId": "abc"}',
        errorMessage: 'Container not found',
        calledAt: DateTime(2026, 3, 1, 10, 5),
      ),
      developerName: 'Claude',
      sessionId: 'sess-9999-0000',
      projectName: 'CodeOps-Client',
    ),
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-3',
        toolName: 'document.update',
        toolCategory: 'document',
        status: ToolCallStatus.timeout,
        durationMs: 5000,
        calledAt: DateTime(2026, 3, 1, 10, 10),
      ),
      developerName: 'Adam',
      sessionId: 'sess-1234-5678',
      projectName: 'CodeOps-Server',
    ),
  ];

  Widget createWidget({
    bool loading = false,
    bool empty = false,
    bool error = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => teamId),
        toolCallAuditProvider.overrideWith((ref) {
          if (loading) return Completer<List<AuditToolCall>>().future;
          if (error) {
            return Future<List<AuditToolCall>>.error('Server error');
          }
          if (empty) return Future.value([]);
          return Future.value(auditCalls);
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ToolCallAuditLogPage()),
      ),
    );
  }

  group('ToolCallAuditLogPage', () {
    testWidgets('renders header with breadcrumb', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Tool Call Audit Log'), findsOneWidget);
    });

    testWidgets('renders table column headers', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);
      expect(find.text('Tool Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
    });

    testWidgets('renders tool call rows', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('registry.listServices'), findsOneWidget);
      expect(find.text('fleet.startContainer'), findsOneWidget);
      expect(find.text('document.update'), findsOneWidget);
    });

    testWidgets('renders status badges', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsWidgets);
      expect(find.text('Failure'), findsWidgets);
      expect(find.text('Timeout'), findsWidgets);
    });

    testWidgets('expands row to show payload inspector', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap the first row to expand
      await tester.tap(find.text('registry.listServices'));
      await tester.pumpAndSettle();

      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Response'), findsOneWidget);
    });

    testWidgets('shows request JSON in payload inspector', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('registry.listServices'));
      await tester.pumpAndSettle();

      expect(find.textContaining('teamId'), findsOneWidget);
    });

    testWidgets('shows error message for failed calls', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('fleet.startContainer'));
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Container not found'), findsOneWidget);
    });

    testWidgets('shows empty state when no calls', (tester) async {
      await tester.pumpWidget(createWidget(empty: true));
      await tester.pumpAndSettle();

      expect(find.text('No tool calls found'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(createWidget(loading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows no team state', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          selectedTeamIdProvider.overrideWith((ref) => null),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ToolCallAuditLogPage()),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No team selected'), findsOneWidget);
    });
  });
}
