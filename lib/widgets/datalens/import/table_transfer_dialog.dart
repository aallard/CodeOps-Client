/// Table-to-table transfer dialog for DataLens.
///
/// Allows the user to select source and target connection/schema/table,
/// configure column mappings, set a WHERE filter, choose transfer options,
/// and execute with progress tracking and result display.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/datalens_enums.dart';
import '../../../models/datalens_models.dart';
import '../../../providers/datalens_providers.dart';
import '../../../services/datalens/import/csv_import_service.dart';
import '../../../services/datalens/import/table_transfer_service.dart';
import '../../../theme/colors.dart';

/// Dialog for transferring data between database tables.
///
/// Supports same-connection and cross-connection transfers with column
/// mapping, WHERE filtering, batch processing, and optional target table
/// creation or truncation.
class TableTransferDialog extends ConsumerStatefulWidget {
  /// Optional pre-populated source.
  final String? sourceConnectionId;
  final String? sourceSchema;
  final String? sourceTable;

  /// Creates a [TableTransferDialog].
  const TableTransferDialog({
    super.key,
    this.sourceConnectionId,
    this.sourceSchema,
    this.sourceTable,
  });

  @override
  ConsumerState<TableTransferDialog> createState() =>
      _TableTransferDialogState();
}

class _TableTransferDialogState extends ConsumerState<TableTransferDialog> {
  // Source
  String? _srcConnectionId;
  String? _srcSchema;
  String? _srcTable;
  List<SchemaInfo> _srcSchemas = [];
  List<TableInfo> _srcTables = [];
  List<ColumnInfo> _srcColumns = [];

  // Target
  String? _tgtConnectionId;
  String? _tgtSchema;
  String? _tgtTable;
  bool _createNewTarget = false;
  String _newTargetName = '';
  List<SchemaInfo> _tgtSchemas = [];
  List<TableInfo> _tgtTables = [];
  List<ColumnInfo> _tgtColumns = [];

  // Mapping
  List<ColumnMapping> _mappings = [];

  // Options
  String _whereClause = '';
  int _batchSize = 1000;
  bool _createTargetIfNotExists = false;
  bool _truncateTarget = false;

  // Execution
  bool _executing = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;
  TransferResult? _result;
  int? _sourceRowCount;

  @override
  void initState() {
    super.initState();
    _srcConnectionId = widget.sourceConnectionId;
    _srcSchema = widget.sourceSchema;
    _srcTable = widget.sourceTable;

    if (_srcConnectionId != null) _loadSrcSchemas();
    if (_srcSchema != null) _loadSrcTables();
    if (_srcTable != null) _loadSrcColumns();
  }

  // -------------------------------------------------------------------------
  // Data Loading
  // -------------------------------------------------------------------------

  Future<void> _loadSrcSchemas() async {
    if (_srcConnectionId == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final schemas = await service.getSchemas(_srcConnectionId!);
      if (mounted) setState(() => _srcSchemas = schemas);
    } catch (_) {}
  }

  Future<void> _loadSrcTables() async {
    if (_srcConnectionId == null || _srcSchema == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final tables = await service.getTables(_srcConnectionId!, _srcSchema!);
      if (mounted) setState(() => _srcTables = tables);
    } catch (_) {}
  }

  Future<void> _loadSrcColumns() async {
    if (_srcConnectionId == null ||
        _srcSchema == null ||
        _srcTable == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final cols = await service.getColumns(
          _srcConnectionId!, _srcSchema!, _srcTable!);
      if (mounted) {
        setState(() => _srcColumns = cols);
        _autoMap();
      }
      _loadSourceRowCount();
    } catch (_) {}
  }

  Future<void> _loadTgtSchemas() async {
    if (_tgtConnectionId == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final schemas = await service.getSchemas(_tgtConnectionId!);
      if (mounted) setState(() => _tgtSchemas = schemas);
    } catch (_) {}
  }

