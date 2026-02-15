// Widget tests for AdminHubPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/team.dart';
import 'package:codeops/models/user.dart';
import 'package:codeops/pages/admin_hub_page.dart';
import 'package:codeops/providers/admin_providers.dart';
import 'package:codeops/providers/auth_providers.dart';
import 'package:codeops/providers/team_providers.dart';

void main() {
  const testUser =
      User(id: 'u1', email: 'admin@test.com', displayName: 'Admin');

  const ownerMember = TeamMember(
    id: 'm1',
    userId: 'u1',
    role: TeamRole.owner,
    displayName: 'Admin',
  );

  const regularMember = TeamMember(
    id: 'm2',
    userId: 'u1',
    role: TeamRole.member,
    displayName: 'Admin',
  );

  Widget createWidget({
    List<TeamMember> members = const [],
    User? user,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => user ?? testUser),
        teamMembersProvider.overrideWith((ref) => Future.value(members)),
        adminUsersProvider.overrideWith(
          (ref) => Future.value(PageResponse<User>.empty()),
        ),
        systemSettingsProvider.overrideWith(
          (ref) => Future.value(<SystemSetting>[]),
        ),
        teamAuditLogProvider.overrideWith(
          (ref) => Future.value(PageResponse<AuditLogEntry>.empty()),
        ),
        usageStatsProvider.overrideWith(
          (ref) => Future.value(<String, dynamic>{}),
        ),
        adminUserSearchProvider.overrideWith((ref) => ''),
        adminUserPageProvider.overrideWith((ref) => 0),
        auditLogPageProvider.overrideWith((ref) => 0),
        auditLogActionFilterProvider.overrideWith((ref) => null),
        ...overrides,
      ],
      child: const MaterialApp(home: Scaffold(body: AdminHubPage())),
    );
  }

  group('AdminHubPage', () {
    testWidgets('shows access denied when user is not admin/owner',
        (tester) async {
      await tester.pumpWidget(createWidget(
        members: [regularMember],
        user: testUser,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
      expect(
        find.text('Admin Hub requires Owner or Admin role.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Admin Hub heading when user is owner',
        (tester) async {
      await tester.pumpWidget(createWidget(
        members: [ownerMember],
        user: testUser,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Admin Hub'), findsOneWidget);
    });

    testWidgets('shows tab bar with Users, System Settings, Audit Log, Usage Stats',
        (tester) async {
      await tester.pumpWidget(createWidget(
        members: [ownerMember],
        user: testUser,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Users'), findsOneWidget);
      expect(find.text('System Settings'), findsOneWidget);
      expect(find.text('Audit Log'), findsOneWidget);
      expect(find.text('Usage Stats'), findsOneWidget);
    });
  });
}
