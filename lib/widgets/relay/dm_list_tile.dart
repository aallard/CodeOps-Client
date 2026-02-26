/// A single DM conversation entry in the Relay sidebar.
///
/// Shows participant name(s), last message preview, relative timestamp,
/// unread badge, selection highlighting, and live presence indicator.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import 'relay_presence_indicator.dart';

/// A single DM conversation entry in the Relay sidebar.
///
/// Shows participant display name(s), live presence indicator dot,
/// last message preview, and unread badge.
class DmListTile extends ConsumerWidget {
  /// The conversation summary data to display.
  final DirectConversationSummaryResponse conversation;

  /// Whether this conversation is currently selected.
  final bool isSelected;

  /// Called when the user taps this conversation.
  final VoidCallback onTap;

  /// Creates a [DmListTile].
  const DmListTile({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Returns the display name for this conversation.
  ///
  /// For named group conversations, returns the name. Otherwise joins
  /// participant display names with commas.
  String get _displayName {
    if (conversation.name != null && conversation.name!.isNotEmpty) {
      return conversation.name!;
    }
    final names = conversation.participantDisplayNames;
    if (names == null || names.isEmpty) return 'Unknown';
    return names.join(', ');
  }

  /// Returns a compact relative timestamp for the last message.
  String get _relativeTime {
    final dt = conversation.lastMessageAt;
    if (dt == null) return '';
    return formatTimeAgo(dt);
  }

  /// Whether there are unread messages.
  bool get _hasUnread => (conversation.unreadCount ?? 0) > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = conversation.unreadCount ?? 0;
    final teamId = ref.watch(selectedTeamIdProvider);
    // Use the first participant's ID for presence lookup.
    final participantId = (conversation.participantIds != null &&
            conversation.participantIds!.isNotEmpty)
        ? conversation.participantIds!.first
        : null;
    final presenceStatus = (teamId != null && participantId != null)
        ? ref.watch(userPresenceProvider(
            (teamId: teamId, userId: participantId)))
        : null;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Live presence indicator
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: RelayPresenceIndicator(
                    status: presenceStatus ?? PresenceStatus.offline,
                  ),
                ),
                // Name + preview column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _displayName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: (isSelected || _hasUnread)
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected || _hasUnread
                              ? CodeOpsColors.textPrimary
                              : CodeOpsColors.textSecondary,
                        ),
                      ),
                      if (conversation.lastMessagePreview != null &&
                          conversation.lastMessagePreview!.isNotEmpty)
                        Text(
                          conversation.lastMessagePreview!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 11,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                // Timestamp + unread badge column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_relativeTime.isNotEmpty)
                      Text(
                        _relativeTime,
                        style: const TextStyle(
                          fontSize: 10,
                          color: CodeOpsColors.textTertiary,
                        ),
                      ),
                    if (unread > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CodeOpsColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
