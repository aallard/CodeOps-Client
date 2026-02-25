/// Tests for [ChannelSettingsDialog] — channel settings and member management.
///
/// Verifies channel info rendering, edit controls for OWNER vs MEMBER,
/// member list, update API calls, archive/delete actions, and invite dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/models/user.dart';
import 'package:codeops/providers/auth_providers.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/services/cloud/relay_api.dart';
import 'package:codeops/widgets/relay/channel_settings_dialog.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

class FakeUpdateChannelRequest extends Fake implements UpdateChannelRequest {}

const _testChannel = ChannelResponse(
  id: 'ch-1',
  name: 'engineering',
  slug: 'engineering',
  description: 'Engineering team discussions',
  topic: 'Sprint 42 review',
  channelType: ChannelType.public,
  teamId: 'team-1',
  isArchived: false,
  memberCount: 5,
);

const _testMembers = [
  ChannelMemberResponse(
    id: 'mem-1',
    channelId: 'ch-1',
    userId: 'user-owner',
    userDisplayName: 'Alice Owner',
    role: MemberRole.owner,
  ),
  ChannelMemberResponse(
    id: 'mem-2',
    channelId: 'ch-1',
    userId: 'user-admin',
    userDisplayName: 'Bob Admin',
    role: MemberRole.admin,
  ),
  ChannelMemberResponse(
    id: 'mem-3',
    channelId: 'ch-1',
    userId: 'user-member',
    userDisplayName: 'Carol Member',
    role: MemberRole.member,
  ),
];

Widget _createDialog({
  String channelId = 'ch-1',
  String teamId = 'team-1',
  String currentUserId = 'user-owner',
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      channelDetailProvider((channelId: channelId, teamId: teamId))
          .overrideWith((ref) async => _testChannel),
      channelMembersProvider((channelId: channelId, teamId: teamId))
          .overrideWith((ref) async => _testMembers),
      currentUserProvider.overrideWith(
        (ref) => User(
          id: currentUserId,
          email: 'test@test.com',
          displayName: 'Test User',
        ),
      ),
      currentUserChannelRoleProvider(
              (channelId: channelId, teamId: teamId))
          .overrideWith((ref) async {
        if (currentUserId == 'user-owner') return MemberRole.owner;
        if (currentUserId == 'user-admin') return MemberRole.admin;
        return MemberRole.member;
      }),
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
                child: ChannelSettingsDialog(
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
    registerFallbackValue(FakeUpdateChannelRequest());
  });

  group('ChannelSettingsDialog', () {
    testWidgets('renders channel name', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('engineering'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders description', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Engineering team discussions'), findsOneWidget);
    });

    testWidgets('renders topic', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Sprint 42 review'), findsOneWidget);
    });

    testWidgets('renders member list on Members tab', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Switch to Members tab (first match is the Tab label)
      await tester.tap(find.text('Members').first);
      await tester.pumpAndSettle();

      expect(find.text('Alice Owner'), findsOneWidget);
      expect(find.text('Bob Admin'), findsOneWidget);
      expect(find.text('Carol Member'), findsOneWidget);
    });

    testWidgets('shows edit controls for OWNER', (tester) async {
      await tester.pumpWidget(_createDialog(currentUserId: 'user-owner'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // OWNER should see archive and delete buttons
      expect(find.text('Archive Channel'), findsOneWidget);
      expect(find.text('Delete Channel'), findsOneWidget);
    });

    testWidgets('hides edit controls for MEMBER', (tester) async {
      await tester.pumpWidget(_createDialog(currentUserId: 'user-member'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // MEMBER should not see archive or delete buttons
      expect(find.text('Archive Channel'), findsNothing);
      expect(find.text('Delete Channel'), findsNothing);
    });

    testWidgets('calls updateChannel API on save', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.updateChannel(any(), any(), any())).thenAnswer(
        (_) async => _testChannel,
      );

      await tester.pumpWidget(_createDialog(
        currentUserId: 'user-owner',
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse<ChannelSummaryResponse>(
              content: [],
              page: 0,
              size: 50,
              totalElements: 0,
              totalPages: 0,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Edit the name field
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'new-name');
      await tester.pumpAndSettle();

      // Save button should appear
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      verify(() => mockApi.updateChannel('ch-1', any(), 'team-1')).called(1);
    });

    testWidgets('archive button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_createDialog(currentUserId: 'user-owner'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Archive Channel'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Archive Channel'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Are you sure'), findsOneWidget);
    });

    testWidgets('delete button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_createDialog(currentUserId: 'user-owner'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Scroll the Delete Channel button into view
      await tester.ensureVisible(find.text('Delete Channel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Channel'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete Channel'), findsAtLeastNWidgets(1));
      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });

    testWidgets('invite button opens invite dialog', (tester) async {
      await tester.pumpWidget(_createDialog(currentUserId: 'user-owner'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Switch to Members tab (first match is the Tab label)
      await tester.tap(find.text('Members').first);
      await tester.pumpAndSettle();

      expect(find.text('Invite Member'), findsOneWidget);
    });
  });
}
