// Widget tests for RunSummaryView.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/courier/collection_runner_service.dart';
import 'package:codeops/widgets/courier/run_summary_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _allPassed = [
  const RequestRunResult(
    requestId: 'r1',
    requestName: 'Get Users',
    method: 'GET',
    url: 'https://api.example.com/users',
    statusCode: 200,
    durationMs: 100,
    passed: true,
    testsTotal: 2,
    testsPassed: 2,
  ),
  const RequestRunResult(
    requestId: 'r2',
    requestName: 'Get User',
    method: 'GET',
    url: 'https://api.example.com/users/1',
    statusCode: 200,
    durationMs: 80,
    passed: true,
    testsTotal: 1,
    testsPassed: 1,
  ),
];

final _mixedResults = [
  const RequestRunResult(
    requestId: 'r1',
    requestName: 'Get Users',
    method: 'GET',
    url: 'https://api.example.com/users',
    statusCode: 200,
    durationMs: 100,
    passed: true,
    iteration: 1,
  ),
  const RequestRunResult(
    requestId: 'r2',
    requestName: 'Create User',
    method: 'POST',
    url: 'https://api.example.com/users',
    statusCode: 500,
    durationMs: 250,
    passed: false,
    error: 'Server error',
    iteration: 1,
  ),
  const RequestRunResult(
    requestId: 'r1',
    requestName: 'Get Users',
    method: 'GET',
    url: 'https://api.example.com/users',
    statusCode: 200,
    durationMs: 90,
    passed: true,
    iteration: 2,
  ),
  const RequestRunResult(
    requestId: 'r2',
    requestName: 'Create User',
    method: 'POST',
    url: 'https://api.example.com/users',
    statusCode: 201,
    durationMs: 120,
    passed: true,
    iteration: 2,
  ),
];

Widget buildSummary({
  required List<RequestRunResult> results,
  int iterations = 1,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 900,
        height: 600,
        child: RunSummaryView(
          results: results,
          iterations: iterations,
          onRunAgain: () {},
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
  group('RunSummaryView', () {
    testWidgets('renders summary view', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(results: _allPassed));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('run_summary_view')), findsOneWidget);
    });

    testWidgets('shows summary header with pass rate', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(results: _allPassed));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('summary_header')), findsOneWidget);
      expect(find.byKey(const Key('pass_rate_indicator')), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('All tests passed'), findsOneWidget);
    });

    testWidgets('shows summary stats', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(results: _allPassed));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('summary_stats')), findsOneWidget);
      expect(find.byKey(const Key('stat_total_requests')), findsOneWidget);
      expect(find.byKey(const Key('stat_passed_requests')), findsOneWidget);
      expect(find.byKey(const Key('stat_failed_requests')), findsOneWidget);
      expect(find.byKey(const Key('stat_avg_time')), findsOneWidget);
    });

    testWidgets('shows failure message when some fail', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(
        results: _mixedResults,
        iterations: 2,
      ));
      await tester.pumpAndSettle();

      expect(find.text('1 request(s) failed'), findsOneWidget);
    });

    testWidgets('shows iteration breakdown for multi-iteration runs',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(
        results: _mixedResults,
        iterations: 2,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('iteration_breakdown')), findsOneWidget);
      expect(find.text('Iteration Breakdown'), findsOneWidget);
      expect(find.text('Iteration 1'), findsOneWidget);
      expect(find.text('Iteration 2'), findsOneWidget);
    });

    testWidgets('shows export bar with JSON and CSV buttons', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(results: _allPassed));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('export_bar')), findsOneWidget);
      expect(find.byKey(const Key('export_json_button')), findsOneWidget);
      expect(find.byKey(const Key('export_csv_button')), findsOneWidget);
    });

    testWidgets('shows results list', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(results: _allPassed));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('summary_results_list')), findsOneWidget);
      expect(find.text('Get Users'), findsOneWidget);
      expect(find.text('Get User'), findsOneWidget);
    });

    testWidgets('shows run again button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildSummary(results: _allPassed));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('run_again_button')), findsOneWidget);
    });
  });
}
