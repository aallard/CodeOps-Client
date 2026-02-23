/// Dialog for creating a new file in the Scribe editor.
///
/// Prompts the user for a file name and language, with language
/// auto-detected from the file extension.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import 'scribe_language.dart';

/// Result returned by [ScribeNewFileDialog.show].
class ScribeNewFileResult {
  /// The user-entered file name.
  final String fileName;

  /// The selected language identifier.
  final String language;

  /// Creates a [ScribeNewFileResult].
  const ScribeNewFileResult({
    required this.fileName,
    required this.language,
  });
}

/// Dialog for creating a new file with a name and language picker.
///
/// Use the static [show] method to display the dialog and receive
/// a [ScribeNewFileResult], or `null` if cancelled.
class ScribeNewFileDialog {
  ScribeNewFileDialog._();

  /// Shows the new file dialog.
  ///
  /// Returns a [ScribeNewFileResult] with the chosen file name and
  /// language, or `null` if the user cancels.
  static Future<ScribeNewFileResult?> show(BuildContext context) async {
    return showDialog<ScribeNewFileResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _NewFileDialogContent(),
    );
  }
}

/// The dialog content widget.
class _NewFileDialogContent extends StatefulWidget {
  const _NewFileDialogContent();

  @override
  State<_NewFileDialogContent> createState() => _NewFileDialogContentState();
}

class _NewFileDialogContentState extends State<_NewFileDialogContent> {
  final _nameController = TextEditingController();
  String _selectedLanguage = 'plaintext';
  bool _manualLanguage = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_manualLanguage) return;
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final detected = ScribeLanguage.fromFileName(name);
      if (detected != _selectedLanguage) {
        setState(() => _selectedLanguage = detected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = ScribeLanguage.supportedLanguages;

    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      title: const Text(
        'New File',
        style: TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Name',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. main.dart',
                hintStyle: const TextStyle(color: CodeOpsColors.textTertiary),
                filled: true,
                fillColor: CodeOpsColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeOpsColors.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _handleCreate(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Language',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              dropdownColor: CodeOpsColors.surface,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: CodeOpsColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeOpsColors.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(ScribeLanguage.displayName(lang)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedLanguage = val;
                    _manualLanguage = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: _handleCreate,
          style: FilledButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _handleCreate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.of(context).pop(
      ScribeNewFileResult(
        fileName: name,
        language: _selectedLanguage,
      ),
    );
  }
}
