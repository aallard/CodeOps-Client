/// JSON key-value editor for environment variable overrides.
///
/// Displays the JSON string as a read-only code block with
/// a copy button. Used in the workstation detail page to show
/// per-solution env var overrides.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Displays environment variable overrides as a formatted key-value list.
///
/// Parses [jsonString] as a JSON object and renders each key-value pair.
/// Falls back to raw text display if the JSON is invalid.
class EnvOverrideEditor extends StatelessWidget {
  /// The raw JSON string of environment variable overrides.
  final String jsonString;

  /// Creates an [EnvOverrideEditor].
  const EnvOverrideEditor({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? parsed;
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        parsed = decoded;
      }
    } catch (_) {
      // Fall through to raw display.
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Environment Overrides',
                style: TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 14),
                color: CodeOpsColors.textTertiary,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                tooltip: 'Copy JSON',
                constraints:
                    const BoxConstraints(minWidth: 24, minHeight: 24),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (parsed != null && parsed.isNotEmpty)
            ...parsed.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.key}: ',
                        style: CodeOpsTypography.code.copyWith(
                          fontSize: 12,
                          color: CodeOpsColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${e.value}',
                          style: CodeOpsTypography.code.copyWith(
                            fontSize: 12,
                            color: CodeOpsColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          else
            Text(
              jsonString,
              style: CodeOpsTypography.code.copyWith(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
