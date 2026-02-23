/// Impact analysis page for visualizing downstream service dependencies.
///
/// Allows selecting a source service and displays a BFS tree of all
/// impacted downstream services with depth-based severity coloring.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/registry_providers.dart';
import '../../theme/colors.dart';
import '../../widgets/registry/impact_tree_view.dart';
import '../../widgets/registry/service_selector_header.dart';
import '../../widgets/shared/error_panel.dart';

/// Impact analysis page.
///
/// Watches [impactServiceIdProvider] for the selected service and
/// [registryImpactAnalysisProvider] for the BFS impact data. Provides
/// a service selector dropdown in the header and navigates back to the
/// dependency graph page.
class ImpactAnalysisPage extends ConsumerWidget {
  /// Creates an [ImpactAnalysisPage].
  const ImpactAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(registryServicesProvider);
    final selectedServiceId = ref.watch(impactServiceIdProvider);

    return Column(
      children: [
        // Header with service selector
        ServiceSelectorHeader(
          services: servicesAsync.valueOrNull?.content ?? [],
          selectedServiceId: selectedServiceId,
          onServiceSelected: (id) {
            ref.read(impactServiceIdProvider.notifier).state = id;
          },
          onBack: () => context.go('/registry/dependencies'),
        ),
        // Main content
        Expanded(
          child: selectedServiceId == null
              ? const _EmptyState()
              : _ImpactContent(serviceId: selectedServiceId),
        ),
      ],
    );
  }
}

/// Empty state when no service is selected.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 48,
            color: CodeOpsColors.textTertiary,
          ),
          SizedBox(height: 12),
          Text(
            'Select a service',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Choose a source service to analyze its downstream impact.',
            style: TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content area that loads and displays impact analysis.
class _ImpactContent extends ConsumerWidget {
  final String serviceId;

  const _ImpactContent({required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impactAsync = ref.watch(registryImpactAnalysisProvider(serviceId));

    return impactAsync.when(
      data: (analysis) => ImpactTreeView(analysis: analysis),
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => ErrorPanel(
        title: 'Failed to Load Impact Analysis',
        message: e.toString(),
        onRetry: () =>
            ref.invalidate(registryImpactAnalysisProvider(serviceId)),
      ),
    );
  }
}
