// Widget tests for UsageStatsTab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/admin_providers.dart';
import 'package:codeops/widgets/admin/usage_stats_tab.dart';

void main() {
  final testStats = <String, dynamic>{
    'totalUsers': 10,
    'activeUsers': 8,
    'totalTeams': 3,
    'totalProjects': 15,
  };

  Widget createWidget({
    Map<String, dynamic>? stats,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        usageStatsProvider.overrideWith(
          (ref) => Future.value(stats ?? testStats),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: UsageStatsTab()),
        ),
      ),
    );
  }

  group('UsageStatsTab', () {
    testWidgets('shows metric cards', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Active Users'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Total Teams'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Total Projects'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('shows empty message when no stats', (tester) async {
      await tester.pumpWidget(createWidget(stats: {}));
      await tester.pumpAndSettle();

      expect(find.text('No usage data available.'), findsOneWidget);
    });

    testWidgets('shows additional keys beyond known set', (tester) async {
      await tester.pumpWidget(createWidget(
        stats: {
          'totalUsers': 10,
          'activeUsers': 8,
          'totalTeams': 3,
          'totalProjects': 15,
          'totalJobs': 42,
        },
      ));
      await tester.pumpAndSettle();

      expect(find.text('Total Jobs'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });
}
