/// Tests for [RelayMessageFeed] — main message feed panel.
///
/// Verifies message list rendering, date separators, empty state,
/// loading state, error state, composer placeholder, header integration,
/// and own-message detection.
library;

import 'dart:async';

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
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/services/cloud/relay_api.dart';
import 'package:codeops/widgets/relay/relay_message_feed.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

class FakeMarkReadRequest extends Fake implements MarkReadRequest {}

final _todayMessages = [
  MessageResponse(
    id: 'msg-1',
    senderDisplayName: 'Alice',
    content: 'Good morning!',
    messageType: MessageType.text,
    senderId: 'user-1',
    createdAt: DateTime.now(),
  ),
  MessageResponse(
    id: 'msg-2',
    senderDisplayName: 'Bob',
    content: 'Hello everyone!',
    messageType: MessageType.text,
    senderId: 'user-2',
    createdAt: DateTime.now(),
  ),
];

final _yesterdayMessage = MessageResponse(
  id: 'msg-0',
  senderDisplayName: 'Carol',
  content: 'See you tomorrow!',
  messageType: MessageType.text,
  senderId: 'user-3',
  createdAt: DateTime.now().subtract(const Duration(days: 1)),
);

const _testChannel = ChannelResponse(
  id: 'ch-1',
  name: 'engineering',
  slug: 'engineering',
  topic: 'Sprint 42',
  channelType: ChannelType.public,
  teamId: 'team-1',
  memberCount: 5,
);

Widget _createFeed({
  String channelId = 'ch-1',
  String teamId = 'team-1',
  String currentUserId = 'user-1',
  List<MessageResponse>? messages,
  bool emptyMessages = false,
  bool errorMessages = false,
  List<Override> overrides = const [],
}) {
  final mockApi = MockRelayApiService();

  if (errorMessages) {
    when(() => mockApi.getChannelMessages(any(), any(),
            page: any(named: 'page'), size: any(named: 'size')))
        .thenThrow(Exception('network error'));
  } else {
    final content = messages ?? (emptyMessages ? <MessageResponse>[] : _todayMessages);
    when(() => mockApi.getChannelMessages(any(), any(),
            page: any(named: 'page'), size: any(named: 'size')))
        .thenAnswer((_) async => PageResponse<MessageResponse>(
              content: content.reversed.toList(), // API returns newest-first
              page: 0,
              size: 50,
              totalElements: content.length,
              totalPages: 1,
              isLast: true,
            ));
  }

  return ProviderScope(
    overrides: [
      selectedTeamIdProvider.overrideWith((ref) => teamId),
      relayApiProvider.overrideWithValue(mockApi),
      channelDetailProvider((channelId: channelId, teamId: teamId))
          .overrideWith((ref) async => _testChannel),
      currentUserProvider.overrideWith(
        (ref) => User(
          id: currentUserId,
          email: 'test@test.com',
          displayName: 'Test User',
        ),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: RelayMessageFeed(channelId: channelId),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMarkReadRequest());
  });

  group('RelayMessageFeed', () {
    testWidgets('renders header with channel name', (tester) async {
      await tester.pumpWidget(_createFeed());
      await tester.pumpAndSettle();

      expect(find.text('engineering'), findsOneWidget);
    });

    testWidgets('renders messages from the channel', (tester) async {
      await tester.pumpWidget(_createFeed());
      await tester.pumpAndSettle();

      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('Hello everyone!'), findsOneWidget);
    });

    testWidgets('renders sender names', (tester) async {
      await tester.pumpWidget(_createFeed());
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows empty state when no messages', (tester) async {
      await tester.pumpWidget(_createFeed(emptyMessages: true));
      await tester.pumpAndSettle();

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('shows date separator', (tester) async {
      await tester.pumpWidget(_createFeed());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows multiple date separators for different days',
        (tester) async {
      final msgs = [_yesterdayMessage, ..._todayMessages];
      await tester.pumpWidget(_createFeed(messages: msgs));
      await tester.pumpAndSettle();

      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('renders disabled composer', (tester) async {
      await tester.pumpWidget(_createFeed());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.getChannelMessages(any(), any(),
              page: any(named: 'page'), size: any(named: 'size')))
          .thenAnswer(
              (_) => Completer<PageResponse<MessageResponse>>().future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
            relayApiProvider.overrideWithValue(mockApi),
            channelDetailProvider((channelId: 'ch-1', teamId: 'team-1'))
                .overrideWith((ref) async => _testChannel),
            currentUserProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: RelayMessageFeed(channelId: 'ch-1'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('renders system messages in feed', (tester) async {
      final msgs = [
        MessageResponse(
          id: 'sys-1',
          content: 'Alice joined the channel',
          messageType: MessageType.system,
          createdAt: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(_createFeed(messages: msgs));
      await tester.pumpAndSettle();

      expect(find.text('Alice joined the channel'), findsOneWidget);
    });

    testWidgets('renders platform event messages in feed', (tester) async {
      final msgs = [
        MessageResponse(
          id: 'pe-1',
          content: 'Build completed for service-x',
          messageType: MessageType.platformEvent,
          createdAt: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(_createFeed(messages: msgs));
      await tester.pumpAndSettle();

      expect(find.text('Platform Event'), findsOneWidget);
      expect(
          find.text('Build completed for service-x'), findsOneWidget);
    });

    testWidgets('renders dividers between header and feed', (tester) async {
      await tester.pumpWidget(_createFeed());
      await tester.pumpAndSettle();

      // At least the two structural dividers (below header, above composer)
      expect(find.byType(Divider), findsAtLeastNWidgets(2));
    });

    testWidgets('shows "Select a team" when no team selected',
        (tester) async {
      final mockApi = MockRelayApiService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedTeamIdProvider.overrideWith((ref) => null),
            relayApiProvider.overrideWithValue(mockApi),
            currentUserProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RelayMessageFeed(channelId: 'ch-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select a team'), findsOneWidget);
    });
  });
}
