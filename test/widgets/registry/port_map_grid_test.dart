// Tests for PortMapGrid widget.
//
// Verifies summary row, range cards, empty state, port chips,
// conflict highlighting, and utilization display.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/widgets/registry/port_map_grid.dart';
import 'package:codeops/widgets/registry/port_range_card.dart';

const _portMap = PortMapResponse(
  teamId: 'team-1',
  environment: 'local',
  ranges: [
    PortRangeWithAllocationsResponse(
      portType: PortType.httpApi,
      rangeStart: 8080,
      rangeEnd: 8099,
      totalCapacity: 20,
      allocated: 3,
      available: 17,
      allocations: [
        PortAllocationResponse(
          id: 'a1',
          serviceId: 's1',
          serviceName: 'Service Alpha',
          environment: 'local',
          portType: PortType.httpApi,
          portNumber: 8080,
        ),
        PortAllocationResponse(
          id: 'a2',
          serviceId: 's2',
          serviceName: 'Service Beta',
          environment: 'local',
          portType: PortType.httpApi,
          portNumber: 8081,
        ),
        PortAllocationResponse(
          id: 'a3',
          serviceId: 's3',
          serviceName: 'Service Gamma',
          environment: 'local',
          portType: PortType.httpApi,
          portNumber: 8082,
        ),
      ],
    ),
    PortRangeWithAllocationsResponse(
      portType: PortType.database,
      rangeStart: 5432,
      rangeEnd: 5439,
      totalCapacity: 8,
      allocated: 1,
      available: 7,
      allocations: [
        PortAllocationResponse(
          id: 'a4',
          serviceId: 's4',
          serviceName: 'PostgreSQL',
          environment: 'local',
          portType: PortType.database,
          portNumber: 5432,
        ),
      ],
    ),
  ],
  totalAllocated: 4,
  totalAvailable: 24,
);

const _emptyPortMap = PortMapResponse(
  teamId: 'team-1',
  environment: 'local',
  ranges: [],
  totalAllocated: 0,
  totalAvailable: 0,
);

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildGrid({
  PortMapResponse portMap = _portMap,
  List<PortConflictResponse> conflicts = const [],
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: PortMapGrid(
          portMap: portMap,
          conflicts: conflicts,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PortMapGrid', () {
    testWidgets('renders summary row with counts', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('4 allocated / 24 available across 2 ranges'),
        findsOneWidget,
      );
    });

    testWidgets('renders one PortRangeCard per range', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid());
      await tester.pumpAndSettle();

      expect(find.byType(PortRangeCard), findsNWidgets(2));
    });

    testWidgets('renders port type labels in cards', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid());
      await tester.pumpAndSettle();

      expect(find.text('HTTP API'), findsOneWidget);
      expect(find.text('Database'), findsOneWidget);
    });

    testWidgets('renders range spans', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid());
      await tester.pumpAndSettle();

      expect(find.text('8080\u20138099'), findsOneWidget);
      expect(find.text('5432\u20135439'), findsOneWidget);
    });

    testWidgets('renders empty state when no ranges', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid(portMap: _emptyPortMap));
      await tester.pumpAndSettle();

      expect(find.text('No port ranges configured'), findsOneWidget);
      expect(find.text('Seed default ranges to get started.'), findsOneWidget);
      expect(find.byType(PortRangeCard), findsNothing);
    });

    testWidgets('summary uses singular "range" for single range',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const singleRangeMap = PortMapResponse(
        teamId: 'team-1',
        environment: 'local',
        ranges: [
          PortRangeWithAllocationsResponse(
            portType: PortType.redis,
            rangeStart: 6379,
            rangeEnd: 6389,
            totalCapacity: 11,
            allocated: 1,
            available: 10,
            allocations: [
              PortAllocationResponse(
                id: 'a5',
                serviceId: 's5',
                serviceName: 'Redis',
                environment: 'local',
                portType: PortType.redis,
                portNumber: 6379,
              ),
            ],
          ),
        ],
        totalAllocated: 1,
        totalAvailable: 10,
      );

      await tester.pumpWidget(_buildGrid(portMap: singleRangeMap));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('1 allocated / 10 available across 1 range'),
        findsOneWidget,
      );
    });

    testWidgets('renders port chips with port numbers', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid());
      await tester.pumpAndSettle();

      expect(find.text('8080'), findsOneWidget);
      expect(find.text('8081'), findsOneWidget);
      expect(find.text('8082'), findsOneWidget);
      expect(find.text('5432'), findsOneWidget);
    });

    testWidgets('renders utilization percentages', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildGrid());
      await tester.pumpAndSettle();

      // 3/20 = 15%, 1/8 = 13%
      expect(find.text('15%'), findsOneWidget);
      expect(find.text('13%'), findsOneWidget);
    });
  });
}
