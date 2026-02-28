/// Enum types for the CodeOps-MCP module.
///
/// Each enum provides SCREAMING_SNAKE_CASE serialization matching the Server's
/// Java enums, plus a companion [JsonConverter] for use with `json_serializable`.
library;

import 'package:json_annotation/json_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SessionStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle state of an MCP AI development session.
enum SessionStatus {
  /// Session is being set up.
  initializing,

  /// Session is actively running.
  active,

  /// Session is writing back results.
  completing,

  /// Session completed successfully.
  completed,

  /// Session failed.
  failed,

  /// Session exceeded its timeout.
  timedOut,

  /// Session was cancelled by a user.
  cancelled;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        SessionStatus.initializing => 'INITIALIZING',
        SessionStatus.active => 'ACTIVE',
        SessionStatus.completing => 'COMPLETING',
        SessionStatus.completed => 'COMPLETED',
        SessionStatus.failed => 'FAILED',
        SessionStatus.timedOut => 'TIMED_OUT',
        SessionStatus.cancelled => 'CANCELLED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static SessionStatus fromJson(String json) => switch (json) {
        'INITIALIZING' => SessionStatus.initializing,
        'ACTIVE' => SessionStatus.active,
        'COMPLETING' => SessionStatus.completing,
        'COMPLETED' => SessionStatus.completed,
        'FAILED' => SessionStatus.failed,
        'TIMED_OUT' => SessionStatus.timedOut,
        'CANCELLED' => SessionStatus.cancelled,
        _ => throw ArgumentError('Unknown SessionStatus: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        SessionStatus.initializing => 'Initializing',
        SessionStatus.active => 'Active',
        SessionStatus.completing => 'Completing',
        SessionStatus.completed => 'Completed',
        SessionStatus.failed => 'Failed',
        SessionStatus.timedOut => 'Timed Out',
        SessionStatus.cancelled => 'Cancelled',
      };
}

/// JSON converter for [SessionStatus].
class SessionStatusConverter extends JsonConverter<SessionStatus, String> {
  /// Creates a [SessionStatusConverter].
  const SessionStatusConverter();

  @override
  SessionStatus fromJson(String json) => SessionStatus.fromJson(json);

