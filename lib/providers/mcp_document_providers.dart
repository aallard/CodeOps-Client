/// Document management providers for the MCP module.
///
/// Manages project selection, document list/detail state, version history,
/// filtering, staleness detection, and editing state for the document
/// management pages.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mcp_enums.dart';
import '../models/mcp_models.dart';
import 'mcp_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UI State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Selected project ID for the document browser.
final docBrowserProjectIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Selected document ID in the browser's left pane.
final docBrowserSelectedIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Whether the document viewer is in edit mode.
final docBrowserEditModeProvider =
    StateProvider.autoDispose<bool>((ref) => false);

/// Document type filter for the document list.
final docTypeFilterProvider =
    StateProvider.autoDispose<DocumentType?>((ref) => null);

/// Toggle to show only flagged documents.
final docFlaggedOnlyProvider =
    StateProvider.autoDispose<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all documents for the selected project in the browser.
final docBrowserListProvider =
    FutureProvider.autoDispose<List<ProjectDocument>>((ref) {
  final projectId = ref.watch(docBrowserProjectIdProvider);
  if (projectId == null) return Future.value([]);
  final api = ref.watch(mcpApiProvider);
  return api.getProjectDocuments(projectId: projectId);
});

/// Fetches document detail by project ID and document type.
///
/// Uses [mcpDocumentByTypeProvider] from [mcp_providers.dart].
/// The selected document from the list provides both `projectId` and
/// `documentType` needed for this lookup.
final docBrowserDetailProvider =
    FutureProvider.autoDispose<ProjectDocumentDetail?>((ref) {
  final docs =
      ref.watch(docBrowserListProvider).whenOrNull(data: (d) => d) ?? [];
  final selectedId = ref.watch(docBrowserSelectedIdProvider);
  if (selectedId == null || docs.isEmpty) return Future.value(null);

  final doc = docs.where((d) => d.id == selectedId).firstOrNull;
  if (doc == null || doc.projectId == null || doc.documentType == null) {
    return Future.value(null);
  }

  final api = ref.watch(mcpApiProvider);
  return api.getDocumentByType(
    projectId: doc.projectId!,
    documentType: doc.documentType!.toJson(),
  );
});

/// Fetches paginated version history for a document.
final docVersionsProvider = FutureProvider.autoDispose
    .family<List<ProjectDocumentVersion>, String>((ref, documentId) async {
  final api = ref.watch(mcpApiProvider);
  final page = await api.getDocumentVersions(documentId, size: 50);
  return page.content;
});

/// Fetches a specific version by document ID and version number.
final docVersionDetailProvider = FutureProvider.autoDispose
    .family<ProjectDocumentVersion,
        ({String documentId, int versionNumber})>((ref, params) {
  final api = ref.watch(mcpApiProvider);
  return api.getDocumentVersion(params.documentId, params.versionNumber);
});

// ─────────────────────────────────────────────────────────────────────────────
// Filtered / Derived Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Applies type and flagged filters to the document list.
final docFilteredListProvider =
    Provider.autoDispose<List<ProjectDocument>>((ref) {
  final docsAsync = ref.watch(docBrowserListProvider);
  final typeFilter = ref.watch(docTypeFilterProvider);
  final flaggedOnly = ref.watch(docFlaggedOnlyProvider);

  final docs = docsAsync.whenOrNull(data: (d) => d) ?? <ProjectDocument>[];

  return docs.where((d) {
    if (typeFilter != null && d.documentType != typeFilter) return false;
    if (flaggedOnly && d.isFlagged != true) return false;
    return true;
  }).toList();
});

/// Groups filtered documents by [DocumentType] for tree display.
final docGroupedByTypeProvider =
    Provider.autoDispose<Map<DocumentType, List<ProjectDocument>>>((ref) {
  final docs = ref.watch(docFilteredListProvider);
  final grouped = <DocumentType, List<ProjectDocument>>{};
  for (final doc in docs) {
    final type = doc.documentType ?? DocumentType.custom;
    grouped.putIfAbsent(type, () => []).add(doc);
  }
  return grouped;
});

// ─────────────────────────────────────────────────────────────────────────────
// Staleness Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Staleness status for a document.
enum DocumentStaleness {
  /// Recently updated (within last 48 hours).
  fresh,

  /// Not updated in 7+ days.
  stale,

  /// Manually flagged as needing attention.
  flagged;

  /// Human-readable display label.
  String get displayName => switch (this) {
        DocumentStaleness.fresh => 'Fresh',
        DocumentStaleness.stale => 'Stale',
        DocumentStaleness.flagged => 'Flagged',
      };
}

/// Computes the staleness of a [ProjectDocument].
DocumentStaleness computeStaleness(ProjectDocument doc) {
  if (doc.isFlagged == true) return DocumentStaleness.flagged;

  final updated = doc.updatedAt;
  if (updated == null) return DocumentStaleness.stale;

  final age = DateTime.now().difference(updated);
  if (age.inHours < 48) return DocumentStaleness.fresh;
  return DocumentStaleness.stale;
}
