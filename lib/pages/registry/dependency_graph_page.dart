/// Dependency graph page with interactive visualization.
///
/// Displays a directed dependency graph with startup order sidebar,
/// cycle detection warnings, layout algorithm selection, and an
/// add-dependency dialog. Supports zoom/pan and node selection.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/registry_enums.dart';
import '../../models/registry_models.dart';
import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/registry/add_dependency_dialog.dart';
import '../../widgets/registry/cycle_warning_banner.dart';
import '../../widgets/registry/dependency_graph_view.dart';
import '../../widgets/registry/startup_order_panel.dart';
import '../../widgets/shared/error_panel.dart';

/// Dependency graph page.
///
/// Watches [registryDependencyGraphProvider] for graph data,
/// [registryStartupOrderProvider] for boot sequence, and
/// [registryCyclesProvider] for cycle detection warnings.
/// Provides layout selection, sidebar toggle, and add-dependency action.
class DependencyGraphPage extends ConsumerWidget {
  /// Creates a [DependencyGraphPage].
  const DependencyGraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphAsync = ref.watch(registryDependencyGraphProvider);

    return Column(
      children: [
        _HeaderBar(),
        // Cycle warning (if any)
        _CycleBanner(),
        // Main content
        Expanded(
          child: graphAsync.when(
            data: (graph) => _GraphContent(graph: graph),
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (e, _) => ErrorPanel(
              title: 'Failed to Load Graph',
              message: e.toString(),
              onRetry: () =>
                  ref.invalidate(registryDependencyGraphProvider),
            ),
          ),
        ),
        // Legend
        const _Legend(),
      ],
    );
  }
}

/// Header bar with title, add dependency button, and sidebar toggle.
class _HeaderBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.divider),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Dependency Graph',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => showAddDependencyDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Dependency'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CodeOpsColors.border),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cycle warning banner that fetches cycle data.
class _CycleBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cyclesAsync = ref.watch(registryCyclesProvider);
    final graphAsync = ref.watch(registryDependencyGraphProvider);

    final cycles = cyclesAsync.valueOrNull ?? [];
    final nodes = graphAsync.valueOrNull?.nodes ?? [];

    if (cycles.isEmpty) return const SizedBox.shrink();

    return CycleWarningBanner(
      cycleServiceIds: cycles,
      allNodes: nodes,
    );
  }
}

/// Main content area with optional sidebar and graph view.
class _GraphContent extends ConsumerStatefulWidget {
  final DependencyGraphResponse graph;

  const _GraphContent({required this.graph});

  @override
  ConsumerState<_GraphContent> createState() => _GraphContentState();
}

class _GraphContentState extends ConsumerState<_GraphContent> {
  bool _showSidebar = true;

  @override
  Widget build(BuildContext context) {
    final startupAsync = ref.watch(registryStartupOrderProvider);
    final cyclesAsync = ref.watch(registryCyclesProvider);
    final layoutType = ref.watch(graphLayoutProvider);
    final selectedNodeId = ref.watch(selectedGraphNodeProvider);

    final cycleNodeIds = (cyclesAsync.valueOrNull ?? []).toSet();

    return Row(
      children: [
        // Startup order sidebar
        if (_showSidebar)
          StartupOrderPanel(
            startupOrder: startupAsync.valueOrNull ?? [],
            onServiceTap: (serviceId) {
              ref.read(selectedGraphNodeProvider.notifier).state = serviceId;
            },
          ),
        // Sidebar toggle
        _SidebarToggle(
          isOpen: _showSidebar,
          onToggle: () => setState(() => _showSidebar = !_showSidebar),
        ),
        // Graph view
        Expanded(
          child: DependencyGraphView(
            graph: widget.graph,
            cycleNodeIds: cycleNodeIds,
            layoutType: layoutType,
            selectedNodeId: selectedNodeId,
            onNodeTap: (node) {
              final current = ref.read(selectedGraphNodeProvider);
              ref.read(selectedGraphNodeProvider.notifier).state =
                  current == node.serviceId ? null : node.serviceId;
            },
            onLayoutChanged: (type) {
              ref.read(graphLayoutProvider.notifier).state = type;
            },
          ),
        ),
      ],
    );
  }
}

/// Thin sidebar toggle strip.
class _SidebarToggle extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;

  const _SidebarToggle({required this.isOpen, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 16,
        color: CodeOpsColors.surface,
        child: Center(
          child: Icon(
            isOpen ? Icons.chevron_left : Icons.chevron_right,
            size: 14,
            color: CodeOpsColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Collapsible legend at the bottom of the page.
class _Legend extends StatefulWidget {
  const _Legend();

  @override
  State<_Legend> createState() => _LegendState();
}

class _LegendState extends State<_Legend> {
  bool _expanded = false;

  static const _edgeTypes = <(DependencyType, Color, String)>[
    (DependencyType.httpRest, Color(0xFF2196F3), 'solid'),
    (DependencyType.grpc, Color(0xFF9C27B0), 'solid'),
    (DependencyType.kafkaTopic, Color(0xFFFF9800), 'dashed'),
    (DependencyType.databaseShared, Color(0xFF4CAF50), 'solid'),
    (DependencyType.redisShared, Color(0xFFF44336), 'solid'),
    (DependencyType.library_, Color(0xFF009688), 'dotted'),
    (DependencyType.gatewayRoute, Color(0xFF3F51B5), 'solid'),
    (DependencyType.websocket, Color(0xFF00BCD4), 'dashed'),
    (DependencyType.fileSystem, Color(0xFF795548), 'dotted'),
    (DependencyType.other, Color(0xFF9E9E9E), 'dashed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(top: BorderSide(color: CodeOpsColors.divider)),
      ),
      child: Column(
        children: [
          // Toggle row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CodeOpsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Minimal inline legend
                  Container(
                    width: 20,
                    height: 0,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: CodeOpsColors.textTertiary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Required',
                    style: TextStyle(
                        fontSize: 11, color: CodeOpsColors.textTertiary),
                  ),
                  const SizedBox(width: 12),
                  _DashedLegendLine(),
                  const SizedBox(width: 4),
                  const Text(
                    'Optional',
                    style: TextStyle(
                        fontSize: 11, color: CodeOpsColors.textTertiary),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_more : Icons.expand_less,
                    size: 16,
                    color: CodeOpsColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: Wrap(
                spacing: 16,
                runSpacing: 6,
                children: _edgeTypes.map((entry) {
                  final (type, color, style) = entry;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 3,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${type.displayName} ($style)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: CodeOpsColors.textTertiary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small dashed line widget for the legend.
class _DashedLegendLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 2,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

/// Paints a short dashed line for the legend.
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CodeOpsColors.textTertiary
      ..strokeWidth = 2;
    const dashWidth = 4.0;
    const dashGap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + dashWidth, size.width), size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
