// Tests for ScribeMarkdownPreview widget.
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_markdown_preview.dart';

void main() {
  Widget createWidget({
    required String content,
    ScrollController? scrollController,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ScribeMarkdownPreview(
          content: content,
          scrollController: scrollController,
        ),
      ),
    );
  }

  group('ScribeMarkdownPreview', () {
    testWidgets('renders markdown content', (tester) async {
      await tester.pumpWidget(createWidget(content: '# Hello'));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders paragraph text', (tester) async {
      await tester.pumpWidget(createWidget(
        content: 'This is a paragraph.',
      ));
      await tester.pumpAndSettle();

      expect(find.text('This is a paragraph.'), findsOneWidget);
    });

    testWidgets('renders bold text', (tester) async {
      await tester.pumpWidget(createWidget(content: '**bold**'));
      await tester.pumpAndSettle();

      expect(find.text('bold'), findsOneWidget);
    });

    testWidgets('contains a Markdown widget', (tester) async {
      await tester.pumpWidget(createWidget(content: '# Test'));
      await tester.pumpAndSettle();

      expect(find.byType(Markdown), findsOneWidget);
    });

    testWidgets('debounces content updates', (tester) async {
      await tester.pumpWidget(createWidget(content: 'Initial'));
      await tester.pumpAndSettle();

      expect(find.text('Initial'), findsOneWidget);

      // Update content.
      await tester.pumpWidget(createWidget(content: 'Updated'));
      // Don't wait for settle — debounce not fired yet.
      await tester.pump(const Duration(milliseconds: 100));

      // Should still show old content (debounce is 300ms).
      expect(find.text('Initial'), findsOneWidget);

      // Wait for debounce to fire.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Updated'), findsOneWidget);
    });

    testWidgets('renders list items', (tester) async {
      await tester.pumpWidget(createWidget(
        content: '- Item 1\n- Item 2',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });
}
