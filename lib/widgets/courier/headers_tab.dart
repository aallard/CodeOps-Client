/// Headers tab content for the Courier request builder.
///
/// Displays auto-generated headers (read-only, collapsible), user-defined
/// headers via [KeyValueEditor], and quick-add header presets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/courier_ui_providers.dart';
import '../../theme/colors.dart';
import 'key_value_editor.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeadersTab
// ─────────────────────────────────────────────────────────────────────────────

/// The Headers sub-tab in the request builder.
///
/// Shows auto-generated headers (Content-Type, Accept, etc.) in a collapsible
/// read-only section above user-editable headers. Includes preset buttons for
/// common header sets and key autocomplete.
class HeadersTab extends ConsumerStatefulWidget {
  /// Available variable names for `{{}}` autocomplete.
  final List<String> variableNames;

  /// Creates a [HeadersTab].
  const HeadersTab({super.key, this.variableNames = const []});

  @override
  ConsumerState<HeadersTab> createState() => _HeadersTabState();
}

class _HeadersTabState extends ConsumerState<HeadersTab> {
  bool _showAutoHeaders = true;

  /// Common HTTP header name suggestions.
  static const _keySuggestions = [
    'Content-Type',
    'Accept',
    'Authorization',
    'Cache-Control',
    'Content-Length',
    'Host',
    'User-Agent',
    'Cookie',
    'Accept-Encoding',
    'Accept-Language',
    'X-Request-ID',
    'X-Correlation-ID',
    'X-API-Key',
    'If-None-Match',
    'If-Modified-Since',
  ];

  /// Auto-generated headers that will be added to requests.
  static const _autoHeaders = <String, String>{
    'User-Agent': 'CodeOps-Courier/1.0',
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
  };

  /// Header presets for quick-add functionality.
  static const _presets = <_HeaderPreset>[
    _HeaderPreset(
      label: 'JSON',
      headers: [
        KeyValuePair(id: 'preset-ct-json', key: 'Content-Type', value: 'application/json'),
        KeyValuePair(id: 'preset-ac-json', key: 'Accept', value: 'application/json'),
      ],
    ),
    _HeaderPreset(
      label: 'Form',
      headers: [
        KeyValuePair(
          id: 'preset-ct-form',
          key: 'Content-Type',
          value: 'application/x-www-form-urlencoded',
        ),
      ],
    ),
    _HeaderPreset(
      label: 'XML',
      headers: [
        KeyValuePair(id: 'preset-ct-xml', key: 'Content-Type', value: 'application/xml'),
        KeyValuePair(id: 'preset-ac-xml', key: 'Accept', value: 'application/xml'),
      ],
    ),
  ];

  void _applyPreset(_HeaderPreset preset) {
    final current = List<KeyValuePair>.from(ref.read(requestHeadersProvider));
    // Remove existing headers that the preset will replace.
    final presetKeys = preset.headers.map((h) => h.key.toLowerCase()).toSet();
    current.removeWhere(
        (h) => presetKeys.contains(h.key.toLowerCase()) || h.isEmpty);
    // Add preset headers at the beginning.
    final updated = [...preset.headers, ...current];
    ref.read(requestHeadersProvider.notifier).state = updated;
  }

  @override
  Widget build(BuildContext context) {
    final headers = ref.watch(requestHeadersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Auto-generated headers section.
        _AutoHeadersSection(
          expanded: _showAutoHeaders,
          onToggle: () => setState(() => _showAutoHeaders = !_showAutoHeaders),
        ),
        const Divider(height: 1, thickness: 1, color: CodeOpsColors.border),
        // Toolbar: presets.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Text(
                'Presets:',
                style: TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              ..._presets.map((preset) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _PresetChip(
                      label: preset.label,
                      onTap: () => _applyPreset(preset),
                    ),
                  )),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: CodeOpsColors.border),
        // User-editable headers.
        Expanded(
          child: KeyValueEditor(
            key: const Key('headers_editor'),
            pairs: headers,
            onChanged: (updated) {
              ref.read(requestHeadersProvider.notifier).state = updated;
            },
            keyHint: 'Header name',
            valueHint: 'Header value',
            keySuggestions: _keySuggestions,
            variableNames: widget.variableNames,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AutoHeadersSection
// ─────────────────────────────────────────────────────────────────────────────

/// Collapsible section showing auto-generated headers.
class _AutoHeadersSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _AutoHeadersSection({
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const Key('auto_headers_toggle'),
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: CodeOpsColors.surfaceVariant.withAlpha(128),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 16,
                  color: CodeOpsColors.textTertiary,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Auto-generated Headers',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: CodeOpsColors.textTertiary.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_HeadersTabState._autoHeaders.length}',
                    style: const TextStyle(fontSize: 9, color: CodeOpsColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          ..._HeadersTabState._autoHeaders.entries.map(
            (entry) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: CodeOpsColors.surfaceVariant.withAlpha(64),
              child: Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PresetChip
// ─────────────────────────────────────────────────────────────────────────────

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('preset_$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: CodeOpsColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderPreset
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderPreset {
  final String label;
  final List<KeyValuePair> headers;

  const _HeaderPreset({required this.label, required this.headers});
}
