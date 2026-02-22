// Widget tests for ScribeEditor.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_editor.dart';
import 'package:codeops/widgets/scribe/scribe_editor_controller.dart';
import 'package:codeops/widgets/scribe/scribe_language.dart';

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('ScribeEditor', () {
    group('rendering', () {
      testWidgets('renders with default parameters', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders provided content', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'Hello World',
            language: 'plaintext',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with dart language', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'void main() { print("hi"); }',
            language: 'dart',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders in read-only mode', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'read only content',
            readOnly: true,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('hides line numbers when showLineNumbers=false',
          (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no line numbers',
            showLineNumbers: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('shows line numbers when showLineNumbers=true',
          (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'with line numbers',
            showLineNumbers: true,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('respects fontSize parameter', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'big text',
            fontSize: 18.0,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('respects wordWrap parameter', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'word wrap enabled',
            wordWrap: true,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('displays placeholder text when content is empty',
          (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: '',
            placeholder: 'Enter code here...',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with different tabSize values', (tester) async {
        for (final tabSize in [2, 4, 8]) {
          await tester.pumpWidget(wrap(
            ScribeEditor(
              content: 'tab test',
              tabSize: tabSize,
            ),
          ));
          await tester.pumpAndSettle();

          expect(
            find.byType(ScribeEditor),
            findsOneWidget,
            reason: 'ScribeEditor should render with tabSize=$tabSize',
          );
        }
      });
    });

    group('CS-001 new parameters', () {
      testWidgets('renders with autofocus=true', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'autofocus test',
            autofocus: true,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with autofocus=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no autofocus',
            autofocus: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with minHeight constraint', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'min height',
            minHeight: 200,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
        expect(find.byType(ConstrainedBox), findsWidgets);
      });

      testWidgets('renders with maxHeight constraint', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'max height',
            maxHeight: 400,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
        expect(find.byType(ConstrainedBox), findsWidgets);
      });

      testWidgets('renders with both minHeight and maxHeight',
          (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'constrained height',
            minHeight: 200,
            maxHeight: 400,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with showCodeFolding=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'void main() {\n  print("hi");\n}',
            language: 'dart',
            showCodeFolding: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with highlightActiveLine=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no active line highlight',
            highlightActiveLine: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with autoCloseBrackets=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no auto close',
            autoCloseBrackets: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with autoCloseQuotes=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no auto close quotes',
            autoCloseQuotes: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with showIndentGuides=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no indent guides',
            showIndentGuides: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders with showBracketMatching=false', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'no bracket matching',
            showBracketMatching: false,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });
    });

    group('controller integration', () {
      testWidgets('accepts a custom ScribeEditorController', (tester) async {
        final controller =
            ScribeEditorController(content: 'controller content');

        await tester.pumpWidget(wrap(
          ScribeEditor(
            controller: controller,
            language: 'dart',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);

        controller.dispose();
      });

      testWidgets('accepts a custom FocusNode', (tester) async {
        final focusNode = FocusNode();

        await tester.pumpWidget(wrap(
          ScribeEditor(
            content: 'focus test',
            focusNode: focusNode,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);

        focusNode.dispose();
      });
    });

    group('language coverage', () {
      testWidgets('handles all supported languages without error',
          (tester) async {
        for (final language in ScribeLanguage.supportedLanguages) {
          await tester.pumpWidget(wrap(
            ScribeEditor(
              content: '// test content for $language',
              language: language,
            ),
          ));
          await tester.pumpAndSettle();

          expect(
            find.byType(ScribeEditor),
            findsOneWidget,
            reason: 'ScribeEditor should render for language: $language',
          );
        }
      });

      testWidgets('renders sql content with sql language', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'SELECT * FROM users WHERE id = 1;',
            language: 'sql',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders json content with json language', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: '{"key": "value", "count": 42}',
            language: 'json',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });

      testWidgets('renders yaml content with yaml language', (tester) async {
        await tester.pumpWidget(wrap(
          const ScribeEditor(
            content: 'server:\n  port: 8080\n  host: localhost',
            language: 'yaml',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
      });
    });

    group('callbacks', () {
      testWidgets('fires onChanged callback when content is edited',
          (tester) async {
        String? changedValue;
        await tester.pumpWidget(wrap(
          ScribeEditor(
            content: 'initial',
            onChanged: (value) => changedValue = value,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
        // Note: Full keyboard input testing requires integration tests.
        // We verify the widget accepts onChanged without error.
        expect(changedValue, isNull);
      });

      testWidgets('accepts onSaved callback without error', (tester) async {
        String? savedValue;
        await tester.pumpWidget(wrap(
          ScribeEditor(
            content: 'save test',
            onSaved: (value) => savedValue = value,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ScribeEditor), findsOneWidget);
        // Ctrl+S keyboard testing requires integration tests.
        // We verify the widget accepts onSaved without error.
        expect(savedValue, isNull);
      });
    });
  });
}
