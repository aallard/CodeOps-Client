/// Parses CSV and JSON data files into iteration data rows.
///
/// Used by the Collection Runner to support parameterized testing:
/// each row becomes one iteration, and columns become variables
/// accessible via `{{variableName}}` in requests.
library;

import 'dart:convert';

/// Preview of a parsed data file showing headers and a subset of rows.
class DataFilePreview {
  /// Column header names.
  final List<String> headers;

  /// Preview rows (up to [maxRows]).
  final List<Map<String, String>> rows;

  /// Total row count in the full file.
  final int totalRows;

  /// Creates a [DataFilePreview].
  const DataFilePreview({
    required this.headers,
    required this.rows,
    required this.totalRows,
  });
}

/// Parses CSV and JSON data files into variable maps for the runner.
///
/// CSV format: first row is headers, subsequent rows are values.
/// JSON format: array of objects, or `{ "iterations": [...] }`.
class DataFileParser {
  /// Creates a [DataFileParser].
  const DataFileParser();

  /// Parses CSV content into a list of variable maps.
  ///
  /// The first line is treated as column headers. Each subsequent line
  /// becomes a map of `{header: value}` pairs.
  ///
  /// Throws [FormatException] if the content is empty or has no data rows.
  List<Map<String, String>> parseCsv(String content) {
    final lines = const LineSplitter().convert(content.trim());
    if (lines.isEmpty) {
      throw const FormatException('CSV file is empty');
    }

    final headers = _parseCsvLine(lines.first);
    if (headers.isEmpty) {
      throw const FormatException('CSV file has no headers');
    }

    final rows = <Map<String, String>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final values = _parseCsvLine(line);
      final row = <String, String>{};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = j < values.length ? values[j] : '';
      }
      rows.add(row);
    }

    if (rows.isEmpty) {
      throw const FormatException('CSV file has no data rows');
    }

    return rows;
  }

  /// Parses JSON content into a list of variable maps.
  ///
  /// Supports two formats:
  /// - Array of objects: `[{"key": "val"}, ...]`
  /// - Wrapper object: `{"iterations": [{"key": "val"}, ...]}`
  ///
  /// All values are converted to strings.
  ///
  /// Throws [FormatException] if the content is not valid JSON or
  /// does not match expected formats.
  List<Map<String, String>> parseJson(String content) {
    final dynamic parsed;
    try {
      parsed = jsonDecode(content.trim());
    } on FormatException {
      throw const FormatException('Invalid JSON content');
    }

    List<dynamic> items;
    if (parsed is List) {
      items = parsed;
    } else if (parsed is Map<String, dynamic> &&
        parsed.containsKey('iterations')) {
      final itr = parsed['iterations'];
      if (itr is! List) {
        throw const FormatException(
            '"iterations" field must be an array');
      }
      items = itr;
    } else {
      throw const FormatException(
          'JSON must be an array or an object with "iterations" key');
    }

    if (items.isEmpty) {
      throw const FormatException('JSON file has no data rows');
    }

    return items.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
            'Each iteration must be a JSON object');
      }
      return item.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }).toList();
  }

  /// Returns a preview of the first [maxRows] rows from the data file.
  ///
  /// The [format] should be `'csv'` or `'json'`.
  DataFilePreview preview(
    String content,
    String format, {
    int maxRows = 5,
  }) {
    final allRows =
        format == 'csv' ? parseCsv(content) : parseJson(content);
    final headers =
        allRows.isNotEmpty ? allRows.first.keys.toList() : <String>[];
    final previewRows = allRows.take(maxRows).toList();
    return DataFilePreview(
      headers: headers,
      rows: previewRows,
      totalRows: allRows.length,
    );
  }

  /// Parses a single CSV line, handling quoted fields.
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (inQuotes) {
        if (ch == '"') {
          // Check for escaped quote ("")
          if (i + 1 < line.length && line[i + 1] == '"') {
            buf.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(ch);
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
        } else if (ch == ',') {
          fields.add(buf.toString().trim());
          buf.clear();
        } else {
          buf.write(ch);
        }
      }
    }
    fields.add(buf.toString().trim());
    return fields;
  }
}
