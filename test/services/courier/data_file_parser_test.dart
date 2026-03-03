// Unit tests for DataFileParser.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/courier/data_file_parser.dart';

void main() {
  const parser = DataFileParser();

  group('DataFileParser — CSV', () {
    test('parses simple CSV with headers and rows', () {
      const csv = 'name,email,role\nAlice,alice@test.com,admin\nBob,bob@test.com,user';
      final rows = parser.parseCsv(csv);

      expect(rows.length, 2);
      expect(rows[0]['name'], 'Alice');
      expect(rows[0]['email'], 'alice@test.com');
      expect(rows[0]['role'], 'admin');
      expect(rows[1]['name'], 'Bob');
    });

    test('handles quoted fields with commas', () {
      const csv = 'name,address\nJohn,"123 Main St, Apt 4"';
      final rows = parser.parseCsv(csv);

      expect(rows.length, 1);
      expect(rows[0]['address'], '123 Main St, Apt 4');
    });

    test('throws on empty CSV', () {
      expect(() => parser.parseCsv(''), throwsFormatException);
    });

    test('throws on headers-only CSV', () {
      expect(() => parser.parseCsv('name,email\n'), throwsFormatException);
    });

    test('fills missing values with empty string', () {
      const csv = 'a,b,c\n1,2';
      final rows = parser.parseCsv(csv);

      expect(rows[0]['c'], '');
    });
  });

  group('DataFileParser — JSON', () {
    test('parses array of objects', () {
      const json = '[{"name":"Alice","age":"30"},{"name":"Bob","age":"25"}]';
      final rows = parser.parseJson(json);

      expect(rows.length, 2);
      expect(rows[0]['name'], 'Alice');
      expect(rows[0]['age'], '30');
      expect(rows[1]['name'], 'Bob');
    });

    test('parses iterations wrapper object', () {
      const json = '{"iterations":[{"key":"val1"},{"key":"val2"}]}';
      final rows = parser.parseJson(json);

      expect(rows.length, 2);
      expect(rows[0]['key'], 'val1');
      expect(rows[1]['key'], 'val2');
    });

    test('converts non-string values to strings', () {
      const json = '[{"count":42,"active":true}]';
      final rows = parser.parseJson(json);

      expect(rows[0]['count'], '42');
      expect(rows[0]['active'], 'true');
    });

    test('throws on invalid JSON', () {
      expect(() => parser.parseJson('{not valid json'), throwsFormatException);
    });

    test('throws on empty array', () {
      expect(() => parser.parseJson('[]'), throwsFormatException);
    });
  });

  group('DataFileParser — preview', () {
    test('returns preview with limited rows', () {
      const csv = 'x,y\n1,2\n3,4\n5,6\n7,8\n9,10\n11,12';
      final preview = parser.preview(csv, 'csv', maxRows: 3);

      expect(preview.headers, ['x', 'y']);
      expect(preview.rows.length, 3);
      expect(preview.totalRows, 6);
    });

    test('returns preview for JSON', () {
      const json =
          '[{"a":"1","b":"2"},{"a":"3","b":"4"},{"a":"5","b":"6"}]';
      final preview = parser.preview(json, 'json', maxRows: 2);

      expect(preview.headers, ['a', 'b']);
      expect(preview.rows.length, 2);
      expect(preview.totalRows, 3);
    });
  });
}
