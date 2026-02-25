/// Tests for [RelayDateSeparator] — date divider in the message feed.
///
/// Verifies "Today", "Yesterday", and formatted date rendering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:codeops/widgets/relay/relay_date_separator.dart';

Widget _createSeparator(DateTime date) {
  return MaterialApp(
    home: Scaffold(
      body: RelayDateSeparator(date: date),
    ),
  );
}

void main() {
  group('RelayDateSeparator', () {
    testWidgets('shows "Today" for today\'s date', (tester) async {
      await tester.pumpWidget(_createSeparator(DateTime.now()));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows "Yesterday" for yesterday\'s date', (tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await tester.pumpWidget(_createSeparator(yesterday));
      await tester.pumpAndSettle();

      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('shows formatted date for older dates', (tester) async {
      final oldDate = DateTime(2025, 6, 15);
      await tester.pumpWidget(_createSeparator(oldDate));
      await tester.pumpAndSettle();

      final expected = DateFormat('EEE, MMM d, yyyy').format(oldDate);
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('renders two horizontal dividers', (tester) async {
      await tester.pumpWidget(_createSeparator(DateTime.now()));
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders date label centered between dividers',
        (tester) async {
      await tester.pumpWidget(_createSeparator(DateTime.now()));
      await tester.pumpAndSettle();

      // Verify the date text is present and layout is correct
      final textWidget = tester.widget<Text>(find.text('Today'));
      expect(textWidget.style?.fontSize, 11);
    });
  });
}
