// User Preferences page.
//
// Full-featured preferences editor with Appearance, Editor, Navigation,
// Notifications, Module Defaults, and Data & Privacy sections.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/preferences_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/search/global_search_service.dart';
import '../../theme/colors.dart';

/// Comprehensive user preferences page.
class PreferencesPage extends ConsumerStatefulWidget {
  /// Creates a [PreferencesPage].
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  static const _sections = [
    (icon: Icons.palette_outlined, label: 'Appearance'),
    (icon: Icons.code_outlined, label: 'Editor'),
    (icon: Icons.navigation_outlined, label: 'Navigation'),
    (icon: Icons.notifications_outlined, label: 'Notifications'),
    (icon: Icons.tune_outlined, label: 'Module Defaults'),
    (icon: Icons.shield_outlined, label: 'Data & Privacy'),
  ];

  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Section sidebar.
        Container(
          width: 200,
          color: CodeOpsColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final active = index == _selectedSection;
              return ListTile(
                dense: true,
                leading: Icon(
                  section.icon,
                  size: 18,
                  color: active
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textSecondary,
                ),
                title: Text(
                  section.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: active
                        ? CodeOpsColors.textPrimary
                        : CodeOpsColors.textSecondary,
                    fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                selected: active,
                selectedTileColor:
                    CodeOpsColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onTap: () => setState(() => _selectedSection = index),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Content panel.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildSection(_selectedSection),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(int index) {
    return switch (index) {
      0 => const _AppearanceSection(),
      1 => const _EditorSection(),
      2 => const _NavigationSection(),
      3 => const _NotificationsSection(),
      4 => const _ModuleDefaultsSection(),
      5 => const _DataPrivacySection(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appearance
// ─────────────────────────────────────────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themePreferenceProvider);
    final accent = ref.watch(accentColorProvider);
    final fontSize = ref.watch(fontSizePreferenceProvider);
    final sidebarPos = ref.watch(sidebarPositionProvider);
    final compact = ref.watch(compactModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        // Theme mode.
        const _SectionLabel('Theme'),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
          ],
          selected: {themeMode},
          onSelectionChanged: (s) =>
              ref.read(themePreferenceProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 24),
        // Accent color.
        const _SectionLabel('Accent Color'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accentColorPalette.map((color) {
            final selected = accent.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () =>
                  ref.read(accentColorProvider.notifier).state = color,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Font size.
        const _SectionLabel('Font Size'),
        SegmentedButton<FontSizePreference>(
          segments: const [
            ButtonSegment(
                value: FontSizePreference.small, label: Text('Small')),
            ButtonSegment(
                value: FontSizePreference.medium, label: Text('Medium')),
            ButtonSegment(
                value: FontSizePreference.large, label: Text('Large')),
          ],
          selected: {fontSize},
          onSelectionChanged: (s) =>
              ref.read(fontSizePreferenceProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 24),
        // Sidebar position.
        const _SectionLabel('Sidebar Position'),
        SegmentedButton<SidebarPosition>(
          segments: const [
            ButtonSegment(value: SidebarPosition.left, label: Text('Left')),
            ButtonSegment(
                value: SidebarPosition.right, label: Text('Right')),
          ],
          selected: {sidebarPos},
          onSelectionChanged: (s) =>
              ref.read(sidebarPositionProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 16),
        // Compact mode.
        SwitchListTile(
          title: const Text('Compact Mode',
              style: TextStyle(fontSize: 13)),
          subtitle: const Text('Reduces padding and margins',
              style:
                  TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary)),
          value: compact,
          onChanged: (v) =>
              ref.read(compactModeProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editor
// ─────────────────────────────────────────────────────────────────────────────

class _EditorSection extends ConsumerWidget {
  const _EditorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabSize = ref.watch(editorTabSizeProvider);
    final wordWrap = ref.watch(editorWordWrapProvider);
    final lineNumbers = ref.watch(editorLineNumbersProvider);
    final minimap = ref.watch(editorMinimapProvider);
    final autoSave = ref.watch(editorAutoSaveProvider);
    final defaultLang = ref.watch(editorDefaultLanguageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Editor (Scribe)', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        // Tab size.
        const _SectionLabel('Tab Size'),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 2, label: Text('2')),
            ButtonSegment(value: 4, label: Text('4')),
            ButtonSegment(value: 8, label: Text('8')),
          ],
          selected: {tabSize},
          onSelectionChanged: (s) =>
              ref.read(editorTabSizeProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 16),
        // Toggles.
        SwitchListTile(
          title: const Text('Word Wrap', style: TextStyle(fontSize: 13)),
          value: wordWrap,
          onChanged: (v) =>
              ref.read(editorWordWrapProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Line Numbers', style: TextStyle(fontSize: 13)),
          value: lineNumbers,
          onChanged: (v) =>
              ref.read(editorLineNumbersProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Minimap', style: TextStyle(fontSize: 13)),
          value: minimap,
          onChanged: (v) =>
              ref.read(editorMinimapProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        // Auto-save interval.
        const _SectionLabel('Auto-save Interval'),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Off')),
            ButtonSegment(value: 5, label: Text('5s')),
            ButtonSegment(value: 15, label: Text('15s')),
            ButtonSegment(value: 30, label: Text('30s')),
          ],
          selected: {autoSave},
          onSelectionChanged: (s) =>
              ref.read(editorAutoSaveProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 16),
        // Default language.
        const _SectionLabel('Default Language'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: defaultLang,
          isExpanded: true,
          dropdownColor: CodeOpsColors.surface,
          onChanged: (v) {
            if (v != null) {
              ref.read(editorDefaultLanguageProvider.notifier).state = v;
            }
          },
          items: const [
            DropdownMenuItem(value: 'plaintext', child: Text('Plain Text')),
            DropdownMenuItem(value: 'dart', child: Text('Dart')),
            DropdownMenuItem(value: 'java', child: Text('Java')),
            DropdownMenuItem(value: 'typescript', child: Text('TypeScript')),
            DropdownMenuItem(value: 'python', child: Text('Python')),
            DropdownMenuItem(value: 'json', child: Text('JSON')),
            DropdownMenuItem(value: 'yaml', child: Text('YAML')),
            DropdownMenuItem(value: 'markdown', child: Text('Markdown')),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────────────────────────────────────

class _NavigationSection extends ConsumerWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleOrder = ref.watch(sidebarOrderProvider);
    final landing = ref.watch(defaultLandingProvider);
    final newTab = ref.watch(openLinksInNewTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Navigation', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        // Default landing page.
        const _SectionLabel('Default Landing Page'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: landing,
          isExpanded: true,
          dropdownColor: CodeOpsColors.surface,
          onChanged: (v) {
            if (v != null) {
              ref.read(defaultLandingProvider.notifier).state = v;
            }
          },
          items: const [
            DropdownMenuItem(value: '/', child: Text('Home')),
            DropdownMenuItem(value: '/registry', child: Text('Registry')),
            DropdownMenuItem(value: '/vault', child: Text('Vault')),
            DropdownMenuItem(value: '/logger', child: Text('Logger')),
            DropdownMenuItem(value: '/courier', child: Text('Courier')),
            DropdownMenuItem(value: '/datalens', child: Text('DataLens')),
            DropdownMenuItem(value: '/relay', child: Text('Relay')),
            DropdownMenuItem(value: '/fleet', child: Text('Fleet')),
            DropdownMenuItem(value: '/mcp', child: Text('MCP')),
          ],
        ),
        const SizedBox(height: 16),
        // Link behavior.
        SwitchListTile(
          title: const Text('Open Links in New Tab',
              style: TextStyle(fontSize: 13)),
          value: newTab,
          onChanged: (v) =>
              ref.read(openLinksInNewTabProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        // Sidebar module order.
        const _SectionLabel('Sidebar Module Order'),
        const SizedBox(height: 4),
        const Text(
          'Drag to reorder modules in the sidebar.',
          style: TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: moduleOrder.length,
          onReorder: (oldIndex, newIndex) {
            final list = List<String>.from(moduleOrder);
            if (newIndex > oldIndex) newIndex--;
            final item = list.removeAt(oldIndex);
            list.insert(newIndex, item);
            ref.read(sidebarOrderProvider.notifier).state = list;
          },
          itemBuilder: (context, index) {
            final module = moduleOrder[index];
            return ListTile(
              key: ValueKey(module),
              dense: true,
              leading: const Icon(Icons.drag_handle,
                  size: 16, color: CodeOpsColors.textTertiary),
              title: Text(
                _moduleDisplayName(module),
                style: const TextStyle(fontSize: 13),
              ),
            );
          },
        ),
      ],
    );
  }

  static String _moduleDisplayName(String key) {
    return switch (key) {
      'vault' => 'Vault',
      'registry' => 'Registry',
      'fleet' => 'Fleet',
      'courier' => 'Courier',
      'datalens' => 'DataLens',
      'logger' => 'Logger',
      'relay' => 'Relay',
      'mcp' => 'MCP',
      _ => key,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktop = ref.watch(desktopNotificationsProvider);
    final sound = ref.watch(notificationSoundProvider);
    final dmLevel = ref.watch(dmNotificationLevelProvider);
    final quietEnabled = ref.watch(quietHoursEnabledProvider);
    final quietStart = ref.watch(quietHoursStartProvider);
    final quietEnd = ref.watch(quietHoursEndProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Desktop Notifications',
              style: TextStyle(fontSize: 13)),
          value: desktop,
          onChanged: (v) =>
              ref.read(desktopNotificationsProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Sound', style: TextStyle(fontSize: 13)),
          value: sound,
          onChanged: (v) =>
              ref.read(notificationSoundProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        // DM notification level.
        const _SectionLabel('DM Notifications'),
        SegmentedButton<DmNotificationLevel>(
          segments: const [
            ButtonSegment(
                value: DmNotificationLevel.always, label: Text('Always')),
            ButtonSegment(
                value: DmNotificationLevel.mentionsOnly,
                label: Text('Mentions')),
            ButtonSegment(
                value: DmNotificationLevel.off, label: Text('Off')),
          ],
          selected: {dmLevel},
          onSelectionChanged: (s) =>
              ref.read(dmNotificationLevelProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 24),
        // Quiet hours.
        SwitchListTile(
          title: const Text('Quiet Hours', style: TextStyle(fontSize: 13)),
          subtitle: const Text(
              'Suppress notifications during set hours',
              style: TextStyle(
                  fontSize: 11, color: CodeOpsColors.textTertiary)),
          value: quietEnabled,
          onChanged: (v) =>
              ref.read(quietHoursEnabledProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        if (quietEnabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Start:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: quietStart,
                dropdownColor: CodeOpsColors.surface,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(quietHoursStartProvider.notifier).state = v;
                  }
                },
                items: List.generate(
                    24,
                    (i) => DropdownMenuItem(
                        value: i,
                        child: Text('${i.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 12)))),
              ),
              const SizedBox(width: 24),
              const Text('End:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: quietEnd,
                dropdownColor: CodeOpsColors.surface,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(quietHoursEndProvider.notifier).state = v;
                  }
                },
                items: List.generate(
                    24,
                    (i) => DropdownMenuItem(
                        value: i,
                        child: Text('${i.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 12)))),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module Defaults
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleDefaultsSection extends ConsumerWidget {
  const _ModuleDefaultsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggerRange = ref.watch(loggerDefaultTimeRangeProvider);
    final loggerLevel = ref.watch(loggerDefaultLevelProvider);
    final courierEnv = ref.watch(courierDefaultEnvProvider);
    final fleetAutoStart = ref.watch(fleetAutoStartProvider);
    final datalensAuto = ref.watch(datalensAutoConnectProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Module Defaults',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        // Logger defaults.
        const _SectionLabel('Logger — Default Time Range'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '15m', label: Text('15m')),
            ButtonSegment(value: '1h', label: Text('1h')),
            ButtonSegment(value: '6h', label: Text('6h')),
            ButtonSegment(value: '24h', label: Text('24h')),
          ],
          selected: {loggerRange},
          onSelectionChanged: (s) =>
              ref.read(loggerDefaultTimeRangeProvider.notifier).state =
                  s.first,
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Logger — Default Level Filter'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'ALL', label: Text('ALL')),
            ButtonSegment(value: 'WARN+', label: Text('WARN+')),
            ButtonSegment(value: 'ERROR+', label: Text('ERROR+')),
          ],
          selected: {loggerLevel},
          onSelectionChanged: (s) =>
              ref.read(loggerDefaultLevelProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 16),
        // Courier default env.
        const _SectionLabel('Courier — Default Environment'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: courierEnv,
          isExpanded: true,
          dropdownColor: CodeOpsColors.surface,
          onChanged: (v) {
            if (v != null) {
              ref.read(courierDefaultEnvProvider.notifier).state = v;
            }
          },
          items: const [
            DropdownMenuItem(value: 'none', child: Text('None')),
            DropdownMenuItem(value: 'local', child: Text('Local')),
            DropdownMenuItem(value: 'dev', child: Text('Development')),
            DropdownMenuItem(value: 'staging', child: Text('Staging')),
            DropdownMenuItem(value: 'prod', child: Text('Production')),
          ],
        ),
        const SizedBox(height: 16),
        // Fleet.
        SwitchListTile(
          title: const Text('Auto-start default workstation on launch',
              style: TextStyle(fontSize: 13)),
          value: fleetAutoStart,
          onChanged: (v) =>
              ref.read(fleetAutoStartProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
        // DataLens.
        SwitchListTile(
          title: const Text('DataLens auto-connect on launch',
              style: TextStyle(fontSize: 13)),
          value: datalensAuto,
          onChanged: (v) =>
              ref.read(datalensAutoConnectProvider.notifier).state = v,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data & Privacy
// ─────────────────────────────────────────────────────────────────────────────

class _DataPrivacySection extends ConsumerWidget {
  const _DataPrivacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data & Privacy',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        // Clear caches.
        _ActionButton(
          label: 'Clear Local Cache',
          icon: Icons.delete_outline,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Local cache cleared')),
            );
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Clear Search History',
          icon: Icons.history,
          onPressed: () {
            ref.read(recentSearchesProvider.notifier).clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search history cleared')),
            );
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Clear DataLens Query History',
          icon: Icons.storage_outlined,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('DataLens query history cleared')),
            );
          },
        ),
        const SizedBox(height: 24),
        const Divider(color: CodeOpsColors.border),
        const SizedBox(height: 16),
        // Export / Import.
        _ActionButton(
          label: 'Export Preferences (JSON)',
          icon: Icons.download_outlined,
          onPressed: () async {
            final service = ref.read(preferencesServiceProvider);
            final prefs = await service.exportAll();
            final json =
                const JsonEncoder.withIndent('  ').convert(prefs);
            if (context.mounted) {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Exported Preferences'),
                  content: SelectableText(
                    json,
                    style: const TextStyle(
                        fontSize: 11, fontFamily: 'JetBrains Mono'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Import Preferences (JSON)',
          icon: Icons.upload_outlined,
          onPressed: () {
            _showImportDialog(context, ref);
          },
        ),
      ],
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Preferences'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste JSON here...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final prefs =
                    jsonDecode(controller.text) as Map<String, dynamic>;
                final service = ref.read(preferencesServiceProvider);
                await service.importAll(prefs);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Preferences imported')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Invalid JSON: $e')),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: CodeOpsColors.textPrimary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
