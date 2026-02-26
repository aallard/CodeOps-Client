/// Tests for reaction interactions on [RelayMessageBubble].
///
/// Verifies reaction chip rendering, tap-to-toggle via API,
/// optimistic update behavior, [+] add-reaction button, context
/// menu "Add reaction" item, and tooltip content.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/services/cloud/relay_api.dart';
import 'package:codeops/widgets/relay/relay_emoji_picker.dart';
import 'package:codeops/widgets/relay/relay_message_bubble.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

class FakeAddReactionRequest extends Fake implements AddReactionRequest {}

Widget _createBubble(
  MessageResponse message, {
  bool isOwnMessage = false,
  MockRelayApiService? mockApi,
  List<Override> overrides = const [],
}) {
  final api = mockApi ?? MockRelayApiService();

  return ProviderScope(
    overrides: [
      relayApiProvider.overrideWithValue(api),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RelayMessageBubble(
            message: message,
            isOwnMessage: isOwnMessage,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAddReactionRequest());
  });

  group('Reaction interactions', () {
    testWidgets('reaction chips are rendered with counts', (tester) async {
      const msg = MessageResponse(
        id: 'msg-1',
        senderDisplayName: 'Alice',
        content: 'Hello',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F44D}',
            count: 3,
            currentUserReacted: false,
          ),
          ReactionSummaryResponse(
            emoji: '\u{2764}',
            count: 1,
            currentUserReacted: true,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.textContaining('3'), findsOneWidget);
      expect(find.textContaining('1'), findsOneWidget);
    });

    testWidgets('tapping reaction chip calls toggleReaction API',
        (tester) async {
      final api = MockRelayApiService();
      when(() => api.toggleReaction(any(), any()))
          .thenAnswer((_) async => null);

      const msg = MessageResponse(
        id: 'msg-2',
        senderDisplayName: 'Bob',
        content: 'React!',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F44D}',
            count: 2,
            currentUserReacted: false,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg, mockApi: api));
      await tester.pumpAndSettle();

      // Tap the reaction chip
      await tester.tap(find.textContaining('2'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => api.toggleReaction('msg-2', captureAny()),
      ).captured;

      expect(captured, isNotEmpty);
      final request = captured.first as AddReactionRequest;
      expect(request.emoji, '\u{1F44D}');
    });

    testWidgets('optimistic update changes count immediately', (tester) async {
      final api = MockRelayApiService();
      // Use a Completer so the API future stays pending while we
      // inspect the optimistic state.
      final completer = Completer<ReactionResponse?>();
      when(() => api.toggleReaction(any(), any()))
          .thenAnswer((_) => completer.future);

      const msg = MessageResponse(
        id: 'msg-3',
        senderDisplayName: 'Carol',
        content: 'Count check',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F44D}',
            count: 2,
            currentUserReacted: false,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg, mockApi: api));
      await tester.pumpAndSettle();

      // Before tap: count is 2
      expect(find.textContaining('2'), findsOneWidget);

      // Tap the reaction chip
      await tester.tap(find.textContaining('2'));
      await tester.pump(); // Process the optimistic state change

      // After tap: count should be 3 (optimistic — API still pending)
      expect(find.textContaining('3'), findsOneWidget);

      // Complete the API call to avoid dangling futures.
      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('[+] button is present when reactions exist', (tester) async {
      const msg = MessageResponse(
        id: 'msg-4',
        senderDisplayName: 'Dave',
        content: 'Has reactions',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F525}',
            count: 1,
            currentUserReacted: false,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      // The [+] button uses Icons.add
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('[+] button opens emoji picker', (tester) async {
      const msg = MessageResponse(
        id: 'msg-5',
        senderDisplayName: 'Eve',
        content: 'Pick emoji',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F44D}',
            count: 1,
            currentUserReacted: false,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Emoji picker should be visible
      expect(find.text('Pick a reaction'), findsOneWidget);
      expect(find.byType(RelayEmojiPicker), findsOneWidget);
    });

    testWidgets('context menu shows "Add reaction" for any message',
        (tester) async {
      const msg = MessageResponse(
        id: 'msg-6',
        senderDisplayName: 'Frank',
        content: 'Context menu test',
        messageType: MessageType.text,
      );

      await tester.pumpWidget(_createBubble(msg, isOwnMessage: false));
      await tester.pumpAndSettle();

      // Long press to open context menu
      await tester.longPress(find.text('Context menu test'));
      await tester.pumpAndSettle();

      expect(find.text('Add reaction'), findsOneWidget);
      expect(find.byIcon(Icons.add_reaction_outlined), findsOneWidget);
    });

    testWidgets('context menu shows "Edit" only for own messages',
        (tester) async {
      const msg = MessageResponse(
        id: 'msg-7',
        senderDisplayName: 'Grace',
        content: 'Own message',
        messageType: MessageType.text,
      );

      // Own message — should see both
      await tester.pumpWidget(_createBubble(msg, isOwnMessage: true));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Own message'));
      await tester.pumpAndSettle();

      expect(find.text('Add reaction'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('context menu "Add reaction" opens emoji picker',
        (tester) async {
      const msg = MessageResponse(
        id: 'msg-8',
        senderDisplayName: 'Heidi',
        content: 'React from menu',
        messageType: MessageType.text,
      );

      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      // Long press to open context menu
      await tester.longPress(find.text('React from menu'));
      await tester.pumpAndSettle();

      // Tap "Add reaction"
      await tester.tap(find.text('Add reaction'));
      await tester.pumpAndSettle();

      // Emoji picker should appear
      expect(find.text('Pick a reaction'), findsOneWidget);
    });

    testWidgets('reaction chip has tooltip', (tester) async {
      const msg = MessageResponse(
        id: 'msg-9',
        senderDisplayName: 'Ivan',
        content: 'Tooltip test',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F44D}',
            count: 3,
            currentUserReacted: true,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      // Find the Tooltip widget wrapping the reaction
      expect(find.byType(Tooltip), findsOneWidget);

      // Verify the tooltip message
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(
        tooltip.message,
        'You and 2 others reacted with \u{1F44D}',
      );
    });

    testWidgets('tooltip for non-self reaction shows people count',
        (tester) async {
      const msg = MessageResponse(
        id: 'msg-10',
        senderDisplayName: 'Jack',
        content: 'Non-self tooltip',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{2764}',
            count: 5,
            currentUserReacted: false,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(
        tooltip.message,
        '5 people reacted with \u{2764}',
      );
    });

    testWidgets('selecting emoji from picker calls toggleReaction',
        (tester) async {
      final api = MockRelayApiService();
      when(() => api.toggleReaction(any(), any()))
          .thenAnswer((_) async => null);

      const msg = MessageResponse(
        id: 'msg-11',
        senderDisplayName: 'Kate',
        content: 'Picker reaction',
        messageType: MessageType.text,
        reactions: [
          ReactionSummaryResponse(
            emoji: '\u{1F44D}',
            count: 1,
            currentUserReacted: false,
          ),
        ],
      );

      await tester.pumpWidget(_createBubble(msg, mockApi: api));
      await tester.pumpAndSettle();

      // Open picker via [+] button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Pick the fire emoji
      await tester.tap(find.text('\u{1F525}'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => api.toggleReaction('msg-11', captureAny()),
      ).captured;

      expect(captured, isNotEmpty);
      final request = captured.first as AddReactionRequest;
      expect(request.emoji, '\u{1F525}');
    });

    testWidgets('deleted messages do not show context menu', (tester) async {
      const msg = MessageResponse(
        id: 'msg-12',
        senderDisplayName: 'Leo',
        content: 'Deleted msg',
        messageType: MessageType.text,
        isDeleted: true,
      );

      await tester.pumpWidget(_createBubble(msg, isOwnMessage: true));
      await tester.pumpAndSettle();

      // Long press on the deleted placeholder
      await tester.longPress(find.text('This message was deleted'));
      await tester.pumpAndSettle();

      // Context menu should NOT appear
      expect(find.text('Add reaction'), findsNothing);
      expect(find.text('Edit'), findsNothing);
    });
  });
}
