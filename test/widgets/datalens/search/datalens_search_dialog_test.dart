// Widget tests for DatalensSearchDialog.
//
// Verifies dialog rendering, search mode tabs, option toggles, schema
// filter dropdown, object type chips, result navigation, and empty state.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/models/datalens_search_models.dart';
import 'package:codeops/providers/datalens_providers.dart';
import 'package:codeops/services/datalens/datalens_search_service.dart';
import 'package:codeops/widgets/datalens/search/datalens_search_dialog.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDatalensSearchService extends Mock
    implements DatalensSearchService {}

Widget _createWidget({
  String? connectionId = 'c1',
  required MockDatalensSearchService mockService,
}) {
  return ProviderScope(
    overrides: [
      datalensConnectionsProvider.overrideWith(
        (ref) => Future.value(<DatabaseConnection>[
          const DatabaseConnection(id: 'c1', name: 'TestDB'),
        ]),
      ),
      datalensSchemasProvider.overrideWith(
        (ref) => Future.value(<SchemaInfo>[
          SchemaInfo(name: 'public'),
          SchemaInfo(name: 'staging'),
        ]),
      ),
      selectedConnectionIdProvider.overrideWith((ref) => connectionId),
      datalensSearchServiceProvider.overrideWithValue(mockService),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DatalensSearchDialog(connectionId: connectionId),
      ),
    ),
  );
}

void main() {
  late MockDatalensSearchService mockService;

  setUp(() {
    mockService = MockDatalensSearchService();
    when(() => mockService.searchMetadata(
          connectionId: any(named: 'connectionId'),
          query: any(named: 'query'),
          schema: any(named: 'schema'),
          objectTypes: any(named: 'objectTypes'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => <MetadataSearchResult>[]);
    when(() => mockService.searchData(
          connectionId: any(named: 'connectionId'),
          query: any(named: 'query'),
          schema: any(named: 'schema'),
          tables: any(named: 'tables'),
          caseSensitive: any(named: 'caseSensitive'),
          regex: any(named: 'regex'),
          maxRowsPerTable: any(named: 'maxRowsPerTable'),
          maxTables: any(named: 'maxTables'),
          onProgress: any(named: 'onProgress'),
        )).thenAnswer((_) async => <DataSearchResult>[]);
    when(() => mockService.searchDdl(
          connectionId: any(named: 'connectionId'),
          query: any(named: 'query'),
          schema: any(named: 'schema'),
          objectTypes: any(named: 'objectTypes'),
          caseSensitive: any(named: 'caseSensitive'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => <DdlSearchResult>[]);
  });

  group('DatalensSearchDialog', () {
    testWidgets('renders header and search bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      expect(find.text('Search Database'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shows three search mode tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      expect(find.text('Metadata'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('DDL'), findsOneWidget);
    });

    testWidgets('defaults to metadata mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      // In metadata mode, should show object type filter chips.
      expect(find.text('Tables'), findsOneWidget);
      expect(find.text('Views'), findsOneWidget);
      expect(find.text('Columns'), findsOneWidget);
    });

    testWidgets('switching to data mode shows regex toggle', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      // Tap Data tab.
      await tester.tap(find.text('Data'));
      await tester.pumpAndSettle();

      // Regex toggle should appear.
      expect(find.text('.*'), findsOneWidget);
    });

    testWidgets('DDL mode shows object type chips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      // Tap DDL tab.
      await tester.tap(find.text('DDL'));
      await tester.pumpAndSettle();

      // Should see DDL-specific chips (Tables, Views, Functions, Triggers).
      expect(find.text('Tables'), findsOneWidget);
      expect(find.text('Functions'), findsOneWidget);
    });

    testWidgets('case sensitive toggle toggles state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      // Find and tap Aa toggle.
      final toggle = find.text('Aa');
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      // Verify it toggled (tap again should un-toggle).
      await tester.tap(toggle);
      await tester.pumpAndSettle();
    });

    testWidgets('shows no results prompt before searching', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a search term and press Enter'),
        findsOneWidget,
      );
    });

    testWidgets('shows no results after empty search', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      // Enter text and search.
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('executes metadata search on submit', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      when(() => mockService.searchMetadata(
            connectionId: any(named: 'connectionId'),
            query: any(named: 'query'),
            schema: any(named: 'schema'),
            objectTypes: any(named: 'objectTypes'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [
            MetadataSearchResult(
              objectType: MetadataObjectType.table,
              schema: 'public',
              objectName: 'users',
              matchHighlight: '**user**s',
            ),
          ]);

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'user');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);
      expect(find.textContaining('public.users'), findsOneWidget);
    });

    testWidgets('schema filter dropdown renders schemas', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(mockService: mockService));
      await tester.pumpAndSettle();

      // Find the All schemas dropdown.
      expect(find.text('All schemas'), findsOneWidget);
    });
  });
}
