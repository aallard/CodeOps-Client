/// Client-side cURL command parser for the Courier module.
///
/// Parses a cURL command string into structured request components: method,
/// URL, headers, body, auth, and SSL flags. Handles multiline backslash
/// continuations, single/double quoted strings, and all common cURL flags.
library;

/// Parsed result from a cURL command string.
class ParsedCurlRequest {
  /// HTTP method (defaults to GET, or POST when body present).
  final String method;

  /// Request URL.
  final String url;

  /// Header name→value map extracted from `-H` flags.
  final Map<String, String> headers;

  /// Request body from `-d`, `--data`, `--data-raw`, or `--data-binary`.
  final String? body;

  /// Inferred body type from Content-Type header.
  final String? bodyType;

  /// Basic auth username from `-u`/`--user`.
  final String? username;

  /// Basic auth password from `-u`/`--user`.
  final String? password;

  /// Whether the `-k`/`--insecure` flag was present.
  final bool insecure;

  /// Creates a [ParsedCurlRequest].
  const ParsedCurlRequest({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.bodyType,
    this.username,
    this.password,
    this.insecure = false,
  });
}

/// Parses cURL command strings into [ParsedCurlRequest] instances.
///
/// Supports:
/// - `-X METHOD` / `--request METHOD`
/// - `-H "Header: Value"` / `--header "Header: Value"`
/// - `-d 'body'` / `--data 'body'` / `--data-raw` / `--data-binary`
/// - `-u user:pass` / `--user user:pass`
/// - `-k` / `--insecure`
/// - `--url "URL"`
/// - Multiline commands with `\` continuation
/// - Single and double quoted strings
class CurlParserService {
  /// Creates a [CurlParserService].
  const CurlParserService();

  /// Returns true if [text] looks like a cURL command.
  bool isCurlCommand(String text) {
    final trimmed = text.trimLeft();
    return trimmed.startsWith('curl ') || trimmed == 'curl';
  }

  /// Parses a cURL command string into a [ParsedCurlRequest].
  ///
  /// Throws [FormatException] if the input does not start with `curl`.
  ParsedCurlRequest parse(String curlCommand) {
    // Normalize multiline continuations.
    final normalized = curlCommand
        .replaceAll('\\\n', ' ')
        .replaceAll('\\\r\n', ' ')
        .trim();

    final tokens = _tokenize(normalized);

    if (tokens.isEmpty || tokens.first != 'curl') {
      throw const FormatException('Not a valid cURL command');
    }

    String? method;
    String? url;
    final headers = <String, String>{};
    String? body;
    String? username;
    String? password;
    bool insecure = false;
    bool hasData = false;

    var i = 1; // skip 'curl'
    while (i < tokens.length) {
      final tok = tokens[i];

      switch (tok) {
        case '-X' || '--request':
          i++;
          if (i < tokens.length) method = tokens[i].toUpperCase();

        case '-H' || '--header':
          i++;
          if (i < tokens.length) {
            final header = tokens[i];
            final colonIdx = header.indexOf(':');
            if (colonIdx > 0) {
              final name = header.substring(0, colonIdx).trim();
              final value = header.substring(colonIdx + 1).trim();
              headers[name] = value;
            }
          }

        case '-d' || '--data' || '--data-raw' || '--data-binary':
          i++;
          if (i < tokens.length) {
            body = tokens[i];
            hasData = true;
          }

        case '-u' || '--user':
          i++;
          if (i < tokens.length) {
            final parts = tokens[i].split(':');
            username = parts.first;
            password = parts.length > 1 ? parts.sublist(1).join(':') : null;
          }

        case '-k' || '--insecure':
          insecure = true;

        case '--url':
          i++;
          if (i < tokens.length) url = tokens[i];

        case '--compressed' || '-s' || '--silent' || '-S' || '--show-error' ||
              '-v' || '--verbose' || '-L' || '--location' || '-i' ||
              '--include' || '-o' || '--output':
          // Skip flags that don't affect the request data.
          if (tok == '-o' || tok == '--output') i++; // skip output filename

        default:
          // Bare argument — likely the URL.
          if (!tok.startsWith('-') && url == null) {
            url = tok;
          }
      }
      i++;
    }

    // Default method based on body presence.
    method ??= hasData ? 'POST' : 'GET';

    // Infer body type from Content-Type header.
    String? bodyType;
    final ct = headers['Content-Type'] ?? headers['content-type'];
    if (ct != null) {
      if (ct.contains('application/json')) {
        bodyType = 'json';
      } else if (ct.contains('application/xml')) {
        bodyType = 'xml';
      } else if (ct.contains('text/html')) {
        bodyType = 'html';
      } else if (ct.contains('text/plain')) {
        bodyType = 'text';
      } else if (ct.contains('application/x-www-form-urlencoded')) {
        bodyType = 'urlencoded';
      } else if (ct.contains('multipart/form-data')) {
        bodyType = 'formdata';
      }
    }

    return ParsedCurlRequest(
      method: method,
      url: url ?? '',
      headers: headers,
      body: body,
      bodyType: bodyType,
      username: username,
      password: password,
      insecure: insecure,
    );
  }

  /// Tokenizes a cURL command respecting single and double quotes.
  List<String> _tokenize(String input) {
    final tokens = <String>[];
    final buf = StringBuffer();
    var inSingle = false;
    var inDouble = false;
    var escaped = false;

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];

      if (escaped) {
        buf.write(ch);
        escaped = false;
        continue;
      }

      if (ch == '\\' && !inSingle) {
        escaped = true;
        continue;
      }

      if (ch == "'" && !inDouble) {
        inSingle = !inSingle;
        continue;
      }

      if (ch == '"' && !inSingle) {
        inDouble = !inDouble;
        continue;
      }

      if (ch == ' ' && !inSingle && !inDouble) {
        if (buf.isNotEmpty) {
          tokens.add(buf.toString());
          buf.clear();
        }
        continue;
      }

      buf.write(ch);
    }

    if (buf.isNotEmpty) {
      tokens.add(buf.toString());
    }

    return tokens;
  }
}
