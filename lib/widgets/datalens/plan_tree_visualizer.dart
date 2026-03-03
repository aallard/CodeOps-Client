/// Execution plan visualizer for the DataLens SQL editor.
///
/// Provides three views of a [PlanResult]:
/// - **Tree** — hierarchical node cards with cost gradient bars,
///   expand/collapse, and click-to-detail
/// - **Table** — flat sortable table of all plan nodes
/// - **Raw** — raw JSON/text output
///
/// Includes a summary bar showing total cost, estimated rows,
/// planning/execution time, node count, and the most expensive node.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/datalens/plan_execution_service.dart';
import '../../theme/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Plan Tab — Top-Level Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Top-level plan visualizer shown in the Plan tab of [SqlResultsPanel].
///
/// Composes [_PlanSummaryBar], a Tree/Table/Raw sub-tab bar, and the
/// corresponding view. Receives a [PlanResult] from the parent.
class PlanVisualizer extends StatefulWidget {
  /// The parsed plan result to display.
  final PlanResult planResult;

  /// Creates a [PlanVisualizer].
  const PlanVisualizer({super.key, required this.planResult});

  @override
  State<PlanVisualizer> createState() => _PlanVisualizerState();
}

class _PlanVisualizerState extends State<PlanVisualizer> {
  int _subTab = 0; // 0=Tree, 1=Table, 2=Raw
  PlanNode? _selectedNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary bar
        _PlanSummaryBar(planResult: widget.planResult),
        const Divider(height: 1, color: CodeOpsColors.border),

        // Sub-tab bar: Tree | Table | Raw
        _buildSubTabBar(),
        const Divider(height: 1, color: CodeOpsColors.border),

        // Content
        Expanded(
          child: switch (_subTab) {
            0 => _buildTreeView(),
            1 => _PlanTable(planResult: widget.planResult),
            2 => _RawJsonView(rawOutput: widget.planResult.rawOutput),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  /// Builds the Tree | Table | Raw sub-tab bar.
  Widget _buildSubTabBar() {
    return Container(
      color: CodeOpsColors.surface,
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          _subTabButton('Tree', 0),
          _subTabButton('Table', 1),
          _subTabButton('Raw', 2),
        ],
      ),
    );
  }

