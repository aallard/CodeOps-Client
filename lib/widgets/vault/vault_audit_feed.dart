/// Compact list of recent Vault audit log entries.
///
/// Each row shows an operation badge, path, success/fail indicator,
/// and relative timestamp. Displays the first page (10 items).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import '../shared/error_panel.dart';

/// Displays the most recent Vault audit log entries.
class VaultAuditFeed extends ConsumerWidget {
  /// Creates a [VaultAuditFeed].
  const VaultAuditFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(vaultAuditLogProvider);

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, size: 18,
                    color: CodeOpsColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Recent Audit Activity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          auditAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => ErrorPanel.fromException(
              error,
              onRetry: () => ref.invalidate(vaultAuditLogProvider),
            ),
            data: (page) {
              final entries = page.content;
              if (entries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No audit activity yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: CodeOpsColors.border),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _OperationBadge(entry.operation),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.path ?? entry.resourceType ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CodeOpsColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (entry.resourceType != null)
                                Text(
                                  entry.resourceType!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: CodeOpsColors.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          entry.success
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 14,
                          color: entry.success
                              ? CodeOpsColors.success
                              : CodeOpsColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTimeAgo(entry.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OperationBadge extends StatelessWidget {
  final String operation;

  const _OperationBadge(this.operation);

  @override
  Widget build(BuildContext context) {
    final color = switch (operation.toUpperCase()) {
      'WRITE' || 'CREATE' => CodeOpsColors.success,
      'READ' || 'LIST' => const Color(0xFF3B82F6),
      'DELETE' => CodeOpsColors.error,
      'ROTATE' => const Color(0xFFA855F7),
      _ => CodeOpsColors.textTertiary,
    };

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        operation,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
