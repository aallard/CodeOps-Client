// Tests for SeverityFilterBar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/providers/finding_providers.dart';
import 'package:codeops/widgets/findings/severity_filter_bar.dart';

void main() {
  final severityCounts = {
    Severity.critical: 2,
    Severity.high: 5,
    Severity.medium: 8,
    Severity.low: 3,
  };

  Widget createWidget({
    Map<Severity, int> counts = const {},
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        findingFiltersProvider
            .overrideWith((ref) => const FindingFilters()),
        ...overrides,
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: SeverityFilterBar(severityCounts: counts),
          ),
        ),
      ),
    );
  }

  group('SeverityFilterBar', () {
    testWidgets('renders severity labels with counts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(counts: severityCounts));
      await tester.pumpAndSettle();

      expect(find.text('Critical (2)'), findsOneWidget);
      expect(find.text('High (5)'), findsOneWidget);
      expect(find.text('Medium (8)'), findsOneWidget);
      expect(find.text('Low (3)'), findsOneWidget);
    });

    testWidgets('renders all severity chips with zero counts',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Critical (0)'), findsOneWidget);
      expect(find.text('High (0)'), findsOneWidget);
      expect(find.text('Medium (0)'), findsOneWidget);
      expect(find.text('Low (0)'), findsOneWidget);
    });

    testWidgets('renders search field with hint text', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(counts: severityCounts));
      await tester.pumpAndSettle();

      expect(find.text('Search findings...'), findsOneWidget);
    });

    testWidgets('renders search icon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(counts: severityCounts));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders dropdown buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(counts: severityCounts));
      await tester.pumpAndSettle();

      // Dropdown hint texts are rendered inside DropdownButton widgets
      expect(find.byType(DropdownButton<FindingStatus>), findsOneWidget);
      expect(find.byType(DropdownButton<AgentType>), findsOneWidget);
    });

    testWidgets('renders sort toggle button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(counts: severityCounts));
      await tester.pumpAndSettle();

      // Default is ascending
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('does not show clear button when no filters active',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(counts: severityCounts));
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsNothing);
    });
  });
}
