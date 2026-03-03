/// Request history page for the Courier module.
///
/// Two-pane layout: left pane shows a scrollable [HistoryListPanel] of
/// previously executed requests grouped by date; right pane shows the
/// [HistoryDetailPanel] for the selected entry with request/response tabs
/// and actions (re-send, open in builder, copy as cURL).
///
/// Route: `/courier/history`
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/courier_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/courier/history_detail_panel.dart';
import '../../widgets/courier/history_list_panel.dart';

/// Full-page request history shown at `/courier/history`.
///
/// Uses a horizontal split: 380 px fixed-width left list panel and the
/// remainder for the detail panel. The back button navigates to the main
/// Courier page.
class RequestHistoryPage extends ConsumerWidget {
  /// Creates a [RequestHistoryPage].
  const RequestHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedHistoryEntryProvider);

    return Scaffold(
      key: const Key('request_history_page'),
      backgroundColor: CodeOpsColors.background,
      body: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────────────
          Container(
            key: const Key('history_page_header'),
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: CodeOpsColors.surface,
              border:
                  Border(bottom: BorderSide(color: CodeOpsColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  color: CodeOpsColors.textSecondary,
                  onPressed: () => context.go('/courier'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.history,
                    size: 18, color: CodeOpsColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Request History',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Two-pane layout ──────────────────────────────────────────
          Expanded(
            child: Row(
              key: const Key('history_two_pane'),
              children: [
                // Left pane — list
                const SizedBox(
                  width: 380,
                  child: HistoryListPanel(),
                ),
                // Right pane — detail
                Expanded(
                  child: selectedId != null
                      ? HistoryDetailPanel(
                          key: ValueKey(selectedId),
                          historyId: selectedId,
                          onOpenInBuilder: (_) {
                            // Navigate to courier builder with this entry
                            context.go('/courier');
                          },
                          onResend: (_) {
                            // Navigate to courier builder to re-send
                            context.go('/courier');
                          },
                        )
                      : const _EmptyDetailState(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown when no history entry is selected.
class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.surface,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: CodeOpsColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'Select an entry to view details',
              style: TextStyle(
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
