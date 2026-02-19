/// List of secrets expiring within 72 hours.
///
/// Each row shows the secret name, path, type badge, and relative
/// time until expiry. Tappable rows navigate to the secret detail page.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/vault_enums.dart';
import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';
import '../shared/error_panel.dart';

/// Shows secrets expiring within the next 72 hours.
class ExpiringSecretsList extends ConsumerWidget {
  /// Creates an [ExpiringSecretsList].
  const ExpiringSecretsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringAsync = ref.watch(vaultExpiringSecretsProvider);

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
                const Icon(Icons.warning_amber, size: 18,
                    color: CodeOpsColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Expiring Secrets (72h)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          expiringAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => ErrorPanel.fromException(
              error,
              onRetry: () => ref.invalidate(vaultExpiringSecretsProvider),
            ),
            data: (secrets) {
              if (secrets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No secrets expiring soon',
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
                itemCount: secrets.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: CodeOpsColors.border),
                itemBuilder: (context, index) {
                  final secret = secrets[index];
                  final remaining =
                      secret.expiresAt?.difference(DateTime.now());

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.key_outlined,
                      size: 18,
                      color: CodeOpsColors
                          .secretTypeColors[secret.secretType],
                    ),
                    title: Text(
                      secret.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      secret.path,
                      style: const TextStyle(
                        fontSize: 11,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TypeBadge(secret.secretType),
                        const SizedBox(width: 8),
                        Text(
                          _formatRemaining(remaining),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: remaining != null &&
                                    remaining.inHours < 24
                                ? CodeOpsColors.error
                                : CodeOpsColors.warning,
                          ),
                        ),
                      ],
                    ),
                    onTap: () =>
                        context.go('/vault/secrets/${secret.id}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatRemaining(Duration? d) {
    if (d == null) return '\u2014';
    if (d.isNegative) return 'Expired';
    if (d.inHours < 1) return '${d.inMinutes}m left';
    if (d.inHours < 24) return '${d.inHours}h left';
    return '${d.inDays}d ${d.inHours.remainder(24)}h left';
  }
}

class _TypeBadge extends StatelessWidget {
  final SecretType type;

  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    final color = CodeOpsColors.secretTypeColors[type] ??
        CodeOpsColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
