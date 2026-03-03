/// Params tab content for the Courier request builder.
///
/// Displays query parameters using [KeyValueEditor] with bidirectional
/// URL sync (params ↔ URL query string) and a path-variables section
/// for `:paramName` / `{paramName}` URL patterns.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/courier_ui_providers.dart';
import '../../theme/colors.dart';
import 'key_value_editor.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Utility
// ─────────────────────────────────────────────────────────────────────────────

/// Parses query parameters from a URL string into [KeyValuePair]s.
///
/// Called when loading a request to populate initial params from the URL.
List<KeyValuePair> parseQueryParams(String url) {
  try {
    final uri = Uri.parse(url);
    final pairs = <KeyValuePair>[];
    var counter = 0;
    uri.queryParameters.forEach((key, value) {
      pairs.add(KeyValuePair(
        id: 'url-param-${counter++}',
        key: key,
        value: value,
        enabled: true,
      ));
    });
    return pairs;
  } catch (_) {
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ParamsTab
// ─────────────────────────────────────────────────────────────────────────────

/// The Params sub-tab in the request builder.
///
/// Shows path variables (if URL contains `:name` or `{name}` patterns)
/// above query parameters. Changes sync bidirectionally with the URL bar.
class ParamsTab extends ConsumerStatefulWidget {
  /// Available variable names for `{{}}` autocomplete.
  final List<String> variableNames;

  /// Creates a [ParamsTab].
  const ParamsTab({super.key, this.variableNames = const []});

  @override
  ConsumerState<ParamsTab> createState() => _ParamsTabState();
}

class _ParamsTabState extends ConsumerState<ParamsTab> {
  Timer? _syncDebounce;
  bool _isSyncing = false;

  /// Common query parameter name suggestions.
  static const _keySuggestions = [
    'page',
    'size',
    'limit',
    'offset',
    'sort',
    'order',
    'query',
    'q',
    'search',
    'filter',
    'fields',
    'include',
    'exclude',
    'format',
    'callback',
    'api_key',
    'token',
    'locale',
    'lang',
    'version',
  ];

  @override
  void dispose() {
    _syncDebounce?.cancel();
    super.dispose();
  }

  // ── URL → Params sync ──────────────────────────────────────────────────

  /// Extracts path variable names from `:name` or `{name}` patterns in a URL.
  ///
  /// Operates on the raw URL string (not Uri.path) to avoid brace encoding.
  static List<String> _extractPathVariables(String url) {
    final vars = <String>[];
    final colonPattern = RegExp(r':(\w+)');
    final bracePattern = RegExp(r'\{(\w+)\}');

    // Strip query string and fragment to inspect only the path portion.
    final pathPart = url.split('?').first.split('#').first;

    for (final match in colonPattern.allMatches(pathPart)) {
      final name = match.group(1)!;
      if (!vars.contains(name)) vars.add(name);
    }
    for (final match in bracePattern.allMatches(pathPart)) {
      final name = match.group(1)!;
      if (!vars.contains(name)) vars.add(name);
    }
    return vars;
  }

  // ── Params → URL sync ──────────────────────────────────────────────────

  /// Rebuilds the URL query string from enabled params.
  void _syncParamsToUrl(List<KeyValuePair> pairs) {
    if (_isSyncing) return;
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 300), () {
      _isSyncing = true;
      try {
        final editState = ref.read(activeRequestStateProvider);
        final url = editState.url;
        if (url.isEmpty) {
          _isSyncing = false;
          return;
        }

        try {
          final uri = Uri.parse(url);
          final enabledParams = pairs.where((p) => p.enabled && p.key.isNotEmpty);
          final queryMap = <String, String>{};
          for (final p in enabledParams) {
            queryMap[p.key] = p.value;
          }
          final newUri = uri.replace(queryParameters: queryMap.isEmpty ? null : queryMap);
          ref.read(activeRequestStateProvider.notifier).setUrl(newUri.toString());
        } catch (_) {
          // ignore malformed URL
        }
      } finally {
        _isSyncing = false;
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(activeRequestStateProvider);
    final url = editState.url;
    final params = ref.watch(requestParamsProvider);
    final pathVarNames = _extractPathVariables(url);
    final pathVars = ref.watch(pathVariablesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Path variables section (only if URL contains path params).
        if (pathVarNames.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: CodeOpsColors.surfaceVariant.withAlpha(128),
            child: Row(
              children: [
                const Icon(Icons.link, size: 14, color: CodeOpsColors.textTertiary),
                const SizedBox(width: 6),
                const Text(
                  'Path Variables',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${pathVarNames.length})',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: pathVarNames.length * 40.0 + 24,
            child: ListView.builder(
              key: const Key('path_variables_list'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: pathVarNames.length,
              itemBuilder: (context, index) {
                final name = pathVarNames[index];
                final currentValue = pathVars[name] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          ':$name',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: CodeOpsColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          key: Key('path_var_$name'),
                          controller: TextEditingController(text: currentValue)
                            ..selection = TextSelection.collapsed(offset: currentValue.length),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: CodeOpsColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'value',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: CodeOpsColors.textTertiary,
                            ),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            filled: true,
                            fillColor: CodeOpsColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: CodeOpsColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: CodeOpsColors.border),
                            ),
                          ),
                          onChanged: (v) {
                            final current = Map<String, String>.from(
                                ref.read(pathVariablesProvider));
                            current[name] = v;
                            ref.read(pathVariablesProvider.notifier).state = current;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: CodeOpsColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: const [
                Icon(Icons.search, size: 14, color: CodeOpsColors.textTertiary),
                SizedBox(width: 6),
                Text(
                  'Query Parameters',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        // Query parameters editor.
        Expanded(
          child: KeyValueEditor(
            key: const Key('params_editor'),
            pairs: params,
            onChanged: (updated) {
              ref.read(requestParamsProvider.notifier).state = updated;
              _syncParamsToUrl(updated);
            },
            keyHint: 'Parameter name',
            valueHint: 'Parameter value',
            keySuggestions: _keySuggestions,
            variableNames: widget.variableNames,
          ),
        ),
      ],
    );
  }
}
