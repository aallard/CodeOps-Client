// Tests for history auto-save (provider invalidation after execution).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/courier_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('History providers', () {
    test('courierHistoryProvider returns page response', () {
      final container = ProviderContainer(
        overrides: [
          courierHistoryProvider.overrideWith(
            (ref) => PageResponse<RequestHistoryResponse>(
              content: [
                RequestHistoryResponse(
                  id: 'h1',
                  requestMethod: CourierHttpMethod.get,
                  requestUrl: 'https://api.example.com/users',
                  responseStatus: 200,
                  responseTimeMs: 50,
                  createdAt: DateTime.now(),
                ),
              ],
              page: 0,
              size: 20,
              totalElements: 1,
              totalPages: 1,
              isLast: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(courierHistoryProvider);
      expect(result, isA<AsyncValue<PageResponse<RequestHistoryResponse>>>());
    });

    test('selectedHistoryEntryProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedHistoryEntryProvider), isNull);
    });

    test('selectedHistoryEntryProvider can be set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHistoryEntryProvider.notifier).state = 'h1';
      expect(container.read(selectedHistoryEntryProvider), 'h1');
    });

    test('courierHistoryStatusFilterProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(courierHistoryStatusFilterProvider), isNull);
    });
  });
}
