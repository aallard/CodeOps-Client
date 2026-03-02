/// SQL script import dialog for DataLens.
///
/// Allows the user to pick a `.sql` file, preview its contents, choose a
/// connection, configure execution options (stop on error, wrap in
/// transaction), and execute with per-statement progress and results.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/datalens_providers.dart';
import '../../../services/datalens/import/sql_script_import_service.dart';
import '../../../theme/colors.dart';

/// Dialog for importing and executing SQL script files.
///
/// Shows file picker, connection selector, script preview, execution options,
/// and per-statement results with status icons.
class SqlScriptImportDialog extends ConsumerStatefulWidget {
  /// Optional pre-selected connection.
  final String? connectionId;

  /// Creates a [SqlScriptImportDialog].
  const SqlScriptImportDialog({super.key, this.connectionId});

  @override
  ConsumerState<SqlScriptImportDialog> createState() =>
      _SqlScriptImportDialogState();
}

class _SqlScriptImportDialogState
    extends ConsumerState<SqlScriptImportDialog> {
  String? _filePath;
  String _scriptContent = '';
  String? _connectionId;
  bool _stopOnError = true;
  bool _wrapInTransaction = false;
  bool _executing = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;
  ScriptResult? _result;

  @override
  void initState() {
    super.initState();
    _connectionId = widget.connectionId;
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select SQL Script',
      type: FileType.custom,
      allowedExtensions: ['sql', 'txt'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final content = await File(path).readAsString();
    setState(() {
      _filePath = path;
      _scriptContent = content;
    });
  }

  Future<void> _execute() async {
    if (_connectionId == null || _scriptContent.isEmpty) return;

    setState(() {
      _executing = true;
      _result = null;
      _progressCurrent = 0;
      _progressTotal = 0;
    });

    try {
      final service = ref.read(sqlScriptImportServiceProvider);
      final result = await service.executeScript(
        connectionId: _connectionId!,
        script: _scriptContent,
        stopOnError: _stopOnError,
        wrapInTransaction: _wrapInTransaction,
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
        setState(() => _result = ScriptResult(
              statementsExecuted: 1,
              statementsFailed: 1,
              details: [
                StatementResult(
                  sql: '(script)',
                  success: false,
                  error: e.toString(),
                ),
              ],
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
        width: 640,
        height: 520,
        child: Column(
          children: [
            _buildTitleBar(),
            const Divider(height: 1, color: CodeOpsColors.border),
            Expanded(child: _buildContent()),
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
          const Icon(Icons.description, size: 18, color: CodeOpsColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Import SQL Script',
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

  Widget _buildContent() {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _pickFile,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Connection selector
        _label('Connection'),
        const SizedBox(height: 4),
        _buildConnectionDropdown(),
        const SizedBox(height: 12),

        // Script preview
        if (_scriptContent.isNotEmpty) ...[
          _label('Script Preview'),
          const SizedBox(height: 4),
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CodeOpsColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: CodeOpsColors.border),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _scriptContent,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'JetBrains Mono',
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_scriptContent.length} characters',
            style: const TextStyle(
                fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
          const SizedBox(height: 12),
        ],

        // Options
        SwitchListTile(
          value: _stopOnError,
          onChanged: (v) => setState(() => _stopOnError = v),
          title: const Text('Stop on error',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: CodeOpsColors.primary,
        ),
        SwitchListTile(
          value: _wrapInTransaction,
          onChanged: (v) => setState(() => _wrapInTransaction = v),
          title: const Text('Wrap in transaction',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary)),
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
                ? 'Executing statement $_progressCurrent of $_progressTotal'
                : 'Executing...',
            style: const TextStyle(
                fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
        ],

        // Results
        if (_result != null) ...[
          const SizedBox(height: 12),
          _buildResultSummary(),
          const SizedBox(height: 8),
          _buildStatementDetails(),
        ],
      ],
    );
  }

  Widget _buildConnectionDropdown() {
    final connectionsAsync = ref.watch(datalensConnectionsProvider);
    return connectionsAsync.when(
      loading: () => const Text('Loading...',
          style: TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary)),
      error: (e, _) => Text('Error: $e',
          style: const TextStyle(fontSize: 12, color: CodeOpsColors.error)),
      data: (connections) => DropdownButtonFormField<String>(
        value: _connectionId,
        decoration: _inputDec(),
        dropdownColor: CodeOpsColors.surfaceVariant,
        style: const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
        items: connections
            .map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name ?? c.id ?? ''),
                ))
            .toList(),
        onChanged: (v) => setState(() => _connectionId = v),
      ),
    );
  }

  Widget _buildResultSummary() {
    final r = _result!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: r.statementsFailed > 0
            ? CodeOpsColors.error.withValues(alpha: 0.1)
            : CodeOpsColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            r.statementsFailed > 0 ? Icons.warning : Icons.check_circle,
            size: 16,
            color:
                r.statementsFailed > 0 ? CodeOpsColors.error : CodeOpsColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            '${r.statementsSucceeded} succeeded, ${r.statementsFailed} failed, ${r.rowsAffected} rows affected (${r.duration.inMilliseconds} ms)',
            style: const TextStyle(
                fontSize: 12, color: CodeOpsColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementDetails() {
    final details = _result!.details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Statement Results'),
        const SizedBox(height: 4),
        ...details.take(50).map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    d.success ? Icons.check : Icons.close,
                    size: 14,
                    color: d.success
                        ? CodeOpsColors.success
                        : CodeOpsColors.error,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      d.success
                          ? '${_truncate(d.sql, 80)} (${d.rowsAffected} rows, ${d.duration.inMilliseconds} ms)'
                          : '${_truncate(d.sql, 60)}: ${d.error}',
                      style: const TextStyle(
                          fontSize: 11, color: CodeOpsColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
        if (details.length > 50)
          Text('... and ${details.length - 50} more',
              style: const TextStyle(
                  fontSize: 11, color: CodeOpsColors.textTertiary)),
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
            label: const Text('Execute'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed:
                _connectionId != null && _scriptContent.isNotEmpty && !_executing
                    ? _execute
                    : null,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CodeOpsColors.textSecondary,
        ),
      );

  InputDecoration _inputDec() => InputDecoration(
        isDense: true,
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

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...';
  }
}
