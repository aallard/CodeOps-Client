// Tests for registry providers.
//
// Verifies singleton provider creation, FutureProvider types,
// StateProvider defaults, and state updates for all Registry providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/providers/registry_providers.dart';
import 'package:codeops/services/cloud/registry_api.dart';
import 'package:codeops/services/cloud/registry_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // Core singleton providers
  // ─────────────────────────────────────────────────────────────────────────

  group('Core providers', () {
    test('registryApiClientProvider creates RegistryApiClient', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final client = container.read(registryApiClientProvider);

      expect(client, isA<RegistryApiClient>());
    });

    test('registryApiProvider creates RegistryApi', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final api = container.read(registryApiProvider);

      expect(api, isA<RegistryApi>());
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FutureProvider types
  // ─────────────────────────────────────────────────────────────────────────

  group('FutureProvider types', () {
    test('registryServicesProvider is a FutureProvider', () {
      expect(
        registryServicesProvider,
        isA<FutureProvider<PageResponse<ServiceRegistrationResponse>>>(),
      );
    });

    test('registrySolutionsProvider is a FutureProvider', () {
      expect(
        registrySolutionsProvider,
        isA<FutureProvider<PageResponse<SolutionResponse>>>(),
      );
    });

    test('registryInfraResourcesProvider is a FutureProvider', () {
      expect(
        registryInfraResourcesProvider,
        isA<FutureProvider<PageResponse<InfraResourceResponse>>>(),
      );
    });

    test('registryDependencyGraphProvider is a FutureProvider', () {
      expect(
        registryDependencyGraphProvider,
        isA<FutureProvider<DependencyGraphResponse>>(),
      );
    });

    test('registryStartupOrderProvider is a FutureProvider', () {
      expect(
        registryStartupOrderProvider,
        isA<FutureProvider<List<DependencyNodeResponse>>>(),
      );
    });

    test('registryCyclesProvider is a FutureProvider', () {
      expect(registryCyclesProvider, isA<FutureProvider<List<String>>>());
    });

    test('registryWorkstationProfilesProvider is a FutureProvider', () {
      expect(
        registryWorkstationProfilesProvider,
        isA<FutureProvider<List<WorkstationProfileResponse>>>(),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Service UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Service UI state', () {
    test('registryServiceStatusFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryServiceStatusFilterProvider), isNull);
    });

    test('registryServiceTypeFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryServiceTypeFilterProvider), isNull);
    });

    test('registryServiceSearchProvider defaults to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryServiceSearchProvider), '');
    });

    test('registryServicePageProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryServicePageProvider), 0);
    });

    test('selectedRegistryServiceIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedRegistryServiceIdProvider), isNull);
    });

    test('selectedRegistryServiceIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedRegistryServiceIdProvider.notifier).state =
          'svc-123';

      expect(container.read(selectedRegistryServiceIdProvider), 'svc-123');
    });

    test('registryServicePageProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(registryServicePageProvider.notifier).state = 5;

      expect(container.read(registryServicePageProvider), 5);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Solution UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Solution UI state', () {
    test('registrySolutionStatusFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registrySolutionStatusFilterProvider), isNull);
    });

    test('registrySolutionCategoryFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registrySolutionCategoryFilterProvider), isNull);
    });

    test('registrySolutionPageProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registrySolutionPageProvider), 0);
    });

    test('selectedRegistrySolutionIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedRegistrySolutionIdProvider), isNull);
    });

    test('selectedRegistrySolutionIdProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedRegistrySolutionIdProvider.notifier).state =
          'sol-456';

      expect(container.read(selectedRegistrySolutionIdProvider), 'sol-456');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Port UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Port UI state', () {
    test('registryPortEnvironmentProvider defaults to local', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryPortEnvironmentProvider), 'local');
    });

    test('registryPortEnvironmentProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(registryPortEnvironmentProvider.notifier).state =
          'staging';

      expect(container.read(registryPortEnvironmentProvider), 'staging');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Infra UI state defaults and updates
  // ─────────────────────────────────────────────────────────────────────────

  group('Infra UI state', () {
    test('registryInfraTypeFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryInfraTypeFilterProvider), isNull);
    });

    test('registryInfraEnvironmentFilterProvider defaults to empty string',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryInfraEnvironmentFilterProvider), '');
    });

    test('registryInfraPageProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryInfraPageProvider), 0);
    });

    test('registryInfraPageProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(registryInfraPageProvider.notifier).state = 3;

      expect(container.read(registryInfraPageProvider), 3);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation state
  // ─────────────────────────────────────────────────────────────────────────

  group('Navigation state', () {
    test('registryActiveTabProvider defaults to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(registryActiveTabProvider), 0);
    });

    test('registryActiveTabProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(registryActiveTabProvider.notifier).state = 4;

      expect(container.read(registryActiveTabProvider), 4);
    });
  });
}
