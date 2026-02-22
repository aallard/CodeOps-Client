/// Collapsible JSON editor for environment and metadata configuration.
///
/// Uses a multiline [TextField] for editing JSON strings. Validates JSON
/// format on blur. Collapsed by default with an expand/collapse toggle.
library;

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Collapsible JSON editor for environments or metadata configuration.
///
/// Collapsed by default, showing just a label and expand button.
/// When expanded, displays a multiline text field for JSON editing.
/// Validates JSON on blur and shows an error message if invalid.
class EnvConfigEditor extends StatefulWidget {
  /// Section label (e.g., "Environments JSON" or "Metadata JSON").
  final String label;

  /// Initial JSON string value.
  final String? initialValue;

  /// Callback invoked when the JSON value changes.
  final ValueChanged<String?> onChanged;

  /// Placeholder hint text shown when the editor is empty.
  final String? placeholder;

  /// Creates an [EnvConfigEditor].
  const EnvConfigEditor({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.placeholder,
  });

  @override
  State<EnvConfigEditor> createState() => _EnvConfigEditorState();
}

class _EnvConfigEditorState extends State<EnvConfigEditor> {
  late final TextEditingController _controller;
  bool _expanded = false;
  String? _jsonError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateJson() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _jsonError = null);
      widget.onChanged(null);
      return;
    }

    try {
      json.decode(text);
      setState(() => _jsonError = null);
      widget.onChanged(text);
    } on FormatException catch (e) {
      setState(() => _jsonError = 'Invalid JSON: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _jsonError != null ? CodeOpsColors.error : CodeOpsColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand toggle
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: CodeOpsColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: CodeOpsColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_controller.text.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _jsonError != null
                            ? CodeOpsColors.error.withValues(alpha: 0.15)
                            : CodeOpsColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _jsonError != null ? 'Invalid' : 'Valid',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _jsonError != null
                              ? CodeOpsColors.error
                              : CodeOpsColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Expanded editor
          if (_expanded) ...[
            const Divider(height: 1, color: CodeOpsColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                minLines: 4,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: CodeOpsColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder ??
                      '{\n  "key": "value"\n}',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: CodeOpsColors.textTertiary,
                  ),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  // Live-validate as user types
                  _validateJson();
                },
              ),
            ),
            if (_jsonError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  _jsonError!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: CodeOpsColors.error,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
