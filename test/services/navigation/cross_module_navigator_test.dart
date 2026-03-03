// Unit tests for CrossModuleNavigator.
//
// Verifies route generation for all cross-module navigation methods
// and the routeForModule resolver.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/navigation/cross_module_navigator.dart';

void main() {
  group('CrossModuleNavigator.routeForModule', () {
    test('returns registry route', () {
      expect(
        CrossModuleNavigator.routeForModule('registry', 'svc-1'),
        '/registry/services/svc-1',
      );
    });

    test('returns vault route', () {
      expect(
        CrossModuleNavigator.routeForModule('vault', 'secret-2'),
        '/vault/secrets/secret-2',
      );
    });

    test('returns fleet route', () {
      expect(
        CrossModuleNavigator.routeForModule('fleet', 'ctr-3'),
        '/fleet/containers/ctr-3',
      );
    });

    test('returns courier route', () {
      expect(
        CrossModuleNavigator.routeForModule('courier', 'req-4'),
        '/courier/request/req-4',
      );
    });

    test('returns logger route', () {
      expect(
        CrossModuleNavigator.routeForModule('logger', 'log-5'),
        '/logger/search',
      );
    });

    test('returns mcp route', () {
      expect(
        CrossModuleNavigator.routeForModule('mcp', 'sess-6'),
        '/mcp/sessions/sess-6',
      );
    });

    test('returns relay route', () {
      expect(
        CrossModuleNavigator.routeForModule('relay', 'ch-7'),
        '/relay/channel/ch-7',
      );
    });

    test('returns datalens route', () {
      expect(
        CrossModuleNavigator.routeForModule('datalens', 'any'),
        '/datalens',
      );
    });

    test('returns null for unknown module', () {
      expect(
        CrossModuleNavigator.routeForModule('unknown', 'id-1'),
        isNull,
      );
    });

    test('is case-insensitive', () {
      expect(
        CrossModuleNavigator.routeForModule('REGISTRY', 'svc-1'),
        '/registry/services/svc-1',
      );
      expect(
        CrossModuleNavigator.routeForModule('Fleet', 'ctr-1'),
        '/fleet/containers/ctr-1',
      );
    });
  });
}
