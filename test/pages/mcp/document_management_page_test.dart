// Widget tests for DocumentManagementPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/pages/mcp/document_management_page.dart';
import 'package:codeops/providers/mcp_document_providers.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:codeops/providers/team_providers.dart'
    show selectedTeamIdProvider;

void main() {
  const teamId = 'team-1';

  final projects = [
    Project(
      id: 'proj-1',
      teamId: teamId,
      name: 'CodeOps-Server',
    ),
    Project(
      id: 'proj-2',
      teamId: teamId,
      name: 'CodeOps-Client',
    ),
  ];

  final documents = [
    ProjectDocument(
      id: 'doc-1',
      documentType: DocumentType.claudeMd,
      lastAuthorType: AuthorType.human,
      isFlagged: false,
      projectId: 'proj-1',
      lastUpdatedByName: 'Adam',
      updatedAt: DateTime.now(),
    ),
    ProjectDocument(
      id: 'doc-2',
      documentType: DocumentType.auditMd,
      lastAuthorType: AuthorType.ai,
      isFlagged: true,
      flagReason: 'Stale after session',
      projectId: 'proj-1',
      lastUpdatedByName: 'Claude',
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ProjectDocument(
      id: 'doc-3',
      documentType: DocumentType.openapiYaml,
      lastAuthorType: AuthorType.ai,
      isFlagged: false,
      projectId: 'proj-1',
      lastUpdatedByName: 'Claude',
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ProjectDocument(
      id: 'doc-4',
      documentType: DocumentType.custom,
      customName: 'README.md',
      lastAuthorType: AuthorType.human,
      isFlagged: false,
      projectId: 'proj-1',
      updatedAt: DateTime.now(),
    ),
  ];

  final documentDetail = ProjectDocumentDetail(
    id: 'doc-1',
    documentType: DocumentType.claudeMd,
    currentContent: '# CLAUDE.md\n\nProject instructions here.',
    lastAuthorType: AuthorType.human,
    isFlagged: false,
    projectId: 'proj-1',
    lastUpdatedByName: 'Adam',
  );

  Widget createWidget({
    String? selectedTeamId = teamId,
    String? selectedProjectId,
    String? selectedDocId,
    bool docLoading = false,
    bool docError = false,
  }) {
    return ProviderScope(
      overrides: [
        selectedTeamIdProvider.overrideWith((ref) => selectedTeamId),
        teamProjectsProvider.overrideWith(
          (ref) => Future.value(projects),
        ),
        if (selectedProjectId != null)
          docBrowserProjectIdProvider.overrideWith(
            (ref) => selectedProjectId,
          ),
        docBrowserListProvider.overrideWith((ref) {
          if (docLoading) {
            return Completer<List<ProjectDocument>>().future;
          }
          if (docError) {
            return Future<List<ProjectDocument>>.error('Server error');
          }
          return Future.value(documents);
        }),
        if (selectedDocId != null) ...[
          docBrowserSelectedIdProvider.overrideWith(
            (ref) => selectedDocId,
          ),
          docBrowserDetailProvider.overrideWith(
            (ref) => Future.value(documentDetail),
          ),
        ],
      ],
      child: const MaterialApp(
        home: Scaffold(body: DocumentManagementPage()),
      ),
    );
  }

  group('DocumentManagementPage', () {
    testWidgets('renders page header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Document Management'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('renders project selector', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select Project'), findsOneWidget);
    });

    testWidgets('renders document tree with type grouping',
        (tester) async {
      await tester.pumpWidget(
          createWidget(selectedProjectId: 'proj-1'));
      await tester.pumpAndSettle();

      // Type group headers
      expect(find.text('CLAUDE.md'), findsWidgets);
      expect(find.text('Audit'), findsWidgets);
      expect(find.text('OpenAPI'), findsWidgets);
      expect(find.text('Custom'), findsWidgets);
    });

    testWidgets('renders staleness indicators', (tester) async {
      await tester.pumpWidget(
          createWidget(selectedProjectId: 'proj-1'));
      await tester.pumpAndSettle();

      // Green and red staleness dots should exist
      // (circle decoration containers)
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
        findsWidgets,
      );
    });

    testWidgets('renders author badges', (tester) async {
      await tester.pumpWidget(
          createWidget(selectedProjectId: 'proj-1'));
      await tester.pumpAndSettle();

      expect(find.text('Human'), findsWidgets);
      expect(find.text('AI'), findsWidgets);
    });

    testWidgets('renders flagged filter chip', (tester) async {
      await tester.pumpWidget(
          createWidget(selectedProjectId: 'proj-1'));
      await tester.pumpAndSettle();

      expect(find.text('Flagged'), findsOneWidget);
    });

    testWidgets('renders type filter dropdown', (tester) async {
      await tester.pumpWidget(
          createWidget(selectedProjectId: 'proj-1'));
      await tester.pumpAndSettle();

      expect(find.text('All Types'), findsOneWidget);
    });

    testWidgets('shows select prompt when no document selected',
        (tester) async {
      await tester.pumpWidget(
          createWidget(selectedProjectId: 'proj-1'));
      await tester.pumpAndSettle();

      expect(find.text('Select a document to view'), findsOneWidget);
    });

    testWidgets('renders viewer when document selected',
        (tester) async {
      await tester.pumpWidget(createWidget(
        selectedProjectId: 'proj-1',
        selectedDocId: 'doc-1',
      ));
      await tester.pumpAndSettle();

      expect(find.text('CLAUDE.md'), findsWidgets);
      expect(find.text('Last updated by Adam'), findsOneWidget);
    });

    testWidgets('renders empty state when no team selected',
        (tester) async {
      await tester.pumpWidget(createWidget(selectedTeamId: null));
      await tester.pumpAndSettle();

      expect(find.text('No team selected'), findsOneWidget);
    });
  });
}
