// Tests for AgentReportTab.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/agent_run.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/providers/report_providers.dart';
import 'package:codeops/widgets/reports/agent_report_tab.dart';

void main() {
  final agentRun = AgentRun(
    id: 'r1',
    jobId: 'j1',
    agentType: AgentType.security,
    status: AgentStatus.completed,
    result: AgentResult.pass,
    score: 92,
    findingsCount: 3,
    reportS3Key: 'reports/r1.md',
  );

  Widget createWidget({
    required AgentRun run,
    required List<Override> overrides,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: AgentReportTab(agentRun: run),
          ),
        ),
      ),
    );
  }

  group('AgentReportTab', () {
    testWidgets('shows agent display name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        run: agentRun,
        overrides: [
          agentReportMarkdownProvider.overrideWith(
            (ref, s3Key) => Future.value('# Security Report\n\nAll good.'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Security'), findsOneWidget);
    });

    testWidgets('shows score in header', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        run: agentRun,
        overrides: [
          agentReportMarkdownProvider.overrideWith(
            (ref, s3Key) => Future.value('# Security Report\n\nAll good.'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('92'), findsOneWidget);
    });

    testWidgets('shows findings count', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        run: agentRun,
        overrides: [
          agentReportMarkdownProvider.overrideWith(
            (ref, s3Key) => Future.value('# Security Report\n\nAll good.'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 findings'), findsOneWidget);
    });

    testWidgets('shows result display name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        run: agentRun,
        overrides: [
          agentReportMarkdownProvider.overrideWith(
            (ref, s3Key) => Future.value('# Report'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pass'), findsOneWidget);
    });

    testWidgets('shows no-report message when reportS3Key is null',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final noReportRun = AgentRun(
        id: 'r2',
        jobId: 'j1',
        agentType: AgentType.codeQuality,
        status: AgentStatus.completed,
        result: AgentResult.warn,
        score: 70,
        findingsCount: 5,
      );

      await tester.pumpWidget(createWidget(
        run: noReportRun,
        overrides: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No detailed report available'), findsOneWidget);
    });

    testWidgets('shows loading indicator while report loads', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final completer = Completer<String>();

      await tester.pumpWidget(createWidget(
        run: agentRun,
        overrides: [
          agentReportMarkdownProvider.overrideWith(
            (ref, s3Key) => completer.future,
          ),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete so the future resolves and no pending timer remains.
      completer.complete('# Report');
      await tester.pumpAndSettle();
    });

    testWidgets('shows critical count badge when present', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final criticalRun = AgentRun(
        id: 'r3',
        jobId: 'j1',
        agentType: AgentType.security,
        status: AgentStatus.completed,
        result: AgentResult.fail,
        score: 35,
        findingsCount: 10,
        criticalCount: 4,
        reportS3Key: 'reports/r3.md',
      );

      await tester.pumpWidget(createWidget(
        run: criticalRun,
        overrides: [
          agentReportMarkdownProvider.overrideWith(
            (ref, s3Key) => Future.value('# Report'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('4 critical'), findsOneWidget);
    });
  });
}
