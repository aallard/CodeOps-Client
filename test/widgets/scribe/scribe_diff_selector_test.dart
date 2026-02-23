// Tests for ScribeDiffSelector widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_diff_selector.dart';

void main() {
  final now = DateTime.now();
  final testTabs = [
    ScribeTab(
      id: 'tab-1',
      title: 'file1.dart',
      content: 'content 1',
      createdAt: now,
      lastModifiedAt: now,
    ),
    ScribeTab(
      id: 'tab-2',
      title: 'file2.dart',
      content: 'content 2',
      createdAt: now,
      lastModifiedAt: now,
    ),
    ScribeTab(
      id: 'tab-3',
      title: 'file3.dart',
      content: 'content 3',
      createdAt: now,
      lastModifiedAt: now,
    ),
  ];

  Widget createWidget({
    List<ScribeTab>? tabs,
    String? initialLeftTabId,
    String? initialRightTabId,
    void Function(String, String)? onCompare,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ScribeDiffSelector(
          tabs: tabs ?? testTabs,
          initialLeftTabId: initialLeftTabId,
          initialRightTabId: initialRightTabId,
          onCompare: onCompare ?? (_, __) {},
          onClose: onClose ?? () {},
        ),
      ),
    );
  }

  group('ScribeDiffSelector', () {
    testWidgets('renders Original and Modified labels', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Original'), findsOneWidget);
      expect(find.text('Modified'), findsOneWidget);
    });

    testWidgets('renders Compare button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Compare'), findsOneWidget);
    });

    testWidgets('renders swap button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('renders close button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close button fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(createWidget(
        onClose: () => closed = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('Compare button disabled when no tabs selected',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Find the ElevatedButton and check it's disabled.
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Compare'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
