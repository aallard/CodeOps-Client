// Tests for navigator tree fuzzy matching.
//
// Verifies that the FuzzyMatcher correctly filters tree nodes,
// highlights matching portions, and works across schema/table/sequence
// levels. Tests the FuzzyMatcher utility directly since the navigator
// tree delegates to it.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/utils/fuzzy_matcher.dart';

void main() {
  group('FuzzyMatcher — navigator filter', () {
    test('filters nodes by substring', () {
      final matches = FuzzyMatcher.filter(
        'user',
        ['users', 'orders', 'user_settings', 'products'],
      );

      expect(matches.length, 2);
      expect(matches[0].candidate, 'users');
      expect(matches[1].candidate, 'user_settings');
    });

    test('fuzzy matches across non-consecutive characters', () {
      final match = FuzzyMatcher.match('usrs', 'users');
      expect(match.score, greaterThan(0));
      expect(match.matchedIndices, [0, 1, 3, 4]);
    });

    test('returns no match for non-subsequence', () {
      final match = FuzzyMatcher.match('xyz', 'users');
      expect(match.score, 0);
      expect(match.matchedIndices, isEmpty);
    });

    test('highlights matched indices correctly', () {
      final match = FuzzyMatcher.match('tbl', 'table_name');
      expect(match.score, greaterThan(0));
      expect(match.matchedIndices.length, 3);
      // First char 't' is at index 0.
      expect(match.matchedIndices[0], 0);
    });

    test('works across multiple naming conventions', () {
      final candidates = [
        'public',
        'pg_catalog',
        'information_schema',
        'staging',
        'prod_analytics',
      ];

      // Search for 'pub' should match 'public'.
      final matches = FuzzyMatcher.filter('pub', candidates);
      expect(matches.length, 1);
      expect(matches[0].candidate, 'public');

      // Search for 'sch' should match 'information_schema'.
      final matches2 = FuzzyMatcher.filter('sch', candidates);
      expect(matches2, isNotEmpty);
      expect(
        matches2.any((m) => m.candidate == 'information_schema'),
        isTrue,
      );
    });
  });
}
