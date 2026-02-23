/// Schema viewer widget for API Docs.
///
/// Renders an [OpenApiSchema] as a tree of property rows with types,
/// formats, required markers, enum values, and nested objects.
library;

import 'package:flutter/material.dart';

import '../../models/openapi_spec.dart';
import '../../theme/colors.dart';

/// Displays an [OpenApiSchema] as a collapsible property tree.
///
/// Object schemas render as an indented list of property rows. Array schemas
/// show the item type. Primitive schemas show the type and format inline.
class ApiSchemaViewer extends StatelessWidget {
  /// The schema to display.
  final OpenApiSchema schema;

  /// Optional label for the root element (e.g., "Request Body").
  final String? label;

  /// Current nesting depth (used for indentation).
  final int depth;

  /// Creates an [ApiSchemaViewer].
  const ApiSchemaViewer({
    super.key,
    required this.schema,
    this.label,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Prevent infinite nesting.
    if (depth > 6) {
      return const Text(
        '(nested object)',
        style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 12),
      );
    }

    // Enum values.
    if (schema.enumValues != null && schema.enumValues!.isNotEmpty) {
      return _buildEnum();
    }

    // Object with properties.
    if (schema.properties != null && schema.properties!.isNotEmpty) {
      return _buildObject();
    }

    // Array.
    if (schema.type == 'array' && schema.items != null) {
      return _buildArray();
    }

    // oneOf / anyOf.
    if (schema.oneOf != null && schema.oneOf!.isNotEmpty) {
      return _buildComposite('oneOf', schema.oneOf!);
    }
    if (schema.anyOf != null && schema.anyOf!.isNotEmpty) {
      return _buildComposite('anyOf', schema.anyOf!);
    }

    // Primitive or ref.
    return _buildPrimitive();
  }

  Widget _buildObject() {
    final required = schema.required ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (schema.ref != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              schema.ref!,
              style: const TextStyle(
                color: CodeOpsColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ...schema.properties!.entries.map((entry) {
          final isRequired = required.contains(entry.key);
          return _PropertyRow(
            name: entry.key,
            schema: entry.value,
            isRequired: isRequired,
            depth: depth + 1,
          );
        }),
      ],
    );
  }

  Widget _buildArray() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Row(
          children: [
            _TypeBadge(type: 'array'),
            const SizedBox(width: 4),
            const Text('of ', style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 11)),
            _TypeBadge(type: schema.items!.ref ?? schema.items!.type ?? 'object'),
          ],
        ),
        if (schema.items!.properties != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ApiSchemaViewer(schema: schema.items!, depth: depth + 1),
          ),
      ],
    );
  }

  Widget _buildEnum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: const TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            _TypeBadge(type: schema.type ?? 'string'),
            const SizedBox(width: 4),
            const Text('enum', style: TextStyle(color: CodeOpsColors.secondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: schema.enumValues!
              .map((v) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        ),
      ],
    );
  }

  Widget _buildComposite(String keyword, List<OpenApiSchema> schemas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Text(
          keyword,
          style: const TextStyle(
            color: CodeOpsColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        ...schemas.map((s) => Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: ApiSchemaViewer(schema: s, depth: depth + 1),
            )),
      ],
    );
  }

  Widget _buildPrimitive() {
    final typeName = schema.ref ?? schema.type ?? 'any';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
        ],
        _TypeBadge(type: typeName),
        if (schema.format != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${schema.format})',
            style: const TextStyle(color: CodeOpsColors.textTertiary, fontSize: 11),
          ),
        ],
        if (schema.description != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              schema.description!,
              style: const TextStyle(color: CodeOpsColors.textTertiary, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// A single property row in the schema tree.
class _PropertyRow extends StatelessWidget {
  final String name;
  final OpenApiSchema schema;
  final bool isRequired;
  final int depth;

  const _PropertyRow({
    required this.name,
    required this.schema,
    required this.isRequired,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = schema.properties != null && schema.properties!.isNotEmpty;
    final isArray = schema.type == 'array' && schema.items != null;
    final typeName = schema.ref ?? schema.type ?? 'any';

    return Padding(
      padding: EdgeInsets.only(left: (depth - 1) * 16.0, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Fira Code',
                ),
              ),
              if (isRequired) ...[
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
              const SizedBox(width: 8),
              if (isArray) ...[
                _TypeBadge(type: 'array'),
                const SizedBox(width: 2),
                const Text('<', style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 11)),
                _TypeBadge(type: schema.items!.ref ?? schema.items!.type ?? 'object'),
                const Text('>', style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 11)),
              ] else
                _TypeBadge(type: typeName),
              if (schema.format != null) ...[
                const SizedBox(width: 4),
                Text(
                  '(${schema.format})',
                  style: const TextStyle(color: CodeOpsColors.textTertiary, fontSize: 11),
                ),
              ],
              if (schema.enumValues != null) ...[
                const SizedBox(width: 4),
                const Text(
                  'enum',
                  style: TextStyle(color: CodeOpsColors.secondary, fontSize: 11),
                ),
              ],
            ],
          ),
          if (schema.description != null)
            Padding(
              padding: EdgeInsets.only(left: (depth - 1) * 16.0),
              child: Text(
                schema.description!,
                style: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ),
          if (schema.enumValues != null && schema.enumValues!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: (depth - 1) * 16.0, top: 2),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: schema.enumValues!
                    .map((v) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: CodeOpsColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            v,
                            style: const TextStyle(
                              color: CodeOpsColors.textPrimary,
                              fontSize: 10,
                              fontFamily: 'Fira Code',
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          if (hasChildren)
            ApiSchemaViewer(schema: schema, depth: depth),
          if (isArray && schema.items!.properties != null)
            ApiSchemaViewer(schema: schema.items!, depth: depth),
        ],
      ),
    );
  }
}

/// Badge showing a schema type name with color coding.
class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'string' => CodeOpsColors.success,
      'integer' || 'number' || 'int64' || 'int32' => CodeOpsColors.secondary,
      'boolean' => CodeOpsColors.warning,
      'array' => CodeOpsColors.primary,
      'object' => CodeOpsColors.primaryVariant,
      _ => CodeOpsColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontSize: 11, fontFamily: 'Fira Code'),
      ),
    );
  }
}
