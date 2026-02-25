/// A single channel entry in the Relay sidebar.
///
/// Displays channel name with type-appropriate prefix (# or lock icon),
/// unread count badge, selection highlighting, and a context menu for
/// channel management actions (mark as read, mute, leave, settings).
library;

import 'package:flutter/material.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../theme/colors.dart';

/// A single channel entry in the Relay sidebar.
///
/// Displays channel name with type-appropriate prefix (# or lock icon),
/// unread count badge, and selection highlighting.
class ChannelListTile extends StatelessWidget {
  /// The channel summary data to display.
  final ChannelSummaryResponse channel;

  /// Whether this channel is currently selected.
  final bool isSelected;

  /// Number of unread messages in this channel.
  final int unreadCount;

  /// Called when the user taps this channel.
  final VoidCallback onTap;

  /// Called when the user long-presses or right-clicks this channel.
  final VoidCallback? onLongPress;

  /// Creates a [ChannelListTile].
  const ChannelListTile({
    required this.channel,
    required this.isSelected,
    required this.unreadCount,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  /// Returns the appropriate prefix widget based on channel type.
  Widget _buildPrefix() {
    final isPrivate = channel.channelType == ChannelType.private;
    if (isPrivate) {
      return const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Icon(
          Icons.lock_outline,
          size: 14,
          color: CodeOpsColors.textTertiary,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        '#',
        style: TextStyle(
          fontSize: 14,
          fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w400,
          color: isSelected
              ? CodeOpsColors.textPrimary
              : CodeOpsColors.textTertiary,
        ),
      ),
    );
  }

  /// Builds the unread badge indicator.
  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: CodeOpsColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Shows a context menu with channel management actions.
  void _showContextMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: CodeOpsColors.surface,
      items: [
        const PopupMenuItem(
          value: 'mark_read',
          child: Row(
            children: [
              Icon(Icons.done_all, size: 16, color: CodeOpsColors.textSecondary),
              SizedBox(width: 8),
              Text('Mark as read',
                  style: TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'mute',
          child: Row(
            children: [
              Icon(Icons.volume_off_outlined,
                  size: 16, color: CodeOpsColors.textSecondary),
              SizedBox(width: 8),
              Text('Mute channel',
                  style: TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 16, color: CodeOpsColors.textSecondary),
              SizedBox(width: 8),
              Text('Channel settings',
                  style: TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'leave',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, size: 16, color: CodeOpsColors.error),
              SizedBox(width: 8),
              Text('Leave channel',
                  style: TextStyle(fontSize: 13, color: CodeOpsColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;

    return Container(
      height: 32,
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
          onLongPress: onLongPress,
          onSecondaryTapUp: (details) =>
              _showContextMenu(context, details.globalPosition),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildPrefix(),
                Expanded(
                  child: Text(
                    channel.name ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: (isSelected || hasUnread)
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? CodeOpsColors.textPrimary
                          : (hasUnread
                              ? CodeOpsColors.textPrimary
                              : CodeOpsColors.textSecondary),
                    ),
                  ),
                ),
                if (hasUnread) _buildUnreadBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
