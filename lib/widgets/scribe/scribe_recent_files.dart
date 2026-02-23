/// Recent files panel for the Scribe editor.
///
/// Displays a searchable list of recently opened files with the ability
/// to open, remove, or clear entries. Activated via Ctrl+Shift+O.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// A panel that displays recently opened files for quick access.
///
/// Includes a search filter, file entries with open/remove actions,
/// and a Clear All button at the bottom. Files that no longer exist
/// on disk are displayed with a dimmed style.
class ScribeRecentFiles extends StatefulWidget {
  /// The list of recent file paths to display.
  final List<String> recentFiles;

  /// Called when the user selects a file to open.
  final ValueChanged<String> onOpen;

  /// Called when the user removes a single file from the list.
  final ValueChanged<String> onRemove;

  /// Called when the user clears all recent files.
  final VoidCallback onClearAll;

  /// Called when the panel should be closed.
  final VoidCallback onClose;

  /// Creates a [ScribeRecentFiles] panel.
  const ScribeRecentFiles({
    super.key,
    required this.recentFiles,
    required this.onOpen,
    required this.onRemove,
    required this.onClearAll,
    required this.onClose,
  });

  @override
  State<ScribeRecentFiles> createState() => _ScribeRecentFilesState();
}

class _ScribeRecentFilesState extends State<ScribeRecentFiles> {
  final _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredFiles {
    if (_filter.isEmpty) return widget.recentFiles;
    final lower = _filter.toLowerCase();
    return widget.recentFiles
        .where((f) => f.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.scribeRecentFilesPanelWidth,
      color: CodeOpsColors.surface,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildFileList()),
          if (widget.recentFiles.isNotEmpty) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: AppConstants.scribeTabBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Recent Files',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: widget.onClose,
            color: CodeOpsColors.textTertiary,
            splashRadius: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 30,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: CodeOpsColors.textPrimary,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: 'Filter recent files...',
            hintStyle: const TextStyle(
              color: CodeOpsColors.textTertiary,
              fontSize: 12,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 16,
              color: CodeOpsColors.textTertiary,
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 32, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            filled: true,
            fillColor: CodeOpsColors.background,
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
          onChanged: (value) => setState(() => _filter = value),
        ),
      ),
    );
  }

  Widget _buildFileList() {
    final files = _filteredFiles;
    if (files.isEmpty) {
      return Center(
        child: Text(
          _filter.isEmpty ? 'No recent files' : 'No matching files',
          style: const TextStyle(
            color: CodeOpsColors.textTertiary,
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final path = files[index];
        return _RecentFileEntry(
          filePath: path,
          onOpen: () => widget.onOpen(path),
          onRemove: () => widget.onRemove(path),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 28,
        child: TextButton(
          onPressed: widget.onClearAll,
          style: TextButton.styleFrom(
            foregroundColor: CodeOpsColors.error,
            textStyle:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          child: const Text('Clear All'),
        ),
      ),
    );
  }
}

/// A single entry in the recent files list.
class _RecentFileEntry extends StatelessWidget {
  final String filePath;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _RecentFileEntry({
    required this.filePath,
    required this.onOpen,
    required this.onRemove,
  });

  String get _fileName {
    final lastSlash = filePath.lastIndexOf('/');
    return lastSlash >= 0 ? filePath.substring(lastSlash + 1) : filePath;
  }

  String get _directory {
    final lastSlash = filePath.lastIndexOf('/');
    if (lastSlash < 0) return '';
    final dir = filePath.substring(0, lastSlash);
    // Abbreviate home directory.
    final home = Platform.environment['HOME'] ?? '';
    if (home.isNotEmpty && dir.startsWith(home)) {
      return '~${dir.substring(home.length)}';
    }
    return dir;
  }

  bool get _exists => File(filePath).existsSync();

  @override
  Widget build(BuildContext context) {
    final exists = _exists;
    return InkWell(
      onTap: exists ? onOpen : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 16,
              color: exists
                  ? CodeOpsColors.textSecondary
                  : CodeOpsColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileName,
                    style: TextStyle(
                      color: exists
                          ? CodeOpsColors.textPrimary
                          : CodeOpsColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _directory,
                    style: TextStyle(
                      color: exists
                          ? CodeOpsColors.textTertiary
                          : CodeOpsColors.textTertiary.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!exists)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text(
                  'Missing',
                  style: TextStyle(
                    color: CodeOpsColors.error,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              onPressed: onRemove,
              color: CodeOpsColors.textTertiary,
              splashRadius: 12,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              tooltip: 'Remove from list',
            ),
          ],
        ),
      ),
    );
  }
}
