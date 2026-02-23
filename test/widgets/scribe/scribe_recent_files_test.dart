// Tests for ScribeRecentFiles panel widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_recent_files.dart';

void main() {
  Widget createWidget({
    List<String>? recentFiles,
    ValueChanged<String>? onOpen,
    ValueChanged<String>? onRemove,
    VoidCallback? onClearAll,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Row(
          children: [
            ScribeRecentFiles(
              recentFiles: recentFiles ?? [],
              onOpen: onOpen ?? (_) {},
              onRemove: onRemove ?? (_) {},
              onClearAll: onClearAll ?? () {},
              onClose: onClose ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  group('ScribeRecentFiles', () {
    testWidgets('displays header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Files'), findsOneWidget);
    });

    testWidgets('displays empty state when no files', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('No recent files'), findsOneWidget);
    });

    testWidgets('displays file names from paths', (tester) async {
      await tester.pumpWidget(createWidget(
        recentFiles: ['/home/user/test.dart', '/home/user/main.dart'],
      ));
      await tester.pumpAndSettle();

      expect(find.text('test.dart'), findsOneWidget);
      expect(find.text('main.dart'), findsOneWidget);
    });

    testWidgets('close button fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(createWidget(
        onClose: () => closed = true,
      ));
      await tester.pumpAndSettle();

      // The close icon in the header.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('shows Clear All button when files exist', (tester) async {
      await tester.pumpWidget(createWidget(
        recentFiles: ['/path/file.dart'],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('Clear All button fires onClearAll', (tester) async {
      var cleared = false;
      await tester.pumpWidget(createWidget(
        recentFiles: ['/path/file.dart'],
        onClearAll: () => cleared = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
    });

    testWidgets('does not show Clear All when empty', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Clear All'), findsNothing);
    });

    testWidgets('search filters files', (tester) async {
      await tester.pumpWidget(createWidget(
        recentFiles: ['/path/apple.dart', '/path/banana.txt'],
      ));
      await tester.pumpAndSettle();

      expect(find.text('apple.dart'), findsOneWidget);
      expect(find.text('banana.txt'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'apple',
      );
      await tester.pumpAndSettle();

      expect(find.text('apple.dart'), findsOneWidget);
      expect(find.text('banana.txt'), findsNothing);
    });

    testWidgets('search with no matches shows empty state', (tester) async {
      await tester.pumpWidget(createWidget(
        recentFiles: ['/path/file.dart'],
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();

      expect(find.text('No matching files'), findsOneWidget);
    });
  });
}
