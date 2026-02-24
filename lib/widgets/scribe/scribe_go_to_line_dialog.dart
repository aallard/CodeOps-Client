/// Go to Line dialog for the Scribe editor.
///
/// Prompts the user for a line number and navigates the editor cursor
/// to that line. Validates input against the document line count.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// Dialog that prompts for a line number to jump to.
///
/// Use the static [show] method to display the dialog. Returns the
/// 0-based line index, or `null` if the user cancels.
class ScribeGoToLineDialog {
  ScribeGoToLineDialog._();

  /// Shows the Go to Line dialog.
  ///
  /// [totalLines] is the total number of lines in the current document,
  /// used for input validation. [currentLine] is the current cursor
  /// line (1-based) shown as the initial placeholder.
  ///
  /// Returns the 0-based line index to jump to, or `null` if cancelled.
  static Future<int?> show(
    BuildContext context, {
    required int totalLines,
    int currentLine = 1,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _GoToLineContent(
        totalLines: totalLines,
        currentLine: currentLine,
      ),
    );
  }
}

/// The dialog content widget.
class _GoToLineContent extends StatefulWidget {
  final int totalLines;
  final int currentLine;

  const _GoToLineContent({
    required this.totalLines,
    required this.currentLine,
  });

  @override
  State<_GoToLineContent> createState() => _GoToLineContentState();
}

class _GoToLineContentState extends State<_GoToLineContent> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleGo() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please enter a line number.');
      return;
    }

    final lineNumber = int.tryParse(text);
    if (lineNumber == null) {
      setState(() => _error = 'Invalid number.');
      return;
    }

    if (lineNumber < 1 || lineNumber > widget.totalLines) {
      setState(() =>
          _error = 'Line must be between 1 and ${widget.totalLines}.');
      return;
    }

    // Return 0-based index.
    Navigator.of(context).pop(lineNumber - 1);
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
        'Go to Line',
        style: TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: AppConstants.scribeGoToLineDialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a line number (1–${widget.totalLines})',
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Line ${widget.currentLine}',
                hintStyle:
                    const TextStyle(color: CodeOpsColors.textTertiary),
                filled: true,
                fillColor: CodeOpsColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: CodeOpsColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: CodeOpsColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: CodeOpsColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _handleGo(),
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
          onPressed: _handleGo,
          style: FilledButton.styleFrom(
            backgroundColor: CodeOpsColors.primary,
          ),
          child: const Text('Go'),
        ),
      ],
    );
  }
}
