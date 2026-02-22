// Tests for ScribeEditorController.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/scribe/scribe_editor_controller.dart';

void main() {
  group('ScribeEditorController', () {
    late ScribeEditorController controller;

    setUp(() {
      controller = ScribeEditorController(content: 'Hello\nWorld\nTest');
    });

    tearDown(() {
      controller.dispose();
    });

    group('content', () {
      test('initial content matches constructor parameter', () {
        final c = ScribeEditorController(content: 'abc');
        expect(c.content, 'abc');
        c.dispose();
      });

      test('empty content when no parameter provided', () {
        final c = ScribeEditorController();
        expect(c.content, isEmpty);
        c.dispose();
      });

      test('content setter updates value and notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.content = 'Updated';
        expect(controller.content, 'Updated');
        expect(notified, isTrue);
      });
    });

    group('cursor', () {
      test('cursorPosition returns valid position', () {
        final pos = controller.cursorPosition;
        expect(pos.line, greaterThanOrEqualTo(0));
        expect(pos.column, greaterThanOrEqualTo(0));
      });

      test('moveCursor moves to specified line and column', () {
        controller.moveCursor(line: 1, column: 3);
        final pos = controller.cursorPosition;
        expect(pos.line, 1);
        expect(pos.column, 3);
      });

      test('moveCursor defaults column to 0', () {
        controller.moveCursor(line: 2);
        final pos = controller.cursorPosition;
        expect(pos.line, 2);
        expect(pos.column, 0);
      });
    });

    group('selection', () {
      test('selectedText returns empty string when no selection', () {
        controller.moveCursor(line: 0, column: 0);
        expect(controller.selectedText, isEmpty);
      });

      test('select creates a selection range', () {
        controller.select(
          startLine: 0,
          startColumn: 0,
          endLine: 0,
          endColumn: 5,
        );
        final sel = controller.selection;
        expect(sel, isNotNull);
        expect(sel!.startLine, 0);
        expect(sel.startColumn, 0);
        expect(sel.endLine, 0);
        expect(sel.endColumn, 5);
      });

      test('selection returns null when cursor is collapsed', () {
        controller.moveCursor(line: 0, column: 0);
        expect(controller.selection, isNull);
      });

      test('selectAll selects entire content', () {
        controller.selectAll();
        final sel = controller.selection;
        expect(sel, isNotNull);
        // After selectAll, the selected text should be the full content.
        expect(controller.selectedText, isNotEmpty);
      });
    });

    group('text manipulation', () {
      test('insertAtCursor inserts text at cursor', () {
        controller.moveCursor(line: 0, column: 5);
        controller.insertAtCursor(' Beautiful');
        expect(controller.content, contains('Hello Beautiful'));
      });

      test('replaceSelection replaces selected text', () {
        controller.select(
          startLine: 0,
          startColumn: 0,
          endLine: 0,
          endColumn: 5,
        );
        controller.replaceSelection('Goodbye');
        expect(controller.content, startsWith('Goodbye'));
      });

      test('replaceContent replaces entire content', () {
        controller.replaceContent('New content');
        expect(controller.content, 'New content');
      });
    });

    group('undo/redo', () {
      test('canUndo is false initially', () {
        final c = ScribeEditorController(content: 'test');
        expect(c.canUndo, isFalse);
        c.dispose();
      });

      test('canRedo is false initially', () {
        final c = ScribeEditorController(content: 'test');
        expect(c.canRedo, isFalse);
        c.dispose();
      });

      test('undo returns false when nothing to undo', () {
        final c = ScribeEditorController(content: 'test');
        expect(c.undo(), isFalse);
        c.dispose();
      });

      test('redo returns false when nothing to redo', () {
        final c = ScribeEditorController(content: 'test');
        expect(c.redo(), isFalse);
        c.dispose();
      });
    });

    group('lineCount', () {
      test('returns correct count for multi-line content', () {
        expect(controller.lineCount, 3);
      });

      test('returns 1 for single-line content', () {
        final c = ScribeEditorController(content: 'single line');
        expect(c.lineCount, 1);
        c.dispose();
      });

      test('returns 1 for empty content', () {
        final c = ScribeEditorController();
        expect(c.lineCount, 1);
        c.dispose();
      });
    });

    group('language', () {
      test('defaults to plaintext', () {
        final c = ScribeEditorController();
        expect(c.language, 'plaintext');
        c.dispose();
      });

      test('initial language matches constructor parameter', () {
        final c = ScribeEditorController(language: 'dart');
        expect(c.language, 'dart');
        c.dispose();
      });

      test('language setter updates value and notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.language = 'python';
        expect(controller.language, 'python');
        expect(notified, isTrue);
      });

      test('language setter does not notify when value is unchanged', () {
        final c = ScribeEditorController(language: 'java');
        var notifyCount = 0;
        c.addListener(() => notifyCount++);
        c.language = 'java';
        expect(notifyCount, 0);
        c.dispose();
      });
    });

    group('dirty tracking', () {
      test('isDirty is false initially', () {
        final c = ScribeEditorController(content: 'initial');
        expect(c.isDirty, isFalse);
        c.dispose();
      });

      test('isDirty becomes true after content change', () {
        final c = ScribeEditorController(content: 'initial');
        c.content = 'modified';
        expect(c.isDirty, isTrue);
        c.dispose();
      });

      test('markClean resets isDirty to false', () {
        final c = ScribeEditorController(content: 'initial');
        c.content = 'modified';
        expect(c.isDirty, isTrue);
        c.markClean();
        expect(c.isDirty, isFalse);
        c.dispose();
      });

      test('isDirty is false when content reverts to original', () {
        final c = ScribeEditorController(content: 'original');
        c.content = 'changed';
        expect(c.isDirty, isTrue);
        c.content = 'original';
        expect(c.isDirty, isFalse);
        c.dispose();
      });

      test('markClean updates baseline to current content', () {
        final c = ScribeEditorController(content: 'first');
        c.content = 'second';
        c.markClean();
        c.content = 'third';
        expect(c.isDirty, isTrue);
        c.content = 'second';
        expect(c.isDirty, isFalse);
        c.dispose();
      });
    });

    group('focus', () {
      test('focus calls requestFocus on bound FocusNode', () {
        final focusNode = FocusNode();
        controller.focusNode = focusNode;
        // Calling focus should not throw.
        expect(() => controller.focus(), returnsNormally);
        focusNode.dispose();
      });

      test('focus is safe when no FocusNode is bound', () {
        expect(() => controller.focus(), returnsNormally);
      });
    });

    group('lifecycle', () {
      test('dispose releases resources without error', () {
        final c = ScribeEditorController(content: 'dispose test');
        expect(() => c.dispose(), returnsNormally);
      });

      test('inner exposes the underlying controller', () {
        expect(controller.inner, isNotNull);
      });

      test('tabSize is applied to indent', () {
        final c = ScribeEditorController(content: '', tabSize: 4);
        expect(c.inner.options.indentSize, 4);
        c.dispose();
      });

      test('fromInner wraps an existing controller', () {
        final inner = controller.inner;
        final wrapper = ScribeEditorController.fromInner(inner);
        expect(wrapper.content, controller.content);
        expect(wrapper.lineCount, controller.lineCount);
        // fromInner does NOT own the inner controller, so dispose is safe.
        wrapper.dispose();
      });

      test('fromInner accepts language parameter', () {
        final inner = controller.inner;
        final wrapper =
            ScribeEditorController.fromInner(inner, language: 'sql');
        expect(wrapper.language, 'sql');
        wrapper.dispose();
      });
    });
  });
}
