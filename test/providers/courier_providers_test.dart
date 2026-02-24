// Tests for courier providers.
//
// Verifies singleton provider creation, FutureProvider types,
// StateProvider defaults, and state updates for all Courier providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/services/cloud/courier_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // Core singleton providers
  // ─────────────────────────────────────────────────────────────────────────

  group('Core providers', () {
    test('courierApiProvider creates CourierApiService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final api = container.read(courierApiProvider);

      expect(api, isA<CourierApiService>());
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Collections
  // ─────────────────────────────────────────────────────────────────────────

  group('Collection FutureProvider types', () {
    test('courierCollectionsProvider is a FutureProvider', () {
      expect(
        courierCollectionsProvider,
        isA<FutureProvider<List<CollectionSummaryResponse>>>(),
      );
    });

    test('courierCollectionsPagedProvider is a FutureProvider', () {
      expect(
        courierCollectionsPagedProvider,
        isA<FutureProvider<PageResponse<CollectionSummaryResponse>>>(),
      );
    });

    test('courierCollectionDetailProvider is a FutureProvider.family', () {
      expect(
        courierCollectionDetailProvider,
        isA<FutureProviderFamily<CollectionResponse, String>>(),
      );
    });

    test('courierCollectionSearchProvider is a FutureProvider', () {
      expect(
        courierCollectionSearchProvider,
        isA<FutureProvider<List<CollectionSummaryResponse>>>(),
      );
    });

    test('courierCollectionTreeProvider is a FutureProvider.family', () {
      expect(
        courierCollectionTreeProvider,
        isA<FutureProviderFamily<List<FolderTreeResponse>, String>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Folders
  // ─────────────────────────────────────────────────────────────────────────

  group('Folder FutureProvider types', () {
    test('courierFolderDetailProvider is a FutureProvider.family', () {
      expect(
        courierFolderDetailProvider,
        isA<FutureProviderFamily<FolderResponse, String>>(),
      );
    });

    test('courierSubfoldersProvider is a FutureProvider.family', () {
      expect(
        courierSubfoldersProvider,
        isA<FutureProviderFamily<List<FolderResponse>, String>>(),
      );
    });

    test('courierFolderRequestsProvider is a FutureProvider.family', () {
      expect(
        courierFolderRequestsProvider,
        isA<FutureProviderFamily<List<RequestSummaryResponse>, String>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Requests
  // ─────────────────────────────────────────────────────────────────────────

  group('Request FutureProvider types', () {
    test('courierRequestDetailProvider is a FutureProvider.family', () {
      expect(
        courierRequestDetailProvider,
        isA<FutureProviderFamily<RequestResponse, String>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Environments
  // ─────────────────────────────────────────────────────────────────────────

  group('Environment FutureProvider types', () {
    test('courierEnvironmentsProvider is a FutureProvider', () {
      expect(
        courierEnvironmentsProvider,
        isA<FutureProvider<List<EnvironmentResponse>>>(),
      );
    });

    test('courierActiveEnvironmentProvider is a FutureProvider', () {
      expect(
        courierActiveEnvironmentProvider,
        isA<FutureProvider<EnvironmentResponse?>>(),
      );
    });

    test('courierEnvironmentDetailProvider is a FutureProvider.family', () {
      expect(
        courierEnvironmentDetailProvider,
        isA<FutureProviderFamily<EnvironmentResponse, String>>(),
      );
    });

    test('courierEnvironmentVariablesProvider is a FutureProvider.family', () {
      expect(
        courierEnvironmentVariablesProvider,
        isA<FutureProviderFamily<List<EnvironmentVariableResponse>, String>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Global Variables
  // ─────────────────────────────────────────────────────────────────────────

  group('Global Variable FutureProvider types', () {
    test('courierGlobalVariablesProvider is a FutureProvider', () {
      expect(
        courierGlobalVariablesProvider,
        isA<FutureProvider<List<GlobalVariableResponse>>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — History
  // ─────────────────────────────────────────────────────────────────────────

  group('History FutureProvider types', () {
    test('courierHistoryProvider is a FutureProvider', () {
      expect(
        courierHistoryProvider,
        isA<FutureProvider<PageResponse<RequestHistoryResponse>>>(),
      );
    });

    test('courierHistoryDetailProvider is a FutureProvider.family', () {
      expect(
        courierHistoryDetailProvider,
        isA<FutureProviderFamily<RequestHistoryDetailResponse, String>>(),
      );
    });

    test('courierHistoryByMethodProvider is a FutureProvider', () {
      expect(
        courierHistoryByMethodProvider,
        isA<FutureProvider<PageResponse<RequestHistoryResponse>>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Sharing
  // ─────────────────────────────────────────────────────────────────────────

  group('Sharing FutureProvider types', () {
    test('courierCollectionSharesProvider is a FutureProvider.family', () {
      expect(
        courierCollectionSharesProvider,
        isA<FutureProviderFamily<List<CollectionShareResponse>, String>>(),
      );
    });

    test('courierSharedWithMeProvider is a FutureProvider', () {
      expect(
        courierSharedWithMeProvider,
        isA<FutureProvider<List<CollectionShareResponse>>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Forking
  // ─────────────────────────────────────────────────────────────────────────

  group('Forking FutureProvider types', () {
    test('courierCollectionForksProvider is a FutureProvider.family', () {
      expect(
        courierCollectionForksProvider,
        isA<FutureProviderFamily<List<ForkResponse>, String>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Runner
  // ─────────────────────────────────────────────────────────────────────────

  group('Runner FutureProvider types', () {
    test('courierRunResultsProvider is a FutureProvider', () {
      expect(
        courierRunResultsProvider,
        isA<FutureProvider<PageResponse<RunResultResponse>>>(),
      );
    });

    test('courierRunResultDetailProvider is a FutureProvider.family', () {
      expect(
        courierRunResultDetailProvider,
        isA<FutureProviderFamily<RunResultDetailResponse, String>>(),
      );
    });

    test('courierRunResultsByCollectionProvider is a FutureProvider.family',
        () {
      expect(
        courierRunResultsByCollectionProvider,
        isA<FutureProviderFamily<List<RunResultResponse>, String>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types — Code Generation
  // ─────────────────────────────────────────────────────────────────────────

  group('Code Generation FutureProvider types', () {
    test('courierCodeLanguagesProvider is a FutureProvider', () {
      expect(
        courierCodeLanguagesProvider,
        isA<FutureProvider<List<CodeSnippetResponse>>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Collection UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Collection UI state', () {
    test('courierCollectionPageProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierCollectionPageProvider), 0);
    });

    test('selectedCourierCollectionIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCourierCollectionIdProvider), isNull);
    });

    test('courierCollectionSearchQueryProvider defaults to empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierCollectionSearchQueryProvider), '');
    });

    test('courierCollectionPageProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(courierCollectionPageProvider.notifier).state = 3;

      expect(container.read(courierCollectionPageProvider), 3);
    });

    test('selectedCourierCollectionIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCourierCollectionIdProvider.notifier).state =
          'col-1';

      expect(container.read(selectedCourierCollectionIdProvider), 'col-1');
    });

    test('courierCollectionSearchQueryProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(courierCollectionSearchQueryProvider.notifier).state =
          'search term';

      expect(
          container.read(courierCollectionSearchQueryProvider), 'search term');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Folder UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Folder UI state', () {
    test('selectedCourierFolderIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCourierFolderIdProvider), isNull);
    });

    test('selectedCourierFolderIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCourierFolderIdProvider.notifier).state = 'fld-1';

      expect(container.read(selectedCourierFolderIdProvider), 'fld-1');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Request UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Request UI state', () {
    test('selectedCourierRequestIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCourierRequestIdProvider), isNull);
    });

    test('selectedCourierRequestIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCourierRequestIdProvider.notifier).state = 'req-1';

      expect(container.read(selectedCourierRequestIdProvider), 'req-1');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Environment UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Environment UI state', () {
    test('selectedCourierEnvironmentIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCourierEnvironmentIdProvider), isNull);
    });

    test('selectedCourierEnvironmentIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCourierEnvironmentIdProvider.notifier).state =
          'env-1';

      expect(container.read(selectedCourierEnvironmentIdProvider), 'env-1');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // History UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('History UI state', () {
    test('courierHistoryPageProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierHistoryPageProvider), 0);
    });

    test('courierHistoryMethodFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierHistoryMethodFilterProvider), isNull);
    });

    test('courierHistorySearchProvider defaults to empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierHistorySearchProvider), '');
    });

    test('courierHistoryPageProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(courierHistoryPageProvider.notifier).state = 5;

      expect(container.read(courierHistoryPageProvider), 5);
    });

    test('courierHistoryMethodFilterProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(courierHistoryMethodFilterProvider.notifier).state =
          CourierHttpMethod.post;

      expect(
        container.read(courierHistoryMethodFilterProvider),
        CourierHttpMethod.post,
      );
    });

    test('courierHistorySearchProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(courierHistorySearchProvider.notifier).state = 'api';

      expect(container.read(courierHistorySearchProvider), 'api');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Runner UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Runner UI state', () {
    test('courierRunResultPageProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierRunResultPageProvider), 0);
    });

    test('courierRunResultPageProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(courierRunResultPageProvider.notifier).state = 2;

      expect(container.read(courierRunResultPageProvider), 2);
    });
  });
}
