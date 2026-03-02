/// Multi-step CSV import wizard for DataLens.
///
/// Guides the user through five steps: file selection, target selection,
/// column mapping, options, and execution/results. Uses [CsvImportService]
/// for parsing and importing.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/datalens_enums.dart';
import '../../../models/datalens_models.dart';
import '../../../providers/datalens_providers.dart';
import '../../../services/datalens/import/csv_import_service.dart';
import '../../../theme/colors.dart';

/// Five-step CSV import wizard dialog.
///
/// Step 1 — File selection with delimiter, encoding, and header toggle.
/// Step 2 — Target connection, schema, and table selection.
/// Step 3 — Column mapping with auto-map and transformations.
/// Step 4 — Import options (truncate, conflict, batch size, dry run).
/// Step 5 — Execution progress and result summary.
class CsvImportWizard extends ConsumerStatefulWidget {
  /// Optional pre-selected connection, schema, and table.
  final String? connectionId;
  final String? schema;
  final String? table;

  /// Creates a [CsvImportWizard].
  const CsvImportWizard({
    super.key,
    this.connectionId,
    this.schema,
    this.table,
  });

  @override
  ConsumerState<CsvImportWizard> createState() => _CsvImportWizardState();
}

class _CsvImportWizardState extends ConsumerState<CsvImportWizard> {
  int _currentStep = 0;

  // Step 1 — File
  String? _filePath;
  String _delimiter = ',';
  String _quoteChar = '"';
  bool _hasHeader = true;
  String _encoding = 'utf-8';
  CsvPreview? _preview;
  bool _loadingPreview = false;

  // Step 2 — Target
  String? _connectionId;
  String? _schema;
  String? _targetTable;
  bool _createNewTable = false;
  String _newTableName = '';
  List<SchemaInfo> _schemas = [];
  List<TableInfo> _tables = [];
  List<ColumnInfo> _targetColumns = [];

  // Step 3 — Mapping
  List<ColumnMapping> _mappings = [];

  // Step 4 — Options
  bool _truncateBeforeImport = false;
  OnConflict _onConflict = OnConflict.error;
  int _batchSize = 500;
  bool _dryRun = false;
  bool _createTableIfNotExists = false;

  // Step 5 — Execution
  bool _executing = false;
  ImportResult? _result;

  @override
  void initState() {
    super.initState();
    _connectionId = widget.connectionId;
    _schema = widget.schema;
    _targetTable = widget.table;
    if (_connectionId != null) _loadSchemas();
    if (_schema != null) _loadTables();
    if (_targetTable != null) _loadTargetColumns();
  }

