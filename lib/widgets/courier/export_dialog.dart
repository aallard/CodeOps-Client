/// Dialog for exporting a collection in various formats.
///
/// Supports Postman v2.1 JSON, OpenAPI 3.0 YAML, OpenAPI 3.0 JSON, and
/// native CodeOps format. Downloads the exported content to a file via
/// file picker.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Available export format options.
enum ExportFormat {
  /// Postman Collection v2.1 JSON.
  postman,

  /// OpenAPI 3.0 specification.
  openapi,

  /// Native CodeOps format.
  native_,
}

/// Extension on [ExportFormat] for display and API integration.
extension ExportFormatExtension on ExportFormat {
  /// Display label.
  String get displayName => switch (this) {
        ExportFormat.postman => 'Postman v2.1 (JSON)',
        ExportFormat.openapi => 'OpenAPI 3.0',
        ExportFormat.native_ => 'CodeOps Native',
      };

  /// File extension for download.
  String get fileExtension => switch (this) {
        ExportFormat.postman => 'json',
        ExportFormat.openapi => 'yaml',
        ExportFormat.native_ => 'json',
      };

  /// API format parameter.
  String get apiFormat => switch (this) {
        ExportFormat.postman => 'postman',
        ExportFormat.openapi => 'openapi',
        ExportFormat.native_ => 'native',
      };

  /// Icon for the format.
  IconData get icon => switch (this) {
        ExportFormat.postman => Icons.rocket_launch_outlined,
        ExportFormat.openapi => Icons.api,
        ExportFormat.native_ => Icons.inventory_2_outlined,
      };
}

/// Dialog for exporting a collection to file.
///
/// Uses `GET /courier/collections/{id}/export/{format}` via
/// [CourierApiService.exportCollection].
class ExportCollectionDialog extends ConsumerStatefulWidget {
  /// The collection ID to export.
  final String collectionId;

  /// The collection name (for display and default filename).
  final String collectionName;

  /// Creates an [ExportCollectionDialog].
  const ExportCollectionDialog({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  ConsumerState<ExportCollectionDialog> createState() =>
      _ExportCollectionDialogState();
}

class _ExportCollectionDialogState
    extends ConsumerState<ExportCollectionDialog> {
  ExportFormat _selectedFormat = ExportFormat.postman;
  bool _includeEnvironment = false;
  bool _exporting = false;
  String? _error;

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _error = null;
    });

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) throw Exception('No team selected');
      final api = ref.read(courierApiProvider);

      final result = await api.exportCollection(
        teamId,
        widget.collectionId,
        format: _selectedFormat.apiFormat,
      );

      final content = result.content ?? '';
      final suggestedName =
          result.filename ?? '${widget.collectionName}.${_selectedFormat.fileExtension}';

      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Collection',
        fileName: suggestedName,
        allowedExtensions: [_selectedFormat.fileExtension],
        type: FileType.custom,
      );

      if (filePath != null) {
        await File(filePath).writeAsString(content);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported to $filePath'),
              duration: const Duration(seconds: 2),
              backgroundColor: CodeOpsColors.surface,
            ),
          );
          Navigator.of(context).pop();
        }
      }

      setState(() => _exporting = false);
    } catch (e) {
      setState(() {
        _exporting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('export_collection_dialog'),
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.file_download_outlined,
                      color: CodeOpsColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Export Collection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: CodeOpsColors.textTertiary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.collectionName,
                style: const TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // ── Format selector ───────────────────────────────────
              const Text(
                'Format',
                style: TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...ExportFormat.values.map((f) => _FormatTile(
                    key: Key('format_${f.name}'),
                    format: f,
                    selected: _selectedFormat == f,
                    onTap: () => setState(() => _selectedFormat = f),
                  )),
              const SizedBox(height: 16),

              // ── Include environment toggle ────────────────────────
              Row(
                children: [
                  Switch(
                    key: const Key('include_environment_toggle'),
                    value: _includeEnvironment,
                    onChanged: (v) => setState(() => _includeEnvironment = v),
                    activeTrackColor: CodeOpsColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Include environment variables',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CodeOpsColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Error ─────────────────────────────────────────────
              if (_error != null) ...[
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: CodeOpsColors.error)),
                const SizedBox(height: 12),
              ],

              // ── Actions ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const Key('export_button'),
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.file_download, size: 16),
                    label: Text(
                      _exporting ? 'Exporting...' : 'Export',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: CodeOpsColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  final ExportFormat format;
  final bool selected;
  final VoidCallback onTap;

  const _FormatTile({
    super.key,
    required this.format,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? CodeOpsColors.primary.withValues(alpha: 0.1)
                : CodeOpsColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? CodeOpsColors.primary : CodeOpsColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                format.icon,
                size: 18,
                color: selected ? CodeOpsColors.primary : CodeOpsColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Text(
                format.displayName,
                style: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? CodeOpsColors.textPrimary
                      : CodeOpsColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (selected)
                const Icon(Icons.check_circle,
                    size: 16, color: CodeOpsColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
