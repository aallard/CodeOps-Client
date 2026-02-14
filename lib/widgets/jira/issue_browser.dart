/// Scrollable list of Jira issues with filter and sort controls.
///
/// Displays issues from [jiraSearchResultsProvider] using [IssueCard]
/// widgets. Supports filtering by status category, priority, and issue
/// type, with sort options for updated, created, priority, and key.
/// Includes pagination via a "Load more" button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/jira_models.dart';
import '../../providers/jira_providers.dart';
import '../../theme/colors.dart';
import '../shared/empty_state.dart';
import '../shared/error_panel.dart';
import 'issue_card.dart';

/// Browsable, filterable list of Jira issues.
///
/// Reads search results from [jiraSearchResultsProvider] and renders
/// them as [IssueCard] widgets. Provides filter controls for status
/// category, priority, and issue type, along with sort options.
/// Supports paginated loading with a "Load more" button.
class IssueBrowser extends ConsumerStatefulWidget {
  /// Called when an issue is selected from the list.
  final ValueChanged<JiraIssueDisplayModel> onIssueSelected;

  /// Creates an [IssueBrowser].
  const IssueBrowser({super.key, required this.onIssueSelected});

  @override
  ConsumerState<IssueBrowser> createState() => _IssueBrowserState();
}

class _IssueBrowserState extends ConsumerState<IssueBrowser> {
  _StatusFilter _statusFilter = _StatusFilter.all;
  String? _priorityFilter;
  String? _issueTypeFilter;
  _SortOption _sortOption = _SortOption.updated;
  final List<JiraIssueDisplayModel> _allIssues = [];
  bool _loadingMore = false;

