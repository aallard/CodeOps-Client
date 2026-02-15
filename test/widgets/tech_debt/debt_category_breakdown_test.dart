// Widget tests for DebtCategoryBreakdown.
//
// Verifies donut chart rendering with category data,
// legend display, and empty state.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/tech_debt_item.dart';
import 'package:codeops/widgets/tech_debt/debt_category_breakdown.dart';

/// Builds a [TechDebtItem] with sensible defaults.
TechDebtItem _item({
  String id = '1',
  DebtCategory category = DebtCategory.code,
}) {
  return TechDebtItem(
    id: id,
    projectId: 'proj-1',
    category: category,
    title: 'Item $id',
    status: DebtStatus.identified,
  );
}

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: child,
        ),
      ),
    );
  }

  group('DebtCategoryBreakdown', () {
    testWidgets('renders donut chart with 5 categories', (tester) async {
      final items = [
        _item(id: '1', category: DebtCategory.architecture),
        _item(id: '2', category: DebtCategory.architecture),
        _item(id: '3', category: DebtCategory.code),
        _item(id: '4', category: DebtCategory.code),
        _item(id: '5', category: DebtCategory.code),
        _item(id: '6', category: DebtCategory.test),
        _item(id: '7', category: DebtCategory.dependency),
        _item(id: '8', category: DebtCategory.documentation),
      ];

      await tester.pumpWidget(wrap(DebtCategoryBreakdown(items: items)));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Category Breakdown'), findsOneWidget);

      // Legend entries for all 5 categories
      expect(find.text('Architecture: 2'), findsOneWidget);
      expect(find.text('Code: 3'), findsOneWidget);
      expect(find.text('Test: 1'), findsOneWidget);
      expect(find.text('Dependency: 1'), findsOneWidget);
      expect(find.text('Documentation: 1'), findsOneWidget);
    });

    testWidgets('legend shows category names and counts', (tester) async {
      final items = [
        _item(id: '1', category: DebtCategory.architecture),
        _item(id: '2', category: DebtCategory.test),
        _item(id: '3', category: DebtCategory.test),
      ];

      await tester.pumpWidget(wrap(DebtCategoryBreakdown(items: items)));
      await tester.pumpAndSettle();

      expect(find.text('Architecture: 1'), findsOneWidget);
      expect(find.text('Test: 2'), findsOneWidget);
      // Zero-count categories should still appear in legend
      expect(find.text('Code: 0'), findsOneWidget);
      expect(find.text('Dependency: 0'), findsOneWidget);
      expect(find.text('Documentation: 0'), findsOneWidget);
    });

    testWidgets('0 items shows empty state', (tester) async {
      await tester
          .pumpWidget(wrap(const DebtCategoryBreakdown(items: [])));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('No tech debt items to categorize.'), findsOneWidget);
    });

    testWidgets('single category renders correctly', (tester) async {
      final items = [
        _item(id: '1', category: DebtCategory.code),
        _item(id: '2', category: DebtCategory.code),
      ];

      await tester.pumpWidget(wrap(DebtCategoryBreakdown(items: items)));
      await tester.pumpAndSettle();

      expect(find.text('Category Breakdown'), findsOneWidget);
      expect(find.text('Code: 2'), findsOneWidget);
    });
  });
}
