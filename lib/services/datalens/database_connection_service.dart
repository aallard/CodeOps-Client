/// Service for managing PostgreSQL database connections in DataLens.
///
/// Handles the full connection lifecycle: opening and closing live
/// [Connection] instances via the `postgres` driver, persisting saved
/// connection configurations to the local Drift database, and exposing
/// a reactive [statusStream] so the UI can observe connection state changes.
///
/// This service does NOT go through the CodeOps server — connections are made
/// directly from the desktop app to the target PostgreSQL instance.
library;

import 'dart:async';

import 'package:drift/drift.dart' hide DatabaseConnection;
import 'package:postgres/postgres.dart' as pg;

import '../../database/database.dart';
import '../../models/datalens_enums.dart';
import '../../models/datalens_models.dart';
import '../logging/log_service.dart';

/// Manages PostgreSQL connections and persists connection configurations.
///
/// Maintains a map of active [pg.Connection] instances keyed by connection ID,
/// a parallel map of [ConnectionStatus] values, and a broadcast stream that
/// emits status changes for the UI layer.
class DatabaseConnectionService {
  static const String _tag = 'DatabaseConnectionService';

  /// The local Drift database for persisting connection configs.
  final CodeOpsDatabase _db;

  /// Live PostgreSQL connections keyed by connection config ID.
  final Map<String, pg.Connection> _activeConnections = {};

  /// Current status of each connection keyed by connection config ID.
  final Map<String, ConnectionStatus> _connectionStatus = {};

  /// Broadcast controller for connection status changes.
  ///
  /// Emits `(connectionId, newStatus)` records whenever a connection's
  /// status changes.
  final StreamController<(String, ConnectionStatus)> _statusController =
      StreamController<(String, ConnectionStatus)>.broadcast();

  /// Creates a [DatabaseConnectionService] with the given [database].
  DatabaseConnectionService(CodeOpsDatabase database) : _db = database;

  /// A broadcast stream of `(connectionId, status)` records.
  ///
  /// Subscribe to be notified whenever any connection's status changes.
  Stream<(String, ConnectionStatus)> get statusStream =>
      _statusController.stream;

  // ---------------------------------------------------------------------------
  // Connection Lifecycle
  // ---------------------------------------------------------------------------

  /// Opens a live PostgreSQL connection using the saved config identified
  /// by [connectionId].
  ///
  /// Reads the connection config from the local database, builds a
  /// [pg.Endpoint], opens the connection, stores it in [_activeConnections],
  /// and updates [lastConnectedAt].
  ///
  /// Throws [StateError] if the connection config is not found.
  /// Throws on network / authentication failures from the postgres driver.
  Future<void> connect(String connectionId) async {
    log.i(_tag, 'Connecting to $connectionId');
    _setStatus(connectionId, ConnectionStatus.connecting);

    try {
      final config = await getConnectionById(connectionId);
      if (config == null) {
        throw StateError('Connection config not found: $connectionId');
      }

      final endpoint = pg.Endpoint(
        host: config.host ?? 'localhost',
        port: config.port ?? 5432,
        database: config.database ?? '',
        username: config.username,
        password: config.password,
      );

      final settings = pg.ConnectionSettings(
        sslMode: _mapSslMode(config.sslMode),
        connectTimeout: Duration(seconds: config.connectionTimeout ?? 10),
        applicationName: 'CodeOps DataLens',
      );

      final connection = await pg.Connection.open(
        endpoint,
        settings: settings,
      );

      _activeConnections[connectionId] = connection;
      _setStatus(connectionId, ConnectionStatus.connected);
      await updateLastConnectedAt(connectionId);
      log.i(_tag, 'Connected to $connectionId');
    } on Exception catch (e, st) {
      log.e(_tag, 'Failed to connect to $connectionId', e, st);
      _setStatus(connectionId, ConnectionStatus.error);
      rethrow;
    }
  }

