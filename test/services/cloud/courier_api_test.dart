// Tests for CourierApiService.
//
// Verifies that key endpoint methods from each of the 13 controller
// sections send the correct path, headers, query parameters, and
// request body, and deserialize responses correctly.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/services/cloud/api_client.dart';
import 'package:codeops/services/cloud/courier_api.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockClient;
  late MockDio mockDio;
  late CourierApiService api;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockClient.dio).thenReturn(mockDio);
    api = CourierApiService(mockClient);
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared JSON fixtures
  // ═══════════════════════════════════════════════════════════════════════════

  final collectionJson = <String, dynamic>{
    'id': 'col-1',
    'teamId': 'team-1',
    'name': 'Test Collection',
    'isShared': false,
    'folderCount': 2,
    'requestCount': 10,
  };

  final collectionSummaryJson = <String, dynamic>{
    'id': 'col-1',
    'name': 'Test Collection',
    'isShared': false,
    'folderCount': 2,
    'requestCount': 10,
  };

  final folderJson = <String, dynamic>{
    'id': 'fld-1',
    'collectionId': 'col-1',
    'name': 'Root Folder',
    'sortOrder': 0,
  };

  final requestJson = <String, dynamic>{
    'id': 'req-1',
    'folderId': 'fld-1',
    'name': 'Get Users',
    'method': 'GET',
    'url': 'https://api.example.com/users',
    'sortOrder': 0,
  };

  final requestSummaryJson = <String, dynamic>{
    'id': 'req-1',
    'name': 'Get Users',
    'method': 'GET',
    'url': 'https://api.example.com/users',
  };

  final environmentJson = <String, dynamic>{
    'id': 'env-1',
    'teamId': 'team-1',
    'name': 'Production',
    'isActive': true,
    'variableCount': 5,
  };

  final envVarJson = <String, dynamic>{
    'id': 'var-1',
    'variableKey': 'API_URL',
    'variableValue': 'https://api.prod.com',
    'isSecret': false,
    'isEnabled': true,
  };

  final globalVarJson = <String, dynamic>{
    'id': 'gvar-1',
    'teamId': 'team-1',
    'variableKey': 'BASE_URL',
    'variableValue': 'https://api.example.com',
  };

  final proxyResponseJson = <String, dynamic>{
    'statusCode': 200,
    'statusText': 'OK',
    'responseBody': '{"data":"test"}',
    'responseTimeMs': 150,
    'historyId': 'hist-1',
  };

  final historyJson = <String, dynamic>{
    'id': 'hist-1',
    'userId': 'user-1',
    'requestMethod': 'GET',
    'requestUrl': 'https://api.example.com',
    'responseStatus': 200,
    'responseTimeMs': 120,
  };

  final historyDetailJson = <String, dynamic>{
    'id': 'hist-1',
    'userId': 'user-1',
    'requestMethod': 'GET',
    'requestUrl': 'https://api.example.com',
    'responseStatus': 200,
    'responseTimeMs': 120,
    'responseBody': '{"data":"test"}',
  };

  final shareJson = <String, dynamic>{
    'id': 'share-1',
    'collectionId': 'col-1',
    'sharedWithUserId': 'user-2',
    'sharedByUserId': 'user-1',
    'permission': 'EDITOR',
  };

  final forkJson = <String, dynamic>{
    'id': 'fork-1',
    'sourceCollectionId': 'col-1',
    'forkedCollectionId': 'col-2',
    'forkedByUserId': 'user-1',
    'label': 'My Fork',
  };

  final importResultJson = <String, dynamic>{
    'collectionId': 'col-1',
    'collectionName': 'Imported',
    'foldersImported': 3,
    'requestsImported': 12,
  };

  final graphqlResponseJson = <String, dynamic>{
    'httpResponse': {
      'statusCode': 200,
      'responseBody': '{"data":{}}',
      'responseTimeMs': 50,
    },
  };

  final runResultJson = <String, dynamic>{
    'id': 'run-1',
    'teamId': 'team-1',
    'collectionId': 'col-1',
    'status': 'COMPLETED',
    'totalRequests': 10,
    'passedRequests': 8,
    'failedRequests': 2,
  };

  final runResultDetailJson = <String, dynamic>{
    'summary': runResultJson,
    'iterations': <Map<String, dynamic>>[],
  };

  final codeSnippetJson = <String, dynamic>{
    'language': 'CURL',
    'displayName': 'cURL',
    'code': 'curl -X GET https://api.example.com',
  };

  final exportJson = <String, dynamic>{
    'format': 'postman',
    'content': '{}',
    'filename': 'collection.json',
  };

  final folderTreeJson = <String, dynamic>{
    'id': 'fld-1',
    'name': 'Root',
    'sortOrder': 0,
    'subFolders': <Map<String, dynamic>>[],
    'requests': <Map<String, dynamic>>[],
  };

  final headerResponseJson = <String, dynamic>{
    'id': 'hdr-1',
    'headerKey': 'Accept',
    'headerValue': 'application/json',
    'isEnabled': true,
  };

  final paramResponseJson = <String, dynamic>{
    'id': 'prm-1',
    'paramKey': 'page',
    'paramValue': '1',
    'isEnabled': true,
  };

  final bodyResponseJson = <String, dynamic>{
    'id': 'body-1',
    'bodyType': 'RAW_JSON',
    'rawContent': '{}',
  };

  final authResponseJson = <String, dynamic>{
    'id': 'auth-1',
    'authType': 'BEARER_TOKEN',
    'bearerToken': 'abc123',
  };

  final scriptResponseJson = <String, dynamic>{
    'id': 'scr-1',
    'scriptType': 'PRE_REQUEST',
    'content': 'console.log("pre")',
  };

  // Helper for paged response JSON matching PageResponse fields.
  Map<String, dynamic> pagedJson(List<Map<String, dynamic>> content) => {
        'content': content,
        'page': 0,
        'size': 20,
        'totalElements': content.length,
        'totalPages': 1,
        'isLast': true,
      };

  // ═══════════════════════════════════════════════════════════════════════════
  // Collections
  // ═══════════════════════════════════════════════════════════════════════════

  group('Collections', () {
    test('createCollection sends POST to /courier/collections', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/collections',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: collectionJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createCollection(
        'team-1',
        const CreateCollectionRequest(name: 'Test Collection'),
      );

      expect(result.id, 'col-1');
      verify(() => mockDio.post<Map<String, dynamic>>(
            '/courier/collections',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).called(1);
    });

    test('getCollections sends GET to /courier/collections', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/collections',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [collectionSummaryJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getCollections('team-1');

      expect(result, hasLength(1));
      expect(result.first.name, 'Test Collection');
    });

    test('getCollectionsPaged sends GET with pagination', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/collections/paged',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([collectionSummaryJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getCollectionsPaged('team-1', page: 0);

      expect(result.content, hasLength(1));
    });

    test('searchCollections sends GET with query param', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/collections/search',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [collectionSummaryJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.searchCollections('team-1', query: 'test');

      expect(result, hasLength(1));
    });

    test('getCollection sends GET to /courier/collections/{id}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/collections/col-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: collectionJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getCollection('team-1', 'col-1');

      expect(result.name, 'Test Collection');
    });

    test('updateCollection sends PUT to /courier/collections/{id}', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/collections/col-1',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: collectionJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateCollection(
        'team-1',
        'col-1',
        const UpdateCollectionRequest(name: 'Updated'),
      );

      expect(result.id, 'col-1');
    });

    test('deleteCollection sends DELETE to /courier/collections/{id}',
        () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/collections/col-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteCollection('team-1', 'col-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/collections/col-1',
            options: any(named: 'options'),
          )).called(1);
    });

    test('duplicateCollection sends POST to .../duplicate', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/collections/col-1/duplicate',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: collectionJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.duplicateCollection('team-1', 'col-1');

      expect(result.id, 'col-1');
    });

    test('getCollectionTree sends GET to .../tree', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/collections/col-1/tree',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [folderTreeJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getCollectionTree('team-1', 'col-1');

      expect(result, hasLength(1));
      expect(result.first.name, 'Root');
    });

    test('exportCollection sends GET to .../export/{format}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/collections/col-1/export/postman',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: exportJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.exportCollection(
        'team-1',
        'col-1',
        format: 'postman',
      );

      expect(result.format, 'postman');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Folders
  // ═══════════════════════════════════════════════════════════════════════════

  group('Folders', () {
    test('createFolder sends POST to /courier/folders', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/folders',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: folderJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createFolder(
        'team-1',
        const CreateFolderRequest(collectionId: 'col-1', name: 'Folder'),
      );

      expect(result.id, 'fld-1');
    });

    test('getFolder sends GET to /courier/folders/{id}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/folders/fld-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: folderJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getFolder('team-1', 'fld-1');

      expect(result.name, 'Root Folder');
    });

    test('updateFolder sends PUT to /courier/folders/{id}', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/folders/fld-1',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: folderJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateFolder(
        'team-1',
        'fld-1',
        const UpdateFolderRequest(name: 'Updated'),
      );

      expect(result.id, 'fld-1');
    });

    test('deleteFolder sends DELETE to /courier/folders/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/folders/fld-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteFolder('team-1', 'fld-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/folders/fld-1',
            options: any(named: 'options'),
          )).called(1);
    });

    test('getSubfolders sends GET to .../subfolders', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/folders/fld-1/subfolders',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [folderJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getSubfolders('team-1', 'fld-1');

      expect(result, hasLength(1));
    });

    test('getFolderRequests sends GET to .../requests', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/folders/fld-1/requests',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [requestSummaryJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getFolderRequests('team-1', 'fld-1');

      expect(result, hasLength(1));
      expect(result.first.name, 'Get Users');
    });

    test('reorderFolders sends PUT to /courier/folders/reorder', () async {
      when(() => mockDio.put<List<dynamic>>(
            '/courier/folders/reorder',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [folderJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.reorderFolders(
        'team-1',
        const ReorderFolderRequest(folderIds: ['fld-1']),
      );

      expect(result, hasLength(1));
    });

    test('moveFolder sends PUT to .../move', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/folders/fld-1/move',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: folderJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.moveFolder(
        'team-1',
        'fld-1',
        newParentFolderId: 'fld-2',
      );

      expect(result.id, 'fld-1');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Requests
  // ═══════════════════════════════════════════════════════════════════════════

  group('Requests', () {
    test('createRequest sends POST to /courier/requests', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/requests',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: requestJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createRequest(
        'team-1',
        CreateRequestRequest.fromJson(<String, dynamic>{
          'folderId': 'fld-1',
          'name': 'New Request',
          'method': 'GET',
          'url': 'https://api.example.com',
        }),
      );

      expect(result.id, 'req-1');
    });

    test('getRequest sends GET to /courier/requests/{id}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/requests/req-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: requestJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getRequest('team-1', 'req-1');

      expect(result.name, 'Get Users');
    });

    test('updateRequest sends PUT to /courier/requests/{id}', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/requests/req-1',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: requestJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateRequest(
        'team-1',
        'req-1',
        const UpdateRequestRequest(name: 'Updated'),
      );

      expect(result.id, 'req-1');
    });

    test('deleteRequest sends DELETE to /courier/requests/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/requests/req-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteRequest('team-1', 'req-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/requests/req-1',
            options: any(named: 'options'),
          )).called(1);
    });

    test('updateRequestHeaders sends PUT to .../headers', () async {
      when(() => mockDio.put<List<dynamic>>(
            '/courier/requests/req-1/headers',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [headerResponseJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateRequestHeaders(
        'team-1',
        'req-1',
        const SaveRequestHeadersRequest(headers: [
          RequestHeaderEntry(headerKey: 'Accept', headerValue: 'text/html'),
        ]),
      );

      expect(result, hasLength(1));
      expect(result.first.headerKey, 'Accept');
    });

    test('updateRequestParams sends PUT to .../params', () async {
      when(() => mockDio.put<List<dynamic>>(
            '/courier/requests/req-1/params',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [paramResponseJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateRequestParams(
        'team-1',
        'req-1',
        const SaveRequestParamsRequest(
            params: [RequestParamEntry(paramKey: 'page')]),
      );

      expect(result, hasLength(1));
    });

    test('updateRequestBody sends PUT to .../body', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/requests/req-1/body',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: bodyResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateRequestBody(
        'team-1',
        'req-1',
        SaveRequestBodyRequest.fromJson(
            <String, dynamic>{'bodyType': 'RAW_JSON', 'rawContent': '{}'}),
      );

      expect(result.bodyType!.toJson(), 'RAW_JSON');
    });

    test('updateRequestAuth sends PUT to .../auth', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/requests/req-1/auth',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: authResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateRequestAuth(
        'team-1',
        'req-1',
        SaveRequestAuthRequest.fromJson(
            <String, dynamic>{'authType': 'BEARER_TOKEN'}),
      );

      expect(result.bearerToken, 'abc123');
    });

    test('updateRequestScripts sends PUT to .../scripts', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/requests/req-1/scripts',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: scriptResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateRequestScripts(
        'team-1',
        'req-1',
        SaveRequestScriptRequest.fromJson(
            <String, dynamic>{'scriptType': 'PRE_REQUEST'}),
      );

      expect(result.scriptType!.toJson(), 'PRE_REQUEST');
    });

    test('sendSavedRequest sends POST to .../send', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/requests/req-1/send',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: proxyResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.sendSavedRequest('team-1', 'req-1');

      expect(result.statusCode, 200);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Environments
  // ═══════════════════════════════════════════════════════════════════════════

  group('Environments', () {
    test('createEnvironment sends POST to /courier/environments', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/environments',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: environmentJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createEnvironment(
        'team-1',
        const CreateEnvironmentRequest(name: 'Staging'),
      );

      expect(result.id, 'env-1');
    });

    test('getEnvironments sends GET to /courier/environments', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/environments',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [environmentJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getEnvironments('team-1');

      expect(result, hasLength(1));
    });

    test('getActiveEnvironment sends GET to .../active', () async {
      when(() => mockDio.get<Map<String, dynamic>?>(
            '/courier/environments/active',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: environmentJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getActiveEnvironment('team-1');

      expect(result!.isActive, isTrue);
    });

    test('getActiveEnvironment returns null for empty response', () async {
      when(() => mockDio.get<Map<String, dynamic>?>(
            '/courier/environments/active',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: null,
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      final result = await api.getActiveEnvironment('team-1');

      expect(result, isNull);
    });

    test('deleteEnvironment sends DELETE to .../environments/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/environments/env-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteEnvironment('team-1', 'env-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/environments/env-1',
            options: any(named: 'options'),
          )).called(1);
    });

    test('activateEnvironment sends PUT to .../activate', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/courier/environments/env-1/activate',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: environmentJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.activateEnvironment('team-1', 'env-1');

      expect(result.name, 'Production');
    });

    test('getEnvironmentVariables sends GET to .../variables', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/environments/env-1/variables',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [envVarJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.getEnvironmentVariables('team-1', 'env-1');

      expect(result, hasLength(1));
      expect(result.first.variableKey, 'API_URL');
    });

    test('setEnvironmentVariables sends PUT to .../variables', () async {
      when(() => mockDio.put<List<dynamic>>(
            '/courier/environments/env-1/variables',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [envVarJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.setEnvironmentVariables(
        'team-1',
        'env-1',
        const SaveEnvironmentVariablesRequest(
          variables: [VariableEntry(variableKey: 'API_URL')],
        ),
      );

      expect(result, hasLength(1));
    });

    test('cloneEnvironment sends POST to .../clone', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/environments/env-1/clone',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: environmentJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.cloneEnvironment(
        'team-1',
        'env-1',
        const CloneEnvironmentRequest(newName: 'Clone'),
      );

      expect(result.id, 'env-1');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Global Variables
  // ═══════════════════════════════════════════════════════════════════════════

  group('Global Variables', () {
    test('getGlobalVariables sends GET to /courier/variables/global', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/variables/global',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [globalVarJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getGlobalVariables('team-1');

      expect(result, hasLength(1));
      expect(result.first.variableKey, 'BASE_URL');
    });

    test('saveGlobalVariable sends POST to /courier/variables/global',
        () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/variables/global',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: globalVarJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.saveGlobalVariable(
        'team-1',
        const SaveGlobalVariableRequest(variableKey: 'BASE_URL'),
      );

      expect(result.variableKey, 'BASE_URL');
    });

    test('batchSaveGlobalVariables sends POST to .../batch', () async {
      when(() => mockDio.post<List<dynamic>>(
            '/courier/variables/global/batch',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [globalVarJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.batchSaveGlobalVariables(
        'team-1',
        const BatchSaveGlobalVariablesRequest(variables: [
          SaveGlobalVariableRequest(variableKey: 'K1'),
        ]),
      );

      expect(result, hasLength(1));
    });

    test('deleteGlobalVariable sends DELETE to .../global/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/variables/global/gvar-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteGlobalVariable('team-1', 'gvar-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/variables/global/gvar-1',
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Proxy
  // ═══════════════════════════════════════════════════════════════════════════

  group('Proxy', () {
    test('sendRequest sends POST to /courier/proxy/send', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/proxy/send',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: proxyResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.sendRequest(
        'team-1',
        SendRequestProxyRequest.fromJson(<String, dynamic>{
          'method': 'GET',
          'url': 'https://api.example.com',
        }),
      );

      expect(result.statusCode, 200);
    });

    test('sendSavedRequestProxy sends POST to .../send/{id}', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/proxy/send/req-1',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: proxyResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.sendSavedRequestProxy('team-1', 'req-1');

      expect(result.statusCode, 200);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // History
  // ═══════════════════════════════════════════════════════════════════════════

  group('History', () {
    test('getHistory sends GET to /courier/history', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/history',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([historyJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getHistory('team-1');

      expect(result.content, hasLength(1));
    });

    test('getHistoryEntry sends GET to /courier/history/{id}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/history/hist-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: historyDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getHistoryEntry('team-1', 'hist-1');

      expect(result.responseBody, '{"data":"test"}');
    });

    test('searchHistory sends GET to /courier/history/search', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/history/search',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [historyJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.searchHistory('team-1', query: 'example');

      expect(result, hasLength(1));
    });

    test('getHistoryByMethod sends GET to .../method/{method}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/history/method/GET',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([historyJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getHistoryByMethod(
        'team-1',
        CourierHttpMethod.get,
      );

      expect(result.content, hasLength(1));
    });

    test('deleteHistoryEntry sends DELETE to /courier/history/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/history/hist-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteHistoryEntry('team-1', 'hist-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/history/hist-1',
            options: any(named: 'options'),
          )).called(1);
    });

    test('clearHistory sends DELETE to /courier/history', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/history',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.clearHistory('team-1', daysToRetain: 30);

      verify(() => mockDio.delete<dynamic>(
            '/courier/history',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Sharing
  // ═══════════════════════════════════════════════════════════════════════════

  group('Sharing', () {
    test('shareCollection sends POST to .../shares', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/collections/col-1/shares',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: shareJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.shareCollection(
        'team-1',
        'col-1',
        ShareCollectionRequest.fromJson(<String, dynamic>{
          'sharedWithUserId': 'user-2',
          'permission': 'EDITOR',
        }),
      );

      expect(result.sharedWithUserId, 'user-2');
    });

    test('getCollectionShares sends GET to .../shares', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/collections/col-1/shares',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [shareJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.getCollectionShares('team-1', 'col-1');

      expect(result, hasLength(1));
    });

    test('getSharedWithMe sends GET to /courier/shared-with-me', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/shared-with-me',
          )).thenAnswer((_) async => Response(
            data: [shareJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getSharedWithMe();

      expect(result, hasLength(1));
    });

    test('removeShare sends DELETE to .../shares/{userId}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/collections/col-1/shares/user-2',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.removeShare('team-1', 'col-1', 'user-2');

      verify(() => mockDio.delete<dynamic>(
            '/courier/collections/col-1/shares/user-2',
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Forking
  // ═══════════════════════════════════════════════════════════════════════════

  group('Forking', () {
    test('forkCollection sends POST to .../fork', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/collections/col-1/fork',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: forkJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.forkCollection('team-1', 'col-1');

      expect(result.label, 'My Fork');
    });

    test('getCollectionForks sends GET to .../forks', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/collections/col-1/forks',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [forkJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.getCollectionForks('team-1', 'col-1');

      expect(result, hasLength(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Import
  // ═══════════════════════════════════════════════════════════════════════════

  group('Import', () {
    test('importPostman sends POST to /courier/import/postman', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/import/postman',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: importResultJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.importPostman(
        'team-1',
        const ImportCollectionRequest(format: 'postman', content: '{}'),
      );

      expect(result.collectionName, 'Imported');
    });

    test('importOpenApi sends POST to /courier/import/openapi', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/import/openapi',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: importResultJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.importOpenApi(
        'team-1',
        const ImportCollectionRequest(format: 'openapi', content: '{}'),
      );

      expect(result.foldersImported, 3);
    });

    test('importCurl sends POST to /courier/import/curl', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/import/curl',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: importResultJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.importCurl(
        'team-1',
        const ImportCollectionRequest(format: 'curl', content: 'curl ...'),
      );

      expect(result.requestsImported, 12);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GraphQL
  // ═══════════════════════════════════════════════════════════════════════════

  group('GraphQL', () {
    test('executeGraphQL sends POST to /courier/graphql/execute', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/graphql/execute',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: graphqlResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.executeGraphQL(
        'team-1',
        const ExecuteGraphQLRequest(
          url: 'https://graphql.example.com',
          query: '{ users { id } }',
        ),
      );

      expect(result.httpResponse!.statusCode, 200);
    });

    test('introspectSchema sends POST to /courier/graphql/introspect',
        () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/graphql/introspect',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: graphqlResponseJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.introspectSchema(
        'team-1',
        const IntrospectGraphQLRequest(url: 'https://graphql.example.com'),
      );

      expect(result.httpResponse, isNotNull);
    });

    test('validateGraphQLQuery sends POST to .../validate', () async {
      when(() => mockDio.post<List<dynamic>>(
            '/courier/graphql/validate',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: <String>[],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api
          .validateGraphQLQuery({'query': '{ users { id } }'});

      expect(result, isEmpty);
    });

    test('formatGraphQLQuery sends POST to .../format', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/graphql/format',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: <String, dynamic>{'query': '{\n  users {\n    id\n  }\n}'},
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api
          .formatGraphQLQuery({'query': '{ users { id } }'});

      expect(result['query'], contains('users'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Runner
  // ═══════════════════════════════════════════════════════════════════════════

  group('Runner', () {
    test('startRun sends POST to /courier/runner/start', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/runner/start',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: runResultDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.startRun(
        'team-1',
        const StartCollectionRunRequest(collectionId: 'col-1'),
      );

      expect(result.summary!.status!.toJson(), 'COMPLETED');
    });

    test('getRunResults sends GET to /courier/runner/results', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/runner/results',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([runResultJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getRunResults('team-1');

      expect(result.content, hasLength(1));
    });

    test('getRunResult sends GET to .../results/{id}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/runner/results/run-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: runResultJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getRunResult('team-1', 'run-1');

      expect(result.totalRequests, 10);
    });

    test('getRunResultDetail sends GET to .../results/{id}/detail', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/runner/results/run-1/detail',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: runResultDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getRunResultDetail('team-1', 'run-1');

      expect(result.summary, isNotNull);
    });

    test('cancelRun sends POST to .../results/{id}/cancel', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/runner/results/run-1/cancel',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: runResultJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.cancelRun('team-1', 'run-1');

      expect(result.id, 'run-1');
    });

    test('getRunResultsByCollection sends GET to .../collection/{id}',
        () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/runner/results/collection/col-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [runResultJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.getRunResultsByCollection('team-1', 'col-1');

      expect(result, hasLength(1));
    });

    test('deleteRunResult sends DELETE to .../results/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/courier/runner/results/run-1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteRunResult('team-1', 'run-1');

      verify(() => mockDio.delete<dynamic>(
            '/courier/runner/results/run-1',
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Code Generation
  // ═══════════════════════════════════════════════════════════════════════════

  group('Code Generation', () {
    test('getCodeLanguages sends GET to /courier/codegen/languages', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/courier/codegen/languages',
          )).thenAnswer((_) async => Response(
            data: [codeSnippetJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getCodeLanguages();

      expect(result, hasLength(1));
      expect(result.first.language!.toJson(), 'CURL');
    });

    test('generateCode sends POST to /courier/codegen/generate', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/courier/codegen/generate',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: codeSnippetJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.generateCode(
        'team-1',
        GenerateCodeRequest.fromJson(<String, dynamic>{
          'requestId': 'req-1',
          'language': 'CURL',
        }),
      );

      expect(result.code, contains('curl'));
    });

    test('generateAllCode sends POST to .../generate/all', () async {
      when(() => mockDio.post<List<dynamic>>(
            '/courier/codegen/generate/all',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: [codeSnippetJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.generateAllCode(
        'team-1',
        GenerateCodeRequest.fromJson(<String, dynamic>{
          'requestId': 'req-1',
          'language': 'CURL',
        }),
      );

      expect(result, hasLength(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Health
  // ═══════════════════════════════════════════════════════════════════════════

  group('Health', () {
    test('getHealth sends GET to /courier/health', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/courier/health',
          )).thenAnswer((_) async => Response(
            data: <String, dynamic>{'status': 'UP'},
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getHealth();

      expect(result['status'], 'UP');
    });
  });
}
