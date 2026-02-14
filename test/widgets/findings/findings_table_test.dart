// Tests for FindingsTable.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/finding.dart';
import 'package:codeops/providers/finding_providers.dart';
import 'package:codeops/widgets/findings/findings_table.dart';

void main() {
  final findings = [
    const Finding(
      id: 'f1',
      jobId: 'j1',
      agentType: AgentType.security,
      severity: Severity.critical,
      title: 'SQL Injection in LoginService',
      filePath: 'src/auth/login.dart',
      lineNumber: 42,
      status: FindingStatus.open,
    ),
    const Finding(
      id: 'f2',
      jobId: 'j1',
      agentType: AgentType.codeQuality,
      severity: Severity.medium,
      title: 'Complex method exceeds threshold',
      filePath: 'src/utils/parser.dart',
      lineNumber: 110,
      status: FindingStatus.acknowledged,
    ),
    const Finding(
      id: 'f3',
      jobId: 'j1',
      agentType: AgentType.performance,
      severity: Severity.low,
      title: 'Unnecessary object allocation',
      filePath: 'src/core/engine.dart',
      status: FindingStatus.fixed,
    ),
  ];

  Widget createWidget({
    List<Finding> findingList = const [],
    int currentPage = 0,
    int totalPages = 1,
    ValueChanged<Finding>? onFindingTap,
    ValueChanged<int>? onPageChanged,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        selectedFindingIdsProvider.overrideWith((ref) => <String>{}),
        ...overrides,
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            width: 1200,
            child: FindingsTable(
              findings: findingList,
              currentPage: currentPage,
              totalPages: totalPages,
              onFindingTap: onFindingTap,
              onPageChanged: onPageChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('FindingsTable', () {
    testWidgets('renders finding titles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.text('SQL Injection in LoginService'), findsOneWidget);
      expect(find.text('Complex method exceeds threshold'), findsOneWidget);
      expect(find.text('Unnecessary object allocation'), findsOneWidget);
    });

    testWidgets('renders severity badges', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
    });

    testWidgets('renders file paths', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.text('src/auth/login.dart:42'), findsOneWidget);
      expect(find.text('src/utils/parser.dart:110'), findsOneWidget);
    });

    testWidgets('renders agent display names', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Code Quality'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('renders status badges', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Acknowledged'), findsOneWidget);
      expect(find.text('Fixed'), findsOneWidget);
    });

    testWidgets('renders column headers', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.text('Severity'), findsOneWidget);
      expect(find.text('Agent'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('shows pagination when totalPages > 1', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        findingList: findings,
        currentPage: 0,
        totalPages: 3,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Page 1 of 3'), findsOneWidget);
    });

    testWidgets('hides pagination when totalPages is 1', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        findingList: findings,
        currentPage: 0,
        totalPages: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Page'), findsNothing);
    });

    testWidgets('renders DataTable widget', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(findingList: findings));
      await tester.pumpAndSettle();

      expect(find.byType(DataTable), findsOneWidget);
    });
  });
}
