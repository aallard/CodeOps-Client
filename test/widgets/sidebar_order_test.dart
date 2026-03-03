// Tests for sidebar module ordering via sidebarOrderProvider.
//
// Verifies that the sidebarOrderProvider produces the expected
// default order and supports reordering.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/preferences_providers.dart';

void main() {
  group('Sidebar module order', () {
    test('default order has 8 modules', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = container.read(sidebarOrderProvider);

      expect(order.length, 8);
    });

    test('default order starts with vault', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = container.read(sidebarOrderProvider);

      expect(order.first, 'vault');
    });

    test('default order ends with mcp', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = container.read(sidebarOrderProvider);

      expect(order.last, 'mcp');
    });

    test('default order contains all expected modules', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = container.read(sidebarOrderProvider);

      expect(order, containsAll([
        'vault',
        'registry',
        'fleet',
        'courier',
        'datalens',
        'logger',
        'relay',
        'mcp',
      ]));
    });

    test('reorder moves a module to a new position', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Move 'mcp' to the front.
      final original = container.read(sidebarOrderProvider);
      final reordered = List<String>.from(original);
      final item = reordered.removeAt(reordered.indexOf('mcp'));
      reordered.insert(0, item);
      container.read(sidebarOrderProvider.notifier).state = reordered;

      final updated = container.read(sidebarOrderProvider);

      expect(updated.first, 'mcp');
      expect(updated.length, 8);
    });

    test('reorder preserves all modules', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Reverse the order.
      final original = container.read(sidebarOrderProvider);
      container.read(sidebarOrderProvider.notifier).state =
          original.reversed.toList();

      final updated = container.read(sidebarOrderProvider);

      expect(updated.toSet(), original.toSet());
    });
  });
}
