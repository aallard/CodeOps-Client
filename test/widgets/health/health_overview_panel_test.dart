// Widget tests for HealthOverviewPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/providers/health_providers.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:codeops/widgets/health/health_overview_panel.dart';

void main() {
  const testMetrics = TeamMetrics(
    teamId: 'team-1',
    totalProjects: 3,
    totalJobs: 15,
    totalFindings: 42,
    averageHealthScore: 78.5,
    projectsBelowThreshold: 1,
    openCriticalFindings: 2,
  );

  final testProjects = [
    const Project(
      id: 'p1',
      name: 'Project Alpha',
      teamId: 'team-1',
      healthScore: 85,
      isArchived: false,
    ),
    const Project(
      id: 'p2',
      name: 'Project Beta',
      teamId: 'team-1',
      healthScore: 62,
      isArchived: false,
    ),
  ];

  Widget createWidget({
    TeamMetrics? metrics = testMetrics,
    List<Project>? projects,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        teamMetricsProvider.overrideWith(
          (ref) => Future.value(metrics),
        ),
        teamProjectsProvider.overrideWith(
          (ref) => Future.value(projects ?? testProjects),
        ),
        projectMetricsProvider.overrideWith(
          (ref, arg) => Future.value(null),
        ),
        selectedHealthProjectProvider.overrideWith((ref) => null),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: HealthOverviewPanel())),
      ),
    );
  }

  group('HealthOverviewPanel', () {
    testWidgets('renders Team Overview heading', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Team Overview'), findsOneWidget);
    });

    testWidgets('shows metric cards when team metrics exist', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Avg Score'), findsOneWidget);
      expect(find.text('79'), findsOneWidget); // 78.5 rounded
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Below Threshold'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Open Criticals'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Total Jobs'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Total Findings'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders project health cards', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Project Health'), findsOneWidget);
      expect(find.text('Project Alpha'), findsOneWidget);
      expect(find.text('Project Beta'), findsOneWidget);
    });

    testWidgets('shows no projects message when list is empty',
        (tester) async {
      await tester.pumpWidget(createWidget(projects: []));
      await tester.pumpAndSettle();

      expect(find.text('No projects found.'), findsOneWidget);
    });

    testWidgets('shows no team selected when metrics are null',
        (tester) async {
      await tester.pumpWidget(createWidget(metrics: null));
      await tester.pumpAndSettle();

      expect(find.text('No team selected.'), findsOneWidget);
    });
  });
}
