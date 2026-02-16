/// Riverpod providers for per-project local configuration.
///
/// Manages the [ProjectLocalConfig] Drift table which stores
/// machine-specific settings (e.g. local working directory) that
/// are never sent to the server.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'auth_providers.dart';

/// Reads the [ProjectLocalConfigData] for a given project ID.
///
/// Returns `null` when no local config row exists yet.
final projectLocalConfigProvider =
    FutureProvider.family<ProjectLocalConfigData?, String>(
  (ref, projectId) async {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.projectLocalConfig)
      ..where((t) => t.projectId.equals(projectId));
    return query.getSingleOrNull();
  },
);

/// Upserts the local working directory for a project and invalidates
/// the corresponding [projectLocalConfigProvider].
Future<void> saveProjectLocalWorkingDir(
  WidgetRef ref,
  String projectId,
  String? path,
) async {
  final db = ref.read(databaseProvider);
  await db.into(db.projectLocalConfig).insertOnConflictUpdate(
        ProjectLocalConfigCompanion.insert(
          projectId: projectId,
          localWorkingDir: Value(path),
        ),
      );
  ref.invalidate(projectLocalConfigProvider(projectId));
}
