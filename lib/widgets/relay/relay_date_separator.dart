/// Date separator widget for the Relay message feed.
///
/// Displays a horizontal line with a centered date label between
/// messages from different days. Uses "Today", "Yesterday", or
/// a formatted date string (e.g. "Mon, Feb 24, 2026").
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';

/// A horizontal divider with a centered date label for the message feed.
///
/// Compares [date] against today and yesterday to produce friendly labels.
/// For older dates, formats as "EEE, MMM d, yyyy" (e.g. "Mon, Feb 24, 2026").
class RelayDateSeparator extends StatelessWidget {
  /// The date to display in the separator.
  final DateTime date;

  /// Creates a [RelayDateSeparator].
  const RelayDateSeparator({required this.date, super.key});

  /// Formats the date as a human-friendly label.
  String _formatLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(height: 1, color: CodeOpsColors.border),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatLabel(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          const Expanded(
            child: Divider(height: 1, color: CodeOpsColors.border),
          ),
        ],
      ),
    );
  }
}
