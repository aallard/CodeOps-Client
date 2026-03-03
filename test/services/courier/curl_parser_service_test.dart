// Unit tests for CurlParserService.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/courier/curl_parser_service.dart';

void main() {
  const parser = CurlParserService();

  group('CurlParserService', () {
    test('parses simple GET request', () {
      final result = parser.parse("curl https://api.example.com/users");
      expect(result.method, 'GET');
      expect(result.url, 'https://api.example.com/users');
    });

    test('parses POST with -X flag', () {
      final result = parser.parse(
          "curl -X POST https://api.example.com/users");
      expect(result.method, 'POST');
      expect(result.url, 'https://api.example.com/users');
    });

    test('parses headers with -H flag', () {
      final result = parser.parse(
          'curl -H "Content-Type: application/json" '
          '-H "Authorization: Bearer token123" '
          'https://api.example.com/users');
      expect(result.headers['Content-Type'], 'application/json');
      expect(result.headers['Authorization'], 'Bearer token123');
    });

    test('parses body with -d flag', () {
      final result = parser.parse(
          "curl -X POST -d '{\"name\":\"John\"}' https://api.example.com/users");
      expect(result.method, 'POST');
      expect(result.body, '{"name":"John"}');
    });

    test('parses basic auth with -u flag', () {
      final result = parser.parse(
          'curl -u admin:secret https://api.example.com/secure');
      expect(result.username, 'admin');
      expect(result.password, 'secret');
    });

    test('parses insecure flag -k', () {
      final result = parser.parse(
          'curl -k https://self-signed.example.com');
      expect(result.insecure, true);
    });

    test('handles multiline with backslash continuation', () {
      final result = parser.parse(
          "curl -X POST \\\n"
          "  -H 'Content-Type: application/json' \\\n"
          "  -d '{\"key\":\"value\"}' \\\n"
          "  https://api.example.com/data");
      expect(result.method, 'POST');
      expect(result.url, 'https://api.example.com/data');
      expect(result.body, '{"key":"value"}');
      expect(result.headers['Content-Type'], 'application/json');
    });

    test('handles double-quoted strings', () {
      final result = parser.parse(
          'curl -H "X-Custom: my value" https://api.example.com');
      expect(result.headers['X-Custom'], 'my value');
    });

    test('parses --data-raw flag', () {
      final result = parser.parse(
          "curl --data-raw 'raw body content' https://api.example.com");
      expect(result.body, 'raw body content');
      expect(result.method, 'POST');
    });

    test('parses --data-binary flag', () {
      final result = parser.parse(
          "curl --data-binary '@file.bin' https://api.example.com");
      expect(result.body, '@file.bin');
    });

    test('infers body type from Content-Type header', () {
      final result = parser.parse(
          'curl -H "Content-Type: application/json" '
          "-d '{\"a\":1}' https://api.example.com");
      expect(result.bodyType, 'json');
    });

    test('detects cURL command', () {
      expect(parser.isCurlCommand('curl https://example.com'), true);
      expect(parser.isCurlCommand('  curl -X GET https://example.com'), true);
      expect(parser.isCurlCommand('https://example.com'), false);
      expect(parser.isCurlCommand('wget https://example.com'), false);
    });

    test('defaults to POST when body present without -X', () {
      final result = parser.parse(
          "curl -d 'data' https://api.example.com");
      expect(result.method, 'POST');
    });

    test('throws FormatException for non-curl input', () {
      expect(
          () => parser.parse('wget https://example.com'),
          throwsFormatException);
    });
  });
}
