/// Toolbar displayed above the Courier three-pane layout.
///
/// Contains the New dropdown, Import, Runner, Search field, and the
/// active-environment selector. All navigation is handled via GoRouter.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/courier_ui_providers.dart';
import '../../theme/colors.dart';

/// Top toolbar for the Courier module.
///
/// Provides quick-access buttons for creating, importing, running, and
/// searching. The environment selector on the right edge controls which
/// environment variables are active during request execution.
class CourierToolbar extends ConsumerWidget {
  /// Creates a [CourierToolbar].
  const CourierToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(bottom: BorderSide(color: CodeOpsColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // New dropdown
          _NewDropdownButton(context: context, ref: ref),
          const SizedBox(width: 8),
          // Import
          _ToolbarButton(
            key: const Key('import_button'),
            icon: Icons.upload_outlined,
            label: 'Import',
            onTap: () => context.go('/courier/import'),
          ),
          const SizedBox(width: 8),
          // Runner
          _ToolbarButton(
            key: const Key('runner_button'),
            icon: Icons.play_circle_outline,
            label: 'Runner',
            onTap: () => context.go('/courier/runner'),
          ),
          const SizedBox(width: 12),
          // Search field
          _SearchField(ref: ref),
          const Spacer(),
          // Environment selector
          _EnvironmentSelector(ref: ref),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _NewDropdownButton extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;

  const _NewDropdownButton({required this.context, required this.ref});

  @override
  Widget build(BuildContext buildContext) {
    return PopupMenuButton<String>(
      key: const Key('new_dropdown'),
      offset: const Offset(0, 40),
      color: CodeOpsColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      onSelected: (value) {
        switch (value) {
          case 'request':
            // CCF-003: open a new empty request tab
            break;
          case 'collection':
            // CCF-002: open create collection dialog
            break;
          case 'folder':
            // CCF-002: open create folder dialog
            break;
          case 'environment':
            context.go('/courier/environments');
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'request',
          child: _MenuRow(icon: Icons.http, label: 'New Request'),
        ),
        PopupMenuItem(
          value: 'collection',
          child: _MenuRow(icon: Icons.folder_outlined, label: 'New Collection'),
        ),
        PopupMenuItem(
          value: 'folder',
          child: _MenuRow(icon: Icons.create_new_folder_outlined, label: 'New Folder'),
        ),
        PopupMenuItem(
          value: 'environment',
          child: _MenuRow(
            icon: Icons.tune_outlined,
            label: 'New Environment',
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CodeOpsColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'New',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CodeOpsColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style:
              const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic toolbar button
// ─────────────────────────────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: CodeOpsColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: CodeOpsColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search field
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatefulWidget {
  final WidgetRef ref;

  const _SearchField({required this.ref});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextField(
        key: const Key('toolbar_search'),
        controller: _controller,
        onChanged: (value) {
          widget.ref.read(sidebarSearchQueryProvider.notifier).state = value;
        },
        style: const TextStyle(
          fontSize: 13,
          color: CodeOpsColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search…',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 15,
            color: CodeOpsColors.textTertiary,
          ),
          filled: true,
          fillColor: CodeOpsColors.background,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.primary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Environment selector
// ─────────────────────────────────────────────────────────────────────────────

class _EnvironmentSelector extends ConsumerWidget {
  final WidgetRef ref;

  const _EnvironmentSelector({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final activeId = watchRef.watch(activeEnvironmentIdProvider);
    final envsAsync = watchRef.watch(courierEnvironmentsProvider);

    final envName = envsAsync.whenOrNull(
          data: (envs) {
            if (activeId == null) return null;
            final match = envs.where((e) => e.id == activeId).firstOrNull;
            return match?.name;
          },
        ) ??
        'No environment';

    final envs = envsAsync.valueOrNull ?? <EnvironmentResponse>[];

    return PopupMenuButton<String?>(
      key: const Key('environment_selector'),
      offset: const Offset(0, 40),
      color: CodeOpsColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      onSelected: (id) {
        watchRef.read(activeEnvironmentIdProvider.notifier).state = id;
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text(
            'No environment',
            style: TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textSecondary,
            ),
          ),
        ),
        ...envs.map(
          (e) => PopupMenuItem<String?>(
            value: e.id,
            child: Text(
              e.name ?? 'Unnamed',
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: CodeOpsColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.tune_outlined,
              size: 14,
              color: CodeOpsColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              envName,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: CodeOpsColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
