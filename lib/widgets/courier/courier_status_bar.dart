/// Bottom status bar for the Courier three-pane layout.
///
/// Shows connection status, console toggle, history shortcut, and cookie
/// manager button. Fixed height 32px.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/courier_ui_providers.dart';
import '../../theme/colors.dart';

/// Fixed-height bottom bar displayed below the three panes in [CourierPage].
class CourierStatusBar extends ConsumerWidget {
  /// Creates a [CourierStatusBar].
  const CourierStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consoleVisible = ref.watch(consoleVisibleProvider);

    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: CodeOpsColors.background,
        border: Border(top: BorderSide(color: CodeOpsColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Online indicator
          const _OnlineIndicator(),
          const SizedBox(width: 16),
          const _Divider(),
          const SizedBox(width: 16),
          // Console toggle
          _StatusBarButton(
            label: 'Console',
            icon: Icons.terminal,
            isActive: consoleVisible,
            onTap: () {
              ref.read(consoleVisibleProvider.notifier).state = !consoleVisible;
            },
          ),
          const SizedBox(width: 8),
          // History shortcut
          _StatusBarButton(
            label: 'History',
            icon: Icons.history,
            onTap: () => context.go('/courier/history'),
          ),
          const SizedBox(width: 8),
          // Cookies button
          _StatusBarButton(
            label: 'Cookies',
            icon: Icons.cookie_outlined,
            onTap: () => _showCookieManager(context),
          ),
          const Spacer(),
          // Keyboard shortcut hint
          const Text(
            '⌘+Enter to send',
            style: TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCookieManager(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CodeOpsColors.surface,
        title: const Text(
          'Cookie Manager',
          style: TextStyle(color: CodeOpsColors.textPrimary, fontSize: 15),
        ),
        content: const Text(
          'Cookie management will be available in a future update.',
          style: TextStyle(color: CodeOpsColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Online status indicator
// ─────────────────────────────────────────────────────────────────────────────

class _OnlineIndicator extends StatelessWidget {
  const _OnlineIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusDot(color: CodeOpsColors.success),
        SizedBox(width: 6),
        Text(
          'Online',
          style: TextStyle(
            fontSize: 11,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;

  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical divider
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: CodeOpsColors.border,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status bar text button
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusBarButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? CodeOpsColors.primary : CodeOpsColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
