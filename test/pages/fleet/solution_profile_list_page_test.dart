// Widget tests for SolutionProfileListPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/pages/fleet/solution_profile_list_page.dart';
import 'package:codeops/providers/fleet_providers.dart'
    hide selectedTeamIdProvider;
import 'package:codeops/providers/team_providers.dart'
    show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';

  final profiles = [
    FleetSolutionProfile(
      id: 'sol-1',
      name: 'Dev Stack',
      description: 'Full development environment',
      isDefault: true,
      serviceCount: 3,
      teamId: teamId,
      createdAt: DateTime(2026, 2, 27, 9, 0),
    ),
    FleetSolutionProfile(
      id: 'sol-2',
      name: 'CI Pipeline',
      description: 'Continuous integration services',
      isDefault: false,
      serviceCount: 5,
      teamId: teamId,
      createdAt: DateTime(2026, 2, 27, 10, 0),
    ),
  ];

  void useWideViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget createWidget({
    String? selectedTeamId = teamId,
    List<FleetSolutionProfile>? profileList,
    bool loading = false,
    bool error = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        fleetSolutionProfilesProvider.overrideWith(
          (ref, tid) {
            if (loading) {
              return Completer<List<FleetSolutionProfile>>().future;
            }
            if (error) {
              return Future<List<FleetSolutionProfile>>.error('Server error');
            }
            return Future.value(profileList ?? profiles);
          },
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SolutionProfileListPage()),
      ),
    );
  }

  group('SolutionProfileListPage', () {
    testWidgets('renders page title', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Solution Profiles'), findsOneWidget);
    });

    testWidgets('renders profile count', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('(2)'), findsOneWidget);
    });

    testWidgets('renders solution names in table', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dev Stack'), findsOneWidget);
      expect(find.text('CI Pipeline'), findsOneWidget);
    });

    testWidgets('renders descriptions in table', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Full development environment'), findsOneWidget);
      expect(find.text('Continuous integration services'), findsOneWidget);
    });

    testWidgets('renders service counts', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders default badge for default profile', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(createWidget(loading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(error: true));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders no team selected state', (tester) async {
      await tester.pumpWidget(createWidget(selectedTeamId: null));
      await tester.pumpAndSettle();

      expect(find.text('No team selected'), findsOneWidget);
    });

    testWidgets('renders empty state', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget(profileList: []));
      await tester.pumpAndSettle();

      expect(find.text('No solution profiles found'), findsOneWidget);
    });

    testWidgets('renders Create button', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('renders table headers', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('renders action buttons per row', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Play (start), stop, star/star_border (toggle default), delete per row
      expect(find.byIcon(Icons.play_arrow), findsNWidgets(2));
      expect(find.byIcon(Icons.stop), findsNWidgets(2));
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('renders star icon for default toggle', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // sol-1 is default → filled star; sol-2 is not → star_border
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });
  });
}
