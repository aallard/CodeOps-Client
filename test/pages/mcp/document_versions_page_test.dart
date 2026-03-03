// Widget tests for DocumentVersionsPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';
import 'package:codeops/pages/mcp/document_versions_page.dart';
import 'package:codeops/providers/mcp_document_providers.dart';

void main() {
  const documentId = 'doc-1';

  final versions = [
    ProjectDocumentVersion(
      id: 'ver-3',
      versionNumber: 3,
      content: '# CLAUDE.md\n\nVersion 3.',
      authorType: AuthorType.human,
      authorName: 'Adam',
      commitHash: 'abc12345',
      changeDescription: 'Updated instructions',
      createdAt: DateTime.now(),
    ),
    ProjectDocumentVersion(
      id: 'ver-2',
      versionNumber: 2,
      content: '# CLAUDE.md\n\nVersion 2.',
      authorType: AuthorType.ai,
      authorName: 'Claude',
      commitHash: 'def67890',
      changeDescription: 'AI regenerated',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ProjectDocumentVersion(
      id: 'ver-1',
      versionNumber: 1,
      content: '# CLAUDE.md\n\nInitial.',
      authorType: AuthorType.human,
      authorName: 'Adam',
      commitHash: '111222333',
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
        docVersionDetailProvider.overrideWith((ref, params) {
          final version = (versionList ?? versions).firstWhere(
            (v) => v.versionNumber == params.versionNumber,
            orElse: () => versions.first,
          );
          return Future.value(version);
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DocumentVersionsPage(documentId: documentId),
        ),
      ),
    );
  }

  group('DocumentVersionsPage', () {
    testWidgets('renders header with breadcrumb', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Version History'), findsOneWidget);
    });

    testWidgets('renders version list with badges', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('v3'), findsOneWidget);
      expect(find.text('v2'), findsOneWidget);
      expect(find.text('v1'), findsOneWidget);
    });

    testWidgets('renders version descriptions', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Updated instructions'), findsOneWidget);
      expect(find.text('AI regenerated'), findsOneWidget);
      expect(find.text('Initial creation'), findsOneWidget);
    });

    testWidgets('renders author badges', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Human'), findsWidgets);
      expect(find.text('AI'), findsWidgets);
    });

    testWidgets('renders compare button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Compare'), findsOneWidget);
    });

    testWidgets('renders select prompt when no version selected',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select a version to view'), findsOneWidget);
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
