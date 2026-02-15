// Widget tests for HealthDashboardPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/pages/health_dashboard_page.dart';
import 'package:codeops/providers/health_providers.dart';
import 'package:codeops/providers/project_providers.dart';

void main() {
  const testTeamMetrics = TeamMetrics(
    teamId: 'team-1',
    totalProjects: 2,
    totalJobs: 10,
    totalFindings: 30,
    averageHealthScore: 82.0,
    projectsBelowThreshold: 0,
    openCriticalFindings: 1,
  );

  final testProjects = [
    const Project(id: 'p1', teamId: 'team-1', name: 'Alpha', healthScore: 85),
    const Project(id: 'p2', teamId: 'team-1', name: 'Beta', healthScore: 72),
  ];

  const testProjectMetrics = ProjectMetrics(
    projectId: 'p1',
    projectName: 'Alpha',
    currentHealthScore: 85,
    previousHealthScore: 80,
    totalFindings: 12,
    openCritical: 0,
  );

  final testSnapshot = HealthSnapshot(
    id: 'snap-1',
    projectId: 'p1',
    healthScore: 85,
    techDebtScore: 78,
    dependencyScore: 90,
    testCoveragePercent: 65.0,
    capturedAt: DateTime(2026, 2, 1),
  );

  final testTrend = [
    HealthSnapshot(
      id: 'snap-0',
      projectId: 'p1',
      healthScore: 80,
      capturedAt: DateTime(2026, 1, 15),
    ),
    HealthSnapshot(
      id: 'snap-1',
      projectId: 'p1',
      healthScore: 85,
      capturedAt: DateTime(2026, 2, 1),
    ),
  ];

  Widget createWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        teamMetricsProvider.overrideWith((ref) => Future.value(testTeamMetrics)),
        teamProjectsProvider
            .overrideWith((ref) => Future.value(testProjects)),
        projectMetricsProvider.overrideWith(
          (ref, projectId) => Future.value(testProjectMetrics),
        ),
        selectedHealthProjectProvider.overrideWith((ref) => null),
        healthTrendRangeProvider.overrideWith((ref) => 30),
        healthTrendProvider.overrideWith(
          (ref, projectId) => Future.value(testTrend),
        ),
        latestSnapshotProvider.overrideWith(
          (ref, projectId) => Future.value(testSnapshot),
        ),
        healthSchedulesProvider.overrideWith(
          (ref, projectId) => Future.value(<HealthSchedule>[]),
        ),
        ...overrides,
      ],
      child: const MaterialApp(home: Scaffold(body: HealthDashboardPage())),
    );
  }

  group('HealthDashboardPage', () {
    testWidgets('renders Health Dashboard heading', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Health Dashboard'), findsOneWidget);
    });

    testWidgets('renders Team Overview section', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Team Overview'), findsOneWidget);
      expect(find.text('Avg Score'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('renders Project Health section', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Project Health'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('shows placeholder when no project selected', (tester) async {
      await tester.pumpWidget(createWidget(
        overrides: [
          // Override auto-select by providing empty project list
          teamProjectsProvider
              .overrideWith((ref) => Future.value(<Project>[])),
          selectedHealthProjectProvider.overrideWith((ref) => null),
        ],
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('Select a project above to view trends and schedules.'),
        findsOneWidget,
      );
    });

    testWidgets('shows trend panel when project is selected', (tester) async {
      await tester.pumpWidget(createWidget(
        overrides: [
          selectedHealthProjectProvider.overrideWith((ref) => 'p1'),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Health Trend'), findsOneWidget);
    });
  });
}
