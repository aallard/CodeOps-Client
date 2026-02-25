/// Dialog for browsing and joining public Relay channels.
///
/// Shows all public channels the user can join, with search filtering,
/// member counts, and one-click join functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Dialog for browsing and joining public Relay channels.
///
/// Shows all public channels the user can join, with search,
/// member counts, and one-click join.
class BrowseChannelsDialog extends ConsumerStatefulWidget {
  /// The team ID to browse channels for.
  final String teamId;

  /// Creates a [BrowseChannelsDialog].
  const BrowseChannelsDialog({required this.teamId, super.key});

  @override
  ConsumerState<BrowseChannelsDialog> createState() =>
      _BrowseChannelsDialogState();
}

class _BrowseChannelsDialogState extends ConsumerState<BrowseChannelsDialog> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final Set<String> _joiningChannelIds = {};
  final Set<String> _joinedChannelIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Joins a public channel by ID.
  Future<void> _joinChannel(ChannelSummaryResponse channel) async {
    if (channel.id == null) return;
    setState(() => _joiningChannelIds.add(channel.id!));

    try {
      final api = ref.read(relayApiProvider);
      await api.joinChannel(channel.id!, widget.teamId);
      ref.invalidate(teamChannelsProvider(widget.teamId));
      if (mounted) {
        setState(() {
          _joiningChannelIds.remove(channel.id!);
          _joinedChannelIds.add(channel.id!);
        });
        showToast(
          context,
          message: 'Joined #${channel.name ?? 'channel'}',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _joiningChannelIds.remove(channel.id!));
        showToast(
          context,
          message: 'Failed to join channel: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(teamChannelsProvider(widget.teamId));

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.explore_outlined,
                      size: 20, color: CodeOpsColors.primary),
                  const SizedBox(width: 10),
                  const Text(
                    'Browse Channels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: CodeOpsColors.textTertiary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: CodeOpsColors.border),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                style: const TextStyle(
                    fontSize: 13, color: CodeOpsColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search channels...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: CodeOpsColors.textTertiary),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: CodeOpsColors.textTertiary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.primary),
                  ),
                  filled: true,
                  fillColor: CodeOpsColors.background,
                ),
              ),
            ),

            // Channel list
            Flexible(
              child: channelsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load channels: $e',
                    style: const TextStyle(
                        fontSize: 13, color: CodeOpsColors.error),
                  ),
                ),
                data: (page) {
                  // Show all non-archived public channels
                  var channels = page.content
                      .where((c) =>
                          c.isArchived != true &&
                          c.channelType == ChannelType.public)
                      .toList();

                  if (_searchQuery.isNotEmpty) {
                    channels = channels
                        .where((c) =>
                            (c.name ?? '')
                                .toLowerCase()
                                .contains(_searchQuery))
                        .toList();
                  }

                  channels.sort((a, b) => (a.name ?? '')
                      .toLowerCase()
                      .compareTo((b.name ?? '').toLowerCase()));

                  if (channels.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No channels found',
                          style: TextStyle(
                              fontSize: 13,
                              color: CodeOpsColors.textTertiary),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: channels.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: CodeOpsColors.border),
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return _BrowseChannelRow(
                        channel: channel,
                        isJoining:
                            _joiningChannelIds.contains(channel.id),
                        isJoined:
                            _joinedChannelIds.contains(channel.id),
                        onJoin: () => _joinChannel(channel),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row in the browse channels list.
class _BrowseChannelRow extends StatelessWidget {
  final ChannelSummaryResponse channel;
  final bool isJoining;
  final bool isJoined;
  final VoidCallback onJoin;

  const _BrowseChannelRow({
    required this.channel,
    required this.isJoining,
    required this.isJoined,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Channel info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '# ${channel.name ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                if (channel.topic != null && channel.topic!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      channel.topic!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Member count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline,
                    size: 14, color: CodeOpsColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${channel.memberCount ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Join button or Joined indicator
          if (isJoined)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: CodeOpsColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Joined',
                    style: TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.success,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: 72,
              height: 30,
              child: FilledButton(
                onPressed: isJoining ? null : onJoin,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: isJoining
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Join'),
              ),
            ),
        ],
      ),
    );
  }
}
