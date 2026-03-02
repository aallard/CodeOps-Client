/// Code generation page for the Courier module.
///
/// Converts the selected request into client code snippets in various
/// languages (cURL, Python, JavaScript, etc.). Stub — full implementation
/// in a subsequent CCF task.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Full-page code generation tool shown at `/courier/codegen`.
class CodeGenerationPage extends StatelessWidget {
  /// Creates a [CodeGenerationPage].
  const CodeGenerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CodeOpsColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.code_outlined,
              size: 48,
              color: CodeOpsColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Code Generation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CodeOpsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Full implementation coming in a subsequent CCF task.',
              style: TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back to Courier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CodeOpsColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
