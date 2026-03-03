// Widget tests for RunnerProgressView.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/courier/collection_runner_service.dart';
import 'package:codeops/widgets/courier/runner_progress_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _sampleResults = [
  const RequestRunResult(
    requestId: 'r1',
    requestName: 'Get Users',
    method: 'GET',
    url: 'https://api.example.com/users',
    statusCode: 200,
    durationMs: 143,
    responseSizeBytes: 2456,
    passed: true,
    testsTotal: 3,
    testsPassed: 3,
  ),
  const RequestRunResult(
    requestId: 'r2',
    requestName: 'Create User',
    method: 'POST',
    url: 'https://api.example.com/users',
    statusCode: 422,
    durationMs: 234,
    responseSizeBytes: 128,
    passed: false,
    testsTotal: 3,
    testsPassed: 1,
    error: 'Validation failed',
  ),
];

Widget buildProgressView({
  required RunProgress progress,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 900,
        height: 600,
        child: RunnerProgressView(
          progress: progress,
          onStop: () {},
          onPause: () {},
          onResume: () {},
        ),
      ),
    ),
  );
}

void setSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('RunnerProgressView', () {
    testWidgets('renders progress view', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 1,
          totalRequests: 5,
          requestName: 'Get Users',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('runner_progress_view')), findsOneWidget);
    });

    testWidgets('shows progress header with bar', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 3,
          totalRequests: 10,
          requestName: 'Create User',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('progress_header')), findsOneWidget);
      expect(find.byKey(const Key('overall_progress_bar')), findsOneWidget);
      expect(find.byKey(const Key('progress_label')), findsOneWidget);
    });

    testWidgets('shows status badge', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 1,
          totalRequests: 5,
          requestName: 'Test',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('run_status_badge')), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('shows live stats', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 2,
          totalRequests: 5,
          requestName: 'Test',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('live_stats')), findsOneWidget);
      expect(find.byKey(const Key('stat_passed')), findsOneWidget);
      expect(find.byKey(const Key('stat_failed')), findsOneWidget);
      expect(find.byKey(const Key('stat_avg_time')), findsOneWidget);
    });

    testWidgets('shows results table with rows', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 2,
          totalRequests: 5,
          requestName: 'Test',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('results_table')), findsOneWidget);
      expect(find.text('Get Users'), findsOneWidget);
      expect(find.text('Create User'), findsOneWidget);
    });

    testWidgets('shows stop button when running', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 1,
          totalRequests: 5,
          requestName: 'Test',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stop_button')), findsOneWidget);
      expect(find.byKey(const Key('pause_button')), findsOneWidget);
    });

    testWidgets('expands row on tap to show detail', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 2,
          totalRequests: 5,
          requestName: 'Test',
          status: RunProgressStatus.running,
          results: _sampleResults,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('result_row_0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expanded_detail')), findsOneWidget);
    });

    testWidgets('shows empty state when no results', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildProgressView(
        progress: const RunProgress(
          currentIteration: 1,
          totalIterations: 1,
          currentRequest: 1,
          totalRequests: 5,
          requestName: 'Test',
          status: RunProgressStatus.running,
          results: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('results_empty')), findsOneWidget);
      expect(find.text('Waiting for results…'), findsOneWidget);
    });
  });
}
