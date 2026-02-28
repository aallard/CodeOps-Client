// Widget tests for WorkstationProfileListPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/models/user.dart';
import 'package:codeops/pages/fleet/workstation_profile_list_page.dart';
import 'package:codeops/providers/auth_providers.dart'
    show currentUserProvider;
import 'package:codeops/providers/fleet_providers.dart'
    hide selectedTeamIdProvider;
import 'package:codeops/providers/team_providers.dart'
    show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';
  const userId = 'user-1';

  final currentUser = User(
    id: userId,
    email: 'adam@allard.com',
    displayName: 'Adam Allard',
  );

  final profiles = [
    FleetWorkstationProfile(
      id: 'ws-1',
      name: 'My Dev Env',
      description: 'Personal development workstation',
      isDefault: true,
      solutionCount: 2,
      userId: userId,
      teamId: teamId,
      createdAt: DateTime(2026, 2, 27, 9, 0),
    ),
    FleetWorkstationProfile(
      id: 'ws-2',
      name: 'CI Runner',
      description: 'Shared CI environment',
      isDefault: false,
      solutionCount: 4,
      userId: 'other-user',
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
    List<FleetWorkstationProfile>? profileList,
    bool loading = false,
    bool error = false,
    User? user,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        currentUserProvider.overrideWith((ref) => user ?? currentUser),
        fleetWorkstationProfilesProvider.overrideWith(
          (ref, tid) {
            if (loading) {
              return Completer<List<FleetWorkstationProfile>>().future;
            }
            if (error) {
              return Future<List<FleetWorkstationProfile>>.error(
                  'Server error');
            }
            return Future.value(profileList ?? profiles);
          },
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: WorkstationProfileListPage()),
      ),
    );
  }

  group('WorkstationProfileListPage', () {
    testWidgets('renders page title', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Workstation Profiles'), findsOneWidget);
    });

    testWidgets('renders profile count', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('(2)'), findsOneWidget);
    });

    testWidgets('renders my workstations tab', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
            (w) => w is Tab && w.text == 'My Workstations (1)'),
        findsOneWidget,
      );
    });

    testWidgets('renders team workstations tab', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
            (w) => w is Tab && w.text == 'Team Workstations (2)'),
        findsOneWidget,
      );
    });

    testWidgets('my workstations tab shows only user-owned profiles',
        (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Default tab is "My Workstations" — should show only ws-1
      expect(find.text('My Dev Env'), findsOneWidget);
      expect(find.text('CI Runner'), findsNothing);
    });

    testWidgets('team workstations tab shows all profiles',
        (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap "Team Workstations" tab
      await tester.tap(find.byWidgetPredicate(
          (w) => w is Tab && w.text == 'Team Workstations (2)'));
      await tester.pumpAndSettle();

      expect(find.text('My Dev Env'), findsOneWidget);
      expect(find.text('CI Runner'), findsOneWidget);
    });

    testWidgets('renders solution counts', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Switch to team tab to see all profiles
      await tester.tap(find.byWidgetPredicate(
          (w) => w is Tab && w.text == 'Team Workstations (2)'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders default badge', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders Create button', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
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

      expect(
          find.text('No workstation profiles found'), findsOneWidget);
    });

    testWidgets('renders action buttons per row', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // My Workstations tab has 1 row
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('renders star icon for default toggle', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // ws-1 is default → filled star on My Workstations tab
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders table headers', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Solutions'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });
  });
}
