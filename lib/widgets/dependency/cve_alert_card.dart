/// CVE alert card widget showing critical/high open vulnerabilities.
///
/// Filters to only OPEN + CRITICAL/HIGH vulnerabilities and displays
/// each as an alert card with action buttons.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/dependency_scan.dart';
import '../../models/enums.dart';
import '../../theme/colors.dart';
import '../shared/confirm_dialog.dart';
import '../shared/empty_state.dart';

/// Displays OPEN + CRITICAL/HIGH vulnerabilities as alert cards.
///
/// Each card shows CVE ID, dependency name, severity badge, description,
/// fixed version if available, and action buttons (Update Now, Suppress, View CVE).
class CveAlertCard extends StatelessWidget {
  /// All vulnerabilities for the current scan.
  final List<DependencyVulnerability> vulnerabilities;

  /// Callback when "Update Now" is tapped (sets status to UPDATING).
  final void Function(DependencyVulnerability vuln)? onUpdate;

  /// Callback when "Suppress" is confirmed (sets status to SUPPRESSED).
  final void Function(DependencyVulnerability vuln)? onSuppress;

  /// Creates a [CveAlertCard].
  const CveAlertCard({
    super.key,
    required this.vulnerabilities,
    this.onUpdate,
    this.onSuppress,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = vulnerabilities
        .where(
          (v) =>
              v.status == VulnerabilityStatus.open &&
              (v.severity == Severity.critical ||
                  v.severity == Severity.high),
        )
        .toList();

    if (alerts.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No critical alerts',
        subtitle:
            'No open critical or high severity vulnerabilities found.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final vuln = alerts[index];
        final sevColor = vuln.severity == Severity.critical
            ? CodeOpsColors.critical
            : CodeOpsColors.error;

        return Card(
          color: CodeOpsColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: sevColor.withValues(alpha: 0.3)),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CVE ID + severity badge
                Row(
                  children: [
                    if (vuln.cveId != null)
                      Text(
                        vuln.cveId!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: sevColor,
                        ),
                      )
                    else
                      Text(
                        'No CVE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: sevColor,
                        ),
                      ),
                    const SizedBox(width: 8),
                    _badge(vuln.severity.displayName, sevColor),
                  ],
                ),
                const SizedBox(height: 8),
                // Dependency name
                Text(
                  vuln.dependencyName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                // Description
                if (vuln.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    vuln.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.textSecondary,
                    ),
                  ),
                ],
                // Fixed version
                if (vuln.fixedVersion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fix available: ${vuln.fixedVersion}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.success,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Action buttons
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.update, size: 16),
                      label: const Text('Update Now'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CodeOpsColors.primary,
                        side: const BorderSide(color: CodeOpsColors.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => onUpdate?.call(vuln),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.visibility_off, size: 16),
                      label: const Text('Suppress'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CodeOpsColors.textTertiary,
                        side: const BorderSide(color: CodeOpsColors.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _confirmSuppress(context, vuln),
                    ),
                    if (vuln.cveId != null)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('View CVE'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CodeOpsColors.secondary,
                          side:
                              const BorderSide(color: CodeOpsColors.secondary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => _openCve(vuln.cveId!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _confirmSuppress(BuildContext context, DependencyVulnerability vuln) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Suppress Vulnerability',
      message:
          'Are you sure you want to suppress ${vuln.cveId ?? vuln.dependencyName}? '
          'This will hide it from alerts.',
      confirmLabel: 'Suppress',
      destructive: true,
    );
    if (confirmed == true) {
      onSuppress?.call(vuln);
    }
  }

  void _openCve(String cveId) {
    final url = Uri.parse('https://nvd.nist.gov/vuln/detail/$cveId');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
