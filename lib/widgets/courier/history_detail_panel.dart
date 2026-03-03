/// Detail panel for a selected request history entry.
///
/// Displays the full request and response in tabbed view with syntax
/// highlighting. Provides actions to re-send, open in builder, save to
/// collection, and copy as cURL.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/courier_enums.dart';
import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../theme/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color helpers (same as list panel)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a colour for an HTTP method badge.
Color _methodColor(CourierHttpMethod? method) => switch (method) {
      CourierHttpMethod.get => CodeOpsColors.success,
      CourierHttpMethod.post => const Color(0xFF60A5FA),
      CourierHttpMethod.put => CodeOpsColors.warning,
      CourierHttpMethod.patch => const Color(0xFFA78BFA),
      CourierHttpMethod.delete => CodeOpsColors.error,
      CourierHttpMethod.head => CodeOpsColors.textTertiary,
      CourierHttpMethod.options => CodeOpsColors.textTertiary,
      null => CodeOpsColors.textTertiary,
    };

/// Returns a colour for an HTTP status code.
Color _statusColor(int? status) {
  if (status == null) return CodeOpsColors.textTertiary;
  if (status < 300) return CodeOpsColors.success;
  if (status < 400) return const Color(0xFF60A5FA);
  if (status < 500) return CodeOpsColors.warning;
  return CodeOpsColors.error;
}

// ─────────────────────────────────────────────────────────────────────────────
// HistoryDetailPanel
// ─────────────────────────────────────────────────────────────────────────────

/// Right-pane detail view for the selected history entry.
///
/// Fetches the full [RequestHistoryDetailResponse] (including headers and
/// body) via [courierHistoryDetailProvider] and renders it in a tabbed
/// layout with Request / Response tabs plus action buttons.
class HistoryDetailPanel extends ConsumerStatefulWidget {
  /// The history entry ID to display.
  final String historyId;

  /// Called when the user taps "Open in Builder".
  final void Function(RequestHistoryDetailResponse detail)? onOpenInBuilder;

  /// Called when the user taps "Re-send".
  final void Function(RequestHistoryDetailResponse detail)? onResend;

  /// Creates a [HistoryDetailPanel].
  const HistoryDetailPanel({
    super.key,
    required this.historyId,
    this.onOpenInBuilder,
    this.onResend,
  });

  @override
  ConsumerState<HistoryDetailPanel> createState() => _HistoryDetailPanelState();
}

class _HistoryDetailPanelState extends ConsumerState<HistoryDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Builds a cURL command from the detail response.
  String _buildCurl(RequestHistoryDetailResponse d) {
    final buf = StringBuffer();
    final method = d.requestMethod?.displayName ?? 'GET';
    final url = d.requestUrl ?? '';
    buf.write("curl -X $method '$url'");

    // Parse request headers JSON.
    if (d.requestHeaders != null && d.requestHeaders!.isNotEmpty) {
      try {
        final headers =
            Map<String, dynamic>.from(jsonDecode(d.requestHeaders!) as Map);
        for (final e in headers.entries) {
          buf.write(" \\\n  -H '${e.key}: ${e.value}'");
        }
      } catch (_) {
        // Headers may not be valid JSON; skip.
      }
    }

    if (d.requestBody != null && d.requestBody!.isNotEmpty) {
      final escaped = d.requestBody!.replaceAll("'", "'\\''");
      buf.write(" \\\n  -d '$escaped'");
    }

    return buf.toString();
  }

  void _copyAsCurl(RequestHistoryDetailResponse d) {
    final curl = _buildCurl(d);
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('cURL copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: CodeOpsColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(courierHistoryDetailProvider(widget.historyId));

    return Container(
      key: const Key('history_detail_panel'),
      color: CodeOpsColors.surface,
      child: detailAsync.when(
        data: (detail) => _buildContent(detail),
        loading: () => const Center(
            child: CircularProgressIndicator(color: CodeOpsColors.primary)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(
                    fontSize: 12, color: CodeOpsColors.error))),
      ),
    );
  }

  Widget _buildContent(RequestHistoryDetailResponse detail) {
    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────
        _DetailHeader(
          detail: detail,
          onOpenInBuilder: widget.onOpenInBuilder != null
              ? () => widget.onOpenInBuilder!(detail)
              : null,
          onCopyAsCurl: () => _copyAsCurl(detail),
          onResend: widget.onResend != null
              ? () => widget.onResend!(detail)
              : null,
        ),

        // ── Tabs ──────────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: CodeOpsColors.border)),
          ),
          child: TabBar(
            key: const Key('history_detail_tabs'),
            controller: _tabController,
            labelColor: CodeOpsColors.primary,
            unselectedLabelColor: CodeOpsColors.textSecondary,
            indicatorColor: CodeOpsColors.primary,
            labelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(text: 'Request'),
              Tab(text: 'Response'),
            ],
          ),
        ),

        // ── Tab views ─────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _RequestTab(key: const Key('request_tab'), detail: detail),
              _ResponseTab(key: const Key('response_tab'), detail: detail),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail header
