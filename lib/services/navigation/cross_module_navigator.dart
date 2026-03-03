/// Cross-module navigation service for deep-linking between CodeOps modules.
///
/// Provides static methods that generate GoRouter paths for navigating
/// between Registry, Courier, Fleet, Logger, DataLens, MCP, Vault, and
/// Relay modules. Each method encapsulates the target route pattern so
/// callers only need to supply the relevant entity IDs or filter values.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Static navigation helpers for cross-module deep links.
///
/// Used by widgets across modules to navigate to related entities in
/// other modules. All methods use [GoRouter.go] for in-app navigation
/// within the [NavigationShell].
class CrossModuleNavigator {
  CrossModuleNavigator._();

  // ───────────────────────────────────────────────────────────────────────────
  // Registry
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to a service detail page in the Registry.
  static void goToService(BuildContext context, String serviceId) {
    context.go('/registry/services/$serviceId');
  }

  /// Navigates to the API docs page for a specific service.
  static void goToApiDocs(BuildContext context, String serviceId) {
    context.go('/registry/api-docs/$serviceId');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Courier
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to Courier, optionally opening a specific request or collection.
  static void goToCourier(
    BuildContext context, {
    String? requestId,
    String? collectionId,
  }) {
    if (requestId != null) {
      context.go('/courier/request/$requestId');
    } else if (collectionId != null) {
      context.go('/courier/collection/$collectionId');
    } else {
      context.go('/courier');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DataLens
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to the DataLens database browser.
  static void goToDataLens(BuildContext context) {
    context.go('/datalens');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Logger
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to Logger search, optionally pre-filtered by service name.
  static void goToLoggerSearch(
    BuildContext context, {
    String? serviceName,
  }) {
    if (serviceName != null) {
      context.go('/logger/search?serviceName=$serviceName');
    } else {
      context.go('/logger/search');
    }
  }

  /// Navigates to the Logger log viewer.
  static void goToLogViewer(BuildContext context) {
    context.go('/logger/viewer');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Fleet
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to a container detail page in Fleet.
  static void goToFleetContainer(BuildContext context, String containerId) {
    context.go('/fleet/containers/$containerId');
  }

  /// Navigates to the Fleet containers list.
  static void goToFleetContainers(BuildContext context) {
    context.go('/fleet/containers');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MCP
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to an MCP session detail page.
  static void goToMcpSession(BuildContext context, String sessionId) {
    context.go('/mcp/sessions/$sessionId');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Vault
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to a Vault secret detail page.
  static void goToVaultSecret(BuildContext context, String secretId) {
    context.go('/vault/secrets/$secretId');
  }

  /// Navigates to the Vault secrets list.
  static void goToVaultSecrets(BuildContext context) {
    context.go('/vault/secrets');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Relay
  // ───────────────────────────────────────────────────────────────────────────

  /// Navigates to a Relay channel.
  static void goToRelayChannel(BuildContext context, String channelId) {
    context.go('/relay/channel/$channelId');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Module Route Resolver
  // ───────────────────────────────────────────────────────────────────────────

  /// Returns the GoRouter path for a given module and entity ID.
  ///
  /// Used by Relay events, MCP tool calls, and other cross-references
  /// to resolve a (module, entityId) pair to a navigation route.
  /// Returns `null` if the module is unrecognized.
  static String? routeForModule(String module, String entityId) {
    return switch (module.toLowerCase()) {
      'registry' => '/registry/services/$entityId',
      'vault' => '/vault/secrets/$entityId',
      'fleet' => '/fleet/containers/$entityId',
      'courier' => '/courier/request/$entityId',
      'logger' => '/logger/search',
      'mcp' => '/mcp/sessions/$entityId',
      'relay' => '/relay/channel/$entityId',
      'datalens' => '/datalens',
      _ => null,
    };
  }
}
