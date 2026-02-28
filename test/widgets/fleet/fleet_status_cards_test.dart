// Widget tests for FleetStatusCards.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/widgets/fleet/fleet_status_cards.dart';

void main() {
  Widget wrap(FleetHealthSummary summary) {
    return MaterialApp(
      home: Scaffold(body: FleetStatusCards(summary: summary)),
    );
  }

  group('FleetStatusCards', () {
    testWidgets('shows running count', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary(
        runningContainers: 7,
        stoppedContainers: 2,
        unhealthyContainers: 1,
        totalContainers: 10,
      )));

      expect(find.text('7'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('shows stopped count', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary(
        runningContainers: 3,
        stoppedContainers: 5,
        unhealthyContainers: 0,
        totalContainers: 8,
      )));

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Stopped'), findsOneWidget);
    });

    testWidgets('shows unhealthy count', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary(
        runningContainers: 4,
        stoppedContainers: 1,
        unhealthyContainers: 3,
        totalContainers: 8,
      )));

      expect(find.text('Unhealthy'), findsOneWidget);
    });

    testWidgets('shows dash for null values', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary()));

      // All four cards should show em-dash
      expect(find.text('\u2014'), findsNWidgets(4));
    });
  });
}
