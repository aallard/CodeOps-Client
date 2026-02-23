// Tests for ScribeFileChangedBanner widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_file_changed_banner.dart';

void main() {
  Widget createWidget({
    String fileName = 'test.dart',
    VoidCallback? onReload,
    VoidCallback? onKeep,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ScribeFileChangedBanner(
          fileName: fileName,
          onReload: onReload ?? () {},
          onKeep: onKeep ?? () {},
        ),
      ),
    );
  }

  group('ScribeFileChangedBanner', () {
    testWidgets('displays file name in message', (tester) async {
      await tester.pumpWidget(createWidget(fileName: 'config.yaml'));
      await tester.pumpAndSettle();

      expect(find.textContaining('config.yaml'), findsOneWidget);
    });

    testWidgets('displays warning message', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('has been changed on disk'), findsOneWidget);
    });

    testWidgets('displays warning icon', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('Reload button fires onReload', (tester) async {
      var reloaded = false;
      await tester.pumpWidget(createWidget(onReload: () => reloaded = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reload'));
      await tester.pumpAndSettle();

      expect(reloaded, isTrue);
    });

    testWidgets('Keep button fires onKeep', (tester) async {
      var kept = false;
      await tester.pumpWidget(createWidget(onKeep: () => kept = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();

      expect(kept, isTrue);
    });

    testWidgets('renders both Reload and Keep buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reload'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
    });
  });
}
