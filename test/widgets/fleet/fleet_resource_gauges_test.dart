// Widget tests for FleetResourceGauges.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/theme/colors.dart';
import 'package:codeops/widgets/fleet/fleet_resource_gauges.dart';

void main() {
  Widget wrap(FleetHealthSummary summary) {
    return MaterialApp(
      home: Scaffold(body: FleetResourceGauges(summary: summary)),
    );
  }

  group('FleetResourceGauges', () {
    testWidgets('shows CPU percentage', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary(
        totalCpuPercent: 34.5,
        totalMemoryBytes: 512 * 1024 * 1024,
        totalMemoryLimitBytes: 1024 * 1024 * 1024,
      )));

      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('34.5%'), findsOneWidget);
    });

    testWidgets('shows memory usage with formatted sizes', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary(
        totalCpuPercent: 10.0,
        totalMemoryBytes: 512 * 1024 * 1024,
        totalMemoryLimitBytes: 1024 * 1024 * 1024,
      )));

      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('512.0 MB / 1.0 GB'), findsOneWidget);
    });

    testWidgets('handles zero state gracefully', (tester) async {
      await tester.pumpWidget(wrap(const FleetHealthSummary()));

      expect(find.text('Resource Usage'), findsOneWidget);
      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('0.0%'), findsOneWidget);
    });
  });

  group('colorForPercent', () {
    test('returns green below 50%', () {
      expect(
        FleetResourceGauges.colorForPercent(0.3),
        CodeOpsColors.success,
      );
    });

    test('returns yellow between 50% and 80%', () {
      expect(
        FleetResourceGauges.colorForPercent(0.65),
        CodeOpsColors.warning,
      );
    });

    test('returns red above 80%', () {
      expect(
        FleetResourceGauges.colorForPercent(0.9),
        CodeOpsColors.error,
      );
    });
  });
}
