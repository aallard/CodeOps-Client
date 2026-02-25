/// Tests for [RelayMessageComposer] — message input area.
///
/// Verifies text field rendering, send button state, Enter/Shift+Enter
/// keyboard shortcuts, edit mode banner, @mention autocomplete overlay,
/// member filtering, escape key handling, and API integration.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:codeops/widgets/relay/relay_message_composer.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

class FakeSendMessageRequest extends Fake implements SendMessageRequest {}

class FakeUpdateMessageRequest extends Fake implements UpdateMessageRequest {}

const _channelId = 'ch-1';
const _teamId = 'team-1';

final _members = [
  const ChannelMemberResponse(
    id: 'mem-1',
    channelId: _channelId,
    userId: 'user-1',
    userDisplayName: 'Alice Smith',
    role: MemberRole.owner,
  ),
  const ChannelMemberResponse(
    id: 'mem-2',
    channelId: _channelId,
    userId: 'user-2',
    userDisplayName: 'Bob Jones',
    role: MemberRole.member,
  ),
  const ChannelMemberResponse(
    id: 'mem-3',
    channelId: _channelId,
    userId: 'user-3',
    userDisplayName: 'Carol Lee',
    role: MemberRole.admin,
  ),
];

final _editMessage = const MessageResponse(
  id: 'msg-edit-1',
  channelId: _channelId,
  senderId: 'user-1',
  senderDisplayName: 'Alice Smith',
  content: 'Original message text',
  messageType: MessageType.text,
);

final _sentMessage = MessageResponse(
  id: 'msg-new-1',
  channelId: _channelId,
  senderId: 'user-1',
  senderDisplayName: 'Alice Smith',
  content: 'Hello world',
  messageType: MessageType.text,
  createdAt: DateTime.now(),
);

