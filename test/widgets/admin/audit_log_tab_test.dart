// Widget tests for AuditLogTab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/admin_providers.dart';
import 'package:codeops/widgets/admin/audit_log_tab.dart';

void main() {
  const testEntry = AuditLogEntry(
    id: 1,
    action: 'LOGIN',
    userId: 'u1',
    userName: 'Alice',
  );

  final testPage = PageResponse<AuditLogEntry>(
    content: [testEntry],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
    isLast: true,
  );

  Widget createWidget({
    PageResponse<AuditLogEntry>? pageResponse,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        teamAuditLogProvider.overrideWith(
          (ref) => Future.value(pageResponse ?? testPage),
        ),
        auditLogActionFilterProvider.overrideWith((ref) => null),
        auditLogPageProvider.overrideWith((ref) => 0),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: AuditLogTab()),
        ),
      ),
    );
  }

  group('AuditLogTab', () {
    testWidgets('shows action filter dropdown', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('All Actions'), findsOneWidget);
    });

    testWidgets('shows audit entries in table', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('shows empty message when no entries', (tester) async {
      await tester.pumpWidget(createWidget(
        pageResponse: PageResponse<AuditLogEntry>(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
          isLast: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No audit log entries found.'), findsOneWidget);
    });

    testWidgets('shows data table column headers', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Action'), findsWidgets);
      expect(find.text('Entity Type'), findsOneWidget);
    });
  });
}
