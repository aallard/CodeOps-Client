// Widget tests for WorkstationProfileDetailPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/pages/fleet/workstation_profile_detail_page.dart';
import 'package:codeops/providers/fleet_providers.dart'
    hide selectedTeamIdProvider;
import 'package:codeops/providers/team_providers.dart'
    show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';
  const profileId = 'ws-1';

  final detail = FleetWorkstationProfileDetail(
    id: profileId,
    name: 'My Dev Env',
    description: 'Personal development workstation',
    isDefault: true,
    userId: 'user-1',
    teamId: teamId,
    solutions: [
      FleetWorkstationSolution(
        id: 'wsol-1',
        startOrder: 1,
        solutionProfileId: 'sol-1',
        solutionProfileName: 'Dev Stack',
        overrideEnvVarsJson: '{"DB_HOST":"localhost"}',
      ),
      FleetWorkstationSolution(
        id: 'wsol-2',
        startOrder: 2,
        solutionProfileId: 'sol-2',
        solutionProfileName: 'CI Pipeline',
      ),
    ],
    createdAt: DateTime(2026, 2, 27, 9, 0),
    updatedAt: DateTime(2026, 2, 27, 10, 0),
  );

  final detailNoSolutions = FleetWorkstationProfileDetail(
    id: profileId,
    name: 'Empty Workstation',
    description: null,
    isDefault: false,
    userId: 'user-1',
    teamId: teamId,
    solutions: [],
    createdAt: DateTime(2026, 2, 27, 9, 0),
  );

  void useWideViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget createWidget({
    String? selectedTeamId = teamId,
    FleetWorkstationProfileDetail? profileDetail,
    bool loadingDetail = false,
    bool errorDetail = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        fleetWorkstationProfileDetailProvider.overrideWith(
          (ref, params) {
            if (loadingDetail) {
              return Completer<FleetWorkstationProfileDetail>().future;
            }
            if (errorDetail) {
              return Future<FleetWorkstationProfileDetail>.error(
                  'Server error');
            }
            return Future.value(profileDetail ?? detail);
          },
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: WorkstationProfileDetailPage(profileId: profileId),
        ),
      ),
    );
  }

  group('WorkstationProfileDetailPage', () {
    testWidgets('renders profile name in header', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Dev Env'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders description in header', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Personal development workstation'),
          findsAtLeastNWidgets(1));
    });

    testWidgets('renders default badge for default profile',
        (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('hides default badge for non-default profile',
        (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(
          createWidget(profileDetail: detailNoSolutions));
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsNothing);
    });

    testWidgets('renders Start and Stop buttons', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
    });

    testWidgets('renders Edit and Delete buttons', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('renders solution list with solutions', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Solutions (2)'), findsOneWidget);
      expect(find.text('Dev Stack'), findsOneWidget);
      expect(find.text('CI Pipeline'), findsOneWidget);
    });

    testWidgets('renders solution start orders', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders env override for first solution',
        (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('{"DB_HOST":"localhost"}'), findsOneWidget);
    });

    testWidgets('renders empty state when no solutions', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(
          createWidget(profileDetail: detailNoSolutions));
      await tester.pumpAndSettle();

      expect(find.text('No solutions added yet'), findsOneWidget);
    });

    testWidgets('renders Add Solution button', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Solution'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(createWidget(loadingDetail: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(createWidget(errorDetail: true));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders no team selected state', (tester) async {
      await tester.pumpWidget(createWidget(selectedTeamId: null));
      await tester.pumpAndSettle();

      expect(find.text('No team selected'), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders owner badge', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Owner:'), findsOneWidget);
    });
  });
}
