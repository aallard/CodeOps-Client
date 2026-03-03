// Tests for PreferencesPage widget.
//
// Verifies section navigation, section rendering, and preference controls.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/pages/settings/preferences_page.dart';

void main() {
  Widget buildPage({List<Override>? overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: const MaterialApp(
        home: Scaffold(body: PreferencesPage()),
      ),
    );
  }

  group('PreferencesPage', () {
    testWidgets('renders 6 section labels in sidebar', (tester) async {
      await tester.pumpWidget(buildPage());

      // "Appearance" appears twice: sidebar label + section title header.
      expect(find.text('Appearance'), findsAtLeast(1));
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Navigation'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Module Defaults'), findsOneWidget);
      expect(find.text('Data & Privacy'), findsOneWidget);
    });

    testWidgets('shows Appearance section by default', (tester) async {
      await tester.pumpWidget(buildPage());

      // Appearance section has a Theme label.
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('tapping Editor shows editor section', (tester) async {
      await tester.pumpWidget(buildPage());

      await tester.tap(find.text('Editor'));
      await tester.pumpAndSettle();

      expect(find.text('Editor (Scribe)'), findsOneWidget);
      expect(find.text('Tab Size'), findsOneWidget);
    });

    testWidgets('tapping Navigation shows navigation section', (tester) async {
      await tester.pumpWidget(buildPage());

      await tester.tap(find.text('Navigation'));
      await tester.pumpAndSettle();

      expect(find.text('Default Landing Page'), findsOneWidget);
    });

    testWidgets('tapping Notifications shows notification section',
        (tester) async {
      await tester.pumpWidget(buildPage());

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Desktop Notifications'), findsOneWidget);
    });

    testWidgets('tapping Module Defaults shows module defaults section',
        (tester) async {
      await tester.pumpWidget(buildPage());

      await tester.tap(find.text('Module Defaults'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Logger'), findsWidgets);
    });

    testWidgets('tapping Data & Privacy shows data section', (tester) async {
      await tester.pumpWidget(buildPage());

      await tester.tap(find.text('Data & Privacy'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Local Cache'), findsOneWidget);
      expect(find.text('Clear Search History'), findsOneWidget);
    });
  });
}
