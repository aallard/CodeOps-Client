/// Interactive dependency graph canvas with zoom, pan, and node interaction.
///
/// Renders service nodes and dependency edges using [CustomPainter] for
/// edge drawing and [Positioned] widgets in a [Stack] for nodes.
/// Supports layered, tree, and force-directed layout algorithms via
/// [GraphLayoutType]. Wrapped in [InteractiveViewer] for zoom/pan.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/registry_enums.dart';
import '../../models/registry_models.dart';
import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';
import 'graph_controls.dart';
import 'graph_node_widget.dart';

/// Interactive dependency graph canvas.
///
/// Computes node positions using the selected [layoutType], renders
/// directed edges with [_EdgePainter], and overlays [GraphNodeWidget]
/// instances. Supports node selection, cycle highlighting, and
/// zoom/pan via [InteractiveViewer].
class DependencyGraphView extends StatefulWidget {
  /// The graph data with nodes and edges.
  final DependencyGraphResponse graph;

  /// Service IDs involved in dependency cycles.
  final Set<String> cycleNodeIds;

  /// Layout algorithm to use.
  final GraphLayoutType layoutType;

  /// Callback when a node is tapped.
  final ValueChanged<DependencyNodeResponse>? onNodeTap;

  /// Currently selected node ID.
  final String? selectedNodeId;

  /// Callback when layout type changes.
  final ValueChanged<GraphLayoutType>? onLayoutChanged;

  /// Creates a [DependencyGraphView].
  const DependencyGraphView({
    super.key,
    required this.graph,
    required this.cycleNodeIds,
    this.layoutType = GraphLayoutType.layered,
    this.onNodeTap,
    this.selectedNodeId,
    this.onLayoutChanged,
  });

  @override
  State<DependencyGraphView> createState() => _DependencyGraphViewState();
}

class _DependencyGraphViewState extends State<DependencyGraphView> {
  final TransformationController _transformCtrl = TransformationController();

  /// Node positions computed by the layout algorithm.
  Map<String, Offset> _positions = {};

  /// Canvas size needed to fit all nodes.
  Size _canvasSize = Size.zero;

  static const double _nodeWidth = 140.0;
  static const double _nodeHeight = 60.0;
  static const double _horizontalGap = 80.0;
  static const double _verticalGap = 60.0;
  static const double _padding = 40.0;

  @override
  void initState() {
    super.initState();
    _computeLayout();
  }

