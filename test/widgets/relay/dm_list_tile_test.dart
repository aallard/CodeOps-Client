/// Tests for [DmListTile] — single DM conversation entry in the sidebar.
///
/// Verifies participant name rendering, last message preview, relative
/// timestamp, unread badge, selected styling, and tap callback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/widgets/relay/dm_list_tile.dart';

Widget _createTile({
  DirectConversationSummaryResponse? conversation,
  bool isSelected = false,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 260,
        child: DmListTile(
          conversation: conversation ??
              DirectConversationSummaryResponse(
                id: 'dm-1',
                conversationType: ConversationType.oneOnOne,
                participantDisplayNames: const ['Adam Allard'],
                lastMessagePreview: 'Hey there!',
                lastMessageAt:
                    DateTime.now().subtract(const Duration(minutes: 2)),
                unreadCount: 3,
              ),
          isSelected: isSelected,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('DmListTile', () {
    testWidgets('renders participant name', (tester) async {
      await tester.pumpWidget(_createTile());
      await tester.pumpAndSettle();

      expect(find.text('Adam Allard'), findsOneWidget);
    });

    testWidgets('renders last message preview', (tester) async {
      await tester.pumpWidget(_createTile());
      await tester.pumpAndSettle();

      expect(find.text('Hey there!'), findsOneWidget);
    });

    testWidgets('renders relative timestamp', (tester) async {
      await tester.pumpWidget(_createTile());
      await tester.pumpAndSettle();

      // Should show '2m ago' since lastMessageAt is 2 minutes ago
      expect(find.text('2m ago'), findsOneWidget);
    });

    testWidgets('renders unread badge', (tester) async {
      await tester.pumpWidget(_createTile());
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('applies selected styling', (tester) async {
      await tester.pumpWidget(_createTile(isSelected: true));
      await tester.pumpAndSettle();

      final nameText = tester.widget<Text>(find.text('Adam Allard'));
      expect(nameText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('calls onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_createTile(onTap: () => tapped = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adam Allard'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
