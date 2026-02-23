/// Service selector dropdown for the API Docs viewer.
///
/// Displays a dropdown of registered services, allowing the user to select
/// which service's OpenAPI spec to load. Shows a health dot and service type
/// next to each entry.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/registry_models.dart';
import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';

/// Dropdown selector for choosing a service to view API documentation.
///
/// Watches [registryServicesProvider] for the service list and writes the
/// selected service ID to [apiDocsServiceIdProvider].
class ApiDocsServiceSelector extends ConsumerWidget {
  /// Creates an [ApiDocsServiceSelector].
  const ApiDocsServiceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(registryServicesProvider);
    final selectedId = ref.watch(apiDocsServiceIdProvider);

    return servicesAsync.when(
      loading: () => const SizedBox(
        width: 300,
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox(
        width: 300,
        child: Text(
          'Failed to load services',
          style: TextStyle(color: CodeOpsColors.error, fontSize: 13),
        ),
      ),
      data: (page) {
        final services = page.content;
        if (services.isEmpty) {
          return const SizedBox(
            width: 300,
            child: Text(
              'No services registered',
              style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 13),
            ),
          );
        }

        return SizedBox(
          width: 300,
          child: DropdownButtonFormField<String>(
            initialValue: selectedId,
            isExpanded: true,
            hint: const Text(
              'Select Service',
              style: TextStyle(color: CodeOpsColors.textTertiary, fontSize: 13),
            ),
            dropdownColor: CodeOpsColors.surface,
            decoration: InputDecoration(
              isDense: true,
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
            ),
            items: services.map((s) => _buildItem(s)).toList(),
            onChanged: (value) {
              ref.read(apiDocsServiceIdProvider.notifier).state = value;
            },
          ),
        );
      },
    );
  }

  DropdownMenuItem<String> _buildItem(ServiceRegistrationResponse service) {
    return DropdownMenuItem<String>(
      value: service.id,
      child: Text(
        service.name,
        style: const TextStyle(
          color: CodeOpsColors.textPrimary,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