  @override
  String toJson(SessionStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// DocumentType
// ─────────────────────────────────────────────────────────────────────────────

/// Type of project document managed by MCP.
enum DocumentType {
  /// CLAUDE.md project instructions.
  claudeMd,

  /// CONVENTIONS.md coding standards.
  conventionsMd,

  /// Architecture specification.
  architectureMd,

  /// Codebase audit document.
  auditMd,

  /// OpenAPI specification.
  openapiYaml,

  /// Custom project document.
  custom;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        DocumentType.claudeMd => 'CLAUDE_MD',
        DocumentType.conventionsMd => 'CONVENTIONS_MD',
        DocumentType.architectureMd => 'ARCHITECTURE_MD',
        DocumentType.auditMd => 'AUDIT_MD',
        DocumentType.openapiYaml => 'OPENAPI_YAML',
        DocumentType.custom => 'CUSTOM',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static DocumentType fromJson(String json) => switch (json) {
        'CLAUDE_MD' => DocumentType.claudeMd,
        'CONVENTIONS_MD' => DocumentType.conventionsMd,
        'ARCHITECTURE_MD' => DocumentType.architectureMd,
        'AUDIT_MD' => DocumentType.auditMd,
        'OPENAPI_YAML' => DocumentType.openapiYaml,
        'CUSTOM' => DocumentType.custom,
        _ => throw ArgumentError('Unknown DocumentType: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        DocumentType.claudeMd => 'CLAUDE.md',
        DocumentType.conventionsMd => 'CONVENTIONS.md',
        DocumentType.architectureMd => 'Architecture',
        DocumentType.auditMd => 'Audit',
        DocumentType.openapiYaml => 'OpenAPI',
        DocumentType.custom => 'Custom',
      };
}

/// JSON converter for [DocumentType].
class DocumentTypeConverter extends JsonConverter<DocumentType, String> {
  /// Creates a [DocumentTypeConverter].
  const DocumentTypeConverter();

  @override
  DocumentType fromJson(String json) => DocumentType.fromJson(json);

  @override
  String toJson(DocumentType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// ToolCallStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Result status of an MCP tool call.
enum ToolCallStatus {
  /// Tool call succeeded.
  success,

  /// Tool call failed.
  failure,

  /// Tool call timed out.
  timeout,

  /// Tool call was unauthorized.
  unauthorized;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        ToolCallStatus.success => 'SUCCESS',
        ToolCallStatus.failure => 'FAILURE',
        ToolCallStatus.timeout => 'TIMEOUT',
        ToolCallStatus.unauthorized => 'UNAUTHORIZED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static ToolCallStatus fromJson(String json) => switch (json) {
        'SUCCESS' => ToolCallStatus.success,
        'FAILURE' => ToolCallStatus.failure,
        'TIMEOUT' => ToolCallStatus.timeout,
        'UNAUTHORIZED' => ToolCallStatus.unauthorized,
        _ => throw ArgumentError('Unknown ToolCallStatus: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        ToolCallStatus.success => 'Success',
        ToolCallStatus.failure => 'Failure',
        ToolCallStatus.timeout => 'Timeout',
        ToolCallStatus.unauthorized => 'Unauthorized',
      };
}

/// JSON converter for [ToolCallStatus].
class ToolCallStatusConverter extends JsonConverter<ToolCallStatus, String> {
  /// Creates a [ToolCallStatusConverter].
  const ToolCallStatusConverter();

  @override
  ToolCallStatus fromJson(String json) => ToolCallStatus.fromJson(json);

  @override
  String toJson(ToolCallStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// ActivityType
// ─────────────────────────────────────────────────────────────────────────────

/// Type of MCP activity feed entry.
enum ActivityType {
  /// An MCP session completed successfully.
  sessionCompleted,

  /// An MCP session failed.
  sessionFailed,

  /// A project document was updated.
  documentUpdated,

  /// A coding convention changed.
  conventionChanged,

  /// A directive was changed.
  directiveChanged,

  /// An impact was detected across services.
  impactDetected;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        ActivityType.sessionCompleted => 'SESSION_COMPLETED',
        ActivityType.sessionFailed => 'SESSION_FAILED',
        ActivityType.documentUpdated => 'DOCUMENT_UPDATED',
        ActivityType.conventionChanged => 'CONVENTION_CHANGED',
        ActivityType.directiveChanged => 'DIRECTIVE_CHANGED',
        ActivityType.impactDetected => 'IMPACT_DETECTED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static ActivityType fromJson(String json) => switch (json) {
        'SESSION_COMPLETED' => ActivityType.sessionCompleted,
        'SESSION_FAILED' => ActivityType.sessionFailed,
        'DOCUMENT_UPDATED' => ActivityType.documentUpdated,
        'CONVENTION_CHANGED' => ActivityType.conventionChanged,
        'DIRECTIVE_CHANGED' => ActivityType.directiveChanged,
        'IMPACT_DETECTED' => ActivityType.impactDetected,
        _ => throw ArgumentError('Unknown ActivityType: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        ActivityType.sessionCompleted => 'Session Completed',
        ActivityType.sessionFailed => 'Session Failed',
        ActivityType.documentUpdated => 'Document Updated',
        ActivityType.conventionChanged => 'Convention Changed',
        ActivityType.directiveChanged => 'Directive Changed',
        ActivityType.impactDetected => 'Impact Detected',
      };
}

/// JSON converter for [ActivityType].
class ActivityTypeConverter extends JsonConverter<ActivityType, String> {
  /// Creates an [ActivityTypeConverter].
  const ActivityTypeConverter();

  @override
  ActivityType fromJson(String json) => ActivityType.fromJson(json);

  @override
  String toJson(ActivityType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// TokenStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle state of an MCP API token.
enum TokenStatus {
  /// Token is active and can be used for authentication.
  active,

  /// Token has been revoked.
  revoked,

  /// Token has expired.
  expired;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        TokenStatus.active => 'ACTIVE',
        TokenStatus.revoked => 'REVOKED',
        TokenStatus.expired => 'EXPIRED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static TokenStatus fromJson(String json) => switch (json) {
        'ACTIVE' => TokenStatus.active,
        'REVOKED' => TokenStatus.revoked,
        'EXPIRED' => TokenStatus.expired,
        _ => throw ArgumentError('Unknown TokenStatus: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        TokenStatus.active => 'Active',
        TokenStatus.revoked => 'Revoked',
        TokenStatus.expired => 'Expired',
      };
}

/// JSON converter for [TokenStatus].
class TokenStatusConverter extends JsonConverter<TokenStatus, String> {
  /// Creates a [TokenStatusConverter].
  const TokenStatusConverter();

  @override
  TokenStatus fromJson(String json) => TokenStatus.fromJson(json);

  @override
  String toJson(TokenStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// McpTransport
// ─────────────────────────────────────────────────────────────────────────────

/// MCP protocol transport type.
enum McpTransport {
  /// Server-Sent Events transport.
  sse,

  /// HTTP (stateless REST) transport.
  http,

  /// Standard I/O (CLI subprocess) transport.
  stdio;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        McpTransport.sse => 'SSE',
        McpTransport.http => 'HTTP',
        McpTransport.stdio => 'STDIO',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static McpTransport fromJson(String json) => switch (json) {
        'SSE' => McpTransport.sse,
        'HTTP' => McpTransport.http,
        'STDIO' => McpTransport.stdio,
        _ => throw ArgumentError('Unknown McpTransport: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        McpTransport.sse => 'SSE',
        McpTransport.http => 'HTTP',
        McpTransport.stdio => 'STDIO',
      };
}

/// JSON converter for [McpTransport].
class McpTransportConverter extends JsonConverter<McpTransport, String> {
  /// Creates a [McpTransportConverter].
  const McpTransportConverter();

  @override
  McpTransport fromJson(String json) => McpTransport.fromJson(json);

  @override
  String toJson(McpTransport object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthorType
// ─────────────────────────────────────────────────────────────────────────────

/// Author type for document updates.
enum AuthorType {
  /// Update authored by a human user.
  human,

  /// Update authored by an AI agent.
  ai;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        AuthorType.human => 'HUMAN',
        AuthorType.ai => 'AI',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static AuthorType fromJson(String json) => switch (json) {
        'HUMAN' => AuthorType.human,
        'AI' => AuthorType.ai,
        _ => throw ArgumentError('Unknown AuthorType: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        AuthorType.human => 'Human',
        AuthorType.ai => 'AI',
      };
}

/// JSON converter for [AuthorType].
class AuthorTypeConverter extends JsonConverter<AuthorType, String> {
  /// Creates an [AuthorTypeConverter].
  const AuthorTypeConverter();

  @override
  AuthorType fromJson(String json) => AuthorType.fromJson(json);

  @override
  String toJson(AuthorType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// McpEnvironment
// ─────────────────────────────────────────────────────────────────────────────

/// Deployment environment for MCP sessions and developer profiles.
///
/// Named [McpEnvironment] to avoid collision with the Courier
/// `CourierEnvironment` entity.
enum McpEnvironment {
  /// Local development machine.
  local,

  /// Shared development server.
  development,

  /// Pre-production staging environment.
  staging,

  /// Live production environment.
  production;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        McpEnvironment.local => 'LOCAL',
        McpEnvironment.development => 'DEVELOPMENT',
        McpEnvironment.staging => 'STAGING',
        McpEnvironment.production => 'PRODUCTION',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static McpEnvironment fromJson(String json) => switch (json) {
        'LOCAL' => McpEnvironment.local,
        'DEVELOPMENT' => McpEnvironment.development,
        'STAGING' => McpEnvironment.staging,
        'PRODUCTION' => McpEnvironment.production,
        _ => throw ArgumentError('Unknown McpEnvironment: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        McpEnvironment.local => 'Local',
        McpEnvironment.development => 'Development',
        McpEnvironment.staging => 'Staging',
        McpEnvironment.production => 'Production',
      };
}

/// JSON converter for [McpEnvironment].
class McpEnvironmentConverter extends JsonConverter<McpEnvironment, String> {
  /// Creates a [McpEnvironmentConverter].
  const McpEnvironmentConverter();

  @override
  McpEnvironment fromJson(String json) => McpEnvironment.fromJson(json);

  @override
  String toJson(McpEnvironment object) => object.toJson();
}
