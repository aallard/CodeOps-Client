/// Collection sidebar stub for CCF-002.
///
/// Displays a search field and an empty state until CCF-002 fills in the
/// actual collection tree. Accepts a [searchQuery] and notifies the parent
/// when the user interacts with the search field.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/courier_ui_providers.dart';
import '../../theme/colors.dart';

/// Left-pane sidebar showing the Courier collection tree.
///
/// Stub implementation — CCF-002 replaces the body with the live tree.
class CollectionSidebar extends ConsumerWidget {
  /// Creates a [CollectionSidebar].
  const CollectionSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(sidebarSearchQueryProvider);

    return Container(
      color: CodeOpsColors.surface,
      child: Column(
        children: [
          _SidebarSearchField(query: query, ref: ref),
          const Divider(height: 1, color: CodeOpsColors.border),
          const Expanded(child: _CollectionList()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Field
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarSearchField extends StatefulWidget {
  final String query;
  final WidgetRef ref;

  const _SidebarSearchField({required this.query, required this.ref});

  @override
  State<_SidebarSearchField> createState() => _SidebarSearchFieldState();
}

class _SidebarSearchFieldState extends State<_SidebarSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          widget.ref.read(sidebarSearchQueryProvider.notifier).state = value;
        },
        style: const TextStyle(
          fontSize: 13,
          color: CodeOpsColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search collections…',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: CodeOpsColors.textTertiary,
          ),
          filled: true,
          fillColor: CodeOpsColors.background,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: CodeOpsColors.primary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collection List (stub)
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionList extends StatelessWidget {
  const _CollectionList();

  @override
  Widget build(BuildContext context) {
    // CCF-002 replaces this with the live collection tree.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_open_outlined,
            size: 40,
            color: CodeOpsColors.textTertiary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No collections yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a collection to get started',
            style: TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Create Collection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
