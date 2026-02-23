// Tests for ScribeUrlDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_url_dialog.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeUrlDialog', () {
    testWidgets('shows title, URL field, and buttons', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeUrlDialog.show(
              context,
              fetchContent: (_) async => '',
            ),
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Open from URL'), findsOneWidget);
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('Fetch'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel returns null', (tester) async {
      ScribeUrlResult? result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeUrlDialog.show(
                context,
                fetchContent: (_) async => '',
              );
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('shows error for empty URL', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeUrlDialog.show(
              context,
              fetchContent: (_) async => '',
            ),
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      // Tap Fetch without entering a URL.
      await tester.tap(find.text('Fetch'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a URL.'), findsOneWidget);
    });

    testWidgets('shows error for invalid URL scheme', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeUrlDialog.show(
              context,
              fetchContent: (_) async => '',
            ),
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ftp://bad.com/file');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fetch'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid HTTP or HTTPS URL.'),
        findsOneWidget,
      );
    });

    testWidgets('returns result on successful fetch', (tester) async {
      late ScribeUrlResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              final r = await ScribeUrlDialog.show(
                context,
                fetchContent: (_) async => 'fetched content',
              );
              if (r != null) result = r;
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'https://example.com/file.dart',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fetch'));
      await tester.pumpAndSettle();

      expect(result.url, 'https://example.com/file.dart');
      expect(result.content, 'fetched content');
    });

    testWidgets('shows error when fetch fails', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeUrlDialog.show(
              context,
              fetchContent: (_) async => throw Exception('Network error'),
            ),
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'https://example.com/fail',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fetch'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to fetch'), findsOneWidget);
    });
  });
}
