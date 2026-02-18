/// Data models for the Scribe editor.
///
/// Contains [ScribeTab] representing an open editor tab and
/// [ScribeSettings] for persistent editor configuration.
library;

import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../widgets/scribe/scribe_language.dart';

/// Represents a single open tab in the Scribe editor.
///
/// Each tab holds its content, language mode, cursor position, and
/// dirty state. Tabs are identified by a unique [id] and displayed
/// with their [title] in the tab bar.
class ScribeTab {
  /// Unique identifier for this tab (UUID).
  final String id;

  /// Display title (file name or "Untitled-N").
  final String title;

  /// The full file path if opened from disk, null if new/unsaved.
  final String? filePath;

  /// Current content of the editor.
  final String content;

  /// Language identifier for syntax highlighting (e.g., 'dart', 'sql').
  final String language;

  /// Whether content has been modified since last save.
  final bool isDirty;

  /// Cursor line position (0-based).
  final int cursorLine;

  /// Cursor column position (0-based).
  final int cursorColumn;

  /// Scroll offset for restoring scroll position on tab switch.
  final double scrollOffset;

  /// Timestamp when this tab was created.
  final DateTime createdAt;

  /// Timestamp of last content modification.
  final DateTime lastModifiedAt;

  /// Creates a [ScribeTab] with all fields.
  const ScribeTab({
    required this.id,
    required this.title,
    this.filePath,
    this.content = '',
    this.language = 'plaintext',
    this.isDirty = false,
    this.cursorLine = 0,
    this.cursorColumn = 0,
    this.scrollOffset = 0.0,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  /// Creates a new empty tab with auto-incrementing title.
  factory ScribeTab.untitled(int number) {
    final now = DateTime.now();
    return ScribeTab(
      id: const Uuid().v4(),
      title: 'Untitled-$number',
      content: '',
      language: 'plaintext',
      createdAt: now,
      lastModifiedAt: now,
    );
  }

  /// Creates a tab from an opened file.
  ///
  /// Detects the language from the file extension using
  /// [ScribeLanguage.fromFileName].
  factory ScribeTab.fromFile({
    required String filePath,
    required String content,
  }) {
    final now = DateTime.now();
    final lastSlash = filePath.lastIndexOf('/');
    final fileName =
        lastSlash >= 0 ? filePath.substring(lastSlash + 1) : filePath;
    final language = ScribeLanguage.fromFileName(filePath);
    return ScribeTab(
      id: const Uuid().v4(),
      title: fileName,
      filePath: filePath,
      content: content,
      language: language,
      createdAt: now,
      lastModifiedAt: now,
    );
  }

  /// Creates a copy of this tab with the given fields replaced.
  ScribeTab copyWith({
    String? id,
    String? title,
    String? filePath,
    String? content,
    String? language,
    bool? isDirty,
    int? cursorLine,
    int? cursorColumn,
    double? scrollOffset,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return ScribeTab(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      language: language ?? this.language,
      isDirty: isDirty ?? this.isDirty,
      cursorLine: cursorLine ?? this.cursorLine,
      cursorColumn: cursorColumn ?? this.cursorColumn,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  /// Serializes this tab to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'content': content,
      'language': language,
      'isDirty': isDirty,
      'cursorLine': cursorLine,
      'cursorColumn': cursorColumn,
      'scrollOffset': scrollOffset,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  /// Deserializes a [ScribeTab] from a JSON-compatible map.
  factory ScribeTab.fromJson(Map<String, dynamic> json) {
    return ScribeTab(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String?,
      content: json['content'] as String? ?? '',
      language: json['language'] as String? ?? 'plaintext',
      isDirty: json['isDirty'] as bool? ?? false,
      cursorLine: json['cursorLine'] as int? ?? 0,
      cursorColumn: json['cursorColumn'] as int? ?? 0,
      scrollOffset: (json['scrollOffset'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ScribeTab && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Settings for the Scribe editor that persist across sessions.
class ScribeSettings {
  /// Font size (12.0 - 24.0). Default: 14.0.
  final double fontSize;

  /// Tab size (2, 4, or 8). Default: 2.
  final int tabSize;

  /// Use spaces instead of tabs. Default: true.
  final bool insertSpaces;

  /// Enable word wrap. Default: false.
  final bool wordWrap;

  /// Show line numbers. Default: true.
  final bool showLineNumbers;

  /// Show minimap. Default: false.
  final bool showMinimap;

  /// Creates [ScribeSettings] with sensible defaults.
  const ScribeSettings({
    this.fontSize = 14.0,
    this.tabSize = 2,
    this.insertSpaces = true,
    this.wordWrap = false,
    this.showLineNumbers = true,
    this.showMinimap = false,
  });

  /// Creates a copy of these settings with the given fields replaced.
  ScribeSettings copyWith({
    double? fontSize,
    int? tabSize,
    bool? insertSpaces,
    bool? wordWrap,
    bool? showLineNumbers,
    bool? showMinimap,
  }) {
    return ScribeSettings(
      fontSize: fontSize ?? this.fontSize,
      tabSize: tabSize ?? this.tabSize,
      insertSpaces: insertSpaces ?? this.insertSpaces,
      wordWrap: wordWrap ?? this.wordWrap,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      showMinimap: showMinimap ?? this.showMinimap,
    );
  }

  /// Serializes these settings to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'tabSize': tabSize,
      'insertSpaces': insertSpaces,
      'wordWrap': wordWrap,
      'showLineNumbers': showLineNumbers,
      'showMinimap': showMinimap,
    };
  }

  /// Serializes these settings to a JSON string.
  String toJsonString() => jsonEncode(toJson());

  /// Deserializes [ScribeSettings] from a JSON-compatible map.
  factory ScribeSettings.fromJson(Map<String, dynamic> json) {
    return ScribeSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      tabSize: json['tabSize'] as int? ?? 2,
      insertSpaces: json['insertSpaces'] as bool? ?? true,
      wordWrap: json['wordWrap'] as bool? ?? false,
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      showMinimap: json['showMinimap'] as bool? ?? false,
    );
  }

  /// Deserializes [ScribeSettings] from a JSON string.
  factory ScribeSettings.fromJsonString(String jsonString) {
    return ScribeSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}
