/// Warning banner shown when port conflicts are detected.
///
/// Collapsed by default, showing conflict count and a toggle button.
/// When expanded, lists each conflict with port number, environment,
/// and the conflicting service names.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';

/// Warning banner for port conflicts.
///
/// Shows a collapsed summary ("N port conflicts detected") with an
/// expand toggle to reveal detailed conflict information.
class PortConflictBanner extends StatefulWidget {
  /// The list of detected port conflicts.
  final List<PortConflictResponse> conflicts;

  /// Creates a [PortConflictBanner].
  const PortConflictBanner({super.key, required this.conflicts});

  @override
  State<PortConflictBanner> createState() => _PortConflictBannerState();
}

class _PortConflictBannerState extends State<PortConflictBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.conflicts.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CodeOpsColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          // Summary row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 18, color: CodeOpsColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.conflicts.length} port '
                      '${widget.conflicts.length == 1 ? 'conflict' : 'conflicts'} '
                      'detected',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CodeOpsColors.warning,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: CodeOpsColors.warning,
                  ),
                ],
              ),
            ),
          ),
          // Expanded details
          if (_expanded) ...[
            Divider(
              height: 1,
              color: CodeOpsColors.warning.withValues(alpha: 0.3),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: widget.conflicts.map((conflict) {
                  final services = conflict.conflictingAllocations
                      .map((a) => a.serviceName ?? a.serviceId)
                      .join(', ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CodeOpsColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${conflict.portNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: CodeOpsColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                services,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CodeOpsColors.textPrimary,
                                ),
                              ),
                              Text(
                                conflict.environment,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CodeOpsColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
