/// Scrollable list of request history entries grouped by date.
///
/// Displays method badges, URLs, status codes, durations, and timestamps.
/// Supports search, method/status filtering, multi-select for bulk delete,
/// and paginated loading via the server history API.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_enums.dart';
import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a colour for an HTTP method badge.
Color _methodColor(CourierHttpMethod? method) => switch (method) {
      CourierHttpMethod.get => CodeOpsColors.success,
      CourierHttpMethod.post => const Color(0xFF60A5FA),
      CourierHttpMethod.put => CodeOpsColors.warning,
      CourierHttpMethod.patch => const Color(0xFFA78BFA),
      CourierHttpMethod.delete => CodeOpsColors.error,
      CourierHttpMethod.head => CodeOpsColors.textTertiary,
      CourierHttpMethod.options => CodeOpsColors.textTertiary,
      null => CodeOpsColors.textTertiary,
    };

/// Returns a colour for an HTTP status code.
Color _statusColor(int? status) {
  if (status == null) return CodeOpsColors.textTertiary;
  if (status < 300) return CodeOpsColors.success;
  if (status < 400) return const Color(0xFF60A5FA);
  if (status < 500) return CodeOpsColors.warning;
  return CodeOpsColors.error;
}

// ─────────────────────────────────────────────────────────────────────────────
// HistoryListPanel
// ─────────────────────────────────────────────────────────────────────────────

/// Left-pane list of history entries with filters and multi-select.
///
/// Entries are grouped by date (Today, Yesterday, specific dates). The toolbar
/// provides method, status, and text search filters. When a method or search
/// query filter is active the corresponding provider is used; otherwise the
/// default paginated history provider supplies data.
class HistoryListPanel extends ConsumerStatefulWidget {
  /// Creates a [HistoryListPanel].
  const HistoryListPanel({super.key});

  @override
  ConsumerState<HistoryListPanel> createState() => _HistoryListPanelState();
}

class _HistoryListPanelState extends ConsumerState<HistoryListPanel> {
  final _searchController = TextEditingController();
  final _selected = <String>{};
  bool _multiSelect = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _onEntryTap(RequestHistoryResponse entry) {
    if (_multiSelect) {
      setState(() {
        final id = entry.id ?? '';
        if (_selected.contains(id)) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      });
    } else {
      ref.read(selectedHistoryEntryProvider.notifier).state = entry.id;
    }
  }

