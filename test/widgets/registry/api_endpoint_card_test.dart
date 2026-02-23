// Tests for ApiEndpointCard.
//
// Verifies collapsed display, expand/collapse, method badge,
// path display, parameters section, copy cURL button,
// deprecated badge, and response codes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/openapi_spec.dart';
import 'package:codeops/widgets/registry/api_endpoint_card.dart';

const _endpoint = OpenApiEndpoint(
  path: '/api/v1/users/{id}',
  method: 'GET',
  summary: 'Get user by ID',
  description: 'Returns a single user.',
  operationId: 'getUserById',
  tags: ['Users'],
  parameters: [
    OpenApiParameter(
      name: 'id',
      location: 'path',
      required: true,
      schema: OpenApiSchema(type: 'string', format: 'uuid'),
    ),
  ],
  responses: {
    '200': OpenApiResponse(description: 'User found'),
    '404': OpenApiResponse(description: 'Not found'),
  },
);

const _deprecatedEndpoint = OpenApiEndpoint(
  path: '/api/v1/old',
  method: 'DELETE',
  summary: 'Legacy endpoint',
  deprecated: true,
  responses: {
    '204': OpenApiResponse(description: 'Deleted'),
  },
);

const _postEndpoint = OpenApiEndpoint(
  path: '/api/v1/users',
  method: 'POST',
  summary: 'Create user',
  requestBody: OpenApiRequestBody(
    required: true,
    content: {
      'application/json': OpenApiMediaType(
        schema: OpenApiSchema(
          type: 'object',
          properties: {
            'name': OpenApiSchema(type: 'string'),
          },
        ),
      ),
    },
  ),
  responses: {
    '201': OpenApiResponse(description: 'Created'),
  },
);

Widget _buildCard(OpenApiEndpoint endpoint, {bool expanded = false}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ApiEndpointCard(
          endpoint: endpoint,
          baseUrl: 'http://localhost:8090',
          initiallyExpanded: expanded,
        ),
      ),
    ),
  );
}

void main() {
  group('ApiEndpointCard', () {
    testWidgets('shows method badge and path when collapsed', (tester) async {
      await tester.pumpWidget(_buildCard(_endpoint));
      await tester.pumpAndSettle();

      expect(find.text('GET'), findsOneWidget);
      expect(find.text('/api/v1/users/{id}'), findsOneWidget);
      expect(find.text('Get user by ID'), findsOneWidget);
    });

    testWidgets('shows details when expanded', (tester) async {
      await tester.pumpWidget(_buildCard(_endpoint, expanded: true));
      await tester.pumpAndSettle();

      expect(find.text('Parameters'), findsOneWidget);
      expect(find.text('id'), findsOneWidget);
      expect(find.text('Responses'), findsOneWidget);
      expect(find.text('Copy cURL'), findsOneWidget);
    });

    testWidgets('toggles expansion on tap', (tester) async {
      await tester.pumpWidget(_buildCard(_endpoint));
      await tester.pumpAndSettle();

      // Collapsed — no Parameters section.
      expect(find.text('Parameters'), findsNothing);

      // Tap to expand.
      await tester.tap(find.text('/api/v1/users/{id}'));
      await tester.pumpAndSettle();

      expect(find.text('Parameters'), findsOneWidget);
    });

    testWidgets('shows deprecated badge', (tester) async {
      await tester.pumpWidget(_buildCard(_deprecatedEndpoint));
      await tester.pumpAndSettle();

      expect(find.text('deprecated'), findsOneWidget);
    });

    testWidgets('shows response codes', (tester) async {
      await tester.pumpWidget(_buildCard(_endpoint, expanded: true));
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(find.text('404'), findsOneWidget);
    });

    testWidgets('shows request body section for POST', (tester) async {
      await tester.pumpWidget(_buildCard(_postEndpoint, expanded: true));
      await tester.pumpAndSettle();

      expect(find.text('Request Body'), findsOneWidget);
    });
  });
}
