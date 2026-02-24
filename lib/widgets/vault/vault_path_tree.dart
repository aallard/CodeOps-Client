/// Hierarchical path tree widget for Vault secret navigation.
///
/// Builds a folder tree from a flat list of secret paths returned by
/// [vaultSecretPathsProvider]. Supports expand/collapse, single-selection,
/// and fires [onPathSelected] when the user clicks a node to filter the
/// secret list by path prefix.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/vault_providers.dart';
import '../../theme/colors.dart';

/// A node in the path tree hierarchy.
///
/// Each node represents a single path segment (folder). Children are
/// stored in a sorted map keyed by segment name.
class PathTreeNode {
  /// The display name of this node (last path segment).
  final String name;

  /// The full path from root to this node (e.g., "/services/app").
  final String fullPath;

  /// Child nodes keyed by segment name, sorted alphabetically.
  final Map<String, PathTreeNode> children = {};

  /// Creates a [PathTreeNode] with the given [name] and [fullPath].
  PathTreeNode({required this.name, required this.fullPath});
}

/// Builds a [PathTreeNode] hierarchy from a flat list of path strings.
///
/// Each path is split by `/` and nodes are created for every segment.
/// The root node has name `/` and fullPath `/`.
///
/// Example:
/// ```dart
/// final root = buildPathTree(['/services/app/db', '/services/app/cache']);
/// // root → "/" children: { "services" → children: { "app" → children: { "db", "cache" } } }
/// ```
PathTreeNode buildPathTree(List<String> paths) {
  final root = PathTreeNode(name: '/', fullPath: '/');

  for (final path in paths) {
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    if (trimmed.isEmpty) continue;

    final segments = trimmed.split('/');
    var current = root;
    var accumulated = '';

    for (final segment in segments) {
      if (segment.isEmpty) continue;
      accumulated = '$accumulated/$segment';
      current = current.children.putIfAbsent(
        segment,
        () => PathTreeNode(name: segment, fullPath: accumulated),
      );
    }
  }

  return root;
}

/// A hierarchical folder tree for navigating Vault secret paths.
///
/// Fetches paths from [vaultSecretPathsProvider] with the root prefix `/`,
/// builds a tree, and renders an expandable tree view. When the user taps
/// a node, [onPathSelected] fires with the node's full path.
///
/// Usage:
/// ```dart
/// VaultPathTree(
///   selectedPath: currentPathFilter,
///   onPathSelected: (path) => ref.read(vaultSecretPathFilterProvider.notifier).state = path,
/// )
/// ```
class VaultPathTree extends ConsumerStatefulWidget {
  /// The currently selected path (highlighted in the tree).
  final String selectedPath;

  /// Called when the user taps a tree node to select a path.
  final ValueChanged<String> onPathSelected;

  /// Creates a [VaultPathTree].
  const VaultPathTree({
    super.key,
    required this.selectedPath,
    required this.onPathSelected,
  });

  @override
  ConsumerState<VaultPathTree> createState() => _VaultPathTreeState();
}

class _VaultPathTreeState extends ConsumerState<VaultPathTree> {
  final Set<String> _expanded = {'/'};

  @override
  Widget build(BuildContext context) {
    final pathsAsync = ref.watch(vaultSecretPathsProvider('/'));

    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CodeOpsColors.divider),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: CodeOpsColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Paths',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => ref.invalidate(vaultSecretPathsProvider),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.refresh,
                      size: 14,
                      color: CodeOpsColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tree content
          Expanded(
            child: pathsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 24,
                      color: CodeOpsColors.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load paths',
                      style: const TextStyle(
                        fontSize: 11,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(vaultSecretPathsProvider),
                      child: const Text(
                        'Retry',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              data: (paths) {
                final root = buildPathTree(paths);
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    // Root node
                    _TreeNodeTile(
                      node: root,
                      depth: 0,
                      isExpanded: _expanded.contains('/'),
                      isSelected: widget.selectedPath == '' ||
                          widget.selectedPath == '/',
                      onTap: () => widget.onPathSelected(''),
                      onToggle: () => _toggleExpand('/'),
                    ),
                    // Child nodes
                    if (_expanded.contains('/'))
                      ..._buildChildNodes(root, 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Recursively builds tree node tiles for the children of [parent].
  List<Widget> _buildChildNodes(PathTreeNode parent, int depth) {
    final sorted = parent.children.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final widgets = <Widget>[];
    for (final entry in sorted) {
      final node = entry.value;
      final hasChildren = node.children.isNotEmpty;
      final isExpanded = _expanded.contains(node.fullPath);

      widgets.add(
        _TreeNodeTile(
          node: node,
          depth: depth,
          isExpanded: isExpanded,
          isSelected: widget.selectedPath == node.fullPath,
          onTap: () => widget.onPathSelected(node.fullPath),
          onToggle: hasChildren ? () => _toggleExpand(node.fullPath) : null,
        ),
      );

      if (hasChildren && isExpanded) {
        widgets.addAll(_buildChildNodes(node, depth + 1));
      }
    }
    return widgets;
  }

  void _toggleExpand(String path) {
    setState(() {
      if (_expanded.contains(path)) {
        _expanded.remove(path);
      } else {
        _expanded.add(path);
      }
    });
  }
}

/// A single row in the path tree displaying a folder node.
class _TreeNodeTile extends StatelessWidget {
  final PathTreeNode node;
  final int depth;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  const _TreeNodeTile({
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;

    return InkWell(
      onTap: () {
        onTap();
        if (hasChildren && onToggle != null) {
          onToggle!();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 8.0 + (depth * 16.0),
          right: 8,
          top: 4,
          bottom: 4,
        ),
        color: isSelected
            ? CodeOpsColors.primary.withValues(alpha: 0.08)
            : null,
        child: Row(
          children: [
            // Expand/collapse icon
            SizedBox(
              width: 16,
              child: hasChildren
                  ? Icon(
                      isExpanded
                          ? Icons.expand_more
                          : Icons.chevron_right,
                      size: 14,
                      color: CodeOpsColors.textTertiary,
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            // Folder icon
            Icon(
              hasChildren
                  ? (isExpanded
                      ? Icons.folder_open_outlined
                      : Icons.folder_outlined)
                  : Icons.folder_outlined,
              size: 14,
              color: isSelected
                  ? CodeOpsColors.primary
                  : CodeOpsColors.textSecondary,
            ),
            const SizedBox(width: 6),
            // Name
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? CodeOpsColors.primary
                      : CodeOpsColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
