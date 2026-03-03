// Tests for MCP document management providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/providers/mcp_document_providers.dart';

void main() {
  final documents = [
    ProjectDocument(
      id: 'doc-1',
      documentType: DocumentType.claudeMd,
      isFlagged: false,
      projectId: 'proj-1',
      updatedAt: DateTime.now(),
    ),
    ProjectDocument(
      id: 'doc-2',
      documentType: DocumentType.auditMd,
      isFlagged: true,
      flagReason: 'Stale',
      projectId: 'proj-1',
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ProjectDocument(
      id: 'doc-3',
      documentType: DocumentType.openapiYaml,
      isFlagged: false,
      projectId: 'proj-1',
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  ProviderContainer createContainer({
    DocumentType? typeFilter,
    bool flaggedOnly = false,
  }) {
    return ProviderContainer(
      overrides: [
        docBrowserListProvider.overrideWith(
          (ref) => Future.value(documents),
        ),
        if (typeFilter != null)
          docTypeFilterProvider.overrideWith((ref) => typeFilter),
        if (flaggedOnly)
          docFlaggedOnlyProvider.overrideWith((ref) => true),
      ],
    );
  }

  group('computeStaleness', () {
    test('returns fresh for recently updated doc', () {
      final doc = ProjectDocument(
        id: 'x',
        isFlagged: false,
        updatedAt: DateTime.now(),
      );
      expect(computeStaleness(doc), DocumentStaleness.fresh);
    });

    test('returns stale for old doc', () {
      final doc = ProjectDocument(
        id: 'x',
        isFlagged: false,
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(computeStaleness(doc), DocumentStaleness.stale);
    });

    test('returns flagged for flagged doc', () {
      final doc = ProjectDocument(
        id: 'x',
        isFlagged: true,
        flagReason: 'Needs review',
        updatedAt: DateTime.now(),
      );
      expect(computeStaleness(doc), DocumentStaleness.flagged);
    });
  });

  group('docFilteredListProvider', () {
    test('returns all docs when no filters', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(docBrowserListProvider.future);

      final filtered = container.read(docFilteredListProvider);
      expect(filtered.length, 3);
    });

    test('filters by document type', () async {
      final container =
          createContainer(typeFilter: DocumentType.claudeMd);
      addTearDown(container.dispose);

      await container.read(docBrowserListProvider.future);

      final filtered = container.read(docFilteredListProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'doc-1');
    });

    test('filters by flagged only', () async {
      final container = createContainer(flaggedOnly: true);
      addTearDown(container.dispose);

      await container.read(docBrowserListProvider.future);

      final filtered = container.read(docFilteredListProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'doc-2');
    });
  });

  group('docGroupedByTypeProvider', () {
    test('groups documents by type', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(docBrowserListProvider.future);

      final grouped = container.read(docGroupedByTypeProvider);
      expect(grouped.keys.length, 3);
      expect(grouped[DocumentType.claudeMd]?.length, 1);
      expect(grouped[DocumentType.auditMd]?.length, 1);
      expect(grouped[DocumentType.openapiYaml]?.length, 1);
    });
  });
}
