// Global search dialog (Ctrl+K / Cmd+K command palette).
//
// A VS Code-style overlay that searches across all CodeOps modules
// with debounced input, grouped results, keyboard navigation,
// module filter chips, and recent search history.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/search/global_search_service.dart';
import '../../theme/colors.dart';

/// Shows the global search dialog as a modal overlay.
///
/// Call this from the NavigationShell's search button or Ctrl+K shortcut.
void showGlobalSearchDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const GlobalSearchDialog(),
  );
}

/// VS Code-style command palette for cross-module search.
class GlobalSearchDialog extends ConsumerStatefulWidget {
  /// Creates a [GlobalSearchDialog].
  const GlobalSearchDialog({super.key});

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  GlobalSearchResults _results = GlobalSearchResults.empty;
  bool _isLoading = false;
  int _selectedIndex = -1;
  Set<SearchModule> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = GlobalSearchResults.empty;
        _isLoading = false;
        _selectedIndex = -1;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _doSearch(query));
  }

  Future<void> _doSearch(String query) async {
    final service = ref.read(globalSearchServiceProvider);
    final results = await service.search(
      query,
      modules: _activeFilters.isEmpty ? null : _activeFilters,
    );
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
        _selectedIndex = results.totalCount > 0 ? 0 : -1;
      });
    }
  }

  List<SearchResult> get _flatResults => _results.allResults;

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    final results = _flatResults;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, results.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, results.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 && _selectedIndex < results.length) {
        _navigateToResult(results[_selectedIndex]);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      // Cycle through filter chips.
      _cycleFilter();
    }
  }

  void _cycleFilter() {
    final modules = SearchModule.values;
    if (_activeFilters.isEmpty) {
      setState(() => _activeFilters = {modules.first});
    } else {
      final currentIndex = modules.indexOf(_activeFilters.first);
      final nextIndex = (currentIndex + 1) % modules.length;
      if (nextIndex == 0) {
        setState(() => _activeFilters = {});
      } else {
        setState(() => _activeFilters = {modules[nextIndex]});
      }
    }
    if (_controller.text.trim().isNotEmpty) {
      _onQueryChanged(_controller.text);
    }
  }

  void _toggleFilter(SearchModule module) {
    setState(() {
      if (_activeFilters.contains(module)) {
        _activeFilters.remove(module);
      } else {
        _activeFilters.add(module);
      }
    });
    if (_controller.text.trim().isNotEmpty) {
      _onQueryChanged(_controller.text);
    }
  }

  void _navigateToResult(SearchResult result) {
    // Save to recent searches.
    ref.read(recentSearchesProvider.notifier).add(_controller.text);
    Navigator.of(context).pop();
    context.go(result.route);
  }

  void _onRecentTapped(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    _onQueryChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyEvent,
      child: Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        backgroundColor: CodeOpsColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CodeOpsColors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input.
              _buildSearchField(),
              const Divider(height: 1, color: CodeOpsColors.border),
              // Filter chips.
              _buildFilterChips(),
              const Divider(height: 1, color: CodeOpsColors.border),
              // Results or recent searches.
              Flexible(
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CodeOpsColors.primary,
                            ),
                          ),
                        ),
                      )
                    : _controller.text.trim().isEmpty
                        ? _buildRecentSearches(recentSearches)
                        : _buildResults(),
              ),
              // Keyboard hints.
              _buildKeyboardHints(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: CodeOpsColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onQueryChanged,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search across all modules...',
                hintStyle: TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: CodeOpsColors.textTertiary,
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: SearchModule.values.map((module) {
          final active = _activeFilters.contains(module);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                module.label,
                style: TextStyle(
                  color: active
                      ? CodeOpsColors.textPrimary
                      : CodeOpsColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              avatar: Icon(module.icon, size: 14,
                  color: active
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textTertiary),
              selected: active,
              onSelected: (_) => _toggleFilter(module),
              selectedColor: CodeOpsColors.primary.withValues(alpha: 0.2),
              backgroundColor: CodeOpsColors.surfaceVariant,
              side: BorderSide(
                color: active ? CodeOpsColors.primary : CodeOpsColors.border,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentSearches(List<String> recent) {
    if (recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Type to search across all modules',
            style: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: CodeOpsColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...recent.map((query) => _RecentSearchTile(
              query: query,
              onTap: () => _onRecentTapped(query),
              onRemove: () =>
                  ref.read(recentSearchesProvider.notifier).remove(query),
            )),
      ],
    );
  }

  Widget _buildResults() {
    if (_results.totalCount == 0) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No results found',
            style: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    var flatIndex = 0;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _results.grouped.entries.expand((entry) {
        final module = entry.key;
        final results = entry.value;
        return [
          // Module group header.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(module.icon, size: 14, color: CodeOpsColors.primary),
                const SizedBox(width: 6),
                Text(
                  module.label,
                  style: const TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${results.length}',
                  style: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Result items.
          ...results.map((result) {
            final thisIndex = flatIndex++;
            final isSelected = thisIndex == _selectedIndex;
            return _SearchResultTile(
              result: result,
              isSelected: isSelected,
              onTap: () => _navigateToResult(result),
            );
          }),
        ];
      }).toList(),
    );
  }

  Widget _buildKeyboardHints() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: const Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          _KeyHint(label: 'navigate', keys: '↑↓'),
          _KeyHint(label: 'open', keys: '↵'),
          _KeyHint(label: 'filter', keys: 'Tab'),
          _KeyHint(label: 'close', keys: 'Esc'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final bool isSelected;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isSelected
              ? CodeOpsColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(result.module.icon, size: 16,
                  color: isSelected
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        color: isSelected
                            ? CodeOpsColors.textPrimary
                            : CodeOpsColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.subtitle != null)
                      Text(
                        result.subtitle!,
                        style: const TextStyle(
                          color: CodeOpsColors.textTertiary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.arrow_forward_ios,
                    size: 12, color: CodeOpsColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchTile({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.history, size: 14,
                  color: CodeOpsColors.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  query,
                  style: const TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 12),
                color: CodeOpsColors.textTertiary,
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  final String label;
  final String keys;

  const _KeyHint({required this.label, required this.keys});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: CodeOpsColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: CodeOpsColors.border),
          ),
          child: Text(
            keys,
            style: const TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: CodeOpsColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
