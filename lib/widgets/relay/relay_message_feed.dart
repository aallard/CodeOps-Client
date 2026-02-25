/// Message feed widget for the Relay module center panel.
///
/// Replaces the placeholder [RelayMessagePanel] with a fully wired
/// message feed: header bar, scrollable message list with date separators,
/// infinite scroll loading, mark-as-read debouncing, and a disabled
/// composer placeholder (enabled in RLF-004).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_models.dart';
import '../../providers/auth_providers.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/shared/error_panel.dart';
import 'relay_date_separator.dart';
import 'relay_message_bubble.dart';
import 'relay_message_composer.dart';
import 'relay_message_feed_header.dart';

/// Full message feed panel for a single channel.
///
/// Composes [RelayMessageFeedHeader], a scrollable list of
/// [RelayMessageBubble] and [RelayDateSeparator] widgets, and a
/// placeholder composer. Uses [AccumulatedMessagesNotifier] for
/// paginated message loading with infinite scroll.
class RelayMessageFeed extends ConsumerStatefulWidget {
  /// UUID of the channel to display messages for.
  final String channelId;

  /// Creates a [RelayMessageFeed].
  const RelayMessageFeed({required this.channelId, super.key});

  @override
  ConsumerState<RelayMessageFeed> createState() => _RelayMessageFeedState();
}

class _RelayMessageFeedState extends ConsumerState<RelayMessageFeed> {
  final _scrollController = ScrollController();
  Timer? _markReadTimer;
  bool _isAtBottom = true;

  /// Resolves the current team ID from the selected team provider.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _markReadTimer?.cancel();
    super.dispose();
  }

  /// Handles scroll events for infinite scroll and mark-as-read.
  void _onScroll() {
    final position = _scrollController.position;

    // Infinite scroll: load more when near the top (older messages)
    if (position.pixels <= position.minScrollExtent + 200) {
      final teamId = _teamId;
      if (teamId == null) return;
      final notifier = ref.read(
        accumulatedMessagesProvider(
          (channelId: widget.channelId, teamId: teamId),
        ).notifier,
      );
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadNextPage();
      }
    }

    // Track if user is at the bottom for mark-as-read
    _isAtBottom = position.pixels >= position.maxScrollExtent - 50;
    if (_isAtBottom) {
      _scheduleMarkRead();
    }
  }

  /// Schedules a mark-as-read API call with 1-second debounce.
  void _scheduleMarkRead() {
    _markReadTimer?.cancel();
    _markReadTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      final teamId = _teamId;
      if (teamId == null) return;

      final messages = ref
          .read(
            accumulatedMessagesProvider(
              (channelId: widget.channelId, teamId: teamId),
            ),
          )
          .valueOrNull;
      if (messages == null || messages.isEmpty) return;

      final lastMessage = messages.last;
      if (lastMessage.id == null) return;

      final api = ref.read(relayApiProvider);
      api.markRead(
        widget.channelId,
        MarkReadRequest(lastReadMessageId: lastMessage.id!),
      );
    });
  }

  /// Scrolls to the bottom of the feed.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);
    if (teamId == null) {
      return const Center(
        child: Text(
          'Select a team',
          style: TextStyle(color: CodeOpsColors.textTertiary),
        ),
      );
    }

    final messagesAsync = ref.watch(
      accumulatedMessagesProvider(
        (channelId: widget.channelId, teamId: teamId),
      ),
    );
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      children: [
        RelayMessageFeedHeader(channelId: widget.channelId, teamId: teamId),
        const Divider(height: 1, color: CodeOpsColors.border),
        Expanded(
          child: messagesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorPanel.fromException(
              e,
              onRetry: () => ref
                  .read(
                    accumulatedMessagesProvider(
                      (channelId: widget.channelId, teamId: teamId),
                    ).notifier,
                  )
                  .refresh(),
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                );
              }

              // Schedule scroll to bottom on first load
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_isAtBottom) _scrollToBottom();
              });

              return _buildMessageList(messages, currentUser?.id);
            },
          ),
        ),
        const Divider(height: 1, color: CodeOpsColors.border),
        RelayMessageComposer(channelId: widget.channelId),
      ],
    );
  }

  /// Builds the scrollable message list with date separators.
  Widget _buildMessageList(List<MessageResponse> messages, String? userId) {
    final items = <Widget>[];
    DateTime? lastDate;

    for (final msg in messages) {
      final msgDate = msg.createdAt;
      if (msgDate != null) {
        final day = DateTime(msgDate.year, msgDate.month, msgDate.day);
        if (lastDate == null || day != lastDate) {
          items.add(RelayDateSeparator(date: msgDate));
          lastDate = day;
        }
      }

      items.add(
        RelayMessageBubble(
          key: ValueKey(msg.id),
          message: msg,
          isOwnMessage: userId != null && msg.senderId == userId,
          onThreadTap: msg.id != null
              ? () {
                  ref.read(threadRootMessageIdProvider.notifier).state = msg.id;
                  ref.read(showThreadPanelProvider.notifier).state = true;
                }
              : null,
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: items,
    );
  }

}
