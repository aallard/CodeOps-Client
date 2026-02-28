// Tests for FleetApiService.
//
// Verifies service instantiation and type identity.
// Full integration tests require a running server.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/fleet_providers.dart';
import 'package:codeops/services/cloud/fleet_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FleetApiService', () {
    test('can be created via fleetApiProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final api = container.read(fleetApiProvider);

      expect(api, isA<FleetApiService>());
    });
  });
}