  Future<void> _deleteSelected() async {
    final teamId = ref.read(selectedTeamIdProvider);
    if (teamId == null || _selected.isEmpty) return;
    final api = ref.read(courierApiProvider);
    for (final id in _selected) {
      await api.deleteHistoryEntry(teamId, id);
    }
    setState(() {
      _selected.clear();
      _multiSelect = false;
    });
    ref.invalidate(courierHistoryProvider);
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CodeOpsColors.surface,
        title: const Text('Clear All History',
            style: TextStyle(color: CodeOpsColors.textPrimary, fontSize: 15)),
        content: const Text(
          'Are you sure you want to delete all request history?',
          style: TextStyle(color: CodeOpsColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: CodeOpsColors.error,
                foregroundColor: Colors.white),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final teamId = ref.read(selectedTeamIdProvider);
    if (teamId == null) return;
    final api = ref.read(courierApiProvider);
    await api.clearHistory(teamId);
    ref.invalidate(courierHistoryProvider);
  }

  void _onSearchChanged(String value) {
    ref.read(courierHistorySearchProvider.notifier).state = value;
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(courierHistorySearchProvider.notifier).state = '';
    ref.read(courierHistoryMethodFilterProvider.notifier).state = null;
    ref.read(courierHistoryStatusFilterProvider.notifier).state = null;
    ref.read(courierHistoryPageProvider.notifier).state = 0;
  }

  // ── Date grouping ────────────────────────────────────────────────────────

  /// Groups entries into date buckets: Today, Yesterday, or YYYY-MM-DD.
  Map<String, List<RequestHistoryResponse>> _groupByDate(
      List<RequestHistoryResponse> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<RequestHistoryResponse>>{};
    for (final e in entries) {
      final d = e.createdAt ?? DateTime(2000);
      final day = DateTime(d.year, d.month, d.day);
      String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      }
      groups.putIfAbsent(label, () => []).add(e);
    }
    return groups;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(courierHistorySearchProvider);
    final methodFilter = ref.watch(courierHistoryMethodFilterProvider);
    final statusFilter = ref.watch(courierHistoryStatusFilterProvider);
    final selectedId = ref.watch(selectedHistoryEntryProvider);

    // Decide which provider to use.
    final bool isSearching = searchQuery.trim().isNotEmpty;
    final bool hasMethodFilter = methodFilter != null;

    return Container(
      key: const Key('history_list_panel'),
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(right: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        children: [
          // ── Toolbar ──────────────────────────────────────────────────
          _Toolbar(
            key: const Key('history_toolbar'),
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            methodFilter: methodFilter,
            onMethodFilterChanged: (m) {
              ref.read(courierHistoryMethodFilterProvider.notifier).state = m;
              ref.read(courierHistoryPageProvider.notifier).state = 0;
            },
            statusFilter: statusFilter,
            onStatusFilterChanged: (s) {
              ref.read(courierHistoryStatusFilterProvider.notifier).state = s;
            },
            onClearFilters: _clearFilters,
            multiSelect: _multiSelect,
            onMultiSelectToggled: () =>
                setState(() => _multiSelect = !_multiSelect),
            selectedCount: _selected.length,
            onDeleteSelected: _deleteSelected,
            onClearAll: _clearAll,
          ),

          // ── Entry list ───────────────────────────────────────────────
          Expanded(
            child: isSearching
                ? _SearchResults(
                    selectedId: selectedId,
                    multiSelect: _multiSelect,
                    selected: _selected,
                    statusFilter: statusFilter,
                    onTap: _onEntryTap,
                    groupByDate: _groupByDate,
                  )
                : hasMethodFilter
                    ? _MethodFilterResults(
                        selectedId: selectedId,
                        multiSelect: _multiSelect,
                        selected: _selected,
                        statusFilter: statusFilter,
                        onTap: _onEntryTap,
                        groupByDate: _groupByDate,
                      )
                    : _AllHistory(
                        selectedId: selectedId,
                        multiSelect: _multiSelect,
                        selected: _selected,
                        statusFilter: statusFilter,
                        onTap: _onEntryTap,
                        groupByDate: _groupByDate,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final CourierHttpMethod? methodFilter;
  final ValueChanged<CourierHttpMethod?> onMethodFilterChanged;
  final int? statusFilter;
  final ValueChanged<int?> onStatusFilterChanged;
  final VoidCallback onClearFilters;
  final bool multiSelect;
  final VoidCallback onMultiSelectToggled;
  final int selectedCount;
  final VoidCallback onDeleteSelected;
  final VoidCallback onClearAll;

  const _Toolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.methodFilter,
    required this.onMethodFilterChanged,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.onClearFilters,
    required this.multiSelect,
    required this.onMultiSelectToggled,
    required this.selectedCount,
    required this.onDeleteSelected,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        methodFilter != null || statusFilter != null || searchController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: CodeOpsColors.primary),
              const SizedBox(width: 8),
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (multiSelect && selectedCount > 0)
                _SmallButton(
                  key: const Key('delete_selected_button'),
                  label: 'Delete ($selectedCount)',
                  color: CodeOpsColors.error,
                  onTap: onDeleteSelected,
                ),
              const SizedBox(width: 4),
              _SmallButton(
                key: const Key('multi_select_button'),
                label: multiSelect ? 'Done' : 'Select',
                color: multiSelect ? CodeOpsColors.primary : CodeOpsColors.textSecondary,
                onTap: onMultiSelectToggled,
              ),
              const SizedBox(width: 4),
              _SmallButton(
                key: const Key('clear_all_button'),
                label: 'Clear All',
                color: CodeOpsColors.textSecondary,
                onTap: onClearAll,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Search field ─────────────────────────────────────────────
          SizedBox(
            height: 32,
            child: TextField(
              key: const Key('history_search_field'),
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(
                  fontSize: 12, color: CodeOpsColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by URL...',
                hintStyle: const TextStyle(
                    fontSize: 12, color: CodeOpsColors.textTertiary),
                prefixIcon: const Icon(Icons.search,
                    size: 14, color: CodeOpsColors.textTertiary),
                filled: true,
                fillColor: CodeOpsColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Filter chips ─────────────────────────────────────────────
          Row(
            key: const Key('history_filters_row'),
            children: [
              // Method filter dropdown
              _FilterChip(
                key: const Key('method_filter'),
                label: methodFilter?.displayName ?? 'Method',
                isActive: methodFilter != null,
                onTap: () => _showMethodPicker(context),
              ),
              const SizedBox(width: 6),
              // Status filter dropdown
              _FilterChip(
                key: const Key('status_filter'),
                label: statusFilter != null ? '${statusFilter}xx' : 'Status',
                isActive: statusFilter != null,
                onTap: () => _showStatusPicker(context),
              ),
              const Spacer(),
              if (hasFilters)
                InkWell(
                  key: const Key('clear_filters_button'),
                  onTap: onClearFilters,
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Clear filters',
                      style: TextStyle(
                          fontSize: 11, color: CodeOpsColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMethodPicker(BuildContext context) {
    final methods = CourierHttpMethod.values;
    showMenu<CourierHttpMethod?>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      color: CodeOpsColors.surface,
      items: [
        const PopupMenuItem(value: null, child: Text('All Methods')),
        ...methods.map((m) => PopupMenuItem(
              value: m,
              child: Text(m.displayName,
                  style: TextStyle(color: _methodColor(m), fontSize: 13)),
            )),
      ],
    ).then((v) {
      if (v != null || methodFilter != null) onMethodFilterChanged(v);
    });
  }

  void _showStatusPicker(BuildContext context) {
    showMenu<int?>(
      context: context,
      position: const RelativeRect.fromLTRB(160, 100, 0, 0),
      color: CodeOpsColors.surface,
      items: [
        const PopupMenuItem(value: null, child: Text('All Statuses')),
        PopupMenuItem(
            value: 2,
            child: Text('2xx Success',
                style: TextStyle(color: _statusColor(200), fontSize: 13))),
        PopupMenuItem(
            value: 3,
            child: Text('3xx Redirect',
                style: TextStyle(color: _statusColor(301), fontSize: 13))),
        PopupMenuItem(
            value: 4,
            child: Text('4xx Client Error',
                style: TextStyle(color: _statusColor(404), fontSize: 13))),
        PopupMenuItem(
            value: 5,
            child: Text('5xx Server Error',
                style: TextStyle(color: _statusColor(500), fontSize: 13))),
      ],
    ).then((v) {
      if (v != null || statusFilter != null) onStatusFilterChanged(v);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared list builder
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a grouped history list from a flat list of entries.
Widget _buildGroupedList({
  required List<RequestHistoryResponse> entries,
  required Map<String, List<RequestHistoryResponse>> Function(
      List<RequestHistoryResponse>) groupByDate,
  required String? selectedId,
  required bool multiSelect,
  required Set<String> selected,
  required int? statusFilter,
  required void Function(RequestHistoryResponse) onTap,
}) {
  // Apply client-side status filter.
  final filtered = statusFilter != null
      ? entries
          .where((e) =>
              e.responseStatus != null &&
              (e.responseStatus! ~/ 100) == statusFilter)
          .toList()
      : entries;

  if (filtered.isEmpty) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 40, color: CodeOpsColors.textTertiary),
          SizedBox(height: 12),
          Text('No history entries',
              style:
                  TextStyle(fontSize: 13, color: CodeOpsColors.textSecondary)),
        ],
      ),
    );
  }

  final groups = groupByDate(filtered);
  final dateLabels = groups.keys.toList();

  return ListView.builder(
    key: const Key('history_entries_list'),
    padding: const EdgeInsets.symmetric(vertical: 4),
    itemCount: dateLabels.length,
    itemBuilder: (context, gi) {
      final label = dateLabels[gi];
      final items = groups[label]!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Entries for this date
          ...items.map((entry) => _HistoryEntryTile(
                entry: entry,
                isSelected: selectedId == entry.id,
                multiSelect: multiSelect,
                isChecked: selected.contains(entry.id),
                onTap: () => onTap(entry),
              )),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Data-driven list widgets (one per provider)
// ─────────────────────────────────────────────────────────────────────────────

class _AllHistory extends ConsumerWidget {
  final String? selectedId;
  final bool multiSelect;
  final Set<String> selected;
  final int? statusFilter;
  final void Function(RequestHistoryResponse) onTap;
  final Map<String, List<RequestHistoryResponse>> Function(
      List<RequestHistoryResponse>) groupByDate;

  const _AllHistory({
    required this.selectedId,
    required this.multiSelect,
    required this.selected,
    required this.statusFilter,
    required this.onTap,
    required this.groupByDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(courierHistoryProvider);
    return historyAsync.when(
      data: (page) => _buildGroupedList(
        entries: page.content,
        groupByDate: groupByDate,
        selectedId: selectedId,
        multiSelect: multiSelect,
        selected: selected,
        statusFilter: statusFilter,
        onTap: onTap,
      ),
      loading: () => const Center(
          child: CircularProgressIndicator(color: CodeOpsColors.primary)),
      error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(
                  fontSize: 12, color: CodeOpsColors.error))),
    );
  }
}

class _MethodFilterResults extends ConsumerWidget {
  final String? selectedId;
  final bool multiSelect;
  final Set<String> selected;
  final int? statusFilter;
  final void Function(RequestHistoryResponse) onTap;
  final Map<String, List<RequestHistoryResponse>> Function(
      List<RequestHistoryResponse>) groupByDate;

  const _MethodFilterResults({
    required this.selectedId,
    required this.multiSelect,
    required this.selected,
    required this.statusFilter,
    required this.onTap,
    required this.groupByDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(courierHistoryByMethodProvider);
    return historyAsync.when(
      data: (page) => _buildGroupedList(
        entries: page.content,
        groupByDate: groupByDate,
        selectedId: selectedId,
        multiSelect: multiSelect,
        selected: selected,
        statusFilter: statusFilter,
        onTap: onTap,
      ),
      loading: () => const Center(
          child: CircularProgressIndicator(color: CodeOpsColors.primary)),
      error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(
                  fontSize: 12, color: CodeOpsColors.error))),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String? selectedId;
  final bool multiSelect;
  final Set<String> selected;
  final int? statusFilter;
  final void Function(RequestHistoryResponse) onTap;
  final Map<String, List<RequestHistoryResponse>> Function(
      List<RequestHistoryResponse>) groupByDate;

  const _SearchResults({
    required this.selectedId,
    required this.multiSelect,
    required this.selected,
    required this.statusFilter,
    required this.onTap,
    required this.groupByDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(courierHistorySearchResultsProvider);
    return resultsAsync.when(
      data: (entries) => _buildGroupedList(
        entries: entries,
        groupByDate: groupByDate,
        selectedId: selectedId,
        multiSelect: multiSelect,
        selected: selected,
        statusFilter: statusFilter,
        onTap: onTap,
      ),
      loading: () => const Center(
          child: CircularProgressIndicator(color: CodeOpsColors.primary)),
      error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(
                  fontSize: 12, color: CodeOpsColors.error))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry tile
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryEntryTile extends StatelessWidget {
  final RequestHistoryResponse entry;
  final bool isSelected;
  final bool multiSelect;
  final bool isChecked;
  final VoidCallback onTap;

  const _HistoryEntryTile({
    required this.entry,
    required this.isSelected,
    required this.multiSelect,
    required this.isChecked,
    required this.onTap,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '${h == 0 ? 12 : h}:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final method = entry.requestMethod;
    final url = entry.requestUrl ?? '';
    final status = entry.responseStatus;
    final duration = entry.responseTimeMs;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Row(
          children: [
            if (multiSelect) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (_) => onTap(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: CodeOpsColors.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Method badge
            Container(
              key: const Key('method_badge'),
              width: 52,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: _methodColor(method).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method?.displayName ?? '???',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _methodColor(method),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // URL
            Expanded(
              child: Text(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Status code
            if (status != null)
              Text(
                '$status',
                key: const Key('status_code'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(status),
                ),
              ),
            const SizedBox(width: 8),
            // Duration
            if (duration != null)
              Text(
                '${duration}ms',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.textTertiary),
              ),
            const SizedBox(width: 8),
            // Timestamp
            Text(
              _formatTime(entry.createdAt),
              style: const TextStyle(
                  fontSize: 11, color: CodeOpsColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? CodeOpsColors.primary.withValues(alpha: 0.15)
              : CodeOpsColors.background,
          border: Border.all(
            color: isActive ? CodeOpsColors.primary : CodeOpsColors.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textSecondary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: isActive
                  ? CodeOpsColors.primary
                  : CodeOpsColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