  Future<void> _loadTgtTables() async {
    if (_tgtConnectionId == null || _tgtSchema == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final tables = await service.getTables(_tgtConnectionId!, _tgtSchema!);
      if (mounted) setState(() => _tgtTables = tables);
    } catch (_) {}
  }

  Future<void> _loadTgtColumns() async {
    if (_tgtConnectionId == null ||
        _tgtSchema == null ||
        _tgtTable == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final cols = await service.getColumns(
          _tgtConnectionId!, _tgtSchema!, _tgtTable!);
      if (mounted) {
        setState(() => _tgtColumns = cols);
        _autoMap();
      }
    } catch (_) {}
  }

  Future<void> _loadSourceRowCount() async {
    if (_srcConnectionId == null ||
        _srcSchema == null ||
        _srcTable == null) return;
    try {
      final queryService = ref.read(datalensQueryServiceProvider);
      final count = await queryService.countRows(
        _srcConnectionId!,
        _srcSchema!,
        _srcTable!,
        whereClause:
            _whereClause.isNotEmpty ? _whereClause : null,
      );
      if (mounted) setState(() => _sourceRowCount = count);
    } catch (_) {}
  }

  void _autoMap() {
    if (_srcColumns.isEmpty) return;

    if (_createNewTarget) {
      _mappings = _srcColumns
          .where((c) => c.columnName != null)
          .map((c) =>
              ColumnMapping(csvColumn: c.columnName!, dbColumn: c.columnName))
          .toList();
      return;
    }

    if (_tgtColumns.isEmpty) return;

    final tgtMap = <String, String>{};
    for (final col in _tgtColumns) {
      final name = col.columnName ?? '';
      if (name.isNotEmpty) tgtMap[name.toLowerCase()] = name;
    }

    _mappings = _srcColumns
        .where((c) => c.columnName != null)
        .map((c) {
      final match = tgtMap[c.columnName!.toLowerCase()];
      return ColumnMapping(csvColumn: c.columnName!, dbColumn: match);
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Execute
  // -------------------------------------------------------------------------

  Future<void> _execute() async {
    if (_srcConnectionId == null ||
        _srcSchema == null ||
        _srcTable == null ||
        _tgtConnectionId == null ||
        _tgtSchema == null) return;

    final tgtTable =
        _createNewTarget ? _newTargetName : _tgtTable;
    if (tgtTable == null || tgtTable.isEmpty) return;

    setState(() {
      _executing = true;
      _result = null;
      _progressCurrent = 0;
      _progressTotal = 0;
    });

    try {
      final service = ref.read(tableTransferServiceProvider);
      final result = await service.transfer(
        sourceConnectionId: _srcConnectionId!,
        sourceSchema: _srcSchema!,
        sourceTable: _srcTable!,
        targetConnectionId: _tgtConnectionId!,
        targetSchema: _tgtSchema!,
        targetTable: tgtTable,
        columnMappings: _mappings.where((m) => m.dbColumn != null).toList(),
        whereClause: _whereClause.isNotEmpty ? _whereClause : null,
        batchSize: _batchSize,
        createTargetIfNotExists: _createNewTarget || _createTargetIfNotExists,
        truncateTarget: _truncateTarget,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _progressCurrent = current;
              _progressTotal = total;
            });
          }
        },
      );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        setState(() => _result = TransferResult(
              rowsFailed: 1,
              errors: [ImportError(rowNumber: 0, message: e.toString())],
            ));
      }
    } finally {
      if (mounted) setState(() => _executing = false);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      child: SizedBox(
        width: 680,
        height: 560,
        child: Column(
          children: [
            _buildTitleBar(),
            const Divider(height: 1, color: CodeOpsColors.border),
            Expanded(child: _buildBody()),
            const Divider(height: 1, color: CodeOpsColors.border),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, size: 18, color: CodeOpsColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Table Transfer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: CodeOpsColors.textTertiary,
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final connectionsAsync = ref.watch(datalensConnectionsProvider);

    return connectionsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              color: CodeOpsColors.primary, strokeWidth: 2)),
      error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: CodeOpsColors.error))),
      data: (connections) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Source section
          _sectionHeader('Source'),
          _buildSelectorRow(
            connectionId: _srcConnectionId,
            schemas: _srcSchemas,
            selectedSchema: _srcSchema,
            tables: _srcTables,
            selectedTable: _srcTable,
            connections: connections,
            onConnectionChanged: (v) {
              setState(() {
                _srcConnectionId = v;
                _srcSchema = null;
                _srcTable = null;
                _srcSchemas = [];
                _srcTables = [];
                _srcColumns = [];
              });
              _loadSrcSchemas();
            },
            onSchemaChanged: (v) {
              setState(() {
                _srcSchema = v;
                _srcTable = null;
                _srcTables = [];
                _srcColumns = [];
              });
              _loadSrcTables();
            },
            onTableChanged: (v) {
              setState(() => _srcTable = v);
              _loadSrcColumns();
            },
          ),

          if (_sourceRowCount != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$_sourceRowCount rows in source',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.textTertiary),
              ),
            ),
          const SizedBox(height: 12),

          // WHERE clause
          _label('WHERE clause (optional)'),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: _whereClause,
            decoration: _inputDec(hint: 'e.g., active = true'),
            style: _fieldStyle,
            onChanged: (v) => _whereClause = v,
          ),
          const SizedBox(height: 16),

          // Target section
          _sectionHeader('Target'),
          SwitchListTile(
            value: _createNewTarget,
            onChanged: (v) => setState(() {
              _createNewTarget = v;
              if (v) {
                _tgtTable = null;
                _tgtColumns = [];
                _autoMap();
              }
            }),
            title: const Text('Create new table',
                style:
                    TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: CodeOpsColors.primary,
          ),
          _buildSelectorRow(
            connectionId: _tgtConnectionId,
            schemas: _tgtSchemas,
            selectedSchema: _tgtSchema,
            tables: _tgtTables,
            selectedTable: _createNewTarget ? null : _tgtTable,
            connections: connections,
            onConnectionChanged: (v) {
              setState(() {
                _tgtConnectionId = v;
                _tgtSchema = null;
                _tgtTable = null;
                _tgtSchemas = [];
                _tgtTables = [];
                _tgtColumns = [];
              });
              _loadTgtSchemas();
            },
            onSchemaChanged: (v) {
              setState(() {
                _tgtSchema = v;
                _tgtTable = null;
                _tgtTables = [];
                _tgtColumns = [];
              });
              _loadTgtTables();
            },
            onTableChanged: _createNewTarget
                ? null
                : (v) {
                    setState(() => _tgtTable = v);
                    _loadTgtColumns();
                  },
          ),
          if (_createNewTarget) ...[
            const SizedBox(height: 8),
            _label('New Table Name'),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: _newTargetName,
              decoration: _inputDec(hint: 'e.g., users_copy'),
              style: _fieldStyle,
              onChanged: (v) => _newTargetName = v,
            ),
          ],
          const SizedBox(height: 12),

          // Column mappings (collapsed)
          if (_mappings.isNotEmpty) ...[
            _sectionHeader('Column Mapping (${_mappings.length})'),
            ..._mappings.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    '${m.csvColumn} → ${m.dbColumn ?? "(skip)"}',
                    style: TextStyle(
                      fontSize: 11,
                      color: m.dbColumn != null
                          ? CodeOpsColors.textPrimary
                          : CodeOpsColors.textTertiary,
                    ),
                  ),
                )),
            const SizedBox(height: 12),
          ],

          // Options
          _sectionHeader('Options'),
          Row(
            children: [
              _label('Batch Size:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: '$_batchSize',
                  decoration: _inputDec(),
                  style: _fieldStyle,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      _batchSize = int.tryParse(v) ?? 1000,
                ),
              ),
            ],
          ),
          SwitchListTile(
            value: _truncateTarget,
            onChanged: (v) => setState(() => _truncateTarget = v),
            title: const Text('Truncate target before transfer',
                style:
                    TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: CodeOpsColors.primary,
          ),

          // Progress
          if (_executing) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _progressTotal > 0
                  ? _progressCurrent / _progressTotal
                  : null,
              color: CodeOpsColors.primary,
              backgroundColor: CodeOpsColors.border,
            ),
            const SizedBox(height: 4),
            Text(
              _progressTotal > 0
                  ? 'Batch $_progressCurrent of $_progressTotal'
                  : 'Transferring...',
              style: const TextStyle(
                  fontSize: 11, color: CodeOpsColors.textTertiary),
            ),
          ],

          // Results
          if (_result != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _result!.rowsFailed > 0
                    ? CodeOpsColors.error.withValues(alpha: 0.1)
                    : CodeOpsColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_result!.rowsTransferred} rows transferred, ${_result!.rowsFailed} failed (${_result!.duration.inMilliseconds} ms)',
                    style: const TextStyle(
                        fontSize: 12, color: CodeOpsColors.textPrimary),
                  ),
                  if (_result!.errors.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ..._result!.errors.take(10).map((e) => Text(
                          e.message,
                          style: const TextStyle(
                              fontSize: 11, color: CodeOpsColors.error),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectorRow({
    required String? connectionId,
    required List<SchemaInfo> schemas,
    required String? selectedSchema,
    required List<TableInfo> tables,
    required String? selectedTable,
    required List<DatabaseConnection> connections,
    required ValueChanged<String?> onConnectionChanged,
    required ValueChanged<String?> onSchemaChanged,
    ValueChanged<String?>? onTableChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: connectionId,
            decoration: _inputDec(hint: 'Connection'),
            dropdownColor: CodeOpsColors.surfaceVariant,
            style: _fieldStyle,
            items: connections
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name ?? c.id ?? '',
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: onConnectionChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedSchema,
            decoration: _inputDec(hint: 'Schema'),
            dropdownColor: CodeOpsColors.surfaceVariant,
            style: _fieldStyle,
            items: schemas
                .map((s) => DropdownMenuItem(
                      value: s.name,
                      child: Text(s.name ?? ''),
                    ))
                .toList(),
            onChanged: onSchemaChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: onTableChanged != null
              ? DropdownButtonFormField<String>(
                  value: selectedTable,
                  decoration: _inputDec(hint: 'Table'),
                  dropdownColor: CodeOpsColors.surfaceVariant,
                  style: _fieldStyle,
                  items: tables
                      .where((t) => t.objectType == ObjectType.table)
                      .map((t) => DropdownMenuItem(
                            value: t.tableName,
                            child: Text(t.tableName ?? ''),
                          ))
                      .toList(),
                  onChanged: onTableChanged,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close',
                style: TextStyle(color: CodeOpsColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Transfer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _canExecute() ? _execute : null,
          ),
        ],
      ),
    );
  }

  bool _canExecute() {
    if (_executing) return false;
    if (_srcConnectionId == null ||
        _srcSchema == null ||
        _srcTable == null) return false;
    if (_tgtConnectionId == null || _tgtSchema == null) return false;
    if (_createNewTarget) {
      return _newTargetName.isNotEmpty;
    }
    return _tgtTable != null;
  }

  // -------------------------------------------------------------------------
  // Shared Styles
  // -------------------------------------------------------------------------

  static const _fieldStyle = TextStyle(
    fontSize: 12,
    color: CodeOpsColors.textPrimary,
  );

  InputDecoration _inputDec({String? hint}) => InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CodeOpsColors.textSecondary,
        ),
      );

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textPrimary,
          ),
        ),
      );
}
