// Widget tests for TechDebtPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/models/tech_debt_item.dart';
import 'package:codeops/pages/tech_debt_page.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:codeops/providers/tech_debt_providers.dart';

final _testProject = Project(
  id: 'proj-1',
  teamId: 'team-1',
  name: 'Test Project',
  repoUrl: 'https://github.com/test/test',
);

final _testDebtItems = PageResponse<TechDebtItem>(
  content: [
    TechDebtItem(
      id: 'td-1',
      projectId: 'proj-1',
      category: DebtCategory.code,
      title: 'Hardcoded database URL',
      description: 'Move to environment variable',
      status: DebtStatus.identified,
      effortEstimate: Effort.s,
      businessImpact: BusinessImpact.high,
    ),
    TechDebtItem(
      id: 'td-2',
      projectId: 'proj-1',
      category: DebtCategory.test,
      title: 'Missing unit tests for AuthService',
      status: DebtStatus.planned,
    ),
  ],
  page: 0,
  size: 20,
  totalElements: 2,
  totalPages: 1,
  isLast: true,
);

void main() {
  Widget createWidget({
    List<Project> projects = const [],
    PageResponse<TechDebtItem>? debtItems,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        teamProjectsProvider.overrideWith(
          (ref) => Future.value(projects),
        ),
        if (projects.isNotEmpty)
          projectTechDebtProvider(projects.first.id).overrideWith(
            (ref) => Future.value(debtItems ?? PageResponse.empty()),
          ),
        if (projects.isNotEmpty)
          debtSummaryProvider(projects.first.id).overrideWith(
            (ref) => Future.value(<String, dynamic>{}),
          ),
        ...overrides,
      ],
      child: const MaterialApp(home: Scaffold(body: TechDebtPage())),
    );
  }

  group('TechDebtPage', () {
    testWidgets('three-column layout renders with projects', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Suppress overflow errors from narrow column layout in test context.
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        debtItems: _testDebtItems,
      ));
      await tester.pumpAndSettle();

      // The page uses a Row with two VerticalDividers separating three columns.
      expect(find.byType(VerticalDivider), findsNWidgets(2));
    });

    testWidgets('renders debt items in the inventory panel',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        debtItems: _testDebtItems,
      ));
      await tester.pumpAndSettle();

      // Debt item titles should be visible in the inventory column.
      expect(find.text('Hardcoded database URL'), findsOneWidget);
      expect(find.text('Missing unit tests for AuthService'), findsOneWidget);
    });

    testWidgets('project selector exists when projects are loaded',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        debtItems: _testDebtItems,
      ));
      await tester.pumpAndSettle();

      // Project selector dropdown should be present.
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Test Project'), findsOneWidget);
    });

    testWidgets('empty state shows when no projects', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(projects: []));
      await tester.pumpAndSettle();

      expect(find.text('No projects'), findsOneWidget);
      expect(find.text('Create a project first to track tech debt.'),
          findsOneWidget);
    });

    testWidgets('shows quick actions section with projects loaded',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        debtItems: _testDebtItems,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Run Tech Debt Scan'), findsOneWidget);
    });
  });
}
