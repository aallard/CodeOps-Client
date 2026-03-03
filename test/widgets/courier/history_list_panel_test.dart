// Widget tests for HistoryListPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/history_list_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _today = DateTime.now();
final _yesterday = _today.subtract(const Duration(days: 1));

final _entries = [
  RequestHistoryResponse(
    id: 'h1',
    requestMethod: CourierHttpMethod.post,
    requestUrl: 'https://api.example.com/auth/token',
    responseStatus: 200,
    responseTimeMs: 143,
    createdAt: _today,
  ),
  RequestHistoryResponse(
    id: 'h2',
    requestMethod: CourierHttpMethod.get,
    requestUrl: 'https://api.example.com/users',
    responseStatus: 200,
    responseTimeMs: 87,
    createdAt: _today,
  ),
  RequestHistoryResponse(
    id: 'h3',
    requestMethod: CourierHttpMethod.get,
    requestUrl: 'https://api.example.com/users/123',
    responseStatus: 404,
    responseTimeMs: 42,
    createdAt: _yesterday,
  ),
  RequestHistoryResponse(
    id: 'h4',
    requestMethod: CourierHttpMethod.delete,
    requestUrl: 'https://api.example.com/users/456',
    responseStatus: 500,
    responseTimeMs: 234,
    createdAt: _yesterday,
  ),
];

final _page = PageResponse<RequestHistoryResponse>(
  content: _entries,
  page: 0,
  size: 20,
  totalElements: 4,
  totalPages: 1,
  isLast: true,
);

Widget buildListPanel({
  PageResponse<RequestHistoryResponse>? page,
}) {
  return ProviderScope(
    overrides: [
      courierHistoryProvider.overrideWith((ref) => page ?? _page),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: HistoryListPanel(),
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
  group('HistoryListPanel', () {
    testWidgets('renders list panel', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history_list_panel')), findsOneWidget);
    });

    testWidgets('shows toolbar with search and filters', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history_toolbar')), findsOneWidget);
      expect(find.byKey(const Key('history_search_field')), findsOneWidget);
      expect(find.byKey(const Key('history_filters_row')), findsOneWidget);
      expect(find.byKey(const Key('method_filter')), findsOneWidget);
      expect(find.byKey(const Key('status_filter')), findsOneWidget);
    });

    testWidgets('groups entries by date', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('shows method badges with correct text', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.text('POST'), findsOneWidget);
      expect(find.text('GET'), findsAtLeast(1));
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('shows status codes', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.text('200'), findsAtLeast(1));
      expect(find.text('404'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('shows duration in ms', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.text('143ms'), findsOneWidget);
      expect(find.text('87ms'), findsOneWidget);
    });

    testWidgets('shows URLs', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.text('https://api.example.com/auth/token'), findsOneWidget);
      expect(find.text('https://api.example.com/users'), findsOneWidget);
    });

    testWidgets('shows multi-select button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multi_select_button')), findsOneWidget);
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('shows clear all button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('clear_all_button')), findsOneWidget);
    });

    testWidgets('shows empty state when no entries', (tester) async {
      setSize(tester);
      await tester.pumpWidget(
          buildListPanel(page: PageResponse.empty()));
      await tester.pumpAndSettle();

      expect(find.text('No history entries'), findsOneWidget);
    });

    testWidgets('toggles multi-select mode', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      // Tap Select button
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Should show Done instead of Select
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
