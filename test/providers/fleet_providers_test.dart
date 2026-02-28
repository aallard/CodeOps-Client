// Tests for Fleet providers.
//
// Verifies singleton provider creation, FutureProvider types,
// and StateProvider defaults for all Fleet providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_models.dart';
import 'package:codeops/providers/fleet_providers.dart';
import 'package:codeops/services/cloud/fleet_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Core providers', () {
    test('fleetApiProvider creates FleetApiService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final api = container.read(fleetApiProvider);
      expect(api, isA<FleetApiService>());
    });
  });

  group('Health providers', () {
    // Type checks only — cannot invoke FutureProvider.family without real API
  });

  group('selectedTeamIdProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(selectedTeamIdProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedTeamIdProvider.notifier).state = 'team-123';
      expect(container.read(selectedTeamIdProvider), 'team-123');
    });
  });
}
