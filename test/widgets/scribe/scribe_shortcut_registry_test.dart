// Tests for ScribeShortcutRegistry.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/scribe/scribe_shortcut_registry.dart';

void main() {
  group('ScribeCommand', () {
    test('shortcutLabel formats correctly for single modifier', () {
      final cmd = ScribeShortcutRegistry.newTab;
      final label = cmd.shortcutLabel;
      // Platform-dependent: Ctrl+N or Cmd+N.
      expect(label, contains('N'));
      expect(label.contains('Ctrl') || label.contains('Cmd'), isTrue);
    });

    test('shortcutLabel formats correctly for double modifier', () {
      final cmd = ScribeShortcutRegistry.commandPalette;
      final label = cmd.shortcutLabel;
      expect(label, contains('Shift'));
      expect(label, contains('P'));
    });

    test('shortcutLabel returns empty for command without shortcut', () {
      final cmd = ScribeShortcutRegistry.openUrl;
      expect(cmd.shortcutLabel, isEmpty);
    });
  });

  group('ScribeShortcutRegistry', () {
    test('commands list is not empty', () {
      expect(ScribeShortcutRegistry.commands, isNotEmpty);
    });

    test('all commands have unique IDs', () {
      final ids = ScribeShortcutRegistry.commands.map((c) => c.id).toSet();
      expect(ids.length, ScribeShortcutRegistry.commands.length);
    });

    test('commandById returns correct command', () {
      final cmd = ScribeShortcutRegistry.commandById('file.new');
      expect(cmd, isNotNull);
      expect(cmd!.label, 'New File');
    });

    test('commandById returns null for unknown ID', () {
      expect(ScribeShortcutRegistry.commandById('nonexistent'), isNull);
    });

    test('shortcutCommands returns only commands with shortcuts', () {
      final shortcuts = ScribeShortcutRegistry.shortcutCommands;
      for (final cmd in shortcuts) {
        expect(cmd.shortcut, isNotNull);
      }
    });

    test('commandsByCategory groups correctly', () {
      final categories = ScribeShortcutRegistry.commandsByCategory;
      expect(categories, contains(ScribeCommandCategory.file));
      expect(categories, contains(ScribeCommandCategory.editor));
      expect(categories, contains(ScribeCommandCategory.view));
      expect(categories, contains(ScribeCommandCategory.tabs));
    });

    test('buildBindings maps shortcuts to handlers', () {
      var called = false;
      final bindings = ScribeShortcutRegistry.buildBindings({
        'file.new': () => called = true,
      });

      expect(bindings, isNotEmpty);
      // Execute the bound callback.
      bindings.values.first();
      expect(called, isTrue);
    });

    test('buildBindings skips commands without handlers', () {
      final bindings = ScribeShortcutRegistry.buildBindings({
        'nonexistent.command': () {},
      });
      expect(bindings, isEmpty);
    });

    test('file commands include expected entries', () {
      final fileCommands = ScribeShortcutRegistry.commandsByCategory[
          ScribeCommandCategory.file]!;
      final ids = fileCommands.map((c) => c.id).toSet();
      expect(ids, contains('file.new'));
      expect(ids, contains('file.open'));
      expect(ids, contains('file.save'));
      expect(ids, contains('file.saveAs'));
      expect(ids, contains('file.saveAll'));
      expect(ids, contains('file.newDialog'));
      expect(ids, contains('file.openUrl'));
    });

    test('editor commands include find, replace, and go to line', () {
      final editorCommands = ScribeShortcutRegistry.commandsByCategory[
          ScribeCommandCategory.editor]!;
      final ids = editorCommands.map((c) => c.id).toSet();
      expect(ids, contains('editor.find'));
      expect(ids, contains('editor.findReplace'));
      expect(ids, contains('editor.goToLine'));
    });

    test('tab commands include close, next, prev, reopen', () {
      final tabCommands = ScribeShortcutRegistry.commandsByCategory[
          ScribeCommandCategory.tabs]!;
      final ids = tabCommands.map((c) => c.id).toSet();
      expect(ids, contains('tabs.close'));
      expect(ids, contains('tabs.next'));
      expect(ids, contains('tabs.prev'));
      expect(ids, contains('tabs.reopen'));
    });
  });

  group('ScribeCommandCategory', () {
    test('displayName returns readable names', () {
      expect(ScribeCommandCategory.file.displayName, 'File');
      expect(ScribeCommandCategory.editor.displayName, 'Editor');
      expect(ScribeCommandCategory.view.displayName, 'View');
      expect(ScribeCommandCategory.tabs.displayName, 'Tabs');
    });
  });
}