  @override
  Widget build(BuildContext context) {
    final searchResultAsync = ref.watch(jiraSearchResultsProvider);

    return Column(
      children: [
        // Filter bar
        _buildFilterBar(),
        const SizedBox(height: 12),
        // Issue list
        Expanded(
          child: searchResultAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: CodeOpsColors.primary),
            ),
            error: (error, _) => ErrorPanel.fromException(
              error,
              onRetry: () => ref.invalidate(jiraSearchResultsProvider),
            ),
            data: (result) {
              if (result == null) {
                return const EmptyState(
                  icon: Icons.search,
                  title: 'Search Jira Issues',
                  subtitle:
                      'Enter a JQL query or select a preset filter to browse issues.',
                );
              }

              _syncIssues(result);
              final filtered = _applyFilters(_allIssues);
              final sorted = _applySort(filtered);

              if (sorted.isEmpty) {
                return const EmptyState(
                  icon: Icons.filter_list_off,
                  title: 'No Matching Issues',
                  subtitle:
                      'Try adjusting your filters or broadening your search.',
                );
              }

              final hasMore =
                  result.startAt + result.issues.length < result.total;

              return Column(
                children: [
                  // Result count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(
                          '${sorted.length} of ${result.total} issues',
                          style: const TextStyle(
                            color: CodeOpsColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Sorted by ${_sortOption.label}',
                          style: const TextStyle(
                            color: CodeOpsColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Issue list
                  Expanded(
                    child: ListView.separated(
                      itemCount: sorted.length + (hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == sorted.length) {
                          return _buildLoadMoreButton(result);
                        }
                        return IssueCard(
                          issue: sorted[index],
                          onTap: () => widget.onIssueSelected(sorted[index]),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Syncs loaded issues from the search result into the accumulator.
  ///
  /// On the first page (startAt == 0) the list is replaced.
  /// On subsequent pages, new issues are appended.
  void _syncIssues(JiraSearchResult result) {
    final displayModels = result.issues.map(_toDisplayModel).toList();
    if (result.startAt == 0) {
      _allIssues
        ..clear()
        ..addAll(displayModels);
    } else {
      // Avoid duplicates when pagination overlaps.
      final existingKeys = _allIssues.map((i) => i.key).toSet();
      for (final model in displayModels) {
        if (!existingKeys.contains(model.key)) {
          _allIssues.add(model);
        }
      }
    }
  }

  /// Converts a [JiraIssue] to a [JiraIssueDisplayModel].
  JiraIssueDisplayModel _toDisplayModel(JiraIssue issue) {
    return JiraIssueDisplayModel(
      key: issue.key,
      summary: issue.fields.summary,
      statusName: issue.fields.status.name,
      statusCategoryKey: issue.fields.status.statusCategory?.key,
      priorityName: issue.fields.priority?.name,
      priorityIconUrl: issue.fields.priority?.iconUrl,
      assigneeName: issue.fields.assignee?.displayName,
      assigneeAvatarUrl: issue.fields.assignee?.avatarUrls?.x24,
      issuetypeName: issue.fields.issuetype.name,
      issuetypeIconUrl: issue.fields.issuetype.iconUrl,
      commentCount: issue.fields.comment?.total ?? 0,
      attachmentCount: issue.fields.attachment?.length ?? 0,
      linkCount: issue.fields.issuelinks?.length ?? 0,
      created: issue.fields.created != null
          ? DateTime.tryParse(issue.fields.created!)
          : null,
      updated: issue.fields.updated != null
          ? DateTime.tryParse(issue.fields.updated!)
          : null,
    );
  }

  /// Applies local filters to the issue list.
  List<JiraIssueDisplayModel> _applyFilters(
      List<JiraIssueDisplayModel> issues) {
    var filtered = issues;

    // Status category filter
    if (_statusFilter != _StatusFilter.all) {
      final categoryKey = switch (_statusFilter) {
        _StatusFilter.toDo => 'new',
        _StatusFilter.inProgress => 'indeterminate',
        _StatusFilter.done => 'done',
        _StatusFilter.all => '',
      };
      filtered = filtered
          .where((i) => i.statusCategoryKey == categoryKey)
          .toList();
    }

    // Priority filter
    if (_priorityFilter != null) {
      filtered = filtered
          .where((i) =>
              i.priorityName?.toLowerCase() == _priorityFilter!.toLowerCase())
          .toList();
    }

    // Issue type filter
    if (_issueTypeFilter != null) {
      filtered = filtered
          .where((i) =>
              i.issuetypeName?.toLowerCase() ==
              _issueTypeFilter!.toLowerCase())
          .toList();
    }

    return filtered;
  }

  /// Applies the selected sort option to the issue list.
  List<JiraIssueDisplayModel> _applySort(List<JiraIssueDisplayModel> issues) {
    final sorted = List<JiraIssueDisplayModel>.from(issues);
    switch (_sortOption) {
      case _SortOption.updated:
        sorted.sort((a, b) =>
            (b.updated ?? DateTime(2000)).compareTo(a.updated ?? DateTime(2000)));
      case _SortOption.created:
        sorted.sort((a, b) =>
            (b.created ?? DateTime(2000)).compareTo(a.created ?? DateTime(2000)));
      case _SortOption.priority:
        sorted.sort((a, b) =>
            _priorityRank(a.priorityName)
                .compareTo(_priorityRank(b.priorityName)));
      case _SortOption.key:
        sorted.sort((a, b) => a.key.compareTo(b.key));
    }
    return sorted;
  }

  /// Returns a numeric rank for priority sorting (lower = higher priority).
  int _priorityRank(String? priorityName) {
    return switch (priorityName?.toLowerCase()) {
      'highest' => 0,
      'high' => 1,
      'medium' => 2,
      'low' => 3,
      'lowest' => 4,
      _ => 5,
    };
  }

  /// Builds the filter and sort control bar.
  Widget _buildFilterBar() {
    // Collect unique priorities and issue types from loaded issues.
    final priorities = _allIssues
        .map((i) => i.priorityName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final issueTypes = _allIssues
        .map((i) => i.issuetypeName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Status category filter
        _buildSegmentedFilter(),
        // Priority dropdown
        _buildDropdownFilter(
          label: 'Priority',
          value: _priorityFilter,
          items: priorities,
          onChanged: (v) => setState(() => _priorityFilter = v),
        ),
        // Issue type dropdown
        _buildDropdownFilter(
          label: 'Type',
          value: _issueTypeFilter,
          items: issueTypes,
          onChanged: (v) => setState(() => _issueTypeFilter = v),
        ),
        // Sort dropdown
        _buildSortDropdown(),
      ],
    );
  }

  /// Builds the status category segmented filter buttons.
  Widget _buildSegmentedFilter() {
    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _StatusFilter.values.map((filter) {
          final isActive = _statusFilter == filter;
          return InkWell(
            onTap: () => setState(() => _statusFilter = filter),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? CodeOpsColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  color: isActive
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a dropdown filter chip.
  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: value != null
            ? CodeOpsColors.primary.withValues(alpha: 0.15)
            : CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value != null ? CodeOpsColors.primary : CodeOpsColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 12,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down,
              size: 18, color: CodeOpsColors.textTertiary),
          dropdownColor: CodeOpsColors.surfaceVariant,
          style: const TextStyle(
            color: CodeOpsColors.textPrimary,
            fontSize: 12,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All $label',
                style: const TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            ...items.map((item) => DropdownMenuItem<String?>(
                  value: item,
                  child: Text(item),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Builds the sort option dropdown.
  Widget _buildSortDropdown() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SortOption>(
          value: _sortOption,
          icon: const Icon(Icons.arrow_drop_down,
              size: 18, color: CodeOpsColors.textTertiary),
          dropdownColor: CodeOpsColors.surfaceVariant,
          style: const TextStyle(
            color: CodeOpsColors.textPrimary,
            fontSize: 12,
          ),
          items: _SortOption.values
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, size: 14,
                            color: CodeOpsColors.textTertiary),
                        const SizedBox(width: 6),
                        Text(option.label),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _sortOption = v);
          },
        ),
      ),
    );
  }

  /// Builds the "Load more" button for pagination.
  Widget _buildLoadMoreButton(JiraSearchResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _loadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CodeOpsColors.primary,
                ),
              )
            : OutlinedButton.icon(
                onPressed: () => _loadMore(result),
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(
                  'Load more (${result.total - _allIssues.length} remaining)',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CodeOpsColors.textSecondary,
                  side: const BorderSide(color: CodeOpsColors.border),
                ),
              ),
      ),
    );
  }

  /// Loads the next page of results.
  Future<void> _loadMore(JiraSearchResult currentResult) async {
    setState(() => _loadingMore = true);
    final nextStartAt = currentResult.startAt + currentResult.issues.length;
    ref.read(jiraSearchStartAtProvider.notifier).state = nextStartAt;
    // The provider will automatically refetch.
    // Wait a tick for the async to start, then let the when-handler manage UI.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _loadingMore = false);
  }
}

/// Status category filter options.
enum _StatusFilter {
  /// Show all statuses.
  all('All'),

  /// Show only "To Do" status category.
  toDo('To Do'),

  /// Show only "In Progress" status category.
  inProgress('In Progress'),

  /// Show only "Done" status category.
  done('Done');

  /// Creates a [_StatusFilter] with the given display label.
  const _StatusFilter(this.label);

  /// Display label for the filter.
  final String label;
}

/// Sort option definitions.
enum _SortOption {
  /// Sort by last updated (most recent first).
  updated('Updated'),

  /// Sort by creation date (most recent first).
  created('Created'),

  /// Sort by priority (highest first).
  priority('Priority'),

  /// Sort by issue key (alphabetical).
  key('Key');

  /// Creates a [_SortOption] with the given display label.
  const _SortOption(this.label);

  /// Display label for the sort option.
  final String label;
}
