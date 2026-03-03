/// MCP document version history page.
///
/// Displays at `/mcp/documents/:documentId/versions` with a version list
/// on the left (number, author, timestamp, commit hash, description) and a
/// content viewer on the right. Supports viewing individual versions and
/// diffing two selected versions with [ScribeDiffEditor].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/mcp_enums.dart';
import '../../models/mcp_models.dart';
import '../../models/scribe_diff_models.dart';
import '../../providers/mcp_document_providers.dart';
import '../../services/data/scribe_diff_service.dart';
import '../../theme/colors.dart';
import '../../widgets/scribe/scribe_diff_editor.dart';
import '../../widgets/scribe/scribe_editor.dart';
import '../../widgets/shared/error_panel.dart';

/// The MCP document version history page.
class DocumentVersionsPage extends ConsumerStatefulWidget {
  /// The document ID from the route parameter.
  final String documentId;

  /// Creates a [DocumentVersionsPage].
  const DocumentVersionsPage({super.key, required this.documentId});

  @override
  ConsumerState<DocumentVersionsPage> createState() =>
      _DocumentVersionsPageState();
}

class _DocumentVersionsPageState
    extends ConsumerState<DocumentVersionsPage> {
  int? _selectedVersionNumber;
  int? _diffLeftVersion;
  int? _diffRightVersion;
  bool _diffMode = false;
  DiffViewMode _diffViewMode = DiffViewMode.sideBySide;
  bool _collapseUnchanged = true;

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
      data: (versions) => Column(
        children: [
          _VersionsHeader(
            documentId: widget.documentId,
            diffMode: _diffMode,
            onToggleDiff: () => setState(() {
              _diffMode = !_diffMode;
              if (_diffMode && versions.length >= 2) {
                _diffLeftVersion ??= versions[1].versionNumber;
                _diffRightVersion ??= versions[0].versionNumber;
              }
            }),
            onRefresh: _refresh,
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — version list
                SizedBox(
                  width: 320,
                  child: _VersionList(
                    versions: versions,
                    selectedVersion: _selectedVersionNumber,
                    diffMode: _diffMode,
                    diffLeft: _diffLeftVersion,
                    diffRight: _diffRightVersion,
                    onSelect: (v) =>
                        setState(() => _selectedVersionNumber = v),
                    onDiffLeftSelect: (v) =>
                        setState(() => _diffLeftVersion = v),
                    onDiffRightSelect: (v) =>
                        setState(() => _diffRightVersion = v),
                  ),
                ),
                const VerticalDivider(
                    width: 1, color: CodeOpsColors.border),
                // Right — content or diff view
                Expanded(
                  child: _diffMode
                      ? _DiffView(
                          documentId: widget.documentId,
                          leftVersion: _diffLeftVersion,
                          rightVersion: _diffRightVersion,
                          viewMode: _diffViewMode,
                          collapseUnchanged: _collapseUnchanged,
                          onViewModeChanged: (m) =>
                              setState(() => _diffViewMode = m),
                          onCollapseChanged: (v) =>
                              setState(() => _collapseUnchanged = v),
                        )
                      : _VersionContentView(
                          documentId: widget.documentId,
                          versionNumber: _selectedVersionNumber,
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
// Versions Header
// ─────────────────────────────────────────────────────────────────────────────

class _VersionsHeader extends StatelessWidget {
  final String documentId;
  final bool diffMode;
  final VoidCallback onToggleDiff;
  final VoidCallback onRefresh;

  const _VersionsHeader({
    required this.documentId,
    required this.diffMode,
    required this.onToggleDiff,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/mcp/documents'),
            child: const Text(
              'Documents',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.primary),
            ),
          ),
          const Text(' / ',
              style: TextStyle(
                  fontSize: 12, color: CodeOpsColors.textTertiary)),
          GestureDetector(
            onTap: () => context.go('/mcp/documents/$documentId'),
            child: const Text(
              'Detail',
              style: TextStyle(fontSize: 12, color: CodeOpsColors.primary),
            ),
          ),
          const Text(' / ',
              style: TextStyle(
                  fontSize: 12, color: CodeOpsColors.textTertiary)),
          const Expanded(
            child: Text(
              'Version History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
          // Diff toggle
          FilterChip(
            label: Text(
              diffMode ? 'Exit Diff' : 'Compare',
              style: const TextStyle(fontSize: 11),
            ),
            selected: diffMode,
            onSelected: (_) => onToggleDiff(),
            selectedColor: CodeOpsColors.primary.withValues(alpha: 0.2),
            backgroundColor: CodeOpsColors.surface,
            side: BorderSide(
              color: diffMode
                  ? CodeOpsColors.primary
                  : CodeOpsColors.border,
            ),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh,
                size: 18, color: CodeOpsColors.textSecondary),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Version List
// ─────────────────────────────────────────────────────────────────────────────

class _VersionList extends StatelessWidget {
  final List<ProjectDocumentVersion> versions;
  final int? selectedVersion;
  final bool diffMode;
  final int? diffLeft;
  final int? diffRight;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onDiffLeftSelect;
  final ValueChanged<int> onDiffRightSelect;

  const _VersionList({
    required this.versions,
    required this.selectedVersion,
    required this.diffMode,
    required this.diffLeft,
    required this.diffRight,
    required this.onSelect,
    required this.onDiffLeftSelect,
    required this.onDiffRightSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (versions.isEmpty) {
      return const Center(
        child: Text(
          'No versions found',
          style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 12),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: versions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: CodeOpsColors.border),
      itemBuilder: (context, i) {
        final v = versions[i];
        final vNum = v.versionNumber ?? i + 1;
        final isSelected = selectedVersion == vNum;

        return InkWell(
          onTap: diffMode ? null : () => onSelect(vNum),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: isSelected && !diffMode
                ? CodeOpsColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            child: Row(
              children: [
                if (diffMode) ...[
                  // Left version selector
                  _DiffSelector(
                    label: 'L',
                    isSelected: diffLeft == vNum,
                    onTap: () => onDiffLeftSelect(vNum),
                  ),
                  const SizedBox(width: 4),
                  // Right version selector
                  _DiffSelector(
                    label: 'R',
                    isSelected: diffRight == vNum,
                    onTap: () => onDiffRightSelect(vNum),
                  ),
                  const SizedBox(width: 4),
                ],
                // Version badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        CodeOpsColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'v$vNum',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (v.changeDescription != null)
                        Text(
                          v.changeDescription!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CodeOpsColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Row(
                        children: [
                          // Author badge
                          if (v.authorType != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: v.authorType == AuthorType.ai
                                    ? CodeOpsColors.primary
                                        .withValues(alpha: 0.1)
                                    : CodeOpsColors.success
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                v.authorType!.displayName,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: v.authorType == AuthorType.ai
                                      ? CodeOpsColors.primary
                                      : CodeOpsColors.success,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (v.authorName != null)
                            Text(
                              v.authorName!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: CodeOpsColors.textTertiary,
                              ),
                            ),
                          const Spacer(),
                          if (v.createdAt != null)
                            Text(
                              DateFormat.MMMd()
                                  .add_Hm()
                                  .format(v.createdAt!),
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: CodeOpsColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                      if (v.commitHash != null)
                        Text(
                          v.commitHash!.length > 8
                              ? v.commitHash!.substring(0, 8)
                              : v.commitHash!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diff Selector (replaces deprecated Radio)
// ─────────────────────────────────────────────────────────────────────────────

class _DiffSelector extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiffSelector({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? CodeOpsColors.primary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? CodeOpsColors.primary
                : CodeOpsColors.border,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : CodeOpsColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Version Content View
// ─────────────────────────────────────────────────────────────────────────────

class _VersionContentView extends ConsumerWidget {
  final String documentId;
  final int? versionNumber;

  const _VersionContentView({
    required this.documentId,
    required this.versionNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (versionNumber == null) {
      return const Center(
        child: Text(
          'Select a version to view',
          style:
              TextStyle(color: CodeOpsColors.textTertiary, fontSize: 13),
        ),
      );
    }

    final versionAsync = ref.watch(docVersionDetailProvider(
      (documentId: documentId, versionNumber: versionNumber!),
    ));

    return versionAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2, color: CodeOpsColors.primary),
      ),
      error: (e, _) => ErrorPanel.fromException(e),
      data: (version) => ScribeEditor(
        content: version.content ?? '',
        language: 'markdown',
        readOnly: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diff View
// ─────────────────────────────────────────────────────────────────────────────

class _DiffView extends ConsumerWidget {
  final String documentId;
  final int? leftVersion;
  final int? rightVersion;
  final DiffViewMode viewMode;
  final bool collapseUnchanged;
  final ValueChanged<DiffViewMode> onViewModeChanged;
  final ValueChanged<bool> onCollapseChanged;

  const _DiffView({
    required this.documentId,
    required this.leftVersion,
    required this.rightVersion,
    required this.viewMode,
    required this.collapseUnchanged,
    required this.onViewModeChanged,
    required this.onCollapseChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (leftVersion == null || rightVersion == null) {
      return const Center(
        child: Text('Select two versions to compare',
            style: TextStyle(
                color: CodeOpsColors.textTertiary, fontSize: 13)),
      );
    }

    if (leftVersion == rightVersion) {
      return const Center(
        child: Text('Select different versions to compare',
            style: TextStyle(
                color: CodeOpsColors.textTertiary, fontSize: 13)),
      );
    }

    final leftAsync = ref.watch(docVersionDetailProvider(
      (documentId: documentId, versionNumber: leftVersion!),
    ));
    final rightAsync = ref.watch(docVersionDetailProvider(
      (documentId: documentId, versionNumber: rightVersion!),
    ));

    return leftAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2, color: CodeOpsColors.primary),
      ),
      error: (e, _) => ErrorPanel.fromException(e),
      data: (left) => rightAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: CodeOpsColors.primary),
        ),
        error: (e, _) => ErrorPanel.fromException(e),
        data: (right) {
          final diffService = ScribeDiffService();
          final diffState = diffService.computeDiff(
            leftTabId: 'v$leftVersion',
            rightTabId: 'v$rightVersion',
            leftText: left.content ?? '',
            rightText: right.content ?? '',
          );

          final displayLines = collapseUnchanged
              ? diffService.collapseUnchanged(diffState.lines)
              : diffState.lines;

          return ScribeDiffEditor(
            diffState: diffState,
            viewMode: viewMode,
            collapseUnchanged: collapseUnchanged,
            displayLines: displayLines,
            onViewModeChanged: onViewModeChanged,
            onCollapseChanged: onCollapseChanged,
            leftTitle: 'v$leftVersion',
            rightTitle: 'v$rightVersion',
          );
        },
      ),
    );
  }
}
