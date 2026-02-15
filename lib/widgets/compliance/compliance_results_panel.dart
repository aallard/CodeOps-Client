/// Compliance results panel for the job report page.
///
/// Renders a score gauge, status summary bar, and the compliance matrix
/// with filtering and pagination for COMPLIANCE mode jobs.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/compliance_providers.dart';
import '../../theme/colors.dart';
import '../reports/compliance_matrix.dart';
import '../shared/error_panel.dart';
import '../shared/loading_overlay.dart';

/// Displays compliance results for a completed compliance job.
class ComplianceResultsPanel extends ConsumerWidget {
  /// The job UUID.
  final String jobId;

  /// Creates a [ComplianceResultsPanel].
  const ComplianceResultsPanel({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(complianceSummaryProvider(jobId));
    final itemsAsync = ref.watch(complianceJobItemsProvider(jobId));
    final scoreAsync = ref.watch(complianceScoreProvider(jobId));

    return summaryAsync.when(
      loading: () =>
          const LoadingOverlay(message: 'Loading compliance results...'),
      error: (e, _) => ErrorPanel.fromException(e,
          onRetry: () => ref.invalidate(complianceSummaryProvider(jobId))),
      data: (summary) {
        return itemsAsync.when(
          loading: () =>
              const LoadingOverlay(message: 'Loading compliance items...'),
          error: (e, _) => ErrorPanel.fromException(e,
              onRetry: () =>
                  ref.invalidate(complianceJobItemsProvider(jobId))),
          data: (itemsPage) {
            final score = scoreAsync.valueOrNull ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score gauge + status summary row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Score gauge
                      _ScoreGauge(score: score),
                      const SizedBox(width: 24),
                      // Status summary cards
                      Expanded(
                        child: _StatusSummaryBar(summary: summary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Compliance matrix
                  SizedBox(
                    height: 500,
                    child: ComplianceMatrix(items: itemsPage.content),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Circular score gauge with color coding.
class _ScoreGauge extends StatelessWidget {
  final double score;

  const _ScoreGauge({required this.score});

  Color get _gaugeColor {
    if (score >= 80) return CodeOpsColors.success;
    if (score >= 60) return CodeOpsColors.warning;
    return CodeOpsColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: CustomPaint(
        painter: _GaugePainter(
          score: score,
          color: _gaugeColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.round()}%',
                style: TextStyle(
                  color: _gaugeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Compliance',
                style: TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background arc
    final bgPaint = Paint()
      ..color = CodeOpsColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}

/// Row of status summary cards.
class _StatusSummaryBar extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _StatusSummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = (summary['total'] as num?)?.toInt() ?? 0;
    final met = (summary['met'] as num?)?.toInt() ?? 0;
    final partial = (summary['partial'] as num?)?.toInt() ?? 0;
    final missing = (summary['missing'] as num?)?.toInt() ?? 0;
    final notApplicable = (summary['notApplicable'] as num?)?.toInt() ?? 0;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _StatusCard(
          label: 'Met',
          count: met,
          total: total,
          color: CodeOpsColors.success,
        ),
        _StatusCard(
          label: 'Partial',
          count: partial,
          total: total,
          color: CodeOpsColors.warning,
        ),
        _StatusCard(
          label: 'Missing',
          count: missing,
          total: total,
          color: CodeOpsColors.error,
        ),
        _StatusCard(
          label: 'N/A',
          count: notApplicable,
          total: total,
          color: CodeOpsColors.textTertiary,
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
