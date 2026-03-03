// Widget tests for RequestHistoryPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/pages/courier/request_history_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _entries = [
  RequestHistoryResponse(
    id: 'h1',
    requestMethod: CourierHttpMethod.get,
    requestUrl: 'https://api.example.com/users',
    responseStatus: 200,
    responseTimeMs: 87,
    createdAt: DateTime.now(),
  ),
  RequestHistoryResponse(
    id: 'h2',
    requestMethod: CourierHttpMethod.post,
    requestUrl: 'https://api.example.com/auth/token',
    responseStatus: 201,
    responseTimeMs: 143,
    createdAt: DateTime.now(),
  ),
];

final _page = PageResponse<RequestHistoryResponse>(
  content: _entries,
  page: 0,
  size: 20,
  totalElements: 2,
  totalPages: 1,
  isLast: true,
);

Widget buildHistoryPage({
  PageResponse<RequestHistoryResponse>? page,
  String? selectedId,
}) {
  return ProviderScope(
    overrides: [
      courierHistoryProvider.overrideWith((ref) => page ?? _page),
      if (selectedId != null)
        selectedHistoryEntryProvider.overrideWith((ref) => selectedId),
    ],
    child: const MaterialApp(
      home: RequestHistoryPage(),
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
  group('RequestHistoryPage', () {
    testWidgets('renders page with header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHistoryPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request_history_page')), findsOneWidget);
      expect(find.byKey(const Key('history_page_header')), findsOneWidget);
      expect(find.text('Request History'), findsOneWidget);
    });

    testWidgets('shows two-pane layout', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHistoryPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history_two_pane')), findsOneWidget);
      expect(find.byKey(const Key('history_list_panel')), findsOneWidget);
    });

    testWidgets('shows empty detail state when no entry selected',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHistoryPage());
      await tester.pumpAndSettle();

      expect(find.text('Select an entry to view details'), findsOneWidget);
    });
  });
}
