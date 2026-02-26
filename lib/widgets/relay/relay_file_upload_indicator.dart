/// Upload progress indicator for the Relay module.
///
/// Displays a compact card per file showing file name, a linear
/// progress bar, and status (uploading / complete / failed).
/// Used inside the message composer to show real-time upload state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/relay_providers.dart';
import '../../theme/colors.dart';
import 'relay_file_icon.dart';

/// Shows upload progress for all files currently being uploaded.
///
/// Reads [uploadProgressProvider] and renders a card per file.
/// Each card shows a file type icon, file name, progress bar,
/// and a status label (percentage, "Complete", or "Failed").
class RelayFileUploadIndicator extends ConsumerWidget {
  /// Creates a [RelayFileUploadIndicator].
  const RelayFileUploadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploads = ref.watch(uploadProgressProvider);
    if (uploads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: uploads.values.map(_buildUploadCard).toList(),
    );
  }

  /// Builds a single upload progress card.
  Widget _buildUploadCard(FileUploadProgress progress) {
    final Color statusColor;
    final String statusText;

    if (progress.isFailed) {
      statusColor = CodeOpsColors.error;
      statusText = 'Failed';
    } else if (progress.isComplete) {
      statusColor = CodeOpsColors.success;
      statusText = 'Complete';
    } else {
      statusColor = CodeOpsColors.primary;
      statusText = '${(progress.progress * 100).toInt()}%';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          RelayFileIcon(fileName: progress.fileName, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress.isFailed ? 1.0 : progress.progress,
                    minHeight: 3,
                    backgroundColor: CodeOpsColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
