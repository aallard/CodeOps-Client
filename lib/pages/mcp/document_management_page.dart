/// MCP document management page.
///
/// Displays at `/mcp/documents` with a two-pane layout: document tree
/// on the left and a viewer/editor on the right. Supports project
/// selection, document type grouping, staleness indicators, filtering,
/// editing with [ScribeEditor], and flag management.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/mcp_enums.dart';
import '../../models/mcp_models.dart';
import '../../models/project.dart';
import '../../providers/mcp_document_providers.dart';
import '../../providers/project_providers.dart';
import '../../providers/team_providers.dart' show selectedTeamIdProvider;
import '../../theme/colors.dart';
import '../../widgets/scribe/scribe_editor.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/error_panel.dart';

/// The MCP document management page.
class DocumentManagementPage extends ConsumerStatefulWidget {
  /// Creates a [DocumentManagementPage].
  const DocumentManagementPage({super.key});

  @override
  ConsumerState<DocumentManagementPage> createState() =>
      _DocumentManagementPageState();
}

class _DocumentManagementPageState
    extends ConsumerState<DocumentManagementPage> {
  String _editorContent = '';

  void _refresh() {
    ref.invalidate(docBrowserListProvider);
    ref.invalidate(docBrowserDetailProvider);
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(selectedTeamIdProvider);

    if (teamId == null) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No team selected',
        subtitle: 'Select a team to manage documents.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onRefresh: _refresh),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height - 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left pane — document tree
                SizedBox(
                  width: 320,
                  child: _LeftPane(onRefresh: _refresh),
                ),
                const SizedBox(width: 16),
                // Right pane — viewer/editor
                Expanded(
                  child: _RightPane(
                    editorContent: _editorContent,
                    onContentChanged: (v) =>
                        setState(() => _editorContent = v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;

  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.go('/mcp'),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: CodeOpsColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Document Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, color: CodeOpsColors.textSecondary),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left Pane — Project selector + Document tree
// ─────────────────────────────────────────────────────────────────────────────

class _LeftPane extends ConsumerWidget {
  final VoidCallback onRefresh;

  const _LeftPane({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(teamProjectsProvider);
    final selectedProjectId = ref.watch(docBrowserProjectIdProvider);
    final typeFilter = ref.watch(docTypeFilterProvider);
    final flaggedOnly = ref.watch(docFlaggedOnlyProvider);

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project selector
          Padding(
            padding: const EdgeInsets.all(12),
            child: projectsAsync.when(
              loading: () => const SizedBox(
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CodeOpsColors.primary,
                  ),
                ),
              ),
              error: (_, __) => const Text('Failed to load projects',
                  style: TextStyle(color: CodeOpsColors.error, fontSize: 12)),
              data: (projects) => _ProjectDropdown(
                projects: projects,
                selectedId: selectedProjectId,
                onChanged: (id) {
                  ref.read(docBrowserProjectIdProvider.notifier).state = id;
                  ref.read(docBrowserSelectedIdProvider.notifier).state = null;
                  ref.read(docBrowserEditModeProvider.notifier).state = false;
                },
              ),
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<DocumentType?>(
                    value: typeFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('All Types',
                        style: TextStyle(fontSize: 12)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: CodeOpsColors.textPrimary,
                    ),
                    dropdownColor: CodeOpsColors.surface,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Types'),
                      ),
                      for (final type in DocumentType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        ),
                    ],
                    onChanged: (v) =>
                        ref.read(docTypeFilterProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Flagged',
                      style: TextStyle(fontSize: 10)),
                  selected: flaggedOnly,
                  onSelected: (v) =>
                      ref.read(docFlaggedOnlyProvider.notifier).state = v,
                  selectedColor:
                      CodeOpsColors.error.withValues(alpha: 0.2),
                  backgroundColor: CodeOpsColors.surface,
                  side: BorderSide(
                    color: flaggedOnly
                        ? CodeOpsColors.error
                        : CodeOpsColors.border,
                  ),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Document tree
          Expanded(
            child: selectedProjectId == null
                ? const Center(
                    child: Text(
                      'Select a project',
                      style: TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  )
                : _DocumentTree(onRefresh: onRefresh),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project Dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectDropdown extends StatelessWidget {
  final List<Project> projects;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _ProjectDropdown({
    required this.projects,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      value: selectedId,
      isExpanded: true,
      underline: const SizedBox(),
      hint: const Text('Select Project',
          style: TextStyle(fontSize: 13, color: CodeOpsColors.textSecondary)),
      style: const TextStyle(
        fontSize: 13,
        color: CodeOpsColors.textPrimary,
      ),
      dropdownColor: CodeOpsColors.surface,
      items: [
        for (final p in projects)
          DropdownMenuItem(
            value: p.id,
            child: Text(p.name),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document Tree (grouped by type)
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentTree extends ConsumerWidget {
  final VoidCallback onRefresh;

  const _DocumentTree({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(docBrowserListProvider);

    return docsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: CodeOpsColors.primary,
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load documents',
                style: TextStyle(color: CodeOpsColors.error, fontSize: 12)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      ),
      data: (_) {
        final grouped = ref.watch(docGroupedByTypeProvider);

        if (grouped.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No documents found',
                style: TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }

        // Sort type groups in enum order
        final sortedTypes = DocumentType.values
            .where((t) => grouped.containsKey(t))
            .toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: [
            for (final type in sortedTypes) ...[
              _TypeGroupHeader(
                type: type,
                count: grouped[type]!.length,
              ),
              for (final doc in grouped[type]!)
                _DocumentListTile(doc: doc),
            ],
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Type Group Header
// ─────────────────────────────────────────────────────────────────────────────

class _TypeGroupHeader extends StatelessWidget {
  final DocumentType type;
  final int count;

  const _TypeGroupHeader({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Icon(
            _documentTypeIcon(type),
            size: 14,
            color: CodeOpsColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              type.displayName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: CodeOpsColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                color: CodeOpsColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document List Tile
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentListTile extends ConsumerWidget {
  final ProjectDocument doc;

  const _DocumentListTile({required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(docBrowserSelectedIdProvider);
    final isSelected = selectedId == doc.id;
    final staleness = computeStaleness(doc);

    return InkWell(
      onTap: () {
        ref.read(docBrowserSelectedIdProvider.notifier).state = doc.id;
        ref.read(docBrowserEditModeProvider.notifier).state = false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Row(
          children: [
            // Staleness indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _stalenessColor(staleness),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _documentDisplayName(doc),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: CodeOpsColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (doc.updatedAt != null)
                    Text(
                      DateFormat.yMMMd().add_Hm().format(doc.updatedAt!),
                      style: const TextStyle(
                        fontSize: 10,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            // Author badge
            if (doc.lastAuthorType != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: doc.lastAuthorType == AuthorType.ai
                      ? CodeOpsColors.primary.withValues(alpha: 0.15)
                      : CodeOpsColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  doc.lastAuthorType!.displayName,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: doc.lastAuthorType == AuthorType.ai
                        ? CodeOpsColors.primary
                        : CodeOpsColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right Pane — Viewer / Editor
// ─────────────────────────────────────────────────────────────────────────────

class _RightPane extends ConsumerWidget {
  final String editorContent;
  final ValueChanged<String> onContentChanged;

  const _RightPane({
    required this.editorContent,
    required this.onContentChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(docBrowserSelectedIdProvider);

    if (selectedId == null) {
      return Container(
        decoration: BoxDecoration(
          color: CodeOpsColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CodeOpsColors.border),
        ),
        child: const Center(
          child: Text(
            'Select a document to view',
            style: TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final detailAsync = ref.watch(docBrowserDetailProvider);
    final editMode = ref.watch(docBrowserEditModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CodeOpsColors.primary),
        ),
        error: (e, _) => ErrorPanel.fromException(e, onRetry: () {
          ref.invalidate(docBrowserDetailProvider);
        }),
        data: (detail) {
          if (detail == null) {
            return const Center(
              child: Text('Document not found',
                  style: TextStyle(color: CodeOpsColors.textTertiary)),
            );
          }

          return Column(
            children: [
              _ViewerToolbar(detail: detail),
              const Divider(height: 1, color: CodeOpsColors.border),
              Expanded(
                child: ScribeEditor(
                  key: ValueKey('${detail.id}-$editMode'),
                  content: editMode
                      ? (editorContent.isNotEmpty
                          ? editorContent
                          : detail.currentContent ?? '')
                      : detail.currentContent ?? '',
                  language: _languageForType(detail.documentType),
                  readOnly: !editMode,
                  onChanged: editMode ? onContentChanged : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Viewer Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _ViewerToolbar extends ConsumerWidget {
  final ProjectDocumentDetail detail;

  const _ViewerToolbar({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editMode = ref.watch(docBrowserEditModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Document type icon + name
          Icon(
            _documentTypeIcon(detail.documentType),
            size: 18,
            color: CodeOpsColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _detailDisplayName(detail),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                if (detail.lastUpdatedByName != null)
                  Text(
                    'Last updated by ${detail.lastUpdatedByName}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          // Staleness badge
          if (detail.isFlagged == true)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: CodeOpsColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag, size: 12, color: CodeOpsColors.error),
                  const SizedBox(width: 4),
                  Text(
                    detail.flagReason ?? 'Flagged',
                    style: const TextStyle(
                      fontSize: 10,
                      color: CodeOpsColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          // Edit toggle
          IconButton(
            onPressed: () {
              ref.read(docBrowserEditModeProvider.notifier).state = !editMode;
            },
            icon: Icon(
              editMode ? Icons.visibility : Icons.edit_outlined,
              size: 18,
            ),
            tooltip: editMode ? 'View Mode' : 'Edit Mode',
            color: CodeOpsColors.textSecondary,
          ),
          // Versions link
          if (detail.id != null)
            IconButton(
              onPressed: () => context.go(
                '/mcp/documents/${detail.id}/versions',
              ),
              icon:
                  const Icon(Icons.history, size: 18),
              tooltip: 'Version History',
              color: CodeOpsColors.textSecondary,
            ),
          // Detail link
          if (detail.id != null)
            IconButton(
              onPressed: () => context.go(
                '/mcp/documents/${detail.id}',
              ),
              icon: const Icon(Icons.open_in_full, size: 18),
              tooltip: 'Full Screen',
              color: CodeOpsColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Document Dialog
// ─────────────────────────────────────────────────────────────────────────────

/// Dialog for creating a new project document.
class NewDocumentDialog extends StatefulWidget {
  /// Project ID to create the document in.
  final String projectId;

  /// Creates a [NewDocumentDialog].
  const NewDocumentDialog({super.key, required this.projectId});

  @override
  State<NewDocumentDialog> createState() => _NewDocumentDialogState();
}

class _NewDocumentDialogState extends State<NewDocumentDialog> {
  DocumentType _selectedType = DocumentType.custom;
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: const Text('New Document',
          style: TextStyle(color: CodeOpsColors.textPrimary)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type',
                style: TextStyle(
                    fontSize: 12, color: CodeOpsColors.textSecondary)),
            const SizedBox(height: 4),
            DropdownButton<DocumentType>(
              value: _selectedType,
              isExpanded: true,
              dropdownColor: CodeOpsColors.surface,
              style: const TextStyle(
                  fontSize: 13, color: CodeOpsColors.textPrimary),
              items: [
                for (final type in DocumentType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            if (_selectedType == DocumentType.custom) ...[
              const SizedBox(height: 12),
              const Text('Name',
                  style: TextStyle(
                      fontSize: 12, color: CodeOpsColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: const TextStyle(
                    fontSize: 13, color: CodeOpsColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Document name',
                  isDense: true,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Initial Content',
                style: TextStyle(
                    fontSize: 12, color: CodeOpsColors.textSecondary)),
            const SizedBox(height: 4),
            TextField(
              controller: _contentController,
              style: const TextStyle(
                  fontSize: 13, color: CodeOpsColors.textPrimary),
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Paste initial content (optional)',
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'documentType': _selectedType.toJson(),
              if (_selectedType == DocumentType.custom &&
                  _nameController.text.isNotEmpty)
                'customName': _nameController.text,
              if (_contentController.text.isNotEmpty)
                'initialContent': _contentController.text,
            });
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns an icon for a [DocumentType].
IconData _documentTypeIcon(DocumentType? type) => switch (type) {
      DocumentType.claudeMd => Icons.smart_toy_outlined,
      DocumentType.conventionsMd => Icons.rule_outlined,
      DocumentType.architectureMd => Icons.architecture_outlined,
      DocumentType.auditMd => Icons.fact_check_outlined,
      DocumentType.openapiYaml => Icons.api_outlined,
      DocumentType.custom => Icons.insert_drive_file_outlined,
      null => Icons.insert_drive_file_outlined,
    };

/// Returns a color for [DocumentStaleness].
Color _stalenessColor(DocumentStaleness staleness) => switch (staleness) {
      DocumentStaleness.fresh => CodeOpsColors.success,
      DocumentStaleness.stale => CodeOpsColors.warning,
      DocumentStaleness.flagged => CodeOpsColors.error,
    };

/// Returns the editor language mode for a document type.
String _languageForType(DocumentType? type) => switch (type) {
      DocumentType.openapiYaml => 'yaml',
      _ => 'markdown',
    };

/// Display name for a [ProjectDocument].
String _documentDisplayName(ProjectDocument doc) {
  if (doc.documentType == DocumentType.custom && doc.customName != null) {
    return doc.customName!;
  }
  return doc.documentType?.displayName ?? 'Document';
}

/// Display name for a [ProjectDocumentDetail].
String _detailDisplayName(ProjectDocumentDetail detail) {
  if (detail.documentType == DocumentType.custom &&
      detail.customName != null) {
    return detail.customName!;
  }
  return detail.documentType?.displayName ?? 'Document';
}
