/// Tab comparison selector for the Scribe diff editor.
///
/// Provides two dropdowns for selecting which tabs to compare,
/// a compare button, and a swap button to exchange left/right.
library;

import 'package:flutter/material.dart';

import '../../models/scribe_models.dart';
import '../../theme/colors.dart';

/// A selector widget for choosing two tabs to compare in a diff view.
///
/// Displays two dropdowns for selecting the left (original) and right
/// (modified) tabs from the open tab list, a "Compare" button to
/// trigger the diff computation, and a swap button to exchange
/// the left and right selections.
class ScribeDiffSelector extends StatefulWidget {
  /// The list of open tabs available for comparison.
  final List<ScribeTab> tabs;

  /// The pre-selected left tab ID, if any.
  final String? initialLeftTabId;

  /// The pre-selected right tab ID, if any.
  final String? initialRightTabId;

  /// Callback when the user clicks "Compare".
  ///
  /// Receives the left and right tab IDs.
  final void Function(String leftTabId, String rightTabId) onCompare;

  /// Callback to close the selector.
  final VoidCallback onClose;

  /// Creates a [ScribeDiffSelector].
  const ScribeDiffSelector({
    super.key,
    required this.tabs,
    this.initialLeftTabId,
    this.initialRightTabId,
    required this.onCompare,
    required this.onClose,
  });

  @override
  State<ScribeDiffSelector> createState() => _ScribeDiffSelectorState();
}

class _ScribeDiffSelectorState extends State<ScribeDiffSelector> {
  String? _leftTabId;
  String? _rightTabId;

  @override
  void initState() {
    super.initState();
    _leftTabId = widget.initialLeftTabId;
    _rightTabId = widget.initialRightTabId;
  }

  @override
  Widget build(BuildContext context) {
    final canCompare =
        _leftTabId != null && _rightTabId != null && _leftTabId != _rightTabId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          // Left tab dropdown.
          Expanded(
            child: _TabDropdown(
              label: 'Original',
              tabs: widget.tabs,
              selectedTabId: _leftTabId,
              excludeTabId: _rightTabId,
              onChanged: (id) => setState(() => _leftTabId = id),
            ),
          ),

          const SizedBox(width: 8),

          // Swap button.
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 20),
            onPressed: _leftTabId != null || _rightTabId != null
                ? _handleSwap
                : null,
            tooltip: 'Swap left and right',
            color: CodeOpsColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          const SizedBox(width: 8),

          // Right tab dropdown.
          Expanded(
            child: _TabDropdown(
              label: 'Modified',
              tabs: widget.tabs,
              selectedTabId: _rightTabId,
              excludeTabId: _leftTabId,
              onChanged: (id) => setState(() => _rightTabId = id),
            ),
          ),

          const SizedBox(width: 12),

          // Compare button.
          ElevatedButton(
            onPressed: canCompare
                ? () => widget.onCompare(_leftTabId!, _rightTabId!)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: CodeOpsColors.textPrimary,
              disabledBackgroundColor:
                  CodeOpsColors.primary.withValues(alpha: 0.3),
              disabledForegroundColor: CodeOpsColors.textTertiary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Compare', style: TextStyle(fontSize: 13)),
          ),

          const SizedBox(width: 8),

          // Close button.
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onClose,
            tooltip: 'Close comparison',
            color: CodeOpsColors.textTertiary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  /// Swaps the left and right tab selections.
  void _handleSwap() {
    setState(() {
      final temp = _leftTabId;
      _leftTabId = _rightTabId;
      _rightTabId = temp;
    });
  }
}

/// A dropdown for selecting a tab.
class _TabDropdown extends StatelessWidget {
  final String label;
  final List<ScribeTab> tabs;
  final String? selectedTabId;
  final String? excludeTabId;
  final ValueChanged<String?> onChanged;

  const _TabDropdown({
    required this.label,
    required this.tabs,
    required this.selectedTabId,
    this.excludeTabId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: CodeOpsColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 32,
          child: DropdownButtonFormField<String>(
            initialValue: selectedTabId,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: CodeOpsColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: CodeOpsColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: CodeOpsColors.primary),
              ),
              filled: true,
              fillColor: CodeOpsColors.background,
            ),
            dropdownColor: CodeOpsColors.surface,
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textPrimary,
            ),
            hint: Text(
              'Select tab...',
              style: TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary.withValues(alpha: 0.7),
              ),
            ),
            items: tabs
                .where((t) => t.id != excludeTabId)
                .map((tab) => DropdownMenuItem<String>(
                      value: tab.id,
                      child: Text(
                        tab.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
