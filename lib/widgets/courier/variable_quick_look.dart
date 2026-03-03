/// Tooltip overlay for previewing resolved `{{variable}}` values.
///
/// When the user hovers over a `{{variableName}}` token in the URL bar,
/// headers, or body, this widget displays the resolved value, its source
/// (environment or global), and whether it is marked as secret.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Information about a resolved variable for display in the quick look.
class ResolvedVariable {
  /// The variable name (without `{{` / `}}`).
  final String name;

  /// The resolved value, or null if unresolved.
  final String? value;

  /// Source of the variable: `environment`, `global`, or `unresolved`.
  final String source;

  /// Whether the variable is marked as secret.
  final bool isSecret;

  /// Creates a [ResolvedVariable].
  const ResolvedVariable({
    required this.name,
    this.value,
    this.source = 'unresolved',
    this.isSecret = false,
  });
}

/// Popup overlay that shows the resolved value of a variable token.
///
/// Use [VariableQuickLook.show] to display the overlay programmatically,
/// or wrap a widget with [VariableQuickLook] to display on hover.
class VariableQuickLook extends StatelessWidget {
  /// The resolved variable to display.
  final ResolvedVariable variable;

  /// Creates a [VariableQuickLook].
  const VariableQuickLook({super.key, required this.variable});

  /// Shows the quick look overlay at the given [position].
  static OverlayEntry show({
    required BuildContext context,
    required Offset position,
    required ResolvedVariable variable,
  }) {
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx,
        top: position.dy + 20,
        child: Material(
          color: Colors.transparent,
          child: VariableQuickLook(variable: variable),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    final v = variable;
    final isResolved = v.value != null;
    final displayValue =
        v.isSecret ? '••••••••' : (v.value ?? 'Not found');

    return Container(
      key: const Key('variable_quick_look'),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variable name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CodeOpsColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  key: const Key('ql_variable_name'),
                  '{{${v.name}}}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Source badge
              Container(
                key: const Key('ql_source_badge'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _sourceColor(v.source).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  v.source,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _sourceColor(v.source),
                  ),
                ),
              ),
              if (v.isSecret) ...[
                const SizedBox(width: 8),
                const Icon(Icons.lock, size: 12, color: CodeOpsColors.warning),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Value
          Container(
            key: const Key('ql_value'),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CodeOpsColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isResolved
                    ? CodeOpsColors.textPrimary
                    : CodeOpsColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the badge color for a variable source.
  static Color _sourceColor(String source) {
    switch (source) {
      case 'environment':
        return CodeOpsColors.success;
      case 'global':
        return CodeOpsColors.secondary;
      default:
        return CodeOpsColors.error;
    }
  }
}
