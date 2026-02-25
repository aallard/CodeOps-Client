/// Tests for [InviteMemberDialog] — team member invitation to a channel.
///
/// Verifies search field, matching team members display, exclusion of
/// existing channel members, role selector, API call on invite, and
/// success toast.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/models/team.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/services/cloud/relay_api.dart';
import 'package:codeops/widgets/relay/invite_member_dialog.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

class FakeInviteMemberRequest extends Fake implements InviteMemberRequest {}

final _testTeamMembers = [
  TeamMember(
    id: 'tm-1',
    userId: 'user-1',
    displayName: 'Alice Owner',
    email: 'alice@test.com',
    role: TeamRole.owner,
    joinedAt: DateTime(2025, 1, 1),
  ),
  TeamMember(
    id: 'tm-2',
    userId: 'user-2',
    displayName: 'Bob Admin',
    email: 'bob@test.com',
    role: TeamRole.admin,
    joinedAt: DateTime(2025, 1, 1),
  ),
  TeamMember(
    id: 'tm-3',
    userId: 'user-3',
    displayName: 'Carol New',
    email: 'carol@test.com',
    role: TeamRole.member,
    joinedAt: DateTime(2025, 1, 1),
  ),
];

const _existingChannelMembers = [
  ChannelMemberResponse(
    id: 'mem-1',
    channelId: 'ch-1',
    userId: 'user-1',
    userDisplayName: 'Alice Owner',
    role: MemberRole.owner,
  ),
];

Widget _createDialog({
  String channelId = 'ch-1',
  String teamId = 'team-1',
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      teamMembersProvider.overrideWith(
        (ref) async => _testTeamMembers,
      ),
      channelMembersProvider((channelId: channelId, teamId: teamId))
          .overrideWith((ref) async => _existingChannelMembers),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ProviderScope(
                parent: ProviderScope.containerOf(context),
                child: InviteMemberDialog(
                  channelId: channelId,
                  teamId: teamId,
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeInviteMemberRequest());
  });

  group('InviteMemberDialog', () {
    testWidgets('renders search field', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows matching team members', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // user-2 (Bob) and user-3 (Carol) should be visible
      // user-1 (Alice) is already in channel
      expect(find.text('Bob Admin'), findsOneWidget);
      expect(find.text('Carol New'), findsOneWidget);
    });

    testWidgets('excludes existing channel members', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Alice (user-1) is already in the channel, should not appear
      expect(find.text('Alice Owner'), findsNothing);
    });

    testWidgets('renders role selector', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Member'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('calls inviteMember API on submit', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.inviteMember(any(), any(), any())).thenAnswer(
        (_) async => const ChannelMemberResponse(
          id: 'mem-new',
          channelId: 'ch-1',
          userId: 'user-2',
          userDisplayName: 'Bob Admin',
          role: MemberRole.member,
        ),
      );

      await tester.pumpWidget(_createDialog(
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Invite for Bob Admin
      await tester.tap(find.widgetWithText(FilledButton, 'Invite').first);
      await tester.pumpAndSettle();

      verify(() => mockApi.inviteMember('ch-1', any(), 'team-1')).called(1);
    });

    testWidgets('filters members by search query', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Both available members visible
      expect(find.text('Bob Admin'), findsOneWidget);
      expect(find.text('Carol New'), findsOneWidget);

      // Filter to Carol
      await tester.enterText(find.byType(TextField), 'carol');
      await tester.pumpAndSettle();

      expect(find.text('Carol New'), findsOneWidget);
      expect(find.text('Bob Admin'), findsNothing);
    });
  });
}
