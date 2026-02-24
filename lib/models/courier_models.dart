/// Model classes for the CodeOps-Courier module.
///
/// Maps to response and request DTOs defined in the Courier controllers.
/// All classes use [JsonSerializable] with generated `fromJson` / `toJson`
/// methods via build_runner.
///
/// Organized by domain:
/// - Collections (4 classes)
/// - Folders (3 classes)
/// - Requests (11 classes)
/// - Environments & Variables (8 classes)
/// - Sharing (3 classes)
/// - Forking (2 classes)
/// - Proxy (1 class)
/// - GraphQL (3 classes)
/// - Runner (4 classes)
/// - History (2 classes)
/// - Import/Export (3 classes)
/// - Code Generation (2 classes)
/// - Request DTOs (17 classes)
library;

import 'package:json_annotation/json_annotation.dart';

import 'courier_enums.dart';

part 'courier_models.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Collections
// ─────────────────────────────────────────────────────────────────────────────

/// Full collection response with metadata and counts.
@JsonSerializable()
class CollectionResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the owning team.
  final String? teamId;

  /// Collection name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Pre-request script applied to all requests.
  final String? preRequestScript;

  /// Post-response script applied to all requests.
  final String? postResponseScript;

  /// Collection-level authentication type.
  @AuthTypeConverter()
  final AuthType? authType;

  /// JSON-encoded authentication configuration.
  final String? authConfig;

  /// Whether the collection is shared.
  final bool? isShared;

  /// UUID of the user who created the collection.
  final String? createdBy;

  /// Number of folders in the collection.
  final int? folderCount;

  /// Number of requests in the collection.
  final int? requestCount;

  /// Timestamp when the collection was created.
  final DateTime? createdAt;

  /// Timestamp when the collection was last updated.
  final DateTime? updatedAt;

  /// Creates a [CollectionResponse] instance.
  const CollectionResponse({
    this.id,
    this.teamId,
    this.name,
    this.description,
    this.preRequestScript,
    this.postResponseScript,
    this.authType,
    this.authConfig,
    this.isShared,
    this.createdBy,
    this.folderCount,
    this.requestCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [CollectionResponse] from a JSON map.
  factory CollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionResponseFromJson(json);

  /// Serializes this [CollectionResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$CollectionResponseToJson(this);
}

/// Summary collection response for list views.
@JsonSerializable()
class CollectionSummaryResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Collection name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether the collection is shared.
  final bool? isShared;

  /// Number of folders.
  final int? folderCount;

  /// Number of requests.
  final int? requestCount;

  /// Timestamp when last updated.
  final DateTime? updatedAt;

  /// Creates a [CollectionSummaryResponse] instance.
  const CollectionSummaryResponse({
    this.id,
    this.name,
    this.description,
    this.isShared,
    this.folderCount,
    this.requestCount,
    this.updatedAt,
  });

  /// Deserializes a [CollectionSummaryResponse] from a JSON map.
  factory CollectionSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionSummaryResponseFromJson(json);

  /// Serializes this [CollectionSummaryResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$CollectionSummaryResponseToJson(this);
}

/// Request body for creating a collection.
@JsonSerializable()
class CreateCollectionRequest {
  /// Collection name (max 200 chars).
  final String name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// Collection-level authentication type.
  @AuthTypeConverter()
  final AuthType? authType;

  /// JSON-encoded authentication configuration.
  final String? authConfig;

  /// Creates a [CreateCollectionRequest] instance.
  const CreateCollectionRequest({
    required this.name,
    this.description,
    this.authType,
    this.authConfig,
  });

  /// Deserializes a [CreateCollectionRequest] from a JSON map.
  factory CreateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCollectionRequestFromJson(json);

  /// Serializes this [CreateCollectionRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateCollectionRequestToJson(this);
}

/// Request body for updating a collection.
@JsonSerializable()
class UpdateCollectionRequest {
  /// Collection name (max 200 chars).
  final String? name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// Pre-request script.
  final String? preRequestScript;

  /// Post-response script.
  final String? postResponseScript;

  /// Collection-level authentication type.
  @AuthTypeConverter()
  final AuthType? authType;

  /// JSON-encoded authentication configuration.
  final String? authConfig;

  /// Creates an [UpdateCollectionRequest] instance.
  const UpdateCollectionRequest({
    this.name,
    this.description,
    this.preRequestScript,
    this.postResponseScript,
    this.authType,
    this.authConfig,
  });

  /// Deserializes an [UpdateCollectionRequest] from a JSON map.
  factory UpdateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCollectionRequestFromJson(json);

  /// Serializes this [UpdateCollectionRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$UpdateCollectionRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Folders
// ─────────────────────────────────────────────────────────────────────────────

/// Full folder response with metadata and counts.
@JsonSerializable()
class FolderResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the parent collection.
  final String? collectionId;

  /// UUID of the parent folder (null for root folders).
  final String? parentFolderId;

  /// Folder name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Display sort order.
  final int? sortOrder;

  /// Pre-request script inherited by child requests.
  final String? preRequestScript;

  /// Post-response script inherited by child requests.
  final String? postResponseScript;

  /// Folder-level authentication type.
  @AuthTypeConverter()
  final AuthType? authType;

  /// JSON-encoded authentication configuration.
  final String? authConfig;

  /// Number of direct subfolders.
  final int? subFolderCount;

  /// Number of direct requests.
  final int? requestCount;

  /// Timestamp when the folder was created.
  final DateTime? createdAt;

  /// Timestamp when the folder was last updated.
  final DateTime? updatedAt;

  /// Creates a [FolderResponse] instance.
  const FolderResponse({
    this.id,
    this.collectionId,
    this.parentFolderId,
    this.name,
    this.description,
    this.sortOrder,
    this.preRequestScript,
    this.postResponseScript,
    this.authType,
    this.authConfig,
    this.subFolderCount,
    this.requestCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [FolderResponse] from a JSON map.
  factory FolderResponse.fromJson(Map<String, dynamic> json) =>
      _$FolderResponseFromJson(json);

  /// Serializes this [FolderResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$FolderResponseToJson(this);
}

/// Recursive folder tree node for collection tree view.
@JsonSerializable(explicitToJson: true)
class FolderTreeResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Folder name.
  final String? name;

  /// Display sort order.
  final int? sortOrder;

  /// Nested subfolders.
  final List<FolderTreeResponse>? subFolders;

  /// Requests within this folder.
  final List<RequestSummaryResponse>? requests;

  /// Creates a [FolderTreeResponse] instance.
  const FolderTreeResponse({
    this.id,
    this.name,
    this.sortOrder,
    this.subFolders,
    this.requests,
  });

  /// Deserializes a [FolderTreeResponse] from a JSON map.
  factory FolderTreeResponse.fromJson(Map<String, dynamic> json) =>
      _$FolderTreeResponseFromJson(json);

  /// Serializes this [FolderTreeResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$FolderTreeResponseToJson(this);
}

/// Request body for creating a folder.
@JsonSerializable()
class CreateFolderRequest {
  /// UUID of the parent collection.
  final String collectionId;

