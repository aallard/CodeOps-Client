/// Status selector popup for the Relay module.
///
/// Allows the current user to set their presence status (Online,
/// Away, DND, Offline) and an optional status message (max 200
/// characters). Calls the appropriate API endpoint for each status.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';
import 'relay_presence_indicator.dart';

/// A popup for the current user to set their presence status.
///
/// Shows four status options (Online, Away, DND, Offline) with the
/// current status highlighted. Includes an optional status message
/// text field (max 200 characters). Calls [RelayApiService.updatePresence],
/// [RelayApiService.goOffline], or [RelayApiService.setDoNotDisturb]
/// depending on the selected status.
class RelayStatusSelector extends ConsumerStatefulWidget {
  /// Creates a [RelayStatusSelector].
  const RelayStatusSelector({super.key});

  @override
  ConsumerState<RelayStatusSelector> createState() =>
      _RelayStatusSelectorState();
}

class _RelayStatusSelectorState extends ConsumerState<RelayStatusSelector> {
  final _messageController = TextEditingController();
  PresenceStatus _selectedStatus = PresenceStatus.online;
  bool _isUpdating = false;
  bool _loaded = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Loads the current presence state from the provider.
  void _loadCurrent(UserPresenceResponse presence) {
    if (_loaded) return;
    _loaded = true;
    _selectedStatus = presence.status ?? PresenceStatus.online;
    _messageController.text = presence.statusMessage ?? '';
  }

  /// Updates the user's presence via the API.
  Future<void> _updatePresence() async {
    final teamId = ref.read(selectedTeamIdProvider);
    if (teamId == null) return;

    setState(() => _isUpdating = true);

    try {
      final api = ref.read(relayApiProvider);
      final message = _messageController.text.trim();

      switch (_selectedStatus) {
        case PresenceStatus.offline:
          await api.goOffline(teamId);
        case PresenceStatus.dnd:
          await api.setDoNotDisturb(
            teamId,
            statusMessage: message.isNotEmpty ? message : null,
          );
        case PresenceStatus.online:
        case PresenceStatus.away:
          await api.updatePresence(
            UpdatePresenceRequest(
              status: _selectedStatus,
              statusMessage: message.isNotEmpty ? message : null,
            ),
            teamId,
          );
      }

      // Invalidate presence providers to refresh UI.
      ref.invalidate(myPresenceProvider(teamId));
      ref.invalidate(teamPresenceProvider(teamId));

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);
    if (teamId == null) return const SizedBox.shrink();

    final presenceAsync = ref.watch(myPresenceProvider(teamId));

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: presenceAsync.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Failed to load status',
                style:
                    TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
              ),
            ),
          ),
          data: (presence) {
            _loadCurrent(presence);
            return _buildContent();
          },
        ),
      ),
    );
  }

  /// Builds the dialog content with status options and message field.
  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text(
              'Set your status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: CodeOpsColors.textTertiary,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status options
        _buildStatusOption(PresenceStatus.online, 'Online'),
        _buildStatusOption(PresenceStatus.away, 'Away'),
        _buildStatusOption(PresenceStatus.dnd, 'Do Not Disturb'),
        _buildStatusOption(PresenceStatus.offline, 'Offline'),

        const SizedBox(height: 12),
        const Divider(height: 1, color: CodeOpsColors.border),
        const SizedBox(height: 12),

        // Status message
        const Text(
          'Status message',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CodeOpsColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _messageController,
          maxLength: 200,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: "What's your status?",
            hintStyle: const TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textTertiary,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            counterStyle: const TextStyle(
              fontSize: 10,
              color: CodeOpsColors.textTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CodeOpsColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CodeOpsColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CodeOpsColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Update button
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _updatePresence,
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _isUpdating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Update status'),
          ),
        ),
      ],
    );
  }

  /// Builds a single status option row.
  Widget _buildStatusOption(PresenceStatus status, String label) {
    final isActive = _selectedStatus == status;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive
              ? CodeOpsColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            RelayPresenceIndicator(status: status, size: 10),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? CodeOpsColors.textPrimary
                    : CodeOpsColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (isActive)
              const Icon(Icons.check, size: 16, color: CodeOpsColors.primary),
          ],
        ),
      ),
    );
  }
}
