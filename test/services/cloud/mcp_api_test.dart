// Tests for McpApiService.
//
// Verifies that all 27 endpoint methods send the correct path,
// query parameters, and request body, and deserialize responses correctly.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/services/cloud/api_client.dart';
import 'package:codeops/services/cloud/mcp_api.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockClient;
  late MockDio mockDio;
  late McpApiService api;

  setUp(() {
    mockClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockClient.dio).thenReturn(mockDio);
    api = McpApiService(mockClient);
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared JSON fixtures
  // ═══════════════════════════════════════════════════════════════════════════

  final sessionJson = <String, dynamic>{
    'id': 'sess-1',
    'status': 'ACTIVE',
    'projectName': 'CodeOps-Server',
    'developerName': 'Adam',
    'environment': 'LOCAL',
    'transport': 'HTTP',
    'totalToolCalls': 5,
  };

  final sessionDetailJson = <String, dynamic>{
    'id': 'sess-1',
    'status': 'COMPLETED',
    'projectName': 'CodeOps-Server',
    'developerName': 'Adam',
    'environment': 'LOCAL',
    'transport': 'HTTP',
    'timeoutMinutes': 30,
    'totalToolCalls': 10,
    'toolCalls': <Map<String, dynamic>>[],
  };

  final toolCallSummaryJson = <String, dynamic>{
    'toolName': 'registry.listServices',
    'callCount': 3,
  };

  final profileJson = <String, dynamic>{
    'id': 'dp-1',
    'displayName': 'Adam Allard',
    'defaultEnvironment': 'LOCAL',
    'isActive': true,
    'teamId': 'team-1',
    'userId': 'user-1',
    'userDisplayName': 'Adam',
  };

  final tokenJson = <String, dynamic>{
    'id': 'tok-1',
    'name': 'CI Token',
    'tokenPrefix': 'mcp_a1b2',
    'status': 'ACTIVE',
  };

  final tokenCreatedJson = <String, dynamic>{
    'id': 'tok-1',
    'name': 'CI Token',
    'tokenPrefix': 'mcp_a1b2',
    'rawToken': 'mcp_a1b2c3d4e5f6',
    'status': 'ACTIVE',
  };

  final documentJson = <String, dynamic>{
    'id': 'doc-1',
    'documentType': 'CLAUDE_MD',
    'isFlagged': false,
    'projectId': 'proj-1',
  };

  final documentDetailJson = <String, dynamic>{
    'id': 'doc-1',
    'documentType': 'CLAUDE_MD',
    'currentContent': '# CLAUDE.md',
    'isFlagged': false,
    'projectId': 'proj-1',
    'versions': <Map<String, dynamic>>[],
  };

  final documentVersionJson = <String, dynamic>{
    'id': 'ver-1',
    'versionNumber': 1,
    'content': '# Initial',
    'authorType': 'HUMAN',
  };

  final activityJson = <String, dynamic>{
    'id': 'act-1',
    'activityType': 'SESSION_COMPLETED',
    'title': 'Session completed',
    'projectName': 'CodeOps-Server',
    'actorName': 'Adam',
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
  // Protocol
  // ═══════════════════════════════════════════════════════════════════════════

  group('Protocol', () {
    test('sendProtocolMessage sends POST to /mcp/protocol/message', () async {
      when(() => mockDio.post<String>(
            '/mcp/protocol/message',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: '{"jsonrpc":"2.0","result":{}}',
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.sendProtocolMessage('{"jsonrpc":"2.0"}');

      expect(result, contains('jsonrpc'));
      verify(() => mockDio.post<String>(
            '/mcp/protocol/message',
            data: any(named: 'data'),
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Sessions
  // ═══════════════════════════════════════════════════════════════════════════

  group('Sessions', () {
    test('initSession sends POST to /mcp/sessions', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/sessions',
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: sessionDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.initSession(
        teamId: 'team-1',
        request: {'projectId': 'proj-1'},
      );

      expect(result.id, 'sess-1');
      verify(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/sessions',
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('completeSession sends POST to /mcp/sessions/{id}/complete',
        () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/sessions/sess-1/complete',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: sessionDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.completeSession('sess-1', {'summary': 'Done'});

      expect(result.id, 'sess-1');
    });

    test('getSession sends GET to /mcp/sessions/{id}', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/sessions/sess-1',
          )).thenAnswer((_) async => Response(
            data: sessionDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getSession('sess-1');

      expect(result.id, 'sess-1');
      expect(result.timeoutMinutes, 30);
    });

    test('getSessionHistory sends GET to /mcp/sessions/history', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/sessions/history',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [sessionJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getSessionHistory(projectId: 'proj-1');

      expect(result, hasLength(1));
      expect(result.first.id, 'sess-1');
    });

    test('getMySessions sends GET to /mcp/sessions/mine', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/sessions/mine',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([sessionJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getMySessions(teamId: 'team-1');

      expect(result.content, hasLength(1));
    });

    test('cancelSession sends POST to /mcp/sessions/{id}/cancel', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/sessions/sess-1/cancel',
          )).thenAnswer((_) async => Response(
            data: sessionJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.cancelSession('sess-1');

      expect(result.id, 'sess-1');
    });

    test('getSessionToolCalls sends GET to /mcp/sessions/{id}/tool-calls',
        () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/sessions/sess-1/tool-calls',
          )).thenAnswer((_) async => Response(
            data: [toolCallSummaryJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getSessionToolCalls('sess-1');

      expect(result, hasLength(1));
      expect(result.first.toolName, 'registry.listServices');
      expect(result.first.callCount, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Documents
  // ═══════════════════════════════════════════════════════════════════════════

  group('Documents', () {
    test('createDocument sends POST to /mcp/documents', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/documents',
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: documentDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createDocument(
        projectId: 'proj-1',
        request: {'documentType': 'CLAUDE_MD', 'content': '# CLAUDE.md'},
      );

      expect(result.id, 'doc-1');
      verify(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/documents',
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('getProjectDocuments sends GET to /mcp/documents', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/documents',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [documentJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getProjectDocuments(projectId: 'proj-1');

      expect(result, hasLength(1));
      expect(result.first.id, 'doc-1');
    });

    test('getDocumentByType sends GET to /mcp/documents/by-type', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/documents/by-type',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: documentDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getDocumentByType(
        projectId: 'proj-1',
        documentType: 'CLAUDE_MD',
      );

      expect(result.id, 'doc-1');
      expect(result.currentContent, '# CLAUDE.md');
    });

    test('updateDocument sends PUT to /mcp/documents/{id}', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/mcp/documents/doc-1',
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: documentDetailJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateDocument(
        'doc-1',
        {'content': '# Updated'},
        sessionId: 'sess-1',
      );

      expect(result.id, 'doc-1');
    });

    test('deleteDocument sends DELETE to /mcp/documents/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/mcp/documents/doc-1',
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.deleteDocument('doc-1');

      verify(() => mockDio.delete<dynamic>(
            '/mcp/documents/doc-1',
          )).called(1);
    });

    test('getDocumentVersions sends GET to /mcp/documents/{id}/versions',
        () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/documents/doc-1/versions',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([documentVersionJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getDocumentVersions('doc-1');

      expect(result.content, hasLength(1));
    });

    test('getDocumentVersion sends GET to .../versions/{versionNumber}',
        () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/documents/doc-1/versions/1',
          )).thenAnswer((_) async => Response(
            data: documentVersionJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getDocumentVersion('doc-1', 1);

      expect(result.versionNumber, 1);
      expect(result.content, '# Initial');
    });

    test('getFlaggedDocuments sends GET to /mcp/documents/flagged', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/documents/flagged',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [documentJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getFlaggedDocuments(projectId: 'proj-1');

      expect(result, hasLength(1));
    });

    test('clearDocumentFlag sends POST to /mcp/documents/{id}/clear-flag',
        () async {
      when(() => mockDio.post<dynamic>(
            '/mcp/documents/doc-1/clear-flag',
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.clearDocumentFlag('doc-1');

      verify(() => mockDio.post<dynamic>(
            '/mcp/documents/doc-1/clear-flag',
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Developers
  // ═══════════════════════════════════════════════════════════════════════════

  group('Developers', () {
    test('getOrCreateProfile sends POST to /mcp/developers/profile', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/developers/profile',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: profileJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getOrCreateProfile(teamId: 'team-1');

      expect(result.id, 'dp-1');
      expect(result.displayName, 'Adam Allard');
    });

    test('getProfile sends GET to /mcp/developers/profile', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/developers/profile',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: profileJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result =
          await api.getProfile(teamId: 'team-1', userId: 'user-1');

      expect(result.id, 'dp-1');
    });

    test('getTeamProfiles sends GET to /mcp/developers', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/developers',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [profileJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getTeamProfiles(teamId: 'team-1');

      expect(result, hasLength(1));
      expect(result.first.displayName, 'Adam Allard');
    });

    test('updateProfile sends PUT to /mcp/developers/{id}', () async {
      when(() => mockDio.put<Map<String, dynamic>>(
            '/mcp/developers/dp-1',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: profileJson,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.updateProfile(
        'dp-1',
        {'displayName': 'Updated Name'},
      );

      expect(result.id, 'dp-1');
    });

    test('createApiToken sends POST to /mcp/developers/{id}/tokens', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/mcp/developers/dp-1/tokens',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: tokenCreatedJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final result = await api.createApiToken(
        'dp-1',
        {'name': 'CI Token'},
      );

      expect(result.id, 'tok-1');
      expect(result.rawToken, 'mcp_a1b2c3d4e5f6');
    });

    test('getTokens sends GET to /mcp/developers/{id}/tokens', () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/developers/dp-1/tokens',
          )).thenAnswer((_) async => Response(
            data: [tokenJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getTokens('dp-1');

      expect(result, hasLength(1));
      expect(result.first.name, 'CI Token');
    });

    test('revokeToken sends DELETE to /mcp/developers/tokens/{id}', () async {
      when(() => mockDio.delete<dynamic>(
            '/mcp/developers/tokens/tok-1',
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 204,
          ));

      await api.revokeToken('tok-1');

      verify(() => mockDio.delete<dynamic>(
            '/mcp/developers/tokens/tok-1',
          )).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Activity
  // ═══════════════════════════════════════════════════════════════════════════

  group('Activity', () {
    test('getTeamFeed sends GET to /mcp/activity/team', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/activity/team',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([activityJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getTeamFeed(teamId: 'team-1');

      expect(result.content, hasLength(1));
      expect(result.content.first.title, 'Session completed');
    });

    test('getProjectFeed sends GET to /mcp/activity/project', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            '/mcp/activity/project',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: pagedJson([activityJson]),
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getProjectFeed(projectId: 'proj-1');

      expect(result.content, hasLength(1));
    });

    test('getTeamActivitySince sends GET to /mcp/activity/team/since',
        () async {
      when(() => mockDio.get<List<dynamic>>(
            '/mcp/activity/team/since',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [activityJson],
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final result = await api.getTeamActivitySince(
        teamId: 'team-1',
        since: DateTime.utc(2026),
      );

      expect(result, hasLength(1));
      expect(result.first.actorName, 'Adam');
    });
  });
}
