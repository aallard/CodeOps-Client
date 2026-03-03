// Global search service for cross-module searching.
//
// Searches across Registry, Vault, Logger, Courier, Fleet, Relay, MCP,
// and DataLens modules in parallel and returns grouped results.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/courier_providers.dart';
import '../../providers/fleet_providers.dart' hide selectedTeamIdProvider;
import '../../providers/logger_providers.dart';
import '../../providers/mcp_providers.dart';
import '../../providers/registry_providers.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../providers/vault_providers.dart';
import '../../services/logging/log_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search Module enum
// ─────────────────────────────────────────────────────────────────────────────

/// Modules available for global search.
enum SearchModule {
  /// Service Registry module.
  registry('Registry', Icons.app_registration_outlined, '/registry'),

  /// Vault secrets module.
  vault('Vault', Icons.lock_outlined, '/vault'),

  /// Logger module.
  logger('Logger', Icons.receipt_long_outlined, '/logger'),

  /// Courier API testing module.
  courier('Courier', Icons.send_outlined, '/courier'),

  /// Fleet container management module.
  fleet('Fleet', Icons.dns_outlined, '/fleet'),

  /// Relay messaging module.
  relay('Relay', Icons.forum_outlined, '/relay'),

  /// MCP AI integration module.
  mcp('MCP', Icons.smart_toy_outlined, '/mcp'),

  /// DataLens database browser module.
  datalens('DataLens', Icons.storage_outlined, '/datalens');

  /// Display label for the module.
  final String label;

  /// Icon for the module.
  final IconData icon;

  /// Base route for the module.
  final String route;

  const SearchModule(this.label, this.icon, this.route);
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Result model
// ─────────────────────────────────────────────────────────────────────────────

/// A single search result from any module.
class SearchResult {
  /// The module this result belongs to.
  final SearchModule module;

  /// Display title for the result.
  final String title;

  /// Optional subtitle / description.
  final String? subtitle;

  /// GoRouter path to navigate to this result.
  final String route;

  /// Optional entity ID.
  final String? entityId;

