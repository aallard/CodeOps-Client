/// Summary view displayed after a collection run completes.
///
/// Shows overall stats (total/passed/failed/avg time), pass rate
/// percentage indicator, per-iteration breakdown, and export buttons.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/courier/collection_runner_service.dart';
import '../../theme/colors.dart';

/// Displays the summary of a completed collection run.
///
/// Accepts the full list of [RequestRunResult] from the runner, computes
/// aggregated stats, and provides export options (JSON, CSV).
class RunSummaryView extends StatelessWidget {
  /// All results from the completed run.
  final List<RequestRunResult> results;

  /// Number of iterations that were configured.
  final int iterations;

  /// Called when the user wants to run again.
  final VoidCallback? onRunAgain;

  /// Creates a [RunSummaryView].
  const RunSummaryView({
    super.key,
    required this.results,
    this.iterations = 1,
    this.onRunAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('run_summary_view'),
      color: CodeOpsColors.background,
      child: Column(
        children: [
          _buildSummaryHeader(context),
          const Divider(height: 1, color: CodeOpsColors.border),
          _buildStatsRow(),
          const Divider(height: 1, color: CodeOpsColors.border),
          if (iterations > 1) ...[
            _buildIterationBreakdown(),
            const Divider(height: 1, color: CodeOpsColors.border),
          ],
          Expanded(child: _buildResultsList()),
          const Divider(height: 1, color: CodeOpsColors.border),
          _buildExportBar(context),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context) {
    final passed = results.where((r) => r.passed).length;
    final failed = results.where((r) => !r.passed).length;
    final total = results.length;
    final passRate = total > 0 ? (passed / total * 100).round() : 0;
    final allPassed = failed == 0 && total > 0;

    return Container(
      key: const Key('summary_header'),
      padding: const EdgeInsets.all(16),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          // Pass rate circle
          Container(
            key: const Key('pass_rate_indicator'),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: allPassed ? CodeOpsColors.success : CodeOpsColors.error,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$passRate%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      allPassed ? CodeOpsColors.success : CodeOpsColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allPassed ? 'All tests passed' : '$failed request(s) failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: allPassed
                        ? CodeOpsColors.success
                        : CodeOpsColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total requests executed'
                  '${iterations > 1 ? ' over $iterations iterations' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRunAgain != null)
            ElevatedButton.icon(
              key: const Key('run_again_button'),
              onPressed: onRunAgain,
              icon: const Icon(Icons.replay, size: 14),
              label: const Text('Run Again', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: CodeOpsColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final passed = results.where((r) => r.passed).length;
    final failed = results.where((r) => !r.passed).length;
    final durations = results
        .where((r) => r.durationMs != null)
        .map((r) => r.durationMs!)
        .toList();
    final avgTime = durations.isNotEmpty
        ? (durations.reduce((a, b) => a + b) / durations.length).round()
        : 0;
    final totalTime =
        durations.isNotEmpty ? durations.reduce((a, b) => a + b) : 0;

    return Container(
      key: const Key('summary_stats'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CodeOpsColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBlock(
              key: const Key('stat_total_requests'),
              label: 'Total',
              value: '${results.length}'),
          _StatBlock(
              key: const Key('stat_passed_requests'),
              label: 'Passed',
              value: '$passed',
              color: CodeOpsColors.success),
          _StatBlock(
              key: const Key('stat_failed_requests'),
              label: 'Failed',
              value: '$failed',
              color: CodeOpsColors.error),
          _StatBlock(
              key: const Key('stat_avg_time'),
              label: 'Avg Time',
              value: '${avgTime}ms'),
          _StatBlock(
              key: const Key('stat_total_time'),
              label: 'Total Time',
              value: _formatDuration(totalTime)),
        ],
      ),
    );
  }

  Widget _buildIterationBreakdown() {
    final iterMap = <int, List<RequestRunResult>>{};
    for (final r in results) {
      iterMap.putIfAbsent(r.iteration, () => []).add(r);
    }

    return Container(
      key: const Key('iteration_breakdown'),
      padding: const EdgeInsets.all(16),
      color: CodeOpsColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iteration Breakdown',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...iterMap.entries.map((entry) {
            final iterResults = entry.value;
            final passed = iterResults.where((r) => r.passed).length;
            final total = iterResults.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    'Iteration ${entry.key}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: total > 0 ? passed / total : 0,
                        backgroundColor: CodeOpsColors.border,
                        color: passed == total
                            ? CodeOpsColors.success
                            : CodeOpsColors.warning,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$passed/$total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: passed == total
                          ? CodeOpsColors.success
                          : CodeOpsColors.warning,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      key: const Key('summary_results_list'),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: CodeOpsColors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ),
              Icon(
                r.passed ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: r.passed
                    ? CodeOpsColors.success
                    : CodeOpsColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.requestName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  r.statusCode?.toString() ?? '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  r.durationMs != null ? '${r.durationMs}ms' : '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportBar(BuildContext context) {
    return Container(
      key: const Key('export_bar'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          const Text(
            'Export Results:',
            style: TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            key: const Key('export_json_button'),
            onPressed: () => _exportJson(context),
            icon: const Icon(Icons.code, size: 14),
            label: const Text('JSON', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: CodeOpsColors.textSecondary,
            ),
          ),
          TextButton.icon(
            key: const Key('export_csv_button'),
            onPressed: () => _exportCsv(context),
            icon: const Icon(Icons.table_chart, size: 14),
            label: const Text('CSV', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _exportJson(BuildContext context) {
    final json = jsonEncode(results.map((r) => {
      'requestId': r.requestId,
      'requestName': r.requestName,
      'method': r.method,
      'url': r.url,
      'statusCode': r.statusCode,
      'durationMs': r.durationMs,
      'passed': r.passed,
      'testsTotal': r.testsTotal,
      'testsPassed': r.testsPassed,
      'error': r.error,
      'iteration': r.iteration,
    }).toList());
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON results copied to clipboard')),
    );
  }

  void _exportCsv(BuildContext context) {
    final buf = StringBuffer();
    buf.writeln(
        '#,Request,Method,URL,Status,Duration (ms),Passed,Tests,Error,Iteration');
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      buf.writeln(
          '${i + 1},"${r.requestName}",${r.method},"${r.url}",${r.statusCode ?? ""},${r.durationMs ?? ""},${r.passed},${r.testsPassed}/${r.testsTotal},"${r.error ?? ""}",${r.iteration}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV results copied to clipboard')),
    );
  }

  String _formatDuration(int ms) {
    if (ms < 1000) return '${ms}ms';
    final seconds = (ms / 1000).toStringAsFixed(1);
    return '${seconds}s';
  }
}

/// Single stat block for the summary stats row.
class _StatBlock extends StatelessWidget {
  /// Stat label.
  final String label;

  /// Stat value.
  final String value;

  /// Optional accent color.
  final Color? color;

  /// Creates a [_StatBlock].
  const _StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color ?? CodeOpsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: CodeOpsColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
