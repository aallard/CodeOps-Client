/// Chip-based tech stack selector with common presets and freeform input.
///
/// Allows selecting from common technology options organized by category
/// (Languages, Frameworks, Databases, Infrastructure) and/or typing custom
/// values. The result is stored as a comma-separated string matching the
/// techStack field.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Common technology presets organized by category.
const _presets = <String, List<String>>{
  'Languages': [
    'Java 21',
    'Dart',
    'Python 3',
    'TypeScript',
    'JavaScript',
    'Go',
    'Rust',
    'C#',
    'Kotlin',
    'Ruby',
    'PHP',
    'Swift',
    'Scala',
  ],
  'Frameworks': [
    'Spring Boot 3',
    'Flutter',
    'React',
    'Vue.js',
    'Next.js',
    'Express',
    'FastAPI',
    '.NET 8',
    'Django',
    'Rails',
  ],
  'Databases': [
    'PostgreSQL',
    'MySQL',
    'SQLite',
    'SQL Server',
    'Oracle',
    'MongoDB',
    'Redis',
    'DynamoDB',
  ],
  'Infrastructure': [
    'Docker',
    'Kubernetes',
    'AWS',
    'Kafka',
    'RabbitMQ',
    'Nginx',
    'Terraform',
  ],
};

/// Chip-based tech stack selector with presets and freeform input.
///
/// Displays selected items as removable chips. Provides a grouped dropdown
/// for preset values and a text field for custom entries. Outputs a
/// comma-separated string via [onChanged].
class TechStackSelector extends StatefulWidget {
  /// Initial comma-separated tech stack string.
  final String? initialValue;

  /// Callback invoked when the selected tech stack changes.
  final ValueChanged<String> onChanged;

  /// Creates a [TechStackSelector].
  const TechStackSelector({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<TechStackSelector> createState() => _TechStackSelectorState();
}

class _TechStackSelectorState extends State<TechStackSelector> {
  final _customController = TextEditingController();
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {};
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _selected.addAll(
        widget.initialValue!
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
      );
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(_selected.join(', '));
  }

  void _addItem(String item) {
    if (item.isEmpty || _selected.contains(item)) return;
    setState(() => _selected.add(item));
    _notifyChanged();
  }

  void _removeItem(String item) {
    setState(() => _selected.remove(item));
    _notifyChanged();
  }

  void _addCustom() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    _addItem(text);
    _customController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected chips
        if (_selected.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selected.map((item) {
              return Chip(
                label: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                deleteIconColor: CodeOpsColors.textTertiary,
                onDeleted: () => _removeItem(item),
                backgroundColor: CodeOpsColors.surfaceVariant,
                side: const BorderSide(color: CodeOpsColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Preset dropdown + custom input
        Row(
          children: [
            Expanded(
              child: _PresetDropdown(
                selected: _selected,
                onSelected: _addItem,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _customController,
                style: const TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add custom...',
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: _addCustom,
                    tooltip: 'Add custom entry',
                  ),
                ),
                onSubmitted: (_) => _addCustom(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Grouped dropdown showing preset technology options.
class _PresetDropdown extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  const _PresetDropdown({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      tooltip: 'Select preset',
      offset: const Offset(0, 40),
      color: CodeOpsColors.surface,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        for (final entry in _presets.entries) {
          // Category header
          items.add(PopupMenuItem<String>(
            enabled: false,
            height: 32,
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CodeOpsColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ));

          // Category items
          for (final preset in entry.value) {
            final isSelected = selected.contains(preset);
            items.add(PopupMenuItem<String>(
              value: isSelected ? null : preset,
              enabled: !isSelected,
              height: 36,
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check, size: 14, color: CodeOpsColors.primary)
                  else
                    const SizedBox(width: 14),
                  const SizedBox(width: 8),
                  Text(
                    preset,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? CodeOpsColors.textTertiary
                          : CodeOpsColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ));
          }

          // Divider between categories
          if (entry.key != _presets.keys.last) {
            items.add(const PopupMenuDivider(height: 8));
          }
        }

        return items;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: CodeOpsColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CodeOpsColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 16,
                color: CodeOpsColors.textSecondary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Add from presets',
                style: TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18,
                color: CodeOpsColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