  /// UUID of the parent folder (null for root folders).
  final String? parentFolderId;

  /// Folder name (max 200 chars).
  final String name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// Display sort order.
  final int? sortOrder;

  /// Creates a [CreateFolderRequest] instance.
  const CreateFolderRequest({
    required this.collectionId,
    this.parentFolderId,
    required this.name,
    this.description,
    this.sortOrder,
  });

  /// Deserializes a [CreateFolderRequest] from a JSON map.
  factory CreateFolderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateFolderRequestFromJson(json);

  /// Serializes this [CreateFolderRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateFolderRequestToJson(this);
}

/// Request body for updating a folder.
@JsonSerializable()
class UpdateFolderRequest {
  /// Folder name (max 200 chars).
  final String? name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// Display sort order.
  final int? sortOrder;

  /// UUID of the parent folder.
  final String? parentFolderId;

  /// Pre-request script.
  final String? preRequestScript;

  /// Post-response script.
  final String? postResponseScript;

  /// Folder-level authentication type.
  @AuthTypeConverter()
  final AuthType? authType;

  /// JSON-encoded authentication configuration.
  final String? authConfig;

  /// Creates an [UpdateFolderRequest] instance.
  const UpdateFolderRequest({
    this.name,
    this.description,
    this.sortOrder,
    this.parentFolderId,
    this.preRequestScript,
    this.postResponseScript,
    this.authType,
    this.authConfig,
  });

  /// Deserializes an [UpdateFolderRequest] from a JSON map.
  factory UpdateFolderRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFolderRequestFromJson(json);

  /// Serializes this [UpdateFolderRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$UpdateFolderRequestToJson(this);
}

/// Request body for reordering folders.
@JsonSerializable()
class ReorderFolderRequest {
  /// Ordered list of folder UUIDs.
  final List<String> folderIds;

  /// Creates a [ReorderFolderRequest] instance.
  const ReorderFolderRequest({required this.folderIds});

  /// Deserializes a [ReorderFolderRequest] from a JSON map.
  factory ReorderFolderRequest.fromJson(Map<String, dynamic> json) =>
      _$ReorderFolderRequestFromJson(json);

  /// Serializes this [ReorderFolderRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$ReorderFolderRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Requests
// ─────────────────────────────────────────────────────────────────────────────

/// Full request response including all components.
@JsonSerializable(explicitToJson: true)
class RequestResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the parent folder.
  final String? folderId;

  /// Request name.
  final String? name;

  /// Optional description.
  final String? description;

  /// HTTP method.
  @CourierHttpMethodConverter()
  final CourierHttpMethod? method;

  /// Request URL.
  final String? url;

  /// Display sort order.
  final int? sortOrder;

  /// HTTP headers.
  final List<RequestHeaderResponse>? headers;

  /// Query parameters.
  final List<RequestParamResponse>? params;

  /// Request body configuration.
  final RequestBodyResponse? body;

  /// Authentication configuration.
  final RequestAuthResponse? auth;

  /// Pre/post scripts.
  final List<RequestScriptResponse>? scripts;

  /// Timestamp when the request was created.
  final DateTime? createdAt;

  /// Timestamp when the request was last updated.
  final DateTime? updatedAt;

  /// Creates a [RequestResponse] instance.
  const RequestResponse({
    this.id,
    this.folderId,
    this.name,
    this.description,
    this.method,
    this.url,
    this.sortOrder,
    this.headers,
    this.params,
    this.body,
    this.auth,
    this.scripts,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [RequestResponse] from a JSON map.
  factory RequestResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestResponseFromJson(json);

  /// Serializes this [RequestResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestResponseToJson(this);
}

/// Summary request response for list views.
@JsonSerializable()
class RequestSummaryResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Request name.
  final String? name;

  /// HTTP method.
  @CourierHttpMethodConverter()
  final CourierHttpMethod? method;

  /// Request URL.
  final String? url;

  /// Display sort order.
  final int? sortOrder;

  /// Creates a [RequestSummaryResponse] instance.
  const RequestSummaryResponse({
    this.id,
    this.name,
    this.method,
    this.url,
    this.sortOrder,
  });

  /// Deserializes a [RequestSummaryResponse] from a JSON map.
  factory RequestSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestSummaryResponseFromJson(json);

  /// Serializes this [RequestSummaryResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestSummaryResponseToJson(this);
}

/// HTTP header attached to a request.
@JsonSerializable()
class RequestHeaderResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Header name.
  final String? headerKey;

  /// Header value.
  final String? headerValue;

  /// Optional description.
  final String? description;

  /// Whether the header is enabled.
  final bool? isEnabled;

  /// Creates a [RequestHeaderResponse] instance.
  const RequestHeaderResponse({
    this.id,
    this.headerKey,
    this.headerValue,
    this.description,
    this.isEnabled,
  });

  /// Deserializes a [RequestHeaderResponse] from a JSON map.
  factory RequestHeaderResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestHeaderResponseFromJson(json);

  /// Serializes this [RequestHeaderResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestHeaderResponseToJson(this);
}

/// Query parameter attached to a request.
@JsonSerializable()
class RequestParamResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Parameter name.
  final String? paramKey;

  /// Parameter value.
  final String? paramValue;

  /// Optional description.
  final String? description;

  /// Whether the parameter is enabled.
  final bool? isEnabled;

  /// Creates a [RequestParamResponse] instance.
  const RequestParamResponse({
    this.id,
    this.paramKey,
    this.paramValue,
    this.description,
    this.isEnabled,
  });

  /// Deserializes a [RequestParamResponse] from a JSON map.
  factory RequestParamResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestParamResponseFromJson(json);

  /// Serializes this [RequestParamResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestParamResponseToJson(this);
}

/// Request body configuration.
@JsonSerializable()
class RequestBodyResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Body content type.
  @BodyTypeConverter()
  final BodyType? bodyType;

  /// Raw body content.
  final String? rawContent;

  /// Form data as JSON string.
  final String? formData;

  /// GraphQL query string.
  final String? graphqlQuery;

  /// GraphQL variables as JSON string.
  final String? graphqlVariables;

  /// Binary file name.
  final String? binaryFileName;

  /// Creates a [RequestBodyResponse] instance.
  const RequestBodyResponse({
    this.id,
    this.bodyType,
    this.rawContent,
    this.formData,
    this.graphqlQuery,
    this.graphqlVariables,
    this.binaryFileName,
  });

  /// Deserializes a [RequestBodyResponse] from a JSON map.
  factory RequestBodyResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestBodyResponseFromJson(json);

  /// Serializes this [RequestBodyResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestBodyResponseToJson(this);
}

