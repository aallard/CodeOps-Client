// Widget tests for DocumentDetailPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/pages/mcp/document_detail_page.dart';
import 'package:codeops/providers/mcp_document_providers.dart';
import 'package:codeops/widgets/scribe/scribe_editor.dart';

void main() {
  const documentId = 'doc-1';

  final versions = [
    ProjectDocumentVersion(
      id: 'ver-3',
      versionNumber: 3,
      content: '# CLAUDE.md\n\nVersion 3 content.',
      authorType: AuthorType.human,
      authorName: 'Adam',
      commitHash: 'abc12345def',
      changeDescription: 'Updated project instructions',
      createdAt: DateTime.now(),
    ),
    ProjectDocumentVersion(
      id: 'ver-2',
      versionNumber: 2,
      content: '# CLAUDE.md\n\nVersion 2 content.',
      authorType: AuthorType.ai,
      authorName: 'Claude',
      commitHash: '789012cdef',
      changeDescription: 'AI-generated update',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ProjectDocumentVersion(
      id: 'ver-1',
      versionNumber: 1,
      content: '# CLAUDE.md\n\nInitial content.',
      authorType: AuthorType.human,
      authorName: 'Adam',
      commitHash: 'aaa111bbb',
      changeDescription: 'Initial creation',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Widget createWidget({
    bool loading = false,
    bool error = false,
    List<ProjectDocumentVersion>? versionList,
  }) {
    return ProviderScope(
      overrides: [
        docVersionsProvider.overrideWith((ref, id) {
          if (loading) {
            return Completer<List<ProjectDocumentVersion>>().future;
          }
          if (error) {
            return Future<List<ProjectDocumentVersion>>.error(
                'Server error');
          }
          return Future.value(versionList ?? versions);
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DocumentDetailPage(documentId: documentId),
        ),
      ),
    );
  }

  group('DocumentDetailPage', () {
    testWidgets('renders breadcrumb and toolbar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Document'), findsOneWidget);
    });

    testWidgets('renders ScribeEditor with content', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ScribeEditor), findsOneWidget);
    });

    testWidgets('renders version badge', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('v3'), findsOneWidget);
    });

    testWidgets('renders edit toggle button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('renders export button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_copy), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(createWidget(loading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      await tester.pumpWidget(createWidget(error: true));
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
    });
  });
}
