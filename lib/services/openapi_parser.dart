/// Parser for OpenAPI 3.0 JSON specifications.
///
/// Handles `$ref` resolution, schema flattening, `allOf`/`oneOf`/`anyOf`
/// merging, and tag grouping. Produces structured [OpenApiSpec] models
/// from raw JSON maps.
library;

import '../models/openapi_spec.dart';

/// Parses OpenAPI 3.0 JSON into structured [OpenApiSpec] models.
///
/// Usage:
/// ```dart
/// final spec = OpenApiParser.parse(jsonMap);
/// ```
class OpenApiParser {
  OpenApiParser._();

  /// Parses a raw OpenAPI 3.0 JSON map into an [OpenApiSpec].
  static OpenApiSpec parse(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final components =
        json['components'] as Map<String, dynamic>? ?? {};
    final schemasJson =
        components['schemas'] as Map<String, dynamic>? ?? {};

    final schemas = <String, OpenApiSchema>{};
    for (final entry in schemasJson.entries) {
      schemas[entry.key] =
          _parseSchema(entry.value as Map<String, dynamic>, schemasJson);
    }

    final paths = json['paths'] as Map<String, dynamic>? ?? {};
    final endpoints = _parsePaths(paths, schemasJson);

    final tagsJson = json['tags'] as List<dynamic>? ?? [];
    final tags = tagsJson.map((t) {
      final tagMap = t as Map<String, dynamic>;
      return OpenApiTag(
        name: tagMap['name'] as String? ?? '',
        description: tagMap['description'] as String?,
      );
    }).toList();

    final serversJson = json['servers'] as List<dynamic>? ?? [];
    final servers = serversJson.map((s) {
      final serverMap = s as Map<String, dynamic>;
      return OpenApiServer(
        url: serverMap['url'] as String? ?? '',
        description: serverMap['description'] as String?,
      );
    }).toList();

    return OpenApiSpec(
      title: info['title'] as String? ?? 'API',
      description: info['description'] as String?,
      version: info['version'] as String? ?? '0.0.0',
      tags: tags,
      endpoints: endpoints,
      schemas: schemas,
      servers: servers,
    );
  }

  /// Extracts all endpoints from the `paths` object.
  static List<OpenApiEndpoint> _parsePaths(
    Map<String, dynamic> paths,
    Map<String, dynamic> schemasJson,
  ) {
    final endpoints = <OpenApiEndpoint>[];
    final httpMethods = {'get', 'post', 'put', 'delete', 'patch', 'options', 'head'};

    for (final pathEntry in paths.entries) {
      final pathStr = pathEntry.key;
      final pathItem = pathEntry.value as Map<String, dynamic>? ?? {};

      // Path-level parameters apply to all operations.
      final pathParams = _parseParameters(
        pathItem['parameters'] as List<dynamic>? ?? [],
        schemasJson,
      );

      for (final method in httpMethods) {
        final operation = pathItem[method] as Map<String, dynamic>?;
        if (operation == null) continue;

        final opTags = (operation['tags'] as List<dynamic>?)
                ?.map((t) => t as String)
                .toList() ??
            [];

        final opParams = _parseParameters(
          operation['parameters'] as List<dynamic>? ?? [],
          schemasJson,
        );

        // Merge path-level params with operation params (op takes precedence).
        final mergedParams = <String, OpenApiParameter>{};
        for (final p in pathParams) {
          mergedParams['${p.location}:${p.name}'] = p;
        }
        for (final p in opParams) {
          mergedParams['${p.location}:${p.name}'] = p;
        }

        final requestBody = _parseRequestBody(
          operation['requestBody'] as Map<String, dynamic>?,
          schemasJson,
        );

        final responsesJson =
            operation['responses'] as Map<String, dynamic>? ?? {};
        final responses = <String, OpenApiResponse>{};
        for (final respEntry in responsesJson.entries) {
          responses[respEntry.key] = _parseResponse(
            respEntry.value as Map<String, dynamic>,
            schemasJson,
          );
        }

        endpoints.add(OpenApiEndpoint(
          path: pathStr,
          method: method.toUpperCase(),
          summary: operation['summary'] as String?,
          description: operation['description'] as String?,
          operationId: operation['operationId'] as String?,
          tags: opTags,
          parameters: mergedParams.values.toList(),
          requestBody: requestBody,
          responses: responses,
          deprecated: operation['deprecated'] as bool? ?? false,
        ));
      }
    }

    return endpoints;
  }

