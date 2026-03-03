// Widget tests for ShareCollectionDialog.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/models/courier_models.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/team.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/widgets/courier/share_collection_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _members = [
  TeamMember(id: 'm1', userId: 'u1', displayName: 'Alice', email: 'alice@test.com', role: TeamRole.admin),
  TeamMember(id: 'm2', userId: 'u2', displayName: 'Bob', email: 'bob@test.com', role: TeamRole.member),
];

final _shares = [
  CollectionShareResponse(
    id: 's1',
    collectionId: 'col-1',
    sharedWithUserId: 'u2',
    sharedByUserId: 'u1',
    permission: SharePermission.viewer,
  ),
];

Widget buildShareDialog({
  List<TeamMember> members = const [],
  List<CollectionShareResponse> shares = const [],
}) {
  return ProviderScope(
    overrides: [
      teamMembersProvider.overrideWith((ref) => members),
      courierCollectionSharesProvider('col-1').overrideWith((ref) => shares),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const ShareCollectionDialog(
                  collectionId: 'col-1',
                  collectionName: 'User API',
                ),
              );
            },
            child: const Text('Open'),
          ),
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
  group('ShareCollectionDialog', () {
    testWidgets('renders dialog with header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildShareDialog(members: _members));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('share_collection_dialog')), findsOneWidget);
      expect(find.textContaining('Share'), findsWidgets);
    });

    testWidgets('shows user search field', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildShareDialog(members: _members));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('share_user_search')), findsOneWidget);
    });

    testWidgets('shows permission selector', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildShareDialog(members: _members));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('share_permission_selector')), findsOneWidget);
    });

    testWidgets('shows current shares list', (tester) async {
      setSize(tester);
      await tester.pumpWidget(
          buildShareDialog(members: _members, shares: _shares));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('current_shares_list')), findsOneWidget);
    });

    testWidgets('shows copy link button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildShareDialog(members: _members));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('copy_link_button')), findsOneWidget);
    });
  });
}
