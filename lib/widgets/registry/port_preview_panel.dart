/// Informational panel showing port allocation preview for a service type.
///
/// Displays which port types are typically needed based on the selected
/// [ServiceType]. Ports are NOT allocated until after registration — this
/// is purely informational. In edit mode, shows actual allocated ports.
library;

import 'package:flutter/material.dart';

import '../../models/registry_enums.dart';
import '../../models/registry_models.dart';
import '../../theme/colors.dart';

/// Port type recommendations by service type.
const _portRecommendations = <ServiceType, List<PortType>>{
  ServiceType.springBootApi: [PortType.httpApi, PortType.database, PortType.actuator],
  ServiceType.flutterWeb: [PortType.frontendDev],
  ServiceType.flutterDesktop: [],
  ServiceType.flutterMobile: [],
  ServiceType.reactSpa: [PortType.frontendDev],
  ServiceType.vueSpa: [PortType.frontendDev],
  ServiceType.nextJs: [PortType.frontendDev],
  ServiceType.expressApi: [PortType.httpApi, PortType.database],
  ServiceType.fastapi: [PortType.httpApi, PortType.database],
  ServiceType.dotnetApi: [PortType.httpApi, PortType.database],
  ServiceType.goApi: [PortType.httpApi, PortType.database],
  ServiceType.library_: [],
  ServiceType.worker: [],
  ServiceType.gateway: [PortType.httpApi],
  ServiceType.databaseService: [PortType.database],
  ServiceType.messageBroker: [PortType.kafka],
  ServiceType.cacheService: [PortType.redis],
  ServiceType.mcpServer: [PortType.httpApi],
  ServiceType.cliTool: [],
  ServiceType.other: [],
};

/// Informational panel showing port allocation preview.
///
/// In create mode, shows suggested ports based on [serviceType].
/// In edit mode (when [allocatedPorts] is provided), shows actual ports.
class PortPreviewPanel extends StatelessWidget {
  /// The selected service type for port recommendations.
  final ServiceType? serviceType;

  /// Actual allocated ports (edit mode only).
  final List<PortAllocationResponse>? allocatedPorts;

  /// Creates a [PortPreviewPanel].
  const PortPreviewPanel({
    super.key,
    required this.serviceType,
    this.allocatedPorts,
  });

  @override
  Widget build(BuildContext context) {
    // Edit mode: show actual ports
    if (allocatedPorts != null) {
      return _buildEditMode();
    }

    // Create mode: show recommendations
    return _buildCreateMode();
  }

  Widget _buildCreateMode() {
    final ports = serviceType != null
        ? (_portRecommendations[serviceType!] ?? <PortType>[])
        : <PortType>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dns_outlined, size: 16,
                  color: CodeOpsColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'Port Allocation Preview',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (serviceType == null)
            const Text(
              'Select a service type to see suggested port allocations.',
              style: TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (ports.isEmpty)
            Text(
              '${serviceType!.displayName} typically does not require server ports.',
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            ...ports.map((pt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: CodeOpsColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        pt.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: CodeOpsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '(auto-allocated from range)',
                        style: TextStyle(
                          fontSize: 11,
                          color: CodeOpsColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 8),
          const Text(
            'Ports will be auto-allocated from your team\u2019s configured '
            'ranges after registration. You can customize allocations on '
            'the service detail page.',
            style: TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    final ports = allocatedPorts!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dns_outlined, size: 16,
                  color: CodeOpsColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Allocated Ports',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: CodeOpsColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${ports.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (ports.isEmpty)
            const Text(
              'No ports allocated.',
              style: TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            )
          else
            ...ports.map((port) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          port.portType.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: CodeOpsColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '${port.portNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: CodeOpsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        port.environment,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CodeOpsColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 4),
          const Text(
            'Edit port allocations on the service detail page.',
            style: TextStyle(
              fontSize: 11,
              color: CodeOpsColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
