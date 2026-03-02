/// Full-featured search dialog for the DataLens module.
///
/// Supports three search modes: Metadata (object names), Data (row values),
/// and DDL (object definitions). Provides schema filtering, object type
/// chips, case-sensitive toggle, regex toggle (data mode), and grouped
/// results with click-to-navigate.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/datalens_search_models.dart';
import '../../../providers/datalens_providers.dart';
import '../../../theme/colors.dart';

/// Dialog for searching database metadata, data, and DDL.
///
/// Opened via the toolbar search icon or Ctrl+Shift+F. Provides a search
/// bar with mode tabs, filter options, and a scrollable results area.
class DatalensSearchDialog extends ConsumerStatefulWidget {
  /// Connection ID to search against.
  final String? connectionId;

  /// Creates a [DatalensSearchDialog].
  const DatalensSearchDialog({super.key, this.connectionId});

  @override
  ConsumerState<DatalensSearchDialog> createState() =>
      _DatalensSearchDialogState();
}

class _DatalensSearchDialogState extends ConsumerState<DatalensSearchDialog>
    with SingleTickerProviderStateMixin {
  final _queryController = TextEditingController();
  late TabController _tabController;

  SearchMode _mode = SearchMode.metadata;
  String? _schemaFilter;
  bool _caseSensitive = false;
  bool _regex = false;
  final Set<MetadataObjectType> _selectedTypes = {};

  // Results
  List<MetadataSearchResult> _metadataResults = [];
  List<DataSearchResult> _dataResults = [];
  List<DdlSearchResult> _ddlResults = [];
  bool _searching = false;
  String? _error;
  DataSearchProgress? _progress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _mode = SearchMode.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty || widget.connectionId == null) return;

    setState(() {
      _searching = true;
      _error = null;
      _progress = null;
    });

    try {
      final service = ref.read(datalensSearchServiceProvider);

      switch (_mode) {
        case SearchMode.metadata:
          final results = await service.searchMetadata(
            connectionId: widget.connectionId!,
            query: query,
            schema: _schemaFilter,
            objectTypes:
                _selectedTypes.isNotEmpty ? _selectedTypes.toList() : null,
          );
          if (mounted) setState(() => _metadataResults = results);

        case SearchMode.data:
          final schema = _schemaFilter ??
              ref.read(selectedSchemaProvider) ??
              'public';
          final results = await service.searchData(
            connectionId: widget.connectionId!,
            query: query,
            schema: schema,
            caseSensitive: _caseSensitive,
            regex: _regex,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
          if (mounted) setState(() => _dataResults = results);

        case SearchMode.ddl:
          final results = await service.searchDdl(
            connectionId: widget.connectionId!,
            query: query,
            schema: _schemaFilter,
            objectTypes:
                _selectedTypes.isNotEmpty ? _selectedTypes.toList() : null,
            caseSensitive: _caseSensitive,
          );
          if (mounted) setState(() => _ddlResults = results);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 720,
        height: 560,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildModeTabs(),
            _buildOptionsRow(),
            const Divider(height: 1, color: CodeOpsColors.border),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: CodeOpsColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Search Database',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: CodeOpsColors.textSecondary,
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: _queryController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: _searchHint,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textTertiary,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 16,
                      color: CodeOpsColors.textTertiary),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: CodeOpsColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.primary),
                  ),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CodeOpsColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: _searching ? null : _search,
              child: _searching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Search', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  String get _searchHint => switch (_mode) {
        SearchMode.metadata => 'Search table, column, function names...',
        SearchMode.data => 'Search row data across tables...',
        SearchMode.ddl => 'Search DDL / object definitions...',
      };

  Widget _buildModeTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: CodeOpsColors.primary,
        unselectedLabelColor: CodeOpsColors.textSecondary,
        indicatorColor: CodeOpsColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: const [
          Tab(text: 'Metadata', height: 32),
          Tab(text: 'Data', height: 32),
          Tab(text: 'DDL', height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionsRow() {
    final schemasAsync = ref.watch(datalensSchemasProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: schema filter + toggles.
          Row(
            children: [
              // Schema dropdown.
              SizedBox(
                width: 160,
                height: 28,
                child: schemasAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (schemas) => DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _schemaFilter,
                      isExpanded: true,
                      hint: const Text(
                        'All schemas',
                        style: TextStyle(
                          fontSize: 11,
                          color: CodeOpsColors.textTertiary,
                        ),
                      ),
                      icon: const Icon(Icons.expand_more, size: 14,
                          color: CodeOpsColors.textTertiary),
                      dropdownColor: CodeOpsColors.surfaceVariant,
                      style: const TextStyle(
                        fontSize: 11,
                        color: CodeOpsColors.textPrimary,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All schemas',
                              style: TextStyle(fontSize: 11)),
                        ),
                        ...schemas.map((s) => DropdownMenuItem<String?>(
                              value: s.name,
                              child: Text(s.name ?? '',
                                  style: const TextStyle(fontSize: 11)),
                            )),
                      ],
                      onChanged: (v) => setState(() => _schemaFilter = v),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Case sensitive toggle.
              _ToggleChip(
                label: 'Aa',
                tooltip: 'Case sensitive',
                selected: _caseSensitive,
                onSelected: (v) => setState(() => _caseSensitive = v),
              ),
              const SizedBox(width: 6),
              // Regex toggle (data mode only).
              if (_mode == SearchMode.data)
                _ToggleChip(
                  label: '.*',
                  tooltip: 'Regex',
                  selected: _regex,
                  onSelected: (v) => setState(() => _regex = v),
                ),
            ],
          ),
          // Second row: object type chips (metadata and DDL modes).
          if (_mode == SearchMode.metadata || _mode == SearchMode.ddl)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _objectTypesForMode.map((type) {
                  final selected = _selectedTypes.contains(type);
                  return FilterChip(
                    label: Text(
                      type.shortLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? Colors.white
                            : CodeOpsColors.textSecondary,
                      ),
                    ),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedTypes.add(type);
                        } else {
                          _selectedTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: CodeOpsColors.primary,
                    backgroundColor: CodeOpsColors.surfaceVariant,
                    side: BorderSide(
                      color: selected
                          ? CodeOpsColors.primary
                          : CodeOpsColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  List<MetadataObjectType> get _objectTypesForMode {
    if (_mode == SearchMode.ddl) {
      return [
        MetadataObjectType.table,
        MetadataObjectType.view,
        MetadataObjectType.function_,
        MetadataObjectType.trigger,
      ];
    }
    return [
      MetadataObjectType.table,
      MetadataObjectType.view,
      MetadataObjectType.column,
      MetadataObjectType.function_,
      MetadataObjectType.index_,
      MetadataObjectType.constraint,
      MetadataObjectType.trigger,
    ];
  }

  Widget _buildResults() {
    if (_searching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: CodeOpsColors.primary),
            if (_progress != null) ...[
              const SizedBox(height: 12),
              Text(
                'Searching table ${_progress!.currentTable} of ${_progress!.totalTables}'
                '${_progress!.currentTableName != null ? ' (${_progress!.currentTableName})' : ''}',
                style: const TextStyle(
                  fontSize: 11,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: CodeOpsColors.error, size: 32),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return switch (_mode) {
      SearchMode.metadata => _buildMetadataResults(),
      SearchMode.data => _buildDataResults(),
      SearchMode.ddl => _buildDdlResults(),
    };
  }

  Widget _buildMetadataResults() {
    if (_metadataResults.isEmpty) {
      return _buildNoResults();
    }

    // Group by object type.
    final grouped = <MetadataObjectType, List<MetadataSearchResult>>{};
    for (final r in _metadataResults) {
      grouped.putIfAbsent(r.objectType, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildResultCount(_metadataResults.length),
        for (final entry in grouped.entries) ...[
          _buildGroupHeader(
            entry.key.label,
            _iconForType(entry.key),
            entry.value.length,
          ),
          for (final r in entry.value)
            _MetadataResultTile(
              result: r,
              onTap: () => _navigateToObject(r),
            ),
        ],
      ],
    );
  }

  Widget _buildDataResults() {
    if (_dataResults.isEmpty) {
      return _buildNoResults();
    }

    final totalRows = _dataResults.fold<int>(0, (s, r) => s + r.rowCount);

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildResultCount(totalRows, label: 'matching rows'),
        for (final r in _dataResults) ...[
          _buildGroupHeader(
            '${r.schema}.${r.table}.${r.column}',
            Icons.table_chart_outlined,
            r.rowCount,
          ),
          for (final row in r.sampleRows)
            _DataResultTile(row: row),
        ],
      ],
    );
  }

  Widget _buildDdlResults() {
    if (_ddlResults.isEmpty) {
      return _buildNoResults();
    }

    // Group by object type.
    final grouped = <MetadataObjectType, List<DdlSearchResult>>{};
    for (final r in _ddlResults) {
      grouped.putIfAbsent(r.objectType, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildResultCount(_ddlResults.length),
        for (final entry in grouped.entries) ...[
          _buildGroupHeader(
            entry.key.label,
            _iconForType(entry.key),
            entry.value.length,
          ),
          for (final r in entry.value)
            _DdlResultTile(result: r),
        ],
      ],
    );
  }

  Widget _buildNoResults() {
    final hasSearched = _metadataResults.isNotEmpty ||
        _dataResults.isNotEmpty ||
        _ddlResults.isNotEmpty ||
        _queryController.text.isNotEmpty;

    if (!hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 40,
                color: CodeOpsColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'Enter a search term and press Enter',
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _modeSuggestion,
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 32,
              color: CodeOpsColors.textTertiary),
          const SizedBox(height: 8),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term or change filters',
            style: const TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  String get _modeSuggestion => switch (_mode) {
        SearchMode.metadata =>
          'Searches table, view, column, function, index names',
        SearchMode.data =>
          'Searches actual row data in text/varchar columns',
        SearchMode.ddl =>
          'Searches CREATE statements and object definitions',
      };

  Widget _buildResultCount(int count, {String label = 'results'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$count $label',
        style: const TextStyle(
          fontSize: 11,
          color: CodeOpsColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String label, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: CodeOpsColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: CodeOpsColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(MetadataObjectType type) {
    return switch (type) {
      MetadataObjectType.table => Icons.table_chart_outlined,
      MetadataObjectType.view => Icons.visibility_outlined,
      MetadataObjectType.column => Icons.view_column_outlined,
      MetadataObjectType.function_ => Icons.functions_outlined,
      MetadataObjectType.procedure => Icons.functions_outlined,
      MetadataObjectType.sequence => Icons.format_list_numbered_outlined,
      MetadataObjectType.index_ => Icons.sort_outlined,
      MetadataObjectType.constraint => Icons.link_outlined,
      MetadataObjectType.trigger => Icons.bolt_outlined,
      MetadataObjectType.schema => Icons.folder_outlined,
    };
  }

  void _navigateToObject(MetadataSearchResult result) {
    // Set the schema and table selection to navigate to the object.
    if (result.schema.isNotEmpty) {
      ref.read(selectedSchemaProvider.notifier).state = result.schema;
    }
    if (result.objectType == MetadataObjectType.table ||
        result.objectType == MetadataObjectType.view) {
      ref.read(selectedTableProvider.notifier).state = result.objectName;
    } else if (result.parentName != null) {
      ref.read(selectedTableProvider.notifier).state = result.parentName;
    }
    Navigator.of(context).pop();
  }
}

// ---------------------------------------------------------------------------
// Toggle Chip
// ---------------------------------------------------------------------------

class _ToggleChip extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _ToggleChip({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => onSelected(!selected),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: selected
                ? CodeOpsColors.primary.withValues(alpha: 0.2)
                : CodeOpsColors.surfaceVariant,
            border: Border.all(
              color: selected ? CodeOpsColors.primary : CodeOpsColors.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: selected ? CodeOpsColors.primary : CodeOpsColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result Tiles
// ---------------------------------------------------------------------------

class _MetadataResultTile extends StatelessWidget {
  final MetadataSearchResult result;
  final VoidCallback onTap;

  const _MetadataResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final path = result.parentName != null
        ? '${result.schema}.${result.parentName}.${result.objectName}'
        : '${result.schema}.${result.objectName}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                path,
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (result.dataType != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: CodeOpsColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  result.dataType!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DataResultTile extends StatelessWidget {
  final DataSearchRow row;

  const _DataResultTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
      child: Text(
        row.matchedValue,
        style: const TextStyle(
          fontSize: 11,
          color: CodeOpsColors.textPrimary,
          fontFamily: 'monospace',
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DdlResultTile extends StatelessWidget {
  final DdlSearchResult result;

  const _DdlResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              Text(
                '${result.schema}.${result.objectName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'line ${result.matchLine}',
                style: const TextStyle(
                  fontSize: 10,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 2),
            child: Text(
              result.ddlSnippet,
              style: const TextStyle(
                fontSize: 10,
                color: CodeOpsColors.textSecondary,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
