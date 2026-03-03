// Widget tests for HistoryDetailPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/history_detail_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _detail = RequestHistoryDetailResponse(
  id: 'h1',
  requestMethod: CourierHttpMethod.post,
  requestUrl: 'https://api.example.com/auth/token',
  responseStatus: 200,
  responseTimeMs: 143,
  responseSizeBytes: 512,
  requestHeaders: '{"Content-Type":"application/json","Authorization":"Bearer tok"}',
  requestBody: '{"username":"admin","password":"pass"}',
  responseHeaders: '{"content-type":"application/json"}',
  responseBody: '{"token":"abc123","expires":3600}',
  createdAt: DateTime(2026, 3, 3, 14, 45),
);

Widget buildDetailPanel({
  RequestHistoryDetailResponse? detail,
  void Function(RequestHistoryDetailResponse)? onOpenInBuilder,
  void Function(RequestHistoryDetailResponse)? onResend,
}) {
  final d = detail ?? _detail;
  return ProviderScope(
    overrides: [
      courierHistoryDetailProvider(d.id!)
          .overrideWith((ref) => d),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 700,
          child: HistoryDetailPanel(
            historyId: d.id!,
            onOpenInBuilder: onOpenInBuilder,
            onResend: onResend,
          ),
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
  group('HistoryDetailPanel', () {
    testWidgets('renders detail panel', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history_detail_panel')), findsOneWidget);
    });

    testWidgets('shows method and URL in header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel());
      await tester.pumpAndSettle();

      expect(find.text('POST'), findsOneWidget);
      expect(find.text('https://api.example.com/auth/token'), findsOneWidget);
    });

    testWidgets('shows timing info', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('timing_row')), findsOneWidget);
      expect(find.text('143ms'), findsOneWidget);
    });

    testWidgets('shows request and response tabs', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history_detail_tabs')), findsOneWidget);
      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Response'), findsOneWidget);
    });

    testWidgets('shows action buttons', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel(
        onOpenInBuilder: (_) {},
        onResend: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('open_in_builder_button')), findsOneWidget);
      expect(find.byKey(const Key('copy_curl_button')), findsOneWidget);
      expect(find.byKey(const Key('resend_button')), findsOneWidget);
    });

    testWidgets('shows request tab content by default', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request_tab')), findsOneWidget);
      expect(find.byKey(const Key('request_headers_block')), findsOneWidget);
      expect(find.byKey(const Key('request_body_block')), findsOneWidget);
    });

    testWidgets('shows response tab on tap', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildDetailPanel());
      await tester.pumpAndSettle();

      // Tap Response tab
      await tester.tap(find.text('Response'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('response_tab')), findsOneWidget);
      expect(find.byKey(const Key('response_headers_block')), findsOneWidget);
      expect(find.byKey(const Key('response_body_block')), findsOneWidget);
    });
  });
}
