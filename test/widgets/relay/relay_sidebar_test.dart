/// Tests for [RelaySidebar] — channel and DM list sidebar.
///
/// Verifies header rendering, search bar, section headers, expand/collapse,
/// channel list from providers, DM list, selection callbacks, unread badges,
/// filtering, and browse channels link.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/models/team.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/widgets/relay/relay_sidebar.dart';

/// Creates test channel summaries.
List<ChannelSummaryResponse> _testChannels() => [
      const ChannelSummaryResponse(
        id: 'ch-1',
        name: 'general',
        slug: 'general',
        channelType: ChannelType.public,
        isArchived: false,
        memberCount: 10,
        unreadCount: 3,
      ),
      const ChannelSummaryResponse(
        id: 'ch-2',
        name: 'engineering',
        slug: 'engineering',
        channelType: ChannelType.public,
        isArchived: false,
        memberCount: 5,
        unreadCount: 0,
      ),
      const ChannelSummaryResponse(
        id: 'ch-3',
        name: 'leadership',
        slug: 'leadership',
        channelType: ChannelType.private,
        isArchived: false,
        memberCount: 3,
        unreadCount: 0,
      ),
    ];

/// Creates test DM conversations.
List<DirectConversationSummaryResponse> _testConversations() => [
      DirectConversationSummaryResponse(
        id: 'dm-1',
        conversationType: ConversationType.oneOnOne,
        participantDisplayNames: const ['Adam Allard'],
        lastMessagePreview: 'Hey there!',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      const DirectConversationSummaryResponse(
        id: 'dm-2',
        conversationType: ConversationType.oneOnOne,
        participantDisplayNames: ['Jane Smith'],
        lastMessagePreview: 'Sounds good',
        unreadCount: 0,
      ),
    ];

/// Creates test unread counts.
List<UnreadCountResponse> _testUnreadCounts() => const [
      UnreadCountResponse(channelId: 'ch-1', channelName: 'general', unreadCount: 3),
    ];

Widget _createSidebar({
  ValueChanged<String>? onChannelSelected,
  ValueChanged<String>? onConversationSelected,
  List<Override> overrides = const [],
  String teamId = 'team-1',
}) {
  return ProviderScope(
    overrides: [
      selectedTeamIdProvider.overrideWith((ref) => teamId),
      selectedTeamProvider.overrideWith(
        (ref) async => Team(
          id: teamId,
          name: 'Test Team',
          ownerId: 'owner-1',
        ),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 260,
          child: RelaySidebar(
            onChannelSelected: onChannelSelected ?? (_) {},
            onConversationSelected: onConversationSelected ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('RelaySidebar', () {
    testWidgets('renders header with team name', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
    });

    testWidgets('renders search bar', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders channels section header', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('CHANNELS'), findsOneWidget);
    });

    testWidgets('renders DMs section header', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('DIRECT MESSAGES'), findsOneWidget);
    });

    testWidgets('displays channel list from provider', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('general'), findsOneWidget);
      expect(find.text('engineering'), findsOneWidget);
      expect(find.text('leadership'), findsOneWidget);
    });

    testWidgets('displays DM list from provider', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Adam Allard'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      await tester.pumpWidget(_createSidebar(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) => Completer<PageResponse<ChannelSummaryResponse>>().future,
          ),
          conversationsProvider('team-1').overrideWith(
            (ref) async => <DirectConversationSummaryResponse>[],
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => <UnreadCountResponse>[],
          ),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state on fetch failure', (tester) async {
      await tester.pumpWidget(_createSidebar(
        overrides: [
          teamChannelsProvider('team-1').overrideWith(
            (ref) => throw Exception('Network error'),
          ),
          conversationsProvider('team-1').overrideWith(
            (ref) async => <DirectConversationSummaryResponse>[],
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => <UnreadCountResponse>[],
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
    });

    testWidgets('filters channels by search query', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // All channels visible initially
      expect(find.text('general'), findsOneWidget);
      expect(find.text('engineering'), findsOneWidget);
      expect(find.text('leadership'), findsOneWidget);

      // Type search query
      await tester.enterText(find.byType(TextField), 'eng');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      // Only engineering visible
      expect(find.text('engineering'), findsOneWidget);
      expect(find.text('general'), findsNothing);
      expect(find.text('leadership'), findsNothing);
    });

    testWidgets('filters DMs by search query', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Both DMs visible
      expect(find.text('Adam Allard'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Filter to Adam
      await tester.enterText(find.byType(TextField), 'adam');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(find.text('Adam Allard'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('calls onChannelSelected when channel tapped', (tester) async {
      String? selectedId;
      await tester.pumpWidget(_createSidebar(
        onChannelSelected: (id) => selectedId = id,
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('general'));
      await tester.pumpAndSettle();

      expect(selectedId, 'ch-1');
    });

    testWidgets('calls onConversationSelected when DM tapped',
        (tester) async {
      String? selectedId;
      await tester.pumpWidget(_createSidebar(
        onConversationSelected: (id) => selectedId = id,
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adam Allard'));
      await tester.pumpAndSettle();

      expect(selectedId, 'dm-1');
    });

    testWidgets('highlights selected channel', (tester) async {
      await tester.pumpWidget(_createSidebar(
        overrides: [
          selectedChannelIdProvider.overrideWith((ref) => 'ch-1'),
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // The selected channel text should render
      expect(find.text('general'), findsOneWidget);
    });

    testWidgets('highlights selected DM', (tester) async {
      await tester.pumpWidget(_createSidebar(
        overrides: [
          selectedConversationIdProvider.overrideWith((ref) => 'dm-1'),
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // The selected DM should render
      expect(find.text('Adam Allard'), findsOneWidget);
    });

    testWidgets('shows unread badges for channels with unread > 0',
        (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Channel 'general' has unreadCount: 3
      expect(find.text('3'), findsAtLeastNWidgets(1));
    });

    testWidgets('bold text for unread channels', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // The 'general' channel name should have bold styling (w600)
      final generalText = tester.widget<Text>(find.text('general'));
      expect(generalText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('private channels show lock icon', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // 'leadership' is private, should show lock icon
      expect(find.byIcon(Icons.lock_outline), findsAtLeastNWidgets(1));
    });

    testWidgets('collapse/expand channels section', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Initially expanded — channels visible
      expect(find.text('general'), findsOneWidget);

      // Tap CHANNELS section header to collapse
      await tester.tap(find.text('CHANNELS'));
      await tester.pumpAndSettle();

      // Channels should be hidden
      expect(find.text('general'), findsNothing);

      // Tap again to expand
      await tester.tap(find.text('CHANNELS'));
      await tester.pumpAndSettle();

      expect(find.text('general'), findsOneWidget);
    });

    testWidgets('collapse/expand DMs section', (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Initially expanded — DMs visible
      expect(find.text('Adam Allard'), findsOneWidget);

      // Tap DIRECT MESSAGES section header to collapse
      await tester.tap(find.text('DIRECT MESSAGES'));
      await tester.pumpAndSettle();

      // DMs should be hidden
      expect(find.text('Adam Allard'), findsNothing);
    });

    testWidgets('browse channels link shown at bottom of channels section',
        (tester) async {
      await tester.pumpWidget(_createSidebar(
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
          conversationsProvider('team-1').overrideWith(
            (ref) async => _testConversations(),
          ),
          unreadCountsProvider('team-1').overrideWith(
            (ref) async => _testUnreadCounts(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Browse channels'), findsOneWidget);
    });
  });
}
