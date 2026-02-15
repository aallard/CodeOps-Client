/// Local analysis service for tech debt trend computations.
///
/// Provides weighted debt scoring, category/status breakdowns,
/// resolution rate calculation, priority matrix sorting,
/// and markdown report generation.
library;

import '../../models/enums.dart';
import '../../models/tech_debt_item.dart';
import '../logging/log_service.dart';

/// Analysis service for computing tech debt metrics from item lists.
class TechDebtTracker {
  /// Category weights for debt score calculation.
  static const Map<DebtCategory, int> _categoryWeights = {
    DebtCategory.architecture: 5,
    DebtCategory.code: 3,
    DebtCategory.test: 3,
    DebtCategory.dependency: 4,
    DebtCategory.documentation: 2,
  };

  /// Effort multipliers for debt score calculation.
  static const Map<Effort, int> _effortMultipliers = {
    Effort.s: 1,
    Effort.m: 2,
    Effort.l: 4,
    Effort.xl: 8,
  };

  /// Business impact multipliers for debt score calculation.
  static const Map<BusinessImpact, int> _impactMultipliers = {
    BusinessImpact.low: 1,
    BusinessImpact.medium: 2,
    BusinessImpact.high: 4,
    BusinessImpact.critical: 8,
  };

  /// Computes a weighted debt score from a list of items.
  ///
  /// Formula per item: categoryWeight × effortMultiplier × impactMultiplier.
  /// Only non-RESOLVED items are counted.
  /// Defaults: effort=S (1), impact=LOW (1) if null.
  static int computeDebtScore(List<TechDebtItem> items) {
    log.i('TechDebtTracker', 'Computing debt score (${items.length} items)');
    var score = 0;
    for (final item in items) {
      if (item.status == DebtStatus.resolved) continue;
      final categoryWeight = _categoryWeights[item.category] ?? 3;
      final effortMul = _effortMultipliers[item.effortEstimate ?? Effort.s] ?? 1;
      final impactMul =
          _impactMultipliers[item.businessImpact ?? BusinessImpact.low] ?? 1;
      score += categoryWeight * effortMul * impactMul;
    }
    return score;
  }

  /// Returns a count of items per [DebtCategory].
  static Map<DebtCategory, int> computeDebtByCategory(
    List<TechDebtItem> items,
  ) {
    final counts = <DebtCategory, int>{
      for (final cat in DebtCategory.values) cat: 0,
    };
    for (final item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns a count of items per [DebtStatus].
  static Map<DebtStatus, int> computeDebtByStatus(
    List<TechDebtItem> items,
  ) {
    final counts = <DebtStatus, int>{
      for (final status in DebtStatus.values) status: 0,
    };
    for (final item in items) {
      counts[item.status] = (counts[item.status] ?? 0) + 1;
    }
    return counts;
  }

  /// Computes the resolution rate as a percentage.
  ///
  /// Returns 0.0 if [items] is empty.
  static double computeResolutionRate(List<TechDebtItem> items) {
    if (items.isEmpty) return 0.0;
    final resolved =
        items.where((i) => i.status == DebtStatus.resolved).length;
    return (resolved / items.length) * 100;
  }

  /// Returns items sorted by priority: high impact descending, then low effort ascending.
  ///
  /// This produces a priority order where high-impact/low-effort items appear first.
  static List<TechDebtItem> computePriorityMatrix(
    List<TechDebtItem> items,
  ) {
    final sorted = List<TechDebtItem>.from(items);
    sorted.sort((a, b) {
      final impactA =
          _impactMultipliers[a.businessImpact ?? BusinessImpact.low] ?? 1;
      final impactB =
          _impactMultipliers[b.businessImpact ?? BusinessImpact.low] ?? 1;
      // Higher impact first
      final impactCmp = impactB.compareTo(impactA);
      if (impactCmp != 0) return impactCmp;
      // Lower effort first
      final effortA =
          _effortMultipliers[a.effortEstimate ?? Effort.s] ?? 1;
      final effortB =
          _effortMultipliers[b.effortEstimate ?? Effort.s] ?? 1;
      return effortA.compareTo(effortB);
    });
    return sorted;
  }

  /// Generates a markdown report from items and a summary map.
  static String formatDebtReport(
    List<TechDebtItem> items,
    Map<String, dynamic> summary,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('# Tech Debt Report');
    buffer.writeln();
    buffer.writeln('## Summary');
    buffer.writeln();
    buffer.writeln('- **Total Items:** ${items.length}');
    buffer.writeln(
      '- **Debt Score:** ${computeDebtScore(items)}',
    );
    buffer.writeln(
      '- **Resolution Rate:** ${computeResolutionRate(items).toStringAsFixed(1)}%',
    );
    buffer.writeln();

    // Status breakdown
    final byStatus = computeDebtByStatus(items);
    buffer.writeln('## Status Breakdown');
    buffer.writeln();
    for (final entry in byStatus.entries) {
      buffer.writeln('- **${entry.key.displayName}:** ${entry.value}');
    }
    buffer.writeln();

    // Category breakdown
    final byCategory = computeDebtByCategory(items);
    buffer.writeln('## Category Breakdown');
    buffer.writeln();
    for (final entry in byCategory.entries) {
      buffer.writeln('- **${entry.key.displayName}:** ${entry.value}');
    }
    buffer.writeln();

    // Priority items (top 10)
    final priority = computePriorityMatrix(
      items.where((i) => i.status != DebtStatus.resolved).toList(),
    );
    if (priority.isNotEmpty) {
      buffer.writeln('## Priority Items');
      buffer.writeln();
      buffer.writeln('| Title | Category | Impact | Effort |');
      buffer.writeln('|-------|----------|--------|--------|');
      for (final item in priority.take(10)) {
        buffer.writeln(
          '| ${item.title} | ${item.category.displayName} '
          '| ${item.businessImpact?.displayName ?? 'N/A'} '
          '| ${item.effortEstimate?.displayName ?? 'N/A'} |',
        );
      }
    }

    // Append raw summary if present
    if (summary.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Server Summary Data');
      buffer.writeln();
      for (final entry in summary.entries) {
        buffer.writeln('- **${entry.key}:** ${entry.value}');
      }
    }

    return buffer.toString();
  }
}
