/// Service selector header for impact analysis.
///
/// Dropdown to select a source service for impact analysis,
/// with a title and optional back navigation.
library;

import 'package:flutter/material.dart';

import '../../models/registry_models.dart';
import '../../theme/colors.dart';

/// Header bar with service selector dropdown for impact analysis.
///
/// Displays a title, back button, and a [DropdownButton] populated
/// with the provided [services]. Fires [onServiceSelected] when
/// the user picks a service.
class ServiceSelectorHeader extends StatelessWidget {
  /// Available services to select from.
  final List<ServiceRegistrationResponse> services;

  /// Currently selected service ID, if any.
  final String? selectedServiceId;

  /// Callback when a service is selected.
  final ValueChanged<String?> onServiceSelected;

  /// Callback for the back button.
  final VoidCallback? onBack;

  /// Creates a [ServiceSelectorHeader].
  const ServiceSelectorHeader({
    super.key,
    required this.services,
    this.selectedServiceId,
    required this.onServiceSelected,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              tooltip: 'Back to graph',
              style: IconButton.styleFrom(
                foregroundColor: CodeOpsColors.textSecondary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Text(
            'Impact Analysis',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          // Service selector
          const Text(
            'Source Service:',
            style: TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: CodeOpsColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: CodeOpsColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedServiceId,
                hint: const Text(
                  'Select a service...',
                  style: TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
                dropdownColor: CodeOpsColors.surface,
                style: const TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textPrimary,
                ),
                icon: const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: CodeOpsColors.textTertiary,
                ),
                isExpanded: true,
                items: services
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(
                          s.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onServiceSelected,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
