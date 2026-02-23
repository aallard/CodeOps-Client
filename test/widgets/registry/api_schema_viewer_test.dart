// Tests for ApiSchemaViewer.
//
// Verifies object property display, required markers, type badges,
// enum rendering, array display, and nested schema rendering.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/openapi_spec.dart';
import 'package:codeops/widgets/registry/api_schema_viewer.dart';

Widget _buildViewer(OpenApiSchema schema, {String? label}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ApiSchemaViewer(schema: schema, label: label),
      ),
    ),
  );
}

void main() {
  group('ApiSchemaViewer', () {
    testWidgets('renders primitive type', (tester) async {
      const schema = OpenApiSchema(type: 'string', format: 'uuid');
      await tester.pumpWidget(_buildViewer(schema, label: 'ID'));
      await tester.pumpAndSettle();

      expect(find.text('ID'), findsOneWidget);
      expect(find.text('string'), findsOneWidget);
      expect(find.text('(uuid)'), findsOneWidget);
    });

    testWidgets('renders object properties', (tester) async {
      const schema = OpenApiSchema(
        type: 'object',
        properties: {
          'name': OpenApiSchema(type: 'string'),
          'age': OpenApiSchema(type: 'integer'),
        },
        required: ['name'],
      );
      await tester.pumpWidget(_buildViewer(schema));
      await tester.pumpAndSettle();

      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);
      // Required marker.
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('renders enum values', (tester) async {
      const schema = OpenApiSchema(
        type: 'string',
        enumValues: ['ACTIVE', 'INACTIVE'],
      );
      await tester.pumpWidget(_buildViewer(schema));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('INACTIVE'), findsOneWidget);
      expect(find.text('enum'), findsOneWidget);
    });

    testWidgets('renders array type', (tester) async {
      const schema = OpenApiSchema(
        type: 'array',
        items: OpenApiSchema(type: 'string'),
      );
      await tester.pumpWidget(_buildViewer(schema));
      await tester.pumpAndSettle();

      expect(find.text('array'), findsOneWidget);
      expect(find.text('string'), findsOneWidget);
    });

    testWidgets('renders ref name', (tester) async {
      const schema = OpenApiSchema(
        type: 'object',
        ref: 'UserResponse',
        properties: {
          'id': OpenApiSchema(type: 'string'),
        },
      );
      await tester.pumpWidget(_buildViewer(schema));
      await tester.pumpAndSettle();

      expect(find.text('UserResponse'), findsOneWidget);
      expect(find.text('id'), findsOneWidget);
    });
  });
}
