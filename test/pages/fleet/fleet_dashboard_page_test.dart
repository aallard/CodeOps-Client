// Widget tests for FleetDashboardPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_enums.dart';
import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/pages/fleet/fleet_dashboard_page.dart';
import 'package:codeops/providers/fleet_providers.dart' hide selectedTeamIdProvider;
import 'package:codeops/providers/team_providers.dart' show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';

  final healthSummary = FleetHealthSummary(
    totalContainers: 10,
    runningContainers: 7,
    stoppedContainers: 2,
    unhealthyContainers: 1,
    restartingContainers: 0,
    totalCpuPercent: 34.5,
    totalMemoryBytes: 512 * 1024 * 1024,
    totalMemoryLimitBytes: 1024 * 1024 * 1024,
    timestamp: DateTime.utc(2026),
  );

  final containers = [
    FleetContainerInstance(
      id: 'c1',
      containerId: 'abc123',
      containerName: 'postgres-a1b2',
      serviceName: 'postgres',
      imageName: 'postgres',
      imageTag: '16',
      status: ContainerStatus.running,
      cpuPercent: 12.0,
      memoryBytes: 256 * 1024 * 1024,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    FleetContainerInstance(
      id: 'c2',
      containerId: 'def456',
      containerName: 'redis-c3d4',
      serviceName: 'redis',
      imageName: 'redis',
      imageTag: '7',
      status: ContainerStatus.running,
      cpuPercent: 2.0,
      memoryBytes: 64 * 1024 * 1024,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    FleetContainerInstance(
      id: 'c3',
      containerId: 'ghi789',
      containerName: 'api-e5f6',
      serviceName: 'api',
      imageName: 'eclipse-temurin',
      imageTag: '21',
      status: ContainerStatus.exited,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  Widget createWidget({
    String? selectedTeamId = teamId,
    FleetHealthSummary? summary,
    List<FleetContainerInstance>? containerList,
    bool healthLoading = false,
    bool healthError = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        fleetHealthSummaryProvider.overrideWith(
          (ref, tid) {
            if (healthLoading) return Completer<FleetHealthSummary>().future;
            if (healthError) return Future<FleetHealthSummary>.error('Server error');
            return Future.value(summary ?? healthSummary);
          },
        ),
        fleetContainersProvider.overrideWith(
          (ref, tid) =>
              Future.value(containerList ?? containers),
        ),
        fleetWorkstationProfilesProvider.overrideWith(
          (ref, tid) => Future.value(<FleetWorkstationProfile>[]),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: FleetDashboardPage())),
    );
  }

  group('FleetDashboardPage', () {
    testWidgets('renders status cards with health summary data',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fleet Dashboard'), findsOneWidget);
      expect(find.text('7'), findsOneWidget); // running
      expect(find.text('2'), findsOneWidget); // stopped
      expect(find.text('1'), findsOneWidget); // unhealthy
      expect(find.text('10'), findsOneWidget); // total
    });

    testWidgets('renders resource gauges with CPU and memory',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Resource Usage'), findsOneWidget);
      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('34.5%'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
    });

    testWidgets('renders recent containers list', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Containers'), findsOneWidget);
      expect(find.text('postgres-a1b2'), findsOneWidget);
      expect(find.text('redis-c3d4'), findsOneWidget);
      expect(find.text('api-e5f6'), findsOneWidget);
    });

    testWidgets('renders empty state when no containers', (tester) async {
      await tester.pumpWidget(createWidget(containerList: []));
      await tester.pumpAndSettle();

      expect(find.text('No containers found'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(createWidget(healthLoading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(healthError: true));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders empty state when no team selected', (tester) async {
      await tester.pumpWidget(createWidget(selectedTeamId: null));
      await tester.pumpAndSettle();

      expect(find.text('No team selected'), findsOneWidget);
    });

    testWidgets('shows quick action buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Start Default Workstation'), findsOneWidget);
      expect(find.text('Stop All'), findsOneWidget);
      expect(find.text('Sync Containers'), findsOneWidget);
      expect(find.text('Prune Images'), findsOneWidget);
    });

    testWidgets('refresh button is visible', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('view all button is visible', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('View All \u2192'), findsOneWidget);
    });

    testWidgets('shows running status badges in container list',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Two running containers
      expect(find.text('Running'), findsNWidgets(3)); // 2 in list + 1 in cards
    });

    testWidgets('shows exited status badge in container list',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Exited'), findsOneWidget);
    });

    testWidgets('limits recent containers to 5', (tester) async {
      final manyContainers = List.generate(
        8,
        (i) => FleetContainerInstance(
          id: 'c$i',
          containerName: 'container-$i',
          status: ContainerStatus.running,
        ),
      );
      await tester.pumpWidget(createWidget(containerList: manyContainers));
      await tester.pumpAndSettle();

      // Only first 5 should be shown
      expect(find.text('container-0'), findsOneWidget);
      expect(find.text('container-4'), findsOneWidget);
      expect(find.text('container-5'), findsNothing);
    });
  });
}
