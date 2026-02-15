// Tests for ComplianceApi.
//
// Verifies specification CRUD, compliance item CRUD (single + batch),
// status-filtered queries, and summary endpoint.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/services/cloud/api_client.dart';
import 'package:codeops/services/cloud/compliance_api.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockClient;
  late ComplianceApi complianceApi;

  final specJson = {
    'id': 's1',
    'jobId': 'j1',
    'name': 'api-spec.yaml',
    'specType': 'OPENAPI',
    's3Key': 'specs/j1/api-spec.yaml',
    'createdAt': '2024-01-01T00:00:00.000Z',
  };

  final complianceItemJson = {
    'id': 'c1',
    'jobId': 'j1',
    'requirement': 'Must use HTTPS',
    'specId': 's1',
    'specName': 'api-spec.yaml',
    'status': 'MET',
    'evidence': 'All endpoints use TLS',
    'agentType': 'SECURITY',
    'notes': null,
    'createdAt': '2024-01-01T00:00:00.000Z',
  };

  setUp(() {
    mockClient = MockApiClient();
    complianceApi = ComplianceApi(mockClient);
  });

  group('ComplianceApi', () {
    test('createSpecification sends POST to /compliance/specs with required fields',
        () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/specs',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: specJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final spec = await complianceApi.createSpecification(
        jobId: 'j1',
        name: 'api-spec.yaml',
        s3Key: 'specs/j1/api-spec.yaml',
      );

      expect(spec.id, 's1');
      expect(spec.name, 'api-spec.yaml');
      expect(spec.s3Key, 'specs/j1/api-spec.yaml');
      verify(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/specs',
            data: {
              'jobId': 'j1',
              'name': 'api-spec.yaml',
              's3Key': 'specs/j1/api-spec.yaml',
            },
          )).called(1);
    });

    test('createSpecification includes optional specType when provided',
        () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/specs',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: specJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final spec = await complianceApi.createSpecification(
        jobId: 'j1',
        name: 'api-spec.yaml',
        s3Key: 'specs/j1/api-spec.yaml',
        specType: SpecType.openapi,
      );

      expect(spec.specType, SpecType.openapi);
      verify(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/specs',
            data: {
              'jobId': 'j1',
              'name': 'api-spec.yaml',
              's3Key': 'specs/j1/api-spec.yaml',
              'specType': 'OPENAPI',
            },
          )).called(1);
    });

    test('getSpecificationsForJob sends GET to /compliance/specs/job/{jobId}',
        () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/specs/job/j1',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'content': [specJson],
              'page': 0,
              'size': 20,
              'totalElements': 1,
              'totalPages': 1,
              'isLast': true,
            },
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final page = await complianceApi.getSpecificationsForJob('j1');

      expect(page.content, hasLength(1));
      expect(page.content.first.name, 'api-spec.yaml');
      expect(page.page, 0);
      expect(page.totalElements, 1);
      expect(page.isLast, true);
      verify(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/specs/job/j1',
            queryParameters: {'page': 0, 'size': 20},
          )).called(1);
    });

    test('getSpecificationsForJob passes custom page and size', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/specs/job/j1',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'content': <Map<String, dynamic>>[],
              'page': 2,
              'size': 10,
              'totalElements': 25,
              'totalPages': 3,
              'isLast': false,
            },
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final page =
          await complianceApi.getSpecificationsForJob('j1', page: 2, size: 10);

      expect(page.page, 2);
      expect(page.size, 10);
      verify(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/specs/job/j1',
            queryParameters: {'page': 2, 'size': 10},
          )).called(1);
    });

    test('createComplianceItem sends POST to /compliance/items with required fields',
        () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/items',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: complianceItemJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final item = await complianceApi.createComplianceItem(
        jobId: 'j1',
        requirement: 'Must use HTTPS',
        status: ComplianceStatus.met,
      );

      expect(item.id, 'c1');
      expect(item.requirement, 'Must use HTTPS');
      expect(item.status, ComplianceStatus.met);
      verify(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/items',
            data: {
              'jobId': 'j1',
              'requirement': 'Must use HTTPS',
              'status': 'MET',
            },
          )).called(1);
    });

    test('createComplianceItem includes optional fields when provided',
        () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/items',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: complianceItemJson,
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      await complianceApi.createComplianceItem(
        jobId: 'j1',
        requirement: 'Must use HTTPS',
        status: ComplianceStatus.met,
        specId: 's1',
        evidence: 'All endpoints use TLS',
        agentType: AgentType.security,
        notes: 'Verified manually',
      );

      verify(() => mockClient.post<Map<String, dynamic>>(
            '/compliance/items',
            data: {
              'jobId': 'j1',
              'requirement': 'Must use HTTPS',
              'status': 'MET',
              'specId': 's1',
              'evidence': 'All endpoints use TLS',
              'agentType': 'SECURITY',
              'notes': 'Verified manually',
            },
          )).called(1);
    });

    test('createComplianceItems sends POST to /compliance/items/batch',
        () async {
      when(() => mockClient.post<List<dynamic>>(
            '/compliance/items/batch',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: [complianceItemJson],
            requestOptions: RequestOptions(),
            statusCode: 201,
          ));

      final batchData = [
        {
          'jobId': 'j1',
          'requirement': 'Must use HTTPS',
          'status': 'MET',
        },
      ];

      final items = await complianceApi.createComplianceItems(batchData);

      expect(items, hasLength(1));
      expect(items.first.id, 'c1');
      verify(() => mockClient.post<List<dynamic>>(
            '/compliance/items/batch',
            data: batchData,
          )).called(1);
    });

    test('getComplianceItemsForJob sends GET to /compliance/items/job/{jobId}',
        () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/items/job/j1',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'content': [complianceItemJson],
              'page': 0,
              'size': 50,
              'totalElements': 1,
              'totalPages': 1,
              'isLast': true,
            },
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final page = await complianceApi.getComplianceItemsForJob('j1');

      expect(page.content, hasLength(1));
      expect(page.content.first.requirement, 'Must use HTTPS');
      expect(page.totalElements, 1);
      verify(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/items/job/j1',
            queryParameters: {'page': 0, 'size': 50},
          )).called(1);
    });

    test('getComplianceItemsByStatus sends GET to /compliance/items/job/{jobId}/status/{STATUS}',
        () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/items/job/j1/status/MISSING',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'content': [
                {...complianceItemJson, 'status': 'MISSING'},
              ],
              'page': 0,
              'size': 50,
              'totalElements': 1,
              'totalPages': 1,
              'isLast': true,
            },
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final page = await complianceApi.getComplianceItemsByStatus(
        'j1',
        ComplianceStatus.missing,
      );

      expect(page.content, hasLength(1));
      expect(page.content.first.status, ComplianceStatus.missing);
      verify(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/items/job/j1/status/MISSING',
            queryParameters: {'page': 0, 'size': 50},
          )).called(1);
    });

    test('getComplianceItemsByStatus passes custom page and size', () async {
      when(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/items/job/j1/status/PARTIAL',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'content': <Map<String, dynamic>>[],
              'page': 1,
              'size': 25,
              'totalElements': 30,
              'totalPages': 2,
              'isLast': false,
            },
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      await complianceApi.getComplianceItemsByStatus(
        'j1',
        ComplianceStatus.partial,
        page: 1,
        size: 25,
      );

      verify(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/items/job/j1/status/PARTIAL',
            queryParameters: {'page': 1, 'size': 25},
          )).called(1);
    });

    test('getComplianceSummary sends GET to /compliance/summary/job/{jobId}',
        () async {
      final summaryData = {
        'met': 10,
        'partial': 3,
        'missing': 2,
        'notApplicable': 1,
        'total': 16,
      };

      when(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/summary/job/j1',
          )).thenAnswer((_) async => Response(
            data: summaryData,
            requestOptions: RequestOptions(),
            statusCode: 200,
          ));

      final summary = await complianceApi.getComplianceSummary('j1');

      expect(summary['met'], 10);
      expect(summary['partial'], 3);
      expect(summary['missing'], 2);
      expect(summary['notApplicable'], 1);
      expect(summary['total'], 16);
      verify(() => mockClient.get<Map<String, dynamic>>(
            '/compliance/summary/job/j1',
          )).called(1);
    });
  });
}
