/// Slide-out settings panel for the Scribe editor.
///
/// Displays all 15 configurable settings organized into three sections:
/// Appearance, Editor, and Auto-Save. Changes are applied instantly and
/// persisted with a 500ms debounce via [ScribeSettingsNotifier].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/scribe_providers.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// Available monospace font families for the editor.
const List<String> scribeFontFamilies = [
  'JetBrains Mono',
  'Fira Code',
  'Source Code Pro',
  'Cascadia Code',
  'Menlo',
  'Consolas',
  'Monaco',
  'Courier New',
];

/// A slide-out settings panel for the Scribe editor.
///
/// Provides controls for all 15 editor settings grouped into Appearance,
/// Editor, and Auto-Save sections. Includes a Reset to Defaults button.
///
/// Use [ScribeSettingsPanel.width] for layout sizing.
class ScribeSettingsPanel extends ConsumerWidget {
  /// Fixed width of the settings panel.
  static const double width = AppConstants.scribeSettingsPanelWidth;

  /// Callback when the close button is pressed.
  final VoidCallback onClose;

  /// Creates a [ScribeSettingsPanel].
  const ScribeSettingsPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(scribeSettingsProvider);
    final notifier = ref.read(scribeSettingsProvider.notifier);

    return Container(
      width: width,
      color: CodeOpsColors.surface,
      child: Column(
        children: [
          _PanelHeader(onClose: onClose),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // --- Appearance Section ---
                const _SectionHeader('Appearance'),
                _ThemeModeRow(
                  themeMode: settings.themeMode,
                  onChanged: notifier.setThemeMode,
                ),
                _FontFamilyRow(
                  fontFamily: settings.fontFamily,
                  onChanged: notifier.updateFontFamily,
                ),
                _FontSizeRow(
                  fontSize: settings.fontSize,
                  onChanged: notifier.updateFontSize,
                ),
                const Divider(
                  height: 16,
                  indent: 16,
                  endIndent: 16,
                  color: CodeOpsColors.border,
                ),

                // --- Editor Section ---
                const _SectionHeader('Editor'),
                _TabSizeRow(
                  tabSize: settings.tabSize,
                  onChanged: notifier.updateTabSize,
                ),
                _ToggleRow(
                  label: 'Insert Spaces',
                  value: settings.insertSpaces,
                  onToggle: notifier.toggleInsertSpaces,
                ),
                _ToggleRow(
                  label: 'Word Wrap',
                  value: settings.wordWrap,
                  onToggle: notifier.toggleWordWrap,
                ),
                _ToggleRow(
                  label: 'Line Numbers',
                  value: settings.showLineNumbers,
                  onToggle: notifier.toggleLineNumbers,
                ),
                _ToggleRow(
                  label: 'Minimap',
                  value: settings.showMinimap,
                  onToggle: notifier.toggleMinimap,
                ),
                _ToggleRow(
                  label: 'Highlight Active Line',
                  value: settings.highlightActiveLine,
                  onToggle: notifier.toggleHighlightActiveLine,
                ),
                _ToggleRow(
                  label: 'Bracket Matching',
                  value: settings.bracketMatching,
                  onToggle: notifier.toggleBracketMatching,
                ),
                _ToggleRow(
                  label: 'Auto-Close Brackets',
                  value: settings.autoCloseBrackets,
                  onToggle: notifier.toggleAutoCloseBrackets,
                ),
                _ToggleRow(
                  label: 'Show Whitespace',
                  value: settings.showWhitespace,
                  onToggle: notifier.toggleShowWhitespace,
                ),
                _ToggleRow(
                  label: 'Scroll Beyond Last Line',
                  value: settings.scrollBeyondLastLine,
                  onToggle: notifier.toggleScrollBeyondLastLine,
                ),
                const Divider(
                  height: 16,
                  indent: 16,
                  endIndent: 16,
                  color: CodeOpsColors.border,
                ),

                // --- Auto-Save Section ---
                const _SectionHeader('Auto-Save'),
                _ToggleRow(
                  label: 'Auto-Save',
                  value: settings.autoSave,
                  onToggle: notifier.toggleAutoSave,
                ),
                if (settings.autoSave)
                  _AutoSaveIntervalRow(
                    seconds: settings.autoSaveIntervalSeconds,
                    onChanged: notifier.updateAutoSaveInterval,
                  ),
                const SizedBox(height: 16),

                // --- Reset ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: notifier.resetToDefaults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CodeOpsColors.textSecondary,
                      side: const BorderSide(color: CodeOpsColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reset to Defaults'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row with title and close button.
class _PanelHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _PanelHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.scribeTabBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(
            Icons.settings,
            size: 16,
            color: CodeOpsColors.textSecondary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Settings',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: CodeOpsColors.textTertiary,
            onPressed: onClose,
            splashRadius: 14,
            tooltip: 'Close settings',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }
}

/// A section title in the settings panel.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: CodeOpsColors.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A toggle row with label and switch.
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              height: 20,
              child: Switch(
                value: value,
                onChanged: (_) => onToggle(),
                activeThumbColor: CodeOpsColors.primary,
                activeTrackColor:
                    CodeOpsColors.primary.withValues(alpha: 0.4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Theme mode selector (Dark / Light).
class _ThemeModeRow extends StatelessWidget {
  final String themeMode;
  final ValueChanged<String> onChanged;

  const _ThemeModeRow({
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Theme',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          _SegmentedControl(
            options: const ['dark', 'light'],
            labels: const ['Dark', 'Light'],
            selected: themeMode,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A simple two-option segmented control.
class _SegmentedControl extends StatelessWidget {
  final List<String> options;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentedControl({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = options[i] == selected;
          return GestureDetector(
            onTap: () => onChanged(options[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? CodeOpsColors.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.horizontal(
                  left: i == 0 ? const Radius.circular(5) : Radius.zero,
                  right: i == options.length - 1
                      ? const Radius.circular(5)
                      : Radius.zero,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSelected
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Font family dropdown row.
class _FontFamilyRow extends StatelessWidget {
  final String fontFamily;
  final ValueChanged<String> onChanged;

  const _FontFamilyRow({
    required this.fontFamily,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Font Family',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onChanged,
            tooltip: 'Select font family',
            color: CodeOpsColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: CodeOpsColors.border),
            ),
            itemBuilder: (_) => scribeFontFamilies.map((font) {
              return PopupMenuItem<String>(
                value: font,
                height: 32,
                child: Text(
                  font,
                  style: TextStyle(
                    fontFamily: font,
                    fontSize: 12,
                    color: font == fontFamily
                        ? CodeOpsColors.primary
                        : CodeOpsColors.textPrimary,
                    fontWeight:
                        font == fontFamily ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: CodeOpsColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fontFamily,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 11,
                      color: CodeOpsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 14,
                    color: CodeOpsColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Font size slider row.
class _FontSizeRow extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onChanged;

  const _FontSizeRow({
    required this.fontSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          const Text(
            'Font Size',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: CodeOpsColors.primary,
                inactiveTrackColor: CodeOpsColors.border,
                thumbColor: CodeOpsColors.primary,
              ),
              child: Slider(
                value: fontSize,
                min: AppConstants.scribeMinFontSize,
                max: AppConstants.scribeMaxFontSize,
                divisions: (AppConstants.scribeMaxFontSize -
                        AppConstants.scribeMinFontSize)
                    .toInt(),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${fontSize.toInt()}',
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab size selector row.
class _TabSizeRow extends StatelessWidget {
  final int tabSize;
  final ValueChanged<int> onChanged;

  const _TabSizeRow({
    required this.tabSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Tab Size',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          _SegmentedControl(
            options: const ['2', '4', '8'],
            labels: const ['2', '4', '8'],
            selected: '$tabSize',
            onChanged: (val) => onChanged(int.parse(val)),
          ),
        ],
      ),
    );
  }
}

/// Auto-save interval selector row.
class _AutoSaveIntervalRow extends StatelessWidget {
  final int seconds;
  final ValueChanged<int> onChanged;

  const _AutoSaveIntervalRow({
    required this.seconds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          const Text(
            'Interval',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: CodeOpsColors.primary,
                inactiveTrackColor: CodeOpsColors.border,
                thumbColor: CodeOpsColors.primary,
              ),
              child: Slider(
                value: seconds.toDouble(),
                min: AppConstants.scribeMinAutoSaveIntervalSeconds.toDouble(),
                max: AppConstants.scribeMaxAutoSaveIntervalSeconds.toDouble(),
                divisions:
                    (AppConstants.scribeMaxAutoSaveIntervalSeconds -
                            AppConstants.scribeMinAutoSaveIntervalSeconds) ~/
                        5,
                onChanged: (val) => onChanged(val.toInt()),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${seconds}s',
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
