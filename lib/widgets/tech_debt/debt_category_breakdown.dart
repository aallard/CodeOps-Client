/// Debt category breakdown widget showing a donut chart of items per category.
///
/// Uses fl_chart PieChart with 5 category slices and a legend.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/tech_debt_item.dart';
import '../../services/analysis/tech_debt_tracker.dart';
import '../../theme/colors.dart';
import '../shared/empty_state.dart';

/// Color mapping for each [DebtCategory] in the chart.
const Map<DebtCategory, Color> _categoryChartColors = {
  DebtCategory.architecture: Color(0xFFEF4444),
  DebtCategory.code: Color(0xFFFBBF24),
  DebtCategory.test: Color(0xFF3B82F6),
  DebtCategory.dependency: Color(0xFFF97316),
  DebtCategory.documentation: Color(0xFF4ADE80),
};

/// Donut chart showing the distribution of debt items across categories.
///
/// Displays a pie chart with 5 category slices and a legend.
/// Shows an empty state when there are no items.
class DebtCategoryBreakdown extends StatelessWidget {
  /// The list of tech debt items to analyze.
  final List<TechDebtItem> items;

  /// Creates a [DebtCategoryBreakdown].
  const DebtCategoryBreakdown({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.pie_chart_outline,
        title: 'No items',
        subtitle: 'No tech debt items to categorize.',
      );
    }

    final byCategory = TechDebtTracker.computeDebtByCategory(items);
    final total = items.length;

    final sections = byCategory.entries
        .where((e) => e.value > 0)
        .map((entry) {
      final color = _categoryChartColors[entry.key]!;
      final pct = (entry.value / total * 100).round();
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$pct%',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        radius: 28,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          ...byCategory.entries.map((entry) {
            final color = _categoryChartColors[entry.key]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key.displayName}: ${entry.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.textSecondary,
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
}
