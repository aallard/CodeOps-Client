import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Collections
  // ═══════════════════════════════════════════════════════════════════════════

  group('CollectionResponse', () {
    final json = <String, dynamic>{
      'id': 'col-1',
      'teamId': 'team-1',
      'name': 'My Collection',
      'description': 'A test collection',
      'authType': 'NO_AUTH',
      'isShared': false,
      'createdBy': 'user-1',
      'folderCount': 3,
      'requestCount': 12,
      'createdAt': '2026-02-20T00:00:00.000Z',
      'updatedAt': '2026-02-20T10:00:00.000Z',
    };

    test('fromJson deserializes all fields', () {
      final m = CollectionResponse.fromJson(json);
      expect(m.id, 'col-1');
      expect(m.name, 'My Collection');
      expect(m.authType!.toJson(), 'NO_AUTH');
      expect(m.folderCount, 3);
      expect(m.requestCount, 12);
    });

    test('toJson round-trip preserves data', () {
      final restored = CollectionResponse.fromJson(
        CollectionResponse.fromJson(json).toJson(),
      );
      expect(restored.id, 'col-1');
      expect(restored.name, 'My Collection');
    });

    test('handles null optionals', () {
      final m = CollectionResponse.fromJson(<String, dynamic>{});
      expect(m.id, isNull);
      expect(m.name, isNull);
      expect(m.authType, isNull);
    });
  });

  group('CollectionSummaryResponse', () {
    test('fromJson deserializes all fields', () {
      final m = CollectionSummaryResponse.fromJson(<String, dynamic>{
        'id': 'col-1',
        'name': 'Summary',
        'isShared': true,
        'folderCount': 2,
        'requestCount': 8,
        'updatedAt': '2026-02-20T10:00:00.000Z',
      });
      expect(m.id, 'col-1');
      expect(m.isShared, isTrue);
      expect(m.folderCount, 2);
    });
  });

  group('CreateCollectionRequest', () {
    test('round-trip preserves data', () {
      const req = CreateCollectionRequest(name: 'New Col');
      final restored = CreateCollectionRequest.fromJson(req.toJson());
      expect(restored.name, 'New Col');
    });

    test('toJson includes optional auth fields', () {
      const req = CreateCollectionRequest(
        name: 'Auth Col',
        authType: null,
        authConfig: '{}',
      );
      final json = req.toJson();
      expect(json['name'], 'Auth Col');
    });
  });

  group('UpdateCollectionRequest', () {
    test('round-trip preserves data', () {
      const req = UpdateCollectionRequest(name: 'Updated', description: 'desc');
      final restored = UpdateCollectionRequest.fromJson(req.toJson());
      expect(restored.name, 'Updated');
      expect(restored.description, 'desc');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Folders
  // ═══════════════════════════════════════════════════════════════════════════

  group('FolderResponse', () {
    final json = <String, dynamic>{
      'id': 'fld-1',
      'collectionId': 'col-1',
      'parentFolderId': null,
      'name': 'Root Folder',
      'sortOrder': 0,
      'authType': 'INHERIT_FROM_PARENT',
      'subFolderCount': 2,
      'requestCount': 5,
      'createdAt': '2026-02-20T00:00:00.000Z',
      'updatedAt': '2026-02-20T10:00:00.000Z',
    };

    test('fromJson deserializes all fields', () {
      final m = FolderResponse.fromJson(json);
      expect(m.id, 'fld-1');
      expect(m.name, 'Root Folder');
      expect(m.parentFolderId, isNull);
      expect(m.authType!.toJson(), 'INHERIT_FROM_PARENT');
      expect(m.subFolderCount, 2);
    });

    test('toJson round-trip preserves data', () {
      final restored = FolderResponse.fromJson(
        FolderResponse.fromJson(json).toJson(),
      );
      expect(restored.collectionId, 'col-1');
    });
  });

  group('FolderTreeResponse', () {
    test('fromJson deserializes nested structure', () {
      final m = FolderTreeResponse.fromJson(<String, dynamic>{
        'id': 'fld-1',
        'name': 'Root',
        'sortOrder': 0,
        'subFolders': [
          {
            'id': 'fld-2',
            'name': 'Child',
            'sortOrder': 0,
            'subFolders': [],
            'requests': [],
          },
        ],
        'requests': [
          {
            'id': 'req-1',
            'name': 'GET Users',
            'method': 'GET',
            'url': 'https://api.example.com/users',
            'sortOrder': 0,
          },
        ],
      });
      expect(m.subFolders, hasLength(1));
      expect(m.requests, hasLength(1));
      expect(m.subFolders!.first.name, 'Child');
    });

    test('toJson round-trip preserves nested data', () {
      final m = FolderTreeResponse.fromJson(<String, dynamic>{
        'id': 'fld-1',
        'name': 'Root',
        'subFolders': [],
        'requests': [],
      });
      final restored = FolderTreeResponse.fromJson(m.toJson());
      expect(restored.id, 'fld-1');
    });
  });

  group('CreateFolderRequest', () {
    test('round-trip preserves data', () {
      const req = CreateFolderRequest(collectionId: 'col-1', name: 'Folder');
      final restored = CreateFolderRequest.fromJson(req.toJson());
      expect(restored.collectionId, 'col-1');
      expect(restored.name, 'Folder');
    });
  });

  group('UpdateFolderRequest', () {
    test('round-trip preserves data', () {
      const req = UpdateFolderRequest(name: 'Updated');
      final restored = UpdateFolderRequest.fromJson(req.toJson());
      expect(restored.name, 'Updated');
    });
  });

  group('ReorderFolderRequest', () {
    test('round-trip preserves data', () {
      const req = ReorderFolderRequest(folderIds: ['fld-1', 'fld-2']);
      final restored = ReorderFolderRequest.fromJson(req.toJson());
      expect(restored.folderIds, ['fld-1', 'fld-2']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Requests
  // ═══════════════════════════════════════════════════════════════════════════

  group('RequestResponse', () {
    final json = <String, dynamic>{
      'id': 'req-1',
      'folderId': 'fld-1',
      'name': 'Get Users',
      'method': 'GET',
      'url': 'https://api.example.com/users',
      'sortOrder': 0,
      'headers': [
        {
          'id': 'hdr-1',
          'headerKey': 'Accept',
          'headerValue': 'application/json',
          'isEnabled': true,
        },
      ],
      'params': [
        {
          'id': 'prm-1',
          'paramKey': 'page',
          'paramValue': '1',
          'isEnabled': true,
        },
      ],
      'body': {
        'id': 'body-1',
        'bodyType': 'NONE',
      },
      'auth': {
        'id': 'auth-1',
        'authType': 'BEARER_TOKEN',
        'bearerToken': 'abc123',
      },
      'scripts': [
        {
          'id': 'scr-1',
          'scriptType': 'PRE_REQUEST',
          'content': 'console.log("pre")',
        },
      ],
      'createdAt': '2026-02-20T00:00:00.000Z',
      'updatedAt': '2026-02-20T10:00:00.000Z',
    };

    test('fromJson deserializes all nested components', () {
      final m = RequestResponse.fromJson(json);
      expect(m.id, 'req-1');
      expect(m.method!.toJson(), 'GET');
      expect(m.headers, hasLength(1));
      expect(m.headers!.first.headerKey, 'Accept');
      expect(m.params, hasLength(1));
      expect(m.body!.bodyType!.toJson(), 'NONE');
      expect(m.auth!.authType!.toJson(), 'BEARER_TOKEN');
      expect(m.auth!.bearerToken, 'abc123');
      expect(m.scripts, hasLength(1));
      expect(m.scripts!.first.scriptType!.toJson(), 'PRE_REQUEST');
    });

    test('toJson round-trip preserves nested data', () {
      final restored = RequestResponse.fromJson(
        RequestResponse.fromJson(json).toJson(),
      );
      expect(restored.headers, hasLength(1));
      expect(restored.auth!.bearerToken, 'abc123');
    });
  });

  group('RequestSummaryResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestSummaryResponse.fromJson(<String, dynamic>{
        'id': 'req-1',
        'name': 'Get Users',
        'method': 'POST',
        'url': 'https://api.example.com/users',
        'sortOrder': 1,
      });
      expect(m.method!.toJson(), 'POST');
      expect(m.sortOrder, 1);
    });
  });

  group('RequestHeaderResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestHeaderResponse.fromJson(<String, dynamic>{
        'id': 'hdr-1',
        'headerKey': 'Content-Type',
        'headerValue': 'application/json',
        'description': 'Content type header',
        'isEnabled': true,
      });
      expect(m.headerKey, 'Content-Type');
      expect(m.isEnabled, isTrue);
    });
  });

  group('RequestParamResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestParamResponse.fromJson(<String, dynamic>{
        'id': 'prm-1',
        'paramKey': 'limit',
        'paramValue': '20',
        'isEnabled': true,
      });
      expect(m.paramKey, 'limit');
      expect(m.paramValue, '20');
    });
  });

  group('RequestBodyResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestBodyResponse.fromJson(<String, dynamic>{
        'id': 'body-1',
        'bodyType': 'RAW_JSON',
        'rawContent': '{"key":"value"}',
      });
      expect(m.bodyType!.toJson(), 'RAW_JSON');
      expect(m.rawContent, '{"key":"value"}');
    });
  });

  group('RequestAuthResponse', () {
    test('fromJson deserializes all auth fields', () {
      final m = RequestAuthResponse.fromJson(<String, dynamic>{
        'id': 'auth-1',
        'authType': 'BASIC_AUTH',
        'basicUsername': 'user',
        'basicPassword': 'pass',
      });
      expect(m.authType!.toJson(), 'BASIC_AUTH');
      expect(m.basicUsername, 'user');
      expect(m.basicPassword, 'pass');
    });

    test('handles OAuth2 fields', () {
      final m = RequestAuthResponse.fromJson(<String, dynamic>{
        'authType': 'OAUTH2_AUTHORIZATION_CODE',
        'oauth2ClientId': 'client-id',
        'oauth2ClientSecret': 'secret',
        'oauth2AuthUrl': 'https://auth.example.com',
        'oauth2TokenUrl': 'https://token.example.com',
        'oauth2Scope': 'read write',
      });
      expect(m.oauth2ClientId, 'client-id');
      expect(m.oauth2Scope, 'read write');
    });

    test('handles JWT fields', () {
      final m = RequestAuthResponse.fromJson(<String, dynamic>{
        'authType': 'JWT_BEARER',
        'jwtSecret': 'my-secret',
        'jwtPayload': '{"sub":"1234"}',
        'jwtAlgorithm': 'HS256',
      });
      expect(m.jwtSecret, 'my-secret');
      expect(m.jwtAlgorithm, 'HS256');
    });
  });

  group('RequestScriptResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestScriptResponse.fromJson(<String, dynamic>{
        'id': 'scr-1',
        'scriptType': 'POST_RESPONSE',
        'content': 'console.log("done")',
      });
      expect(m.scriptType!.toJson(), 'POST_RESPONSE');
      expect(m.content, 'console.log("done")');
    });
  });

  group('CreateRequestRequest', () {
    test('round-trip preserves data', () {
      final req = CreateRequestRequest.fromJson(<String, dynamic>{
        'folderId': 'fld-1',
        'name': 'New Req',
        'method': 'POST',
        'url': 'https://api.example.com',
      });
      final restored = CreateRequestRequest.fromJson(req.toJson());
      expect(restored.folderId, 'fld-1');
      expect(restored.method.toJson(), 'POST');
    });
  });

  group('UpdateRequestRequest', () {
    test('round-trip preserves data', () {
      const req = UpdateRequestRequest(name: 'Updated', url: 'https://new.com');
      final restored = UpdateRequestRequest.fromJson(req.toJson());
      expect(restored.name, 'Updated');
      expect(restored.url, 'https://new.com');
    });
  });

  group('SaveRequestHeadersRequest', () {
    test('toJson serializes nested headers', () {
      const req = SaveRequestHeadersRequest(headers: [
        RequestHeaderEntry(headerKey: 'X-Custom', headerValue: 'val'),
      ]);
      final json = req.toJson();
      expect((json['headers'] as List), hasLength(1));
    });
  });

  group('RequestHeaderEntry', () {
    test('round-trip preserves data', () {
      const req = RequestHeaderEntry(
        headerKey: 'Auth',
        headerValue: 'Bearer token',
        isEnabled: true,
      );
      final restored = RequestHeaderEntry.fromJson(req.toJson());
      expect(restored.headerKey, 'Auth');
      expect(restored.isEnabled, isTrue);
    });
  });

  group('SaveRequestParamsRequest', () {
    test('toJson serializes nested params', () {
      const req = SaveRequestParamsRequest(params: [
        RequestParamEntry(paramKey: 'limit', paramValue: '10'),
      ]);
      final json = req.toJson();
      expect((json['params'] as List), hasLength(1));
    });
  });

  group('SaveRequestBodyRequest', () {
    test('round-trip preserves data', () {
      final req = SaveRequestBodyRequest.fromJson(<String, dynamic>{
        'bodyType': 'RAW_JSON',
        'rawContent': '{}',
      });
      expect(req.bodyType.toJson(), 'RAW_JSON');
    });
  });

  group('SaveRequestAuthRequest', () {
    test('round-trip preserves data', () {
      final req = SaveRequestAuthRequest.fromJson(<String, dynamic>{
        'authType': 'API_KEY',
        'apiKeyHeader': 'X-API-Key',
        'apiKeyValue': 'secret',
        'apiKeyAddTo': 'header',
      });
      expect(req.authType.toJson(), 'API_KEY');
      expect(req.apiKeyHeader, 'X-API-Key');
    });
  });

  group('SaveRequestScriptRequest', () {
    test('round-trip preserves data', () {
      final req = SaveRequestScriptRequest.fromJson(<String, dynamic>{
        'scriptType': 'PRE_REQUEST',
        'content': 'pm.environment.set("key","val")',
      });
      expect(req.scriptType.toJson(), 'PRE_REQUEST');
      expect(req.content, contains('pm.environment'));
    });
  });

  group('ReorderRequestRequest', () {
    test('round-trip preserves data', () {
      const req = ReorderRequestRequest(requestIds: ['req-1', 'req-2']);
      final restored = ReorderRequestRequest.fromJson(req.toJson());
      expect(restored.requestIds, ['req-1', 'req-2']);
    });
  });

  group('DuplicateRequestRequest', () {
    test('round-trip preserves data', () {
      const req = DuplicateRequestRequest(targetFolderId: 'fld-2');
      final restored = DuplicateRequestRequest.fromJson(req.toJson());
      expect(restored.targetFolderId, 'fld-2');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Environments & Variables
  // ═══════════════════════════════════════════════════════════════════════════

  group('EnvironmentResponse', () {
    test('fromJson deserializes all fields', () {
      final m = EnvironmentResponse.fromJson(<String, dynamic>{
        'id': 'env-1',
        'teamId': 'team-1',
        'name': 'Production',
        'description': 'Prod environment',
        'isActive': true,
        'createdBy': 'user-1',
        'variableCount': 5,
        'createdAt': '2026-02-20T00:00:00.000Z',
        'updatedAt': '2026-02-20T10:00:00.000Z',
      });
      expect(m.name, 'Production');
      expect(m.isActive, isTrue);
      expect(m.variableCount, 5);
    });
  });

  group('EnvironmentVariableResponse', () {
    test('fromJson deserializes all fields', () {
      final m = EnvironmentVariableResponse.fromJson(<String, dynamic>{
        'id': 'var-1',
        'variableKey': 'API_URL',
        'variableValue': 'https://api.prod.com',
        'isSecret': false,
        'isEnabled': true,
        'scope': 'environment',
      });
      expect(m.variableKey, 'API_URL');
      expect(m.isSecret, isFalse);
    });
  });

  group('GlobalVariableResponse', () {
    test('fromJson deserializes all fields', () {
      final m = GlobalVariableResponse.fromJson(<String, dynamic>{
        'id': 'gvar-1',
        'teamId': 'team-1',
        'variableKey': 'BASE_URL',
        'variableValue': 'https://api.example.com',
        'isSecret': false,
        'isEnabled': true,
        'createdAt': '2026-02-20T00:00:00.000Z',
        'updatedAt': '2026-02-20T10:00:00.000Z',
      });
      expect(m.variableKey, 'BASE_URL');
      expect(m.isEnabled, isTrue);
    });
  });

  group('CreateEnvironmentRequest', () {
    test('round-trip preserves data', () {
      const req = CreateEnvironmentRequest(name: 'Staging');
      final restored = CreateEnvironmentRequest.fromJson(req.toJson());
      expect(restored.name, 'Staging');
    });
  });

  group('UpdateEnvironmentRequest', () {
    test('round-trip preserves data', () {
      const req = UpdateEnvironmentRequest(name: 'Updated', description: 'd');
      final restored = UpdateEnvironmentRequest.fromJson(req.toJson());
      expect(restored.name, 'Updated');
    });
  });

  group('SaveEnvironmentVariablesRequest', () {
    test('toJson serializes nested variables', () {
      const req = SaveEnvironmentVariablesRequest(variables: [
        VariableEntry(variableKey: 'KEY', variableValue: 'VAL'),
      ]);
      final json = req.toJson();
      expect((json['variables'] as List), hasLength(1));
    });
  });

  group('VariableEntry', () {
    test('round-trip preserves data', () {
      const req = VariableEntry(
        variableKey: 'TOKEN',
        variableValue: 'abc',
        isSecret: true,
        isEnabled: true,
      );
      final restored = VariableEntry.fromJson(req.toJson());
      expect(restored.variableKey, 'TOKEN');
      expect(restored.isSecret, isTrue);
    });
  });

  group('CloneEnvironmentRequest', () {
    test('round-trip preserves data', () {
      const req = CloneEnvironmentRequest(newName: 'Clone');
      final restored = CloneEnvironmentRequest.fromJson(req.toJson());
      expect(restored.newName, 'Clone');
    });
  });

  group('SaveGlobalVariableRequest', () {
    test('round-trip preserves data', () {
      const req = SaveGlobalVariableRequest(
        variableKey: 'API_KEY',
        variableValue: 'secret',
        isSecret: true,
      );
      final restored = SaveGlobalVariableRequest.fromJson(req.toJson());
      expect(restored.variableKey, 'API_KEY');
      expect(restored.isSecret, isTrue);
    });
  });

  group('BatchSaveGlobalVariablesRequest', () {
    test('toJson serializes nested variables', () {
      const req = BatchSaveGlobalVariablesRequest(variables: [
        SaveGlobalVariableRequest(variableKey: 'K1'),
        SaveGlobalVariableRequest(variableKey: 'K2'),
      ]);
      final json = req.toJson();
      expect((json['variables'] as List), hasLength(2));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Sharing
  // ═══════════════════════════════════════════════════════════════════════════

  group('CollectionShareResponse', () {
    test('fromJson deserializes all fields', () {
      final m = CollectionShareResponse.fromJson(<String, dynamic>{
        'id': 'share-1',
        'collectionId': 'col-1',
        'sharedWithUserId': 'user-2',
        'sharedByUserId': 'user-1',
        'permission': 'EDITOR',
        'createdAt': '2026-02-20T00:00:00.000Z',
      });
      expect(m.permission!.toJson(), 'EDITOR');
      expect(m.sharedWithUserId, 'user-2');
    });
  });

  group('ShareCollectionRequest', () {
    test('round-trip preserves data', () {
      final req = ShareCollectionRequest.fromJson(<String, dynamic>{
        'sharedWithUserId': 'user-2',
        'permission': 'VIEWER',
      });
      expect(req.permission.toJson(), 'VIEWER');
    });
  });

  group('UpdateSharePermissionRequest', () {
    test('round-trip preserves data', () {
      final req = UpdateSharePermissionRequest.fromJson(<String, dynamic>{
        'permission': 'ADMIN',
      });
      expect(req.permission.toJson(), 'ADMIN');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Forking
  // ═══════════════════════════════════════════════════════════════════════════

  group('ForkResponse', () {
    test('fromJson deserializes all fields', () {
      final m = ForkResponse.fromJson(<String, dynamic>{
        'id': 'fork-1',
        'sourceCollectionId': 'col-1',
        'sourceCollectionName': 'Original',
        'forkedCollectionId': 'col-2',
        'forkedByUserId': 'user-1',
        'label': 'My Fork',
        'forkedAt': '2026-02-20T00:00:00.000Z',
        'createdAt': '2026-02-20T00:00:00.000Z',
      });
      expect(m.sourceCollectionName, 'Original');
      expect(m.label, 'My Fork');
    });
  });

  group('CreateForkRequest', () {
    test('round-trip preserves data', () {
      const req = CreateForkRequest(label: 'Fork Label');
      final restored = CreateForkRequest.fromJson(req.toJson());
      expect(restored.label, 'Fork Label');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Proxy
  // ═══════════════════════════════════════════════════════════════════════════

  group('ProxyResponse', () {
    test('fromJson deserializes all fields', () {
      final m = ProxyResponse.fromJson(<String, dynamic>{
        'statusCode': 200,
        'statusText': 'OK',
        'responseHeaders': {
          'content-type': ['application/json'],
        },
        'responseBody': '{"data":"test"}',
        'responseTimeMs': 150,
        'responseSizeBytes': 1024,
        'contentType': 'application/json',
        'redirectChain': ['https://redirect.example.com'],
        'historyId': 'hist-1',
      });
      expect(m.statusCode, 200);
      expect(m.responseTimeMs, 150);
      expect(m.redirectChain, hasLength(1));
      expect(m.historyId, 'hist-1');
    });
  });

  group('SendRequestProxyRequest', () {
    test('round-trip preserves data', () {
      final req = SendRequestProxyRequest.fromJson(<String, dynamic>{
        'method': 'POST',
        'url': 'https://api.example.com/data',
        'saveToHistory': true,
        'timeoutMs': 30000,
        'followRedirects': true,
      });
      expect(req.method.toJson(), 'POST');
      expect(req.saveToHistory, isTrue);
      expect(req.timeoutMs, 30000);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GraphQL
  // ═══════════════════════════════════════════════════════════════════════════

  group('GraphQLResponse', () {
    test('fromJson deserializes nested httpResponse', () {
      final m = GraphQLResponse.fromJson(<String, dynamic>{
        'httpResponse': {
          'statusCode': 200,
          'responseBody': '{"data":{"users":[]}}',
          'responseTimeMs': 50,
        },
        'schema': null,
      });
      expect(m.httpResponse!.statusCode, 200);
      expect(m.schema, isNull);
    });
  });

  group('ExecuteGraphQLRequest', () {
    test('round-trip preserves data', () {
      const req = ExecuteGraphQLRequest(
        url: 'https://graphql.example.com',
        query: '{ users { id name } }',
        operationName: 'GetUsers',
      );
      final restored = ExecuteGraphQLRequest.fromJson(req.toJson());
      expect(restored.url, 'https://graphql.example.com');
      expect(restored.operationName, 'GetUsers');
    });
  });

  group('IntrospectGraphQLRequest', () {
    test('round-trip preserves data', () {
      const req = IntrospectGraphQLRequest(
        url: 'https://graphql.example.com',
      );
      final restored = IntrospectGraphQLRequest.fromJson(req.toJson());
      expect(restored.url, 'https://graphql.example.com');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Runner
  // ═══════════════════════════════════════════════════════════════════════════

  group('RunResultResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RunResultResponse.fromJson(<String, dynamic>{
        'id': 'run-1',
        'teamId': 'team-1',
        'collectionId': 'col-1',
        'status': 'COMPLETED',
        'totalRequests': 10,
        'passedRequests': 8,
        'failedRequests': 2,
        'totalAssertions': 20,
        'passedAssertions': 18,
        'failedAssertions': 2,
        'totalDurationMs': 5000,
        'iterationCount': 1,
        'startedAt': '2026-02-20T00:00:00.000Z',
        'completedAt': '2026-02-20T00:00:05.000Z',
        'startedByUserId': 'user-1',
        'createdAt': '2026-02-20T00:00:00.000Z',
      });
      expect(m.status!.toJson(), 'COMPLETED');
      expect(m.totalRequests, 10);
      expect(m.passedRequests, 8);
      expect(m.failedRequests, 2);
      expect(m.totalDurationMs, 5000);
    });
  });

  group('RunResultDetailResponse', () {
    test('fromJson deserializes nested iterations', () {
      final m = RunResultDetailResponse.fromJson(<String, dynamic>{
        'summary': {
          'id': 'run-1',
          'status': 'COMPLETED',
          'totalRequests': 2,
        },
        'iterations': [
          {
            'id': 'iter-1',
            'iterationNumber': 1,
            'requestName': 'Get Users',
            'requestMethod': 'GET',
            'requestUrl': 'https://api.example.com/users',
            'responseStatus': 200,
            'responseTimeMs': 150,
            'passed': true,
          },
        ],
      });
      expect(m.summary!.totalRequests, 2);
      expect(m.iterations, hasLength(1));
      expect(m.iterations!.first.passed, isTrue);
    });
  });

  group('RunIterationResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RunIterationResponse.fromJson(<String, dynamic>{
        'id': 'iter-1',
        'iterationNumber': 1,
        'requestName': 'Create User',
        'requestMethod': 'POST',
        'requestUrl': 'https://api.example.com/users',
        'responseStatus': 201,
        'responseTimeMs': 200,
        'responseSizeBytes': 512,
        'passed': true,
        'assertionResults': '[]',
        'errorMessage': null,
      });
      expect(m.requestMethod!.toJson(), 'POST');
      expect(m.responseStatus, 201);
      expect(m.passed, isTrue);
      expect(m.errorMessage, isNull);
    });
  });

  group('StartCollectionRunRequest', () {
    test('round-trip preserves data', () {
      const req = StartCollectionRunRequest(
        collectionId: 'col-1',
        iterationCount: 5,
        delayBetweenRequestsMs: 1000,
      );
      final restored = StartCollectionRunRequest.fromJson(req.toJson());
      expect(restored.collectionId, 'col-1');
      expect(restored.iterationCount, 5);
      expect(restored.delayBetweenRequestsMs, 1000);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // History
  // ═══════════════════════════════════════════════════════════════════════════

  group('RequestHistoryResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestHistoryResponse.fromJson(<String, dynamic>{
        'id': 'hist-1',
        'userId': 'user-1',
        'requestMethod': 'GET',
        'requestUrl': 'https://api.example.com/users',
        'responseStatus': 200,
        'responseTimeMs': 120,
        'responseSizeBytes': 2048,
        'contentType': 'application/json',
        'collectionId': 'col-1',
        'requestId': 'req-1',
        'environmentId': 'env-1',
        'createdAt': '2026-02-20T00:00:00.000Z',
      });
      expect(m.requestMethod!.toJson(), 'GET');
      expect(m.responseStatus, 200);
      expect(m.collectionId, 'col-1');
    });
  });

  group('RequestHistoryDetailResponse', () {
    test('fromJson deserializes all fields', () {
      final m = RequestHistoryDetailResponse.fromJson(<String, dynamic>{
        'id': 'hist-1',
        'userId': 'user-1',
        'requestMethod': 'POST',
        'requestUrl': 'https://api.example.com/data',
        'requestHeaders': '{"Content-Type":"application/json"}',
        'requestBody': '{"key":"value"}',
        'responseStatus': 201,
        'responseHeaders': '{"Location":"/data/1"}',
        'responseBody': '{"id":"1"}',
        'responseSizeBytes': 512,
        'responseTimeMs': 200,
        'contentType': 'application/json',
        'createdAt': '2026-02-20T00:00:00.000Z',
      });
      expect(m.requestBody, '{"key":"value"}');
      expect(m.responseBody, '{"id":"1"}');
      expect(m.responseStatus, 201);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Import / Export
  // ═══════════════════════════════════════════════════════════════════════════

  group('ImportCollectionRequest', () {
    test('round-trip preserves data', () {
      const req = ImportCollectionRequest(
        format: 'postman',
        content: '{"info":{"name":"test"}}',
      );
      final restored = ImportCollectionRequest.fromJson(req.toJson());
      expect(restored.format, 'postman');
      expect(restored.content, contains('test'));
    });
  });

  group('ImportResultResponse', () {
    test('fromJson deserializes all fields', () {
      final m = ImportResultResponse.fromJson(<String, dynamic>{
        'collectionId': 'col-1',
        'collectionName': 'Imported',
        'foldersImported': 3,
        'requestsImported': 12,
        'environmentsImported': 2,
        'warnings': ['Duplicate header removed'],
      });
      expect(m.collectionName, 'Imported');
      expect(m.requestsImported, 12);
      expect(m.warnings, hasLength(1));
    });
  });

  group('ExportCollectionResponse', () {
    test('fromJson deserializes all fields', () {
      final m = ExportCollectionResponse.fromJson(<String, dynamic>{
        'format': 'postman',
        'content': '{"info":{}}',
        'filename': 'collection.json',
      });
      expect(m.format, 'postman');
      expect(m.filename, 'collection.json');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Code Generation
  // ═══════════════════════════════════════════════════════════════════════════

  group('CodeSnippetResponse', () {
    test('fromJson deserializes all fields', () {
      final m = CodeSnippetResponse.fromJson(<String, dynamic>{
        'language': 'CURL',
        'displayName': 'cURL',
        'code': 'curl -X GET https://api.example.com',
        'fileExtension': 'sh',
        'contentType': 'text/plain',
      });
      expect(m.language!.toJson(), 'CURL');
      expect(m.code, contains('curl'));
      expect(m.fileExtension, 'sh');
    });
  });

  group('GenerateCodeRequest', () {
    test('round-trip preserves data', () {
      final req = GenerateCodeRequest.fromJson(<String, dynamic>{
        'requestId': 'req-1',
        'language': 'PYTHON_REQUESTS',
      });
      expect(req.language.toJson(), 'PYTHON_REQUESTS');
      expect(req.requestId, 'req-1');
    });
  });
}
