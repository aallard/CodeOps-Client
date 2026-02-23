/// Quick-open overlay for the Scribe editor.
///
/// Provides a Ctrl+P quick-open experience that fuzzy-matches across
/// open tabs and recent files, letting the user jump to any file instantly.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../utils/fuzzy_matcher.dart';

/// An item that can appear in the quick-open results.
class QuickOpenItem {
  /// Display title (file name or tab title).
  final String title;

  /// Optional subtitle (directory path or "Open tab").
  final String? subtitle;

  /// Unique identifier (tab ID or file path).
  final String id;

  /// Whether this item represents a currently open tab.
  final bool isOpenTab;

  /// Creates a [QuickOpenItem].
  const QuickOpenItem({
    required this.title,
    this.subtitle,
    required this.id,
    this.isOpenTab = false,
  });
}

/// A floating overlay for fuzzy quick-open search.
///
/// Shows a text field with a filtered list of [QuickOpenItem]s. The user
/// can navigate with arrow keys and select with Enter. Pressing Escape
/// or clicking outside dismisses the overlay.
class ScribeQuickOpen extends StatefulWidget {
  /// The items to search through.
  final List<QuickOpenItem> items;

  /// Called when the user selects an item.
  final ValueChanged<QuickOpenItem> onSelect;

  /// Called when the overlay should be dismissed.
  final VoidCallback onClose;

  /// Creates a [ScribeQuickOpen] overlay.
  const ScribeQuickOpen({
    super.key,
    required this.items,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<ScribeQuickOpen> createState() => _ScribeQuickOpenState();
}

class _ScribeQuickOpenState extends State<ScribeQuickOpen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<_ScoredItem> _results = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _results = widget.items
        .map((item) => _ScoredItem(item: item, score: 1, matchedIndices: []))
        .toList();
    // Auto-focus the search field.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(
        milliseconds: AppConstants.scribeQuickOpenSearchDebounceMs,
      ),
      () => _updateResults(value),
    );
  }

  void _updateResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = widget.items
            .map((item) =>
                _ScoredItem(item: item, score: 1, matchedIndices: []))
            .toList();
        _selectedIndex = 0;
      });
      return;
    }

    final candidates = widget.items.map((item) => item.title).toList();
    final matches = FuzzyMatcher.filter(
      query,
      candidates,
      maxResults: AppConstants.scribeQuickOpenMaxResults,
    );

    // Map matches back to items.
    final scored = <_ScoredItem>[];
    for (final match in matches) {
      final item = widget.items.firstWhere((i) => i.title == match.candidate);
      scored.add(_ScoredItem(
        item: item,
        score: match.score,
        matchedIndices: match.matchedIndices,
      ));
    }

    setState(() {
      _results = scored;
      _selectedIndex = 0;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _results.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _results.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_results.isNotEmpty) {
        widget.onSelect(_results[_selectedIndex].item);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: AppConstants.scribeQuickOpenWidth,
          constraints: BoxConstraints(
            maxHeight: AppConstants.scribeQuickOpenHeight,
          ),
          decoration: BoxDecoration(
            color: CodeOpsColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CodeOpsColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchField(),
              const Divider(height: 1, color: CodeOpsColors.border),
              Flexible(child: _buildResultList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: const TextStyle(
            color: CodeOpsColors.textPrimary,
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            hintText: 'Type to search files...',
            hintStyle: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: CodeOpsColors.textTertiary,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildResultList() {
    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No matching files',
          style: TextStyle(
            color: CodeOpsColors.textTertiary,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final scored = _results[index];
        final isSelected = index == _selectedIndex;
        return _QuickOpenResultItem(
          item: scored.item,
          isSelected: isSelected,
          matchedIndices: scored.matchedIndices,
          onTap: () => widget.onSelect(scored.item),
        );
      },
    );
  }
}

/// A quick-open item paired with its fuzzy match score.
class _ScoredItem {
  final QuickOpenItem item;
  final int score;
  final List<int> matchedIndices;

  const _ScoredItem({
    required this.item,
    required this.score,
    required this.matchedIndices,
  });
}

/// A single result row in the quick-open list.
class _QuickOpenResultItem extends StatelessWidget {
  final QuickOpenItem item;
  final bool isSelected;
  final List<int> matchedIndices;
  final VoidCallback onTap;

  const _QuickOpenResultItem({
    required this.item,
    required this.isSelected,
    required this.matchedIndices,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              item.isOpenTab ? Icons.tab : Icons.description_outlined,
              size: 16,
              color: item.isOpenTab
                  ? CodeOpsColors.primary
                  : CodeOpsColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedTitle(),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (item.isOpenTab)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CodeOpsColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                    color: CodeOpsColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle() {
    if (matchedIndices.isEmpty) {
      return Text(
        item.title,
        style: const TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    final matchSet = matchedIndices.toSet();
    for (var i = 0; i < item.title.length; i++) {
      spans.add(TextSpan(
        text: item.title[i],
        style: TextStyle(
          color: matchSet.contains(i)
              ? CodeOpsColors.secondary
              : CodeOpsColors.textPrimary,
          fontWeight:
              matchSet.contains(i) ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
      ));
    }
    return RichText(
      text: TextSpan(children: spans),
      overflow: TextOverflow.ellipsis,
    );
  }
}
