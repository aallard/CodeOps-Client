/// MCP document detail page.
///
/// Displays at `/mcp/documents/:documentId` with a full-screen
/// [ScribeEditor], toolbar (Edit/Save/Flag/Versions/Export), and
/// metadata sidebar.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/mcp_models.dart';
import '../../providers/mcp_document_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/scribe/scribe_editor.dart';
import '../../widgets/shared/error_panel.dart';

/// The MCP document detail page.
class DocumentDetailPage extends ConsumerStatefulWidget {
  /// The document ID from the route parameter.
  final String documentId;

  /// Creates a [DocumentDetailPage].
  const DocumentDetailPage({super.key, required this.documentId});

  @override
  ConsumerState<DocumentDetailPage> createState() =>
      _DocumentDetailPageState();
}

class _DocumentDetailPageState extends ConsumerState<DocumentDetailPage> {
  bool _editMode = false;
  String _editorContent = '';
  bool _showMetadata = false;

  void _refresh() {
    ref.invalidate(docVersionsProvider(widget.documentId));
  }

  @override
  Widget build(BuildContext context) {
    final versionsAsync =
        ref.watch(docVersionsProvider(widget.documentId));

    return versionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (e, _) => ErrorPanel.fromException(e, onRetry: _refresh),
      data: (versions) {
        final latestVersion = versions.isNotEmpty ? versions.first : null;
        final content = latestVersion?.content ?? '';

        return Column(
          children: [
            _DetailToolbar(
              documentId: widget.documentId,
              version: latestVersion,
              editMode: _editMode,
              showMetadata: _showMetadata,
              onToggleEdit: () =>
                  setState(() => _editMode = !_editMode),
              onToggleMetadata: () =>
                  setState(() => _showMetadata = !_showMetadata),
              onExport: () => _exportContent(content),
            ),
            const Divider(height: 1, color: CodeOpsColors.border),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ScribeEditor(
                      key: ValueKey(
                        '${widget.documentId}-$_editMode-'
                        '${latestVersion?.versionNumber}',
                      ),
                      content: _editMode && _editorContent.isNotEmpty
                          ? _editorContent
                          : content,
                      language: _languageFromVersion(latestVersion),
                      readOnly: !_editMode,
                      onChanged: _editMode
                          ? (v) => setState(() => _editorContent = v)
                          : null,
                    ),
                  ),
                  if (_showMetadata) ...[
                    const VerticalDivider(
                        width: 1, color: CodeOpsColors.border),
                    SizedBox(
                      width: 260,
                      child: _MetadataSidebar(
                        documentId: widget.documentId,
                        version: latestVersion,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _exportContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _languageFromVersion(ProjectDocumentVersion? version) {
    // Infer from content or default to markdown
    final content = version?.content ?? '';
    if (content.trimLeft().startsWith('openapi:') ||
        content.trimLeft().startsWith('swagger:')) {
      return 'yaml';
    }
    return 'markdown';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _DetailToolbar extends StatelessWidget {
  final String documentId;
  final ProjectDocumentVersion? version;
  final bool editMode;
  final bool showMetadata;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleMetadata;
  final VoidCallback onExport;

  const _DetailToolbar({
    required this.documentId,
    required this.version,
    required this.editMode,
    required this.showMetadata,
    required this.onToggleEdit,
    required this.onToggleMetadata,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Breadcrumb
          GestureDetector(
            onTap: () => context.go('/mcp/documents'),
            child: const Text(
              'Documents',
              style: TextStyle(
                fontSize: 12,
                color: CodeOpsColors.primary,
              ),
            ),
          ),
          const Text(' / ',
              style: TextStyle(
                  fontSize: 12, color: CodeOpsColors.textTertiary)),
          Expanded(
            child: Text(
              'Document',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
          // Version badge
          if (version != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: CodeOpsColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'v${version!.versionNumber}',
                style: const TextStyle(
                  fontSize: 10,
                  color: CodeOpsColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Edit toggle
          IconButton(
            onPressed: onToggleEdit,
            icon: Icon(
              editMode ? Icons.visibility : Icons.edit_outlined,
              size: 18,
            ),
            tooltip: editMode ? 'View Mode' : 'Edit Mode',
            color: CodeOpsColors.textSecondary,
          ),
          // Metadata toggle
          IconButton(
            onPressed: onToggleMetadata,
            icon: Icon(
              showMetadata ? Icons.info : Icons.info_outline,
              size: 18,
            ),
            tooltip: showMetadata ? 'Hide Metadata' : 'Show Metadata',
            color: CodeOpsColors.textSecondary,
          ),
          // Versions
          IconButton(
            onPressed: () =>
                context.go('/mcp/documents/$documentId/versions'),
            icon: const Icon(Icons.history, size: 18),
            tooltip: 'Version History',
            color: CodeOpsColors.textSecondary,
          ),
          // Export
          IconButton(
            onPressed: onExport,
            icon: const Icon(Icons.content_copy, size: 18),
            tooltip: 'Export',
            color: CodeOpsColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metadata Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _MetadataSidebar extends StatelessWidget {
  final String documentId;
  final ProjectDocumentVersion? version;

  const _MetadataSidebar({
    required this.documentId,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metadata',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _MetadataRow(
            label: 'Document ID',
            value: documentId,
          ),
          if (version != null) ...[
            _MetadataRow(
              label: 'Version',
              value: '${version!.versionNumber}',
            ),
            _MetadataRow(
              label: 'Author',
              value: version!.authorName ?? 'Unknown',
            ),
            _MetadataRow(
              label: 'Author Type',
              value: version!.authorType?.displayName ?? 'Unknown',
            ),
            if (version!.commitHash != null)
              _MetadataRow(
                label: 'Commit',
                value: version!.commitHash!.length > 8
                    ? version!.commitHash!.substring(0, 8)
                    : version!.commitHash!,
              ),
            if (version!.changeDescription != null)
              _MetadataRow(
                label: 'Description',
                value: version!.changeDescription!,
              ),
            if (version!.createdAt != null)
              _MetadataRow(
                label: 'Created',
                value: DateFormat.yMMMd()
                    .add_Hm()
                    .format(version!.createdAt!),
              ),
          ],
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: CodeOpsColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
