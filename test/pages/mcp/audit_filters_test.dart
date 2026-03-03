// Widget tests for audit log filter controls.
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
        calledAt: DateTime(2026, 3, 1, 10, 0),
      ),
      developerName: 'Adam',
      sessionId: 'sess-1111',
    ),
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-2',
        toolName: 'fleet.startContainer',
        toolCategory: 'fleet',
        status: ToolCallStatus.failure,
        durationMs: 3200,
        calledAt: DateTime(2026, 3, 1, 10, 5),
      ),
      developerName: 'Claude',
      sessionId: 'sess-2222',
    ),
  ];

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => teamId),
        toolCallAuditProvider.overrideWith(
          (ref) => Future.value(auditCalls),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ToolCallAuditLogPage()),
      ),
    );
  }

  group('Audit Filters', () {
    testWidgets('renders developer filter dropdown', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // The developer dropdown hint
      expect(find.text('Developer'), findsOneWidget);
    });

    testWidgets('renders tool name filter', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Tool name...'), findsOneWidget);
    });

    testWidgets('renders status filter chips', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Status filter chips (in the filter bar)
      expect(find.widgetWithText(FilterChip, 'Success'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Failure'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Timeout'), findsOneWidget);
      expect(
          find.widgetWithText(FilterChip, 'Unauthorized'), findsOneWidget);
    });

    testWidgets('renders session ID filter', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
          find.widgetWithText(TextField, 'Session ID...'), findsOneWidget);
    });

    testWidgets('renders duration threshold filter', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Min ms...'), findsOneWidget);
    });

    testWidgets('renders category filter chips', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilterChip, 'registry'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'fleet'), findsOneWidget);
    });
  });
}
