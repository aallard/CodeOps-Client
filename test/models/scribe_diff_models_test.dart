// Tests for Scribe diff models.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_diff_models.dart';

void main() {
  group('DiffSegment', () {
    test('isUnchanged returns true when not added or removed', () {
      const segment = DiffSegment(text: 'hello');
      expect(segment.isUnchanged, isTrue);
      expect(segment.isAdded, isFalse);
      expect(segment.isRemoved, isFalse);
    });

    test('isUnchanged returns false when isAdded', () {
      const segment = DiffSegment(text: 'new', isAdded: true);
      expect(segment.isUnchanged, isFalse);
    });

    test('isUnchanged returns false when isRemoved', () {
      const segment = DiffSegment(text: 'old', isRemoved: true);
      expect(segment.isUnchanged, isFalse);
    });
  });

  group('DiffSummary', () {
    test('totalChanges sums added, removed, and modified', () {
      const summary = DiffSummary(
        addedLines: 5,
        removedLines: 3,
        modifiedLines: 2,
      );
      expect(summary.totalChanges, 10);
    });

    test('default values are all zero', () {
      const summary = DiffSummary();
      expect(summary.addedLines, 0);
      expect(summary.removedLines, 0);
      expect(summary.modifiedLines, 0);
      expect(summary.totalChanges, 0);
    });
  });

  group('DiffLine', () {
    test('creates unchanged line with both line numbers', () {
      const line = DiffLine(
        leftLineNumber: 1,
        rightLineNumber: 1,
        text: 'same',
        type: DiffLineType.unchanged,
      );
      expect(line.leftLineNumber, 1);
      expect(line.rightLineNumber, 1);
      expect(line.text, 'same');
      expect(line.segments, isEmpty);
    });

    test('creates added line with only right line number', () {
      const line = DiffLine(
        rightLineNumber: 5,
        text: 'new line',
        type: DiffLineType.added,
      );
      expect(line.leftLineNumber, isNull);
      expect(line.rightLineNumber, 5);
    });

    test('creates removed line with only left line number', () {
      const line = DiffLine(
        leftLineNumber: 3,
        text: 'old line',
        type: DiffLineType.removed,
      );
      expect(line.leftLineNumber, 3);
      expect(line.rightLineNumber, isNull);
    });

    test('creates modified line with segments and paired text', () {
      const line = DiffLine(
        leftLineNumber: 2,
        rightLineNumber: 2,
        text: 'world',
        type: DiffLineType.modified,
        segments: [DiffSegment(text: 'world', isAdded: true)],
        pairedText: 'hello',
        pairedSegments: [DiffSegment(text: 'hello', isRemoved: true)],
      );
      expect(line.segments, hasLength(1));
      expect(line.pairedText, 'hello');
      expect(line.pairedSegments, hasLength(1));
    });
  });

  group('DiffViewMode', () {
    test('has sideBySide and inline values', () {
      expect(DiffViewMode.values, hasLength(2));
      expect(DiffViewMode.sideBySide.name, 'sideBySide');
      expect(DiffViewMode.inline.name, 'inline');
    });
  });

  group('DiffLineType', () {
    test('has all expected values', () {
      expect(DiffLineType.values, hasLength(5));
      expect(DiffLineType.values,
          contains(DiffLineType.unchanged));
      expect(DiffLineType.values, contains(DiffLineType.added));
      expect(DiffLineType.values, contains(DiffLineType.removed));
      expect(DiffLineType.values, contains(DiffLineType.modified));
      expect(DiffLineType.values, contains(DiffLineType.padding));
    });
  });

  group('DiffState', () {
    test('stores all fields correctly', () {
      const state = DiffState(
        leftTabId: 'tab-1',
        rightTabId: 'tab-2',
        lines: [],
        summary: DiffSummary(),
        changeIndices: [0, 3, 7],
      );
      expect(state.leftTabId, 'tab-1');
      expect(state.rightTabId, 'tab-2');
      expect(state.lines, isEmpty);
      expect(state.changeIndices, [0, 3, 7]);
    });
  });
}
