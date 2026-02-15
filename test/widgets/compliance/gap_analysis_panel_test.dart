// Widget tests for GapAnalysisPanel.
//
// Verifies filtering to MISSING/PARTIAL items only, grouping by spec name,
// collapsible sections, empty state, and gap count badge.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/compliance_item.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/compliance_providers.dart';
import 'package:codeops/widgets/compliance/gap_analysis_panel.dart';

void main() {
  const jobId = 'test-job-1';

  // Items covering all 4 status types.
  final allStatusItems = <ComplianceItem>[
    const ComplianceItem(
      id: 'c1',
      jobId: jobId,
      requirement: 'Must use HTTPS',
      status: ComplianceStatus.met,
      specName: 'api-spec.yaml',
      agentType: AgentType.security,
    ),
    const ComplianceItem(
      id: 'c2',
      jobId: jobId,
      requirement: 'Must encrypt at rest',
      status: ComplianceStatus.missing,
      specName: 'security-spec.md',
      agentType: AgentType.security,
      evidence: 'No encryption found',
    ),
    const ComplianceItem(
      id: 'c3',
      jobId: jobId,
      requirement: 'Must log access',
      status: ComplianceStatus.partial,
      specName: 'api-spec.yaml',
      agentType: AgentType.completeness,
      evidence: 'Only write operations logged',
    ),
    const ComplianceItem(
      id: 'c4',
      jobId: jobId,
      requirement: 'Must have mobile app',
      status: ComplianceStatus.notApplicable,
      specName: 'design-spec.md',
    ),
    const ComplianceItem(
      id: 'c5',
      jobId: jobId,
      requirement: 'Must validate input',
      status: ComplianceStatus.missing,
      specName: 'security-spec.md',
      agentType: AgentType.security,
      notes: 'XSS risk identified',
    ),
  ];

  // All items are MET.
  final allMetItems = <ComplianceItem>[
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
      status: ComplianceStatus.met,
      specName: 'security-spec.md',
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
            child: GapAnalysisPanel(jobId: jobId),
          ),
        ),
      ),
    );
  }

  group('GapAnalysisPanel', () {
    testWidgets('renders only MISSING and PARTIAL items, not MET or NOT_APPLICABLE',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      // MISSING and PARTIAL items should appear.
      expect(find.text('Must encrypt at rest'), findsOneWidget);
      expect(find.text('Must log access'), findsOneWidget);
      expect(find.text('Must validate input'), findsOneWidget);

      // MET and NOT_APPLICABLE items should not appear.
      expect(find.text('Must use HTTPS'), findsNothing);
      expect(find.text('Must have mobile app'), findsNothing);
    });

    testWidgets('groups items by spec name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      // Spec group headers should appear.
      expect(find.text('security-spec.md'), findsOneWidget);
      expect(find.text('api-spec.yaml'), findsOneWidget);
    });

    testWidgets('shows collapsible sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      // Sections start expanded — items are visible.
      expect(find.text('Must encrypt at rest'), findsOneWidget);

      // Tap the security-spec.md header to collapse it.
      await tester.tap(find.text('security-spec.md'));
      await tester.pumpAndSettle();

      // Items under that section should be hidden after collapse.
      expect(find.text('Must encrypt at rest'), findsNothing);
      expect(find.text('Must validate input'), findsNothing);

      // Items under api-spec.yaml should still be visible.
      expect(find.text('Must log access'), findsOneWidget);
    });

    testWidgets('shows "No compliance gaps found" when all items are MET',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allMetItems,
            page: 0,
            size: 50,
            totalElements: allMetItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('No compliance gaps found'), findsOneWidget);
      expect(find.text('All requirements are met.'), findsOneWidget);
    });

    testWidgets('shows gap count badge on section headers', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      // security-spec.md has 2 gaps (c2 MISSING, c5 MISSING).
      expect(find.text('2 gap(s)'), findsOneWidget);
      // api-spec.yaml has 1 gap (c3 PARTIAL).
      expect(find.text('1 gap(s)'), findsOneWidget);
    });

    testWidgets('shows total gap count in header', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      // 3 total gaps (c2, c3, c5).
      expect(find.text('3 compliance gap(s) found'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      final completer = Completer<PageResponse<ComplianceItem>>();

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => completer.future,
        ),
      ]));

      expect(find.text('Loading gap analysis...'), findsOneWidget);

      // Complete the future to avoid pending timer issues.
      completer.complete(PageResponse<ComplianceItem>.empty());
      await tester.pump();
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future<PageResponse<ComplianceItem>>.error(
            Exception('Server error'),
          ),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows evidence text for gap items', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Evidence: No encryption found'), findsOneWidget);
      expect(
          find.text('Evidence: Only write operations logged'), findsOneWidget);
    });

    testWidgets('shows notes text for gap items', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(overrides: [
        complianceJobItemsProvider(jobId).overrideWith(
          (ref) => Future.value(PageResponse<ComplianceItem>(
            content: allStatusItems,
            page: 0,
            size: 50,
            totalElements: allStatusItems.length,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Notes: XSS risk identified'), findsOneWidget);
    });
  });
}
