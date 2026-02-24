/// Command palette overlay for the Scribe editor.
///
/// Provides a Ctrl+Shift+P command palette that fuzzy-matches across
/// all registered commands in [ScribeShortcutRegistry], letting the
/// user search and execute any command by name.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../utils/fuzzy_matcher.dart';
import 'scribe_shortcut_registry.dart';

/// A floating overlay for fuzzy command palette search.
///
/// Shows a text field prefixed with ">" and a filtered list of
/// [ScribeCommand]s. The user can navigate with arrow keys and
/// select with Enter. Pressing Escape or clicking outside dismisses
/// the overlay.
class ScribeCommandPalette extends StatefulWidget {
  /// The commands to search through.
  final List<ScribeCommand> commands;

  /// Called when the user selects a command.
  final ValueChanged<ScribeCommand> onSelect;

  /// Called when the overlay should be dismissed.
  final VoidCallback onClose;

  /// Creates a [ScribeCommandPalette] overlay.
  const ScribeCommandPalette({
    super.key,
    required this.commands,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<ScribeCommandPalette> createState() => _ScribeCommandPaletteState();
}

class _ScribeCommandPaletteState extends State<ScribeCommandPalette> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<_ScoredCommand> _results = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Show all commands initially.
    _results = widget.commands
        .map((cmd) => _ScoredCommand(command: cmd, score: 1, matchedIndices: []))
        .toList();
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
      const Duration(milliseconds: 100),
      () => _updateResults(value),
    );
  }

  void _updateResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = widget.commands
            .map((cmd) =>
                _ScoredCommand(command: cmd, score: 1, matchedIndices: []))
            .toList();
        _selectedIndex = 0;
      });
      return;
    }

    final candidates = widget.commands.map((c) => c.label).toList();
    final matches = FuzzyMatcher.filter(
      query,
      candidates,
      maxResults: AppConstants.scribeCommandPaletteMaxResults,
    );

    final scored = <_ScoredCommand>[];
    for (final match in matches) {
      final cmd =
          widget.commands.firstWhere((c) => c.label == match.candidate);
      scored.add(_ScoredCommand(
        command: cmd,
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
        widget.onSelect(_results[_selectedIndex].command);
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
          width: AppConstants.scribeCommandPaletteWidth,
          constraints: BoxConstraints(
            maxHeight: AppConstants.scribeCommandPaletteHeight,
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
            hintText: 'Type a command...',
            hintStyle: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 8, right: 4),
              child: Text(
                '>',
                style: TextStyle(
                  color: CodeOpsColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 24),
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
          'No matching commands',
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
        return _CommandPaletteItem(
          command: scored.command,
          isSelected: isSelected,
          matchedIndices: scored.matchedIndices,
          onTap: () => widget.onSelect(scored.command),
        );
      },
    );
  }
}

/// A command paired with its fuzzy match score.
class _ScoredCommand {
  final ScribeCommand command;
  final int score;
  final List<int> matchedIndices;

  const _ScoredCommand({
    required this.command,
    required this.score,
    required this.matchedIndices,
  });
}

/// A single result row in the command palette list.
class _CommandPaletteItem extends StatelessWidget {
  final ScribeCommand command;
  final bool isSelected;
  final List<int> matchedIndices;
  final VoidCallback onTap;

  const _CommandPaletteItem({
    required this.command,
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
              _categoryIcon(command.category),
              size: 16,
              color: CodeOpsColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedLabel(),
                  if (command.description != null)
                    Text(
                      command.description!,
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (command.shortcut != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CodeOpsColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: CodeOpsColors.border,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  command.shortcutLabel,
                  style: const TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 10,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedLabel() {
    if (matchedIndices.isEmpty) {
      return Text(
        command.label,
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
    for (var i = 0; i < command.label.length; i++) {
      spans.add(TextSpan(
        text: command.label[i],
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

  IconData _categoryIcon(ScribeCommandCategory category) {
    return switch (category) {
      ScribeCommandCategory.file => Icons.insert_drive_file_outlined,
      ScribeCommandCategory.editor => Icons.edit_outlined,
      ScribeCommandCategory.view => Icons.visibility_outlined,
      ScribeCommandCategory.tabs => Icons.tab_outlined,
    };
  }
}
