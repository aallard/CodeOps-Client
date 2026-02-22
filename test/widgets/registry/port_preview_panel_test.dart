// Tests for PortPreviewPanel widget.
//
// Verifies create mode recommendations per service type,
// edit mode with allocated ports, and empty states.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/widgets/registry/port_preview_panel.dart';

Widget _buildWidget({
  ServiceType? serviceType,
  List<PortAllocationResponse>? allocatedPorts,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PortPreviewPanel(
        serviceType: serviceType,
        allocatedPorts: allocatedPorts,
      ),
    ),
  );
}

void main() {
  group('PortPreviewPanel', () {
    testWidgets('shows prompt when no service type selected', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Port Allocation Preview'), findsOneWidget);
      expect(
        find.text('Select a service type to see suggested port allocations.'),
        findsOneWidget,
      );
    });

    testWidgets('shows recommendations for Spring Boot API', (tester) async {
      await tester.pumpWidget(
        _buildWidget(serviceType: ServiceType.springBootApi),
      );
      await tester.pumpAndSettle();

      expect(find.text('HTTP API'), findsOneWidget);
      expect(find.text('Database'), findsOneWidget);
      expect(find.text('Actuator'), findsOneWidget);
    });

    testWidgets('shows no-ports message for library type', (tester) async {
      await tester.pumpWidget(
        _buildWidget(serviceType: ServiceType.library_),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Library typically does not require server ports.'),
        findsOneWidget,
      );
    });

    testWidgets('edit mode shows allocated ports', (tester) async {
      final ports = [
        PortAllocationResponse.fromJson(const {
          'id': 'port-1',
          'serviceId': 'svc-1',
          'environment': 'local',
          'portType': 'HTTP_API',
          'portNumber': 8090,
          'protocol': 'TCP',
        }),
        PortAllocationResponse.fromJson(const {
          'id': 'port-2',
          'serviceId': 'svc-1',
          'environment': 'local',
          'portType': 'DATABASE',
          'portNumber': 5432,
          'protocol': 'TCP',
        }),
      ];

      await tester.pumpWidget(
        _buildWidget(
          serviceType: ServiceType.springBootApi,
          allocatedPorts: ports,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allocated Ports'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // count badge
      expect(find.text('8090'), findsOneWidget);
      expect(find.text('5432'), findsOneWidget);
    });

    testWidgets('edit mode shows empty ports message', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          serviceType: ServiceType.springBootApi,
          allocatedPorts: [],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allocated Ports'), findsOneWidget);
      expect(find.text('No ports allocated.'), findsOneWidget);
    });
  });
}
