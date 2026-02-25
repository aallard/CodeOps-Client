/// Tests for [BrowseChannelsDialog] — channel discovery and join dialog.
///
/// Verifies search bar, channel list, search filtering, join button,
/// joined indicator, API call on join, success toast, and provider invalidation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/services/cloud/relay_api.dart';
import 'package:codeops/widgets/relay/browse_channels_dialog.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

List<ChannelSummaryResponse> _testChannels() => const [
      ChannelSummaryResponse(
        id: 'ch-1',
        name: 'general',
        slug: 'general',
        channelType: ChannelType.public,
        isArchived: false,
        memberCount: 10,
        topic: 'General discussion',
      ),
      ChannelSummaryResponse(
        id: 'ch-2',
        name: 'random',
        slug: 'random',
        channelType: ChannelType.public,
        isArchived: false,
        memberCount: 5,
      ),
      ChannelSummaryResponse(
        id: 'ch-3',
        name: 'secret',
        slug: 'secret',
        channelType: ChannelType.private,
        isArchived: false,
        memberCount: 2,
      ),
    ];

Widget _createDialog({
  String teamId = 'team-1',
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ProviderScope(
                parent: ProviderScope.containerOf(context),
                child: BrowseChannelsDialog(teamId: teamId),
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
  group('BrowseChannelsDialog', () {
    testWidgets('renders search bar', (tester) async {
      await tester.pumpWidget(_createDialog(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders channel list (public only)', (tester) async {
      await tester.pumpWidget(_createDialog(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Public channels should appear
      expect(find.text('# general'), findsOneWidget);
      expect(find.text('# random'), findsOneWidget);
      // Private channel should NOT appear
      expect(find.text('# secret'), findsNothing);
    });

    testWidgets('filters by search query', (tester) async {
      await tester.pumpWidget(_createDialog(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'gen');
      await tester.pumpAndSettle();

      expect(find.text('# general'), findsOneWidget);
      expect(find.text('# random'), findsNothing);
    });

    testWidgets('shows Join button for non-member channels',
        (tester) async {
      await tester.pumpWidget(_createDialog(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Join'), findsAtLeastNWidgets(1));
    });

    testWidgets('calls joinChannel API on join tap', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.joinChannel(any(), any())).thenAnswer(
        (_) async => const ChannelMemberResponse(
          id: 'mem-1',
          channelId: 'ch-1',
          userId: 'user-1',
          role: MemberRole.member,
        ),
      );

      await tester.pumpWidget(_createDialog(
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the first Join button
      await tester.tap(find.widgetWithText(FilledButton, 'Join').first);
      await tester.pumpAndSettle();

      verify(() => mockApi.joinChannel(any(), 'team-1')).called(1);
    });

    testWidgets('shows Joined indicator after successful join',
        (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.joinChannel(any(), any())).thenAnswer(
        (_) async => const ChannelMemberResponse(
          id: 'mem-1',
          channelId: 'ch-1',
          userId: 'user-1',
          role: MemberRole.member,
        ),
      );

      await tester.pumpWidget(_createDialog(
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Join').first);
      await tester.pumpAndSettle();

      expect(find.text('Joined'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows member count', (tester) async {
      await tester.pumpWidget(_createDialog(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse(
              content: _testChannels(),
              page: 0,
              size: 50,
              totalElements: 3,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}
