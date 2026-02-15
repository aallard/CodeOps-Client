// Widget tests for HealthTrendPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/health_providers.dart';
import 'package:codeops/widgets/health/health_trend_panel.dart';

void main() {
  final testSnapshot = HealthSnapshot(
    id: 'snap-1',
    projectId: 'proj-1',
    healthScore: 85,
    techDebtScore: 80,
    dependencyScore: 90,
    testCoveragePercent: 75.5,
    capturedAt: DateTime(2024, 1, 1),
  );

  Widget createWidget({
    List<HealthSnapshot>? trendData,
    HealthSnapshot? latestSnapshot,
    int trendRange = 30,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        healthTrendRangeProvider.overrideWith((ref) => trendRange),
        healthTrendProvider.overrideWith(
          (ref, arg) => Future.value(trendData ?? [testSnapshot]),
        ),
        latestSnapshotProvider.overrideWith(
          (ref, arg) => Future.value(latestSnapshot ?? testSnapshot),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HealthTrendPanel(projectId: 'proj-1'),
          ),
        ),
      ),
    );
  }

  group('HealthTrendPanel', () {
    testWidgets('renders Health Trend heading', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Health Trend'), findsOneWidget);
    });

    testWidgets('shows time range selector buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('7d'), findsOneWidget);
      expect(find.text('14d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
      expect(find.text('60d'), findsOneWidget);
      expect(find.text('90d'), findsOneWidget);
    });

    testWidgets('shows sub-score cards when snapshot exists', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sub-Scores'), findsOneWidget);
      expect(find.text('Tech Debt'), findsOneWidget);
      expect(find.text('Dependencies'), findsOneWidget);
      expect(find.text('Test Coverage'), findsOneWidget);
    });

    testWidgets('shows empty trend message when no trend data',
        (tester) async {
      await tester.pumpWidget(createWidget(
        trendData: [],
        latestSnapshot: null,
      ));
      await tester.pumpAndSettle();

      // TrendChart displays this message when snapshots list is empty
      expect(find.text('No trend data available'), findsOneWidget);
    });
  });
}
