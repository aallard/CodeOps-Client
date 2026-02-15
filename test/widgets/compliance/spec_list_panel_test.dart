import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/specification.dart';
import 'package:codeops/providers/compliance_providers.dart';
import 'package:codeops/widgets/compliance/spec_list_panel.dart';

void main() {
  /// Builds a [SpecListPanel] wrapped in the required providers.
  Widget createWidget({
    required PageResponse<Specification> specsPage,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        complianceJobSpecsProvider('j1')
            .overrideWith((ref) => Future.value(specsPage)),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: SpecListPanel(jobId: 'j1'),
          ),
        ),
      ),
    );
  }

  /// Helper to build a [PageResponse] from a list of [Specification]s.
  PageResponse<Specification> pageOf(List<Specification> specs) {
    return PageResponse<Specification>(
      content: specs,
      page: 0,
      size: specs.length,
      totalElements: specs.length,
      totalPages: 1,
      isLast: true,
    );
  }

  final testSpecs = [
    const Specification(
      id: 's1',
      jobId: 'j1',
      name: 'api-spec.yaml',
      specType: SpecType.openapi,
      s3Key: 'specs/j1/api-spec.yaml',
      createdAt: null,
    ),
    Specification(
      id: 's2',
      jobId: 'j1',
      name: 'requirements.md',
      specType: SpecType.markdown,
      s3Key: 'specs/j1/requirements.md',
      createdAt: DateTime.utc(2024, 1, 15, 10, 30),
    ),
    const Specification(
      id: 's3',
      jobId: 'j1',
      name: 'mockup.png',
      specType: SpecType.screenshot,
      s3Key: 'specs/j1/mockup.png',
      createdAt: null,
    ),
    const Specification(
      id: 's4',
      jobId: 'j1',
      name: 'design.figma',
      specType: SpecType.figma,
      s3Key: 'specs/j1/design.figma',
      createdAt: null,
    ),
  ];

  group('SpecListPanel', () {
    testWidgets('renders spec list with name, type badge, and date',
        (tester) async {
      await tester.pumpWidget(createWidget(specsPage: pageOf(testSpecs)));
      await tester.pumpAndSettle();

      // Spec names should be visible.
      expect(find.text('api-spec.yaml'), findsOneWidget);
      expect(find.text('requirements.md'), findsOneWidget);
      expect(find.text('mockup.png'), findsOneWidget);
      expect(find.text('design.figma'), findsOneWidget);

      // Count label should reflect 4 specs.
      expect(find.text('4 specification(s)'), findsOneWidget);

      // The formatted date for spec s2 should appear.
      expect(find.text('2024-01-15 10:30'), findsOneWidget);

      // Spec s1 has no date, so 'N/A' should appear at least once.
      expect(find.text('N/A'), findsWidgets);
    });

    testWidgets('renders empty state when no specs', (tester) async {
      await tester.pumpWidget(
        createWidget(specsPage: PageResponse<Specification>.empty()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No specifications uploaded'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('type badges show correct text for each SpecType',
        (tester) async {
      await tester.pumpWidget(createWidget(specsPage: pageOf(testSpecs)));
      await tester.pumpAndSettle();

      // Each SpecType.displayName should appear as a badge.
      expect(find.text('OpenAPI'), findsOneWidget);
      expect(find.text('Markdown'), findsOneWidget);
      expect(find.text('Screenshot'), findsOneWidget);
      expect(find.text('Figma'), findsOneWidget);
    });

    testWidgets('download button renders for each spec', (tester) async {
      await tester.pumpWidget(createWidget(specsPage: pageOf(testSpecs)));
      await tester.pumpAndSettle();

      // Each row should have a download icon button.
      expect(find.byIcon(Icons.download), findsNWidgets(testSpecs.length));
    });

    testWidgets('table has expected column headers', (tester) async {
      await tester.pumpWidget(createWidget(specsPage: pageOf(testSpecs)));
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Uploaded'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('spec with null specType shows Unknown badge', (tester) async {
      final specNoType = const Specification(
        id: 's5',
        jobId: 'j1',
        name: 'unknown-file.bin',
        specType: null,
        s3Key: 'specs/j1/unknown-file.bin',
      );

      await tester
          .pumpWidget(createWidget(specsPage: pageOf([specNoType])));
      await tester.pumpAndSettle();

      expect(find.text('Unknown'), findsOneWidget);
    });
  });
}