  /// Parses a list of parameter definitions.
  static List<OpenApiParameter> _parseParameters(
    List<dynamic> paramsJson,
    Map<String, dynamic> schemasJson,
  ) {
    return paramsJson.map((p) {
      final param = p as Map<String, dynamic>;

      // Handle $ref in parameters.
      if (param.containsKey('\$ref')) {
        return OpenApiParameter(
          name: _refName(param['\$ref'] as String),
          location: 'query',
        );
      }

      final schemaJson = param['schema'] as Map<String, dynamic>?;

      return OpenApiParameter(
        name: param['name'] as String? ?? '',
        location: param['in'] as String? ?? 'query',
        required: param['required'] as bool? ?? false,
        description: param['description'] as String?,
        schema:
            schemaJson != null ? _parseSchema(schemaJson, schemasJson) : null,
      );
    }).toList();
  }

  /// Parses a request body definition.
  static OpenApiRequestBody? _parseRequestBody(
    Map<String, dynamic>? bodyJson,
    Map<String, dynamic> schemasJson,
  ) {
    if (bodyJson == null) return null;

    // Handle $ref on requestBody.
    if (bodyJson.containsKey('\$ref')) return null;

    final contentJson =
        bodyJson['content'] as Map<String, dynamic>? ?? {};
    final content = <String, OpenApiMediaType>{};
    for (final entry in contentJson.entries) {
      final mediaJson = entry.value as Map<String, dynamic>;
      final schemaJson = mediaJson['schema'] as Map<String, dynamic>?;
      if (schemaJson != null) {
        content[entry.key] = OpenApiMediaType(
          schema: _parseSchema(schemaJson, schemasJson),
        );
      }
    }

    return OpenApiRequestBody(
      required: bodyJson['required'] as bool? ?? false,
      description: bodyJson['description'] as String?,
      content: content,
    );
  }

  /// Parses a response definition.
  static OpenApiResponse _parseResponse(
    Map<String, dynamic> respJson,
    Map<String, dynamic> schemasJson,
  ) {
    final contentJson =
        respJson['content'] as Map<String, dynamic>?;
    Map<String, OpenApiMediaType>? content;

    if (contentJson != null) {
      content = {};
      for (final entry in contentJson.entries) {
        final mediaJson = entry.value as Map<String, dynamic>;
        final schemaJson = mediaJson['schema'] as Map<String, dynamic>?;
        if (schemaJson != null) {
          content[entry.key] = OpenApiMediaType(
            schema: _parseSchema(schemaJson, schemasJson),
          );
        }
      }
    }

    return OpenApiResponse(
      description: respJson['description'] as String? ?? '',
      content: content,
    );
  }

