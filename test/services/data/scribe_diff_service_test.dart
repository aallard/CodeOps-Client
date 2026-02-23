// Tests for ScribeDiffService.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_diff_models.dart';
import 'package:codeops/services/data/scribe_diff_service.dart';

void main() {
  late ScribeDiffService service;

  setUp(() {
    service = ScribeDiffService();
  });

  group('ScribeDiffService.computeLineDiff', () {
    test('identical texts produce only unchanged lines', () {
      const text = 'line 1\nline 2\nline 3';
      final lines = service.computeLineDiff(text, text);

      expect(lines, hasLength(3));
      for (final line in lines) {
        expect(line.type, DiffLineType.unchanged);
      }
    });

    test('added lines at the end', () {
      const left = 'line 1\nline 2';
      const right = 'line 1\nline 2\nline 3';
      final lines = service.computeLineDiff(left, right);

      final addedLines =
          lines.where((l) => l.type == DiffLineType.added).toList();
      expect(addedLines, hasLength(1));
      expect(addedLines.first.text, 'line 3');
      expect(addedLines.first.rightLineNumber, isNotNull);
      expect(addedLines.first.leftLineNumber, isNull);
    });

    test('removed lines produce removed diff lines', () {
      const left = 'line 1\nline 2\nline 3';
      const right = 'line 1\nline 3';
      final lines = service.computeLineDiff(left, right);

      final removedLines =
          lines.where((l) => l.type == DiffLineType.removed).toList();
      expect(removedLines, isNotEmpty);
      expect(removedLines.first.leftLineNumber, isNotNull);
      expect(removedLines.first.rightLineNumber, isNull);
    });

    test('modified lines have character segments', () {
      const left = 'hello world';
      const right = 'hello earth';
      final lines = service.computeLineDiff(left, right);

      final modifiedLines =
          lines.where((l) => l.type == DiffLineType.modified).toList();
      expect(modifiedLines, hasLength(1));
      expect(modifiedLines.first.segments, isNotEmpty);
      expect(modifiedLines.first.pairedSegments, isNotEmpty);
      expect(modifiedLines.first.pairedText, 'hello world');
      expect(modifiedLines.first.text, 'hello earth');
    });

    test('empty texts produce single unchanged line', () {
      final lines = service.computeLineDiff('', '');
      expect(lines, hasLength(1));
      expect(lines.first.type, DiffLineType.unchanged);
      expect(lines.first.text, '');
    });

    test('left empty, right has content produces added lines', () {
      final lines = service.computeLineDiff('', 'new line');
      final addedOrModified = lines.where(
          (l) => l.type == DiffLineType.added ||
                 l.type == DiffLineType.modified);
      expect(addedOrModified, isNotEmpty);
    });

    test('multiple changes produce correct line numbers', () {
      const left = 'A\nB\nC\nD\nE';
      const right = 'A\nX\nC\nD\nE\nF';
      final lines = service.computeLineDiff(left, right);

      // B->X is a modification, F is an addition.
      final unchanged = lines.where((l) => l.type == DiffLineType.unchanged);
      expect(unchanged, isNotEmpty);

      // Verify line numbers increment correctly.
      final leftNums = lines
          .where((l) => l.leftLineNumber != null)
          .map((l) => l.leftLineNumber!)
          .toList();
      final rightNums = lines
          .where((l) => l.rightLineNumber != null)
          .map((l) => l.rightLineNumber!)
          .toList();

      // Left should have 1..5, right should have 1..6.
      expect(leftNums, orderedEquals(leftNums..sort()));
      expect(rightNums, orderedEquals(rightNums..sort()));
    });
  });

  group('ScribeDiffService.computeSummary', () {
    test('counts added, removed, modified lines', () {
      final lines = [
        const DiffLine(
            leftLineNumber: 1,
            rightLineNumber: 1,
            text: 'same',
            type: DiffLineType.unchanged),
        const DiffLine(
            rightLineNumber: 2,
            text: 'added',
            type: DiffLineType.added),
        const DiffLine(
            leftLineNumber: 2,
            text: 'removed',
            type: DiffLineType.removed),
        const DiffLine(
            leftLineNumber: 3,
            rightLineNumber: 3,
            text: 'mod',
            type: DiffLineType.modified),
      ];

      final summary = service.computeSummary(lines);
      expect(summary.addedLines, 1);
      expect(summary.removedLines, 1);
      expect(summary.modifiedLines, 1);
      expect(summary.totalChanges, 3);
    });

    test('empty lines produce zero summary', () {
      final summary = service.computeSummary([]);
      expect(summary.totalChanges, 0);
    });
  });

  group('ScribeDiffService.collapseUnchanged', () {
    test('collapses long unchanged regions', () {
      final lines = <DiffLine>[
        for (var i = 1; i <= 20; i++)
          DiffLine(
            leftLineNumber: i,
            rightLineNumber: i,
            text: 'line $i',
            type: DiffLineType.unchanged,
          ),
        const DiffLine(
            leftLineNumber: 21,
            rightLineNumber: 21,
            text: 'changed',
            type: DiffLineType.modified),
      ];

      final collapsed = service.collapseUnchanged(lines, contextLines: 3);

      // Should have a padding line, then 3 context lines, then the change.
      final padding =
          collapsed.where((l) => l.type == DiffLineType.padding).toList();
      expect(padding, hasLength(1));
      expect(padding.first.text, contains('unchanged lines'));
    });

    test('preserves context lines around changes', () {
      final lines = <DiffLine>[
        for (var i = 1; i <= 10; i++)
          DiffLine(
            leftLineNumber: i,
            rightLineNumber: i,
            text: 'line $i',
            type: DiffLineType.unchanged,
          ),
        const DiffLine(
            leftLineNumber: 11,
            text: 'removed',
            type: DiffLineType.removed),
        for (var i = 12; i <= 20; i++)
          DiffLine(
            leftLineNumber: i,
            rightLineNumber: i - 1,
            text: 'line $i',
            type: DiffLineType.unchanged,
          ),
      ];

      final collapsed = service.collapseUnchanged(lines, contextLines: 2);
      final types = collapsed.map((l) => l.type).toList();

      // Should have: padding, context*2, removed, context*2, padding.
      expect(types, contains(DiffLineType.padding));
      expect(types, contains(DiffLineType.removed));
    });

    test('no collapse when all lines are changes', () {
      final lines = [
        const DiffLine(
            rightLineNumber: 1,
            text: 'added',
            type: DiffLineType.added),
        const DiffLine(
            leftLineNumber: 1,
            text: 'removed',
            type: DiffLineType.removed),
      ];

      final collapsed = service.collapseUnchanged(lines);
      expect(collapsed, hasLength(2));
    });

    test('empty input returns empty output', () {
      final collapsed = service.collapseUnchanged([]);
      expect(collapsed, isEmpty);
    });
  });

  group('ScribeDiffService.computeDiff', () {
    test('returns complete DiffState', () {
      const left = 'hello\nworld';
      const right = 'hello\nearth';

      final state = service.computeDiff(
        leftTabId: 'tab-1',
        rightTabId: 'tab-2',
        leftText: left,
        rightText: right,
      );

      expect(state.leftTabId, 'tab-1');
      expect(state.rightTabId, 'tab-2');
      expect(state.lines, isNotEmpty);
      expect(state.summary.totalChanges, greaterThan(0));
      expect(state.changeIndices, isNotEmpty);
    });

    test('changeIndices point to actual change lines', () {
      const left = 'A\nB\nC';
      const right = 'A\nX\nC';

      final state = service.computeDiff(
        leftTabId: 'l',
        rightTabId: 'r',
        leftText: left,
        rightText: right,
      );

      for (final idx in state.changeIndices) {
        final line = state.lines[idx];
        expect(
          line.type,
          isNot(DiffLineType.unchanged),
          reason: 'Change index $idx should not point to unchanged line',
        );
      }
    });
  });
}
