/// Riverpod providers for tech debt data.
///
/// Exposes the [TechDebtApi] service, paginated debt items,
/// filter state for status/category/effort/impact,
/// filtered and derived providers, selection state,
/// and trend data.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/health_snapshot.dart';
import '../models/tech_debt_item.dart';
import '../services/cloud/tech_debt_api.dart';
import '../services/logging/log_service.dart';
import 'auth_providers.dart';

/// Provides [TechDebtApi] singleton.
final techDebtApiProvider = Provider<TechDebtApi>(
  (ref) => TechDebtApi(ref.watch(apiClientProvider)),
);

/// Fetches paginated tech debt items for a project.
final projectTechDebtProvider = FutureProvider.family<
    PageResponse<TechDebtItem>, String>((ref, projectId) async {
  log.d('TechDebtProviders', 'Loading tech debt for projectId=$projectId');
  final api = ref.watch(techDebtApiProvider);
  return api.getTechDebtForProject(projectId);
});

/// Fetches a single tech debt item by ID.
final techDebtItemProvider =
    FutureProvider.family<TechDebtItem, String>((ref, itemId) async {
  final api = ref.watch(techDebtApiProvider);
  return api.getTechDebtItem(itemId);
});

/// Fetches tech debt items filtered by status.
final techDebtByStatusProvider = FutureProvider.family<
    PageResponse<TechDebtItem>,
    ({String projectId, DebtStatus status})>((ref, params) async {
  final api = ref.watch(techDebtApiProvider);
  return api.getTechDebtByStatus(params.projectId, params.status);
});

/// Fetches tech debt items filtered by category.
final techDebtByCategoryProvider = FutureProvider.family<
    PageResponse<TechDebtItem>,
    ({String projectId, DebtCategory category})>((ref, params) async {
  final api = ref.watch(techDebtApiProvider);
  return api.getTechDebtByCategory(params.projectId, params.category);
});

/// Fetches the debt summary map for a project.
final debtSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, projectId) async {
    log.d('TechDebtProviders', 'Loading debt summary for projectId=$projectId');
    final api = ref.watch(techDebtApiProvider);
    return api.getDebtSummary(projectId);
  },
);

/// Currently selected tech debt item for the detail panel.
final selectedTechDebtItemProvider =
    StateProvider<TechDebtItem?>((ref) => null);

/// Search query for filtering debt items.
final techDebtSearchQueryProvider = StateProvider<String>((ref) => '');

/// Status filter for the debt inventory.
final techDebtStatusFilterProvider =
    StateProvider<DebtStatus?>((ref) => null);

/// Category filter for the debt inventory.
final techDebtCategoryFilterProvider =
    StateProvider<DebtCategory?>((ref) => null);

/// Effort filter for the debt inventory.
final techDebtEffortFilterProvider =
    StateProvider<Effort?>((ref) => null);

/// Business impact filter for the debt inventory.
final techDebtImpactFilterProvider =
    StateProvider<BusinessImpact?>((ref) => null);

/// Derived provider combining all filters against the full item list.
///
/// Watches [projectTechDebtProvider] and all filter state providers,
/// returning a filtered list of [TechDebtItem]s.
final filteredTechDebtProvider =
    Provider.family<AsyncValue<List<TechDebtItem>>, String>(
  (ref, projectId) {
    final itemsAsync = ref.watch(projectTechDebtProvider(projectId));
    final query = ref.watch(techDebtSearchQueryProvider).toLowerCase();
    final statusFilter = ref.watch(techDebtStatusFilterProvider);
    final categoryFilter = ref.watch(techDebtCategoryFilterProvider);
    final effortFilter = ref.watch(techDebtEffortFilterProvider);
    final impactFilter = ref.watch(techDebtImpactFilterProvider);

    return itemsAsync.whenData((page) {
      var items = page.content;

      if (query.isNotEmpty) {
        items = items.where((item) {
          return item.title.toLowerCase().contains(query) ||
              (item.description?.toLowerCase().contains(query) ?? false) ||
              (item.filePath?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      if (statusFilter != null) {
        items = items.where((i) => i.status == statusFilter).toList();
      }
      if (categoryFilter != null) {
        items = items.where((i) => i.category == categoryFilter).toList();
      }
      if (effortFilter != null) {
        items =
            items.where((i) => i.effortEstimate == effortFilter).toList();
      }
      if (impactFilter != null) {
        items =
            items.where((i) => i.businessImpact == impactFilter).toList();
      }

      return items;
    });
  },
);

/// Derived provider computing trend data from debt summary history.
///
/// Uses health snapshots' techDebtScore over time for trend visualization.
final debtTrendDataProvider =
    Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>(
  (ref, projectId) {
    final summaryAsync = ref.watch(debtSummaryProvider(projectId));
    return summaryAsync.whenData((summary) {
      final trendData = <Map<String, dynamic>>[];
      final history = summary['history'];
      if (history is List) {
        for (final entry in history) {
          if (entry is Map<String, dynamic>) {
            trendData.add(entry);
          }
        }
      }
      return trendData;
    });
  },
);
