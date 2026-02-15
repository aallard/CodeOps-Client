/// Debt trend chart widget showing tech debt score over time.
///
/// Uses fl_chart to render a line chart of historical debt scores.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tech_debt_providers.dart';
import '../../theme/colors.dart';
import '../shared/empty_state.dart';

/// Line chart visualizing tech debt trend data over time.
///
/// Renders debt score values from [debtTrendDataProvider].
/// Shows "No trend data" when no history is available.
class DebtTrendChart extends ConsumerWidget {
  /// Project ID to load trend data for.
  final String projectId;

  /// Creates a [DebtTrendChart].
  const DebtTrendChart({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(debtTrendDataProvider(projectId));

    return trendAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Error: $err',
          style: const TextStyle(color: CodeOpsColors.error),
        ),
      ),
      data: (trendData) {
        if (trendData.isEmpty) {
          return const EmptyState(
            icon: Icons.show_chart,
            title: 'No trend data',
            subtitle: 'Run multiple scans to see debt trends.',
          );
        }

        final spots = <FlSpot>[];
        for (var i = 0; i < trendData.length; i++) {
          final score = (trendData[i]['techDebtScore'] as num?)?.toDouble() ??
              (trendData[i]['score'] as num?)?.toDouble() ??
              0;
          spots.add(FlSpot(i.toDouble(), score));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Debt Score Trend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: CodeOpsColors.border,
                        strokeWidth: 0.5,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: CodeOpsColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: CodeOpsColors.primary,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: CodeOpsColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'Score: ${spot.y.toInt()}',
                              const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
