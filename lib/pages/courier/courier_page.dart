/// Courier main page — three-pane HTTP client layout.
///
/// Renders the [CourierToolbar], resizable collection sidebar (left),
/// request builder (center), response viewer (right), and
/// [CourierStatusBar]. Subsequent CCF tasks fill in each pane.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_enums.dart';
import '../../providers/courier_ui_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/courier/collection_sidebar.dart';
import '../../widgets/courier/courier_status_bar.dart';
import '../../widgets/courier/courier_toolbar.dart';
import '../../widgets/courier/request_builder.dart';
import '../../widgets/courier/response_viewer.dart';

/// The Courier module root — a Postman-style three-pane HTTP client.
///
/// Layout:
/// ```
/// ┌──────────────────────────────────────────────────────────┐
/// │ CourierToolbar                                           │
/// ├───────────┬──────────────────────────┬───────────────────┤
/// │ Collection│ Request Builder          │ Response Viewer   │
/// │ Sidebar   │ [Tab bar · builder area] │                   │
/// ├───────────┴──────────────────────────┴───────────────────┤
/// │ CourierStatusBar                                         │
/// └──────────────────────────────────────────────────────────┘
/// ```
///
/// The [requestId] and [collectionId] parameters are set by the router
/// when navigating to `/courier/request/:requestId` or
/// `/courier/collection/:collectionId`. Both are null on `/courier`.
class CourierPage extends ConsumerStatefulWidget {
  /// Pre-selected request ID to open in a tab, or null.
  final String? requestId;

  /// Pre-selected collection ID to highlight in the sidebar, or null.
  final String? collectionId;

  /// Creates a [CourierPage].
  const CourierPage({super.key, this.requestId, this.collectionId});

  @override
  ConsumerState<CourierPage> createState() => _CourierPageState();
}

class _CourierPageState extends ConsumerState<CourierPage> {
  // Minimum / maximum pane widths.
  static const double _minSidebarWidth = 200;
  static const double _maxSidebarWidth = 400;
  static const double _minResponseWidth = 300;

  @override
  void initState() {
    super.initState();
    // Apply router-supplied selections after first frame so providers are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.collectionId != null) {
        ref.read(selectedCollectionIdProvider.notifier).state =
            widget.collectionId;
      }
    });
  }

  // ─── Sidebar drag ────────────────────────────────────────────────────────

  void _onSidebarDrag(double delta) {
    final current = ref.read(sidebarWidthProvider);
    final updated = (current + delta).clamp(_minSidebarWidth, _maxSidebarWidth);
    ref.read(sidebarWidthProvider.notifier).state = updated;
  }

  // ─── Response pane drag ──────────────────────────────────────────────────

  void _onResponseDrag(double delta) {
    final current = ref.read(responsePaneWidthProvider);
    // Dragging right → smaller response pane; left → larger.
    final updated = (current - delta).clamp(_minResponseWidth, double.infinity);
    ref.read(responsePaneWidthProvider.notifier).state = updated;
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = ref.watch(sidebarWidthProvider);
    final responseWidth = ref.watch(responsePaneWidthProvider);
    final responseCollapsed = ref.watch(responsePaneCollapsedProvider);

    return Column(
      children: [
        // ── Toolbar ─────────────────────────────────────────────────────────
        const CourierToolbar(),
        // ── Request tab bar ─────────────────────────────────────────────────
        const _OpenRequestTabBar(),
        // ── Three panes ─────────────────────────────────────────────────────
        Expanded(
          child: Row(
            children: [
              // Left: collection sidebar
              SizedBox(
                width: sidebarWidth,
                child: const CollectionSidebar(),
              ),
              // Draggable divider between sidebar and request builder
              _PaneDivider(onDrag: _onSidebarDrag),
              // Center: request builder
              const Expanded(child: RequestBuilder()),
              // Draggable divider between request builder and response viewer
              _PaneDivider(onDrag: _onResponseDrag),
              // Right: response viewer (collapsible)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: responseCollapsed ? 0 : responseWidth,
                child: responseCollapsed
                    ? const SizedBox.shrink()
                    : const ResponseViewer(),
              ),
            ],
          ),
        ),
        // ── Status bar ──────────────────────────────────────────────────────
        const CourierStatusBar(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Open request tab bar (browser-style tabs above the request builder)
// ─────────────────────────────────────────────────────────────────────────────

/// Horizontal bar showing open request tabs.
///
/// Each tab displays the HTTP method badge, request name, and a close button.
/// Clicking a tab makes it active. The [+] button creates a new empty request.
class _OpenRequestTabBar extends ConsumerWidget {
  const _OpenRequestTabBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(openRequestTabsProvider);
    final activeId = ref.watch(activeRequestTabProvider);

    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: CodeOpsColors.background,
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.border),
          top: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: Row(
        children: [
          // Scrollable tab list
          Expanded(
            child: tabs.isEmpty
                ? const _EmptyTabHint()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    separatorBuilder: (_, __) => Container(
                      width: 1,
                      color: CodeOpsColors.border,
                    ),
                    itemBuilder: (_, index) {
                      final tab = tabs[index];
                      return _RequestTab(
                        tab: tab,
                        isActive: tab.id == activeId,
                        onTap: () {
                          ref
                              .read(activeRequestTabProvider.notifier)
                              .state = tab.id;
                        },
                        onClose: () {
                          final updated =
                              tabs.where((t) => t.id != tab.id).toList();
                          ref.read(openRequestTabsProvider.notifier).state =
                              updated;
                          if (activeId == tab.id) {
                            ref
                                .read(activeRequestTabProvider.notifier)
                                .state = updated.isEmpty ? null : updated.last.id;
                          }
                        },
                      );
                    },
                  ),
          ),
          // New tab button
          SizedBox(
            width: 36,
            child: IconButton(
              key: const Key('new_tab_button'),
              icon: const Icon(Icons.add, size: 16),
              color: CodeOpsColors.textSecondary,
              tooltip: 'New Request',
              onPressed: () {
                // CCF-003 implements the actual new-tab creation.
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabHint extends StatelessWidget {
  const _EmptyTabHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No open requests — click + to create one',
        style: TextStyle(
          fontSize: 11,
          color: CodeOpsColors.textTertiary,
        ),
      ),
    );
  }
}

class _RequestTab extends StatelessWidget {
  final RequestTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _RequestTab({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  Color _methodColor(CourierHttpMethod m) => switch (m) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? CodeOpsColors.surface : Colors.transparent,
          border: isActive
              ? const Border(
                  top: BorderSide(color: CodeOpsColors.primary, width: 2),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Method badge
            Text(
              tab.method.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _methodColor(tab.method),
              ),
            ),
            const SizedBox(width: 6),
            // Tab name
            Flexible(
              child: Text(
                tab.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? CodeOpsColors.textPrimary
                      : CodeOpsColors.textSecondary,
                ),
              ),
            ),
            if (tab.isDirty) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: CodeOpsColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            const SizedBox(width: 4),
            // Close button
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draggable pane divider
// ─────────────────────────────────────────────────────────────────────────────

/// Thin vertical divider between two panes that reacts to horizontal drag.
///
/// Shows [SystemMouseCursors.resizeColumn] on hover.
class _PaneDivider extends StatelessWidget {
  /// Called with the horizontal drag delta in logical pixels.
  final void Function(double delta) onDrag;

  const _PaneDivider({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: Container(
          width: 4,
          color: CodeOpsColors.border,
          child: Center(
            child: Container(
              width: 1,
              color: CodeOpsColors.border,
            ),
          ),
        ),
      ),
    );
  }
}
