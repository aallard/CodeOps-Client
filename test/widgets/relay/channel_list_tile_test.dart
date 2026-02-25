/// Tests for [ChannelListTile] — single channel entry in the sidebar.
///
/// Verifies channel name rendering, type prefix (# or lock), unread badge,
/// bold styling, selected styling, tap callback, and context menu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/widgets/relay/channel_list_tile.dart';

Widget _createTile({
  ChannelSummaryResponse? channel,
  bool isSelected = false,
  int unreadCount = 0,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 260,
        child: ChannelListTile(
          channel: channel ??
              const ChannelSummaryResponse(
                id: 'ch-1',
                name: 'general',
                slug: 'general',
                channelType: ChannelType.public,
                isArchived: false,
                memberCount: 10,
                unreadCount: 0,
              ),
          isSelected: isSelected,
          unreadCount: unreadCount,
          onTap: onTap ?? () {},
          onLongPress: onLongPress,
        ),
      ),
    ),
  );
}

void main() {
  group('ChannelListTile', () {
    testWidgets('renders channel name with hash prefix', (tester) async {
      await tester.pumpWidget(_createTile());
      await tester.pumpAndSettle();

      expect(find.text('general'), findsOneWidget);
      expect(find.text('#'), findsOneWidget);
    });

    testWidgets('renders lock icon for private channels', (tester) async {
      await tester.pumpWidget(_createTile(
        channel: const ChannelSummaryResponse(
          id: 'ch-priv',
          name: 'secret',
          slug: 'secret',
          channelType: ChannelType.private,
          isArchived: false,
          memberCount: 3,
          unreadCount: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('#'), findsNothing);
    });

    testWidgets('renders unread badge when count > 0', (tester) async {
      await tester.pumpWidget(_createTile(unreadCount: 5));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides unread badge when count is 0', (tester) async {
      await tester.pumpWidget(_createTile(unreadCount: 0));
      await tester.pumpAndSettle();

      // No badge text should appear
      expect(find.text('0'), findsNothing);
    });

    testWidgets('bold name when unread', (tester) async {
      await tester.pumpWidget(_createTile(unreadCount: 3));
      await tester.pumpAndSettle();

      final nameText = tester.widget<Text>(find.text('general'));
      expect(nameText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('applies selected styling', (tester) async {
      await tester.pumpWidget(_createTile(isSelected: true));
      await tester.pumpAndSettle();

      // Selected channel should be rendered with bold text
      final nameText = tester.widget<Text>(find.text('general'));
      expect(nameText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('calls onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_createTile(onTap: () => tapped = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('general'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('long press triggers onLongPress', (tester) async {
      bool longPressed = false;
      await tester.pumpWidget(
          _createTile(onLongPress: () => longPressed = true));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('general'));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });
  });
}
