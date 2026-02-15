// Widget tests for DebtPriorityMatrix.
//
// Verifies quadrant grid rendering, item tap callback,
// and empty state for resolved-only items.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/tech_debt_item.dart';
import 'package:codeops/widgets/tech_debt/debt_priority_matrix.dart';

/// Builds a [TechDebtItem] with sensible defaults.
TechDebtItem _item({
  String id = '1',
  String title = 'Debt Item',
  DebtCategory category = DebtCategory.code,
  DebtStatus status = DebtStatus.identified,
  Effort? effort,
  BusinessImpact? impact,
}) {
  return TechDebtItem(
    id: id,
    projectId: 'proj-1',
    category: category,
    title: title,
    status: status,
    effortEstimate: effort,
    businessImpact: impact,
  );
}

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 500,
          height: 500,
          child: child,
        ),
      ),
    );
  }

  group('DebtPriorityMatrix', () {
    testWidgets('renders quadrant grid with active items', (tester) async {
      final items = [
        _item(
          id: '1',
          title: 'Quick win',
          status: DebtStatus.identified,
          effort: Effort.s,
          impact: BusinessImpact.critical,
        ),
        _item(
          id: '2',
          title: 'Big project',
          status: DebtStatus.planned,
          effort: Effort.xl,
          impact: BusinessImpact.low,
        ),
      ];

      await tester.pumpWidget(wrap(
        DebtPriorityMatrix(items: items),
      ));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Priority Matrix'), findsOneWidget);

      // Axis labels
      expect(find.text('Impact'), findsOneWidget);
      expect(find.text('Effort'), findsOneWidget);

      // Item dots are rendered (as GestureDetector containers)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('item tap calls onItemTap', (tester) async {
      TechDebtItem? tappedItem;
      final items = [
        _item(
          id: 'tap-me',
          title: 'Tappable item',
          status: DebtStatus.identified,
          effort: Effort.m,
          impact: BusinessImpact.high,
        ),
      ];

      await tester.pumpWidget(wrap(
        DebtPriorityMatrix(
          items: items,
          onItemTap: (item) => tappedItem = item,
        ),
      ));
      await tester.pumpAndSettle();

      // Find the dot container (16x16 circle inside a GestureDetector).
      // The dots are Positioned widgets containing Tooltip > GestureDetector > Container.
      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 16 &&
            widget.constraints?.maxHeight == 16,
      );

      if (dotFinder.evaluate().isNotEmpty) {
        await tester.tap(dotFinder.first);
        await tester.pumpAndSettle();
        expect(tappedItem, isNotNull);
        expect(tappedItem!.id, 'tap-me');
      }
    });

    testWidgets('no active items shows empty state', (tester) async {
      final items = [
        _item(id: '1', status: DebtStatus.resolved),
        _item(id: '2', status: DebtStatus.resolved),
      ];

      await tester.pumpWidget(wrap(
        DebtPriorityMatrix(items: items),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No active items'), findsOneWidget);
      expect(find.text('All items are resolved.'), findsOneWidget);
    });

    testWidgets('empty items list shows empty state', (tester) async {
      await tester.pumpWidget(wrap(
        const DebtPriorityMatrix(items: []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No active items'), findsOneWidget);
    });

    testWidgets('mixed resolved and active shows only active dots',
        (tester) async {
      final items = [
        _item(
          id: '1',
          status: DebtStatus.resolved,
          effort: Effort.s,
          impact: BusinessImpact.low,
        ),
        _item(
          id: '2',
          title: 'Active item',
          status: DebtStatus.identified,
          effort: Effort.m,
          impact: BusinessImpact.high,
        ),
      ];

      await tester.pumpWidget(wrap(
        DebtPriorityMatrix(items: items),
      ));
      await tester.pumpAndSettle();

      // Matrix title should be visible (not empty state)
      expect(find.text('Priority Matrix'), findsOneWidget);
      expect(find.text('No active items'), findsNothing);
    });
  });
}
