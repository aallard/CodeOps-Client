/// Keyboard shortcuts help overlay for the Scribe editor.
///
/// Displays all registered keyboard shortcuts grouped by category.
/// Triggered by Ctrl+Shift+? (or Cmd+Shift+? on macOS).
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';
import 'scribe_shortcut_registry.dart';

/// A modal overlay displaying all registered keyboard shortcuts.
///
/// Shows shortcuts grouped by [ScribeCommandCategory], with each entry
/// displaying the command label and its shortcut key binding.
class ScribeShortcutsHelp extends StatelessWidget {
  /// Called when the overlay should be closed.
  final VoidCallback onClose;

  /// Creates a [ScribeShortcutsHelp] overlay.
  const ScribeShortcutsHelp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final categories = ScribeShortcutRegistry.commandsByCategory;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: AppConstants.scribeShortcutsHelpWidth,
          constraints: BoxConstraints(
            maxHeight: AppConstants.scribeShortcutsHelpMaxHeight,
          ),
          decoration: BoxDecoration(
            color: CodeOpsColors.surface,
            borderRadius: BorderRadius.circular(12),
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
              _buildHeader(),
              const Divider(height: 1, color: CodeOpsColors.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in categories.entries) ...[
                        _buildCategorySection(entry.key, entry.value),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header row with title and close button.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.keyboard,
            size: 18,
            color: CodeOpsColors.primary,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Keyboard Shortcuts',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onClose,
              color: CodeOpsColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section for one [ScribeCommandCategory].
  Widget _buildCategorySection(
    ScribeCommandCategory category,
    List<ScribeCommand> commands,
  ) {
    // Only show commands that have shortcuts.
    final withShortcuts = commands.where((c) => c.shortcut != null).toList();
    if (withShortcuts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.displayName,
          style: const TextStyle(
            color: CodeOpsColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        for (final cmd in withShortcuts)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _ShortcutRow(command: cmd),
          ),
      ],
    );
  }
}

/// A single row showing a command label and its shortcut.
class _ShortcutRow extends StatelessWidget {
  final ScribeCommand command;

  const _ShortcutRow({required this.command});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            command.label,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: CodeOpsColors.background,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: CodeOpsColors.border, width: 0.5),
          ),
          child: Text(
            command.shortcutLabel,
            style: const TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ),
      ],
    );
  }
}
