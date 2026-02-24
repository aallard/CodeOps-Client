/// Find and Replace panel for the Scribe editor.
///
/// Appears below the tab bar when Ctrl+F (find) or Ctrl+H (find and
/// replace) is triggered. Provides search with match count, next/prev
/// navigation, and toggles for case sensitivity, whole word, and regex.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// Callback signature for find operations.
///
/// Receives the [query], whether [caseSensitive], [wholeWord], and
/// [regex] toggles are active.
typedef FindCallback = void Function({
  required String query,
  required bool caseSensitive,
  required bool wholeWord,
  required bool regex,
});

/// A compact find (and optionally replace) panel for the Scribe editor.
///
/// Supports:
/// - Text search with match count display
/// - Next/Previous match navigation
/// - Case-sensitive, whole-word, and regex toggle buttons
/// - Replace single and replace all (when replace row is visible)
/// - Escape key or close button to dismiss
class ScribeFindPanel extends StatefulWidget {
  /// Whether the replace row is visible.
  final bool showReplace;

  /// Current match count, or `null` if not yet computed.
  final int? matchCount;

  /// Index of the currently highlighted match (0-based).
  final int currentMatch;

  /// Called when the search query or toggle state changes.
  final FindCallback? onFind;

  /// Called when the user clicks "Next" or presses Enter.
  final VoidCallback? onFindNext;

  /// Called when the user clicks "Previous" or presses Shift+Enter.
  final VoidCallback? onFindPrev;

  /// Called when the user clicks "Replace" for the current match.
  final ValueChanged<String>? onReplace;

  /// Called when the user clicks "Replace All".
  final ValueChanged<String>? onReplaceAll;

  /// Called when the panel should be closed.
  final VoidCallback onClose;

  /// Called when the replace row visibility should be toggled.
  final VoidCallback? onToggleReplace;

  /// Creates a [ScribeFindPanel].
  const ScribeFindPanel({
    super.key,
    this.showReplace = false,
    this.matchCount,
    this.currentMatch = 0,
    this.onFind,
    this.onFindNext,
    this.onFindPrev,
    this.onReplace,
    this.onReplaceAll,
    required this.onClose,
    this.onToggleReplace,
  });

  @override
  State<ScribeFindPanel> createState() => _ScribeFindPanelState();
}

class _ScribeFindPanelState extends State<ScribeFindPanel> {
  final _findController = TextEditingController();
  final _replaceController = TextEditingController();
  final _findFocusNode = FocusNode();
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _regex = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    _findFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    widget.onFind?.call(
      query: _findController.text,
      caseSensitive: _caseSensitive,
      wholeWord: _wholeWord,
      regex: _regex,
    );
  }

  void _toggleCaseSensitive() {
    setState(() => _caseSensitive = !_caseSensitive);
    _onQueryChanged();
  }

  void _toggleWholeWord() {
    setState(() => _wholeWord = !_wholeWord);
    _onQueryChanged();
  }

  void _toggleRegex() {
    setState(() => _regex = !_regex);
    _onQueryChanged();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeight = widget.showReplace
        ? AppConstants.scribeFindReplacePanelHeight
        : AppConstants.scribeFindPanelHeight;

    return Container(
      height: panelHeight,
      color: CodeOpsColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildFindRow(),
          if (widget.showReplace) _buildReplaceRow(),
        ],
      ),
    );
  }

  /// Builds the find row with search field, toggles, and nav buttons.
  Widget _buildFindRow() {
    final matchText = widget.matchCount != null
        ? '${widget.matchCount == 0 ? 'No' : '${widget.currentMatch + 1} of ${widget.matchCount}'} results'
        : '';

    return SizedBox(
      height: AppConstants.scribeFindPanelHeight,
      child: Row(
        children: [
          // Expand/collapse replace toggle.
          SizedBox(
            width: 24,
            child: IconButton(
              icon: Icon(
                widget.showReplace
                    ? Icons.expand_less
                    : Icons.expand_more,
                size: 16,
                color: CodeOpsColors.textSecondary,
              ),
              onPressed: widget.onToggleReplace,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              tooltip: widget.showReplace ? 'Hide replace' : 'Show replace',
            ),
          ),
          const SizedBox(width: 4),
          // Search field.
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  widget.onClose();
                } else if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  if (HardwareKeyboard.instance.isShiftPressed) {
                    widget.onFindPrev?.call();
                  } else {
                    widget.onFindNext?.call();
                  }
                }
              },
              child: SizedBox(
                height: 28,
                child: TextField(
                  controller: _findController,
                  focusNode: _findFocusNode,
                  style: const TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 12,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Find',
                    hintStyle: TextStyle(
                      color: CodeOpsColors.textTertiary,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: CodeOpsColors.background,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: CodeOpsColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CodeOpsColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CodeOpsColors.primary),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  onChanged: (_) => _onQueryChanged(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Match count.
          if (matchText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                matchText,
                style: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ),
          // Toggle buttons.
          _ToggleButton(
            icon: 'Aa',
            isActive: _caseSensitive,
            tooltip: 'Match Case',
            onPressed: _toggleCaseSensitive,
          ),
          _ToggleButton(
            icon: 'W',
            isActive: _wholeWord,
            tooltip: 'Whole Word',
            onPressed: _toggleWholeWord,
          ),
          _ToggleButton(
            icon: '.*',
            isActive: _regex,
            tooltip: 'Regex',
            onPressed: _toggleRegex,
          ),
          const SizedBox(width: 4),
          // Previous / Next.
          _NavButton(
            icon: Icons.arrow_upward,
            tooltip: 'Previous Match',
            onPressed: widget.onFindPrev,
          ),
          _NavButton(
            icon: Icons.arrow_downward,
            tooltip: 'Next Match',
            onPressed: widget.onFindNext,
          ),
          const SizedBox(width: 4),
          // Close button.
          _NavButton(
            icon: Icons.close,
            tooltip: 'Close',
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  /// Builds the replace row with replace field and action buttons.
  Widget _buildReplaceRow() {
    return SizedBox(
      height: AppConstants.scribeFindPanelHeight,
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: SizedBox(
              height: 28,
              child: TextField(
                controller: _replaceController,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 12,
                ),
                decoration: const InputDecoration(
                  hintText: 'Replace',
                  hintStyle: TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: CodeOpsColors.background,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CodeOpsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CodeOpsColors.primary),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.find_replace,
            tooltip: 'Replace',
            onPressed: widget.onReplace != null
                ? () => widget.onReplace!(_replaceController.text)
                : null,
          ),
          _NavButton(
            icon: Icons.find_replace_outlined,
            tooltip: 'Replace All',
            onPressed: widget.onReplaceAll != null
                ? () => widget.onReplaceAll!(_replaceController.text)
                : null,
          ),
        ],
      ),
    );
  }
}

/// A small toggle button for case/word/regex toggles.
class _ToggleButton extends StatelessWidget {
  final String icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? CodeOpsColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            icon,
            style: TextStyle(
              color: isActive
                  ? CodeOpsColors.primary
                  : CodeOpsColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// A small icon button for navigation (prev, next, close).
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        icon: Icon(icon, size: 14),
        onPressed: onPressed,
        color: CodeOpsColors.textSecondary,
        disabledColor: CodeOpsColors.textTertiary,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
    );
  }
}
