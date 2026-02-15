// Widget tests for DebtInventory.
//
// Verifies card rendering, badge display, filter dropdowns,
// search, item selection, empty state, and loading state.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/tech_debt_item.dart';
import 'package:codeops/providers/tech_debt_providers.dart';
import 'package:codeops/widgets/tech_debt/debt_inventory.dart';

/// Builds a [TechDebtItem] with sensible defaults.
TechDebtItem _item({
  String id = '1',
  String title = 'Test Debt',
  String? description,
  String? filePath,
  DebtCategory category = DebtCategory.code,
  DebtStatus status = DebtStatus.identified,
  Effort? effort,
  BusinessImpact? impact,
  DateTime? createdAt,
}) {
  return TechDebtItem(
    id: id,
    projectId: 'proj-1',
    category: category,
    title: title,
    description: description,
    filePath: filePath,
    effortEstimate: effort,
    businessImpact: impact,
    status: status,
    createdAt: createdAt,
  );
}

PageResponse<TechDebtItem> _page(List<TechDebtItem> items) {
  return PageResponse<TechDebtItem>(
    content: items,
    page: 0,
    size: items.length,
    totalElements: items.length,
    totalPages: 1,
    isLast: true,
  );
}

void main() {
  Widget buildWidget({
    required List<Override> overrides,
    ValueChanged<TechDebtItem>? onItemSelected,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: DebtInventory(
              projectId: 'proj-1',
              onItemSelected: onItemSelected,
            ),
          ),
        ),
      ),
    );
  }

  group('DebtInventory', () {
    testWidgets('renders debt item cards with all badges', (tester) async {
      final items = [
        _item(
          id: '1',
          title: 'Legacy API coupling',
          category: DebtCategory.architecture,
          status: DebtStatus.identified,
          effort: Effort.xl,
          impact: BusinessImpact.critical,
          filePath: 'src/main/java/Api.java',
          createdAt: DateTime(2026, 1, 15),
        ),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      ));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Legacy API coupling'), findsOneWidget);

      // Category badge
      expect(find.text('Architecture'), findsOneWidget);

      // Status badge
      expect(find.text('Identified'), findsOneWidget);

      // Effort badge (uses toJson() format)
      expect(find.text('XL'), findsOneWidget);

      // Impact badge
      expect(find.text('Critical'), findsOneWidget);

      // File path
      expect(find.text('src/main/java/Api.java'), findsOneWidget);
    });

    testWidgets('shows loading spinner while data loads', (tester) async {
      // Use a Completer so the future never completes during the test.
      final completer = Completer<PageResponse<TechDebtItem>>();

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) => completer.future),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the completer to avoid pending timer errors.
      completer.complete(_page([]));
      await tester.pumpAndSettle();
    });

    testWidgets('empty state shows when no items', (tester) async {
      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page([])),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No tech debt items'), findsOneWidget);
    });

    testWidgets('search field exists and filters on title', (tester) async {
      final items = [
        _item(id: '1', title: 'Legacy code smell'),
        _item(id: '2', title: 'Architecture issue'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      ));
      await tester.pumpAndSettle();

      // Both items visible initially
      expect(find.text('Legacy code smell'), findsOneWidget);
      expect(find.text('Architecture issue'), findsOneWidget);

      // Type in search
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Legacy');
      await tester.pumpAndSettle();

      // Only matching item visible
      expect(find.text('Legacy code smell'), findsOneWidget);
      expect(find.text('Architecture issue'), findsNothing);
    });

    testWidgets('search filters on description', (tester) async {
      final items = [
        _item(
            id: '1',
            title: 'Item A',
            description: 'Needs database refactor'),
        _item(
            id: '2', title: 'Item B', description: 'Simple cleanup task'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'database');
      await tester.pumpAndSettle();

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsNothing);
    });

    testWidgets('search filters on filePath', (tester) async {
      final items = [
        _item(
            id: '1',
            title: 'Item A',
            filePath: 'src/main/java/Service.java'),
        _item(
            id: '2',
            title: 'Item B',
            filePath: 'src/test/kotlin/Test.kt'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'kotlin');
      await tester.pumpAndSettle();

      expect(find.text('Item A'), findsNothing);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('filter dropdowns exist (status, category, effort, impact)',
        (tester) async {
      final items = [
        _item(id: '1', title: 'Test item'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      ));
      await tester.pumpAndSettle();

      // The filter bar contains the search field + 5 dropdown buttons
      // (status, category, effort, impact, sort).
      // DropdownButtonHideUnderline wraps each DropdownButton.
      expect(find.byType(DropdownButtonHideUnderline), findsNWidgets(5));

      // The search text field also exists.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('card selection updates selectedTechDebtItemProvider',
        (tester) async {
      TechDebtItem? selectedItem;
      final items = [
        _item(
          id: 'debt-1',
          title: 'Clickable item',
          category: DebtCategory.code,
          status: DebtStatus.identified,
        ),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
        onItemSelected: (item) => selectedItem = item,
      ));
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.text('Clickable item'));
      await tester.pumpAndSettle();

      expect(selectedItem, isNotNull);
      expect(selectedItem!.id, 'debt-1');
    });

    testWidgets('renders multiple cards', (tester) async {
      final items = [
        _item(id: '1', title: 'First debt item'),
        _item(id: '2', title: 'Second debt item'),
        _item(id: '3', title: 'Third debt item'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('First debt item'), findsOneWidget);
      expect(find.text('Second debt item'), findsOneWidget);
      expect(find.text('Third debt item'), findsOneWidget);
    });
  });
}
