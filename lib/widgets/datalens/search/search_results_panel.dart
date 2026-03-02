/// Dockable search results panel for the DataLens module.
///
/// Displays persistent search results in a table layout with sortable
/// columns, export to CSV, clear, and pin functionality. Supports all
/// three search modes: metadata, data, and DDL results.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/datalens_search_models.dart';
import '../../../theme/colors.dart';

/// Panel displaying persistent search results in a columnar layout.
///
/// Features: sortable columns, export to CSV, clear results, and pin
/// results to keep them visible while navigating. Reads results from
/// the search result providers.
class SearchResultsPanel extends ConsumerStatefulWidget {
  /// Metadata search results to display.
  final List<MetadataSearchResult> metadataResults;

  /// Data search results to display.
  final List<DataSearchResult> dataResults;

  /// DDL search results to display.
  final List<DdlSearchResult> ddlResults;

  /// Active search mode determining which results to show.
  final SearchMode mode;

  /// Callback to clear all results.
  final VoidCallback? onClear;

  /// Creates a [SearchResultsPanel].
  const SearchResultsPanel({
    super.key,
    this.metadataResults = const [],
    this.dataResults = const [],
    this.ddlResults = const [],
    this.mode = SearchMode.metadata,
    this.onClear,
  });

  @override
  ConsumerState<SearchResultsPanel> createState() =>
      _SearchResultsPanelState();
}

class _SearchResultsPanelState extends ConsumerState<SearchResultsPanel> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _pinned = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.surface,
      child: Column(
        children: [
          _buildToolbar(),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final count = _resultCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          const Icon(Icons.search, size: 14, color: CodeOpsColors.textSecondary),
          const SizedBox(width: 6),
          const Text(
            'Search Results',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0)
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
          const Spacer(),
          // Pin toggle.
          IconButton(
            icon: Icon(
              _pinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 14,
            ),
            color: _pinned
                ? CodeOpsColors.primary
                : CodeOpsColors.textSecondary,
            tooltip: _pinned ? 'Unpin results' : 'Pin results',
            onPressed: () => setState(() => _pinned = !_pinned),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          // Export CSV.
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 14),
            color: CodeOpsColors.textSecondary,
            tooltip: 'Export to CSV',
            onPressed: count > 0 ? _exportCsv : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          // Clear.
          IconButton(
            icon: const Icon(Icons.clear_all, size: 14),
            color: CodeOpsColors.textSecondary,
            tooltip: 'Clear results',
            onPressed: widget.onClear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  int get _resultCount => switch (widget.mode) {
        SearchMode.metadata => widget.metadataResults.length,
        SearchMode.data =>
          widget.dataResults.fold<int>(0, (s, r) => s + r.rowCount),
        SearchMode.ddl => widget.ddlResults.length,
      };

  Widget _buildContent() {
    if (_resultCount == 0) {
      return const Center(
        child: Text(
          'No search results',
          style: TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary),
        ),
      );
    }

    return switch (widget.mode) {
      SearchMode.metadata => _buildMetadataTable(),
      SearchMode.data => _buildDataTable(),
      SearchMode.ddl => _buildDdlTable(),
    };
  }

  Widget _buildMetadataTable() {
    final rows = List<MetadataSearchResult>.from(widget.metadataResults);
    _sortMetadata(rows);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(CodeOpsColors.surface),
          columnSpacing: 16,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingTextStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textSecondary,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 11,
            color: CodeOpsColors.textPrimary,
          ),
          columns: [
            DataColumn(label: const Text('Type'), onSort: _onSort),
            DataColumn(label: const Text('Schema'), onSort: _onSort),
            DataColumn(label: const Text('Object'), onSort: _onSort),
            DataColumn(label: const Text('Parent'), onSort: _onSort),
          ],
          rows: rows.map((r) => DataRow(cells: [
                DataCell(Text(r.objectType.label)),
                DataCell(Text(r.schema)),
                DataCell(Text(r.objectName)),
                DataCell(Text(r.parentName ?? '')),
              ])).toList(),
        ),
      ),
    );
  }

  void _sortMetadata(List<MetadataSearchResult> rows) {
    rows.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.objectType.label.compareTo(b.objectType.label);
        case 1:
          cmp = a.schema.compareTo(b.schema);
        case 2:
          cmp = a.objectName.compareTo(b.objectName);
        case 3:
          cmp = (a.parentName ?? '').compareTo(b.parentName ?? '');
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(CodeOpsColors.surface),
          columnSpacing: 16,
          headingTextStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textSecondary,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 11,
            color: CodeOpsColors.textPrimary,
          ),
          columns: const [
            DataColumn(label: Text('Schema')),
            DataColumn(label: Text('Table')),
            DataColumn(label: Text('Column')),
            DataColumn(label: Text('Rows'), numeric: true),
          ],
          rows: widget.dataResults
              .map((r) => DataRow(cells: [
                    DataCell(Text(r.schema)),
                    DataCell(Text(r.table)),
                    DataCell(Text(r.column)),
                    DataCell(Text(r.rowCount.toString())),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDdlTable() {
    final rows = List<DdlSearchResult>.from(widget.ddlResults);
    _sortDdl(rows);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(CodeOpsColors.surface),
          columnSpacing: 16,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingTextStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textSecondary,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 11,
            color: CodeOpsColors.textPrimary,
          ),
          columns: [
            DataColumn(label: const Text('Type'), onSort: _onSort),
            DataColumn(label: const Text('Schema'), onSort: _onSort),
            DataColumn(label: const Text('Object'), onSort: _onSort),
            DataColumn(label: const Text('Match Context'), onSort: _onSort),
          ],
          rows: rows.map((r) => DataRow(cells: [
                DataCell(Text(r.objectType.label)),
                DataCell(Text(r.schema)),
                DataCell(Text(r.objectName)),
                DataCell(SizedBox(
                  width: 300,
                  child: Text(
                    r.ddlSnippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                )),
              ])).toList(),
        ),
      ),
    );
  }

  void _sortDdl(List<DdlSearchResult> rows) {
    rows.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.objectType.label.compareTo(b.objectType.label);
        case 1:
          cmp = a.schema.compareTo(b.schema);
        case 2:
          cmp = a.objectName.compareTo(b.objectName);
        case 3:
          cmp = a.ddlSnippet.compareTo(b.ddlSnippet);
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _exportCsv() {
    final buffer = StringBuffer();

    switch (widget.mode) {
      case SearchMode.metadata:
        buffer.writeln('Type,Schema,Object,Parent,Data Type');
        for (final r in widget.metadataResults) {
          buffer.writeln(
            '${_csvEscape(r.objectType.label)},${_csvEscape(r.schema)},'
            '${_csvEscape(r.objectName)},${_csvEscape(r.parentName ?? '')},'
            '${_csvEscape(r.dataType ?? '')}',
          );
        }

      case SearchMode.data:
        buffer.writeln('Schema,Table,Column,Row Count');
        for (final r in widget.dataResults) {
          buffer.writeln(
            '${_csvEscape(r.schema)},${_csvEscape(r.table)},'
            '${_csvEscape(r.column)},${r.rowCount}',
          );
        }

      case SearchMode.ddl:
        buffer.writeln('Type,Schema,Object,Line,Snippet');
        for (final r in widget.ddlResults) {
          buffer.writeln(
            '${_csvEscape(r.objectType.label)},${_csvEscape(r.schema)},'
            '${_csvEscape(r.objectName)},${r.matchLine},'
            '${_csvEscape(r.ddlSnippet)}',
          );
        }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    }
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