/// Request authentication configuration.
@JsonSerializable()
class RequestAuthResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Authentication type.
  @AuthTypeConverter()
  final AuthType? authType;

  /// API key header name.
  final String? apiKeyHeader;

  /// API key value.
  final String? apiKeyValue;

  /// Where to add the API key (header, query, etc.).
  final String? apiKeyAddTo;

  /// Bearer token.
  final String? bearerToken;

  /// Basic auth username.
  final String? basicUsername;

  /// Basic auth password.
  final String? basicPassword;

  /// OAuth2 grant type.
  final String? oauth2GrantType;

  /// OAuth2 authorization URL.
  final String? oauth2AuthUrl;

  /// OAuth2 token URL.
  final String? oauth2TokenUrl;

  /// OAuth2 client ID.
  final String? oauth2ClientId;

  /// OAuth2 client secret.
  final String? oauth2ClientSecret;

  /// OAuth2 scope.
  final String? oauth2Scope;

  /// OAuth2 callback URL.
  final String? oauth2CallbackUrl;

  /// OAuth2 access token.
  final String? oauth2AccessToken;

  /// JWT secret key.
  final String? jwtSecret;

  /// JWT payload as JSON string.
  final String? jwtPayload;

  /// JWT signing algorithm.
  final String? jwtAlgorithm;

  /// Creates a [RequestAuthResponse] instance.
  const RequestAuthResponse({
    this.id,
    this.authType,
    this.apiKeyHeader,
    this.apiKeyValue,
    this.apiKeyAddTo,
    this.bearerToken,
    this.basicUsername,
    this.basicPassword,
    this.oauth2GrantType,
    this.oauth2AuthUrl,
    this.oauth2TokenUrl,
    this.oauth2ClientId,
    this.oauth2ClientSecret,
    this.oauth2Scope,
    this.oauth2CallbackUrl,
    this.oauth2AccessToken,
    this.jwtSecret,
    this.jwtPayload,
    this.jwtAlgorithm,
  });

  /// Deserializes a [RequestAuthResponse] from a JSON map.
  factory RequestAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestAuthResponseFromJson(json);

  /// Serializes this [RequestAuthResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestAuthResponseToJson(this);
}

/// Pre-request or post-response script.
@JsonSerializable()
class RequestScriptResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Script execution timing.
  @ScriptTypeConverter()
  final ScriptType? scriptType;

  /// Script content.
  final String? content;

  /// Creates a [RequestScriptResponse] instance.
  const RequestScriptResponse({
    this.id,
    this.scriptType,
    this.content,
  });

  /// Deserializes a [RequestScriptResponse] from a JSON map.
  factory RequestScriptResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestScriptResponseFromJson(json);

  /// Serializes this [RequestScriptResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestScriptResponseToJson(this);
}

/// Request body for creating an API request.
@JsonSerializable()
class CreateRequestRequest {
  /// UUID of the parent folder.
  final String folderId;

  /// Request name (max 200 chars).
  final String name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// HTTP method.
  @CourierHttpMethodConverter()
  final CourierHttpMethod method;

  /// Request URL (max 2000 chars).
  final String url;

  /// Display sort order.
  final int? sortOrder;

  /// Creates a [CreateRequestRequest] instance.
  const CreateRequestRequest({
    required this.folderId,
    required this.name,
    this.description,
    required this.method,
    required this.url,
    this.sortOrder,
  });

  /// Deserializes a [CreateRequestRequest] from a JSON map.
  factory CreateRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRequestRequestFromJson(json);

  /// Serializes this [CreateRequestRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateRequestRequestToJson(this);
}

/// Request body for updating an API request.
@JsonSerializable()
class UpdateRequestRequest {
  /// Request name (max 200 chars).
  final String? name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// HTTP method.
  @CourierHttpMethodConverter()
  final CourierHttpMethod? method;

  /// Request URL (max 2000 chars).
  final String? url;

  /// Display sort order.
  final int? sortOrder;

  /// Creates an [UpdateRequestRequest] instance.
  const UpdateRequestRequest({
    this.name,
    this.description,
    this.method,
    this.url,
    this.sortOrder,
  });

  /// Deserializes an [UpdateRequestRequest] from a JSON map.
  factory UpdateRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRequestRequestFromJson(json);

  /// Serializes this [UpdateRequestRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$UpdateRequestRequestToJson(this);
}

/// Request body for saving request headers.
@JsonSerializable(explicitToJson: true)
class SaveRequestHeadersRequest {
  /// HTTP headers.
  final List<RequestHeaderEntry> headers;

  /// Creates a [SaveRequestHeadersRequest] instance.
  const SaveRequestHeadersRequest({required this.headers});

  /// Deserializes a [SaveRequestHeadersRequest] from a JSON map.
  factory SaveRequestHeadersRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveRequestHeadersRequestFromJson(json);

  /// Serializes this [SaveRequestHeadersRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SaveRequestHeadersRequestToJson(this);
}

/// A single header entry for save operations.
@JsonSerializable()
class RequestHeaderEntry {
  /// Header name (max 500 chars).
  final String headerKey;

  /// Header value (max 5000 chars).
  final String? headerValue;

  /// Optional description (max 500 chars).
  final String? description;

  /// Whether the header is enabled.
  final bool? isEnabled;

  /// Creates a [RequestHeaderEntry] instance.
  const RequestHeaderEntry({
    required this.headerKey,
    this.headerValue,
    this.description,
    this.isEnabled,
  });

  /// Deserializes a [RequestHeaderEntry] from a JSON map.
  factory RequestHeaderEntry.fromJson(Map<String, dynamic> json) =>
      _$RequestHeaderEntryFromJson(json);

  /// Serializes this [RequestHeaderEntry] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestHeaderEntryToJson(this);
}

/// Request body for saving request parameters.
@JsonSerializable(explicitToJson: true)
class SaveRequestParamsRequest {
  /// Query parameters.
  final List<RequestParamEntry> params;

  /// Creates a [SaveRequestParamsRequest] instance.
  const SaveRequestParamsRequest({required this.params});

  /// Deserializes a [SaveRequestParamsRequest] from a JSON map.
  factory SaveRequestParamsRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveRequestParamsRequestFromJson(json);

  /// Serializes this [SaveRequestParamsRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SaveRequestParamsRequestToJson(this);
}

/// A single parameter entry for save operations.
@JsonSerializable()
class RequestParamEntry {
  /// Parameter name (max 500 chars).
  final String paramKey;

  /// Parameter value (max 5000 chars).
  final String? paramValue;

  /// Optional description (max 500 chars).
  final String? description;

  /// Whether the parameter is enabled.
  final bool? isEnabled;

  /// Creates a [RequestParamEntry] instance.
  const RequestParamEntry({
    required this.paramKey,
    this.paramValue,
    this.description,
    this.isEnabled,
  });

