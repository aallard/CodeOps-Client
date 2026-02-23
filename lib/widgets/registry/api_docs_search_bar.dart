/// Search and filter bar for the API Docs viewer.
///
/// Provides a text search field and an HTTP method filter dropdown
/// for narrowing down displayed endpoints.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';

/// Search and method filter bar for API documentation endpoints.
///
/// Writes search text to [apiDocsSearchProvider] and method filter
/// to [apiDocsMethodFilterProvider].
class ApiDocsSearchBar extends ConsumerStatefulWidget {
  /// Creates an [ApiDocsSearchBar].
  const ApiDocsSearchBar({super.key});

  @override
  ConsumerState<ApiDocsSearchBar> createState() => _ApiDocsSearchBarState();
}

class _ApiDocsSearchBarState extends ConsumerState<ApiDocsSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final methodFilter = ref.watch(apiDocsMethodFilterProvider);

    return Row(
      children: [
        // Search field.
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search endpoints...',
                hintStyle: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: CodeOpsColors.textTertiary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 16, color: CodeOpsColors.textTertiary),
                        onPressed: () {
                          _controller.clear();
                          ref.read(apiDocsSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
              ),
              onChanged: (value) {
                ref.read(apiDocsSearchProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Method filter dropdown.
        SizedBox(
          width: 180,
          height: 36,
          child: DropdownButtonFormField<String?>(
            initialValue: methodFilter,
            hint: const Text(
              'All',
              style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 12),
            ),
            isExpanded: true,
            dropdownColor: CodeOpsColors.surface,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: CodeOpsColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: CodeOpsColors.border),
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Methods',
                    style: TextStyle(
                        color: CodeOpsColors.textSecondary, fontSize: 12)),
              ),
              ...['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].map(
                (m) => DropdownMenuItem<String?>(
                  value: m,
                  child: Text(m,
                      style: TextStyle(
                          color: _methodColor(m), fontSize: 12)),
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(apiDocsMethodFilterProvider.notifier).state = value;
            },
          ),
        ),
      ],
    );
  }

  Color _methodColor(String method) {
    return switch (method) {
      'GET' => const Color(0xFF4CAF50),
      'POST' => const Color(0xFF2196F3),
      'PUT' => const Color(0xFFFF9800),
      'DELETE' => const Color(0xFFF44336),
      'PATCH' => const Color(0xFF00BCD4),
      _ => CodeOpsColors.textSecondary,
    };
  }
}
