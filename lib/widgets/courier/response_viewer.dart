/// Response viewer stub for CCF-008.
///
/// Shows an empty state until the user sends a request. CCF-008 fills in
/// the actual response body, headers, cookies, and test-result tabs.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Right pane — HTTP response viewer.
///
/// Stub implementation — CCF-008 replaces the body with live response data.
class ResponseViewer extends StatefulWidget {
  /// Creates a [ResponseViewer].
  const ResponseViewer({super.key});

  @override
  State<ResponseViewer> createState() => _ResponseViewerState();
}

class _ResponseViewerState extends State<ResponseViewer>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Body', 'Headers', 'Cookies', 'Test Results'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResponseTabBar(controller: _tabController, tabs: _tabs),
        const Divider(height: 1, color: CodeOpsColors.border),
        const Expanded(child: _EmptyResponseState()),
        const _ResponseStatusBar(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response tab bar
// ─────────────────────────────────────────────────────────────────────────────

class _ResponseTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _ResponseTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.surface,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: CodeOpsColors.primary,
        unselectedLabelColor: CodeOpsColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        indicatorColor: CodeOpsColors.primary,
        indicatorWeight: 2,
        tabs: tabs.map((t) => Tab(text: t, height: 36)).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state (no response yet)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResponseState extends StatelessWidget {
  const _EmptyResponseState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.send_outlined,
            size: 48,
            color: CodeOpsColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Click Send to get a response',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter a URL and press Send',
            style: TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response status bar (status code, time, size)
// ─────────────────────────────────────────────────────────────────────────────

class _ResponseStatusBar extends StatelessWidget {
  const _ResponseStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: CodeOpsColors.background,
        border: Border(top: BorderSide(color: CodeOpsColors.border)),
      ),
      child: const Row(
        children: [
          Text(
            '— —',
            style: TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
          SizedBox(width: 16),
          Text(
            'Status: —',
            style: TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
          SizedBox(width: 16),
          Text(
            'Time: —',
            style: TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
          SizedBox(width: 16),
          Text(
            'Size: —',
            style: TextStyle(fontSize: 11, color: CodeOpsColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
