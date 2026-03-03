/// Bottom status bar for the Courier three-pane layout.
///
/// Shows connection status, console toggle, history shortcut (with a
/// dropdown showing the last 5 entries), and cookie manager button.
/// Fixed height 32px.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/courier_enums.dart';
import '../../providers/courier_providers.dart';
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
          // History dropdown
          _HistoryDropdown(
            key: const Key('history_dropdown'),
            onViewAll: () => context.go('/courier/history'),
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

// ─────────────────────────────────────────────────────────────────────────────
// History dropdown
// ─────────────────────────────────────────────────────────────────────────────

/// Dropdown button showing the last 5 history entries with a "View All" link.
class _HistoryDropdown extends ConsumerWidget {
  final VoidCallback onViewAll;

  const _HistoryDropdown({super.key, required this.onViewAll});

  /// Returns a colour for an HTTP method badge.
  Color _methodColor(CourierHttpMethod? method) => switch (method) {
        CourierHttpMethod.get => CodeOpsColors.success,
        CourierHttpMethod.post => const Color(0xFF60A5FA),
        CourierHttpMethod.put => CodeOpsColors.warning,
        CourierHttpMethod.patch => const Color(0xFFA78BFA),
        CourierHttpMethod.delete => CodeOpsColors.error,
        _ => CodeOpsColors.textTertiary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(courierHistoryProvider);

    return PopupMenuButton<String>(
      tooltip: 'Recent history',
      offset: const Offset(0, -200),
      color: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == '_view_all') {
          onViewAll();
        } else {
          ref.read(selectedHistoryEntryProvider.notifier).state = value;
          onViewAll();
        }
      },
      itemBuilder: (_) {
        final entries = historyAsync.valueOrNull?.content ?? [];
        final recent = entries.take(5).toList();

        if (recent.isEmpty) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: Text('No recent history',
                  style: TextStyle(
                      fontSize: 12, color: CodeOpsColors.textTertiary)),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: '_view_all',
              child: Text('View All History',
                  style: TextStyle(
                      fontSize: 12, color: CodeOpsColors.primary)),
            ),
          ];
        }

        return [
          ...recent.map((e) => PopupMenuItem(
                value: e.id ?? '',
                height: 32,
                child: Row(
                  children: [
                    Text(
                      e.requestMethod?.displayName ?? '???',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _methodColor(e.requestMethod),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.requestUrl ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CodeOpsColors.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${e.responseStatus ?? ''}',
                      style: const TextStyle(
                          fontSize: 11, color: CodeOpsColors.textSecondary),
                    ),
                  ],
                ),
              )),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: '_view_all',
            child: Text('View All History',
                style:
                    TextStyle(fontSize: 12, color: CodeOpsColors.primary)),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history,
                size: 12, color: CodeOpsColors.textSecondary),
            const SizedBox(width: 4),
            const Text(
              'History',
              style:
                  TextStyle(fontSize: 11, color: CodeOpsColors.textSecondary),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down,
                size: 12, color: CodeOpsColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
