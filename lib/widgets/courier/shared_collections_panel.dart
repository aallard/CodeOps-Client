/// Panel listing collections shared with the current user.
///
/// Shows each shared collection with its owner, permission level, and a
/// click-to-open action. Designed as a section within the collection sidebar
/// or as a standalone panel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../theme/colors.dart';

/// Displays collections that have been shared with the current user.
///
/// Uses `GET /courier/shared-with-me` via [courierSharedWithMeProvider].
/// Each row shows the collection ID, permission badge, and provides an
/// `onOpen` callback to navigate to the shared collection.
class SharedCollectionsPanel extends ConsumerWidget {
  /// Callback when a shared collection is tapped to open it.
  final ValueChanged<String>? onOpen;

  /// Creates a [SharedCollectionsPanel].
  const SharedCollectionsPanel({super.key, this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedAsync = ref.watch(courierSharedWithMeProvider);

    return Container(
      key: const Key('shared_collections_panel'),
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(top: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          const Padding(
            key: Key('shared_panel_header'),
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: CodeOpsColors.textTertiary),
                SizedBox(width: 6),
                Text(
                  'Shared With Me',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── List ────────────────────────────────────────────────
          sharedAsync.when(
            data: (shares) => shares.isEmpty
                ? const Padding(
                    key: Key('shared_empty'),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Text(
                      'No collections shared with you',
                      style: TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  )
                : Column(
                    children: shares
                        .map((s) => _SharedRow(
                              share: s,
                              onTap: () {
                                if (s.collectionId != null) {
                                  onOpen?.call(s.collectionId!);
                                }
                              },
                            ))
                        .toList(),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Failed to load shared collections',
                style: TextStyle(fontSize: 12, color: CodeOpsColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedRow extends StatelessWidget {
  final CollectionShareResponse share;
  final VoidCallback onTap;

  const _SharedRow({required this.share, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.folder_shared_outlined,
                size: 16, color: CodeOpsColors.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    share.collectionId ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    key: const Key('shared_owner_name'),
                    'Shared by ${share.sharedByUserId ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              key: const Key('shared_permission_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: share.permission?.name == 'editor'
                    ? CodeOpsColors.primary.withValues(alpha: 0.15)
                    : CodeOpsColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                share.permission?.displayName ?? 'Viewer',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: share.permission?.name == 'editor'
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
