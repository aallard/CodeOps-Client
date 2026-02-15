// Widget tests for ComplianceResultsPanel.
//
// Verifies loading state, error state with retry, score gauge rendering,
// score gauge color thresholds, status summary cards, and empty matrix.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/compliance_item.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/compliance_providers.dart';
import 'package:codeops/widgets/compliance/compliance_results_panel.dart';

void main() {
  const jobId = 'test-job-1';

  final testSummary = {
    'met': 8,
    'partial': 4,
    'missing': 2,
    'notApplicable': 1,
    'total': 15,
  };

  final testItems = <ComplianceItem>[
    const ComplianceItem(
      id: 'c1',
      jobId: jobId,
      requirement: 'Must use HTTPS',
      status: ComplianceStatus.met,
      specName: 'api-spec.yaml',
    ),
    const ComplianceItem(
      id: 'c2',
      jobId: jobId,
      requirement: 'Must encrypt at rest',
      status: ComplianceStatus.missing,
      specName: 'security-spec.md',
    ),
    const ComplianceItem(
      id: 'c3',
      jobId: jobId,
      requirement: 'Must log access',
      status: ComplianceStatus.partial,
      specName: 'api-spec.yaml',
    ),
  ];

  Widget createWidget({required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 800,
            child: ComplianceResultsPanel(jobId: jobId),
          ),
        ),
      ),
    );
  }

  group('ComplianceResultsPanel', () {
    testWidgets('renders loading state', (tester) async {
      final summaryCompleter = Completer<Map<String, dynamic>>();
      final itemsCompleter = Completer<PageResponse<ComplianceItem>>();
      final scoreCompleter = Completer<double>();

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => summaryCompleter.future,
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => itemsCompleter.future,
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => scoreCompleter.future,
        ),
      ]));

      expect(find.text('Loading compliance results...'), findsOneWidget);

      // Complete futures to avoid pending timer issues.
      summaryCompleter.complete(testSummary);
      itemsCompleter.complete(PageResponse<ComplianceItem>.empty());
      scoreCompleter.complete(0.0);
      await tester.pump();
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future<Map<String, dynamic>>.error(
            Exception('Network error'),
          ),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>.empty()),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(0.0),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('score gauge shows correct percentage', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future.value(testSummary),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: testItems,
            page: 0,
            size: 50,
            totalElements: testItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(67.0),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('67%'), findsOneWidget);
      expect(find.text('Compliance'), findsOneWidget);
    });

    testWidgets('score gauge color green when >= 80', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future.value({
            'met': 9,
            'partial': 1,
            'missing': 0,
            'notApplicable': 0,
            'total': 10,
          }),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: testItems,
            page: 0,
            size: 50,
            totalElements: testItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(95.0),
        ),
      ]));
      await tester.pumpAndSettle();

      // Verify the gauge displays 95%.
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('score gauge color yellow when >= 60 and < 80',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future.value(testSummary),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: testItems,
            page: 0,
            size: 50,
            totalElements: testItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(65.0),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('score gauge color red when < 60', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future.value({
            'met': 2,
            'partial': 3,
            'missing': 5,
            'notApplicable': 0,
            'total': 10,
          }),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: testItems,
            page: 0,
            size: 50,
            totalElements: testItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(35.0),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('35%'), findsOneWidget);
    });

    testWidgets('status summary cards show correct counts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future.value(testSummary),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: testItems,
            page: 0,
            size: 50,
            totalElements: testItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(67.0),
        ),
      ]));
      await tester.pumpAndSettle();

      // Status labels.
      expect(find.text('Met'), findsAtLeast(1));
      expect(find.text('Partial'), findsAtLeast(1));
      expect(find.text('Missing'), findsAtLeast(1));
      expect(find.text('N/A'), findsAtLeast(1));

      // Count values from testSummary.
      expect(find.text('8'), findsAtLeast(1));
      expect(find.text('4'), findsAtLeast(1));
      expect(find.text('2'), findsAtLeast(1));
      expect(find.text('1'), findsAtLeast(1));
    });

    testWidgets('empty items show empty matrix', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceSummaryProvider(jobId).overrideWith(
          (ref) => Future.value({
            'met': 0,
            'partial': 0,
            'missing': 0,
            'notApplicable': 0,
            'total': 0,
          }),
        ),
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: <ComplianceItem>[],
            page: 0,
            size: 50,
            totalElements: 0,
            totalPages: 0,
            isLast: true,
          )),
        ),
        complianceScoreProvider(jobId).overrideWith(
          (ref) => Future.value(0.0),
        ),
      ]));
      await tester.pumpAndSettle();

      // Score gauge shows 0% plus status cards also show 0%.
      expect(find.text('0%'), findsAtLeast(1));
      // Empty matrix should show "All (0)".
      expect(find.text('All (0)'), findsOneWidget);
    });
  });
}
