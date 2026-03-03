// Widget tests for audit log stats bar.
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
        durationMs: 100,
        calledAt: DateTime(2026, 3, 1, 10, 0),
      ),
      developerName: 'Adam',
      sessionId: 'sess-1',
    ),
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-2',
        toolName: 'registry.listServices',
        toolCategory: 'registry',
        status: ToolCallStatus.success,
        durationMs: 200,
        calledAt: DateTime(2026, 3, 1, 10, 1),
      ),
      developerName: 'Adam',
      sessionId: 'sess-1',
    ),
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-3',
        toolName: 'fleet.startContainer',
        toolCategory: 'fleet',
        status: ToolCallStatus.failure,
        durationMs: 5000,
        calledAt: DateTime(2026, 3, 1, 10, 2),
      ),
      developerName: 'Claude',
      sessionId: 'sess-2',
    ),
    AuditToolCall(
      toolCall: SessionToolCall(
        id: 'tc-4',
        toolName: 'document.update',
        toolCategory: 'document',
        status: ToolCallStatus.success,
        durationMs: 300,
        calledAt: DateTime(2026, 3, 1, 10, 3),
      ),
      developerName: 'Adam',
      sessionId: 'sess-1',
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

  group('Audit Stats Bar', () {
    testWidgets('renders total calls stat', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Calls'), findsOneWidget);
      expect(find.text('4 / 4'), findsOneWidget);
    });

    testWidgets('renders success rate stat', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Success Rate'), findsOneWidget);
      // 3/4 = 75.0%
      expect(find.text('75.0%'), findsOneWidget);
    });

    testWidgets('renders avg duration stat', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Avg Duration'), findsOneWidget);
      // (100 + 200 + 5000 + 300) / 4 = 1400
      expect(find.text('1400 ms'), findsOneWidget);
    });

    testWidgets('renders most called tool', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Most Called'), findsOneWidget);
      // registry.listServices called 2 times
      expect(find.text('listServices (2)'), findsOneWidget);
    });

    testWidgets('renders slowest tool', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Slowest'), findsOneWidget);
      // fleet.startContainer avg = 5000ms
      expect(find.text('startContainer (5000 ms)'), findsOneWidget);
    });
  });
}
