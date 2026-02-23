// Tests for the Markdown heading parser utility.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/utils/markdown_heading_parser.dart';

void main() {
  group('parseMarkdownHeadings', () {
    test('returns empty list for empty string', () {
      expect(parseMarkdownHeadings(''), isEmpty);
    });

    test('parses h1 heading', () {
      final headings = parseMarkdownHeadings('# Hello World');
      expect(headings, hasLength(1));
      expect(headings.first.level, 1);
      expect(headings.first.title, 'Hello World');
      expect(headings.first.line, 0);
    });

    test('parses multiple heading levels', () {
      const md = '# Title\n## Section\n### Subsection\n#### Deep';
      final headings = parseMarkdownHeadings(md);

      expect(headings, hasLength(4));
      expect(headings[0].level, 1);
      expect(headings[0].title, 'Title');
      expect(headings[0].line, 0);
      expect(headings[1].level, 2);
      expect(headings[1].title, 'Section');
      expect(headings[1].line, 1);
      expect(headings[2].level, 3);
      expect(headings[2].title, 'Subsection');
      expect(headings[2].line, 2);
      expect(headings[3].level, 4);
      expect(headings[3].title, 'Deep');
      expect(headings[3].line, 3);
    });

    test('ignores headings inside fenced code blocks (backticks)', () {
      const md = '# Real\n```\n# Fake\n```\n## Also Real';
      final headings = parseMarkdownHeadings(md);

      expect(headings, hasLength(2));
      expect(headings[0].title, 'Real');
      expect(headings[1].title, 'Also Real');
    });

    test('ignores headings inside fenced code blocks (tildes)', () {
      const md = '# Before\n~~~\n## Inside\n~~~\n### After';
      final headings = parseMarkdownHeadings(md);

      expect(headings, hasLength(2));
      expect(headings[0].title, 'Before');
      expect(headings[1].title, 'After');
    });

    test('strips trailing hash characters', () {
      final headings = parseMarkdownHeadings('## Section ##');
      expect(headings.first.title, 'Section');
    });

    test('ignores lines with only hashes and no text', () {
      final headings = parseMarkdownHeadings('# ');
      expect(headings, isEmpty);
    });

    test('handles h5 and h6 levels', () {
      const md = '##### H5\n###### H6';
      final headings = parseMarkdownHeadings(md);

      expect(headings, hasLength(2));
      expect(headings[0].level, 5);
      expect(headings[1].level, 6);
    });

    test('ignores lines that are not headings', () {
      const md = 'Hello\n# Title\nSome paragraph\n## Section\n- list item';
      final headings = parseMarkdownHeadings(md);

      expect(headings, hasLength(2));
      expect(headings[0].line, 1);
      expect(headings[1].line, 3);
    });

    test('preserves correct line numbers with blank lines', () {
      const md = '\n\n# Title\n\n## Section\n';
      final headings = parseMarkdownHeadings(md);

      expect(headings, hasLength(2));
      expect(headings[0].line, 2);
      expect(headings[1].line, 4);
    });

    test('ignores more than 6 hashes', () {
      final headings = parseMarkdownHeadings('####### Not a heading');
      expect(headings, isEmpty);
    });
  });

  group('MarkdownHeading', () {
    test('equality based on level, title, and line', () {
      const a = MarkdownHeading(level: 1, title: 'Test', line: 0);
      const b = MarkdownHeading(level: 1, title: 'Test', line: 0);
      const c = MarkdownHeading(level: 2, title: 'Test', line: 0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toString includes all fields', () {
      const h = MarkdownHeading(level: 2, title: 'Section', line: 5);
      expect(h.toString(), contains('level: 2'));
      expect(h.toString(), contains('Section'));
      expect(h.toString(), contains('line: 5'));
    });
  });
}
