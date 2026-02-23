// Tests for OpenApiParser.
//
// Verifies parsing of info, paths, schemas, parameters, request bodies,
// responses, $ref resolution, allOf merging, oneOf/anyOf, enum values,
// depth limiting, and tag extraction.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/openapi_spec.dart';
import 'package:codeops/services/openapi_parser.dart';

Map<String, dynamic> _minimalSpec({
  Map<String, dynamic>? paths,
  Map<String, dynamic>? schemas,
  List<dynamic>? tags,
  List<dynamic>? servers,
}) {
  return {
    'info': {
      'title': 'Test API',
      'version': '1.0.0',
      'description': 'A test API',
    },
    if (paths != null) 'paths': paths,
    if (schemas != null)
      'components': {'schemas': schemas},
    if (tags != null) 'tags': tags,
    if (servers != null) 'servers': servers,
  };
}

void main() {
  group('OpenApiParser', () {
    test('parses info section', () {
      final spec = OpenApiParser.parse(_minimalSpec());

      expect(spec.title, 'Test API');
      expect(spec.version, '1.0.0');
      expect(spec.description, 'A test API');
    });

    test('parses tags', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        tags: [
          {'name': 'Users', 'description': 'User management'},
          {'name': 'Auth'},
        ],
      ));

      expect(spec.tags.length, 2);
      expect(spec.tags[0].name, 'Users');
      expect(spec.tags[0].description, 'User management');
      expect(spec.tags[1].name, 'Auth');
      expect(spec.tags[1].description, isNull);
    });

    test('parses servers', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        servers: [
          {'url': 'http://localhost:8090', 'description': 'Local'},
        ],
      ));

      expect(spec.servers.length, 1);
      expect(spec.servers[0].url, 'http://localhost:8090');
      expect(spec.servers[0].description, 'Local');
    });

    test('parses simple GET endpoint', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/users': {
            'get': {
              'summary': 'List users',
              'operationId': 'listUsers',
              'tags': ['Users'],
              'responses': {
                '200': {'description': 'Success'},
              },
            },
          },
        },
      ));

      expect(spec.endpoints.length, 1);
      final ep = spec.endpoints[0];
      expect(ep.path, '/api/users');
      expect(ep.method, 'GET');
      expect(ep.summary, 'List users');
      expect(ep.operationId, 'listUsers');
      expect(ep.tags, ['Users']);
      expect(ep.responses.containsKey('200'), true);
    });

    test('parses multiple methods on same path', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/users': {
            'get': {
              'summary': 'List users',
              'responses': {'200': {'description': 'OK'}},
            },
            'post': {
              'summary': 'Create user',
              'responses': {'201': {'description': 'Created'}},
            },
          },
        },
      ));

      expect(spec.endpoints.length, 2);
      final methods = spec.endpoints.map((e) => e.method).toSet();
      expect(methods, containsAll(['GET', 'POST']));
    });

    test('parses path parameters', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/users/{id}': {
            'get': {
              'parameters': [
                {
                  'name': 'id',
                  'in': 'path',
                  'required': true,
                  'schema': {'type': 'string', 'format': 'uuid'},
                },
              ],
              'responses': {'200': {'description': 'OK'}},
            },
          },
        },
      ));

      final ep = spec.endpoints[0];
      expect(ep.parameters.length, 1);
      expect(ep.parameters[0].name, 'id');
      expect(ep.parameters[0].location, 'path');
      expect(ep.parameters[0].required, true);
      expect(ep.parameters[0].schema?.type, 'string');
      expect(ep.parameters[0].schema?.format, 'uuid');
    });

    test('merges path-level and operation-level parameters', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/users/{id}': {
            'parameters': [
              {'name': 'id', 'in': 'path', 'required': true},
            ],
            'get': {
              'parameters': [
                {'name': 'fields', 'in': 'query'},
              ],
              'responses': {'200': {'description': 'OK'}},
            },
          },
        },
      ));

      final ep = spec.endpoints[0];
      expect(ep.parameters.length, 2);
      final names = ep.parameters.map((p) => p.name).toSet();
      expect(names, containsAll(['id', 'fields']));
    });

    test('parses request body with schema', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/users': {
            'post': {
              'requestBody': {
                'required': true,
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'name': {'type': 'string'},
                        'email': {'type': 'string', 'format': 'email'},
                      },
                      'required': ['name', 'email'],
                    },
                  },
                },
              },
              'responses': {'201': {'description': 'Created'}},
            },
          },
        },
      ));

      final ep = spec.endpoints[0];
      expect(ep.requestBody, isNotNull);
      expect(ep.requestBody!.required, true);
      expect(ep.requestBody!.content.containsKey('application/json'), true);
      final schema = ep.requestBody!.content['application/json']!.schema;
      expect(schema.type, 'object');
      expect(schema.properties!.containsKey('name'), true);
      expect(schema.required, ['name', 'email']);
    });

    test('parses response with content schema', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/users/{id}': {
            'get': {
              'responses': {
                '200': {
                  'description': 'User found',
                  'content': {
                    'application/json': {
                      'schema': {
                        'type': 'object',
                        'properties': {
                          'id': {'type': 'string'},
                        },
                      },
                    },
                  },
                },
                '404': {'description': 'Not found'},
              },
            },
          },
        },
      ));

      final ep = spec.endpoints[0];
      expect(ep.responses.length, 2);
      final resp200 = ep.responses['200']!;
      expect(resp200.description, 'User found');
      expect(resp200.content, isNotNull);
      expect(resp200.content!.containsKey('application/json'), true);
      final resp404 = ep.responses['404']!;
      expect(resp404.description, 'Not found');
      expect(resp404.content, isNull);
    });

    test('resolves \$ref in schemas', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        schemas: {
          'User': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
            },
          },
        },
        paths: {
          '/api/users/{id}': {
            'get': {
              'responses': {
                '200': {
                  'description': 'OK',
                  'content': {
                    'application/json': {
                      'schema': {'\$ref': '#/components/schemas/User'},
                    },
                  },
                },
              },
            },
          },
        },
      ));

      final ep = spec.endpoints[0];
      final schema = ep.responses['200']!.content!['application/json']!.schema;
      expect(schema.ref, 'User');
      expect(schema.properties!.containsKey('name'), true);
    });

    test('parses allOf schema merge', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        schemas: {
          'Base': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string'},
            },
          },
          'Extended': {
            'allOf': [
              {'\$ref': '#/components/schemas/Base'},
              {
                'type': 'object',
                'properties': {
                  'extra': {'type': 'string'},
                },
              },
            ],
          },
        },
      ));

      final extended = spec.schemas['Extended']!;
      expect(extended.type, 'object');
      expect(extended.properties!.containsKey('id'), true);
      expect(extended.properties!.containsKey('extra'), true);
    });

    test('parses enum values', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        schemas: {
          'Status': {
            'type': 'string',
            'enum': ['ACTIVE', 'INACTIVE', 'PENDING'],
          },
        },
      ));

      final status = spec.schemas['Status']!;
      expect(status.type, 'string');
      expect(status.enumValues, ['ACTIVE', 'INACTIVE', 'PENDING']);
    });

    test('parses array schema with items', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        schemas: {
          'UserList': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
              },
            },
          },
        },
      ));

      final list = spec.schemas['UserList']!;
      expect(list.type, 'array');
      expect(list.items, isNotNull);
      expect(list.items!.type, 'object');
      expect(list.items!.properties!.containsKey('name'), true);
    });

    test('parses deprecated endpoints', () {
      final spec = OpenApiParser.parse(_minimalSpec(
        paths: {
          '/api/old': {
            'get': {
              'deprecated': true,
              'responses': {'200': {'description': 'OK'}},
            },
          },
        },
      ));

      expect(spec.endpoints[0].deprecated, true);
    });

    test('handles missing info gracefully', () {
      final spec = OpenApiParser.parse({});

      expect(spec.title, 'API');
      expect(spec.version, '0.0.0');
      expect(spec.endpoints, isEmpty);
      expect(spec.schemas, isEmpty);
    });

    test('limits recursion depth', () {
      // Create a self-referencing schema that would loop forever.
      final spec = OpenApiParser.parse(_minimalSpec(
        schemas: {
          'Node': {
            'type': 'object',
            'properties': {
              'child': {'\$ref': '#/components/schemas/Node'},
            },
          },
        },
      ));

      // Should parse without crashing.
      expect(spec.schemas['Node'], isNotNull);
      expect(spec.schemas['Node']!.properties!.containsKey('child'), true);
    });
  });
}
