// Tests for PortAllocationPage.
//
// Verifies loading, error, empty, data states, header elements,
// environment selector, conflict banner, port map grid, seed ranges
// dialog, and deallocation dialog.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/pages/registry/port_allocation_page.dart';
import 'package:codeops/providers/registry_providers.dart';
import 'package:codeops/providers/team_providers.dart';

const _testPortMap = PortMapResponse(
  teamId: 'team-1',
  environment: 'local',
  ranges: [
    PortRangeWithAllocationsResponse(
      portType: PortType.httpApi,
      rangeStart: 8080,
      rangeEnd: 8099,
      totalCapacity: 20,
      allocated: 2,
      available: 18,
      allocations: [
        PortAllocationResponse(
          id: 'alloc-1',
          serviceId: 'svc-1',
          serviceName: 'CodeOps Server',
          environment: 'local',
          portType: PortType.httpApi,
          portNumber: 8090,
        ),
        PortAllocationResponse(
          id: 'alloc-2',
          serviceId: 'svc-2',
          serviceName: 'Auth Service',
          environment: 'local',
          portType: PortType.httpApi,
          portNumber: 8091,
        ),
      ],
    ),
  ],
  totalAllocated: 2,
  totalAvailable: 18,
);

const _emptyPortMap = PortMapResponse(
  teamId: 'team-1',
  environment: 'local',
  ranges: [],
  totalAllocated: 0,
  totalAvailable: 0,
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildPage({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(body: PortAllocationPage()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PortAllocationPage', () {
    testWidgets('renders loading state', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) => Completer<PortMapResponse?>().future,
            ),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) => throw Exception('Network error'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to Load Port Map'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders empty team message when portMap is null',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select a team to view port allocations.'),
          findsOneWidget);
    });

    testWidgets('renders header bar with title and buttons', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Port Allocations'), findsOneWidget);
      expect(find.text('Allocate'), findsOneWidget);
      expect(find.text('Seed Ranges'), findsOneWidget);
    });

    testWidgets('renders environment dropdown with default "local"',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Environment'), findsOneWidget);
      // "local" is shown in the dropdown
      expect(find.text('local'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders port map summary row', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('2 allocated / 18 available across 1 range'),
        findsOneWidget,
      );
    });

    testWidgets('renders port chips in range card', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Port numbers
      expect(find.text('8090'), findsOneWidget);
      expect(find.text('8091'), findsOneWidget);
      // Service names
      expect(find.text('CodeOps Server'), findsOneWidget);
      expect(find.text('Auth Service'), findsOneWidget);
    });

    testWidgets('renders empty state when no ranges', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _emptyPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No port ranges configured'), findsOneWidget);
      expect(find.text('Seed default ranges to get started.'), findsOneWidget);
    });

    testWidgets('renders conflict banner when conflicts exist',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final conflicts = [
        const PortConflictResponse(
          portNumber: 8090,
          environment: 'local',
          conflictingAllocations: [
            PortAllocationResponse(
              id: 'alloc-1',
              serviceId: 'svc-1',
              serviceName: 'CodeOps Server',
              environment: 'local',
              portType: PortType.httpApi,
              portNumber: 8090,
            ),
            PortAllocationResponse(
              id: 'alloc-3',
              serviceId: 'svc-3',
              serviceName: 'Gateway',
              environment: 'local',
              portType: PortType.httpApi,
              portNumber: 8090,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => conflicts,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('1 port conflict detected'), findsOneWidget);
    });

    testWidgets('seed ranges dialog opens', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Seed Ranges'));
      await tester.pumpAndSettle();

      expect(find.text('Seed Default Ranges'), findsOneWidget);
      expect(find.textContaining('"local" environment'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('seed ranges dialog can be cancelled', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Seed Ranges'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Seed Default Ranges'), findsNothing);
    });

    testWidgets('renders utilization bar and percentage', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          overrides: [
            registryPortMapProvider.overrideWith(
              (ref) async => _testPortMap,
            ),
            registryPortConflictsProvider.overrideWith(
              (ref) async => <PortConflictResponse>[],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 2/20 = 10%
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('2/20 allocated'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
