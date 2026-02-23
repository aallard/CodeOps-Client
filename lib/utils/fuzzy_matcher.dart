/// Fuzzy subsequence matcher for quick-open file search.
///
/// Scores candidates by how well a query matches as a subsequence,
/// rewarding consecutive character runs, word-boundary matches, and
/// prefix alignment.
library;

/// A single fuzzy match result with its score and matched indices.
class FuzzyMatch {
  /// The original candidate string that was matched.
  final String candidate;

  /// Match score (higher is better). Zero means no match.
  final int score;

  /// Character indices in [candidate] that matched the query.
  final List<int> matchedIndices;

  /// Creates a [FuzzyMatch].
  const FuzzyMatch({
    required this.candidate,
    required this.score,
    required this.matchedIndices,
  });
}

/// Fuzzy subsequence matcher with scoring.
///
/// Matches a query against candidate strings using case-insensitive
/// subsequence matching. Scores reward:
/// - Consecutive character runs (+5 per consecutive match)
/// - Word boundary matches (+10 for match after `/`, `.`, `-`, `_`, or space)
/// - Prefix matches (+15 for matching at position 0)
/// - Shorter candidates (+1 bonus, so exact-length matches rank higher)
class FuzzyMatcher {
  FuzzyMatcher._();

  /// Scores how well [query] matches [candidate] as a fuzzy subsequence.
  ///
  /// Returns a [FuzzyMatch] with score > 0 if [query] is a subsequence
  /// of [candidate] (case-insensitive), or score == 0 if no match.
  static FuzzyMatch match(String query, String candidate) {
    if (query.isEmpty) {
      return FuzzyMatch(candidate: candidate, score: 1, matchedIndices: []);
    }

    final lowerQuery = query.toLowerCase();
    final lowerCandidate = candidate.toLowerCase();

    final matchedIndices = <int>[];
    var queryIndex = 0;
    var score = 0;
    var lastMatchIndex = -2; // -2 so first match is never "consecutive"

    for (var i = 0; i < lowerCandidate.length && queryIndex < lowerQuery.length; i++) {
      if (lowerCandidate[i] == lowerQuery[queryIndex]) {
        matchedIndices.add(i);

        // Base score per matched character.
        score += 1;

        // Consecutive run bonus.
        if (i == lastMatchIndex + 1) {
          score += 5;
        }

        // Word boundary bonus.
        if (i == 0) {
          score += 15;
        } else {
          final prev = candidate[i - 1];
          if (prev == '/' || prev == '.' || prev == '-' || prev == '_' || prev == ' ') {
            score += 10;
          }
        }

        // Case-exact bonus.
        if (candidate[i] == query[queryIndex]) {
          score += 1;
        }

        lastMatchIndex = i;
        queryIndex++;
      }
    }

    // All query characters must be matched.
    if (queryIndex < lowerQuery.length) {
      return FuzzyMatch(candidate: candidate, score: 0, matchedIndices: []);
    }

    // Shorter candidates get a small bonus (tiebreaker).
    score += (100 - candidate.length).clamp(0, 10);

    return FuzzyMatch(
      candidate: candidate,
      score: score,
      matchedIndices: matchedIndices,
    );
  }

  /// Filters and ranks [candidates] by fuzzy match against [query].
  ///
  /// Returns only candidates with a positive match score, sorted by
  /// descending score. If [maxResults] is provided, truncates the list.
  static List<FuzzyMatch> filter(
    String query,
    List<String> candidates, {
    int? maxResults,
  }) {
    final matches = candidates
        .map((c) => match(query, c))
        .where((m) => m.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (maxResults != null && matches.length > maxResults) {
      return matches.sublist(0, maxResults);
    }
    return matches;
  }
}
