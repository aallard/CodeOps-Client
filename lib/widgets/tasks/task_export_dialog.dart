/// Dialog for exporting selected remediation tasks.
///
/// Supports markdown export to clipboard or file, with options to
/// include metadata and finding details. Updates task status to
/// EXPORTED after successful export.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/enums.dart';
import '../../models/remediation_task.dart';
import '../../providers/task_providers.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Shows the task export dialog.
///
/// Returns `true` if the export completed successfully.
Future<bool?> showTaskExportDialog(
  BuildContext context, {
  required List<RemediationTask> tasks,
  String? jobName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _TaskExportDialog(tasks: tasks, jobName: jobName),
  );
}

enum _ExportTarget { clipboard, file }

class _TaskExportDialog extends ConsumerStatefulWidget {
  final List<RemediationTask> tasks;
  final String? jobName;

  const _TaskExportDialog({required this.tasks, this.jobName});

  @override
  ConsumerState<_TaskExportDialog> createState() => _TaskExportDialogState();
}

class _TaskExportDialogState extends ConsumerState<_TaskExportDialog> {
  _ExportTarget _target = _ExportTarget.clipboard;
  bool _includeMetadata = true;
  bool _includeFindings = false;
  bool _numberByPriority = true;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: const Row(
        children: [
          Icon(Icons.file_download_outlined,
              color: CodeOpsColors.primary, size: 22),
          SizedBox(width: 10),
          Text(
            'Export Tasks',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.tasks.length} task${widget.tasks.length == 1 ? '' : 's'} selected',
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Export target.
            const Text(
              'Export to',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildTargetChip(
                  label: 'Clipboard',
                  icon: Icons.content_paste,
                  target: _ExportTarget.clipboard,
                ),
                const SizedBox(width: 8),
                _buildTargetChip(
                  label: 'Markdown File',
                  icon: Icons.description_outlined,
                  target: _ExportTarget.file,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Options.
            const Text(
              'Options',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _buildCheckbox(
              label: 'Include metadata (status, priority, assignee)',
              value: _includeMetadata,
              onChanged: (v) =>
                  setState(() => _includeMetadata = v ?? false),
            ),
            _buildCheckbox(
              label: 'Include finding IDs',
              value: _includeFindings,
              onChanged: (v) =>
                  setState(() => _includeFindings = v ?? false),
            ),
            _buildCheckbox(
              label: 'Number tasks by priority',
              value: _numberByPriority,
              onChanged: (v) =>
                  setState(() => _numberByPriority = v ?? false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _exporting ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _exporting ? null : _export,
          icon: _exporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.file_download, size: 16),
          label: Text(_exporting ? 'Exporting...' : 'Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetChip({
    required String label,
    required IconData icon,
    required _ExportTarget target,
  }) {
    final isActive = _target == target;
    return InkWell(
      onTap: () => setState(() => _target = target),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? CodeOpsColors.primary.withValues(alpha: 0.15)
              : CodeOpsColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isActive ? CodeOpsColors.primary : CodeOpsColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: _exporting ? null : onChanged,
            activeColor: CodeOpsColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: CodeOpsColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);

    try {
      final markdown = _buildMarkdown();

      if (_target == _ExportTarget.clipboard) {
        await Clipboard.setData(ClipboardData(text: markdown));
      } else {
        final fileName = widget.jobName != null
            ? 'tasks-${widget.jobName}.md'
            : 'tasks-export.md';
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Tasks Export',
          fileName: fileName,
          allowedExtensions: ['md'],
          type: FileType.custom,
        );
        if (result == null) {
          setState(() => _exporting = false);
          return;
        }
        await File(result).writeAsBytes(utf8.encode(markdown));
      }

      // Update task status to exported.
      final taskApi = ref.read(taskApiProvider);
      for (final task in widget.tasks) {
        if (task.status == TaskStatus.pending ||
            task.status == TaskStatus.assigned) {
          try {
            await taskApi.updateTask(task.id, status: TaskStatus.exported);
          } catch (_) {
            // Best-effort status update.
          }
        }
      }

      if (mounted) {
        showToast(
          context,
          message:
              '${widget.tasks.length} task${widget.tasks.length == 1 ? '' : 's'} exported.',
          type: ToastType.success,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _exporting = false);
        showToast(context,
            message: 'Export failed: $e', type: ToastType.error);
      }
    }
  }

  String _buildMarkdown() {
    final buffer = StringBuffer();
    final header = widget.jobName != null
        ? 'Remediation Tasks — ${widget.jobName}'
        : 'Remediation Tasks';
    buffer.writeln('# $header');
    buffer.writeln();

    var tasks = List<RemediationTask>.from(widget.tasks);
    if (_numberByPriority) {
      tasks.sort((a, b) {
        final pa = a.priority?.index ?? 4;
        final pb = b.priority?.index ?? 4;
        return pa.compareTo(pb);
      });
    }

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      buffer.writeln('## ${i + 1}. ${task.title}');
      buffer.writeln();

      if (_includeMetadata) {
        buffer.writeln(
            '- **Priority:** ${task.priority?.displayName ?? "None"}');
        buffer.writeln('- **Status:** ${task.status.displayName}');
        buffer.writeln('- **Task #:** ${task.taskNumber}');
        if (task.assignedToName != null) {
          buffer.writeln('- **Assignee:** ${task.assignedToName}');
        }
        if (task.jiraKey != null) {
          buffer.writeln('- **Jira:** ${task.jiraKey}');
        }
        buffer.writeln();
      }

      if (task.description != null) {
        buffer.writeln(task.description);
        buffer.writeln();
      }

      if (task.promptMd != null) {
        buffer.writeln('### Remediation Prompt');
        buffer.writeln();
        buffer.writeln(task.promptMd);
        buffer.writeln();
      }

      if (_includeFindings &&
          task.findingIds != null &&
          task.findingIds!.isNotEmpty) {
        buffer.writeln(
            '**Related Findings:** ${task.findingIds!.join(", ")}');
        buffer.writeln();
      }

      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
