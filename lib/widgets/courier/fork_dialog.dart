/// Dialog for forking a collection and viewing existing forks.
///
/// Creates a personal copy of a shared collection via
/// `POST /courier/collections/{id}/fork` and lists existing forks via
/// `GET /courier/collections/{id}/forks`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Dialog for forking a collection and viewing its forks.
///
/// The user can enter an optional label for the fork, then create it.
/// Below the fork form, existing forks are listed with their creator
/// and creation date.
class ForkDialog extends ConsumerStatefulWidget {
  /// The collection ID to fork.
  final String collectionId;

  /// The collection name (for display).
  final String collectionName;

  /// Creates a [ForkDialog].
  const ForkDialog({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  ConsumerState<ForkDialog> createState() => _ForkDialogState();
}

class _ForkDialogState extends ConsumerState<ForkDialog> {
  final _labelController = TextEditingController();
  bool _forking = false;
  String? _error;
  ForkResponse? _createdFork;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _fork() async {
    setState(() {
      _forking = true;
      _error = null;
    });

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) throw Exception('No team selected');
      final api = ref.read(courierApiProvider);

      final label = _labelController.text.trim();
      final fork = await api.forkCollection(
        teamId,
        widget.collectionId,
        request: label.isNotEmpty ? CreateForkRequest(label: label) : null,
      );

      ref.invalidate(courierCollectionForksProvider(widget.collectionId));
      ref.invalidate(courierCollectionsProvider);

      setState(() {
        _forking = false;
        _createdFork = fork;
      });
    } catch (e) {
      setState(() {
        _forking = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final forksAsync =
        ref.watch(courierCollectionForksProvider(widget.collectionId));

    return Dialog(
      key: const Key('fork_dialog'),
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 460,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.fork_right,
                      color: CodeOpsColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fork "${widget.collectionName}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CodeOpsColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: CodeOpsColors.textTertiary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Success banner ────────────────────────────────────
              if (_createdFork != null) ...[
                Container(
                  key: const Key('fork_success'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CodeOpsColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CodeOpsColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: CodeOpsColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fork created successfully! '
                          'Collection ID: ${_createdFork!.forkedCollectionId ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CodeOpsColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Fork form ─────────────────────────────────────────
              if (_createdFork == null) ...[
                const Text(
                  'Create a personal copy of this collection.',
                  style: TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('fork_label_field'),
                  controller: _labelController,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Label (optional)',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: CodeOpsColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: CodeOpsColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: CodeOpsColors.border),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 12, color: CodeOpsColors.error)),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('fork_button'),
                    onPressed: _forking ? null : _fork,
                    icon: _forking
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.fork_right, size: 16),
                    label: Text(
                      _forking ? 'Forking...' : 'Fork Collection',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: CodeOpsColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Existing forks ────────────────────────────────────
              const Text(
                'Existing Forks',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              forksAsync.when(
                data: (forks) => forks.isEmpty
                    ? const Padding(
                        key: Key('forks_empty'),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No forks yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      )
                    : Column(
                        key: const Key('forks_list'),
                        children: forks.map((f) => _ForkRow(fork: f)).toList(),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const Text(
                  'Failed to load forks',
                  style: TextStyle(color: CodeOpsColors.error, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForkRow extends StatelessWidget {
  final ForkResponse fork;

  const _ForkRow({required this.fork});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.fork_right, size: 14, color: CodeOpsColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fork.label ?? fork.sourceCollectionName ?? 'Fork',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                Text(
                  'by ${fork.forkedByUserId ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (fork.forkedAt != null)
            Text(
              fork.forkedAt!.toIso8601String().substring(0, 10),
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
