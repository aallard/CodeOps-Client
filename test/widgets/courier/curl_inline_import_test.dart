// Widget tests for cURL inline import in the URL bar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/providers/courier_ui_providers.dart';
import 'package:codeops/widgets/courier/request_builder.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildRequestBuilder() {
  return ProviderScope(
    overrides: [
      openRequestTabsProvider.overrideWith((ref) => [
            RequestTab(
              id: 'tab-1',
              requestId: null,
              name: 'New Request',
              method: CourierHttpMethod.get,
              url: '',
              isNew: true,
            ),
          ]),
      activeRequestTabProvider.overrideWith((ref) => 'tab-1'),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 600,
          child: RequestBuilder(),
        ),
      ),
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
  group('cURL inline import', () {
    testWidgets('URL field exists for paste detection', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRequestBuilder());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('url_field')), findsOneWidget);
    });

    testWidgets('detects cURL and updates URL field', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRequestBuilder());
      await tester.pumpAndSettle();

      // Paste a cURL command into the URL field.
      await tester.enterText(
        find.byKey(const Key('url_field')),
        'curl -X POST https://api.example.com/users',
      );
      await tester.pumpAndSettle();

      // After cURL detection, the URL field should be updated to just the URL.
      final field = tester.widget<TextField>(find.byKey(const Key('url_field')));
      expect(field.controller!.text, 'https://api.example.com/users');
    });

    testWidgets('shows toast after cURL import', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRequestBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('url_field')),
        'curl https://api.example.com/data',
      );
      await tester.pumpAndSettle();

      expect(find.text('cURL imported \u2014 request populated'), findsOneWidget);
    });
  });
}
