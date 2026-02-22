/// Programmatic controller for [ScribeEditor].
///
/// Wraps [CodeLineEditingController] from re_editor to provide a clean,
/// platform-agnostic API for cursor management, text selection, content
/// manipulation, dirty tracking, and undo/redo operations.
library;

import 'package:flutter/widgets.dart';
import 'package:re_editor/re_editor.dart';

/// Controller for programmatic interaction with a [ScribeEditor].
///
/// Provides access to cursor position, text selection, scroll position,
/// content manipulation, dirty state tracking, and undo/redo operations.
///
/// Usage:
/// ```dart
/// final controller = ScribeEditorController(content: 'Hello World');
/// controller.moveCursor(line: 0, column: 5);
/// controller.insertAtCursor(' Beautiful');
/// print(controller.content); // 'Hello Beautiful World'
/// print(controller.isDirty); // true
/// controller.markClean();
/// print(controller.isDirty); // false
/// ```
class ScribeEditorController extends ChangeNotifier {
  /// The underlying re_editor controller.
  final CodeLineEditingController _inner;

  /// Whether this controller owns the inner controller and should
  /// dispose it.
  final bool _ownsInner;

  /// The current language identifier for syntax highlighting.
  String _language;

  /// Snapshot of content at last clean point (after construction or
  /// [markClean]).
  String _cleanContent;

  /// Optional focus node for requesting editor focus.
  FocusNode? _focusNode;

  /// Creates a [ScribeEditorController] with optional initial [content].
  ///
  /// The [tabSize] sets the indentation width in spaces (default 2).
  /// The [language] sets the initial syntax highlighting language.
  ScribeEditorController({
    String content = '',
    int tabSize = 2,
    String language = 'plaintext',
  })  : _inner = CodeLineEditingController.fromText(
          content,
          CodeLineOptions(indentSize: tabSize),
        ),
        _ownsInner = true,
        _language = language,
        _cleanContent = content {
    _inner.addListener(_onInnerChanged);
  }

  /// Creates a [ScribeEditorController] from an existing
  /// [CodeLineEditingController].
  ///
  /// The caller retains ownership of [inner] and must dispose it
  /// separately.
  ScribeEditorController.fromInner(
    CodeLineEditingController inner, {
    String language = 'plaintext',
  })  : _inner = inner,
        _ownsInner = false,
        _language = language,
        _cleanContent = inner.text {
    _inner.addListener(_onInnerChanged);
  }

  /// The underlying [CodeLineEditingController] for use by [ScribeEditor].
  CodeLineEditingController get inner => _inner;

  /// The current text content of the editor.
  String get content => _inner.text;

  /// Replaces the entire content via the setter.
  set content(String value) {
    _inner.text = value;
  }

  /// The current language identifier for syntax highlighting.
  ///
  /// Setting this value notifies listeners so the editor can rebuild
  /// with the new language grammar.
  String get language => _language;

  /// Sets the language and notifies listeners to trigger re-highlighting.
  set language(String value) {
    if (_language != value) {
      _language = value;
      notifyListeners();
    }
  }

  /// Whether the content has been modified since construction or the
  /// last call to [markClean].
  bool get isDirty => _inner.text != _cleanContent;

  /// Marks the current content as the clean baseline.
  ///
  /// After calling this, [isDirty] returns `false` until the content
  /// changes again.
  void markClean() {
    _cleanContent = _inner.text;
    notifyListeners();
  }

  /// Current cursor position as line and column (both 0-based).
  ///
  /// When there is an active selection, this returns the extent
  /// (caret) position.
  ({int line, int column}) get cursorPosition {
    final sel = _inner.selection;
    return (line: sel.extentIndex, column: sel.extentOffset);
  }

  /// Current text selection range, or `null` if no selection is active
  /// (i.e., the cursor is collapsed).
  ({int startLine, int startColumn, int endLine, int endColumn})?
      get selection {
    final sel = _inner.selection;
    if (sel.baseIndex == sel.extentIndex &&
        sel.baseOffset == sel.extentOffset) {
      return null;
    }
    // Normalize so start <= end.
    final int startLine;
    final int startColumn;
    final int endLine;
    final int endColumn;
    if (sel.baseIndex < sel.extentIndex ||
        (sel.baseIndex == sel.extentIndex &&
            sel.baseOffset <= sel.extentOffset)) {
      startLine = sel.baseIndex;
      startColumn = sel.baseOffset;
      endLine = sel.extentIndex;
      endColumn = sel.extentOffset;
    } else {
      startLine = sel.extentIndex;
      startColumn = sel.extentOffset;
      endLine = sel.baseIndex;
      endColumn = sel.baseOffset;
    }
    return (
      startLine: startLine,
      startColumn: startColumn,
      endLine: endLine,
      endColumn: endColumn,
    );
  }

  /// Moves the cursor to a specific [line] and [column] (both 0-based).
  ///
  /// The [column] defaults to 0 (beginning of line).
  void moveCursor({required int line, int column = 0}) {
    _inner.selection = CodeLineSelection.collapsed(
      index: line,
      offset: column,
    );
  }

  /// Selects a range of text from [startLine]:[startColumn] to
  /// [endLine]:[endColumn].
  void select({
    required int startLine,
    required int startColumn,
    required int endLine,
    required int endColumn,
  }) {
    _inner.selection = CodeLineSelection(
      baseIndex: startLine,
      baseOffset: startColumn,
      extentIndex: endLine,
      extentOffset: endColumn,
    );
  }

  /// Selects all text in the editor.
  void selectAll() {
    _inner.selectAll();
  }

  /// Inserts [text] at the current cursor position.
  ///
  /// If there is an active selection, the selected text is replaced.
  void insertAtCursor(String text) {
    _inner.replaceSelection(text);
  }

  /// Replaces the current selection with [text].
  ///
  /// If no selection is active, inserts at the cursor position.
  void replaceSelection(String text) {
    _inner.replaceSelection(text);
  }

  /// Replaces the entire content with [newContent].
  ///
  /// Resets the cursor to the beginning of the document.
  void replaceContent(String newContent) {
    _inner.text = newContent;
  }

  /// Returns the currently selected text, or an empty string if no
  /// selection is active.
  String get selectedText => _inner.selectedText;

  /// Undoes the last edit.
  ///
  /// Returns `true` if an undo operation was performed.
  bool undo() {
    if (!_inner.canUndo) return false;
    _inner.undo();
    return true;
  }

  /// Redoes the last undone edit.
  ///
  /// Returns `true` if a redo operation was performed.
  bool redo() {
    if (!_inner.canRedo) return false;
    _inner.redo();
    return true;
  }

  /// Whether an undo operation is available.
  bool get canUndo => _inner.canUndo;

  /// Whether a redo operation is available.
  bool get canRedo => _inner.canRedo;

  /// Total number of lines in the editor.
  int get lineCount => _inner.lineCount;

  /// Associates a [FocusNode] with this controller for [focus] calls.
  ///
  /// Called internally by [ScribeEditor] during initialization.
  set focusNode(FocusNode? node) => _focusNode = node;

  /// Requests keyboard focus for the editor.
  void focus() {
    _focusNode?.requestFocus();
  }

  void _onInnerChanged() {
    notifyListeners();
  }

  /// Releases all resources held by this controller.
  @override
  void dispose() {
    _inner.removeListener(_onInnerChanged);
    if (_ownsInner) {
      _inner.dispose();
    }
    super.dispose();
  }
}
