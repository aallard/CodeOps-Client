/// Compact card for displaying a single Jira issue in a list.
///
/// Shows the issue key, summary, status badge, priority, assignee,
/// issue type, comment/attachment counts, and relative timestamp.
/// Supports hover highlight and a tap callback.
library;

import 'package:flutter/material.dart';

import '../../models/jira_models.dart';
import '../../theme/colors.dart';

/// A compact list card for a single Jira issue.
///
/// Renders key information from a [JiraIssueDisplayModel] in a
/// space-efficient layout suitable for issue lists and search results.
/// Hover state provides visual feedback, and tapping triggers [onTap].
class IssueCard extends StatefulWidget {
  /// The display model containing issue data.
  final JiraIssueDisplayModel issue;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Creates an [IssueCard].
  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
  });

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  bool _hovered = false;

  /// Returns a color for the status badge based on the status category key.
  ///
  /// Maps Jira status category keys to theme-appropriate colors:
  /// - `new` (To Do): blue-gray
  /// - `indeterminate` (In Progress): warning yellow
  /// - `done`: success green
  /// - Unknown: text tertiary
  Color _statusColor() {
    return switch (widget.issue.statusCategoryKey) {
      'new' => const Color(0xFF78909C), // blue-gray
      'indeterminate' => CodeOpsColors.warning,
      'done' => CodeOpsColors.success,
      _ => CodeOpsColors.textTertiary,
    };
  }

  /// Returns an icon for the issue type name.
  ///
  /// Maps common Jira issue type names to Material icons.
  IconData _issueTypeIcon() {
    final typeName = widget.issue.issuetypeName?.toLowerCase() ?? '';
    if (typeName.contains('bug')) return Icons.bug_report;
    if (typeName.contains('story')) return Icons.auto_stories;
    if (typeName.contains('epic')) return Icons.bolt;
    if (typeName.contains('sub-task') || typeName.contains('subtask')) {
      return Icons.subdirectory_arrow_right;
    }
    if (typeName.contains('task')) return Icons.check_box_outlined;
    if (typeName.contains('improvement')) return Icons.trending_up;
    return Icons.article_outlined;
  }

  /// Returns a priority icon for the priority name.
  ///
  /// Maps Jira priority names to directional arrow icons with colors.
  (IconData, Color) _priorityDisplay() {
    final name = widget.issue.priorityName?.toLowerCase() ?? '';
    if (name.contains('highest')) {
      return (Icons.keyboard_double_arrow_up, CodeOpsColors.error);
    }
    if (name.contains('high')) {
      return (Icons.keyboard_arrow_up, CodeOpsColors.error);
    }
    if (name.contains('medium')) {
      return (Icons.remove, CodeOpsColors.warning);
    }
    if (name.contains('low')) {
      return (Icons.keyboard_arrow_down, CodeOpsColors.secondary);
    }
    if (name.contains('lowest')) {
      return (Icons.keyboard_double_arrow_down, CodeOpsColors.textTertiary);
    }
    return (Icons.remove, CodeOpsColors.textTertiary);
  }

  /// Formats a [DateTime] as a relative time string (e.g. "2h ago", "3d ago").
  String _relativeTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final (priorityIcon, priorityColor) = _priorityDisplay();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? CodeOpsColors.surfaceVariant
                : CodeOpsColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? CodeOpsColors.primary : CodeOpsColors.border,
              width: _hovered ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: key, status badge, priority, updated time
              Row(
                children: [
                  // Issue type icon
                  Icon(
                    _issueTypeIcon(),
                    size: 16,
                    color: CodeOpsColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  // Issue key
                  Text(
                    issue.key,
                    style: const TextStyle(
                      color: CodeOpsColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Status badge
                  _buildStatusBadge(),
                  const Spacer(),
                  // Priority
                  if (issue.priorityName != null) ...[
                    Icon(priorityIcon, size: 16, color: priorityColor),
                    const SizedBox(width: 4),
                    Text(
                      issue.priorityName!,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Updated time
                  Text(
                    _relativeTime(issue.updated),
                    style: const TextStyle(
                      color: CodeOpsColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Summary
              Text(
                issue.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              // Bottom row: assignee, comments, attachments
              Row(
                children: [
                  // Assignee
                  _buildAssignee(),
                  const Spacer(),
                  // Comment count
                  if (issue.commentCount > 0) ...[
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: CodeOpsColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${issue.commentCount}',
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // Attachment count
                  if (issue.attachmentCount > 0) ...[
                    Icon(
                      Icons.attach_file,
                      size: 14,
                      color: CodeOpsColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${issue.attachmentCount}',
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the status badge pill with category-based coloring.
  Widget _buildStatusBadge() {
    final color = _statusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        widget.issue.statusName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds the assignee display with avatar and name.
  Widget _buildAssignee() {
    final issue = widget.issue;

    if (issue.assigneeName == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: CodeOpsColors.surfaceVariant,
            child: Icon(Icons.person_outline, size: 14,
                color: CodeOpsColors.textTertiary),
          ),
          SizedBox(width: 6),
          Text(
            'Unassigned',
            style: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: CodeOpsColors.surfaceVariant,
          backgroundImage: issue.assigneeAvatarUrl != null
              ? NetworkImage(issue.assigneeAvatarUrl!)
              : null,
          child: issue.assigneeAvatarUrl == null
              ? Text(
                  issue.assigneeName!.isNotEmpty
                      ? issue.assigneeName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          issue.assigneeName!,
          style: const TextStyle(
            color: CodeOpsColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
