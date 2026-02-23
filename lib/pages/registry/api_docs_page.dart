/// API documentation viewer page.
///
/// Fetches and displays OpenAPI 3.0 specifications from registered services.
/// Supports endpoint grouping by tag, search/filter, expand/collapse,
/// schema viewing, and try-it-out panels. Routed at `/registry/api-docs`
/// (service selector) and `/registry/api-docs/:serviceId` (deep link).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/openapi_spec.dart';
import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/registry/api_docs_search_bar.dart';
import '../../widgets/registry/api_docs_service_selector.dart';
import '../../widgets/registry/api_endpoint_group.dart';

/// The API docs viewer page at `/registry/api-docs`.
class ApiDocsPage extends ConsumerWidget {
  /// Optional service ID for deep-linking directly to a service's docs.
  final String? serviceId;

  /// Creates an [ApiDocsPage].
  const ApiDocsPage({super.key, this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Apply deep-link service ID if provided and not already selected.
    if (serviceId != null) {
      final current = ref.read(apiDocsServiceIdProvider);
      if (current != serviceId) {
        Future.microtask(() {
          ref.read(apiDocsServiceIdProvider.notifier).state = serviceId;
        });
      }
    }

    final selectedId = ref.watch(apiDocsServiceIdProvider);
    final specAsync = ref.watch(openApiSpecProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 16),
          if (selectedId == null)
            _buildEmptyState()
          else
            specAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => _buildError(error, ref),
              data: (spec) {
                if (spec == null) return _buildNoSpec();
                return _SpecContent(spec: spec);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (serviceId != null) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: CodeOpsColors.textSecondary),
            onPressed: () => context.go('/registry/api-docs'),
            tooltip: 'Back to service selector',
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Documentation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              const Text(
                'Interactive API documentation generated from OpenAPI specs.',
                style: TextStyle(
                  fontSize: 14,
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const ApiDocsServiceSelector(),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh, color: CodeOpsColors.textSecondary),
          onPressed: () => ref.invalidate(openApiSpecProvider),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.api, size: 48, color: CodeOpsColors.textTertiary),
            SizedBox(height: 16),
            Text(
              'Select a service to view its API documentation',
              style: TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSpec() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.warning_amber, size: 48, color: CodeOpsColors.warning),
            SizedBox(height: 16),
            Text(
              'No OpenAPI spec available',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'The service may not expose /v3/api-docs or has no HTTP API port.',
              style: TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: CodeOpsColors.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load API spec',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(openApiSpecProvider),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the parsed OpenAPI spec content.
class _SpecContent extends ConsumerWidget {
  final OpenApiSpec spec;

  const _SpecContent({required this.spec});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(apiDocsSearchProvider).toLowerCase();
    final methodFilter = ref.watch(apiDocsMethodFilterProvider);
    final expandedTags = ref.watch(apiDocsExpandedTagsProvider);

    // Group endpoints by tag.
    final tagDescriptions = <String, String?>{};
    for (final tag in spec.tags) {
      tagDescriptions[tag.name] = tag.description;
    }

    final grouped = <String, List<OpenApiEndpoint>>{};
    for (final ep in spec.endpoints) {
      // Apply method filter.
      if (methodFilter != null && ep.method != methodFilter) continue;

      // Apply search filter.
      if (search.isNotEmpty) {
        final matches = ep.path.toLowerCase().contains(search) ||
            (ep.summary?.toLowerCase().contains(search) ?? false) ||
            (ep.operationId?.toLowerCase().contains(search) ?? false) ||
            (ep.description?.toLowerCase().contains(search) ?? false);
        if (!matches) continue;
      }

      final tags = ep.tags.isEmpty ? ['Untagged'] : ep.tags;
      for (final tag in tags) {
        grouped.putIfAbsent(tag, () => []).add(ep);
      }
    }

    // Build base URL from servers or use localhost.
    final baseUrl = spec.servers.isNotEmpty
        ? spec.servers.first.url
        : 'http://localhost:8080';

    // Count total visible endpoints.
    final totalEndpoints =
        grouped.values.fold<int>(0, (sum, list) => sum + list.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spec info bar.
        _SpecInfoBar(spec: spec, endpointCount: totalEndpoints),
        const SizedBox(height: 12),

        // Search and filter.
        const ApiDocsSearchBar(),
        const SizedBox(height: 8),

        // Expand/Collapse all.
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                ref.read(apiDocsExpandedTagsProvider.notifier).state =
                    grouped.keys.toSet();
              },
              icon: const Icon(Icons.unfold_more, size: 16),
              label: const Text('Expand All', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {
                ref.read(apiDocsExpandedTagsProvider.notifier).state = {};
              },
              icon: const Icon(Icons.unfold_less, size: 16),
              label: const Text('Collapse All', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Endpoint groups.
        if (grouped.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No endpoints match your search',
                style: TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...grouped.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ApiEndpointGroup(
                  tagName: entry.key,
                  tagDescription: tagDescriptions[entry.key],
                  endpoints: entry.value,
                  baseUrl: baseUrl,
                  isExpanded: expandedTags.contains(entry.key),
                  onToggle: () {
                    final current =
                        ref.read(apiDocsExpandedTagsProvider.notifier).state;
                    final updated = Set<String>.from(current);
                    if (updated.contains(entry.key)) {
                      updated.remove(entry.key);
                    } else {
                      updated.add(entry.key);
                    }
                    ref.read(apiDocsExpandedTagsProvider.notifier).state =
                        updated;
                  },
                ),
              )),

        // Schemas section.
        if (spec.schemas.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SchemasSection(schemas: spec.schemas),
        ],
      ],
    );
  }
}

/// Info bar showing spec title, version, and endpoint count.
class _SpecInfoBar extends StatelessWidget {
  final OpenApiSpec spec;
  final int endpointCount;

  const _SpecInfoBar({required this.spec, required this.endpointCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.api, size: 20, color: CodeOpsColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  style: const TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (spec.description != null)
                  Text(
                    spec.description!,
                    style: const TextStyle(
                      color: CodeOpsColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CodeOpsColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'v${spec.version}',
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Fira Code',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CodeOpsColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$endpointCount endpoints',
              style: const TextStyle(
                color: CodeOpsColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CodeOpsColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${spec.schemas.length} schemas',
              style: const TextStyle(
                color: CodeOpsColors.secondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible schemas section showing all component schemas.
class _SchemasSection extends StatefulWidget {
  final Map<String, OpenApiSchema> schemas;

  const _SchemasSection({required this.schemas});

  @override
  State<_SchemasSection> createState() => _SchemasSectionState();
}

class _SchemasSectionState extends State<_SchemasSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: CodeOpsColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.schema_outlined,
                      size: 20, color: CodeOpsColors.secondary),
                  const SizedBox(width: 8),
                  const Text(
                    'Schemas',
                    style: TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CodeOpsColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.schemas.length}',
                      style: const TextStyle(
                        color: CodeOpsColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.schemas.entries
                    .map((entry) => _SchemaEntry(
                          name: entry.key,
                          schema: entry.value,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single named schema in the schemas section.
class _SchemaEntry extends StatefulWidget {
  final String name;
  final OpenApiSchema schema;

  const _SchemaEntry({required this.name, required this.schema});

  @override
  State<_SchemaEntry> createState() => _SchemaEntryState();
}

class _SchemaEntryState extends State<_SchemaEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: CodeOpsColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: CodeOpsColors.primary,
                      fontSize: 13,
                      fontFamily: 'Fira Code',
                    ),
                  ),
                  if (widget.schema.type != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.schema.type!,
                      style: const TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (widget.schema.description != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.schema.description!,
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
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _buildSchemaContent(),
            ),
        ],
      ),
    );
  }

  Widget _buildSchemaContent() {
    final schema = widget.schema;

    // Enum.
    if (schema.enumValues != null && schema.enumValues!.isNotEmpty) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: schema.enumValues!
            .map((v) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CodeOpsColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: CodeOpsColors.border),
                  ),
                  child: Text(
                    v,
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 11,
                      fontFamily: 'Fira Code',
                    ),
                  ),
                ))
            .toList(),
      );
    }

    // Object with properties.
    if (schema.properties != null) {
      final required = schema.required ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: schema.properties!.entries.map((entry) {
          final prop = entry.value;
          final isRequired = required.contains(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 12,
                    fontFamily: 'Fira Code',
                  ),
                ),
                if (isRequired)
                  const Text(' *',
                      style: TextStyle(
                          color: CodeOpsColors.error, fontSize: 12)),
                const SizedBox(width: 8),
                Text(
                  prop.ref ?? prop.type ?? 'any',
                  style: const TextStyle(
                    color: CodeOpsColors.secondary,
                    fontSize: 11,
                  ),
                ),
                if (prop.format != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${prop.format})',
                    style: const TextStyle(
                      color: CodeOpsColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (prop.description != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      prop.description!,
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
        }).toList(),
      );
    }

    return Text(
      schema.type ?? 'unknown',
      style: const TextStyle(
        color: CodeOpsColors.textTertiary,
        fontSize: 12,
      ),
    );
  }
}
