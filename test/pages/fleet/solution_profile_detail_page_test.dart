// Widget tests for SolutionProfileDetailPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/pages/fleet/solution_profile_detail_page.dart';
import 'package:codeops/providers/fleet_providers.dart'
    hide selectedTeamIdProvider;
import 'package:codeops/providers/team_providers.dart'
    show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';
  const profileId = 'sol-1';

  final detail = FleetSolutionProfileDetail(
    id: profileId,
    name: 'Dev Stack',
    description: 'Full development environment',
    isDefault: true,
    teamId: teamId,
    services: [
      FleetSolutionService(
        id: 'ss-1',
        startOrder: 1,
        serviceProfileId: 'sp-1',
        serviceProfileName: 'PostgreSQL',
        imageName: 'postgres',
        isEnabled: true,
      ),
      FleetSolutionService(
        id: 'ss-2',
        startOrder: 2,
        serviceProfileId: 'sp-2',
        serviceProfileName: 'Redis',
        imageName: 'redis',
        isEnabled: false,
      ),
    ],
    createdAt: DateTime(2026, 2, 27, 9, 0),
    updatedAt: DateTime(2026, 2, 27, 10, 0),
  );

  final detailNoServices = FleetSolutionProfileDetail(
    id: profileId,
    name: 'Empty Solution',
    description: null,
    isDefault: false,
    teamId: teamId,
    services: [],
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
    FleetSolutionProfileDetail? profileDetail,
    bool loadingDetail = false,
    bool errorDetail = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        fleetSolutionProfileDetailProvider.overrideWith(
          (ref, params) {
            if (loadingDetail) {
              return Completer<FleetSolutionProfileDetail>().future;
            }
            if (errorDetail) {
              return Future<FleetSolutionProfileDetail>.error('Server error');
            }
            return Future.value(profileDetail ?? detail);
          },
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SolutionProfileDetailPage(profileId: profileId),
        ),
      ),
    );
  }

  group('SolutionProfileDetailPage', () {
    testWidgets('renders profile name in header', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dev Stack'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders description in header', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
          find.text('Full development environment'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders default badge for default profile', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('hides default badge for non-default profile', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(
          createWidget(profileDetail: detailNoServices));
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

    testWidgets('renders service list with services', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Services (2)'), findsOneWidget);
      expect(find.text('PostgreSQL'), findsOneWidget);
      expect(find.text('Redis'), findsOneWidget);
    });

    testWidgets('renders service start orders', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders service image names', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('postgres'), findsOneWidget);
      expect(find.text('redis'), findsOneWidget);
    });

    testWidgets('renders empty state when no services', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(
          createWidget(profileDetail: detailNoServices));
      await tester.pumpAndSettle();

      expect(find.text('No services added yet'), findsOneWidget);
    });

    testWidgets('renders Add Service button', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Service'), findsOneWidget);
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
  });
}