  /// Deserializes a [RequestParamEntry] from a JSON map.
  factory RequestParamEntry.fromJson(Map<String, dynamic> json) =>
      _$RequestParamEntryFromJson(json);

  /// Serializes this [RequestParamEntry] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestParamEntryToJson(this);
}

/// Request body for saving a request body configuration.
@JsonSerializable()
class SaveRequestBodyRequest {
  /// Body content type.
  @BodyTypeConverter()
  final BodyType bodyType;

  /// Raw body content.
  final String? rawContent;

  /// Form data as JSON string.
  final String? formData;

  /// GraphQL query string.
  final String? graphqlQuery;

  /// GraphQL variables as JSON string.
  final String? graphqlVariables;

  /// Binary file name.
  final String? binaryFileName;

  /// Creates a [SaveRequestBodyRequest] instance.
  const SaveRequestBodyRequest({
    required this.bodyType,
    this.rawContent,
    this.formData,
    this.graphqlQuery,
    this.graphqlVariables,
    this.binaryFileName,
  });

  /// Deserializes a [SaveRequestBodyRequest] from a JSON map.
  factory SaveRequestBodyRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveRequestBodyRequestFromJson(json);

  /// Serializes this [SaveRequestBodyRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SaveRequestBodyRequestToJson(this);
}

/// Request body for saving request authentication.
@JsonSerializable()
class SaveRequestAuthRequest {
  /// Authentication type.
  @AuthTypeConverter()
  final AuthType authType;

  /// API key header name.
  final String? apiKeyHeader;

  /// API key value.
  final String? apiKeyValue;

  /// Where to add the API key.
  final String? apiKeyAddTo;

  /// Bearer token.
  final String? bearerToken;

  /// Basic auth username.
  final String? basicUsername;

  /// Basic auth password.
  final String? basicPassword;

  /// OAuth2 grant type.
  final String? oauth2GrantType;

  /// OAuth2 authorization URL.
  final String? oauth2AuthUrl;

  /// OAuth2 token URL.
  final String? oauth2TokenUrl;

  /// OAuth2 client ID.
  final String? oauth2ClientId;

  /// OAuth2 client secret.
  final String? oauth2ClientSecret;

  /// OAuth2 scope.
  final String? oauth2Scope;

  /// OAuth2 callback URL.
  final String? oauth2CallbackUrl;

  /// OAuth2 access token.
  final String? oauth2AccessToken;

  /// JWT secret key.
  final String? jwtSecret;

  /// JWT payload as JSON string.
  final String? jwtPayload;

  /// JWT signing algorithm.
  final String? jwtAlgorithm;

  /// Creates a [SaveRequestAuthRequest] instance.
  const SaveRequestAuthRequest({
    required this.authType,
    this.apiKeyHeader,
    this.apiKeyValue,
    this.apiKeyAddTo,
    this.bearerToken,
    this.basicUsername,
    this.basicPassword,
    this.oauth2GrantType,
    this.oauth2AuthUrl,
    this.oauth2TokenUrl,
    this.oauth2ClientId,
    this.oauth2ClientSecret,
    this.oauth2Scope,
    this.oauth2CallbackUrl,
    this.oauth2AccessToken,
    this.jwtSecret,
    this.jwtPayload,
    this.jwtAlgorithm,
  });

  /// Deserializes a [SaveRequestAuthRequest] from a JSON map.
  factory SaveRequestAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveRequestAuthRequestFromJson(json);

  /// Serializes this [SaveRequestAuthRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SaveRequestAuthRequestToJson(this);
}

/// Request body for saving a pre/post script.
@JsonSerializable()
class SaveRequestScriptRequest {
  /// Script execution timing.
  @ScriptTypeConverter()
  final ScriptType scriptType;

  /// Script content.
  final String? content;

  /// Creates a [SaveRequestScriptRequest] instance.
  const SaveRequestScriptRequest({
    required this.scriptType,
    this.content,
  });

  /// Deserializes a [SaveRequestScriptRequest] from a JSON map.
  factory SaveRequestScriptRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveRequestScriptRequestFromJson(json);

  /// Serializes this [SaveRequestScriptRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SaveRequestScriptRequestToJson(this);
}

/// Request body for reordering requests.
@JsonSerializable()
class ReorderRequestRequest {
  /// Ordered list of request UUIDs.
  final List<String> requestIds;

  /// Creates a [ReorderRequestRequest] instance.
  const ReorderRequestRequest({required this.requestIds});

  /// Deserializes a [ReorderRequestRequest] from a JSON map.
  factory ReorderRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$ReorderRequestRequestFromJson(json);

  /// Serializes this [ReorderRequestRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$ReorderRequestRequestToJson(this);
}

/// Request body for duplicating a request.
@JsonSerializable()
class DuplicateRequestRequest {
  /// Target folder UUID for the duplicate.
  final String? targetFolderId;

  /// Creates a [DuplicateRequestRequest] instance.
  const DuplicateRequestRequest({this.targetFolderId});

  /// Deserializes a [DuplicateRequestRequest] from a JSON map.
  factory DuplicateRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$DuplicateRequestRequestFromJson(json);

  /// Serializes this [DuplicateRequestRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$DuplicateRequestRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Environments & Variables
// ─────────────────────────────────────────────────────────────────────────────

/// Environment response with metadata.
@JsonSerializable()
class EnvironmentResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the owning team.
  final String? teamId;

  /// Environment name.
  final String? name;

  /// Optional description.
  final String? description;

  /// Whether this is the active environment.
  final bool? isActive;

  /// UUID of the user who created the environment.
  final String? createdBy;

  /// Number of variables in the environment.
  final int? variableCount;

  /// Timestamp when the environment was created.
  final DateTime? createdAt;

  /// Timestamp when the environment was last updated.
  final DateTime? updatedAt;

  /// Creates an [EnvironmentResponse] instance.
  const EnvironmentResponse({
    this.id,
    this.teamId,
    this.name,
    this.description,
    this.isActive,
    this.createdBy,
    this.variableCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes an [EnvironmentResponse] from a JSON map.
  factory EnvironmentResponse.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentResponseFromJson(json);

  /// Serializes this [EnvironmentResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$EnvironmentResponseToJson(this);
}

/// Environment variable response.
@JsonSerializable()
class EnvironmentVariableResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Variable name.
  final String? variableKey;

  /// Variable value (masked if secret).
  final String? variableValue;

  /// Whether the variable value is secret.
  final bool? isSecret;

  /// Whether the variable is enabled.
  final bool? isEnabled;

  /// Variable scope (e.g., environment, collection).
  final String? scope;

  /// Creates an [EnvironmentVariableResponse] instance.
  const EnvironmentVariableResponse({
    this.id,
    this.variableKey,
    this.variableValue,
    this.isSecret,
    this.isEnabled,
    this.scope,
  });

  /// Deserializes an [EnvironmentVariableResponse] from a JSON map.
  factory EnvironmentVariableResponse.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentVariableResponseFromJson(json);

  /// Serializes this [EnvironmentVariableResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$EnvironmentVariableResponseToJson(this);
}

/// Global variable response.
@JsonSerializable()
class GlobalVariableResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the owning team.
  final String? teamId;