  // -------------------------------------------------------------------------
  // Data Loading
  // -------------------------------------------------------------------------

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select CSV File',
      type: FileType.custom,
      allowedExtensions: ['csv', 'tsv', 'txt'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _filePath = result.files.single.path;
      _preview = null;
    });
    await _loadPreview();
  }

  Future<void> _loadPreview() async {
    if (_filePath == null) return;
    setState(() => _loadingPreview = true);

    try {
      final service = ref.read(csvImportServiceProvider);
      final preview = await service.previewCsv(
        _filePath!,
        delimiter: _delimiter,
        quoteChar: _quoteChar,
        hasHeader: _hasHeader,
        encoding: _encoding,
        previewRows: 5,
      );
      if (mounted) {
        setState(() {
          _preview = preview;
          _delimiter = preview.detectedDelimiter;
          _loadingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingPreview = false);
    }
  }

  Future<void> _loadSchemas() async {
    if (_connectionId == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final schemas = await service.getSchemas(_connectionId!);
      if (mounted) setState(() => _schemas = schemas);
    } catch (_) {}
  }

  Future<void> _loadTables() async {
    if (_connectionId == null || _schema == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final tables = await service.getTables(_connectionId!, _schema!);
      if (mounted) setState(() => _tables = tables);
    } catch (_) {}
  }

  Future<void> _loadTargetColumns() async {
    if (_connectionId == null || _schema == null || _targetTable == null) return;
    try {
      final service = ref.read(datalensSchemaServiceProvider);
      final cols =
          await service.getColumns(_connectionId!, _schema!, _targetTable!);
      if (mounted) {
        setState(() => _targetColumns = cols);
        _autoMapColumns();
      }
    } catch (_) {}
  }

  void _autoMapColumns() {
    if (_preview == null) return;

    final tgtMap = <String, String>{};
    for (final col in _targetColumns) {
      final name = col.columnName ?? '';
      if (name.isNotEmpty) tgtMap[name.toLowerCase()] = name;
    }

    _mappings = _preview!.detectedColumns.map((csvCol) {
      final match = tgtMap[csvCol.toLowerCase()];
      return ColumnMapping(csvColumn: csvCol, dbColumn: match);
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Execute
  // -------------------------------------------------------------------------

  Future<void> _execute() async {
    if (_connectionId == null || _schema == null) return;
    final table = _createNewTable ? _newTableName : _targetTable;
    if (table == null || table.isEmpty) return;

    setState(() => _executing = true);

    try {
      final service = ref.read(csvImportServiceProvider);
      final result = await service.importCsv(
        filePath: _filePath!,
        connectionId: _connectionId!,
        schema: _schema!,
        targetTable: table,
        mappings: _mappings,
        options: CsvImportOptions(
          createTableIfNotExists: _createNewTable || _createTableIfNotExists,
          truncateBeforeImport: _truncateBeforeImport,
          onConflict: _onConflict,
          batchSize: _batchSize,
          dryRun: _dryRun,
          delimiter: _delimiter,
          quoteChar: _quoteChar,
          hasHeader: _hasHeader,
        ),
      );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        setState(() => _result = ImportResult(
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
        width: 720,
        height: 580,
        child: Column(
          children: [
            _buildTitleBar(),
            const Divider(height: 1, color: CodeOpsColors.border),
            _buildStepIndicator(),
            const Divider(height: 1, color: CodeOpsColors.border),
            Expanded(child: _buildStepContent()),
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
          const Icon(Icons.upload_file, size: 18, color: CodeOpsColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Import CSV',
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

  Widget _buildStepIndicator() {
    const labels = ['File', 'Target', 'Mapping', 'Options', 'Execute'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDone
                        ? CodeOpsColors.success
                        : isActive
                            ? CodeOpsColors.primary
                            : CodeOpsColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : CodeOpsColors.textTertiary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? CodeOpsColors.textPrimary
                        : CodeOpsColors.textTertiary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (i < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isDone
                          ? CodeOpsColors.success
                          : CodeOpsColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return switch (_currentStep) {
      0 => _buildFileStep(),
      1 => _buildTargetStep(),
      2 => _buildMappingStep(),
      3 => _buildOptionsStep(),
      4 => _buildExecuteStep(),
      _ => const SizedBox.shrink(),
    };
  }

  // -------------------------------------------------------------------------
  // Step 1 — File Selection
  // -------------------------------------------------------------------------

  Widget _buildFileStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // File picker
        Row(
          children: [
            Expanded(
              child: Text(
                _filePath ?? 'No file selected',
                style: TextStyle(
                  fontSize: 12,
                  color: _filePath != null
                      ? CodeOpsColors.textPrimary
                      : CodeOpsColors.textTertiary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open, size: 14),
              label: const Text('Browse', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: CodeOpsColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _pickFile,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Delimiter
        Row(
          children: [
            _label('Delimiter'),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _delimiter,
                decoration: _inputDec(),
                dropdownColor: CodeOpsColors.surfaceVariant,
                style: _fieldStyle,
                items: const [
                  DropdownMenuItem(value: ',', child: Text('Comma (,)')),
                  DropdownMenuItem(value: '\t', child: Text('Tab')),
                  DropdownMenuItem(value: ';', child: Text('Semicolon (;)')),
                  DropdownMenuItem(value: '|', child: Text('Pipe (|)')),
                ],
                onChanged: (v) {
                  setState(() => _delimiter = v ?? ',');
                  _loadPreview();
                },
              ),
            ),
            const SizedBox(width: 16),
            _label('Encoding'),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _encoding,
                decoration: _inputDec(),
                dropdownColor: CodeOpsColors.surfaceVariant,
                style: _fieldStyle,
                items: const [
                  DropdownMenuItem(value: 'utf-8', child: Text('UTF-8')),
                  DropdownMenuItem(value: 'latin-1', child: Text('Latin-1')),
                  DropdownMenuItem(
                      value: 'windows-1252', child: Text('Windows-1252')),
                ],
                onChanged: (v) {
                  setState(() => _encoding = v ?? 'utf-8');
                  _loadPreview();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Has header toggle
        SwitchListTile(
          value: _hasHeader,
          onChanged: (v) {
            setState(() => _hasHeader = v);
            _loadPreview();
          },
          title: const Text('First row is header',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: CodeOpsColors.primary,
        ),
        const SizedBox(height: 12),

        // Preview table
        if (_loadingPreview)
          const Center(
              child: CircularProgressIndicator(
                  color: CodeOpsColors.primary, strokeWidth: 2)),
        if (_preview != null) ...[
          Text(
            '${_preview!.totalRows} rows detected',
            style: const TextStyle(
                fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
          const SizedBox(height: 8),
          _buildPreviewTable(),
        ],
      ],
    );
  }

  Widget _buildPreviewTable() {
    final p = _preview!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 28,
        dataRowMinHeight: 24,
        dataRowMaxHeight: 24,
        columnSpacing: 16,
        horizontalMargin: 8,
        headingTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: CodeOpsColors.textSecondary,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 11,
          color: CodeOpsColors.textPrimary,
        ),
        columns: p.detectedColumns
            .map((c) => DataColumn(label: Text(c)))
            .toList(),
        rows: p.previewRows
            .map((row) => DataRow(
                  cells: List.generate(
                    p.detectedColumns.length,
                    (i) => DataCell(Text(
                      i < row.length ? row[i] : '',
                      overflow: TextOverflow.ellipsis,
                    )),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Step 2 — Target Selection
  // -------------------------------------------------------------------------

  Widget _buildTargetStep() {
    final connectionsAsync = ref.watch(datalensConnectionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection
        _label('Connection'),
        const SizedBox(height: 4),
        connectionsAsync.when(
          loading: () => const Text('Loading...'),
          error: (e, _) => Text('Error: $e'),
          data: (connections) => DropdownButtonFormField<String>(
            value: _connectionId,
            decoration: _inputDec(),
            dropdownColor: CodeOpsColors.surfaceVariant,
            style: _fieldStyle,
            items: connections
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name ?? c.id ?? ''),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() {
                _connectionId = v;
                _schema = null;
                _targetTable = null;
                _schemas = [];
                _tables = [];
                _targetColumns = [];
              });
              _loadSchemas();
            },
          ),
        ),
        const SizedBox(height: 12),

        // Schema
        _label('Schema'),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _schema,
          decoration: _inputDec(),
          dropdownColor: CodeOpsColors.surfaceVariant,
          style: _fieldStyle,
          items: _schemas
              .map((s) => DropdownMenuItem(
                    value: s.name,
                    child: Text(s.name ?? ''),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() {
              _schema = v;
              _targetTable = null;
              _tables = [];
              _targetColumns = [];
            });
            _loadTables();
          },
        ),
        const SizedBox(height: 12),

        // Table or Create New
        SwitchListTile(
          value: _createNewTable,
          onChanged: (v) => setState(() {
            _createNewTable = v;
            if (v) {
              _targetTable = null;
              _targetColumns = [];
              _autoMapColumnsForNewTable();
            }
          }),
          title: const Text('Create new table',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: CodeOpsColors.primary,
        ),
        const SizedBox(height: 8),

        if (_createNewTable) ...[
          _label('New Table Name'),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: _newTableName,
            decoration: _inputDec(hint: 'e.g., imported_data'),
            style: _fieldStyle,
            onChanged: (v) => _newTableName = v,
          ),
        ] else ...[
          _label('Table'),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _targetTable,
            decoration: _inputDec(),
            dropdownColor: CodeOpsColors.surfaceVariant,
            style: _fieldStyle,
            items: _tables
                .where((t) => t.objectType == ObjectType.table)
                .map((t) => DropdownMenuItem(
                      value: t.tableName,
                      child: Text(t.tableName ?? ''),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() => _targetTable = v);
              _loadTargetColumns();
            },
          ),
        ],
      ],
    );
  }

  void _autoMapColumnsForNewTable() {
    if (_preview == null) return;
    _mappings = _preview!.detectedColumns.map((csvCol) {
      final sanitized = csvCol
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      return ColumnMapping(csvColumn: csvCol, dbColumn: sanitized);
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Step 3 — Column Mapping
  // -------------------------------------------------------------------------

  Widget _buildMappingStep() {
    if (_preview == null) {
      return const Center(
          child: Text('No CSV loaded',
              style: TextStyle(color: CodeOpsColors.textTertiary)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Auto-map button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.auto_fix_high, size: 14),
            label: const Text('Auto-Map', style: TextStyle(fontSize: 12)),
            onPressed: () {
              if (_createNewTable) {
                _autoMapColumnsForNewTable();
              } else {
                _autoMapColumns();
              }
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 8),

        // Mapping rows
        for (var i = 0; i < _mappings.length; i++) _buildMappingRow(i),

        // Unmapped required DB columns
        if (!_createNewTable) _buildUnmappedWarning(),
      ],
    );
  }

  Widget _buildMappingRow(int index) {
    final mapping = _mappings[index];
    final isSkipped = mapping.dbColumn == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // CSV column label
          SizedBox(
            width: 140,
            child: Text(
              mapping.csvColumn,
              style: TextStyle(
                fontSize: 12,
                color: isSkipped
                    ? CodeOpsColors.textTertiary
                    : CodeOpsColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 14,
              color: CodeOpsColors.textTertiary),
          const SizedBox(width: 8),

          // Target column dropdown
          SizedBox(
            width: 140,
            child: _createNewTable
                ? TextFormField(
                    initialValue: mapping.dbColumn ?? '',
                    decoration: _inputDec(hint: 'column name'),
                    style: _fieldStyle,
                    onChanged: (v) {
                      _mappings[index] = ColumnMapping(
                        csvColumn: mapping.csvColumn,
                        dbColumn: v.isEmpty ? null : v,
                        transformation: mapping.transformation,
                        defaultValue: mapping.defaultValue,
                      );
                    },
                  )
                : DropdownButtonFormField<String?>(
                    value: mapping.dbColumn,
                    decoration: _inputDec(),
                    dropdownColor: CodeOpsColors.surfaceVariant,
                    style: _fieldStyle,
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('(Skip)')),
                      ..._targetColumns.map((c) => DropdownMenuItem(
                            value: c.columnName,
                            child: Text(c.columnName ?? ''),
                          )),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _mappings[index] = ColumnMapping(
                          csvColumn: mapping.csvColumn,
                          dbColumn: v,
                          transformation: mapping.transformation,
                          defaultValue: mapping.defaultValue,
                        );
                      });
                    },
                  ),
          ),
          const SizedBox(width: 8),

          // Transformation dropdown
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String?>(
              value: mapping.transformation,
              decoration: _inputDec(),
              dropdownColor: CodeOpsColors.surfaceVariant,
              style: _fieldStyle,
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('None')),
                DropdownMenuItem(value: 'trim', child: Text('Trim')),
                DropdownMenuItem(value: 'uppercase', child: Text('Uppercase')),
                DropdownMenuItem(value: 'lowercase', child: Text('Lowercase')),
              ],
              onChanged: (v) {
                setState(() {
                  _mappings[index] = ColumnMapping(
                    csvColumn: mapping.csvColumn,
                    dbColumn: mapping.dbColumn,
                    transformation: v,
                    defaultValue: mapping.defaultValue,
                  );
                });
              },
            ),
          ),
          const SizedBox(width: 8),

          // Default value
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: mapping.defaultValue ?? '',
              decoration: _inputDec(hint: 'default'),
              style: _fieldStyle,
              onChanged: (v) {
                _mappings[index] = ColumnMapping(
                  csvColumn: mapping.csvColumn,
                  dbColumn: mapping.dbColumn,
                  transformation: mapping.transformation,
                  defaultValue: v.isEmpty ? null : v,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnmappedWarning() {
    final mappedDbCols =
        _mappings.where((m) => m.dbColumn != null).map((m) => m.dbColumn);
    final unmapped = _targetColumns
        .where((c) =>
            c.columnName != null &&
            !mappedDbCols.contains(c.columnName) &&
            c.isNullable == false &&
            c.columnDefault == null &&
            c.category != ColumnCategory.serial &&
            c.category != ColumnCategory.generated)
        .toList();

    if (unmapped.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unmapped required columns:',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.error),
          ),
          const SizedBox(height: 4),
          ...unmapped.map((c) => Text(
                '  • ${c.columnName} (${c.dataType})',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.error),
              )),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Step 4 — Options
  // -------------------------------------------------------------------------

  Widget _buildOptionsStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: _truncateBeforeImport,
          onChanged: (v) => setState(() => _truncateBeforeImport = v),
          title: const Text('Truncate table before import',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
          subtitle: const Text('Deletes all existing rows first',
              style:
                  TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary)),
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: CodeOpsColors.primary,
        ),
        const SizedBox(height: 8),

        // On conflict
        _label('On Conflict'),
        const SizedBox(height: 4),
        ...OnConflict.values.map((oc) => RadioListTile<OnConflict>(
              value: oc,
              groupValue: _onConflict,
              onChanged: (v) => setState(() => _onConflict = v!),
              title: Text(oc.label,
                  style: const TextStyle(
                      fontSize: 12, color: CodeOpsColors.textPrimary)),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: CodeOpsColors.primary,
            )),
        const SizedBox(height: 12),

        // Batch size
        _label('Batch Size: $_batchSize'),
        Slider(
          value: _batchSize.toDouble(),
          min: 100,
          max: 5000,
          divisions: 49,
          activeColor: CodeOpsColors.primary,
          onChanged: (v) => setState(() => _batchSize = v.round()),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          value: _dryRun,
          onChanged: (v) => setState(() => _dryRun = v),
          title: const Text('Dry run (preview SQL only)',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: CodeOpsColors.primary,
        ),

        if (_createNewTable)
          SwitchListTile(
            value: _createTableIfNotExists,
            onChanged: (v) => setState(() => _createTableIfNotExists = v),
            title: const Text('Create table if not exists',
                style:
                    TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: CodeOpsColors.primary,
          ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Step 5 — Execute
  // -------------------------------------------------------------------------

  Widget _buildExecuteStep() {
    if (_executing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
                color: CodeOpsColors.primary, strokeWidth: 2),
            SizedBox(height: 12),
            Text('Importing...',
                style:
                    TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary)),
          ],
        ),
      );
    }

    if (_result == null) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 16),
          label: Text(
            _dryRun ? 'Generate SQL' : 'Start Import',
            style: const TextStyle(fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _execute,
        ),
      );
    }

    final r = _result!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary
        _resultRow('Imported', '${r.rowsImported}', CodeOpsColors.success),
        _resultRow('Skipped', '${r.rowsSkipped}', CodeOpsColors.warning),
        _resultRow('Failed', '${r.rowsFailed}', CodeOpsColors.error),
        _resultRow('Duration', '${r.duration.inMilliseconds} ms', null),
        const SizedBox(height: 12),

        // Errors
        if (r.errors.isNotEmpty) ...[
          const Text('Errors:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.error)),
          const SizedBox(height: 4),
          ...r.errors.take(20).map((e) => Text(
                'Row ${e.rowNumber}: ${e.message}',
                style: const TextStyle(
                    fontSize: 11, color: CodeOpsColors.textSecondary),
              )),
          if (r.errors.length > 20)
            Text(
              '... and ${r.errors.length - 20} more',
              style: const TextStyle(
                  fontSize: 11, color: CodeOpsColors.textTertiary),
            ),
        ],

        // Generated SQL (dry run)
        if (_dryRun && r.generatedSql.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Generated SQL:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CodeOpsColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            height: 200,
            child: SingleChildScrollView(
              child: SelectableText(
                r.generatedSql.join(';\n\n'),
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'JetBrains Mono',
                    color: CodeOpsColors.textPrimary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _resultRow(String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: CodeOpsColors.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? CodeOpsColors.textPrimary,
              )),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentStep > 0 && !_executing
                ? () => setState(() => _currentStep--)
                : null,
            child: const Text('Back',
                style: TextStyle(color: CodeOpsColors.textSecondary)),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel',
                    style: TextStyle(color: CodeOpsColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              if (_currentStep < 4)
                ElevatedButton(
                  onPressed: _canAdvance() && !_executing
                      ? () => setState(() => _currentStep++)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CodeOpsColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Next'),
                ),
              if (_currentStep == 4 && _result != null)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_result),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CodeOpsColors.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canAdvance() {
    return switch (_currentStep) {
      0 => _filePath != null && _preview != null,
      1 => _connectionId != null &&
          _schema != null &&
          (_createNewTable ? _newTableName.isNotEmpty : _targetTable != null),
      2 => _mappings.any((m) => m.dbColumn != null),
      3 => true,
      _ => false,
    };
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
}
