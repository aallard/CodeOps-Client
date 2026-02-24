/// Enum types for the CodeOps-Courier module.
///
/// Each enum provides SCREAMING_SNAKE_CASE serialization matching the Server's
/// Java enums, plus a companion [JsonConverter] for use with `json_serializable`.
library;

import 'package:json_annotation/json_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CourierHttpMethod
// ─────────────────────────────────────────────────────────────────────────────

/// HTTP methods supported by Courier API requests.
///
/// Named `CourierHttpMethod` to avoid conflict with Dart/Flutter built-in types.
enum CourierHttpMethod {
  /// HTTP GET.
  get,

  /// HTTP POST.
  post,

  /// HTTP PUT.
  put,

  /// HTTP PATCH.
  patch,

  /// HTTP DELETE.
  delete,

  /// HTTP HEAD.
  head,

  /// HTTP OPTIONS.
  options;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        CourierHttpMethod.get => 'GET',
        CourierHttpMethod.post => 'POST',
        CourierHttpMethod.put => 'PUT',
        CourierHttpMethod.patch => 'PATCH',
        CourierHttpMethod.delete => 'DELETE',
        CourierHttpMethod.head => 'HEAD',
        CourierHttpMethod.options => 'OPTIONS',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static CourierHttpMethod fromJson(String json) => switch (json) {
        'GET' => CourierHttpMethod.get,
        'POST' => CourierHttpMethod.post,
        'PUT' => CourierHttpMethod.put,
        'PATCH' => CourierHttpMethod.patch,
        'DELETE' => CourierHttpMethod.delete,
        'HEAD' => CourierHttpMethod.head,
        'OPTIONS' => CourierHttpMethod.options,
        _ => throw ArgumentError('Unknown CourierHttpMethod: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        CourierHttpMethod.get => 'GET',
        CourierHttpMethod.post => 'POST',
        CourierHttpMethod.put => 'PUT',
        CourierHttpMethod.patch => 'PATCH',
        CourierHttpMethod.delete => 'DELETE',
        CourierHttpMethod.head => 'HEAD',
        CourierHttpMethod.options => 'OPTIONS',
      };
}

/// JSON converter for [CourierHttpMethod].
class CourierHttpMethodConverter
    extends JsonConverter<CourierHttpMethod, String> {
  /// Creates a [CourierHttpMethodConverter].
  const CourierHttpMethodConverter();

  @override
  CourierHttpMethod fromJson(String json) => CourierHttpMethod.fromJson(json);

  @override
  String toJson(CourierHttpMethod object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthType
// ─────────────────────────────────────────────────────────────────────────────

/// Authentication types for request auth configuration.
enum AuthType {
  /// No authentication.
  noAuth,

  /// API key authentication.
  apiKey,

  /// Bearer token authentication.
  bearerToken,

  /// HTTP basic authentication.
  basicAuth,

  /// OAuth 2.0 Authorization Code flow.
  oauth2AuthorizationCode,

  /// OAuth 2.0 Client Credentials flow.
  oauth2ClientCredentials,

  /// OAuth 2.0 Implicit flow.
  oauth2Implicit,

  /// OAuth 2.0 Password flow.
  oauth2Password,

  /// JWT Bearer authentication.
  jwtBearer,

  /// Inherit authentication from parent collection or folder.
  inheritFromParent;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        AuthType.noAuth => 'NO_AUTH',
        AuthType.apiKey => 'API_KEY',
        AuthType.bearerToken => 'BEARER_TOKEN',
        AuthType.basicAuth => 'BASIC_AUTH',
        AuthType.oauth2AuthorizationCode => 'OAUTH2_AUTHORIZATION_CODE',
        AuthType.oauth2ClientCredentials => 'OAUTH2_CLIENT_CREDENTIALS',
        AuthType.oauth2Implicit => 'OAUTH2_IMPLICIT',
        AuthType.oauth2Password => 'OAUTH2_PASSWORD',
        AuthType.jwtBearer => 'JWT_BEARER',
        AuthType.inheritFromParent => 'INHERIT_FROM_PARENT',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static AuthType fromJson(String json) => switch (json) {
        'NO_AUTH' => AuthType.noAuth,
        'API_KEY' => AuthType.apiKey,
        'BEARER_TOKEN' => AuthType.bearerToken,
        'BASIC_AUTH' => AuthType.basicAuth,
        'OAUTH2_AUTHORIZATION_CODE' => AuthType.oauth2AuthorizationCode,
        'OAUTH2_CLIENT_CREDENTIALS' => AuthType.oauth2ClientCredentials,
        'OAUTH2_IMPLICIT' => AuthType.oauth2Implicit,
        'OAUTH2_PASSWORD' => AuthType.oauth2Password,
        'JWT_BEARER' => AuthType.jwtBearer,
        'INHERIT_FROM_PARENT' => AuthType.inheritFromParent,
        _ => throw ArgumentError('Unknown AuthType: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        AuthType.noAuth => 'No Auth',
        AuthType.apiKey => 'API Key',
        AuthType.bearerToken => 'Bearer Token',
        AuthType.basicAuth => 'Basic Auth',
        AuthType.oauth2AuthorizationCode => 'OAuth 2.0 Authorization Code',
        AuthType.oauth2ClientCredentials => 'OAuth 2.0 Client Credentials',
        AuthType.oauth2Implicit => 'OAuth 2.0 Implicit',
        AuthType.oauth2Password => 'OAuth 2.0 Password',
        AuthType.jwtBearer => 'JWT Bearer',
        AuthType.inheritFromParent => 'Inherit from Parent',
      };
}

/// JSON converter for [AuthType].
class AuthTypeConverter extends JsonConverter<AuthType, String> {
  /// Creates an [AuthTypeConverter].
  const AuthTypeConverter();

  @override
  AuthType fromJson(String json) => AuthType.fromJson(json);

  @override
  String toJson(AuthType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// BodyType
// ─────────────────────────────────────────────────────────────────────────────

/// Request body content types.
enum BodyType {
  /// No body.
  none,

  /// Multipart form data.
  formData,

  /// URL-encoded form data.
  xWwwFormUrlEncoded,

  /// Raw JSON body.
  rawJson,

  /// Raw XML body.
  rawXml,

  /// Raw HTML body.
  rawHtml,

  /// Raw plain text body.
  rawText,

  /// Raw YAML body.
  rawYaml,

  /// Binary file body.
  binary,

  /// GraphQL query body.
  graphql;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        BodyType.none => 'NONE',
        BodyType.formData => 'FORM_DATA',
        BodyType.xWwwFormUrlEncoded => 'X_WWW_FORM_URLENCODED',
        BodyType.rawJson => 'RAW_JSON',
        BodyType.rawXml => 'RAW_XML',
        BodyType.rawHtml => 'RAW_HTML',
        BodyType.rawText => 'RAW_TEXT',
        BodyType.rawYaml => 'RAW_YAML',
        BodyType.binary => 'BINARY',
        BodyType.graphql => 'GRAPHQL',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static BodyType fromJson(String json) => switch (json) {
        'NONE' => BodyType.none,
        'FORM_DATA' => BodyType.formData,
        'X_WWW_FORM_URLENCODED' => BodyType.xWwwFormUrlEncoded,
        'RAW_JSON' => BodyType.rawJson,
        'RAW_XML' => BodyType.rawXml,
        'RAW_HTML' => BodyType.rawHtml,
        'RAW_TEXT' => BodyType.rawText,
        'RAW_YAML' => BodyType.rawYaml,
        'BINARY' => BodyType.binary,
        'GRAPHQL' => BodyType.graphql,
        _ => throw ArgumentError('Unknown BodyType: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        BodyType.none => 'None',
        BodyType.formData => 'Form Data',
        BodyType.xWwwFormUrlEncoded => 'URL Encoded',
        BodyType.rawJson => 'JSON',
        BodyType.rawXml => 'XML',
        BodyType.rawHtml => 'HTML',
        BodyType.rawText => 'Text',
        BodyType.rawYaml => 'YAML',
        BodyType.binary => 'Binary',
        BodyType.graphql => 'GraphQL',
      };
}

/// JSON converter for [BodyType].
class BodyTypeConverter extends JsonConverter<BodyType, String> {
  /// Creates a [BodyTypeConverter].
  const BodyTypeConverter();

  @override
  BodyType fromJson(String json) => BodyType.fromJson(json);

  @override
  String toJson(BodyType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// CodeLanguage
// ─────────────────────────────────────────────────────────────────────────────

/// Supported code generation target languages.
enum CodeLanguage {
  /// cURL command line.
  curl,

  /// Python Requests library.
  pythonRequests,

  /// JavaScript Fetch API.
  javascriptFetch,

  /// JavaScript Axios library.
  javascriptAxios,

  /// Java HttpClient.
  javaHttpClient,

  /// Java OkHttp library.
  javaOkhttp,

  /// C# HttpClient.
  csharpHttpClient,

  /// Go net/http.
  go,

  /// Ruby Net::HTTP.
  ruby,

  /// PHP cURL.
  php,

  /// Swift URLSession.
  swift,

  /// Kotlin OkHttp.
  kotlin;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        CodeLanguage.curl => 'CURL',
        CodeLanguage.pythonRequests => 'PYTHON_REQUESTS',
        CodeLanguage.javascriptFetch => 'JAVASCRIPT_FETCH',
        CodeLanguage.javascriptAxios => 'JAVASCRIPT_AXIOS',
        CodeLanguage.javaHttpClient => 'JAVA_HTTP_CLIENT',
        CodeLanguage.javaOkhttp => 'JAVA_OKHTTP',
        CodeLanguage.csharpHttpClient => 'CSHARP_HTTP_CLIENT',
        CodeLanguage.go => 'GO',
        CodeLanguage.ruby => 'RUBY',
        CodeLanguage.php => 'PHP',
        CodeLanguage.swift => 'SWIFT',
        CodeLanguage.kotlin => 'KOTLIN',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static CodeLanguage fromJson(String json) => switch (json) {
        'CURL' => CodeLanguage.curl,
        'PYTHON_REQUESTS' => CodeLanguage.pythonRequests,
        'JAVASCRIPT_FETCH' => CodeLanguage.javascriptFetch,
        'JAVASCRIPT_AXIOS' => CodeLanguage.javascriptAxios,
        'JAVA_HTTP_CLIENT' => CodeLanguage.javaHttpClient,
        'JAVA_OKHTTP' => CodeLanguage.javaOkhttp,
        'CSHARP_HTTP_CLIENT' => CodeLanguage.csharpHttpClient,
        'GO' => CodeLanguage.go,
        'RUBY' => CodeLanguage.ruby,
        'PHP' => CodeLanguage.php,
        'SWIFT' => CodeLanguage.swift,
        'KOTLIN' => CodeLanguage.kotlin,
        _ => throw ArgumentError('Unknown CodeLanguage: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        CodeLanguage.curl => 'cURL',
        CodeLanguage.pythonRequests => 'Python (Requests)',
        CodeLanguage.javascriptFetch => 'JavaScript (Fetch)',
        CodeLanguage.javascriptAxios => 'JavaScript (Axios)',
        CodeLanguage.javaHttpClient => 'Java (HttpClient)',
        CodeLanguage.javaOkhttp => 'Java (OkHttp)',
        CodeLanguage.csharpHttpClient => 'C# (HttpClient)',
        CodeLanguage.go => 'Go',
        CodeLanguage.ruby => 'Ruby',
        CodeLanguage.php => 'PHP',
        CodeLanguage.swift => 'Swift',
        CodeLanguage.kotlin => 'Kotlin',
      };
}

/// JSON converter for [CodeLanguage].
class CodeLanguageConverter extends JsonConverter<CodeLanguage, String> {
  /// Creates a [CodeLanguageConverter].
  const CodeLanguageConverter();

  @override
  CodeLanguage fromJson(String json) => CodeLanguage.fromJson(json);

  @override
  String toJson(CodeLanguage object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// RunStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Collection run execution status.
enum RunStatus {
  /// Run is queued.
  pending,

  /// Run is actively executing.
  running,

  /// Run finished successfully.
  completed,

  /// Run encountered an error.
  failed,

  /// Run was cancelled by user.
  cancelled;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        RunStatus.pending => 'PENDING',
        RunStatus.running => 'RUNNING',
        RunStatus.completed => 'COMPLETED',
        RunStatus.failed => 'FAILED',
        RunStatus.cancelled => 'CANCELLED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static RunStatus fromJson(String json) => switch (json) {
        'PENDING' => RunStatus.pending,
        'RUNNING' => RunStatus.running,
        'COMPLETED' => RunStatus.completed,
        'FAILED' => RunStatus.failed,
        'CANCELLED' => RunStatus.cancelled,
        _ => throw ArgumentError('Unknown RunStatus: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        RunStatus.pending => 'Pending',
        RunStatus.running => 'Running',
        RunStatus.completed => 'Completed',
        RunStatus.failed => 'Failed',
        RunStatus.cancelled => 'Cancelled',
      };
}

/// JSON converter for [RunStatus].
class RunStatusConverter extends JsonConverter<RunStatus, String> {
  /// Creates a [RunStatusConverter].
  const RunStatusConverter();

  @override
  RunStatus fromJson(String json) => RunStatus.fromJson(json);

  @override
  String toJson(RunStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// ScriptType
// ─────────────────────────────────────────────────────────────────────────────

/// Script execution timing.
enum ScriptType {
  /// Runs before the request is sent.
  preRequest,

  /// Runs after the response is received.
  postResponse;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        ScriptType.preRequest => 'PRE_REQUEST',
        ScriptType.postResponse => 'POST_RESPONSE',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static ScriptType fromJson(String json) => switch (json) {
        'PRE_REQUEST' => ScriptType.preRequest,
        'POST_RESPONSE' => ScriptType.postResponse,
        _ => throw ArgumentError('Unknown ScriptType: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        ScriptType.preRequest => 'Pre-Request',
        ScriptType.postResponse => 'Post-Response',
      };
}

/// JSON converter for [ScriptType].
class ScriptTypeConverter extends JsonConverter<ScriptType, String> {
  /// Creates a [ScriptTypeConverter].
  const ScriptTypeConverter();

  @override
  ScriptType fromJson(String json) => ScriptType.fromJson(json);

  @override
  String toJson(ScriptType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// SharePermission
// ─────────────────────────────────────────────────────────────────────────────

/// Collection sharing permission levels.
enum SharePermission {
  /// Read-only access.
  viewer,

  /// Read and write access.
  editor,

  /// Full access including sharing management.
  admin;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        SharePermission.viewer => 'VIEWER',
        SharePermission.editor => 'EDITOR',
        SharePermission.admin => 'ADMIN',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static SharePermission fromJson(String json) => switch (json) {
        'VIEWER' => SharePermission.viewer,
        'EDITOR' => SharePermission.editor,
        'ADMIN' => SharePermission.admin,
        _ => throw ArgumentError('Unknown SharePermission: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        SharePermission.viewer => 'Viewer',
        SharePermission.editor => 'Editor',
        SharePermission.admin => 'Admin',
      };
}

/// JSON converter for [SharePermission].
class SharePermissionConverter
    extends JsonConverter<SharePermission, String> {
  /// Creates a [SharePermissionConverter].
  const SharePermissionConverter();

  @override
  SharePermission fromJson(String json) => SharePermission.fromJson(json);

  @override
  String toJson(SharePermission object) => object.toJson();
}
