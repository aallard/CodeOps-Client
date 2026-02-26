/// Tests for [DmListTile] — single DM conversation entry in the sidebar.
///
/// Verifies participant name rendering, last message preview, relative
/// timestamp, unread badge, selected styling, tap callback, and live
/// presence indicator.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/widgets/relay/dm_list_tile.dart';
import 'package:codeops/widgets/relay/relay_presence_indicator.dart';

Widget _createTile({
  DirectConversationSummaryResponse? conversation,
  bool isSelected = false,
  VoidCallback? onTap,
  List<UserPresenceResponse> presences = const [],
}) {
  return ProviderScope(
    overrides: [
      selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
      teamPresenceProvider('team-1')
          .overrideWith((ref) async => presences),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 260,
          child: DmListTile(
            conversation: conversation ??
                DirectConversationSummaryResponse(
                  id: 'dm-1',
                  conversationType: ConversationType.oneOnOne,
                  participantIds: const ['user-1'],
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

    testWidgets('shows presence indicator from provider', (tester) async {
      const presences = [
        UserPresenceResponse(
          userId: 'user-1',
          userDisplayName: 'Adam Allard',
          teamId: 'team-1',
          status: PresenceStatus.online,
        ),
      ];
      await tester.pumpWidget(_createTile(presences: presences));
      await tester.pumpAndSettle();

      expect(find.byType(RelayPresenceIndicator), findsOneWidget);
    });

    testWidgets('defaults to offline when no presence data', (tester) async {
      await tester.pumpWidget(_createTile());
      await tester.pumpAndSettle();

      final indicator = tester.widget<RelayPresenceIndicator>(
        find.byType(RelayPresenceIndicator),
      );
      expect(indicator.status, PresenceStatus.offline);
    });
  });
}
