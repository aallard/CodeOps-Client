/// Integration test: Health dashboard renders and allows project selection.
///
/// Uses mocked providers to avoid real API calls.
library;

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/pages/health_dashboard_page.dart';
import 'package:codeops/providers/health_providers.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('health dashboard renders and shows team overview',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Verify page heading renders
    expect(find.text('Health Dashboard'), findsOneWidget);

    // Verify Team Overview section renders
    expect(find.text('Team Overview'), findsOneWidget);
    expect(find.text('Avg Score'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
  });

  testWidgets('health dashboard shows project cards and allows selection',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Verify project cards are visible
    expect(find.text('Project Health'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    // Tap a project card to select it
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    // After selecting, trend panel should appear
    expect(find.text('Health Trend'), findsOneWidget);
  });
}