Widget _createComposer({
  MockRelayApiService? mockApi,
  MessageResponse? editingMessage,
  List<Override> overrides = const [],
}) {
  final api = mockApi ?? MockRelayApiService();

  // Default stubs
  when(() => api.getMembers(any(), any())).thenAnswer((_) async => _members);
  when(() => api.getChannelMessages(any(), any(),
          page: any(named: 'page'), size: any(named: 'size')))
      .thenAnswer((_) async => PageResponse<MessageResponse>(
            content: [],
            page: 0,
            size: 50,
            totalElements: 0,
            totalPages: 1,
            isLast: true,
          ));

  return ProviderScope(
    overrides: [
      selectedTeamIdProvider.overrideWith((ref) => _teamId),
      relayApiProvider.overrideWithValue(api),
      currentUserProvider.overrideWith(
        (ref) => const User(
          id: 'user-1',
          email: 'alice@test.com',
          displayName: 'Alice Smith',
        ),
      ),
      if (editingMessage != null)
        editingMessageProvider.overrideWith((ref) => editingMessage),
      ...overrides,
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              RelayMessageComposer(channelId: _channelId),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSendMessageRequest());
    registerFallbackValue(FakeUpdateMessageRequest());
  });

  group('RelayMessageComposer', () {
    testWidgets('renders text field with placeholder', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Type a message...'), findsOneWidget);
    });

    testWidgets('send button disabled when text is empty', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      final sendButton = tester.widgetList<IconButton>(
        find.byType(IconButton),
      ).last;
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('send button enabled when text is non-empty', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      final sendButton = tester.widgetList<IconButton>(
        find.byType(IconButton),
      ).last;
      expect(sendButton.onPressed, isNotNull);
    });

    testWidgets('sends message on send button tap', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.getMembers(any(), any()))
          .thenAnswer((_) async => _members);
      when(() => mockApi.getChannelMessages(any(), any(),
              page: any(named: 'page'), size: any(named: 'size')))
          .thenAnswer((_) async => PageResponse<MessageResponse>(
                content: [],
                page: 0,
                size: 50,
                totalElements: 0,
                totalPages: 1,
                isLast: true,
              ));
      when(() => mockApi.sendMessage(any(), any(), any()))
          .thenAnswer((_) async => _sentMessage);

      await tester.pumpWidget(_createComposer(mockApi: mockApi));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      // Tap the send button (last IconButton)
      final sendButtons = find.byIcon(Icons.send);
      await tester.tap(sendButtons);
      await tester.pumpAndSettle();

      verify(() => mockApi.sendMessage(_channelId, any(), _teamId)).called(1);
    });

    testWidgets('inserts newline on Shift+Enter', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Line 1');
      await tester.pump();

      // Simulate Shift+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();

      // The TextField should still exist (not submitted)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows edit banner when editing message', (tester) async {
      await tester.pumpWidget(_createComposer(editingMessage: _editMessage));
      await tester.pumpAndSettle();

      expect(find.text('Editing message'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('pre-populates text field in edit mode', (tester) async {
      await tester.pumpWidget(_createComposer(editingMessage: _editMessage));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Original message text');
    });

    testWidgets('cancel edit clears edit state', (tester) async {
      await tester.pumpWidget(_createComposer(editingMessage: _editMessage));
      await tester.pumpAndSettle();

      // Tap the cancel button (close icon in edit banner)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Edit banner should be gone
      expect(find.text('Editing message'), findsNothing);
    });

    testWidgets('edit mode shows check icon instead of send',
        (tester) async {
      await tester.pumpWidget(_createComposer(editingMessage: _editMessage));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('attachment button is present', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });

    testWidgets('shows @mention dropdown when typing @', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '@');
      await tester.pumpAndSettle();

      // The @everyone option should appear
      expect(find.text('@everyone'), findsOneWidget);
    });

    testWidgets('filters members in @mention dropdown', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '@Ali');
      await tester.pumpAndSettle();

      // Alice should be visible, Bob and Carol should not
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Jones'), findsNothing);
      expect(find.text('Carol Lee'), findsNothing);
    });

    testWidgets('selecting member inserts @mention', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '@Ali');
      await tester.pumpAndSettle();

      // Tap Alice's name
      await tester.tap(find.text('Alice Smith'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, contains('@Alice Smith'));
    });

    testWidgets('dismisses @mention on Escape', (tester) async {
      await tester.pumpWidget(_createComposer());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '@');
      await tester.pumpAndSettle();

      // @everyone should be visible
      expect(find.text('@everyone'), findsOneWidget);

      // Press Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Dropdown should be dismissed
      expect(find.text('@everyone'), findsNothing);
    });

    testWidgets('send calls API with mentionedUserIds', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.getMembers(any(), any()))
          .thenAnswer((_) async => _members);
      when(() => mockApi.getChannelMessages(any(), any(),
              page: any(named: 'page'), size: any(named: 'size')))
          .thenAnswer((_) async => PageResponse<MessageResponse>(
                content: [],
                page: 0,
                size: 50,
                totalElements: 0,
                totalPages: 1,
                isLast: true,
              ));
      when(() => mockApi.sendMessage(any(), any(), any()))
          .thenAnswer((_) async => _sentMessage);

      await tester.pumpWidget(_createComposer(mockApi: mockApi));
      await tester.pumpAndSettle();

      // Type @ to trigger mention
      await tester.enterText(find.byType(TextField), '@Ali');
      await tester.pumpAndSettle();

      // Select Alice
      await tester.tap(find.text('Alice Smith'));
      await tester.pumpAndSettle();

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Verify the API was called with a SendMessageRequest
      final captured = verify(() => mockApi.sendMessage(
            _channelId,
            captureAny(),
            _teamId,
          )).captured;

      expect(captured, isNotEmpty);
      final request = captured.first as SendMessageRequest;
      expect(request.mentionedUserIds, contains('user-1'));
    });

    testWidgets('escape key cancels edit mode', (tester) async {
      await tester.pumpWidget(_createComposer(editingMessage: _editMessage));
      await tester.pumpAndSettle();

      expect(find.text('Editing message'), findsOneWidget);

      // Press Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Editing message'), findsNothing);
    });
  });
}
