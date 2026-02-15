// Widget tests for DebtTrendChart.
//
// Verifies chart rendering with trend data and empty state display.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/tech_debt_providers.dart';
import 'package:codeops/widgets/tech_debt/debt_trend_chart.dart';

void main() {
  Widget buildWidget({required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 400,
            child: DebtTrendChart(projectId: 'proj-1'),
          ),
        ),
      ),
    );
  }

  group('DebtTrendChart', () {
    testWidgets('renders chart with trend data', (tester) async {
      final summaryData = <String, dynamic>{
        'history': [
          {'techDebtScore': 90},
          {'techDebtScore': 85},
          {'techDebtScore': 80},
        ],
      };

      await tester.pumpWidget(buildWidget(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) async => summaryData),
        ],
      ));
      await tester.pumpAndSettle();

      // Should show the title text
      expect(find.text('Debt Score Trend'), findsOneWidget);

      // Should not show empty state
      expect(find.text('No trend data'), findsNothing);
    });

    testWidgets('empty data shows "No trend data"', (tester) async {
      final summaryData = <String, dynamic>{
        'history': <Map<String, dynamic>>[],
      };

      await tester.pumpWidget(buildWidget(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) async => summaryData),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No trend data'), findsOneWidget);
    });

    testWidgets('no history key shows empty state', (tester) async {
      final summaryData = <String, dynamic>{
        'totalItems': 5,
      };

      await tester.pumpWidget(buildWidget(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) async => summaryData),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No trend data'), findsOneWidget);
    });

    testWidgets('shows loading spinner while data loads', (tester) async {
      final completer = Completer<Map<String, dynamic>>();

      await tester.pumpWidget(buildWidget(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) => completer.future),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the completer to avoid pending timer errors.
      completer.complete(<String, dynamic>{});
      await tester.pumpAndSettle();
    });
  });
}
