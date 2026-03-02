/// Request builder stub for CCF-003.
///
/// Shows the method dropdown, URL field, Send button, and the request
/// configuration tab bar (Params, Headers, Body, Auth, Scripts, Tests,
/// Settings). CCF-003 fills in each tab's content area.
library;

import 'package:flutter/material.dart';

import '../../models/courier_enums.dart';
import '../../theme/colors.dart';

/// Center pane — HTTP request builder.
///
/// Stub implementation — CCF-003 replaces the tab content with live editors.
class RequestBuilder extends StatefulWidget {
  /// Creates a [RequestBuilder].
  const RequestBuilder({super.key});

  @override
  State<RequestBuilder> createState() => _RequestBuilderState();
}

class _RequestBuilderState extends State<RequestBuilder>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  CourierHttpMethod _method = CourierHttpMethod.get;

  static const _tabs = [
    'Params',
    'Headers',
    'Body',
    'Auth',
    'Scripts',
    'Tests',
    'Settings',
  ];

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
        _UrlBar(
          method: _method,
          onMethodChanged: (m) => setState(() => _method = m),
        ),
        const Divider(height: 1, color: CodeOpsColors.border),
        _RequestTabBar(controller: _tabController, tabs: _tabs),
        const Divider(height: 1, color: CodeOpsColors.border),
        const Expanded(child: _TabContent()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// URL bar: method dropdown + URL input + Send button
// ─────────────────────────────────────────────────────────────────────────────

class _UrlBar extends StatefulWidget {
  final CourierHttpMethod method;
  final ValueChanged<CourierHttpMethod> onMethodChanged;

  const _UrlBar({required this.method, required this.onMethodChanged});

  @override
  State<_UrlBar> createState() => _UrlBarState();
}

class _UrlBarState extends State<_UrlBar> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Color _methodColor(CourierHttpMethod method) => switch (method) {
        CourierHttpMethod.get => const Color(0xFF4ADE80),
        CourierHttpMethod.post => const Color(0xFFFBBF24),
        CourierHttpMethod.put => const Color(0xFF60A5FA),
        CourierHttpMethod.patch => const Color(0xFFA78BFA),
        CourierHttpMethod.delete => const Color(0xFFEF4444),
        CourierHttpMethod.head => const Color(0xFF34D399),
        CourierHttpMethod.options => const Color(0xFF94A3B8),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Method dropdown
          _MethodDropdown(
            method: widget.method,
            color: _methodColor(widget.method),
            onChanged: widget.onMethodChanged,
          ),
          const SizedBox(width: 8),
          // URL text field
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textPrimary,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: 'Enter URL or paste cURL',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textTertiary,
                ),
                filled: true,
                fillColor: CodeOpsColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          ),
          const SizedBox(width: 8),
          // Send button
          ElevatedButton(
            key: const Key('send_button'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: CodeOpsColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Send',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodDropdown extends StatelessWidget {
  final CourierHttpMethod method;
  final Color color;
  final ValueChanged<CourierHttpMethod> onChanged;

  const _MethodDropdown({
    required this.method,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: CodeOpsColors.background,
        border: Border.all(color: CodeOpsColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CourierHttpMethod>(
          value: method,
          dropdownColor: CodeOpsColors.surfaceVariant,
          isDense: true,
          items: CourierHttpMethod.values
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    m.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (_) => CourierHttpMethod.values
              .map(
                (m) => Text(
                  m.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request tab bar: Params | Headers | Body | Auth | Scripts | Tests | Settings
// ─────────────────────────────────────────────────────────────────────────────

class _RequestTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _RequestTabBar({required this.controller, required this.tabs});

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
// Tab content placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  const _TabContent();

  @override
  Widget build(BuildContext context) {
    // CCF-003 replaces this with live param/header/body/auth editors.
    return const Center(
      child: Text(
        'CCF-003 will populate this area',
        style: TextStyle(
          fontSize: 13,
          color: CodeOpsColors.textTertiary,
        ),
      ),
    );
  }
}
