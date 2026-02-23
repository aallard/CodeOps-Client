// Tests for FuzzyMatcher utility.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/utils/fuzzy_matcher.dart';

void main() {
  group('FuzzyMatcher.match', () {
    test('empty query matches everything with score 1', () {
      final result = FuzzyMatcher.match('', 'hello.dart');
      expect(result.score, greaterThan(0));
      expect(result.matchedIndices, isEmpty);
    });

    test('exact match returns high score', () {
      final result = FuzzyMatcher.match('hello', 'hello');
      expect(result.score, greaterThan(0));
      expect(result.matchedIndices, [0, 1, 2, 3, 4]);
    });

    test('subsequence match returns positive score', () {
      final result = FuzzyMatcher.match('hlo', 'hello');
      expect(result.score, greaterThan(0));
      // Greedy left-to-right matches 'l' at index 2, then 'o' at 4.
      expect(result.matchedIndices, [0, 2, 4]);
    });

    test('non-matching returns zero score', () {
      final result = FuzzyMatcher.match('xyz', 'hello');
      expect(result.score, 0);
      expect(result.matchedIndices, isEmpty);
    });

    test('case insensitive matching', () {
      final result = FuzzyMatcher.match('HELLO', 'hello.dart');
      expect(result.score, greaterThan(0));
    });

    test('word boundary bonus for path separators', () {
      final pathMatch = FuzzyMatcher.match('sd', 'src/data');
      final noPathMatch = FuzzyMatcher.match('sd', 'aasdbb');
      // Path separator gives a word boundary bonus.
      expect(pathMatch.score, greaterThan(noPathMatch.score));
    });

    test('prefix match gets highest bonus', () {
      final prefixMatch = FuzzyMatcher.match('he', 'hello');
      final midMatch = FuzzyMatcher.match('ll', 'hello');
      expect(prefixMatch.score, greaterThan(midMatch.score));
    });

    test('consecutive characters score higher', () {
      final consecutive = FuzzyMatcher.match('hel', 'hello');
      final scattered = FuzzyMatcher.match('heo', 'hello');
      expect(consecutive.score, greaterThan(scattered.score));
    });

    test('shorter candidates get tiebreaker bonus', () {
      final short = FuzzyMatcher.match('a', 'ab');
      // Length > 100 clamps tiebreaker to 0 vs short's 10.
      final long = FuzzyMatcher.match('a', 'a${'b' * 110}');
      expect(short.score, greaterThan(long.score));
    });

    test('case-exact bonus when casing matches', () {
      final exact = FuzzyMatcher.match('H', 'Hello');
      final inexact = FuzzyMatcher.match('h', 'Hello');
      expect(exact.score, greaterThan(inexact.score));
    });
  });

  group('FuzzyMatcher.filter', () {
    test('returns matching candidates sorted by score', () {
      final candidates = ['apple.dart', 'banana.txt', 'apricot.dart'];
      final results = FuzzyMatcher.filter('ap', candidates);

      expect(results.length, 2);
      expect(results[0].candidate, 'apple.dart');
      expect(results[1].candidate, 'apricot.dart');
    });

    test('filters out non-matching candidates', () {
      final candidates = ['hello', 'world', 'foo'];
      final results = FuzzyMatcher.filter('xyz', candidates);
      expect(results, isEmpty);
    });

    test('respects maxResults limit', () {
      final candidates = List.generate(100, (i) => 'file_$i.dart');
      final results = FuzzyMatcher.filter('file', candidates, maxResults: 5);
      expect(results.length, 5);
    });

    test('empty query returns all candidates', () {
      final candidates = ['a', 'b', 'c'];
      final results = FuzzyMatcher.filter('', candidates);
      expect(results.length, 3);
    });

    test('results are sorted by descending score', () {
      final candidates = ['lib/data/service.dart', 'src/data.dart'];
      final results = FuzzyMatcher.filter('data', candidates);
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].score, greaterThanOrEqualTo(results[i + 1].score));
      }
    });
  });
}
