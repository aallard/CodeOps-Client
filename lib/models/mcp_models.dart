/// Model classes for the CodeOps-MCP module.
///
/// Maps to response and request DTOs defined in the MCP controllers.
/// All classes use [JsonSerializable] with generated `fromJson` / `toJson`
/// methods via build_runner.
///
/// Organized by domain:
/// - Sessions (2 classes)
/// - Tool Calls & Results (3 classes)
/// - Developer Profiles & Tokens (3 classes)
/// - Project Documents (3 classes)
/// - Activity Feed (1 class)
/// - Tool Definitions (1 class)
library;

import 'package:json_annotation/json_annotation.dart';

import 'mcp_enums.dart';

part 'mcp_models.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sessions
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight list-view DTO for an MCP session.
@JsonSerializable()
class McpSession {
  /// Unique identifier (UUID).
  final String? id;

  /// Session lifecycle status.
  @SessionStatusConverter()
  final SessionStatus? status;

  /// Denormalized project name.
  final String? projectName;

  /// Denormalized developer display name.
  final String? developerName;

  /// Deployment environment.
  @McpEnvironmentConverter()
  final McpEnvironment? environment;

  /// Protocol transport type.
  @McpTransportConverter()
  final McpTransport? transport;

  /// When the session became active.
  final DateTime? startedAt;

  /// When the session completed or failed.
  final DateTime? completedAt;

  /// Running count of tool calls.
  final int? totalToolCalls;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [McpSession].
  const McpSession({
    this.id,
    this.status,
    this.projectName,
    this.developerName,
    this.environment,
    this.transport,
    this.startedAt,
    this.completedAt,
    this.totalToolCalls,
    this.createdAt,
  });

  /// Deserializes a [McpSession] from a JSON map.
  factory McpSession.fromJson(Map<String, dynamic> json) =>
      _$McpSessionFromJson(json);

  /// Serializes this [McpSession] to a JSON map.
  Map<String, dynamic> toJson() => _$McpSessionToJson(this);
}

/// Detailed session DTO including tool calls and result.
@JsonSerializable(explicitToJson: true)
class McpSessionDetail {
  /// Unique identifier (UUID).
  final String? id;

  /// Session lifecycle status.
  @SessionStatusConverter()
  final SessionStatus? status;

  /// Denormalized project name.
  final String? projectName;

  /// Denormalized developer display name.
  final String? developerName;

  /// Deployment environment.
  @McpEnvironmentConverter()
  final McpEnvironment? environment;

  /// Protocol transport type.
  @McpTransportConverter()
  final McpTransport? transport;

  /// When the session became active.
  final DateTime? startedAt;

  /// When the session completed or failed.
  final DateTime? completedAt;

  /// Last tool call timestamp.
  final DateTime? lastActivityAt;

  /// Max session duration in minutes.
  final int? timeoutMinutes;

  /// Running count of tool calls.
  final int? totalToolCalls;

  /// Error message on failure.
  final String? errorMessage;

  /// List of tool calls made during the session.
  final List<SessionToolCall>? toolCalls;

