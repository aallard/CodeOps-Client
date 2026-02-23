/// Dialog for opening a file from a URL in the Scribe editor.
///
/// Prompts the user for a URL, fetches the content via HTTP, and
/// returns the fetched text for display in a new tab.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Result returned by [ScribeUrlDialog.show].
class ScribeUrlResult {
  /// The URL that was fetched.
  final String url;

  /// The fetched text content.
  final String content;

  /// Creates a [ScribeUrlResult].
  const ScribeUrlResult({required this.url, required this.content});
}

/// Dialog for opening a file from a URL.
///
/// Shows a text field for the URL, a Fetch button with loading state,
/// and error feedback. Use the static [show] method to display.
class ScribeUrlDialog {
  ScribeUrlDialog._();

  /// Shows the URL dialog.
  ///
  /// [fetchContent] is the function that fetches text from a URL
  /// (typically [ScribeFileService.readFromUrl]).
  ///
  /// Returns a [ScribeUrlResult] on success, or `null` if cancelled.
  static Future<ScribeUrlResult?> show(
    BuildContext context, {
    required Future<String> Function(String url) fetchContent,
  }) async {
    return showDialog<ScribeUrlResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UrlDialogContent(fetchContent: fetchContent),
    );
  }
}

/// The dialog content widget.
class _UrlDialogContent extends StatefulWidget {
  final Future<String> Function(String url) fetchContent;

  const _UrlDialogContent({required this.fetchContent});

  @override
  State<_UrlDialogContent> createState() => _UrlDialogContentState();
}

class _UrlDialogContentState extends State<_UrlDialogContent> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleFetch() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a URL.');
      return;
    }

    // Basic URL validation.
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      setState(() => _error = 'Please enter a valid HTTP or HTTPS URL.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await widget.fetchContent(url);
      if (!mounted) return;
      Navigator.of(context).pop(
        ScribeUrlResult(url: url, content: content),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to fetch: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CodeOpsColors.border),
      ),
      title: const Text(
        'Open from URL',
        style: TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'URL',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _urlController,
              autofocus: true,
              enabled: !_isLoading,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'https://example.com/file.dart',
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
              onSubmitted: (_) => _handleFetch(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  color: CodeOpsColors.error,
                  fontSize: 12,
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CodeOpsColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(null),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleFetch,
          style: FilledButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
          ),
          child: const Text('Fetch'),
        ),
      ],
    );
  }
}