// ─────────────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  final RequestHistoryDetailResponse detail;
  final VoidCallback? onOpenInBuilder;
  final VoidCallback onCopyAsCurl;
  final VoidCallback? onResend;

  const _DetailHeader({
    required this.detail,
    this.onOpenInBuilder,
    required this.onCopyAsCurl,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final method = detail.requestMethod;
    final url = detail.requestUrl ?? '';
    final status = detail.responseStatus;
    final duration = detail.responseTimeMs;
    final size = detail.responseSizeBytes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CodeOpsColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method + URL
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _methodColor(method).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  method?.displayName ?? '???',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _methodColor(method),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status + timing row
          Row(
            key: const Key('timing_row'),
            children: [
              if (status != null) ...[
                Text(
                  '$status',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (duration != null)
                Text(
                  '${duration}ms',
                  style: const TextStyle(
                      fontSize: 12, color: CodeOpsColors.textSecondary),
                ),
              if (size != null && size > 0) ...[
                const SizedBox(width: 12),
                Text(
                  _formatSize(size),
                  style: const TextStyle(
                      fontSize: 12, color: CodeOpsColors.textSecondary),
                ),
              ],
              const Spacer(),
              // Action buttons
              _ActionButton(
                key: const Key('open_in_builder_button'),
                icon: Icons.open_in_new,
                label: 'Open in Builder',
                onTap: onOpenInBuilder,
              ),
              const SizedBox(width: 6),
              _ActionButton(
                key: const Key('copy_curl_button'),
                icon: Icons.content_copy,
                label: 'Copy cURL',
                onTap: onCopyAsCurl,
              ),
              const SizedBox(width: 6),
              _ActionButton(
                key: const Key('resend_button'),
                icon: Icons.replay,
                label: 'Re-send',
                onTap: onResend,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request tab
// ─────────────────────────────────────────────────────────────────────────────

class _RequestTab extends StatelessWidget {
  final RequestHistoryDetailResponse detail;

  const _RequestTab({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Headers
        _SectionHeader(label: 'Headers'),
        const SizedBox(height: 6),
        _CodeBlock(
            key: const Key('request_headers_block'),
            content: _prettyJson(detail.requestHeaders)),
        const SizedBox(height: 16),

        // Body
        _SectionHeader(label: 'Body'),
        const SizedBox(height: 6),
        _CodeBlock(
            key: const Key('request_body_block'),
            content: _prettyJson(detail.requestBody)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response tab
// ─────────────────────────────────────────────────────────────────────────────

class _ResponseTab extends StatelessWidget {
  final RequestHistoryDetailResponse detail;

  const _ResponseTab({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status
        Row(
          children: [
            _SectionHeader(label: 'Status'),
            const SizedBox(width: 8),
            if (detail.responseStatus != null)
              Text(
                '${detail.responseStatus}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(detail.responseStatus),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Headers
        _SectionHeader(label: 'Response Headers'),
        const SizedBox(height: 6),
        _CodeBlock(
            key: const Key('response_headers_block'),
            content: _prettyJson(detail.responseHeaders)),
        const SizedBox(height: 16),

        // Body
        _SectionHeader(label: 'Response Body'),
        const SizedBox(height: 6),
        _CodeBlock(
            key: const Key('response_body_block'),
            content: _prettyJson(detail.responseBody)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Tries to pretty-print JSON, otherwise returns raw text.
String _prettyJson(String? raw) {
  if (raw == null || raw.isEmpty) return '(empty)';
  try {
    final decoded = jsonDecode(raw);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return raw;
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: CodeOpsColors.textSecondary,
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String content;

  const _CodeBlock({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: SelectableText(
        content,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: CodeOpsColors.textPrimary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        onTap != null ? CodeOpsColors.textSecondary : CodeOpsColors.textTertiary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: CodeOpsColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