  @override
  void didUpdateWidget(DependencyGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph ||
        oldWidget.layoutType != widget.layoutType) {
      _computeLayout();
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _computeLayout() {
    if (widget.graph.nodes.isEmpty) {
      _positions = {};
      _canvasSize = Size.zero;
      return;
    }

    switch (widget.layoutType) {
      case GraphLayoutType.layered:
        _computeLayeredLayout();
      case GraphLayoutType.tree:
        _computeTreeLayout();
      case GraphLayoutType.forceDirected:
        _computeForceDirectedLayout();
    }
  }

  /// Layered (Sugiyama) layout: groups nodes into layers by dependency depth.
  void _computeLayeredLayout() {
    final nodes = widget.graph.nodes;
    final edges = widget.graph.edges;

    // Build adjacency: source → [targets]
    final outgoing = <String, List<String>>{};
    final incoming = <String, List<String>>{};
    for (final n in nodes) {
      outgoing[n.serviceId] = [];
      incoming[n.serviceId] = [];
    }
    for (final e in edges) {
      outgoing[e.sourceServiceId]?.add(e.targetServiceId);
      incoming[e.targetServiceId]?.add(e.sourceServiceId);
    }

    // Assign layers using longest path from roots
    final layers = <String, int>{};

    void assignLayer(String nodeId, int layer) {
      if (layers.containsKey(nodeId) && layers[nodeId]! >= layer) return;
      layers[nodeId] = layer;
      for (final target in outgoing[nodeId] ?? <String>[]) {
        assignLayer(target, layer + 1);
      }
    }

    // Roots = nodes with no incoming edges
    final roots = nodes
        .where((n) => incoming[n.serviceId]?.isEmpty ?? true)
        .map((n) => n.serviceId)
        .toList();

    // If no roots (all in cycles), start from first node
    if (roots.isEmpty && nodes.isNotEmpty) {
      roots.add(nodes.first.serviceId);
    }

    for (final root in roots) {
      assignLayer(root, 0);
    }

    // Nodes without assigned layers get layer 0
    for (final n in nodes) {
      layers.putIfAbsent(n.serviceId, () => 0);
    }

    // Group by layer
    final layerGroups = <int, List<String>>{};
    for (final entry in layers.entries) {
      layerGroups.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    // Position nodes
    _positions = {};
    double maxX = 0;
    double maxY = 0;

    for (final entry in layerGroups.entries) {
      final layer = entry.key;
      final nodeIds = entry.value;
      final x = _padding + layer * (_nodeWidth + _horizontalGap);

      for (var i = 0; i < nodeIds.length; i++) {
        final y = _padding + i * (_nodeHeight + _verticalGap);
        _positions[nodeIds[i]] = Offset(x, y);
        if (x + _nodeWidth > maxX) maxX = x + _nodeWidth;
        if (y + _nodeHeight > maxY) maxY = y + _nodeHeight;
      }
    }

    _canvasSize = Size(maxX + _padding, maxY + _padding);
  }

  /// Tree layout: hierarchical tree from root services.
  void _computeTreeLayout() {
    final nodes = widget.graph.nodes;
    final edges = widget.graph.edges;

    final incoming = <String, List<String>>{};
    final outgoing = <String, List<String>>{};
    for (final n in nodes) {
      incoming[n.serviceId] = [];
      outgoing[n.serviceId] = [];
    }
    for (final e in edges) {
      outgoing[e.sourceServiceId]?.add(e.targetServiceId);
      incoming[e.targetServiceId]?.add(e.sourceServiceId);
    }

    final roots = nodes
        .where((n) => incoming[n.serviceId]?.isEmpty ?? true)
        .map((n) => n.serviceId)
        .toList();
    if (roots.isEmpty && nodes.isNotEmpty) {
      roots.add(nodes.first.serviceId);
    }

    _positions = {};
    final visited = <String>{};
    var currentY = _padding;

    void layoutTree(String nodeId, int depth) {
      if (visited.contains(nodeId)) return;
      visited.add(nodeId);

      final x = _padding + depth * (_nodeWidth + _horizontalGap);
      _positions[nodeId] = Offset(x, currentY);
      currentY += _nodeHeight + _verticalGap;

      for (final child in outgoing[nodeId] ?? <String>[]) {
        layoutTree(child, depth + 1);
      }
    }

    for (final root in roots) {
      layoutTree(root, 0);
    }

    // Place unvisited nodes
    for (final n in nodes) {
      if (!visited.contains(n.serviceId)) {
        _positions[n.serviceId] = Offset(_padding, currentY);
        currentY += _nodeHeight + _verticalGap;
      }
    }

    double maxX = 0;
    double maxY = 0;
    for (final pos in _positions.values) {
      if (pos.dx + _nodeWidth > maxX) maxX = pos.dx + _nodeWidth;
      if (pos.dy + _nodeHeight > maxY) maxY = pos.dy + _nodeHeight;
    }
    _canvasSize = Size(maxX + _padding, maxY + _padding);
  }

  /// Force-directed layout: simple spring-based simulation.
  void _computeForceDirectedLayout() {
    final nodes = widget.graph.nodes;
    final edges = widget.graph.edges;
    final rng = math.Random(42);

    // Initialize random positions
    final positions = <String, Offset>{};
    for (final n in nodes) {
      positions[n.serviceId] = Offset(
        _padding + rng.nextDouble() * 600,
        _padding + rng.nextDouble() * 400,
      );
    }

    // Run simulation
    const iterations = 80;
    const repulsion = 8000.0;
    const attraction = 0.01;
    const damping = 0.9;

    final velocities = <String, Offset>{
      for (final n in nodes) n.serviceId: Offset.zero,
    };

    for (var iter = 0; iter < iterations; iter++) {
      // Repulsive forces between all pairs
      for (var i = 0; i < nodes.length; i++) {
        for (var j = i + 1; j < nodes.length; j++) {
          final a = nodes[i].serviceId;
          final b = nodes[j].serviceId;
          var delta = positions[a]! - positions[b]!;
          final dist = math.max(delta.distance, 1.0);
          final force = repulsion / (dist * dist);
          final normalized = delta / dist * force;
          velocities[a] = velocities[a]! + normalized;
          velocities[b] = velocities[b]! - normalized;
        }
      }

      // Attractive forces along edges
      for (final e in edges) {
        final a = e.sourceServiceId;
        final b = e.targetServiceId;
        if (!positions.containsKey(a) || !positions.containsKey(b)) continue;
        var delta = positions[b]! - positions[a]!;
        final dist = math.max(delta.distance, 1.0);
        final force = attraction * dist;
        final normalized = delta / dist * force;
        velocities[a] = velocities[a]! + normalized;
        velocities[b] = velocities[b]! - normalized;
      }

      // Apply velocities with damping
      for (final n in nodes) {
        velocities[n.serviceId] = velocities[n.serviceId]! * damping;
        positions[n.serviceId] = positions[n.serviceId]! + velocities[n.serviceId]!;
      }
    }

    // Normalize to positive coordinates
    double minX = double.infinity, minY = double.infinity;
    for (final pos in positions.values) {
      if (pos.dx < minX) minX = pos.dx;
      if (pos.dy < minY) minY = pos.dy;
    }

    _positions = {};
    double maxX = 0, maxY = 0;
    for (final entry in positions.entries) {
      final adjusted = Offset(
        entry.value.dx - minX + _padding,
        entry.value.dy - minY + _padding,
      );
      _positions[entry.key] = adjusted;
      if (adjusted.dx + _nodeWidth > maxX) maxX = adjusted.dx + _nodeWidth;
      if (adjusted.dy + _nodeHeight > maxY) maxY = adjusted.dy + _nodeHeight;
    }
    _canvasSize = Size(maxX + _padding, maxY + _padding);
  }

  void _zoomIn() {
    final matrix = _transformCtrl.value.clone();
    // ignore: deprecated_member_use
    matrix.scale(1.2);
    _transformCtrl.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformCtrl.value.clone();
    // ignore: deprecated_member_use
    matrix.scale(1 / 1.2);
    _transformCtrl.value = matrix;
  }

  void _resetView() {
    _transformCtrl.value = Matrix4.identity();
  }

  void _fitToScreen() {
    if (_canvasSize == Size.zero) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final viewSize = renderBox.size;

    final scaleX = viewSize.width / _canvasSize.width;
    final scaleY = viewSize.height / _canvasSize.height;
    final scale = math.min(scaleX, scaleY).clamp(0.3, 2.0);

    // ignore: deprecated_member_use
    final matrix = Matrix4.identity()..scale(scale);
    _transformCtrl.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.graph.nodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined,
                size: 48, color: CodeOpsColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No dependencies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Add dependencies to see the graph.',
              style: TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    // Build highlighted edge set for selected node
    final highlightedEdges = <int>{};
    if (widget.selectedNodeId != null) {
      for (var i = 0; i < widget.graph.edges.length; i++) {
        final e = widget.graph.edges[i];
        if (e.sourceServiceId == widget.selectedNodeId ||
            e.targetServiceId == widget.selectedNodeId) {
          highlightedEdges.add(i);
        }
      }
    }

    return Stack(
      children: [
        // Graph canvas with zoom/pan
        InteractiveViewer(
          transformationController: _transformCtrl,
          boundaryMargin: const EdgeInsets.all(200),
          minScale: 0.2,
          maxScale: 3.0,
          child: SizedBox(
            width: math.max(_canvasSize.width, 800),
            height: math.max(_canvasSize.height, 600),
            child: Stack(
              children: [
                // Edges (painted below nodes)
                CustomPaint(
                  size: _canvasSize,
                  painter: _EdgePainter(
                    edges: widget.graph.edges,
                    positions: _positions,
                    nodeWidth: _nodeWidth,
                    nodeHeight: _nodeHeight,
                    highlightedEdges: highlightedEdges,
                  ),
                ),
                // Nodes
                for (final node in widget.graph.nodes)
                  if (_positions.containsKey(node.serviceId))
                    Positioned(
                      left: _positions[node.serviceId]!.dx,
                      top: _positions[node.serviceId]!.dy,
                      child: GraphNodeWidget(
                        node: node,
                        isSelected: widget.selectedNodeId == node.serviceId,
                        isCycleNode:
                            widget.cycleNodeIds.contains(node.serviceId),
                        onTap: () => widget.onNodeTap?.call(node),
                      ),
                    ),
              ],
            ),
          ),
        ),
        // Controls overlay
        Positioned(
          right: 12,
          bottom: 12,
          child: GraphControls(
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onReset: _resetView,
            onFitToScreen: _fitToScreen,
            currentLayout: widget.layoutType,
            onLayoutChanged: (t) => widget.onLayoutChanged?.call(t),
          ),
        ),
      ],
    );
  }
}

/// Paints directed edges (arrows) between nodes.
class _EdgePainter extends CustomPainter {
  final List<DependencyEdgeResponse> edges;
  final Map<String, Offset> positions;
  final double nodeWidth;
  final double nodeHeight;
  final Set<int> highlightedEdges;

  _EdgePainter({
    required this.edges,
    required this.positions,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.highlightedEdges,
  });

  /// Color for each dependency type.
  static Color _edgeColor(DependencyType type) => switch (type) {
        DependencyType.httpRest => const Color(0xFF2196F3),
        DependencyType.grpc => const Color(0xFF9C27B0),
        DependencyType.kafkaTopic => const Color(0xFFFF9800),
        DependencyType.databaseShared => const Color(0xFF4CAF50),
        DependencyType.redisShared => const Color(0xFFF44336),
        DependencyType.library_ => const Color(0xFF009688),
        DependencyType.gatewayRoute => const Color(0xFF3F51B5),
        DependencyType.websocket => const Color(0xFF00BCD4),
        DependencyType.fileSystem => const Color(0xFF795548),
        DependencyType.other => const Color(0xFF9E9E9E),
      };

  /// Whether to use dashed style for this type.
  static bool _isDashed(DependencyType type) => switch (type) {
        DependencyType.kafkaTopic ||
        DependencyType.websocket ||
        DependencyType.other => true,
        _ => false,
      };

  /// Whether to use dotted style for this type.
  static bool _isDotted(DependencyType type) => switch (type) {
        DependencyType.library_ || DependencyType.fileSystem => true,
        _ => false,
      };

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < edges.length; i++) {
      final edge = edges[i];
      final sourcePos = positions[edge.sourceServiceId];
      final targetPos = positions[edge.targetServiceId];
      if (sourcePos == null || targetPos == null) continue;

      final isHighlighted = highlightedEdges.contains(i);
      final isOptional = edge.isRequired == false;
      final color = _edgeColor(edge.dependencyType);

      // Edge from right side of source to left side of target
      final start = Offset(
        sourcePos.dx + nodeWidth,
        sourcePos.dy + nodeHeight / 2,
      );
      final end = Offset(
        targetPos.dx,
        targetPos.dy + nodeHeight / 2,
      );

      final paint = Paint()
        ..color = isHighlighted ? color : color.withValues(alpha: 0.6)
        ..strokeWidth = isHighlighted
            ? 2.5
            : isOptional
                ? 1.0
                : 1.5
        ..style = PaintingStyle.stroke;

      final isDashed = _isDashed(edge.dependencyType) || isOptional;
      final isDotted = _isDotted(edge.dependencyType);

      if (isDashed || isDotted) {
        _drawDashedLine(canvas, start, end, paint,
            dashLength: isDotted ? 3.0 : 8.0,
            gapLength: isDotted ? 3.0 : 5.0);
      } else {
        canvas.drawLine(start, end, paint);
      }

      // Draw arrowhead
      _drawArrowHead(canvas, start, end, paint..style = PaintingStyle.fill);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLength = 8.0,
    double gapLength = 5.0,
  }) {
    final delta = end - start;
    final totalLength = delta.distance;
    final direction = delta / totalLength;

    var drawn = 0.0;
    while (drawn < totalLength) {
      final segEnd = math.min(drawn + dashLength, totalLength);
      canvas.drawLine(
        start + direction * drawn,
        start + direction * segEnd,
        paint,
      );
      drawn = segEnd + gapLength;
    }
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Paint paint) {
    const arrowSize = 8.0;
    final direction = (to - from);
    final dist = direction.distance;
    if (dist == 0) return;
    final normalized = direction / dist;

    final tip = to;
    final perp = Offset(-normalized.dy, normalized.dx);

    final path = ui.Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - normalized.dx * arrowSize + perp.dx * arrowSize / 2,
          tip.dy - normalized.dy * arrowSize + perp.dy * arrowSize / 2)
      ..lineTo(tip.dx - normalized.dx * arrowSize - perp.dx * arrowSize / 2,
          tip.dy - normalized.dy * arrowSize - perp.dy * arrowSize / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EdgePainter oldDelegate) =>
      oldDelegate.edges != edges ||
      oldDelegate.positions != positions ||
      oldDelegate.highlightedEdges != highlightedEdges;
}
