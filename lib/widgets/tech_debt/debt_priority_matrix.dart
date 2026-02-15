/// Debt priority matrix widget displaying items in a 2D effort vs impact grid.
///
/// Items are positioned by effort (X axis) and business impact (Y axis),
/// allowing visual identification of high-impact/low-effort quick wins.
library;

import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/tech_debt_item.dart';
import '../../theme/colors.dart';
import '../shared/empty_state.dart';

/// Color mapping for categories in the matrix.
const Map<DebtCategory, Color> _matrixCategoryColors = {
  DebtCategory.architecture: Color(0xFFEF4444),
  DebtCategory.code: Color(0xFFFBBF24),
  DebtCategory.test: Color(0xFF3B82F6),
  DebtCategory.dependency: Color(0xFFF97316),
  DebtCategory.documentation: Color(0xFF4ADE80),
};

/// A 2D matrix showing tech debt items by effort (x) and impact (y).
///
/// High-impact / low-effort items appear in the top-left quadrant,
/// making it easy to identify quick wins.
class DebtPriorityMatrix extends StatelessWidget {
  /// The list of tech debt items to display.
  final List<TechDebtItem> items;

  /// Callback when an item is tapped.
  final ValueChanged<TechDebtItem>? onItemTap;

  /// Creates a [DebtPriorityMatrix].
  const DebtPriorityMatrix({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeItems =
        items.where((i) => i.status != DebtStatus.resolved).toList();

    if (activeItems.isEmpty) {
      return const EmptyState(
        icon: Icons.grid_view,
        title: 'No active items',
        subtitle: 'All items are resolved.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Matrix',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Grid background
                    _buildGrid(constraints),
                    // Axis labels
                    _buildAxisLabels(constraints),
                    // Item dots
                    ...activeItems.map(
                      (item) => _buildDot(item, constraints),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: _GridPainter(),
    );
  }

  Widget _buildAxisLabels(BoxConstraints constraints) {
    return Stack(
      children: [
        // Y-axis label (Impact)
        Positioned(
          left: 0,
          top: constraints.maxHeight / 2 - 8,
          child: const RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Impact',
              style: TextStyle(
                fontSize: 10,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
        ),
        // X-axis label (Effort)
        Positioned(
          bottom: 0,
          left: constraints.maxWidth / 2 - 16,
          child: const Text(
            'Effort',
            style: TextStyle(
              fontSize: 10,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(TechDebtItem item, BoxConstraints constraints) {
    // Map effort to x (0..3 for S/M/L/XL)
    final effortIndex =
        Effort.values.indexOf(item.effortEstimate ?? Effort.s);
    // Map impact to y (0..3 for LOW/MEDIUM/HIGH/CRITICAL), invert for top = high
    final impactIndex = BusinessImpact.values
        .indexOf(item.businessImpact ?? BusinessImpact.low);

    final padding = 24.0;
    final usableW = constraints.maxWidth - padding * 2;
    final usableH = constraints.maxHeight - padding * 2;

    final x = padding + (effortIndex / 3) * usableW;
    // Invert Y so high impact is at top
    final y = padding + ((3 - impactIndex) / 3) * usableH;

    final color = _matrixCategoryColors[item.category] ?? CodeOpsColors.primary;

    return Positioned(
      left: x - 8,
      top: y - 8,
      child: Tooltip(
        message: '${item.title}\n'
            '${item.category.displayName} | '
            '${item.effortEstimate?.toJson() ?? '?'} | '
            '${item.businessImpact?.displayName ?? '?'}',
        child: GestureDetector(
          onTap: () => onItemTap?.call(item),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CodeOpsColors.border
      ..strokeWidth = 0.5;

    // Draw 4x4 grid lines
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
