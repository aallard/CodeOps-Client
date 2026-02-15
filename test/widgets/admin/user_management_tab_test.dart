// Widget tests for UserManagementTab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/user.dart';
import 'package:codeops/providers/admin_providers.dart';
import 'package:codeops/widgets/admin/user_management_tab.dart';

void main() {
  const testUser = User(
    id: 'u1',
    email: 'alice@test.com',
    displayName: 'Alice',
    isActive: true,
  );

  final testPage = PageResponse<User>(
    content: [testUser],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
    isLast: true,
  );

  Widget createWidget({
    PageResponse<User>? pageResponse,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        adminUsersProvider.overrideWith(
          (ref) => Future.value(pageResponse ?? testPage),
        ),
        adminUserSearchProvider.overrideWith((ref) => ''),
        adminUserPageProvider.overrideWith((ref) => 0),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(child: UserManagementTab()),
          ),
        ),
      ),
    );
  }

  group('UserManagementTab', () {
    testWidgets('renders search bar', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by name or email...'), findsOneWidget);
    });

    testWidgets('shows user data table with name and email', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@test.com'), findsOneWidget);
    });

    testWidgets('shows empty message when no users', (tester) async {
      await tester.pumpWidget(createWidget(
        pageResponse: PageResponse<User>(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
          isLast: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No users found.'), findsOneWidget);
    });

    testWidgets('shows Active status badge', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
    });
  });
}
