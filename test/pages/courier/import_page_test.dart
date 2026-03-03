// Widget tests for ImportPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/pages/courier/import_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildImportPage() {
  return const ProviderScope(
    child: MaterialApp(
      home: ImportPage(),
    ),
  );
}

void setSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('ImportPage', () {
    testWidgets('renders page header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('import_page_header')), findsOneWidget);
      expect(find.text('Import Collection'), findsOneWidget);
    });

    testWidgets('shows Postman tab', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('postman_tab')), findsOneWidget);
    });

    testWidgets('shows OpenAPI tab', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('openapi_tab')), findsOneWidget);
    });

    testWidgets('shows cURL tab', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('curl_tab')), findsOneWidget);
    });

    testWidgets('shows file upload area on Postman tab', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('file_upload_area')), findsOneWidget);
    });

    testWidgets('shows paste area', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('paste_area')), findsOneWidget);
    });

    testWidgets('shows import button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildImportPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('import_button')), findsOneWidget);
    });
  });
}