  /// Variable name.
  final String? variableKey;

  /// Variable value (masked if secret).
  final String? variableValue;

  /// Whether the variable value is secret.
  final bool? isSecret;

  /// Whether the variable is enabled.
  final bool? isEnabled;

  /// Timestamp when the variable was created.
  final DateTime? createdAt;

  /// Timestamp when the variable was last updated.
  final DateTime? updatedAt;

  /// Creates a [GlobalVariableResponse] instance.
  const GlobalVariableResponse({
    this.id,
    this.teamId,
    this.variableKey,
    this.variableValue,
    this.isSecret,
    this.isEnabled,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserializes a [GlobalVariableResponse] from a JSON map.
  factory GlobalVariableResponse.fromJson(Map<String, dynamic> json) =>
      _$GlobalVariableResponseFromJson(json);

  /// Serializes this [GlobalVariableResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$GlobalVariableResponseToJson(this);
}

/// Request body for creating an environment.
@JsonSerializable()
class CreateEnvironmentRequest {
  /// Environment name (max 200 chars).
  final String name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// Creates a [CreateEnvironmentRequest] instance.
  const CreateEnvironmentRequest({required this.name, this.description});

  /// Deserializes a [CreateEnvironmentRequest] from a JSON map.
  factory CreateEnvironmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEnvironmentRequestFromJson(json);

  /// Serializes this [CreateEnvironmentRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateEnvironmentRequestToJson(this);
}

/// Request body for updating an environment.
@JsonSerializable()
class UpdateEnvironmentRequest {
  /// Environment name (max 200 chars).
  final String? name;

  /// Optional description (max 2000 chars).
  final String? description;

  /// Creates an [UpdateEnvironmentRequest] instance.
  const UpdateEnvironmentRequest({this.name, this.description});

  /// Deserializes an [UpdateEnvironmentRequest] from a JSON map.
  factory UpdateEnvironmentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateEnvironmentRequestFromJson(json);

  /// Serializes this [UpdateEnvironmentRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$UpdateEnvironmentRequestToJson(this);
}

/// Request body for saving environment variables.
@JsonSerializable(explicitToJson: true)
class SaveEnvironmentVariablesRequest {
  /// Variable entries to save.
  final List<VariableEntry> variables;

  /// Creates a [SaveEnvironmentVariablesRequest] instance.
  const SaveEnvironmentVariablesRequest({required this.variables});

  /// Deserializes a [SaveEnvironmentVariablesRequest] from a JSON map.
  factory SaveEnvironmentVariablesRequest.fromJson(
          Map<String, dynamic> json) =>
      _$SaveEnvironmentVariablesRequestFromJson(json);

  /// Serializes this [SaveEnvironmentVariablesRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$SaveEnvironmentVariablesRequestToJson(this);
}

/// A single variable entry for save operations.
@JsonSerializable()
class VariableEntry {
  /// Variable name (max 500 chars).
  final String variableKey;

  /// Variable value (max 5000 chars).
  final String? variableValue;

  /// Whether the variable is secret.
  final bool? isSecret;

  /// Whether the variable is enabled.
  final bool? isEnabled;

  /// Creates a [VariableEntry] instance.
  const VariableEntry({
    required this.variableKey,
    this.variableValue,
    this.isSecret,
    this.isEnabled,
  });

  /// Deserializes a [VariableEntry] from a JSON map.
  factory VariableEntry.fromJson(Map<String, dynamic> json) =>
      _$VariableEntryFromJson(json);

  /// Serializes this [VariableEntry] to a JSON map.
  Map<String, dynamic> toJson() => _$VariableEntryToJson(this);
}

/// Request body for cloning an environment.
@JsonSerializable()
class CloneEnvironmentRequest {
  /// Name for the cloned environment (max 200 chars).
  final String newName;

  /// Creates a [CloneEnvironmentRequest] instance.
  const CloneEnvironmentRequest({required this.newName});

  /// Deserializes a [CloneEnvironmentRequest] from a JSON map.
  factory CloneEnvironmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CloneEnvironmentRequestFromJson(json);

  /// Serializes this [CloneEnvironmentRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CloneEnvironmentRequestToJson(this);
}

/// Request body for saving a global variable.
@JsonSerializable()
class SaveGlobalVariableRequest {
  /// Variable name (max 500 chars).
  final String variableKey;

  /// Variable value (max 5000 chars).
  final String? variableValue;

  /// Whether the variable is secret.
  final bool? isSecret;

  /// Whether the variable is enabled.
  final bool? isEnabled;

  /// Creates a [SaveGlobalVariableRequest] instance.
  const SaveGlobalVariableRequest({
    required this.variableKey,
    this.variableValue,
    this.isSecret,
    this.isEnabled,
  });

  /// Deserializes a [SaveGlobalVariableRequest] from a JSON map.
  factory SaveGlobalVariableRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveGlobalVariableRequestFromJson(json);

  /// Serializes this [SaveGlobalVariableRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SaveGlobalVariableRequestToJson(this);
}

/// Request body for batch-saving global variables.
@JsonSerializable(explicitToJson: true)
class BatchSaveGlobalVariablesRequest {
  /// Variable entries to save.
  final List<SaveGlobalVariableRequest> variables;

  /// Creates a [BatchSaveGlobalVariablesRequest] instance.
  const BatchSaveGlobalVariablesRequest({required this.variables});

  /// Deserializes a [BatchSaveGlobalVariablesRequest] from a JSON map.
  factory BatchSaveGlobalVariablesRequest.fromJson(
          Map<String, dynamic> json) =>
      _$BatchSaveGlobalVariablesRequestFromJson(json);

  /// Serializes this [BatchSaveGlobalVariablesRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$BatchSaveGlobalVariablesRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sharing
// ─────────────────────────────────────────────────────────────────────────────

/// Collection share response.
@JsonSerializable()
class CollectionShareResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the shared collection.
  final String? collectionId;

  /// UUID of the user the collection is shared with.
  final String? sharedWithUserId;

  /// UUID of the user who shared the collection.
  final String? sharedByUserId;

  /// Permission level.
  @SharePermissionConverter()
  final SharePermission? permission;

  /// Timestamp when the share was created.
  final DateTime? createdAt;

  /// Creates a [CollectionShareResponse] instance.
  const CollectionShareResponse({
    this.id,
    this.collectionId,
    this.sharedWithUserId,
    this.sharedByUserId,
    this.permission,
    this.createdAt,
  });

  /// Deserializes a [CollectionShareResponse] from a JSON map.
  factory CollectionShareResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionShareResponseFromJson(json);

  /// Serializes this [CollectionShareResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$CollectionShareResponseToJson(this);
}

/// Request body for sharing a collection.
@JsonSerializable()
class ShareCollectionRequest {
  /// UUID of the user to share with.
  final String sharedWithUserId;

  /// Permission level.
  @SharePermissionConverter()
  final SharePermission permission;

  /// Creates a [ShareCollectionRequest] instance.
  const ShareCollectionRequest({
    required this.sharedWithUserId,
    required this.permission,
  });

  /// Deserializes a [ShareCollectionRequest] from a JSON map.
  factory ShareCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$ShareCollectionRequestFromJson(json);

  /// Serializes this [ShareCollectionRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$ShareCollectionRequestToJson(this);
}

/// Request body for updating a share permission.
@JsonSerializable()
class UpdateSharePermissionRequest {
  /// New permission level.
  @SharePermissionConverter()
  final SharePermission permission;

  /// Creates an [UpdateSharePermissionRequest] instance.
  const UpdateSharePermissionRequest({required this.permission});

  /// Deserializes an [UpdateSharePermissionRequest] from a JSON map.
  factory UpdateSharePermissionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSharePermissionRequestFromJson(json);

  /// Serializes this [UpdateSharePermissionRequest] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$UpdateSharePermissionRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Forking
// ─────────────────────────────────────────────────────────────────────────────

/// Fork response.
@JsonSerializable()
class ForkResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the original collection.
  final String? sourceCollectionId;

  /// Name of the original collection.
  final String? sourceCollectionName;

  /// UUID of the forked collection.
  final String? forkedCollectionId;

  /// UUID of the user who forked.
  final String? forkedByUserId;

  /// Fork label.
  final String? label;

  /// Timestamp when the fork was created.
  final DateTime? forkedAt;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Creates a [ForkResponse] instance.
  const ForkResponse({
    this.id,
    this.sourceCollectionId,
    this.sourceCollectionName,
    this.forkedCollectionId,
    this.forkedByUserId,
    this.label,
    this.forkedAt,
    this.createdAt,
  });

  /// Deserializes a [ForkResponse] from a JSON map.
  factory ForkResponse.fromJson(Map<String, dynamic> json) =>
      _$ForkResponseFromJson(json);

  /// Serializes this [ForkResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$ForkResponseToJson(this);
}

/// Request body for forking a collection.
@JsonSerializable()
class CreateForkRequest {
  /// Optional label for the fork (max 200 chars).
  final String? label;

  /// Creates a [CreateForkRequest] instance.
  const CreateForkRequest({this.label});

  /// Deserializes a [CreateForkRequest] from a JSON map.
  factory CreateForkRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateForkRequestFromJson(json);

  /// Serializes this [CreateForkRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateForkRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Proxy
// ─────────────────────────────────────────────────────────────────────────────

/// HTTP proxy response from an executed request.
@JsonSerializable()
class ProxyResponse {
  /// HTTP status code.
  final int? statusCode;

  /// HTTP status text.
  final String? statusText;

  /// Response headers.
  final Map<String, List<String>>? responseHeaders;

  /// Response body content.
  final String? responseBody;

  /// Response time in milliseconds.
  final int? responseTimeMs;

  /// Response size in bytes.
  final int? responseSizeBytes;

  /// Response content type.
  final String? contentType;

  /// Redirect chain URLs followed.
  final List<String>? redirectChain;

  /// UUID of the request history entry.
  final String? historyId;

  /// Creates a [ProxyResponse] instance.
  const ProxyResponse({
    this.statusCode,
    this.statusText,
    this.responseHeaders,
    this.responseBody,
    this.responseTimeMs,
    this.responseSizeBytes,
    this.contentType,
    this.redirectChain,
    this.historyId,
  });

  /// Deserializes a [ProxyResponse] from a JSON map.
  factory ProxyResponse.fromJson(Map<String, dynamic> json) =>
      _$ProxyResponseFromJson(json);

  /// Serializes this [ProxyResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$ProxyResponseToJson(this);
}

/// Request body for sending an ad-hoc HTTP request via the proxy.
@JsonSerializable(explicitToJson: true)
class SendRequestProxyRequest {
  /// HTTP method.
  @CourierHttpMethodConverter()
  final CourierHttpMethod method;

  /// Request URL (max 2000 chars).
  final String url;

  /// HTTP headers.
  final List<RequestHeaderEntry>? headers;

  /// Request body configuration.
  final SaveRequestBodyRequest? body;

  /// Authentication configuration.
  final SaveRequestAuthRequest? auth;

  /// UUID of the environment to use for variable substitution.
  final String? environmentId;

  /// UUID of the collection context.
  final String? collectionId;

  /// Whether to save the request to history.
  final bool? saveToHistory;

  /// Request timeout in milliseconds (1000–300000).
  final int? timeoutMs;

  /// Whether to follow HTTP redirects.
  final bool? followRedirects;

  /// Creates a [SendRequestProxyRequest] instance.
  const SendRequestProxyRequest({
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.auth,
    this.environmentId,
    this.collectionId,
    this.saveToHistory,
    this.timeoutMs,
    this.followRedirects,
  });

  /// Deserializes a [SendRequestProxyRequest] from a JSON map.
  factory SendRequestProxyRequest.fromJson(Map<String, dynamic> json) =>
      _$SendRequestProxyRequestFromJson(json);

  /// Serializes this [SendRequestProxyRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$SendRequestProxyRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// GraphQL
// ─────────────────────────────────────────────────────────────────────────────

/// GraphQL execution response.
@JsonSerializable(explicitToJson: true)
class GraphQLResponse {
  /// Underlying HTTP response.
  final ProxyResponse? httpResponse;

  /// GraphQL schema as JSON string.
  final String? schema;

  /// Creates a [GraphQLResponse] instance.
  const GraphQLResponse({this.httpResponse, this.schema});

  /// Deserializes a [GraphQLResponse] from a JSON map.
  factory GraphQLResponse.fromJson(Map<String, dynamic> json) =>
      _$GraphQLResponseFromJson(json);

  /// Serializes this [GraphQLResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$GraphQLResponseToJson(this);
}

/// Request body for executing a GraphQL query.
@JsonSerializable(explicitToJson: true)
class ExecuteGraphQLRequest {
  /// GraphQL endpoint URL.
  final String url;

  /// GraphQL query string.
  final String query;

  /// GraphQL variables as JSON string.
  final String? variables;

  /// GraphQL operation name.
  final String? operationName;

  /// HTTP headers.
  final List<RequestHeaderEntry>? headers;

  /// Authentication configuration.
  final SaveRequestAuthRequest? auth;

  /// UUID of the environment to use.
  final String? environmentId;

  /// Creates an [ExecuteGraphQLRequest] instance.
  const ExecuteGraphQLRequest({
    required this.url,
    required this.query,
    this.variables,
    this.operationName,
    this.headers,
    this.auth,
    this.environmentId,
  });

  /// Deserializes an [ExecuteGraphQLRequest] from a JSON map.
  factory ExecuteGraphQLRequest.fromJson(Map<String, dynamic> json) =>
      _$ExecuteGraphQLRequestFromJson(json);

  /// Serializes this [ExecuteGraphQLRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$ExecuteGraphQLRequestToJson(this);
}

/// Request body for introspecting a GraphQL schema.
@JsonSerializable(explicitToJson: true)
class IntrospectGraphQLRequest {
  /// GraphQL endpoint URL.
  final String url;

  /// HTTP headers.
  final List<RequestHeaderEntry>? headers;

  /// Authentication configuration.
  final SaveRequestAuthRequest? auth;

  /// Creates an [IntrospectGraphQLRequest] instance.
  const IntrospectGraphQLRequest({
    required this.url,
    this.headers,
    this.auth,
  });

  /// Deserializes an [IntrospectGraphQLRequest] from a JSON map.
  factory IntrospectGraphQLRequest.fromJson(Map<String, dynamic> json) =>
      _$IntrospectGraphQLRequestFromJson(json);

  /// Serializes this [IntrospectGraphQLRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$IntrospectGraphQLRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Runner
// ─────────────────────────────────────────────────────────────────────────────

/// Collection run result summary.
@JsonSerializable()
class RunResultResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the owning team.
  final String? teamId;

  /// UUID of the collection that was run.
  final String? collectionId;

  /// UUID of the environment used.
  final String? environmentId;

  /// Run execution status.
  @RunStatusConverter()
  final RunStatus? status;

  /// Total number of requests in the run.
  final int? totalRequests;

  /// Number of passed requests.
  final int? passedRequests;

  /// Number of failed requests.
  final int? failedRequests;

  /// Total number of assertions evaluated.
  final int? totalAssertions;

  /// Number of passed assertions.
  final int? passedAssertions;

  /// Number of failed assertions.
  final int? failedAssertions;

  /// Total duration in milliseconds.
  final int? totalDurationMs;

  /// Number of iterations executed.
  final int? iterationCount;

  /// Delay between requests in milliseconds.
  final int? delayBetweenRequestsMs;

  /// Data file name used for parameterized runs.
  final String? dataFilename;

  /// Timestamp when the run started.
  final DateTime? startedAt;

  /// Timestamp when the run completed.
  final DateTime? completedAt;

  /// UUID of the user who started the run.
  final String? startedByUserId;

  /// Timestamp when the run was created.
  final DateTime? createdAt;

  /// Creates a [RunResultResponse] instance.
  const RunResultResponse({
    this.id,
    this.teamId,
    this.collectionId,
    this.environmentId,
    this.status,
    this.totalRequests,
    this.passedRequests,
    this.failedRequests,
    this.totalAssertions,
    this.passedAssertions,
    this.failedAssertions,
    this.totalDurationMs,
    this.iterationCount,
    this.delayBetweenRequestsMs,
    this.dataFilename,
    this.startedAt,
    this.completedAt,
    this.startedByUserId,
    this.createdAt,
  });

  /// Deserializes a [RunResultResponse] from a JSON map.
  factory RunResultResponse.fromJson(Map<String, dynamic> json) =>
      _$RunResultResponseFromJson(json);

  /// Serializes this [RunResultResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RunResultResponseToJson(this);
}

/// Detailed collection run result with per-iteration data.
@JsonSerializable(explicitToJson: true)
class RunResultDetailResponse {
  /// Overall run summary.
  final RunResultResponse? summary;

  /// Per-iteration results.
  final List<RunIterationResponse>? iterations;

  /// Creates a [RunResultDetailResponse] instance.
  const RunResultDetailResponse({this.summary, this.iterations});

  /// Deserializes a [RunResultDetailResponse] from a JSON map.
  factory RunResultDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$RunResultDetailResponseFromJson(json);

  /// Serializes this [RunResultDetailResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RunResultDetailResponseToJson(this);
}

/// A single iteration within a collection run.
@JsonSerializable()
class RunIterationResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// Iteration number (1-based).
  final int? iterationNumber;

  /// Name of the request executed.
  final String? requestName;

  /// HTTP method of the request.
  @CourierHttpMethodConverter()
  final CourierHttpMethod? requestMethod;

  /// URL of the request.
  final String? requestUrl;

  /// HTTP status code of the response.
  final int? responseStatus;

  /// Response time in milliseconds.
  final int? responseTimeMs;

  /// Response size in bytes.
  final int? responseSizeBytes;

  /// Whether the iteration passed all assertions.
  final bool? passed;

  /// Assertion results as JSON string.
  final String? assertionResults;

  /// Error message if the iteration failed.
  final String? errorMessage;

  /// Creates a [RunIterationResponse] instance.
  const RunIterationResponse({
    this.id,
    this.iterationNumber,
    this.requestName,
    this.requestMethod,
    this.requestUrl,
    this.responseStatus,
    this.responseTimeMs,
    this.responseSizeBytes,
    this.passed,
    this.assertionResults,
    this.errorMessage,
  });

  /// Deserializes a [RunIterationResponse] from a JSON map.
  factory RunIterationResponse.fromJson(Map<String, dynamic> json) =>
      _$RunIterationResponseFromJson(json);

  /// Serializes this [RunIterationResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RunIterationResponseToJson(this);
}

/// Request body for starting a collection run.
@JsonSerializable()
class StartCollectionRunRequest {
  /// UUID of the collection to run.
  final String collectionId;

  /// UUID of the environment to use.
  final String? environmentId;

  /// Number of iterations (1–1000).
  final int? iterationCount;

  /// Delay between requests in milliseconds (0–60000).
  final int? delayBetweenRequestsMs;

  /// Data file name for parameterized runs.
  final String? dataFilename;

  /// Data file content as JSON/CSV string.
  final String? dataContent;

  /// Creates a [StartCollectionRunRequest] instance.
  const StartCollectionRunRequest({
    required this.collectionId,
    this.environmentId,
    this.iterationCount,
    this.delayBetweenRequestsMs,
    this.dataFilename,
    this.dataContent,
  });

  /// Deserializes a [StartCollectionRunRequest] from a JSON map.
  factory StartCollectionRunRequest.fromJson(Map<String, dynamic> json) =>
      _$StartCollectionRunRequestFromJson(json);

  /// Serializes this [StartCollectionRunRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$StartCollectionRunRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// History
// ─────────────────────────────────────────────────────────────────────────────

/// Request history summary entry.
@JsonSerializable()
class RequestHistoryResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the user who made the request.
  final String? userId;

  /// HTTP method used.
  @CourierHttpMethodConverter()
  final CourierHttpMethod? requestMethod;

  /// Request URL.
  final String? requestUrl;

  /// HTTP status code of the response.
  final int? responseStatus;

  /// Response time in milliseconds.
  final int? responseTimeMs;

  /// Response size in bytes.
  final int? responseSizeBytes;

  /// Response content type.
  final String? contentType;

  /// UUID of the collection context.
  final String? collectionId;

  /// UUID of the request.
  final String? requestId;

  /// UUID of the environment used.
  final String? environmentId;

  /// Timestamp when the request was made.
  final DateTime? createdAt;

  /// Creates a [RequestHistoryResponse] instance.
  const RequestHistoryResponse({
    this.id,
    this.userId,
    this.requestMethod,
    this.requestUrl,
    this.responseStatus,
    this.responseTimeMs,
    this.responseSizeBytes,
    this.contentType,
    this.collectionId,
    this.requestId,
    this.environmentId,
    this.createdAt,
  });

  /// Deserializes a [RequestHistoryResponse] from a JSON map.
  factory RequestHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestHistoryResponseFromJson(json);

  /// Serializes this [RequestHistoryResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$RequestHistoryResponseToJson(this);
}

/// Detailed request history entry with full request/response data.
@JsonSerializable()
class RequestHistoryDetailResponse {
  /// Unique identifier (UUID).
  final String? id;

  /// UUID of the user who made the request.
  final String? userId;

  /// HTTP method used.
  @CourierHttpMethodConverter()
  final CourierHttpMethod? requestMethod;

  /// Request URL.
  final String? requestUrl;

  /// Request headers as JSON string.
  final String? requestHeaders;

  /// Request body.
  final String? requestBody;

  /// HTTP status code of the response.
  final int? responseStatus;

  /// Response headers as JSON string.
  final String? responseHeaders;

  /// Response body.
  final String? responseBody;

  /// Response size in bytes.
  final int? responseSizeBytes;

  /// Response time in milliseconds.
  final int? responseTimeMs;

  /// Response content type.
  final String? contentType;

  /// UUID of the collection context.
  final String? collectionId;

  /// UUID of the request.
  final String? requestId;

  /// UUID of the environment used.
  final String? environmentId;

  /// Timestamp when the request was made.
  final DateTime? createdAt;

  /// Creates a [RequestHistoryDetailResponse] instance.
  const RequestHistoryDetailResponse({
    this.id,
    this.userId,
    this.requestMethod,
    this.requestUrl,
    this.requestHeaders,
    this.requestBody,
    this.responseStatus,
    this.responseHeaders,
    this.responseBody,
    this.responseSizeBytes,
    this.responseTimeMs,
    this.contentType,
    this.collectionId,
    this.requestId,
    this.environmentId,
    this.createdAt,
  });

  /// Deserializes a [RequestHistoryDetailResponse] from a JSON map.
  factory RequestHistoryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestHistoryDetailResponseFromJson(json);

  /// Serializes this [RequestHistoryDetailResponse] to a JSON map.
  Map<String, dynamic> toJson() =>
      _$RequestHistoryDetailResponseToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Import / Export
// ─────────────────────────────────────────────────────────────────────────────

/// Request body for importing a collection.
@JsonSerializable()
class ImportCollectionRequest {
  /// Import format (postman, openapi, curl).
  final String format;

  /// Collection content to import.
  final String content;

  /// Creates an [ImportCollectionRequest] instance.
  const ImportCollectionRequest({
    required this.format,
    required this.content,
  });

  /// Deserializes an [ImportCollectionRequest] from a JSON map.
  factory ImportCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$ImportCollectionRequestFromJson(json);

  /// Serializes this [ImportCollectionRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$ImportCollectionRequestToJson(this);
}

/// Import result response.
@JsonSerializable()
class ImportResultResponse {
  /// UUID of the imported collection.
  final String? collectionId;

  /// Collection name.
  final String? collectionName;

  /// Number of folders imported.
  final int? foldersImported;

  /// Number of requests imported.
  final int? requestsImported;

  /// Number of environments imported.
  final int? environmentsImported;

  /// Import warnings.
  final List<String>? warnings;

  /// Creates an [ImportResultResponse] instance.
  const ImportResultResponse({
    this.collectionId,
    this.collectionName,
    this.foldersImported,
    this.requestsImported,
    this.environmentsImported,
    this.warnings,
  });

  /// Deserializes an [ImportResultResponse] from a JSON map.
  factory ImportResultResponse.fromJson(Map<String, dynamic> json) =>
      _$ImportResultResponseFromJson(json);

  /// Serializes this [ImportResultResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$ImportResultResponseToJson(this);
}

/// Collection export response.
@JsonSerializable()
class ExportCollectionResponse {
  /// Export format.
  final String? format;

  /// Exported collection content.
  final String? content;

  /// Suggested filename for download.
  final String? filename;

  /// Creates an [ExportCollectionResponse] instance.
  const ExportCollectionResponse({
    this.format,
    this.content,
    this.filename,
  });

  /// Deserializes an [ExportCollectionResponse] from a JSON map.
  factory ExportCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$ExportCollectionResponseFromJson(json);

  /// Serializes this [ExportCollectionResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$ExportCollectionResponseToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Code Generation
// ─────────────────────────────────────────────────────────────────────────────

/// Generated code snippet response.
@JsonSerializable()
class CodeSnippetResponse {
  /// Target language.
  @CodeLanguageConverter()
  final CodeLanguage? language;

  /// Language display name.
  final String? displayName;

  /// Generated code.
  final String? code;

  /// File extension for the language.
  final String? fileExtension;

  /// Content type.
  final String? contentType;

  /// Creates a [CodeSnippetResponse] instance.
  const CodeSnippetResponse({
    this.language,
    this.displayName,
    this.code,
    this.fileExtension,
    this.contentType,
  });

  /// Deserializes a [CodeSnippetResponse] from a JSON map.
  factory CodeSnippetResponse.fromJson(Map<String, dynamic> json) =>
      _$CodeSnippetResponseFromJson(json);

  /// Serializes this [CodeSnippetResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$CodeSnippetResponseToJson(this);
}

/// Request body for generating a code snippet.
@JsonSerializable()
class GenerateCodeRequest {
  /// UUID of the request to generate code from.
  final String requestId;

  /// Target language.
  @CodeLanguageConverter()
  final CodeLanguage language;

  /// UUID of the environment to use for variable substitution.
  final String? environmentId;

  /// Creates a [GenerateCodeRequest] instance.
  const GenerateCodeRequest({
    required this.requestId,
    required this.language,
    this.environmentId,
  });

  /// Deserializes a [GenerateCodeRequest] from a JSON map.
  factory GenerateCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateCodeRequestFromJson(json);

  /// Serializes this [GenerateCodeRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$GenerateCodeRequestToJson(this);
}
