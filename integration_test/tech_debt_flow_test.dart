/// Integration test: Tech Debt page flow.
///
/// Verifies the tech debt page renders correctly with mocked providers.
library;

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/models/tech_debt_item.dart';
import 'package:codeops/pages/tech_debt_page.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:codeops/providers/tech_debt_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final testProject = Project(
    id: 'proj-1',
    teamId: 'team-1',
    name: 'Integration Test Project',
    repoUrl: 'https://github.com/test/test',
  );

  final testDebtItems = PageResponse<TechDebtItem>(
    content: [
      TechDebtItem(
        id: 'td-1',
        projectId: 'proj-1',
        category: DebtCategory.code,
        title: 'Legacy authentication module',
        description: 'Refactor to use modern auth patterns',
        status: DebtStatus.identified,
        effortEstimate: Effort.l,
        businessImpact: BusinessImpact.high,
      ),
      TechDebtItem(
        id: 'td-2',
        projectId: 'proj-1',
        category: DebtCategory.test,
        title: 'Missing integration tests',
        status: DebtStatus.planned,
        effortEstimate: Effort.m,
        businessImpact: BusinessImpact.medium,
      ),
    ],
    page: 0,
    size: 20,
    totalElements: 2,
    totalPages: 1,
    isLast: true,
  );

  testWidgets('tech debt page renders with mocked data', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamProjectsProvider.overrideWith(
            (ref) => Future.value([testProject]),
          ),
          projectTechDebtProvider(testProject.id).overrideWith(
            (ref) => Future.value(testDebtItems),
          ),
          debtSummaryProvider(testProject.id).overrideWith(
            (ref) => Future.value(<String, dynamic>{}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TechDebtPage())),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the page loaded.
    expect(find.text('Integration Test Project'), findsOneWidget);

    // Verify three-column layout rendered (VerticalDividers separate columns).
    expect(find.byType(VerticalDivider), findsNWidgets(2));

    // Verify quick actions section is present.
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Run Tech Debt Scan'), findsOneWidget);
    expect(find.text('Export Debt Report'), findsOneWidget);
  });

  testWidgets('tech debt page shows empty state with no projects',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamProjectsProvider.overrideWith(
            (ref) => Future.value(<Project>[]),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TechDebtPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No projects'), findsOneWidget);
  });
}
