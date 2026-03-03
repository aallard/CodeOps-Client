/// Live progress view for a running collection.
///
/// Displays an overall progress bar, a per-request results table with
/// status icons, and live stats (passed/failed/average time). Each row
/// is expandable to show response details.
library;

import 'package:flutter/material.dart';

import '../../services/courier/collection_runner_service.dart';
import '../../theme/colors.dart';

/// Displays live progress of a collection run.
///
/// Accepts a [RunProgress] snapshot and renders an overall progress bar,
/// per-request results table, and summary stats.
class RunnerProgressView extends StatefulWidget {
  /// Current progress snapshot from the runner stream.
  final RunProgress progress;

  /// Called when the user taps "Stop".
  final VoidCallback? onStop;

  /// Called when the user taps "Pause".
  final VoidCallback? onPause;

  /// Called when the user taps "Resume".
  final VoidCallback? onResume;

  /// Creates a [RunnerProgressView].
  const RunnerProgressView({
    super.key,
    required this.progress,
    this.onStop,
    this.onPause,
    this.onResume,
  });

  @override
  State<RunnerProgressView> createState() => _RunnerProgressViewState();
}

class _RunnerProgressViewState extends State<RunnerProgressView> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    return Container(
      key: const Key('runner_progress_view'),
      color: CodeOpsColors.background,
      child: Column(
        children: [
          _buildProgressHeader(p),
          const Divider(height: 1, color: CodeOpsColors.border),
          _buildLiveStats(p),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(child: _buildResultsTable(p)),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(RunProgress p) {
    final totalOps = p.totalIterations * p.totalRequests;
    final completedOps =
        (p.currentIteration - 1) * p.totalRequests + p.currentRequest;
    final fraction = totalOps > 0 ? completedOps / totalOps : 0.0;

    return Container(
      key: const Key('progress_header'),
      padding: const EdgeInsets.all(16),
      color: CodeOpsColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.totalIterations > 1
                      ? 'Iteration ${p.currentIteration}/${p.totalIterations} '
                          '— Request ${p.currentRequest}/${p.totalRequests}'
                      : 'Request ${p.currentRequest}/${p.totalRequests}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
              ),
              _buildStatusBadge(p.status),
              const SizedBox(width: 8),
              _buildControls(p),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              key: const Key('overall_progress_bar'),
              value: fraction.clamp(0.0, 1.0),
              backgroundColor: CodeOpsColors.border,
              color: _progressColor(p.status),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            key: const Key('progress_label'),
            '${p.requestName} — ${(fraction * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RunProgressStatus status) {
    final (label, color) = switch (status) {
      RunProgressStatus.preparing => ('Preparing', CodeOpsColors.textTertiary),
      RunProgressStatus.running => ('Running', CodeOpsColors.primary),
      RunProgressStatus.paused => ('Paused', CodeOpsColors.warning),
      RunProgressStatus.completed => ('Completed', CodeOpsColors.success),
      RunProgressStatus.cancelled => ('Cancelled', CodeOpsColors.textTertiary),
      RunProgressStatus.error => ('Error', CodeOpsColors.error),
    };

    return Container(
      key: const Key('run_status_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildControls(RunProgress p) {
    final isRunning = p.status == RunProgressStatus.running;
    final isPaused = p.status == RunProgressStatus.paused;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRunning && widget.onPause != null)
          _SmallButton(
            key: const Key('pause_button'),
            icon: Icons.pause,
            label: 'Pause',
            onTap: widget.onPause!,
          ),
        if (isPaused && widget.onResume != null)
          _SmallButton(
            key: const Key('resume_button'),
            icon: Icons.play_arrow,
            label: 'Resume',
            onTap: widget.onResume!,
          ),
        if ((isRunning || isPaused) && widget.onStop != null) ...[
          const SizedBox(width: 4),
          _SmallButton(
            key: const Key('stop_button'),
            icon: Icons.stop,
            label: 'Stop',
            color: CodeOpsColors.error,
            onTap: widget.onStop!,
          ),
        ],
      ],
    );
  }

  Widget _buildLiveStats(RunProgress p) {
    final results = p.results;
    final passed = results.where((r) => r.passed).length;
    final failed = results.where((r) => !r.passed).length;
    final durations = results
        .where((r) => r.durationMs != null)
        .map((r) => r.durationMs!)
        .toList();
    final avgTime = durations.isNotEmpty
        ? (durations.reduce((a, b) => a + b) / durations.length).round()
        : 0;

    return Container(
      key: const Key('live_stats'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          _StatChip(
            key: const Key('stat_passed'),
            label: 'Passed',
            value: '$passed',
            color: CodeOpsColors.success,
          ),
          const SizedBox(width: 12),
          _StatChip(
            key: const Key('stat_failed'),
            label: 'Failed',
            value: '$failed',
            color: CodeOpsColors.error,
          ),
          const SizedBox(width: 12),
          _StatChip(
            key: const Key('stat_avg_time'),
            label: 'Avg',
            value: '${avgTime}ms',
            color: CodeOpsColors.secondary,
          ),
          const Spacer(),
          Text(
            key: const Key('stat_total'),
            '${results.length} / ${p.totalIterations * p.totalRequests} total',
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(RunProgress p) {
    final results = p.results;
    if (results.isEmpty) {
      return const Center(
        key: Key('results_empty'),
        child: Text(
          'Waiting for results…',
          style: TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textTertiary,
          ),
        ),
      );
    }

    return ListView.builder(
      key: const Key('results_table'),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        final isExpanded = _expandedIndex == index;
        return Column(
          children: [
            InkWell(
              key: Key('result_row_$index'),
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: isExpanded
                    ? CodeOpsColors.surfaceVariant
                    : CodeOpsColors.background,
                child: Row(
                  children: [
                    // Index
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CodeOpsColors.textTertiary,
                        ),
                      ),
                    ),
                    // Status icon
                    _statusIcon(r),
                    const SizedBox(width: 8),
                    // Request name
                    Expanded(
                      child: Text(
                        r.requestName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CodeOpsColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status code
                    SizedBox(
                      width: 50,
                      child: Text(
                        r.statusCode?.toString() ?? '—',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusCodeColor(r.statusCode),
                        ),
                      ),
                    ),
                    // Duration
                    SizedBox(
                      width: 70,
                      child: Text(
                        r.durationMs != null ? '${r.durationMs}ms' : '—',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CodeOpsColors.textSecondary,
                        ),
                      ),
                    ),
                    // Tests
                    SizedBox(
                      width: 70,
                      child: r.testsTotal > 0
                          ? Text(
                              '${r.testsPassed}/${r.testsTotal}',
                              style: TextStyle(
                                fontSize: 12,
                                color: r.testsPassed == r.testsTotal
                                    ? CodeOpsColors.success
                                    : CodeOpsColors.error,
                              ),
                            )
                          : const Text(
                              '—',
                              style: TextStyle(
                                fontSize: 12,
                                color: CodeOpsColors.textTertiary,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) _buildExpandedDetail(r),
            const Divider(height: 1, color: CodeOpsColors.border),
          ],
        );
      },
    );
  }

  Widget _buildExpandedDetail(RequestRunResult r) {
    return Container(
      key: const Key('expanded_detail'),
      padding: const EdgeInsets.all(16),
      color: CodeOpsColors.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Method', value: r.method),
          _DetailRow(label: 'URL', value: r.url),
          if (r.statusCode != null)
            _DetailRow(label: 'Status', value: r.statusCode.toString()),
          if (r.durationMs != null)
            _DetailRow(label: 'Duration', value: '${r.durationMs}ms'),
          if (r.responseSizeBytes != null)
            _DetailRow(
                label: 'Size', value: '${r.responseSizeBytes} bytes'),
          if (r.testsTotal > 0)
            _DetailRow(
                label: 'Tests',
                value: '${r.testsPassed}/${r.testsTotal} passed'),
          if (r.error != null)
            _DetailRow(label: 'Error', value: r.error!, isError: true),
        ],
      ),
    );
  }

  Widget _statusIcon(RequestRunResult r) {
    if (r.passed) {
      return const Icon(Icons.check_circle,
          size: 16, color: CodeOpsColors.success);
    } else {
      return const Icon(Icons.cancel, size: 16, color: CodeOpsColors.error);
    }
  }

  Color _statusCodeColor(int? code) {
    if (code == null) return CodeOpsColors.textTertiary;
    if (code < 200) return CodeOpsColors.textSecondary;
    if (code < 300) return CodeOpsColors.success;
    if (code < 400) return const Color(0xFF3B82F6);
    if (code < 500) return CodeOpsColors.warning;
    return CodeOpsColors.error;
  }

  Color _progressColor(RunProgressStatus status) {
    return switch (status) {
      RunProgressStatus.running => CodeOpsColors.primary,
      RunProgressStatus.paused => CodeOpsColors.warning,
      RunProgressStatus.completed => CodeOpsColors.success,
      RunProgressStatus.error || RunProgressStatus.cancelled =>
        CodeOpsColors.error,
      _ => CodeOpsColors.primary,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SmallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? CodeOpsColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: c.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: c)),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 12,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isError ? CodeOpsColors.error : CodeOpsColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
