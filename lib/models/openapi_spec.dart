/// Parsed OpenAPI 3.0 specification models.
///
/// Represents a fully-parsed OpenAPI spec with endpoints grouped by tags,
/// request/response schemas, and parameter definitions. Used by
/// [OpenApiParser] to produce structured data from raw JSON.
library;

/// Parsed OpenAPI 3.0 specification.
class OpenApiSpec {
  /// API title from `info.title`.
  final String title;

  /// API description from `info.description`.
  final String? description;

  /// API version from `info.version`.
  final String version;

  /// Tag definitions for endpoint grouping.
  final List<OpenApiTag> tags;

  /// All endpoint definitions from `paths`.
  final List<OpenApiEndpoint> endpoints;

  /// Named schema definitions from `components.schemas`.
  final Map<String, OpenApiSchema> schemas;

  /// Server definitions from `servers`.
  final List<OpenApiServer> servers;

  /// Creates an [OpenApiSpec].
  const OpenApiSpec({
    required this.title,
    this.description,
    required this.version,
    this.tags = const [],
    this.endpoints = const [],
    this.schemas = const {},
    this.servers = const [],
  });
}

/// Tag grouping for endpoints.
class OpenApiTag {
  /// Tag name used to group endpoints.
  final String name;

  /// Optional description of the tag group.
  final String? description;

  /// Creates an [OpenApiTag].
  const OpenApiTag({required this.name, this.description});
}

/// Single API endpoint (path + method combination).
class OpenApiEndpoint {
  /// URL path template (e.g., `/api/v1/registry/services/{serviceId}`).
  final String path;

  /// HTTP method (GET, POST, PUT, DELETE, PATCH).
  final String method;

  /// Short summary of the endpoint.
  final String? summary;

  /// Longer description of the endpoint.
  final String? description;

  /// Unique operation identifier.
  final String? operationId;

  /// Tag names this endpoint belongs to.
  final List<String> tags;

  /// Path, query, and header parameters.
  final List<OpenApiParameter> parameters;

  /// Request body specification.
  final OpenApiRequestBody? requestBody;

  /// Response specifications keyed by status code.
  final Map<String, OpenApiResponse> responses;

  /// Whether this endpoint is deprecated.
  final bool deprecated;

  /// Creates an [OpenApiEndpoint].
  const OpenApiEndpoint({
    required this.path,
    required this.method,
    this.summary,
    this.description,
    this.operationId,
    this.tags = const [],
    this.parameters = const [],
    this.requestBody,
    this.responses = const {},
    this.deprecated = false,
  });
}

/// Request/query/path parameter definition.
class OpenApiParameter {
  /// Parameter name.
  final String name;

  /// Parameter location: `path`, `query`, or `header`.
  final String location;

  /// Whether this parameter is required.
  final bool required;

  /// Optional description of the parameter.
  final String? description;

  /// Schema defining the parameter type.
  final OpenApiSchema? schema;

  /// Creates an [OpenApiParameter].
  const OpenApiParameter({
    required this.name,
    required this.location,
    this.required = false,
    this.description,
    this.schema,
  });
}

/// Request body specification.
class OpenApiRequestBody {
  /// Whether the request body is required.
  final bool required;

  /// Optional description of the request body.
  final String? description;

  /// Content types with their schemas (e.g., `application/json`).
  final Map<String, OpenApiMediaType> content;

  /// Creates an [OpenApiRequestBody].
  const OpenApiRequestBody({
    this.required = false,
    this.description,
    this.content = const {},
  });
}

/// Media type with schema reference.
class OpenApiMediaType {
  /// Schema defining the content structure.
  final OpenApiSchema schema;

  /// Creates an [OpenApiMediaType].
  const OpenApiMediaType({required this.schema});
}

/// Response specification for a status code.
class OpenApiResponse {
  /// Description of the response.
  final String description;

  /// Content types with their schemas.
  final Map<String, OpenApiMediaType>? content;

  /// Creates an [OpenApiResponse].
  const OpenApiResponse({required this.description, this.content});
}

/// Schema definition for request/response bodies.
class OpenApiSchema {
  /// Type identifier: `object`, `array`, `string`, `integer`, etc.
  final String? type;

  /// Format qualifier: `uuid`, `date-time`, `int64`, etc.
  final String? format;

  /// Resolved `$ref` schema name.
  final String? ref;

  /// Optional description.
  final String? description;

  /// Required property names for object types.
  final List<String>? required;

  /// Object properties keyed by name.
  final Map<String, OpenApiSchema>? properties;

  /// Item schema for array types.
  final OpenApiSchema? items;

  /// Enum value options.
  final List<String>? enumValues;

  /// Maximum string length.
  final int? maxLength;

  /// Example value.
  final dynamic example;

  /// `allOf` composite schemas.
  final List<OpenApiSchema>? allOf;

  /// `oneOf` alternative schemas.
  final List<OpenApiSchema>? oneOf;

  /// `anyOf` flexible schemas.
  final List<OpenApiSchema>? anyOf;

  /// Creates an [OpenApiSchema].
  const OpenApiSchema({
    this.type,
    this.format,
    this.ref,
    this.description,
    this.required,
    this.properties,
    this.items,
    this.enumValues,
    this.maxLength,
    this.example,
    this.allOf,
    this.oneOf,
    this.anyOf,
  });
}

/// Server definition from `servers`.
class OpenApiServer {
  /// Server URL.
  final String url;

  /// Optional description of the server.
  final String? description;

  /// Creates an [OpenApiServer].
  const OpenApiServer({required this.url, this.description});
}