  /// Tests connectivity to a PostgreSQL server using the given [config]
  /// without persisting the connection.
  ///
  /// Opens a temporary connection, executes `SELECT 1`, measures round-trip
  /// latency, and closes the connection. Returns a record with
  /// [success], an optional [error] message, and the measured [latency].
  Future<({bool success, String? error, Duration latency})> testConnection(
    DatabaseConnection config,
  ) async {
    log.d(_tag, 'Testing connection to ${config.host}:${config.port}');
    final stopwatch = Stopwatch()..start();
    pg.Connection? connection;

    try {
      final endpoint = pg.Endpoint(
        host: config.host ?? 'localhost',
        port: config.port ?? 5432,
        database: config.database ?? '',
        username: config.username,
        password: config.password,
      );

      final settings = pg.ConnectionSettings(
        sslMode: _mapSslMode(config.sslMode),
        connectTimeout: Duration(seconds: config.connectionTimeout ?? 10),
        applicationName: 'CodeOps DataLens Test',
      );

      connection = await pg.Connection.open(endpoint, settings: settings);
      await connection.execute('SELECT 1');
      stopwatch.stop();
      log.d(_tag, 'Test connection succeeded in ${stopwatch.elapsed}');
      return (success: true, error: null, latency: stopwatch.elapsed);
    } on Exception catch (e) {
      stopwatch.stop();
      log.w(_tag, 'Test connection failed: $e');
      return (success: false, error: e.toString(), latency: stopwatch.elapsed);
    } finally {
      await connection?.close();
    }
  }

  /// Closes the live connection identified by [connectionId] and removes it
  /// from the active connections map.
  ///
  /// No-op if no active connection exists for the given ID.
  Future<void> disconnect(String connectionId) async {
    final connection = _activeConnections.remove(connectionId);
    if (connection != null) {
      log.i(_tag, 'Disconnecting $connectionId');
      await connection.close();
      _setStatus(connectionId, ConnectionStatus.disconnected);
    }
  }

  /// Closes all active connections.
  Future<void> disconnectAll() async {
    log.i(_tag, 'Disconnecting all (${_activeConnections.length} active)');
    final ids = _activeConnections.keys.toList();
    for (final id in ids) {
      await disconnect(id);
    }
  }

  /// Returns the live [pg.Connection] for [connectionId], or `null` if none
  /// is active.
  pg.Connection? getConnection(String connectionId) {
    return _activeConnections[connectionId];
  }

  /// Whether a live connection exists and is open for [connectionId].
  bool isConnected(String connectionId) {
    final connection = _activeConnections[connectionId];
    return connection != null && connection.isOpen;
  }

  /// Returns the current [ConnectionStatus] for [connectionId].
  ///
  /// Returns [ConnectionStatus.disconnected] if no status has been recorded.
  ConnectionStatus getStatus(String connectionId) {
    return _connectionStatus[connectionId] ?? ConnectionStatus.disconnected;
  }

  // ---------------------------------------------------------------------------
  // Server Introspection (requires active connection)
  // ---------------------------------------------------------------------------

  /// Returns the PostgreSQL server version string for [connectionId].
  ///
  /// Throws [StateError] if no active connection exists.
  Future<String> getServerVersion(String connectionId) async {
    final connection = _requireConnection(connectionId);
    final result = await connection.execute('SHOW server_version');
    return result.first.first as String;
  }

  /// Returns the current database name for [connectionId].
  ///
  /// Throws [StateError] if no active connection exists.
  Future<String> getCurrentDatabase(String connectionId) async {
    final connection = _requireConnection(connectionId);
    final result = await connection.execute('SELECT current_database()');
    return result.first.first as String;
  }

  /// Returns the current database user for [connectionId].
  ///
  /// Throws [StateError] if no active connection exists.
  Future<String> getCurrentUser(String connectionId) async {
    final connection = _requireConnection(connectionId);
    final result = await connection.execute('SELECT current_user');
    return result.first.first as String;
  }

  // ---------------------------------------------------------------------------
  // Drift CRUD — Saved Connection Configs
  // ---------------------------------------------------------------------------

  /// Persists a new connection configuration to the local database.
  ///
  /// Returns the [DatabaseConnection] as read back from the database.
  Future<DatabaseConnection> saveConnection(DatabaseConnection config) async {
    log.i(_tag, 'Saving connection "${config.name}" (${config.id})');
    await _db.into(_db.datalensConnections).insert(
          _modelToCompanion(config),
        );
    return (await getConnectionById(config.id!))!;
  }

