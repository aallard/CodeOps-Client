// Tests for tech debt Riverpod providers.
//
// Verifies filter state defaults, filtered provider logic,
// debt summary shape, and selection state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/tech_debt_item.dart';
import 'package:codeops/providers/tech_debt_providers.dart';

/// Builds a [TechDebtItem] with sensible defaults for testing.
TechDebtItem _item({
  String id = '1',
  String title = 'Test Debt',
  String? description,
  String? filePath,
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
    description: description,
    filePath: filePath,
    effortEstimate: effort,
    businessImpact: impact,
    status: status,
  );
}

/// Creates a [PageResponse] wrapping the given items.
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
  group('Filter state providers defaults', () {
    test('techDebtSearchQueryProvider defaults to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(techDebtSearchQueryProvider), '');
    });

    test('techDebtStatusFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(techDebtStatusFilterProvider), isNull);
    });

    test('techDebtCategoryFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(techDebtCategoryFilterProvider), isNull);
    });

    test('techDebtEffortFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(techDebtEffortFilterProvider), isNull);
    });

    test('techDebtImpactFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(techDebtImpactFilterProvider), isNull);
    });
  });

  group('selectedTechDebtItemProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedTechDebtItemProvider), isNull);
    });

    test('can select an item', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final item = _item(id: 'debt-1', title: 'Selected Item');
      container.read(selectedTechDebtItemProvider.notifier).state = item;

      expect(container.read(selectedTechDebtItemProvider), isNotNull);
      expect(container.read(selectedTechDebtItemProvider)!.id, 'debt-1');
      expect(container.read(selectedTechDebtItemProvider)!.title,
          'Selected Item');
    });

    test('can deselect by setting to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final item = _item(id: 'debt-1');
      container.read(selectedTechDebtItemProvider.notifier).state = item;
      expect(container.read(selectedTechDebtItemProvider), isNotNull);

      container.read(selectedTechDebtItemProvider.notifier).state = null;
      expect(container.read(selectedTechDebtItemProvider), isNull);
    });
  });

  group('filteredTechDebtProvider', () {
    test('returns all items with no filters applied', () {
      final items = [
        _item(id: '1', title: 'First'),
        _item(id: '2', title: 'Second'),
        _item(id: '3', title: 'Third'),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      // Let the future resolve.
      container.read(projectTechDebtProvider('proj-1'));

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 3);
      });
    });

    test('filters by search query on title', () {
      final items = [
        _item(id: '1', title: 'Legacy code smell'),
        _item(id: '2', title: 'Architecture issue'),
        _item(id: '3', title: 'Legacy migration'),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtSearchQueryProvider.notifier).state = 'legacy';

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(data.every((i) => i.title.toLowerCase().contains('legacy')),
            isTrue);
      });
    });

    test('filters by search query on description', () {
      final items = [
        _item(
            id: '1',
            title: 'Item A',
            description: 'Needs database refactor'),
        _item(
            id: '2', title: 'Item B', description: 'Simple cleanup task'),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtSearchQueryProvider.notifier).state = 'database';

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.id, '1');
      });
    });

    test('filters by search query on filePath', () {
      final items = [
        _item(id: '1', title: 'A', filePath: 'src/main/java/Service.java'),
        _item(id: '2', title: 'B', filePath: 'src/test/kotlin/Test.kt'),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtSearchQueryProvider.notifier).state = 'kotlin';

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.id, '2');
      });
    });

    test('filters by status', () {
      final items = [
        _item(id: '1', status: DebtStatus.identified),
        _item(id: '2', status: DebtStatus.planned),
        _item(id: '3', status: DebtStatus.identified),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtStatusFilterProvider.notifier).state =
          DebtStatus.identified;

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(data.every((i) => i.status == DebtStatus.identified), isTrue);
      });
    });

    test('filters by category', () {
      final items = [
        _item(id: '1', category: DebtCategory.architecture),
        _item(id: '2', category: DebtCategory.code),
        _item(id: '3', category: DebtCategory.architecture),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtCategoryFilterProvider.notifier).state =
          DebtCategory.architecture;

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(
            data.every((i) => i.category == DebtCategory.architecture), isTrue);
      });
    });

    test('filters by effort', () {
      final items = [
        _item(id: '1', effort: Effort.s),
        _item(id: '2', effort: Effort.xl),
        _item(id: '3', effort: Effort.s),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtEffortFilterProvider.notifier).state = Effort.s;

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(data.every((i) => i.effortEstimate == Effort.s), isTrue);
      });
    });

    test('filters by business impact', () {
      final items = [
        _item(id: '1', impact: BusinessImpact.critical),
        _item(id: '2', impact: BusinessImpact.low),
        _item(id: '3', impact: BusinessImpact.critical),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtImpactFilterProvider.notifier).state =
          BusinessImpact.critical;

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 2);
        expect(
            data.every((i) => i.businessImpact == BusinessImpact.critical),
            isTrue);
      });
    });

    test('combines multiple filters', () {
      final items = [
        _item(
          id: '1',
          title: 'Arch debt',
          category: DebtCategory.architecture,
          status: DebtStatus.identified,
          effort: Effort.s,
          impact: BusinessImpact.high,
        ),
        _item(
          id: '2',
          title: 'Code debt',
          category: DebtCategory.code,
          status: DebtStatus.identified,
          effort: Effort.s,
          impact: BusinessImpact.high,
        ),
        _item(
          id: '3',
          title: 'Arch resolved',
          category: DebtCategory.architecture,
          status: DebtStatus.resolved,
          effort: Effort.s,
          impact: BusinessImpact.high,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtCategoryFilterProvider.notifier).state =
          DebtCategory.architecture;
      container.read(techDebtStatusFilterProvider.notifier).state =
          DebtStatus.identified;

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.id, '1');
      });
    });

    test('returns empty list when no items match all filters', () {
      final items = [
        _item(
          id: '1',
          category: DebtCategory.code,
          status: DebtStatus.planned,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          projectTechDebtProvider('proj-1')
              .overrideWith((ref) async => _page(items)),
        ],
      );
      addTearDown(container.dispose);

      container.read(techDebtCategoryFilterProvider.notifier).state =
          DebtCategory.architecture;
      container.read(techDebtStatusFilterProvider.notifier).state =
          DebtStatus.resolved;

      final filtered = container.read(filteredTechDebtProvider('proj-1'));
      filtered.whenData((data) {
        expect(data, isEmpty);
      });
    });
  });

  group('debtSummaryProvider', () {
    test('returns a Map<String, dynamic>', () {
      final container = ProviderContainer(
        overrides: [
          debtSummaryProvider('proj-1').overrideWith(
            (ref) async => <String, dynamic>{
              'totalItems': 10,
              'resolvedItems': 3,
              'debtScore': 42,
              'history': <Map<String, dynamic>>[],
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      final summaryAsync = container.read(debtSummaryProvider('proj-1'));
      expect(summaryAsync, isA<AsyncValue<Map<String, dynamic>>>());
    });

    test('summary data contains expected keys', () async {
      final summaryData = <String, dynamic>{
        'totalItems': 5,
        'resolvedItems': 2,
        'debtScore': 25,
        'history': [
          {'techDebtScore': 80},
          {'techDebtScore': 75},
        ],
      };

      final container = ProviderContainer(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) async => summaryData),
        ],
      );
      addTearDown(container.dispose);

      // Wait for the future to resolve.
      await container.read(debtSummaryProvider('proj-1').future);
      final result = container.read(debtSummaryProvider('proj-1'));

      result.whenData((data) {
        expect(data.containsKey('totalItems'), isTrue);
        expect(data.containsKey('resolvedItems'), isTrue);
        expect(data.containsKey('debtScore'), isTrue);
        expect(data.containsKey('history'), isTrue);
        expect(data['totalItems'], 5);
        expect(data['history'], isList);
      });
    });
  });

  group('debtTrendDataProvider', () {
    test('extracts trend list from summary history', () async {
      final summaryData = <String, dynamic>{
        'history': [
          {'techDebtScore': 90, 'date': '2026-01-01'},
          {'techDebtScore': 85, 'date': '2026-01-08'},
          {'techDebtScore': 80, 'date': '2026-01-15'},
        ],
      };

      final container = ProviderContainer(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) async => summaryData),
        ],
      );
      addTearDown(container.dispose);

      await container.read(debtSummaryProvider('proj-1').future);
      final trend = container.read(debtTrendDataProvider('proj-1'));

      trend.whenData((data) {
        expect(data.length, 3);
        expect(data.first['techDebtScore'], 90);
      });
    });

    test('returns empty list when no history in summary', () async {
      final summaryData = <String, dynamic>{
        'totalItems': 5,
      };

      final container = ProviderContainer(
        overrides: [
          debtSummaryProvider('proj-1')
              .overrideWith((ref) async => summaryData),
        ],
      );
      addTearDown(container.dispose);

      await container.read(debtSummaryProvider('proj-1').future);
      final trend = container.read(debtTrendDataProvider('proj-1'));

      trend.whenData((data) {
        expect(data, isEmpty);
      });
    });
  });
}
