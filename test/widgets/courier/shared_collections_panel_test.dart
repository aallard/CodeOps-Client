// Widget tests for SharedCollectionsPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/shared_collections_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _shared = [
  CollectionShareResponse(
    id: 's1',
    collectionId: 'col-1',
    sharedByUserId: 'user-alice',
    sharedWithUserId: 'me',
    permission: SharePermission.viewer,
  ),
  CollectionShareResponse(
    id: 's2',
    collectionId: 'col-2',
    sharedByUserId: 'user-bob',
    sharedWithUserId: 'me',
    permission: SharePermission.editor,
  ),
];

Widget buildPanel({
  List<CollectionShareResponse> shares = const [],
  ValueChanged<String>? onOpen,
}) {
  return ProviderScope(
    overrides: [
      courierSharedWithMeProvider.overrideWith((ref) => shares),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 280,
          height: 400,
          child: SharedCollectionsPanel(onOpen: onOpen),
        ),
      ),
    ),
  );
}

void setSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('SharedCollectionsPanel', () {
    testWidgets('renders panel with header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPanel(shares: _shared));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('shared_collections_panel')), findsOneWidget);
      expect(find.byKey(const Key('shared_panel_header')), findsOneWidget);
      expect(find.text('Shared With Me'), findsOneWidget);
    });

    testWidgets('shows shared collections', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPanel(shares: _shared));
      await tester.pumpAndSettle();

      expect(find.text('col-1'), findsOneWidget);
      expect(find.text('col-2'), findsOneWidget);
    });

    testWidgets('shows owner name', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPanel(shares: _shared));
      await tester.pumpAndSettle();

      expect(find.text('Shared by user-alice'), findsOneWidget);
      expect(find.text('Shared by user-bob'), findsOneWidget);
    });

    testWidgets('shows permission badge', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPanel(shares: _shared));
      await tester.pumpAndSettle();

      expect(find.text('Viewer'), findsOneWidget);
      expect(find.text('Editor'), findsOneWidget);
    });

    testWidgets('shows empty state when no shares', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('shared_empty')), findsOneWidget);
      expect(find.text('No collections shared with you'), findsOneWidget);
    });
  });
}
