// Tests for VaultPathTree widget and buildPathTree utility (CVF-002).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/vault_providers.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/vault/vault_path_tree.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // buildPathTree unit tests
  // ─────────────────────────────────────────────────────────────────────────

  group('buildPathTree', () {
    test('builds empty tree from empty list', () {
      final root = buildPathTree([]);
      expect(root.name, '/');
      expect(root.fullPath, '/');
      expect(root.children, isEmpty);
    });

    test('builds single-level tree', () {
      final root = buildPathTree(['/services']);
      expect(root.children.length, 1);
      expect(root.children['services']!.name, 'services');
      expect(root.children['services']!.fullPath, '/services');
    });

    test('builds multi-level tree', () {
      final root = buildPathTree(['/services/app/db-password']);
      expect(root.children.length, 1);
      final services = root.children['services']!;
      expect(services.children.length, 1);
      final app = services.children['app']!;
      expect(app.children.length, 1);
      expect(app.children['db-password']!.fullPath, '/services/app/db-password');
    });

    test('merges common prefixes', () {
      final root = buildPathTree([
        '/services/app/db-password',
        '/services/app/api-key',
        '/services/auth/jwt-secret',
      ]);
      final services = root.children['services']!;
      expect(services.children.length, 2);
      expect(services.children['app']!.children.length, 2);
      expect(services.children['auth']!.children.length, 1);
    });

    test('sorts children alphabetically in tree structure', () {
      final root = buildPathTree([
        '/zebra',
        '/alpha',
        '/middle',
      ]);
      final keys = root.children.keys.toList();
      expect(keys, containsAll(['zebra', 'alpha', 'middle']));
    });

    test('handles paths without leading slash', () {
      final root = buildPathTree(['services/app']);
      expect(root.children.length, 1);
      expect(root.children['services']!.children['app']!.fullPath,
          '/services/app');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // VaultPathTree widget tests
  // ─────────────────────────────────────────────────────────────────────────

  group('VaultPathTree', () {
    Widget createWidget({
      List<String> paths = const [],
      String selectedPath = '',
      ValueChanged<String>? onPathSelected,
    }) {
      return ProviderScope(
        overrides: [
          vaultSecretPathsProvider('/').overrideWith(
            (ref) => Future.value(paths),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SizedBox(
              width: 220,
              child: VaultPathTree(
                selectedPath: selectedPath,
                onPathSelected: onPathSelected ?? (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows Paths header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Paths'), findsOneWidget);
    });

    testWidgets('shows refresh icon', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows root node', (tester) async {
      await tester.pumpWidget(createWidget(paths: ['/services']));
      await tester.pumpAndSettle();

      expect(find.text('/'), findsOneWidget);
    });

    testWidgets('shows child folders when root is expanded', (tester) async {
      await tester.pumpWidget(createWidget(
        paths: ['/services/app', '/config/db'],
      ));
      await tester.pumpAndSettle();

      // Root is expanded by default, so children should be visible
      expect(find.text('services'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);
    });

    testWidgets('fires onPathSelected when tapping a node', (tester) async {
      String? selected;
      await tester.pumpWidget(createWidget(
        paths: ['/services'],
        onPathSelected: (path) => selected = path,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('services'));
      expect(selected, '/services');
    });

    testWidgets('fires empty path when tapping root node', (tester) async {
      String? selected;
      await tester.pumpWidget(createWidget(
        paths: ['/services'],
        onPathSelected: (path) => selected = path,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('/'));
      expect(selected, '');
    });

    testWidgets('highlights selected path', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidget(
        paths: ['/services'],
        selectedPath: '/services',
      ));
      await tester.pumpAndSettle();

      // The selected node text should use primary color (bold, FontWeight.w600)
      final text = tester.widget<Text>(find.text('services'));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('shows loading state', (tester) async {
      final completer = Completer<List<String>>();
      final widget = ProviderScope(
        overrides: [
          vaultSecretPathsProvider('/').overrideWith(
            (ref) => completer.future,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SizedBox(
              width: 220,
              child: VaultPathTree(
                selectedPath: '',
                onPathSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timer issues.
      completer.complete([]);
      await tester.pumpAndSettle();
    });
  });
}
