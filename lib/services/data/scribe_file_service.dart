/// File I/O service for the Scribe editor.
///
/// Handles opening, saving, and reading files from disk and URLs.
/// Manages recent file tracking with persistence via
/// [ScribePersistenceService].
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/scribe_models.dart';
import '../../services/logging/log_service.dart';
import '../../utils/constants.dart';
import 'scribe_persistence_service.dart';

/// Service for file I/O operations in the Scribe editor.
///
/// Provides methods to open files from disk (single or multi-select),
/// save files, save-as with a native dialog, fetch content from URLs,
/// and track recently opened files.
class ScribeFileService {
  static const String _tag = 'ScribeFileService';

  final ScribePersistenceService _persistence;
  final Dio _dio;

  /// Creates a [ScribeFileService].
  ScribeFileService(this._persistence, this._dio);

  // ---------------------------------------------------------------------------
  // Open files
  // ---------------------------------------------------------------------------

  /// Opens a native file picker and returns tabs for each selected file.
  ///
  /// Returns an empty list if the user cancels or selects no files.
  /// Files exceeding [AppConstants.scribeMaxFileSizeBytes] are skipped
  /// with a warning logged.
  Future<List<ScribeTab>> openFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return [];

    final tabs = <ScribeTab>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;

      final ioFile = File(path);
      final stat = await ioFile.stat();
      if (stat.size > AppConstants.scribeMaxFileSizeBytes) {
        log.w(_tag, 'Skipping file (too large): $path '
            '(${stat.size} bytes > ${AppConstants.scribeMaxFileSizeBytes})');
        continue;
      }

      try {
        final content = await ioFile.readAsString();
        tabs.add(ScribeTab.fromFile(filePath: path, content: content));
      } on FormatException catch (e) {
        log.w(_tag, 'Skipping binary/unreadable file: $path', e);
      }
    }

    return tabs;
  }

  // ---------------------------------------------------------------------------
  // Save operations
  // ---------------------------------------------------------------------------

  /// Saves the tab content to its existing [ScribeTab.filePath].
  ///
  /// Returns `true` on success, `false` if the tab has no file path
  /// or if the write fails.
  Future<bool> saveFile(ScribeTab tab) async {
    if (tab.filePath == null) return false;

    try {
      await File(tab.filePath!).writeAsString(tab.content);
      log.i(_tag, 'Saved: ${tab.filePath}');
      return true;
    } on FileSystemException catch (e) {
      log.e(_tag, 'Failed to save file: ${tab.filePath}', e);
      return false;
    }
  }

  /// Opens a native "Save As" dialog and writes the tab content.
  ///
  /// Returns the chosen file path on success, or `null` if the user
  /// cancels or the write fails. The [suggestedName] defaults to the
  /// tab's current title.
  Future<String?> saveFileAs(ScribeTab tab, {String? suggestedName}) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save As',
      fileName: suggestedName ?? tab.title,
    );
    if (outputPath == null) return null;

    try {
      await File(outputPath).writeAsString(tab.content);
      log.i(_tag, 'Saved as: $outputPath');
      return outputPath;
    } on FileSystemException catch (e) {
      log.e(_tag, 'Failed to save as: $outputPath', e);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // URL fetching
  // ---------------------------------------------------------------------------

  /// Fetches text content from a [url].
  ///
  /// Validates the response content-type is text-based. Returns the
  /// fetched content on success, or throws an [Exception] on failure.
  Future<String> readFromUrl(String url) async {
    log.i(_tag, 'Fetching URL: $url');

    final response = await _dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    final contentType = response.headers.value('content-type') ?? '';
    final isText = contentType.contains('text/') ||
        contentType.contains('application/json') ||
        contentType.contains('application/xml') ||
        contentType.contains('application/yaml') ||
        contentType.contains('application/javascript') ||
        contentType.contains('application/typescript') ||
        contentType.isEmpty;

    if (!isText) {
      throw Exception('Unsupported content type: $contentType');
    }

    return response.data ?? '';
  }

  /// Extracts a file name from a URL path.
  ///
  /// Returns the last path segment, or `'untitled'` if the URL has
  /// no meaningful path.
  static String fileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return segments.last;
    } on FormatException {
      // Fall through to default.
    }
    return 'untitled';
  }

  // ---------------------------------------------------------------------------
  // Recent files
  // ---------------------------------------------------------------------------

  /// Loads the list of recently opened file paths from persistence.
  Future<List<String>> loadRecentFiles() async {
    final raw = await _persistence.loadSettingsValue('recent_files');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<String>();
    } on FormatException {
      return [];
    }
  }

  /// Adds a file path to the recent files list.
  ///
  /// Deduplicates and caps at [AppConstants.scribeMaxRecentFiles].
  /// Persists the updated list.
  Future<void> addRecentFile(String filePath) async {
    final current = await loadRecentFiles();
    current.remove(filePath);
    current.insert(0, filePath);
    if (current.length > AppConstants.scribeMaxRecentFiles) {
      current.removeRange(
          AppConstants.scribeMaxRecentFiles, current.length);
    }
    await _saveRecentFiles(current);
  }

  /// Clears all recent files from persistence.
  Future<void> clearRecentFiles() async {
    await _saveRecentFiles([]);
  }

  Future<void> _saveRecentFiles(List<String> files) async {
    // Store as a JSON array in the ScribeSettings table under 'recent_files'.
    await _persistence.saveSettingsValue(
      'recent_files',
      jsonEncode(files),
    );
  }
}
