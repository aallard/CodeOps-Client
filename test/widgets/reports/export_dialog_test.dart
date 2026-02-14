// Tests for ExportDialog.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/agent_run.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/finding.dart';
import 'package:codeops/models/qa_job.dart';
import 'package:codeops/widgets/reports/export_dialog.dart';

void main() {
  final job = QaJob(
    id: 'j1',
    projectId: 'p1',
    mode: JobMode.audit,
    status: JobStatus.completed,
    name: 'Test Audit',
  );

  Widget createWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showExportDialog(
                context: context,
                job: job,
                agentRuns: const <AgentRun>[],
                findings: const <Finding>[],
              ),
              child: const Text('Open Export'),
            ),
          ),
        ),
      ),
    );
  }

  group('ExportDialog', () {
    testWidgets('shows dialog title', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      expect(find.text('Export Report'), findsOneWidget);
    });

    testWidgets('shows format label heading', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      expect(find.text('Format'), findsOneWidget);
    });

    testWidgets('shows format chips for all formats', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      expect(find.text('Markdown'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('ZIP'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
    });

    testWidgets('shows section checkboxes for non-CSV format', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      // Default format is Markdown, so sections should be visible
      expect(find.text('Sections'), findsOneWidget);
      expect(find.text('Executive Summary'), findsOneWidget);
      expect(find.text('Agent Reports'), findsOneWidget);
      expect(find.text('Findings'), findsOneWidget);
      expect(find.text('Compliance Matrix'), findsOneWidget);
      expect(find.text('Health Trend'), findsOneWidget);
    });

    testWidgets('hides section checkboxes when CSV is selected',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      // Tap CSV chip
      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();

      expect(find.text('Sections'), findsNothing);
      expect(find.text('Executive Summary'), findsNothing);
    });

    testWidgets('shows Cancel and Export buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('cancel closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Export Report'), findsNothing);
    });
  });
}
