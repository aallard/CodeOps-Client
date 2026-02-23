/// Banner displayed when a file has changed on disk since it was loaded.
///
/// Shows a warning message with Reload and Keep buttons so the user can
/// choose to update the tab content from disk or keep their current edits.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A banner indicating that a tab's underlying file has been modified on disk.
///
/// Placed above the editor area for the affected tab. The user can choose
/// to [onReload] the content from disk or [onKeep] the current content.
class ScribeFileChangedBanner extends StatelessWidget {
  /// The file name to display in the banner.
  final String fileName;

  /// Called when the user chooses to reload the file from disk.
  final VoidCallback onReload;

  /// Called when the user chooses to keep the current content.
  final VoidCallback onKeep;

  /// Creates a [ScribeFileChangedBanner].
  const ScribeFileChangedBanner({
    super.key,
    required this.fileName,
    required this.onReload,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.scribeFileChangedBannerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: CodeOpsColors.warning.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: CodeOpsColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "'$fileName' has been changed on disk.",
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _BannerButton(
            label: 'Reload',
            onPressed: onReload,
            isPrimary: true,
          ),
          const SizedBox(width: 4),
          _BannerButton(
            label: 'Keep',
            onPressed: onKeep,
            isPrimary: false,
          ),
        ],
      ),
    );
  }
}

/// A compact button used within the file-changed banner.
class _BannerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _BannerButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: isPrimary
              ? CodeOpsColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          foregroundColor:
              isPrimary ? CodeOpsColors.primary : CodeOpsColors.textSecondary,
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
