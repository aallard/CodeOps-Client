/// Collapsible endpoint group widget for the API Docs viewer.
///
/// Groups endpoints by tag name with expand/collapse functionality.
/// Each group renders a header with the tag name and endpoint count,
/// followed by a list of [ApiEndpointCard] widgets.
library;

import 'package:flutter/material.dart';

import '../../models/openapi_spec.dart';
import '../../theme/colors.dart';
import 'api_endpoint_card.dart';

/// Collapsible group of endpoints sharing the same tag.
///
/// Renders a clickable header that toggles visibility of the endpoint
/// cards within the group. The header shows the tag name, description,
/// and endpoint count.
class ApiEndpointGroup extends StatelessWidget {
  /// Tag name for this group.
  final String tagName;

  /// Optional tag description.
  final String? tagDescription;

  /// Endpoints belonging to this group.
  final List<OpenApiEndpoint> endpoints;

  /// Base URL for cURL construction.
  final String baseUrl;

  /// Whether the group is currently expanded.
  final bool isExpanded;

  /// Callback when the group header is tapped.
  final VoidCallback onToggle;

  /// Creates an [ApiEndpointGroup].
  const ApiEndpointGroup({
    super.key,
    required this.tagName,
    this.tagDescription,
    required this.endpoints,
    required this.baseUrl,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
            child: Column(
              children: endpoints
                  .map((ep) => ApiEndpointCard(
                        endpoint: ep,
                        baseUrl: baseUrl,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: CodeOpsColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: CodeOpsColors.border),
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: CodeOpsColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tagName,
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (tagDescription != null)
                    Text(
                      tagDescription!,
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CodeOpsColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${endpoints.length}',
                style: const TextStyle(
                  color: CodeOpsColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