  /// Session result summary.
  final SessionResult? result;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [McpSessionDetail].
  const McpSessionDetail({
    this.id,
    this.status,
    this.projectName,
    this.developerName,
    this.environment,
    this.transport,
    this.startedAt,
    this.completedAt,
    this.lastActivityAt,
    this.timeoutMinutes,
    this.totalToolCalls,
    this.errorMessage,
    this.toolCalls,
    this.result,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [McpSessionDetail] from a JSON map.
  factory McpSessionDetail.fromJson(Map<String, dynamic> json) =>
      _$McpSessionDetailFromJson(json);

  /// Serializes this [McpSessionDetail] to a JSON map.
  Map<String, dynamic> toJson() => _$McpSessionDetailToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tool Calls & Results
// ─────────────────────────────────────────────────────────────────────────────

/// Single tool call within an MCP session.
@JsonSerializable()
class SessionToolCall {
  /// Unique identifier (UUID).
  final String? id;

  /// Fully qualified tool name.
  final String? toolName;

  /// Tool category.
  final String? toolCategory;

  /// Tool call arguments as JSON string.
  final String? requestJson;

  /// Tool call result as JSON string.
  final String? responseJson;

  /// Tool call result status.
  @ToolCallStatusConverter()
  final ToolCallStatus? status;

  /// Execution time in milliseconds.
  final int? durationMs;

  /// Error message on failure.
  final String? errorMessage;

  /// When the call was made.
  final DateTime? calledAt;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [SessionToolCall].
  const SessionToolCall({
    this.id,
    this.toolName,
    this.toolCategory,
    this.requestJson,
    this.responseJson,
    this.status,
    this.durationMs,
    this.errorMessage,
    this.calledAt,
    this.createdAt,
  });

  /// Deserializes a [SessionToolCall] from a JSON map.
  factory SessionToolCall.fromJson(Map<String, dynamic> json) =>
      _$SessionToolCallFromJson(json);

  /// Serializes this [SessionToolCall] to a JSON map.
  Map<String, dynamic> toJson() => _$SessionToolCallToJson(this);
}

/// Completed session result summary.
@JsonSerializable()
class SessionResult {
  /// Unique identifier (UUID).
  final String? id;

  /// AI-generated session summary.
  final String? summary;

  /// JSON array of commit hashes.
  final String? commitHashesJson;

  /// JSON of files changed.
  final String? filesChangedJson;

  /// JSON of endpoints changed.
  final String? endpointsChangedJson;

  /// Number of tests added.
  final int? testsAdded;

  /// Code coverage percentage.
  final double? testCoverage;

  /// Lines added.
  final int? linesAdded;

  /// Lines removed.
  final int? linesRemoved;

  /// JSON of dependency changes.
  final String? dependencyChangesJson;

  /// Total session duration in minutes.
  final int? durationMinutes;

  /// Estimated token usage.
  final int? tokenUsage;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [SessionResult].
  const SessionResult({
    this.id,
    this.summary,
    this.commitHashesJson,
    this.filesChangedJson,
    this.endpointsChangedJson,
    this.testsAdded,
    this.testCoverage,
    this.linesAdded,
    this.linesRemoved,
    this.dependencyChangesJson,
    this.durationMinutes,
    this.tokenUsage,
    this.createdAt,
  });

  /// Deserializes a [SessionResult] from a JSON map.
  factory SessionResult.fromJson(Map<String, dynamic> json) =>
      _$SessionResultFromJson(json);

  /// Serializes this [SessionResult] to a JSON map.
  Map<String, dynamic> toJson() => _$SessionResultToJson(this);
}

/// Tool call summary aggregated by tool name.
@JsonSerializable()
class ToolCallSummary {
  /// Fully qualified tool name.
  final String? toolName;

  /// Number of times the tool was called.
  final int? callCount;

  /// Creates a [ToolCallSummary].
  const ToolCallSummary({
    this.toolName,
    this.callCount,
  });

  /// Deserializes a [ToolCallSummary] from a JSON map.
  factory ToolCallSummary.fromJson(Map<String, dynamic> json) =>
      _$ToolCallSummaryFromJson(json);

  /// Serializes this [ToolCallSummary] to a JSON map.
  Map<String, dynamic> toJson() => _$ToolCallSummaryToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Developer Profiles & Tokens
// ─────────────────────────────────────────────────────────────────────────────

/// MCP developer profile.
@JsonSerializable()
class DeveloperProfile {
  /// Unique identifier (UUID).
  final String? id;

  /// Override display name for MCP context.
  final String? displayName;

  /// Developer bio.
  final String? bio;

  /// Default deployment environment.
  @McpEnvironmentConverter()
  final McpEnvironment? defaultEnvironment;

  /// JSON string of AI preferences.
  final String? preferencesJson;

  /// IANA timezone identifier.
  final String? timezone;

  /// Whether the profile is active.
  final bool? isActive;

  /// Owning team ID.
  final String? teamId;

  /// Associated user ID.
  final String? userId;

  /// User's display name.
  final String? userDisplayName;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [DeveloperProfile].
  const DeveloperProfile({
    this.id,
    this.displayName,
    this.bio,
    this.defaultEnvironment,
    this.preferencesJson,
    this.timezone,
    this.isActive,
    this.teamId,
    this.userId,
    this.userDisplayName,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [DeveloperProfile] from a JSON map.
  factory DeveloperProfile.fromJson(Map<String, dynamic> json) =>
      _$DeveloperProfileFromJson(json);

  /// Serializes this [DeveloperProfile] to a JSON map.
  Map<String, dynamic> toJson() => _$DeveloperProfileToJson(this);
}

/// MCP API token (list view — no raw token).
@JsonSerializable()
class McpApiToken {
  /// Unique identifier (UUID).
  final String? id;

  /// Human-readable token name.
  final String? name;

  /// Display prefix (e.g., "mcp_a1b2...").
  final String? tokenPrefix;

  /// Token lifecycle status.
  @TokenStatusConverter()
  final TokenStatus? status;

  /// Last authentication timestamp.
  final DateTime? lastUsedAt;

  /// Expiration timestamp.
  final DateTime? expiresAt;

  /// JSON array of allowed tool categories.
  final String? scopesJson;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [McpApiToken].
  const McpApiToken({
    this.id,
    this.name,
    this.tokenPrefix,
    this.status,
    this.lastUsedAt,
    this.expiresAt,
    this.scopesJson,
    this.createdAt,
  });

  /// Deserializes a [McpApiToken] from a JSON map.
  factory McpApiToken.fromJson(Map<String, dynamic> json) =>
      _$McpApiTokenFromJson(json);

  /// Serializes this [McpApiToken] to a JSON map.
  Map<String, dynamic> toJson() => _$McpApiTokenToJson(this);
}

/// Response returned only at token creation (includes raw token).
@JsonSerializable()
class McpApiTokenCreated {
  /// Unique identifier (UUID).
  final String? id;

  /// Human-readable token name.
  final String? name;

  /// Display prefix (e.g., "mcp_a1b2...").
  final String? tokenPrefix;

  /// The actual token value (only returned at creation).
  final String? rawToken;

  /// Token lifecycle status.
  @TokenStatusConverter()
  final TokenStatus? status;

  /// Expiration timestamp.
  final DateTime? expiresAt;

  /// JSON array of allowed tool categories.
  final String? scopesJson;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [McpApiTokenCreated].
  const McpApiTokenCreated({
    this.id,
    this.name,
    this.tokenPrefix,
    this.rawToken,
    this.status,
    this.expiresAt,
    this.scopesJson,
    this.createdAt,
  });

  /// Deserializes a [McpApiTokenCreated] from a JSON map.
  factory McpApiTokenCreated.fromJson(Map<String, dynamic> json) =>
      _$McpApiTokenCreatedFromJson(json);

  /// Serializes this [McpApiTokenCreated] to a JSON map.
  Map<String, dynamic> toJson() => _$McpApiTokenCreatedToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Project Documents
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight list-view DTO for a project document.
@JsonSerializable()
class ProjectDocument {
  /// Unique identifier (UUID).
  final String? id;

  /// Document type.
  @DocumentTypeConverter()
  final DocumentType? documentType;

  /// Name for CUSTOM types.
  final String? customName;

  /// Author type of the last update.
  @AuthorTypeConverter()
  final AuthorType? lastAuthorType;

  /// Session that last updated.
  final String? lastSessionId;

  /// Whether flagged as stale.
  final bool? isFlagged;

  /// Reason for the flag.
  final String? flagReason;

  /// Owning project ID.
  final String? projectId;

  /// Name of the user who last updated.
  final String? lastUpdatedByName;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [ProjectDocument].
  const ProjectDocument({
    this.id,
    this.documentType,
    this.customName,
    this.lastAuthorType,
    this.lastSessionId,
    this.isFlagged,
    this.flagReason,
    this.projectId,
    this.lastUpdatedByName,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [ProjectDocument] from a JSON map.
  factory ProjectDocument.fromJson(Map<String, dynamic> json) =>
      _$ProjectDocumentFromJson(json);

  /// Serializes this [ProjectDocument] to a JSON map.
  Map<String, dynamic> toJson() => _$ProjectDocumentToJson(this);
}

/// Detailed document with content and version history.
@JsonSerializable(explicitToJson: true)
class ProjectDocumentDetail {
  /// Unique identifier (UUID).
  final String? id;

  /// Document type.
  @DocumentTypeConverter()
  final DocumentType? documentType;

  /// Name for CUSTOM types.
  final String? customName;

  /// Full document content.
  final String? currentContent;

  /// Author type of the last update.
  @AuthorTypeConverter()
  final AuthorType? lastAuthorType;

  /// Session that last updated.
  final String? lastSessionId;

  /// Whether flagged as stale.
  final bool? isFlagged;

  /// Reason for the flag.
  final String? flagReason;

  /// Owning project ID.
  final String? projectId;

  /// Name of the user who last updated.
  final String? lastUpdatedByName;

  /// Version history.
  final List<ProjectDocumentVersion>? versions;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Creates a [ProjectDocumentDetail].
  const ProjectDocumentDetail({
    this.id,
    this.documentType,
    this.customName,
    this.currentContent,
    this.lastAuthorType,
    this.lastSessionId,
    this.isFlagged,
    this.flagReason,
    this.projectId,
    this.lastUpdatedByName,
    this.versions,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [ProjectDocumentDetail] from a JSON map.
  factory ProjectDocumentDetail.fromJson(Map<String, dynamic> json) =>
      _$ProjectDocumentDetailFromJson(json);

  /// Serializes this [ProjectDocumentDetail] to a JSON map.
  Map<String, dynamic> toJson() => _$ProjectDocumentDetailToJson(this);
}

/// Document version entry.
@JsonSerializable()
class ProjectDocumentVersion {
  /// Unique identifier (UUID).
  final String? id;

  /// Sequential version number.
  final int? versionNumber;

  /// Full content at this version.
  final String? content;

  /// Author type.
  @AuthorTypeConverter()
  final AuthorType? authorType;

  /// Associated Git commit hash.
  final String? commitHash;

  /// What changed in this version.
  final String? changeDescription;

  /// Display name of the author.
  final String? authorName;

  /// MCP session that produced this version.
  final String? sessionId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [ProjectDocumentVersion].
  const ProjectDocumentVersion({
    this.id,
    this.versionNumber,
    this.content,
    this.authorType,
    this.commitHash,
    this.changeDescription,
    this.authorName,
    this.sessionId,
    this.createdAt,
  });

  /// Deserializes a [ProjectDocumentVersion] from a JSON map.
  factory ProjectDocumentVersion.fromJson(Map<String, dynamic> json) =>
      _$ProjectDocumentVersionFromJson(json);

  /// Serializes this [ProjectDocumentVersion] to a JSON map.
  Map<String, dynamic> toJson() => _$ProjectDocumentVersionToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity Feed
// ─────────────────────────────────────────────────────────────────────────────

/// Activity feed entry.
@JsonSerializable()
class ActivityFeedEntry {
  /// Unique identifier (UUID).
  final String? id;

  /// Type of activity.
  @ActivityTypeConverter()
  final ActivityType? activityType;

  /// Human-readable title.
  final String? title;

  /// Full detail or summary.
  final String? detail;

  /// Originating CodeOps module.
  final String? sourceModule;

  /// ID of the source entity.
  final String? sourceEntityId;

  /// Denormalized project name.
  final String? projectName;

  /// JSON array of impacted service UUIDs.
  final String? impactedServiceIdsJson;

  /// Relay message ID if posted to channel.
  final String? relayMessageId;

  /// Display name of the actor.
  final String? actorName;

  /// Associated project ID.
  final String? projectId;

  /// Associated session ID.
  final String? sessionId;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates an [ActivityFeedEntry].
  const ActivityFeedEntry({
    this.id,
    this.activityType,
    this.title,
    this.detail,
    this.sourceModule,
    this.sourceEntityId,
    this.projectName,
    this.impactedServiceIdsJson,
    this.relayMessageId,
    this.actorName,
    this.projectId,
    this.sessionId,
    this.createdAt,
  });

  /// Deserializes an [ActivityFeedEntry] from a JSON map.
  factory ActivityFeedEntry.fromJson(Map<String, dynamic> json) =>
      _$ActivityFeedEntryFromJson(json);

  /// Serializes this [ActivityFeedEntry] to a JSON map.
  Map<String, dynamic> toJson() => _$ActivityFeedEntryToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tool Definitions
// ─────────────────────────────────────────────────────────────────────────────

/// MCP tool definition response for tool discovery.
@JsonSerializable()
class McpToolDefinition {
  /// Tool name (e.g., "registry.listServices").
  final String? name;

  /// Human-readable description of the tool.
  final String? description;

  /// Tool category (e.g., "registry", "fleet").
  final String? category;

  /// JSON schema describing the tool's input parameters.
  final String? inputSchema;

  /// Creates a [McpToolDefinition].
  const McpToolDefinition({
    this.name,
    this.description,
    this.category,
    this.inputSchema,
  });

  /// Deserializes a [McpToolDefinition] from a JSON map.
  factory McpToolDefinition.fromJson(Map<String, dynamic> json) =>
      _$McpToolDefinitionFromJson(json);

  /// Serializes this [McpToolDefinition] to a JSON map.
  Map<String, dynamic> toJson() => _$McpToolDefinitionToJson(this);
}
