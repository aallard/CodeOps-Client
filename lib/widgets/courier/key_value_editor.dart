/// Reusable key-value pair editor for the Courier module.
///
/// Used by the Params, Headers, and Form-Data tabs to manage lists of
/// key-value pairs with enable/disable, description, variable highlighting,
/// bulk editing, drag-reorder, and auto-add empty row behavior.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KeyValuePair
// ─────────────────────────────────────────────────────────────────────────────

/// A single key-value entry with optional description and enable/disable state.
class KeyValuePair {
  /// Client-generated unique identifier.
  final String id;

  /// The key (e.g. header name, param name).
  final String key;

  /// The value (may contain `{{variable}}` tokens).
  final String value;

  /// Optional human-readable description.
  final String description;

  /// Whether this pair is included in the request.
  final bool enabled;

  /// Creates a [KeyValuePair].
  const KeyValuePair({
    required this.id,
    this.key = '',
    this.value = '',
    this.description = '',
    this.enabled = true,
  });

  /// Returns a copy with optionally updated fields.
  KeyValuePair copyWith({
    String? id,
    String? key,
    String? value,
    String? description,
    bool? enabled,
  }) {
    return KeyValuePair(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Whether this row is empty (no key or value entered).
  bool get isEmpty => key.isEmpty && value.isEmpty && description.isEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// KeyValueEditor
// ─────────────────────────────────────────────────────────────────────────────

/// A table-style editor for lists of [KeyValuePair]s.
///
/// Features: enable/disable checkboxes, auto-add empty row, variable
/// highlighting, bulk edit toggle, drag reorder, select-all via header
/// checkbox, and delete per row.
class KeyValueEditor extends StatefulWidget {
  /// Current list of key-value pairs.
  final List<KeyValuePair> pairs;

  /// Called whenever the list changes.
  final ValueChanged<List<KeyValuePair>> onChanged;

  /// Whether to show the description column.
  final bool showDescription;

  /// Hint text for the key field.
  final String keyHint;

  /// Hint text for the value field.
  final String valueHint;

  /// Autocomplete suggestions for key names.
  final List<String> keySuggestions;

  /// Available variable names for `{{}}` autocomplete in value fields.
  final List<String> variableNames;

  /// Creates a [KeyValueEditor].
  const KeyValueEditor({
    super.key,
    required this.pairs,
    required this.onChanged,
    this.showDescription = true,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
    this.keySuggestions = const [],
    this.variableNames = const [],
  });

  @override
  State<KeyValueEditor> createState() => _KeyValueEditorState();
}

class _KeyValueEditorState extends State<KeyValueEditor> {
  bool _bulkEditMode = false;
  late TextEditingController _bulkController;

  @override
  void initState() {
    super.initState();
    _bulkController = TextEditingController();
  }

  @override
  void dispose() {
    _bulkController.dispose();
    super.dispose();
  }

  // Ensure there's always a trailing empty row.
  List<KeyValuePair> _ensureTrailingEmpty(List<KeyValuePair> pairs) {
    if (pairs.isEmpty || !pairs.last.isEmpty) {
      return [...pairs, KeyValuePair(id: _newId())];
    }
    return pairs;
  }

  String _newId() => 'kv-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';

  void _emitChange(List<KeyValuePair> updated) {
    widget.onChanged(_ensureTrailingEmpty(updated));
  }

  void _updatePair(int index, KeyValuePair updated) {
    final list = List<KeyValuePair>.from(widget.pairs);
    list[index] = updated;
    _emitChange(list);
  }

  void _deletePair(int index) {
    final list = List<KeyValuePair>.from(widget.pairs);
    list.removeAt(index);
    _emitChange(list);
  }

  void _toggleAll(bool? value) {
    final enabled = value ?? true;
    final list = widget.pairs.map((p) => p.isEmpty ? p : p.copyWith(enabled: enabled)).toList();
    _emitChange(list);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final list = List<KeyValuePair>.from(widget.pairs);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _emitChange(list);
  }

  // ── Bulk Edit ────────────────────────────────────────────────────────────

  void _enterBulkEdit() {
    final lines = widget.pairs
        .where((p) => !p.isEmpty)
        .map((p) => '${p.key}:${p.value}')
        .join('\n');
    _bulkController.text = lines;
    setState(() => _bulkEditMode = true);
  }

  void _exitBulkEdit() {
    final text = _bulkController.text;
    final pairs = _parseBulkText(text);
    setState(() => _bulkEditMode = false);
    _emitChange(pairs);
  }

  List<KeyValuePair> _parseBulkText(String text) {
    final pairs = <KeyValuePair>[];
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final sep = trimmed.contains(':') ? ':' : '=';
      final idx = trimmed.indexOf(sep);
      if (idx == -1) {
        pairs.add(KeyValuePair(id: _newId(), key: trimmed));
      } else {
        pairs.add(KeyValuePair(
          id: _newId(),
          key: trimmed.substring(0, idx).trim(),
          value: trimmed.substring(idx + 1).trim(),
        ));
      }
    }
    return pairs;
  }

  // ── Paste handler ────────────────────────────────────────────────────────

  void _handlePaste(String pastedText, int index) {
    final lines = pastedText.split('\n');
    if (lines.length <= 1) return; // single-line paste handled by TextField

    final newPairs = _parseBulkText(pastedText);
    if (newPairs.isEmpty) return;

    final list = List<KeyValuePair>.from(widget.pairs);
    // Replace the current row and insert the rest after it.
    if (index < list.length) {
      list[index] = newPairs.first;
      list.insertAll(index + 1, newPairs.skip(1));
    } else {
      list.addAll(newPairs);
    }
    _emitChange(list);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_bulkEditMode) {
      return _buildBulkEditor();
    }
    return _buildTableEditor();
  }

  Widget _buildBulkEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('bulk_edit_done_button'),
                onPressed: _exitBulkEdit,
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 12, color: CodeOpsColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              key: const Key('bulk_edit_field'),
              controller: _bulkController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: CodeOpsColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'key:value (one per line)',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textTertiary,
                ),
                filled: true,
                fillColor: CodeOpsColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableEditor() {
    final pairs = _ensureTrailingEmpty(widget.pairs);
    final allNonEmpty = pairs.where((p) => !p.isEmpty).toList();
    final allEnabled = allNonEmpty.isNotEmpty && allNonEmpty.every((p) => p.enabled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row.
        _HeaderRow(
          allEnabled: allEnabled,
          onToggleAll: _toggleAll,
          showDescription: widget.showDescription,
        ),
        const Divider(height: 1, thickness: 1, color: CodeOpsColors.border),
        // Data rows.
        Expanded(
          child: ReorderableListView.builder(
            key: const Key('kv_reorderable_list'),
            buildDefaultDragHandles: false,
            itemCount: pairs.length,
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final pair = pairs[index];
              final isLast = pair.isEmpty && index == pairs.length - 1;
              return _PairRow(
                key: ValueKey(pair.id),
                index: index,
                pair: pair,
                isLastEmpty: isLast,
                showDescription: widget.showDescription,
                keyHint: widget.keyHint,
                valueHint: widget.valueHint,
                keySuggestions: widget.keySuggestions,
                variableNames: widget.variableNames,
                onChanged: (updated) => _updatePair(index, updated),
                onDelete: () => _deletePair(index),
                onPaste: (text) => _handlePaste(text, index),
              );
            },
          ),
        ),
        // Footer toolbar.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('bulk_edit_button'),
                onPressed: _enterBulkEdit,
                child: const Text(
                  'Bulk Edit',
                  style: TextStyle(fontSize: 11, color: CodeOpsColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderRow
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final bool allEnabled;
  final ValueChanged<bool?> onToggleAll;
  final bool showDescription;

  const _HeaderRow({
    required this.allEnabled,
    required this.onToggleAll,
    required this.showDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          // Drag handle placeholder width.
          const SizedBox(width: 28),
          // Select-all checkbox.
          SizedBox(
            width: 32,
            child: Checkbox(
              key: const Key('select_all_checkbox'),
              value: allEnabled,
              onChanged: onToggleAll,
              visualDensity: VisualDensity.compact,
              side: const BorderSide(color: CodeOpsColors.textTertiary),
              activeColor: CodeOpsColors.primary,
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Key',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Value',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ),
          if (showDescription)
            const Expanded(
              flex: 3,
              child: Text(
                'Description',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ),
          // Delete button placeholder width.
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PairRow
// ─────────────────────────────────────────────────────────────────────────────

class _PairRow extends StatelessWidget {
  final int index;
  final KeyValuePair pair;
  final bool isLastEmpty;
  final bool showDescription;
  final String keyHint;
  final String valueHint;
  final List<String> keySuggestions;
  final List<String> variableNames;
  final ValueChanged<KeyValuePair> onChanged;
  final VoidCallback onDelete;
  final ValueChanged<String> onPaste;

  const _PairRow({
    super.key,
    required this.index,
    required this.pair,
    required this.isLastEmpty,
    required this.showDescription,
    required this.keyHint,
    required this.valueHint,
    required this.keySuggestions,
    required this.variableNames,
    required this.onChanged,
    required this.onDelete,
    required this.onPaste,
  });

  TextStyle _fieldStyle() {
    return TextStyle(
      fontSize: 12,
      fontFamily: 'monospace',
      color: pair.enabled ? CodeOpsColors.textPrimary : CodeOpsColors.textTertiary,
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: CodeOpsColors.textTertiary,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      filled: true,
      fillColor: Colors.transparent,
      border: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CodeOpsColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          // Drag handle.
          ReorderableDragStartListener(
            index: index,
            child: const SizedBox(
              width: 28,
              child: Icon(Icons.drag_indicator, size: 16, color: CodeOpsColors.textTertiary),
            ),
          ),
          // Enable/disable checkbox.
          SizedBox(
            width: 32,
            child: Checkbox(
              key: Key('enable_checkbox_$index'),
              value: pair.enabled,
              onChanged: isLastEmpty ? null : (v) => onChanged(pair.copyWith(enabled: v ?? true)),
              visualDensity: VisualDensity.compact,
              side: const BorderSide(color: CodeOpsColors.textTertiary),
              activeColor: CodeOpsColors.primary,
            ),
          ),
          // Key field.
          Expanded(
            flex: 3,
            child: _KeyField(
              keyValue: pair.key,
              hint: keyHint,
              style: _fieldStyle(),
              decoration: _fieldDecoration(keyHint),
              suggestions: keySuggestions,
              onChanged: (v) => onChanged(pair.copyWith(key: v)),
            ),
          ),
          // Value field (with variable highlighting).
          Expanded(
            flex: 3,
            child: _ValueField(
              value: pair.value,
              hint: valueHint,
              style: _fieldStyle(),
              decoration: _fieldDecoration(valueHint),
              variableNames: variableNames,
              onChanged: (v) => onChanged(pair.copyWith(value: v)),
              onPaste: onPaste,
            ),
          ),
          // Description field.
          if (showDescription)
            Expanded(
              flex: 3,
              child: TextField(
                key: Key('description_field_$index'),
                controller: TextEditingController(text: pair.description)
                  ..selection = TextSelection.collapsed(offset: pair.description.length),
                style: TextStyle(
                  fontSize: 12,
                  color: pair.enabled ? CodeOpsColors.textSecondary : CodeOpsColors.textTertiary,
                ),
                decoration: _fieldDecoration('Description'),
                onChanged: (v) => onChanged(pair.copyWith(description: v)),
              ),
            ),
          // Delete button.
          SizedBox(
            width: 36,
            child: isLastEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    key: Key('delete_button_$index'),
                    icon: const Icon(Icons.close, size: 14, color: CodeOpsColors.textTertiary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                    splashRadius: 14,
                    onPressed: onDelete,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KeyField — Key column with autocomplete
// ─────────────────────────────────────────────────────────────────────────────

class _KeyField extends StatelessWidget {
  final String keyValue;
  final String hint;
  final TextStyle style;
  final InputDecoration decoration;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;

  const _KeyField({
    required this.keyValue,
    required this.hint,
    required this.style,
    required this.decoration,
    required this.suggestions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return TextField(
        controller: TextEditingController(text: keyValue)
          ..selection = TextSelection.collapsed(offset: keyValue.length),
        style: style,
        decoration: decoration,
        onChanged: onChanged,
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: keyValue),
      optionsBuilder: (textEditingValue) {
        final text = textEditingValue.text.toLowerCase();
        if (text.isEmpty) return const Iterable<String>.empty();
        return suggestions.where((s) => s.toLowerCase().contains(text));
      },
      onSelected: onChanged,
      fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
        // Sync external changes.
        if (controller.text != keyValue) {
          controller.text = keyValue;
          controller.selection = TextSelection.collapsed(offset: keyValue.length);
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: style,
          decoration: decoration,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: CodeOpsColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 240),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (ctx, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ValueField — Value column with variable highlighting
// ─────────────────────────────────────────────────────────────────────────────

/// Variable token pattern used for highlighting.
final _variablePattern = RegExp(r'\{\{([^}]+)\}\}');

class _ValueField extends StatelessWidget {
  final String value;
  final String hint;
  final TextStyle style;
  final InputDecoration decoration;
  final List<String> variableNames;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onPaste;

  const _ValueField({
    required this.value,
    required this.hint,
    required this.style,
    required this.decoration,
    required this.variableNames,
    required this.onChanged,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    if (variableNames.isEmpty) {
      return TextField(
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        style: style,
        decoration: decoration,
        onChanged: onChanged,
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value),
      optionsBuilder: (textEditingValue) {
        final text = textEditingValue.text;
        final cursor = textEditingValue.selection.baseOffset;
        // Check if cursor is right after `{{` without a closing `}}`.
        final beforeCursor = text.substring(0, cursor.clamp(0, text.length));
        final lastOpen = beforeCursor.lastIndexOf('{{');
        if (lastOpen == -1) return const Iterable<String>.empty();
        final afterOpen = beforeCursor.substring(lastOpen + 2);
        if (afterOpen.contains('}}')) return const Iterable<String>.empty();
        final partial = afterOpen.toLowerCase();
        return variableNames
            .where((v) => v.toLowerCase().contains(partial))
            .map((v) => '{{$v}}');
      },
      onSelected: (selected) {
        // Replace the partial `{{...` with the selected variable.
        onChanged(selected);
      },
      fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: style,
          decoration: decoration.copyWith(
            // Show variable-highlighted text as prefix when value has variables.
            prefix: _variablePattern.hasMatch(value)
                ? null
                : null,
          ),
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: CodeOpsColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 240),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (ctx, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CodeOpsColors.warning,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VariableHighlightText — Rich text with {{variable}} highlighting
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a [TextSpan] that highlights `{{variable}}` tokens in amber/orange.
TextSpan buildVariableHighlightSpan(String text, {TextStyle? baseStyle}) {
  final spans = <InlineSpan>[];
  int lastEnd = 0;

  for (final match in _variablePattern.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: baseStyle,
      ));
    }
    spans.add(TextSpan(
      text: match.group(0),
      style: (baseStyle ?? const TextStyle()).copyWith(
        color: const Color(0xFFFBBF24),
        backgroundColor: const Color(0x33FBBF24),
      ),
    ));
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: baseStyle,
    ));
  }

  return TextSpan(children: spans);
}
