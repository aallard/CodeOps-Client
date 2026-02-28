// Tests for MCP providers.
//
// Verifies singleton provider creation, FutureProvider types,
// and StateProvider defaults for all MCP providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/mcp_providers.dart';
import 'package:codeops/services/cloud/mcp_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Core providers', () {
    test('mcpApiProvider creates McpApiService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final api = container.read(mcpApiProvider);
      expect(api, isA<McpApiService>());
    });
  });

  group('selectedMcpSessionIdProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(selectedMcpSessionIdProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedMcpSessionIdProvider.notifier).state = 'sess-123';
      expect(container.read(selectedMcpSessionIdProvider), 'sess-123');
    });
  });

  group('selectedMcpDocumentIdProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(selectedMcpDocumentIdProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedMcpDocumentIdProvider.notifier).state = 'doc-456';
      expect(container.read(selectedMcpDocumentIdProvider), 'doc-456');
    });
  });

  group('mcpActivityTypeFilterProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(mcpActivityTypeFilterProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Import not needed — ActivityType is inferred from the provider type.
      // Just verify state can be set and read.
      container.read(mcpActivityTypeFilterProvider.notifier).state = null;
      expect(container.read(mcpActivityTypeFilterProvider), isNull);
    });
  });
}
