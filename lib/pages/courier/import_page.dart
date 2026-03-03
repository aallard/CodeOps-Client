/// Import page for the Courier module.
///
/// Tabbed interface for importing collections from Postman v2.1 JSON,
/// OpenAPI 3.x specs (YAML/JSON), and cURL commands. Each tab provides
/// a file upload/paste area, preview of what will be imported, and an
/// import button that calls the corresponding server API endpoint.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/team_providers.dart';
import '../../theme/colors.dart';

/// Import source tab identifiers.
enum _ImportSource { postman, openapi, curl }

/// Full-page import tool shown at `/courier/import`.
///
/// Three tabs — Postman, OpenAPI, cURL — each with file upload or text
/// paste area, a preview section, and an import button. Results show
/// the number of folders, requests, and environments imported.
class ImportPage extends ConsumerStatefulWidget {
  /// Creates an [ImportPage].
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _pasteController = TextEditingController();

  _ImportSource _activeSource = _ImportSource.postman;
  String? _fileContent;
  String? _fileName;
  bool _importing = false;
  String? _error;
  ImportResultResponse? _result;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeSource = _ImportSource.values[_tabController.index];
          _reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  void _reset() {
    _fileContent = null;
    _fileName = null;
    _error = null;
    _result = null;
    _pasteController.clear();
  }

  Future<void> _pickFile() async {
    final extensions = switch (_activeSource) {
      _ImportSource.postman => ['json'],
      _ImportSource.openapi => ['yaml', 'yml', 'json'],
      _ImportSource.curl => ['sh', 'txt'],
    };

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final content = await File(path).readAsString();
    setState(() {
      _fileContent = content;
      _fileName = result.files.single.name;
    });
  }

  String _effectiveContent() {
    if (_activeSource == _ImportSource.curl) {
      return _pasteController.text.isNotEmpty
          ? _pasteController.text
          : (_fileContent ?? '');
    }
    return _fileContent ?? _pasteController.text;
  }

  String get _formatString => switch (_activeSource) {
        _ImportSource.postman => 'postman',
        _ImportSource.openapi => 'openapi',
        _ImportSource.curl => 'curl',
      };

  Future<void> _import() async {
    final content = _effectiveContent().trim();
    if (content.isEmpty) return;

    setState(() {
      _importing = true;
      _error = null;
      _result = null;
    });

    try {
      final teamId = ref.read(selectedTeamIdProvider);
      if (teamId == null) throw Exception('No team selected');
      final api = ref.read(courierApiProvider);

      final request = ImportCollectionRequest(
        format: _formatString,
        content: content,
      );

      final result = switch (_activeSource) {
        _ImportSource.postman => await api.importPostman(teamId, request),
        _ImportSource.openapi => await api.importOpenApi(teamId, request),
        _ImportSource.curl => await api.importCurl(teamId, request),
      };

      ref.invalidate(courierCollectionsProvider);

      setState(() {
        _importing = false;
        _result = result;
      });
    } catch (e) {
      setState(() {
        _importing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CodeOpsColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            key: const Key('import_page_header'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: CodeOpsColors.surface,
              border: Border(bottom: BorderSide(color: CodeOpsColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  key: const Key('import_back_button'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  color: CodeOpsColors.textSecondary,
                  onPressed: () => context.go('/courier'),
                  tooltip: 'Back to Courier',
                ),
                const SizedBox(width: 8),
                const Icon(Icons.upload_outlined,
                    color: CodeOpsColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Import Collection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Tab bar ─────────────────────────────────────────────
          Container(
            color: CodeOpsColors.surface,
            child: TabBar(
              key: const Key('import_tab_bar'),
              controller: _tabController,
              indicatorColor: CodeOpsColors.primary,
              labelColor: CodeOpsColors.textPrimary,
              unselectedLabelColor: CodeOpsColors.textTertiary,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(key: Key('postman_tab'), text: 'Postman'),
                Tab(key: Key('openapi_tab'), text: 'OpenAPI'),
                Tab(key: Key('curl_tab'), text: 'cURL'),
              ],
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source description
                      Text(
                        switch (_activeSource) {
                          _ImportSource.postman =>
                            'Upload a Postman Collection v2.1 JSON file.',
                          _ImportSource.openapi =>
                            'Upload an OpenAPI 3.x specification (YAML or JSON).',
                          _ImportSource.curl =>
                            'Paste a cURL command to create a single request.',
                        },
                        style: const TextStyle(
                          fontSize: 13,
                          color: CodeOpsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // File upload area
                      if (_activeSource != _ImportSource.curl) ...[
                        InkWell(
                          key: const Key('file_upload_area'),
                          onTap: _pickFile,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            decoration: BoxDecoration(
                              color: CodeOpsColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: CodeOpsColors.border,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _fileName != null
                                      ? Icons.insert_drive_file
                                      : Icons.cloud_upload_outlined,
                                  size: 36,
                                  color: _fileName != null
                                      ? CodeOpsColors.primary
                                      : CodeOpsColors.textTertiary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _fileName ?? 'Click to upload file',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _fileName != null
                                        ? CodeOpsColors.textPrimary
                                        : CodeOpsColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'or paste content below',
                            style: TextStyle(
                              fontSize: 12,
                              color: CodeOpsColors.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Paste area
                      TextField(
                        key: const Key('paste_area'),
                        controller: _pasteController,
                        maxLines: _activeSource == _ImportSource.curl ? 6 : 10,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'JetBrains Mono',
                          color: CodeOpsColors.textPrimary,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: switch (_activeSource) {
                            _ImportSource.postman => 'Paste Postman JSON...',
                            _ImportSource.openapi => 'Paste OpenAPI spec...',
                            _ImportSource.curl =>
                              'curl -X GET https://api.example.com/users',
                          },
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: CodeOpsColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: CodeOpsColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: CodeOpsColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: CodeOpsColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: CodeOpsColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Result preview ──────────────────────────────
                      if (_result != null) ...[
                        Container(
                          key: const Key('import_result'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CodeOpsColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CodeOpsColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 18, color: CodeOpsColors.success),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Imported: ${_result!.collectionName ?? 'Collection'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: CodeOpsColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_result!.foldersImported ?? 0} folders, '
                                '${_result!.requestsImported ?? 0} requests, '
                                '${_result!.environmentsImported ?? 0} environments',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CodeOpsColors.textSecondary,
                                ),
                              ),
                              if (_result!.warnings != null &&
                                  _result!.warnings!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...(_result!.warnings!.map((w) => Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.warning_amber,
                                              size: 14,
                                              color: CodeOpsColors.warning),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              w,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: CodeOpsColors.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Error ───────────────────────────────────────
                      if (_error != null) ...[
                        Text(_error!,
                            style: const TextStyle(
                                fontSize: 12, color: CodeOpsColors.error)),
                        const SizedBox(height: 16),
                      ],

                      // ── Import button ───────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          key: const Key('import_button'),
                          onPressed: _importing ? null : _import,
                          icon: _importing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.upload, size: 16),
                          label: Text(
                            _importing ? 'Importing...' : 'Import',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: CodeOpsColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