  /// Parses a schema definition with `$ref` resolution.
  static OpenApiSchema _parseSchema(
    Map<String, dynamic> json,
    Map<String, dynamic> schemasJson, {
    int depth = 0,
  }) {
    // Prevent infinite recursion.
    if (depth > 8) {
      return const OpenApiSchema(type: 'object', description: '(circular)');
    }

    // Handle $ref.
    if (json.containsKey('\$ref')) {
      final refStr = json['\$ref'] as String;
      final name = _refName(refStr);
      final resolved = schemasJson[name] as Map<String, dynamic>?;
      if (resolved != null) {
        return _parseSchema(resolved, schemasJson, depth: depth + 1)
            ._withRef(name);
      }
      return OpenApiSchema(ref: name, type: 'object');
    }

    // Handle allOf.
    if (json.containsKey('allOf')) {
      final allOfList = json['allOf'] as List<dynamic>;
      return _mergeAllOf(allOfList, schemasJson, depth);
    }

    // Handle oneOf / anyOf.
    List<OpenApiSchema>? oneOf;
    if (json.containsKey('oneOf')) {
      oneOf = (json['oneOf'] as List<dynamic>)
          .map((s) =>
              _parseSchema(s as Map<String, dynamic>, schemasJson, depth: depth + 1))
          .toList();
    }

    List<OpenApiSchema>? anyOf;
    if (json.containsKey('anyOf')) {
      anyOf = (json['anyOf'] as List<dynamic>)
          .map((s) =>
              _parseSchema(s as Map<String, dynamic>, schemasJson, depth: depth + 1))
          .toList();
    }

    // Parse properties.
    Map<String, OpenApiSchema>? properties;
    final propsJson = json['properties'] as Map<String, dynamic>?;
    if (propsJson != null) {
      properties = {};
      for (final entry in propsJson.entries) {
        properties[entry.key] = _parseSchema(
          entry.value as Map<String, dynamic>,
          schemasJson,
          depth: depth + 1,
        );
      }
    }

    // Parse items (for arrays).
    OpenApiSchema? items;
    final itemsJson = json['items'] as Map<String, dynamic>?;
    if (itemsJson != null) {
      items = _parseSchema(itemsJson, schemasJson, depth: depth + 1);
    }

    // Parse enum values.
    List<String>? enumValues;
    final enumJson = json['enum'] as List<dynamic>?;
    if (enumJson != null) {
      enumValues = enumJson.map((e) => e.toString()).toList();
    }

    // Parse required fields.
    List<String>? required;
    final requiredJson = json['required'] as List<dynamic>?;
    if (requiredJson != null) {
      required = requiredJson.map((r) => r as String).toList();
    }

    return OpenApiSchema(
      type: json['type'] as String?,
      format: json['format'] as String?,
      description: json['description'] as String?,
      required: required,
      properties: properties,
      items: items,
      enumValues: enumValues,
      maxLength: json['maxLength'] as int?,
      example: json['example'],
      oneOf: oneOf,
      anyOf: anyOf,
    );
  }

  /// Merges `allOf` schemas into a single schema.
  static OpenApiSchema _mergeAllOf(
    List<dynamic> allOfList,
    Map<String, dynamic> schemasJson,
    int depth,
  ) {
    final mergedProps = <String, OpenApiSchema>{};
    final mergedRequired = <String>[];
    String? refName;

    for (final item in allOfList) {
      final schema = _parseSchema(
        item as Map<String, dynamic>,
        schemasJson,
        depth: depth + 1,
      );
      if (schema.ref != null) refName = schema.ref;
      if (schema.properties != null) {
        mergedProps.addAll(schema.properties!);
      }
      if (schema.required != null) {
        mergedRequired.addAll(schema.required!);
      }
    }

    return OpenApiSchema(
      type: 'object',
      ref: refName,
      properties: mergedProps.isEmpty ? null : mergedProps,
      required: mergedRequired.isEmpty ? null : mergedRequired,
    );
  }

  /// Extracts the schema name from a `$ref` string.
  static String _refName(String ref) {
    // "#/components/schemas/ServiceRegistrationResponse" → "ServiceRegistrationResponse"
    return ref.split('/').last;
  }
}

extension on OpenApiSchema {
  /// Returns a copy with the [ref] field set.
  OpenApiSchema _withRef(String refName) => OpenApiSchema(
        type: type,
        format: format,
        ref: refName,
        description: description,
        required: required,
        properties: properties,
        items: items,
        enumValues: enumValues,
        maxLength: maxLength,
        example: example,
        allOf: allOf,
        oneOf: oneOf,
        anyOf: anyOf,
      );
}