  /// Updates an existing connection configuration.
  ///
  /// Returns the updated [DatabaseConnection] as read back from the database.
  Future<DatabaseConnection> updateConnection(
    DatabaseConnection config,
  ) async {
    log.i(_tag, 'Updating connection "${config.name}" (${config.id})');
    await (_db.update(_db.datalensConnections)
          ..where((t) => t.id.equals(config.id!)))
        .write(_modelToCompanion(config));
    return (await getConnectionById(config.id!))!;
  }

  /// Deletes the connection configuration identified by [connectionId].
  ///
  /// Also disconnects the live connection if one is active.
  Future<void> deleteConnection(String connectionId) async {
    log.i(_tag, 'Deleting connection $connectionId');
    await disconnect(connectionId);
    await (_db.delete(_db.datalensConnections)
          ..where((t) => t.id.equals(connectionId)))
        .go();
    _connectionStatus.remove(connectionId);
  }

  /// Returns all saved connection configurations, ordered by name.
  Future<List<DatabaseConnection>> getAllConnections() async {
    final rows = await (_db.select(_db.datalensConnections)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the connection configuration for [connectionId], or `null` if
  /// not found.
  Future<DatabaseConnection?> getConnectionById(String connectionId) async {
    final row = await (_db.select(_db.datalensConnections)
          ..where((t) => t.id.equals(connectionId)))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Updates the [lastConnectedAt] timestamp for [connectionId] to now.
  Future<void> updateLastConnectedAt(String connectionId) async {
    await (_db.update(_db.datalensConnections)
          ..where((t) => t.id.equals(connectionId)))
        .write(
      DatalensConnectionsCompanion(
        lastConnectedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Releases resources held by this service.
  ///
  /// Disconnects all active connections and closes the status stream.
  Future<void> dispose() async {
    await disconnectAll();
    await _statusController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  /// Sets the status for [connectionId] and emits a change on the stream.
  void _setStatus(String connectionId, ConnectionStatus status) {
    _connectionStatus[connectionId] = status;
    if (!_statusController.isClosed) {
      _statusController.add((connectionId, status));
    }
  }

  /// Returns the active connection or throws [StateError].
  pg.Connection _requireConnection(String connectionId) {
    final connection = _activeConnections[connectionId];
    if (connection == null) {
      throw StateError('No active connection for $connectionId');
    }
    return connection;
  }

  /// Maps a string SSL mode to the postgres driver's [pg.SslMode].
  pg.SslMode _mapSslMode(String? sslMode) {
    return switch (sslMode) {
      'require' => pg.SslMode.require,
      'verify-full' || 'verify-ca' => pg.SslMode.verifyFull,
      _ => pg.SslMode.disable,
    };
  }

  /// Converts a Drift [DatalensConnection] row to a [DatabaseConnection].
  DatabaseConnection _rowToModel(DatalensConnection row) {
    return DatabaseConnection(
      id: row.id,
      name: row.name,
      driver: DatabaseDriver.fromJson(row.driver),
      host: row.host,
      port: row.port,
      database: row.database,
      schema: row.schema,
      username: row.username,
      password: row.password,
      useSsl: row.useSsl,
      sslMode: row.sslMode,
      color: row.color,
      connectionTimeout: row.connectionTimeout,
      lastConnectedAt: row.lastConnectedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Converts a [DatabaseConnection] model to a Drift companion for writes.
  DatalensConnectionsCompanion _modelToCompanion(DatabaseConnection config) {
    return DatalensConnectionsCompanion(
      id: Value(config.id!),
      name: Value(config.name ?? ''),
      driver: Value(config.driver?.toJson() ?? 'POSTGRESQL'),
      host: Value(config.host ?? 'localhost'),
      port: Value(config.port ?? 5432),
      database: Value(config.database ?? ''),
      schema: Value(config.schema),
      username: Value(config.username ?? ''),
      password: Value(config.password),
      useSsl: Value(config.useSsl ?? false),
      sslMode: Value(config.sslMode),
      color: Value(config.color),
      connectionTimeout: Value(config.connectionTimeout ?? 10),
      lastConnectedAt: Value(config.lastConnectedAt),
      createdAt: Value(config.createdAt ?? DateTime.now()),
      updatedAt: Value(config.updatedAt),
    );
  }
}
