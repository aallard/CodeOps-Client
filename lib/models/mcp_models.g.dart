// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpSession _$McpSessionFromJson(Map<String, dynamic> json) => McpSession(
      id: json['id'] as String?,
      status: _$JsonConverterFromJson<String, SessionStatus>(
          json['status'], const SessionStatusConverter().fromJson),
      projectName: json['projectName'] as String?,
      developerName: json['developerName'] as String?,
      environment: _$JsonConverterFromJson<String, McpEnvironment>(
          json['environment'], const McpEnvironmentConverter().fromJson),
      transport: _$JsonConverterFromJson<String, McpTransport>(
          json['transport'], const McpTransportConverter().fromJson),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      totalToolCalls: (json['totalToolCalls'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$McpSessionToJson(McpSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$JsonConverterToJson<String, SessionStatus>(
          instance.status, const SessionStatusConverter().toJson),
      'projectName': instance.projectName,
      'developerName': instance.developerName,
      'environment': _$JsonConverterToJson<String, McpEnvironment>(
          instance.environment, const McpEnvironmentConverter().toJson),
      'transport': _$JsonConverterToJson<String, McpTransport>(
          instance.transport, const McpTransportConverter().toJson),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'totalToolCalls': instance.totalToolCalls,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

McpSessionDetail _$McpSessionDetailFromJson(Map<String, dynamic> json) =>
    McpSessionDetail(
      id: json['id'] as String?,
      status: _$JsonConverterFromJson<String, SessionStatus>(
          json['status'], const SessionStatusConverter().fromJson),
      projectName: json['projectName'] as String?,
      developerName: json['developerName'] as String?,
      environment: _$JsonConverterFromJson<String, McpEnvironment>(
          json['environment'], const McpEnvironmentConverter().fromJson),
      transport: _$JsonConverterFromJson<String, McpTransport>(
          json['transport'], const McpTransportConverter().fromJson),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      timeoutMinutes: (json['timeoutMinutes'] as num?)?.toInt(),
      totalToolCalls: (json['totalToolCalls'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
      toolCalls: (json['toolCalls'] as List<dynamic>?)
          ?.map((e) => SessionToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: json['result'] == null
          ? null
          : SessionResult.fromJson(json['result'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$McpSessionDetailToJson(McpSessionDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$JsonConverterToJson<String, SessionStatus>(
          instance.status, const SessionStatusConverter().toJson),
      'projectName': instance.projectName,
      'developerName': instance.developerName,
      'environment': _$JsonConverterToJson<String, McpEnvironment>(
          instance.environment, const McpEnvironmentConverter().toJson),
      'transport': _$JsonConverterToJson<String, McpTransport>(
          instance.transport, const McpTransportConverter().toJson),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'timeoutMinutes': instance.timeoutMinutes,
      'totalToolCalls': instance.totalToolCalls,
      'errorMessage': instance.errorMessage,
      'toolCalls': instance.toolCalls?.map((e) => e.toJson()).toList(),
      'result': instance.result?.toJson(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SessionToolCall _$SessionToolCallFromJson(Map<String, dynamic> json) =>
    SessionToolCall(
      id: json['id'] as String?,
      toolName: json['toolName'] as String?,
      toolCategory: json['toolCategory'] as String?,
      requestJson: json['requestJson'] as String?,
      responseJson: json['responseJson'] as String?,
      status: _$JsonConverterFromJson<String, ToolCallStatus>(
          json['status'], const ToolCallStatusConverter().fromJson),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
      calledAt: json['calledAt'] == null
          ? null
          : DateTime.parse(json['calledAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SessionToolCallToJson(SessionToolCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'toolName': instance.toolName,
      'toolCategory': instance.toolCategory,
      'requestJson': instance.requestJson,
      'responseJson': instance.responseJson,
      'status': _$JsonConverterToJson<String, ToolCallStatus>(
          instance.status, const ToolCallStatusConverter().toJson),
      'durationMs': instance.durationMs,
      'errorMessage': instance.errorMessage,
      'calledAt': instance.calledAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

SessionResult _$SessionResultFromJson(Map<String, dynamic> json) =>
    SessionResult(
      id: json['id'] as String?,
      summary: json['summary'] as String?,
      commitHashesJson: json['commitHashesJson'] as String?,
      filesChangedJson: json['filesChangedJson'] as String?,
      endpointsChangedJson: json['endpointsChangedJson'] as String?,
      testsAdded: (json['testsAdded'] as num?)?.toInt(),
      testCoverage: (json['testCoverage'] as num?)?.toDouble(),
      linesAdded: (json['linesAdded'] as num?)?.toInt(),
      linesRemoved: (json['linesRemoved'] as num?)?.toInt(),
      dependencyChangesJson: json['dependencyChangesJson'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      tokenUsage: (json['tokenUsage'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SessionResultToJson(SessionResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'commitHashesJson': instance.commitHashesJson,
      'filesChangedJson': instance.filesChangedJson,
      'endpointsChangedJson': instance.endpointsChangedJson,
      'testsAdded': instance.testsAdded,
      'testCoverage': instance.testCoverage,
      'linesAdded': instance.linesAdded,
      'linesRemoved': instance.linesRemoved,
      'dependencyChangesJson': instance.dependencyChangesJson,
      'durationMinutes': instance.durationMinutes,
      'tokenUsage': instance.tokenUsage,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ToolCallSummary _$ToolCallSummaryFromJson(Map<String, dynamic> json) =>
    ToolCallSummary(
      toolName: json['toolName'] as String?,
      callCount: (json['callCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ToolCallSummaryToJson(ToolCallSummary instance) =>
    <String, dynamic>{
      'toolName': instance.toolName,
      'callCount': instance.callCount,
    };

DeveloperProfile _$DeveloperProfileFromJson(Map<String, dynamic> json) =>
    DeveloperProfile(
      id: json['id'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      defaultEnvironment: _$JsonConverterFromJson<String, McpEnvironment>(
          json['defaultEnvironment'], const McpEnvironmentConverter().fromJson),
      preferencesJson: json['preferencesJson'] as String?,
      timezone: json['timezone'] as String?,
      isActive: json['isActive'] as bool?,
      teamId: json['teamId'] as String?,
      userId: json['userId'] as String?,
      userDisplayName: json['userDisplayName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DeveloperProfileToJson(DeveloperProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'defaultEnvironment': _$JsonConverterToJson<String, McpEnvironment>(
          instance.defaultEnvironment, const McpEnvironmentConverter().toJson),
      'preferencesJson': instance.preferencesJson,
      'timezone': instance.timezone,
      'isActive': instance.isActive,
      'teamId': instance.teamId,
      'userId': instance.userId,
      'userDisplayName': instance.userDisplayName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

McpApiToken _$McpApiTokenFromJson(Map<String, dynamic> json) => McpApiToken(
      id: json['id'] as String?,
      name: json['name'] as String?,
      tokenPrefix: json['tokenPrefix'] as String?,
      status: _$JsonConverterFromJson<String, TokenStatus>(
          json['status'], const TokenStatusConverter().fromJson),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      scopesJson: json['scopesJson'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$McpApiTokenToJson(McpApiToken instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tokenPrefix': instance.tokenPrefix,
      'status': _$JsonConverterToJson<String, TokenStatus>(
          instance.status, const TokenStatusConverter().toJson),
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'scopesJson': instance.scopesJson,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

McpApiTokenCreated _$McpApiTokenCreatedFromJson(Map<String, dynamic> json) =>
    McpApiTokenCreated(
      id: json['id'] as String?,
      name: json['name'] as String?,
      tokenPrefix: json['tokenPrefix'] as String?,
      rawToken: json['rawToken'] as String?,
      status: _$JsonConverterFromJson<String, TokenStatus>(
          json['status'], const TokenStatusConverter().fromJson),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      scopesJson: json['scopesJson'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$McpApiTokenCreatedToJson(McpApiTokenCreated instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tokenPrefix': instance.tokenPrefix,
      'rawToken': instance.rawToken,
      'status': _$JsonConverterToJson<String, TokenStatus>(
          instance.status, const TokenStatusConverter().toJson),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'scopesJson': instance.scopesJson,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ProjectDocument _$ProjectDocumentFromJson(Map<String, dynamic> json) =>
    ProjectDocument(
      id: json['id'] as String?,
      documentType: _$JsonConverterFromJson<String, DocumentType>(
          json['documentType'], const DocumentTypeConverter().fromJson),
      customName: json['customName'] as String?,
      lastAuthorType: _$JsonConverterFromJson<String, AuthorType>(
          json['lastAuthorType'], const AuthorTypeConverter().fromJson),
      lastSessionId: json['lastSessionId'] as String?,
      isFlagged: json['isFlagged'] as bool?,
      flagReason: json['flagReason'] as String?,
      projectId: json['projectId'] as String?,
      lastUpdatedByName: json['lastUpdatedByName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProjectDocumentToJson(ProjectDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentType': _$JsonConverterToJson<String, DocumentType>(
          instance.documentType, const DocumentTypeConverter().toJson),
      'customName': instance.customName,
      'lastAuthorType': _$JsonConverterToJson<String, AuthorType>(
          instance.lastAuthorType, const AuthorTypeConverter().toJson),
      'lastSessionId': instance.lastSessionId,
      'isFlagged': instance.isFlagged,
      'flagReason': instance.flagReason,
      'projectId': instance.projectId,
      'lastUpdatedByName': instance.lastUpdatedByName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ProjectDocumentDetail _$ProjectDocumentDetailFromJson(
        Map<String, dynamic> json) =>
    ProjectDocumentDetail(
      id: json['id'] as String?,
      documentType: _$JsonConverterFromJson<String, DocumentType>(
          json['documentType'], const DocumentTypeConverter().fromJson),
      customName: json['customName'] as String?,
      currentContent: json['currentContent'] as String?,
      lastAuthorType: _$JsonConverterFromJson<String, AuthorType>(
          json['lastAuthorType'], const AuthorTypeConverter().fromJson),
      lastSessionId: json['lastSessionId'] as String?,
      isFlagged: json['isFlagged'] as bool?,
      flagReason: json['flagReason'] as String?,
      projectId: json['projectId'] as String?,
      lastUpdatedByName: json['lastUpdatedByName'] as String?,
      versions: (json['versions'] as List<dynamic>?)
          ?.map(
              (e) => ProjectDocumentVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProjectDocumentDetailToJson(
        ProjectDocumentDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentType': _$JsonConverterToJson<String, DocumentType>(
          instance.documentType, const DocumentTypeConverter().toJson),
      'customName': instance.customName,
      'currentContent': instance.currentContent,
      'lastAuthorType': _$JsonConverterToJson<String, AuthorType>(
          instance.lastAuthorType, const AuthorTypeConverter().toJson),
      'lastSessionId': instance.lastSessionId,
      'isFlagged': instance.isFlagged,
      'flagReason': instance.flagReason,
      'projectId': instance.projectId,
      'lastUpdatedByName': instance.lastUpdatedByName,
      'versions': instance.versions?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ProjectDocumentVersion _$ProjectDocumentVersionFromJson(
        Map<String, dynamic> json) =>
    ProjectDocumentVersion(
      id: json['id'] as String?,
      versionNumber: (json['versionNumber'] as num?)?.toInt(),
      content: json['content'] as String?,
      authorType: _$JsonConverterFromJson<String, AuthorType>(
          json['authorType'], const AuthorTypeConverter().fromJson),
      commitHash: json['commitHash'] as String?,
      changeDescription: json['changeDescription'] as String?,
      authorName: json['authorName'] as String?,
      sessionId: json['sessionId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProjectDocumentVersionToJson(
        ProjectDocumentVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'versionNumber': instance.versionNumber,
      'content': instance.content,
      'authorType': _$JsonConverterToJson<String, AuthorType>(
          instance.authorType, const AuthorTypeConverter().toJson),
      'commitHash': instance.commitHash,
      'changeDescription': instance.changeDescription,
      'authorName': instance.authorName,
      'sessionId': instance.sessionId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ActivityFeedEntry _$ActivityFeedEntryFromJson(Map<String, dynamic> json) =>
    ActivityFeedEntry(
      id: json['id'] as String?,
      activityType: _$JsonConverterFromJson<String, ActivityType>(
          json['activityType'], const ActivityTypeConverter().fromJson),
      title: json['title'] as String?,
      detail: json['detail'] as String?,
      sourceModule: json['sourceModule'] as String?,
      sourceEntityId: json['sourceEntityId'] as String?,
      projectName: json['projectName'] as String?,
      impactedServiceIdsJson: json['impactedServiceIdsJson'] as String?,
      relayMessageId: json['relayMessageId'] as String?,
      actorName: json['actorName'] as String?,
      projectId: json['projectId'] as String?,
      sessionId: json['sessionId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ActivityFeedEntryToJson(ActivityFeedEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityType': _$JsonConverterToJson<String, ActivityType>(
          instance.activityType, const ActivityTypeConverter().toJson),
      'title': instance.title,
      'detail': instance.detail,
      'sourceModule': instance.sourceModule,
      'sourceEntityId': instance.sourceEntityId,
      'projectName': instance.projectName,
      'impactedServiceIdsJson': instance.impactedServiceIdsJson,
      'relayMessageId': instance.relayMessageId,
      'actorName': instance.actorName,
      'projectId': instance.projectId,
      'sessionId': instance.sessionId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

McpToolDefinition _$McpToolDefinitionFromJson(Map<String, dynamic> json) =>
    McpToolDefinition(
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      inputSchema: json['inputSchema'] as String?,
    );

Map<String, dynamic> _$McpToolDefinitionToJson(McpToolDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'inputSchema': instance.inputSchema,
    };
