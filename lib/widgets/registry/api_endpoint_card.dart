/// Expandable endpoint card for the API Docs viewer.
///
/// Displays an HTTP method badge, path, summary, and expands to show
/// parameters, request body, response schemas, and a copy cURL button.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/openapi_spec.dart';
import '../../theme/colors.dart';
import 'api_schema_viewer.dart';

/// Color mapping for HTTP methods.
const _methodColors = <String, Color>{
  'GET': Color(0xFF4CAF50),
  'POST': Color(0xFF2196F3),
  'PUT': Color(0xFFFF9800),
  'DELETE': Color(0xFFF44336),
  'PATCH': Color(0xFF00BCD4),
  'OPTIONS': Color(0xFF9C27B0),
  'HEAD': Color(0xFF607D8B),
};

/// Expandable card displaying a single API endpoint.
///
/// Collapsed view shows method badge, path, and summary. Expanded view
/// adds parameters, request body, responses, and a copy cURL button.
class ApiEndpointCard extends StatefulWidget {
  /// The endpoint to display.
  final OpenApiEndpoint endpoint;

  /// Base URL for constructing cURL commands.
  final String baseUrl;

  /// Whether the card starts expanded.
  final bool initiallyExpanded;

  /// Creates an [ApiEndpointCard].
  const ApiEndpointCard({
    super.key,
    required this.endpoint,
    required this.baseUrl,
    this.initiallyExpanded = false,
  });

  @override
  State<ApiEndpointCard> createState() => _ApiEndpointCardState();
}

class _ApiEndpointCardState extends State<ApiEndpointCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.endpoint;
    final methodColor = _methodColors[ep.method] ?? CodeOpsColors.textTertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: _expanded
            ? CodeOpsColors.surface
            : CodeOpsColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _expanded
              ? methodColor.withValues(alpha: 0.4)
              : CodeOpsColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ep, methodColor),
          if (_expanded) _buildDetails(ep),
        ],
      ),
    );
  }

  Widget _buildHeader(OpenApiEndpoint ep, Color methodColor) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _MethodBadge(method: ep.method, color: methodColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ep.path,
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 13,
                      fontFamily: 'Fira Code',
                    ),
                  ),
                  if (ep.summary != null)
                    Text(
                      ep.summary!,
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (ep.deprecated)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CodeOpsColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'deprecated',
                  style: TextStyle(color: CodeOpsColors.warning, fontSize: 10),
                ),
              ),
            Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: CodeOpsColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(OpenApiEndpoint ep) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: CodeOpsColors.divider, height: 1),
          const SizedBox(height: 8),

          // Description.
          if (ep.description != null) ...[
            Text(
              ep.description!,
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Parameters.
          if (ep.parameters.isNotEmpty) ...[
            const _SectionTitle(text: 'Parameters'),
            const SizedBox(height: 4),
            ...ep.parameters.map(_buildParameter),
            const SizedBox(height: 12),
          ],

          // Request Body.
          if (ep.requestBody != null) ...[
            const _SectionTitle(text: 'Request Body'),
            const SizedBox(height: 4),
            _buildRequestBody(ep.requestBody!),
            const SizedBox(height: 12),
          ],

          // Responses.
          if (ep.responses.isNotEmpty) ...[
            const _SectionTitle(text: 'Responses'),
            const SizedBox(height: 4),
            ...ep.responses.entries.map(_buildResponse),
            const SizedBox(height: 12),
          ],

          // Copy cURL.
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _copyCurl(ep),
              icon: const Icon(Icons.copy, size: 14, color: CodeOpsColors.textSecondary),
              label: const Text(
                'Copy cURL',
                style: TextStyle(fontSize: 11, color: CodeOpsColors.textSecondary),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                side: const BorderSide(color: CodeOpsColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameter(OpenApiParameter param) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: CodeOpsColors.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                param.location,
                style: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            param.name,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 12,
              fontFamily: 'Fira Code',
            ),
          ),
          if (param.required) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: CodeOpsColors.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (param.schema != null) ...[
            const SizedBox(width: 8),
            Text(
              param.schema!.type ?? param.schema!.ref ?? '',
              style: const TextStyle(
                color: CodeOpsColors.secondary,
                fontSize: 11,
              ),
            ),
          ],
          if (param.description != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                param.description!,
                style: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestBody(OpenApiRequestBody body) {
    final contentEntries = body.content.entries.toList();
    if (contentEntries.isEmpty) {
      return const Text(
        'No content',
        style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (body.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              body.description!,
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ...contentEntries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                ApiSchemaViewer(schema: entry.value.schema),
              ],
            )),
      ],
    );
  }

  Widget _buildResponse(MapEntry<String, OpenApiResponse> entry) {
    final code = entry.key;
    final resp = entry.value;
    final codeColor = switch (code[0]) {
      '2' => CodeOpsColors.success,
      '3' => CodeOpsColors.secondary,
      '4' => CodeOpsColors.warning,
      '5' => CodeOpsColors.error,
      _ => CodeOpsColors.textTertiary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: codeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    color: codeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Fira Code',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  resp.description,
                  style: const TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (resp.content != null)
            ...resp.content!.entries.map((ce) => Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: ApiSchemaViewer(schema: ce.value.schema),
                )),
        ],
      ),
    );
  }

  void _copyCurl(OpenApiEndpoint ep) {
    final buffer = StringBuffer("curl -X ${ep.method} '${widget.baseUrl}${ep.path}'");

    // Add content-type header if there's a request body.
    if (ep.requestBody != null && ep.requestBody!.content.isNotEmpty) {
      final contentType = ep.requestBody!.content.keys.first;
      buffer.write(" \\\n  -H 'Content-Type: $contentType'");
    }

    // Add auth header placeholder.
    buffer.write(" \\\n  -H 'Authorization: Bearer <token>'");

    // Add body placeholder for POST/PUT/PATCH.
    if (ep.requestBody != null &&
        {'POST', 'PUT', 'PATCH'}.contains(ep.method)) {
      buffer.write(" \\\n  -d '{}'");
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('cURL copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// HTTP method badge with color coding.
class _MethodBadge extends StatelessWidget {
  final String method;
  final Color color;

  const _MethodBadge({required this.method, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Fira Code',
        ),
      ),
    );
  }
}

/// Section title within endpoint details.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CodeOpsColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