  /// Creates a [SearchResult].
  const SearchResult({
    required this.module,
    required this.title,
    required this.route,
    this.subtitle,
    this.entityId,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Global Search Results
// ─────────────────────────────────────────────────────────────────────────────

/// Aggregated search results grouped by module.
class GlobalSearchResults {
  /// All results grouped by module.
  final Map<SearchModule, List<SearchResult>> grouped;

  /// Total count across all modules.
  final int totalCount;

  /// Whether the search is still loading.
  final bool isLoading;

  /// Creates a [GlobalSearchResults].
  const GlobalSearchResults({
    this.grouped = const {},
    this.totalCount = 0,
    this.isLoading = false,
  });

  /// Returns an empty results instance.
  static const empty = GlobalSearchResults();

  /// Returns a loading results instance.
  static const loading = GlobalSearchResults(isLoading: true);

  /// Flat list of all results across modules.
  List<SearchResult> get allResults =>
      grouped.values.expand((list) => list).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Global Search Service
// ─────────────────────────────────────────────────────────────────────────────

/// Service that searches across all CodeOps modules in parallel.
///
/// Each module search is independent; if one fails, the others still
/// return their results. Results are capped at [maxResultsPerModule].
class GlobalSearchService {
  final Ref _ref;

  /// Maximum results returned per module.
  static const int maxResultsPerModule = 5;

  /// Creates a [GlobalSearchService] backed by Riverpod [ref].
  GlobalSearchService(this._ref);

  /// Searches all enabled modules for [query].
  ///
  /// If [modules] is provided, only those modules are searched.
  /// Returns results grouped by module.
  Future<GlobalSearchResults> search(
    String query, {
    Set<SearchModule>? modules,
  }) async {
    if (query.trim().isEmpty) return GlobalSearchResults.empty;

    final teamId = _ref.read(selectedTeamIdProvider);
    final enabledModules = modules ?? SearchModule.values.toSet();

    final futures = <SearchModule, Future<List<SearchResult>>>{};

    for (final module in enabledModules) {
      futures[module] = _searchModule(module, query.trim(), teamId);
    }

    final grouped = <SearchModule, List<SearchResult>>{};
    var totalCount = 0;

    for (final entry in futures.entries) {
      try {
        final results = await entry.value;
        if (results.isNotEmpty) {
          grouped[entry.key] = results;
          totalCount += results.length;
        }
      } catch (e) {
        log.w('GlobalSearch', 'Search failed for ${entry.key.label}: $e');
      }
    }

    return GlobalSearchResults(grouped: grouped, totalCount: totalCount);
  }

  Future<List<SearchResult>> _searchModule(
    SearchModule module,
    String query,
    String? teamId,
  ) async {
    try {
      return switch (module) {
        SearchModule.registry => _searchRegistry(query, teamId),
        SearchModule.vault => _searchVault(query),
        SearchModule.logger => _searchLogger(query, teamId),
        SearchModule.courier => _searchCourier(query, teamId),
        SearchModule.fleet => _searchFleet(query, teamId),
        SearchModule.relay => _searchRelay(query, teamId),
        SearchModule.mcp => _searchMcp(query, teamId),
        SearchModule.datalens => _searchDataLens(query, teamId),
      };
    } catch (e) {
      log.w('GlobalSearch', '${module.label} search error: $e');
      return [];
    }
  }

  Future<List<SearchResult>> _searchRegistry(
    String query,
    String? teamId,
  ) async {
    if (teamId == null) return [];
    final api = _ref.read(registryApiProvider);
    final page = await api.getServicesForTeam(
      teamId,
      search: query,
      size: maxResultsPerModule,
    );
    return page.content.map((s) => SearchResult(
          module: SearchModule.registry,
          title: s.name,
          subtitle: '${s.serviceType.name} service',
          route: '/registry/services/${s.id}',
          entityId: s.id,
        )).toList();
  }

  Future<List<SearchResult>> _searchVault(String query) async {
    final api = _ref.read(vaultApiProvider);
    final page = await api.searchSecrets(
      query,
      size: maxResultsPerModule,
    );
    return page.content.map((s) => SearchResult(
          module: SearchModule.vault,
          title: s.name,
          subtitle: s.path,
          route: '/vault/secrets/${s.id}',
          entityId: s.id,
        )).toList();
  }

  Future<List<SearchResult>> _searchLogger(
    String query,
    String? teamId,
  ) async {
    if (teamId == null) return [];
    final api = _ref.read(loggerApiProvider);
    final page = await api.searchLogs(
      teamId,
      q: query,
      size: maxResultsPerModule,
    );
    return page.content.map((entry) => SearchResult(
          module: SearchModule.logger,
          title: entry.message,
          subtitle: entry.serviceName,
          route: '/logger/search',
          entityId: entry.id,
        )).toList();
  }

  Future<List<SearchResult>> _searchCourier(
    String query,
    String? teamId,
  ) async {
    if (teamId == null) return [];
    final api = _ref.read(courierApiProvider);
    final results = await api.searchCollections(teamId, query: query);
    return results.take(maxResultsPerModule).map((c) => SearchResult(
          module: SearchModule.courier,
          title: c.name ?? 'Collection',
          subtitle: c.description,
          route: '/courier/collection/${c.id}',
          entityId: c.id,
        )).toList();
  }

  Future<List<SearchResult>> _searchFleet(
    String query,
    String? teamId,
  ) async {
    if (teamId == null) return [];
    final api = _ref.read(fleetApiProvider);
    final containers = await api.listContainers(teamId);
    final lowerQuery = query.toLowerCase();
    return containers
        .where((c) =>
            (c.containerName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (c.serviceName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (c.imageName?.toLowerCase().contains(lowerQuery) ?? false))
        .take(maxResultsPerModule)
        .map((c) => SearchResult(
              module: SearchModule.fleet,
              title: c.containerName ?? c.containerId ?? 'Container',
              subtitle: c.serviceName,
              route: '/fleet/containers/${c.id}',
              entityId: c.id,
            ))
        .toList();
  }

  Future<List<SearchResult>> _searchRelay(
    String query,
    String? teamId,
  ) async {
    if (teamId == null) return [];
    final api = _ref.read(relayApiProvider);
    final page = await api.searchMessagesAcrossChannels(
      query,
      teamId,
      size: maxResultsPerModule,
    );
    return page.content.map((r) => SearchResult(
          module: SearchModule.relay,
          title: r.channelName ?? 'Message',
          subtitle: r.contentSnippet,
          route: '/relay/channel/${r.channelId}',
          entityId: r.messageId,
        )).toList();
  }

  Future<List<SearchResult>> _searchMcp(
    String query,
    String? teamId,
  ) async {
    if (teamId == null) return [];
    final api = _ref.read(mcpApiProvider);
    final sessions = await api.getMySessions(teamId: teamId, size: 20);
    final lowerQuery = query.toLowerCase();
    return sessions.content
        .where((s) =>
            (s.projectName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (s.developerName?.toLowerCase().contains(lowerQuery) ?? false))
        .take(maxResultsPerModule)
        .map((s) => SearchResult(
              module: SearchModule.mcp,
              title: s.projectName ?? 'MCP Session',
              subtitle: s.developerName,
              route: '/mcp/sessions/${s.id}',
              entityId: s.id,
            ))
        .toList();
  }

  Future<List<SearchResult>> _searchDataLens(
    String query,
    String? teamId,
  ) async {
    // DataLens does not have a text search API — return empty.
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the [GlobalSearchService] singleton.
final globalSearchServiceProvider = Provider<GlobalSearchService>((ref) {
  return GlobalSearchService(ref);
});

/// Holds the list of recent search queries (max 10).
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

/// State notifier for managing recent search queries.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  /// Maximum number of recent searches to retain.
  static const int maxRecent = 10;

  /// Creates a [RecentSearchesNotifier] with an empty list.
  RecentSearchesNotifier() : super([]);

  /// Adds a query to the top of the recent list.
  void add(String query) {
    if (query.trim().isEmpty) return;
    final trimmed = query.trim();
    state = [trimmed, ...state.where((q) => q != trimmed)].take(maxRecent).toList();
  }

  /// Removes a specific query from the recent list.
  void remove(String query) {
    state = state.where((q) => q != query).toList();
  }

  /// Clears all recent searches.
  void clear() {
    state = [];
  }
}
