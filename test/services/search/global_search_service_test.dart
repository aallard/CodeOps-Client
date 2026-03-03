// Unit tests for GlobalSearchService.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/search/global_search_service.dart';

void main() {
  group('SearchModule', () {
    test('has correct number of modules', () {
      expect(SearchModule.values.length, 8);
    });

    test('each module has a label, icon, and route', () {
      for (final module in SearchModule.values) {
        expect(module.label, isNotEmpty);
        expect(module.route, startsWith('/'));
      }
    });
  });

  group('SearchResult', () {
    test('creates with required fields', () {
      const result = SearchResult(
        module: SearchModule.registry,
        title: 'My Service',
        route: '/registry/services/123',
      );
      expect(result.module, SearchModule.registry);
      expect(result.title, 'My Service');
      expect(result.route, '/registry/services/123');
      expect(result.subtitle, isNull);
      expect(result.entityId, isNull);
    });

    test('creates with all fields', () {
      const result = SearchResult(
        module: SearchModule.vault,
        title: 'DB Password',
        route: '/vault/secrets/456',
        subtitle: '/services/db-password',
        entityId: '456',
      );
      expect(result.subtitle, '/services/db-password');
      expect(result.entityId, '456');
    });
  });

  group('GlobalSearchResults', () {
    test('empty has zero total and no loading', () {
      expect(GlobalSearchResults.empty.totalCount, 0);
      expect(GlobalSearchResults.empty.isLoading, false);
      expect(GlobalSearchResults.empty.grouped, isEmpty);
    });

    test('loading has isLoading true', () {
      expect(GlobalSearchResults.loading.isLoading, true);
    });

    test('allResults returns flat list', () {
      const results = GlobalSearchResults(
        grouped: {
          SearchModule.registry: [
            SearchResult(
              module: SearchModule.registry,
              title: 'Svc A',
              route: '/registry/services/a',
            ),
          ],
          SearchModule.vault: [
            SearchResult(
              module: SearchModule.vault,
              title: 'Secret B',
              route: '/vault/secrets/b',
            ),
          ],
        },
        totalCount: 2,
      );
      expect(results.allResults, hasLength(2));
    });
  });

  group('RecentSearchesNotifier', () {
    test('starts empty', () {
      final notifier = RecentSearchesNotifier();
      expect(notifier.state, isEmpty);
    });

    test('add inserts at front', () {
      final notifier = RecentSearchesNotifier();
      notifier.add('hello');
      notifier.add('world');
      expect(notifier.state, ['world', 'hello']);
    });

    test('add deduplicates', () {
      final notifier = RecentSearchesNotifier();
      notifier.add('hello');
      notifier.add('world');
      notifier.add('hello');
      expect(notifier.state, ['hello', 'world']);
    });

    test('add respects max limit', () {
      final notifier = RecentSearchesNotifier();
      for (var i = 0; i < 15; i++) {
        notifier.add('query-$i');
      }
      expect(notifier.state, hasLength(RecentSearchesNotifier.maxRecent));
      expect(notifier.state.first, 'query-14');
    });

    test('add ignores empty strings', () {
      final notifier = RecentSearchesNotifier();
      notifier.add('');
      notifier.add('   ');
      expect(notifier.state, isEmpty);
    });

    test('remove removes specific query', () {
      final notifier = RecentSearchesNotifier();
      notifier.add('hello');
      notifier.add('world');
      notifier.remove('hello');
      expect(notifier.state, ['world']);
    });

    test('clear empties the list', () {
      final notifier = RecentSearchesNotifier();
      notifier.add('hello');
      notifier.add('world');
      notifier.clear();
      expect(notifier.state, isEmpty);
    });
  });

  group('recentSearchesProvider', () {
    test('is accessible via ProviderContainer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(recentSearchesProvider), isEmpty);
      container.read(recentSearchesProvider.notifier).add('test');
      expect(container.read(recentSearchesProvider), ['test']);
    });
  });
}