  /// Builds a single sub-tab button.
  Widget _subTabButton(String label, int index) {
    final isSelected = _subTab == index;
    return InkWell(
      onTap: () => setState(() => _subTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? CodeOpsColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? CodeOpsColors.textPrimary
                : CodeOpsColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Builds the tree view — tree on the left, detail panel on the right.
  Widget _buildTreeView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tree
        Expanded(
          flex: _selectedNode != null ? 3 : 1,
          child: Container(
            color: CodeOpsColors.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _PlanNodeCard(
                node: widget.planResult.root,
                totalPlanCost: widget.planResult.totalCost,
                depth: 0,
                isAnalyze: widget.planResult.isAnalyze,
                selectedNode: _selectedNode,
                onNodeSelected: (node) {
                  setState(() {
                    _selectedNode =
                        identical(node, _selectedNode) ? null : node;
                  });
                },
              ),
            ),
          ),
        ),

        // Detail panel (right)
        if (_selectedNode != null) ...[
          const VerticalDivider(width: 1, color: CodeOpsColors.border),
          Expanded(
            flex: 2,
            child: _PlanDetailPanel(
              node: _selectedNode!,
              isAnalyze: widget.planResult.isAnalyze,
              onClose: () => setState(() => _selectedNode = null),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Summary Bar
// ─────────────────────────────────────────────────────────────────────────────

/// Horizontal bar showing plan-level statistics.
class _PlanSummaryBar extends StatelessWidget {
  final PlanResult planResult;

  const _PlanSummaryBar({required this.planResult});

  @override
  Widget build(BuildContext context) {
    final most = planResult.mostExpensiveNode;

    return Container(
      color: CodeOpsColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 24,
        runSpacing: 4,
        children: [
          _metric('Total Cost', planResult.totalCost.toStringAsFixed(2)),
          _metric('Est. Rows', planResult.estimatedRows.toStringAsFixed(0)),
          _metric('Nodes', planResult.nodeCount.toString()),
          _metric('Costliest', most.nodeType),
          if (planResult.planningTime != null)
            _metric(
              'Planning',
              '${planResult.planningTime!.toStringAsFixed(3)} ms',
            ),
          if (planResult.executionTime != null)
            _metric(
              'Execution',
              '${planResult.executionTime!.toStringAsFixed(3)} ms',
            ),
        ],
      ),
    );
  }

  /// A single metric label + value.
  Widget _metric(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 11,
            color: CodeOpsColors.textTertiary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Node Card (Tree View)
// ─────────────────────────────────────────────────────────────────────────────

/// A single node in the plan tree, rendered as a card.
///
/// Shows the node type, cost bar (green→red gradient relative to the total
/// plan cost), rows/time stats, and recursively renders child nodes with
/// indentation. Supports expand/collapse and click-to-select.
class _PlanNodeCard extends StatefulWidget {
  final PlanNode node;
  final double totalPlanCost;
  final int depth;
  final bool isAnalyze;
  final PlanNode? selectedNode;
  final ValueChanged<PlanNode> onNodeSelected;

  const _PlanNodeCard({
    required this.node,
    required this.totalPlanCost,
    required this.depth,
    required this.isAnalyze,
    this.selectedNode,
    required this.onNodeSelected,
  });

  @override
  State<_PlanNodeCard> createState() => _PlanNodeCardState();
}

class _PlanNodeCardState extends State<_PlanNodeCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isSelected = identical(node, widget.selectedNode);
    final hasChildren = node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Node card
        GestureDetector(
          onTap: () => widget.onNodeSelected(node),
          child: Container(
            margin: EdgeInsets.only(
              left: widget.depth * 24.0,
              bottom: 4,
            ),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? CodeOpsColors.primary.withValues(alpha: 0.15)
                  : CodeOpsColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? CodeOpsColors.primary : CodeOpsColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: expand toggle + node type + relationship
                Row(
                  children: [
                    // Expand/collapse toggle
                    if (hasChildren)
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Icon(
                          _expanded
                              ? Icons.expand_more
                              : Icons.chevron_right,
                          size: 16,
                          color: CodeOpsColors.textSecondary,
                        ),
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 4),

                    // Node type label
                    Text(
                      node.nodeType,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CodeOpsColors.textPrimary,
                      ),
                    ),

                    // Table name
                    if (node.tableName != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'on ${node.tableName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: CodeOpsColors.secondary,
                        ),
                      ),
                    ],

                    // Relationship badge
                    if (node.relationship != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: CodeOpsColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          node.relationship!,
                          style: const TextStyle(
                            fontSize: 9,
                            color: CodeOpsColors.primary,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Cost value
                    Text(
                      'Cost: ${node.totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Cost bar
                _CostBar(
                  cost: node.totalCost,
                  maxCost: widget.totalPlanCost,
                ),

                const SizedBox(height: 4),

                // Stats row
                Wrap(
                  spacing: 12,
                  runSpacing: 2,
                  children: [
                    _statChip(
                      'Rows',
                      node.planRows.toStringAsFixed(0),
                    ),
                    if (widget.isAnalyze && node.actualRows != null)
                      _statChip(
                        'Actual Rows',
                        node.actualRows!.toStringAsFixed(0),
                      ),
                    if (widget.isAnalyze && node.actualTime != null)
                      _statChip(
                        'Time',
                        '${node.actualTime!.toStringAsFixed(3)} ms',
                      ),
                    if (node.indexName != null)
                      _statChip('Index', node.indexName!),
                    if (widget.isAnalyze && node.actualLoops != null)
                      _statChip('Loops', node.actualLoops!.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Children (indented)
        if (hasChildren && _expanded)
          for (final child in node.children)
            _PlanNodeCard(
              node: child,
              totalPlanCost: widget.totalPlanCost,
              depth: widget.depth + 1,
              isAnalyze: widget.isAnalyze,
              selectedNode: widget.selectedNode,
              onNodeSelected: widget.onNodeSelected,
            ),
      ],
    );
  }

  /// A small stat chip (label: value).
  Widget _statChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: CodeOpsColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cost Bar
// ─────────────────────────────────────────────────────────────────────────────

/// Horizontal bar showing the cost as a fraction of the total plan cost.
///
/// Uses a green→yellow→red gradient where green = low cost fraction and
/// red = high cost fraction.
class _CostBar extends StatelessWidget {
  final double cost;
  final double maxCost;

  const _CostBar({required this.cost, required this.maxCost});

  @override
  Widget build(BuildContext context) {
    final fraction = maxCost > 0 ? (cost / maxCost).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // Background
            Container(color: CodeOpsColors.border),
            // Filled portion
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _costColor(0),
                      _costColor(fraction),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a color on the green→yellow→red gradient for [t] in [0, 1].
  static Color _costColor(double t) {
    // 0.0 = green (#4ADE80), 0.5 = yellow (#FBBF24), 1.0 = red (#EF4444)
    if (t <= 0.5) {
      return Color.lerp(CodeOpsColors.success, CodeOpsColors.warning, t * 2)!;
    }
    return Color.lerp(
        CodeOpsColors.warning, CodeOpsColors.error, (t - 0.5) * 2)!;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Detail Panel
// ─────────────────────────────────────────────────────────────────────────────

/// Side panel showing full properties of a selected [PlanNode].
///
/// Displays all node fields, and when ANALYZE data is present shows an
/// actual-vs-estimated comparison with percentage difference.
class _PlanDetailPanel extends StatelessWidget {
  final PlanNode node;
  final bool isAnalyze;
  final VoidCallback onClose;

  const _PlanDetailPanel({
    required this.node,
    required this.isAnalyze,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: CodeOpsColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    node.nodeType,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CodeOpsColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onClose,
                  color: CodeOpsColors.textSecondary,
                  splashRadius: 14,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),

          // Properties
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Core properties
                  _sectionHeader('Estimates'),
                  _property('Total Cost', node.totalCost.toStringAsFixed(2)),
                  _property(
                      'Startup Cost', node.startupCost.toStringAsFixed(2)),
                  _property('Plan Rows', node.planRows.toStringAsFixed(0)),
                  _property('Plan Width', '${node.planWidth} bytes'),

                  // ANALYZE comparison
                  if (isAnalyze && node.actualRows != null) ...[
                    const SizedBox(height: 12),
                    _sectionHeader('Actual vs Estimated'),
                    _comparison(
                      'Rows',
                      estimated: node.planRows,
                      actual: node.actualRows!,
                    ),
                    if (node.actualTime != null)
                      _property(
                        'Actual Time',
                        '${node.actualTime!.toStringAsFixed(3)} ms',
                      ),
                    if (node.actualStartupTime != null)
                      _property(
                        'Actual Startup',
                        '${node.actualStartupTime!.toStringAsFixed(3)} ms',
                      ),
                    if (node.actualTotalTime != null)
                      _property(
                        'Actual Total',
                        '${node.actualTotalTime!.toStringAsFixed(3)} ms',
                      ),
                    if (node.actualLoops != null)
                      _property('Loops', node.actualLoops!.toString()),
                    if (node.rowsRemovedByFilter != null)
                      _property(
                        'Rows Removed by Filter',
                        node.rowsRemovedByFilter!.toStringAsFixed(0),
                      ),
                  ],

                  // Access details
                  if (_hasAccessDetails()) ...[
                    const SizedBox(height: 12),
                    _sectionHeader('Access Details'),
                    if (node.tableName != null)
                      _property('Table', node.tableName!),
                    if (node.schemaName != null)
                      _property('Schema', node.schemaName!),
                    if (node.alias != null)
                      _property('Alias', node.alias!),
                    if (node.indexName != null)
                      _property('Index', node.indexName!),
                    if (node.scanDirection != null)
                      _property('Scan Direction', node.scanDirection!),
                    if (node.relationship != null)
                      _property('Relationship', node.relationship!),
                    if (node.joinType != null)
                      _property('Join Type', node.joinType!),
                  ],

                  // Conditions
                  if (_hasConditions()) ...[
                    const SizedBox(height: 12),
                    _sectionHeader('Conditions'),
                    if (node.filter != null) _property('Filter', node.filter!),
                    if (node.indexCondition != null)
                      _property('Index Cond', node.indexCondition!),
                    if (node.hashCondition != null)
                      _property('Hash Cond', node.hashCondition!),
                  ],

                  // Sort keys
                  if (node.sortKey != null && node.sortKey!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionHeader('Sort Keys'),
                    _property('Keys', node.sortKey!.join(', ')),
                  ],

                  // Output columns
                  if (node.output != null && node.output!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionHeader('Output'),
                    _property('Columns', node.output!.join(', ')),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Whether any access detail fields are populated.
  bool _hasAccessDetails() =>
      node.tableName != null ||
      node.schemaName != null ||
      node.alias != null ||
      node.indexName != null ||
      node.scanDirection != null ||
      node.relationship != null ||
      node.joinType != null;

  /// Whether any condition fields are populated.
  bool _hasConditions() =>
      node.filter != null ||
      node.indexCondition != null ||
      node.hashCondition != null;

  /// Renders a section header.
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: CodeOpsColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Renders a single property row (label: value).
  Widget _property(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: CodeOpsColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders an actual-vs-estimated comparison with percentage difference.
  Widget _comparison(
    String label, {
    required double estimated,
    required double actual,
  }) {
    final diff = estimated > 0
        ? ((actual - estimated) / estimated * 100)
        : (actual > 0 ? double.infinity : 0.0);
    final diffText = diff.isFinite ? '${diff.toStringAsFixed(1)}%' : 'N/A';
    final isOver = diff > 10; // More than 10% over-estimate
    final isUnder = diff < -10; // More than 10% under-estimate

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                children: [
                  TextSpan(
                    text: 'Est: ${estimated.toStringAsFixed(0)}',
                    style: const TextStyle(color: CodeOpsColors.textSecondary),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: 'Act: ${actual.toStringAsFixed(0)}',
                    style: const TextStyle(color: CodeOpsColors.textPrimary),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: '($diffText)',
                    style: TextStyle(
                      color: isOver
                          ? CodeOpsColors.error
                          : isUnder
                              ? CodeOpsColors.warning
                              : CodeOpsColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Table (Tabular View)
// ─────────────────────────────────────────────────────────────────────────────

/// Flat table view of all plan nodes with sortable columns.
class _PlanTable extends StatefulWidget {
  final PlanResult planResult;

  const _PlanTable({required this.planResult});

  @override
  State<_PlanTable> createState() => _PlanTableState();
}

class _PlanTableState extends State<_PlanTable> {
  int _sortColumn = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final nodes = _flattenNodes(widget.planResult.root);
    _sortNodes(nodes);

    return Container(
      color: CodeOpsColors.background,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColumn,
            sortAscending: _sortAscending,
            headingRowHeight: 32,
            dataRowMinHeight: 28,
            dataRowMaxHeight: 28,
            columnSpacing: 16,
            horizontalMargin: 12,
            headingTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textSecondary,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: CodeOpsColors.textPrimary,
            ),
            columns: [
              _sortableColumn('Node Type', 0),
              _sortableColumn('Table', 1),
              _sortableColumn('Index', 2),
              _sortableColumn('Rows Est', 3),
              if (widget.planResult.isAnalyze)
                _sortableColumn('Rows Act', 4),
              _sortableColumn('Cost', widget.planResult.isAnalyze ? 5 : 4),
              if (widget.planResult.isAnalyze)
                _sortableColumn('Time (ms)', 6),
              if (widget.planResult.isAnalyze)
                _sortableColumn('Loops', 7),
            ],
            rows: nodes.map((n) {
              return DataRow(cells: [
                DataCell(Text(n.nodeType)),
                DataCell(Text(n.tableName ?? '—')),
                DataCell(Text(n.indexName ?? '—')),
                DataCell(Text(n.planRows.toStringAsFixed(0))),
                if (widget.planResult.isAnalyze)
                  DataCell(Text(
                    n.actualRows?.toStringAsFixed(0) ?? '—',
                  )),
                DataCell(Text(n.totalCost.toStringAsFixed(2))),
                if (widget.planResult.isAnalyze)
                  DataCell(Text(
                    n.actualTime?.toStringAsFixed(3) ?? '—',
                  )),
                if (widget.planResult.isAnalyze)
                  DataCell(Text(n.actualLoops?.toString() ?? '—')),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Creates a sortable DataColumn.
  DataColumn _sortableColumn(String label, int index) {
    return DataColumn(
      label: Text(label),
      onSort: (colIndex, ascending) {
        setState(() {
          _sortColumn = colIndex;
          _sortAscending = ascending;
        });
      },
    );
  }

  /// Flattens the plan tree into a list of nodes.
  static List<PlanNode> _flattenNodes(PlanNode node) {
    final result = <PlanNode>[node];
    for (final child in node.children) {
      result.addAll(_flattenNodes(child));
    }
    return result;
  }

  /// Sorts the node list by the selected column.
  void _sortNodes(List<PlanNode> nodes) {
    final isAnalyze = widget.planResult.isAnalyze;

    nodes.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 0:
          cmp = a.nodeType.compareTo(b.nodeType);
        case 1:
          cmp = (a.tableName ?? '').compareTo(b.tableName ?? '');
        case 2:
          cmp = (a.indexName ?? '').compareTo(b.indexName ?? '');
        case 3:
          cmp = a.planRows.compareTo(b.planRows);
        case 4:
          if (isAnalyze) {
            cmp = (a.actualRows ?? 0).compareTo(b.actualRows ?? 0);
          } else {
            cmp = a.totalCost.compareTo(b.totalCost);
          }
        case 5:
          cmp = a.totalCost.compareTo(b.totalCost);
        case 6:
          cmp = (a.actualTime ?? 0).compareTo(b.actualTime ?? 0);
        case 7:
          cmp = (a.actualLoops ?? 0).compareTo(b.actualLoops ?? 0);
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Raw JSON View
// ─────────────────────────────────────────────────────────────────────────────

/// Raw JSON/text output view with a copy button.
class _RawJsonView extends StatelessWidget {
  final String rawOutput;

  const _RawJsonView({required this.rawOutput});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CodeOpsColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Copy button
          Container(
            color: CodeOpsColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: rawOutput));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text(
                    'Copy',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: CodeOpsColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 28),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),

          // JSON content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                rawOutput,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
