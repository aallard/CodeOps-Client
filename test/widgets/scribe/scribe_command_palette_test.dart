// Tests for ScribeCommandPalette.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_command_palette.dart';
import 'package:codeops/widgets/scribe/scribe_shortcut_registry.dart';

void main() {
  final testCommands = [
    ScribeShortcutRegistry.newTab,
    ScribeShortcutRegistry.save,
    ScribeShortcutRegistry.find,
    ScribeShortcutRegistry.goToLine,
    ScribeShortcutRegistry.commandPalette,
  ];

  Widget createWidget({
    List<ScribeCommand>? commands,
    ValueChanged<ScribeCommand>? onSelect,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ScribeCommandPalette(
          commands: commands ?? testCommands,
          onSelect: onSelect ?? (_) {},
          onClose: onClose ?? () {},
        ),
      ),
    );
  }

  group('ScribeCommandPalette', () {
    testWidgets('renders search field with prompt', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('>'), findsOneWidget);
      expect(find.text('Type a command...'), findsOneWidget);
    });

    testWidgets('renders all commands initially', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('New File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Find'), findsOneWidget);
      expect(find.text('Go to Line...'), findsOneWidget);
    });

    testWidgets('shows shortcut labels', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // The command palette items with shortcuts show shortcut labels.
      // At least one should contain the text.
      final shortcutLabels = testCommands
          .where((c) => c.shortcut != null)
          .map((c) => c.shortcutLabel);
      for (final label in shortcutLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('shows command descriptions', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Create a new untitled tab'),
        findsOneWidget,
      );
      expect(
        find.text('Save the active file'),
        findsOneWidget,
      );
    });

    testWidgets('shows no results message when nothing matches',
        (tester) async {
      await tester.pumpWidget(createWidget(commands: []));
      await tester.pumpAndSettle();

      expect(find.text('No matching commands'), findsOneWidget);
    });

    testWidgets('clicking a command fires onSelect', (tester) async {
      ScribeCommand? selected;
      await tester.pumpWidget(createWidget(
        onSelect: (cmd) => selected = cmd,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New File'));
      expect(selected, isNotNull);
      expect(selected!.id, 'file.new');
    });

    testWidgets('shows category icons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // File icon for file commands.
      expect(
        find.byIcon(Icons.insert_drive_file_outlined),
        findsWidgets,
      );
      // Editor icon for editor commands.
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    });
  });
}
