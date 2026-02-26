/// Full-screen search dialog for the Relay module.
///
/// Allows searching messages within a single channel or across all
/// channels. Results show sender, channel name, content snippet,
/// and timestamp. Tapping a result navigates to that channel.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';

/// Dialog for searching messages within a channel or across all channels.
///
/// Features:
/// - Search input with 300ms debounce
/// - Toggle between "This channel" and "All channels" modes
/// - Paginated results with "Load more" button
/// - Click result to navigate to the channel
class RelaySearchDialog extends ConsumerStatefulWidget {
  /// Optional channel ID to enable "This channel" search mode.
  final String? channelId;

  /// Creates a [RelaySearchDialog].
  const RelaySearchDialog({this.channelId, super.key});

  @override
  ConsumerState<RelaySearchDialog> createState() => _RelaySearchDialogState();
}

class _RelaySearchDialogState extends ConsumerState<RelaySearchDialog> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _searchAllChannels = true;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = false;
  int _totalResults = 0;

  // Results
  List<ChannelSearchResultResponse> _globalResults = [];
  List<MessageResponse> _channelResults = [];

  String? get _teamId => ref.read(selectedTeamIdProvider);

  @override
  void initState() {
    super.initState();
    // Default to "This channel" if a channel is selected.
    if (widget.channelId != null) {
      _searchAllChannels = false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Handles search input with 300ms debounce.
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _currentPage = 0;
        _globalResults = [];
        _channelResults = [];
        _search();
      }
    });
  }

  /// Executes the search against the API.
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _globalResults = [];
        _channelResults = [];
        _totalResults = 0;
        _hasMore = false;
      });
      return;
    }

    final teamId = _teamId;
    if (teamId == null) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(relayApiProvider);

      if (_searchAllChannels) {
        final page = await api.searchMessagesAcrossChannels(
          query,
          teamId,
          page: _currentPage,
        );
        setState(() {
          if (_currentPage == 0) {
            _globalResults = page.content;
          } else {
            _globalResults = [..._globalResults, ...page.content];
          }
          _totalResults = page.totalElements;
          _hasMore = !page.isLast;
        });
      } else {
        final channelId = widget.channelId;
        if (channelId == null) return;

        final page = await api.searchMessages(
          channelId,
          query,
          teamId,
          page: _currentPage,
        );
        setState(() {
          if (_currentPage == 0) {
            _channelResults = page.content;
          } else {
            _channelResults = [..._channelResults, ...page.content];
          }
          _totalResults = page.totalElements;
          _hasMore = !page.isLast;
        });
      }
    } catch (_) {
      // Silently handle errors — results remain empty.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Loads the next page of results.
  void _loadMore() {
    _currentPage++;
    _search();
  }

  /// Navigates to a channel when a search result is tapped.
  void _navigateToResult(String? channelId) {
    if (channelId == null) return;
    ref.read(selectedChannelIdProvider.notifier).state = channelId;
    ref.read(selectedConversationIdProvider.notifier).state = null;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasChannelContext = widget.channelId != null;
    final resultCount = _searchAllChannels
        ? _globalResults.length
        : _channelResults.length;

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSearchInput(),
            if (hasChannelContext) _buildModeToggle(),
            const Divider(height: 1, color: CodeOpsColors.border),
            Flexible(child: _buildResults(resultCount)),
            if (_totalResults > 0)
              _buildFooter(resultCount),
          ],
        ),
      ),
    );
  }

  /// Builds the dialog header row.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: CodeOpsColors.textTertiary),
          const SizedBox(width: 8),
          const Text(
            'Search messages',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: CodeOpsColors.textTertiary,
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  /// Builds the search text input.
  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        style:
            const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle:
              const TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            borderSide: const BorderSide(color: CodeOpsColors.primary),
          ),
        ),
      ),
    );
  }

  /// Builds the "This channel" / "All channels" toggle.
  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _buildToggleChip('This channel', !_searchAllChannels, () {
            setState(() {
              _searchAllChannels = false;
              _currentPage = 0;
              _globalResults = [];
              _channelResults = [];
            });
            _search();
          }),
          const SizedBox(width: 8),
          _buildToggleChip('All channels', _searchAllChannels, () {
            setState(() {
              _searchAllChannels = true;
              _currentPage = 0;
              _globalResults = [];
              _channelResults = [];
            });
            _search();
          }),
        ],
      ),
    );
  }

  /// Builds a single toggle chip.
  Widget _buildToggleChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? CodeOpsColors.primary.withValues(alpha: 0.2)
              : CodeOpsColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: CodeOpsColors.primary, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? CodeOpsColors.primary
                : CodeOpsColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Builds the results list.
  Widget _buildResults(int resultCount) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Type to search messages',
            style: TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
          ),
        ),
      );
    }

    if (_isLoading && resultCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (resultCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No results found',
            style: TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: resultCount + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= resultCount) {
          return _buildLoadMoreButton();
        }

        if (_searchAllChannels) {
          return _buildGlobalResultTile(_globalResults[index]);
        }
        return _buildChannelResultTile(_channelResults[index]);
      },
    );
  }

  /// Builds a search result tile for cross-channel results.
  Widget _buildGlobalResultTile(ChannelSearchResultResponse result) {
    return InkWell(
      onTap: () => _navigateToResult(result.channelId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${result.channelName ?? "unknown"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  result.senderDisplayName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  formatTimeAgo(result.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              result.contentSnippet ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textPrimary,
              ),
            ),
            const Divider(height: 12, color: CodeOpsColors.border),
          ],
        ),
      ),
    );
  }

  /// Builds a search result tile for in-channel results.
  Widget _buildChannelResultTile(MessageResponse result) {
    return InkWell(
      onTap: () => _navigateToResult(result.channelId ?? widget.channelId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  result.senderDisplayName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  formatTimeAgo(result.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              result.content ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textPrimary,
              ),
            ),
            const Divider(height: 12, color: CodeOpsColors.border),
          ],
        ),
      ),
    );
  }

  /// Builds the "Load more" button.
  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: _loadMore,
                child: const Text(
                  'Load more',
                  style: TextStyle(fontSize: 12, color: CodeOpsColors.primary),
                ),
              ),
      ),
    );
  }

  /// Builds the footer showing result counts.
  Widget _buildFooter(int resultCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Text(
        'Showing $resultCount of $_totalResults results',
        style: const TextStyle(
          fontSize: 11,
          color: CodeOpsColors.textTertiary,
        ),
      ),
    );
  }
}
