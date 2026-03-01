// Tests for DatabaseConnectionService.
//
// Verifies Drift CRUD operations for saved connection configs, connection
// state management, status stream emissions, and helper methods.
// No real PostgreSQL server is used — live connection methods are tested
// indirectly through state management and error handling.
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/database/database.dart';
import 'package:codeops/models/datalens_enums.dart';
import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/services/datalens/database_connection_service.dart';

void main() {
  late CodeOpsDatabase db;
  late DatabaseConnectionService service;

  setUp(() {
    db = CodeOpsDatabase(NativeDatabase.memory());
    service = DatabaseConnectionService(db);
  });

  tearDown(() async {
    await service.dispose();
    await db.close();
  });

  // Helper to build a DatabaseConnection model for testing.
  DatabaseConnection makeConfig({
    String id = 'conn-1',
    String name = 'Test DB',
    String host = 'localhost',
    int port = 5432,
    String database = 'testdb',
    String username = 'user',
    String? password = 'pass',
    bool useSsl = false,
    String? sslMode,
    int connectionTimeout = 10,
  }) {
    return DatabaseConnection(
      id: id,
      name: name,
      driver: DatabaseDriver.postgresql,
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
      useSsl: useSsl,
      sslMode: sslMode,
      connectionTimeout: connectionTimeout,
      createdAt: DateTime.utc(2026),
    );
  }

  // ---------------------------------------------------------------------------
  // CRUD — saveConnection
  // ---------------------------------------------------------------------------
  group('saveConnection', () {
    test('persists a connection config and returns it', () async {
      final config = makeConfig();
      final saved = await service.saveConnection(config);

      expect(saved.id, 'conn-1');
      expect(saved.name, 'Test DB');
      expect(saved.host, 'localhost');
      expect(saved.port, 5432);
      expect(saved.database, 'testdb');
      expect(saved.username, 'user');
      expect(saved.password, 'pass');
      expect(saved.driver, DatabaseDriver.postgresql);
      expect(saved.useSsl, false);
      expect(saved.connectionTimeout, 10);
    });

    test('persists multiple connections', () async {
      await service.saveConnection(makeConfig(id: 'conn-1', name: 'Alpha'));
      await service.saveConnection(makeConfig(id: 'conn-2', name: 'Beta'));
      await service.saveConnection(makeConfig(id: 'conn-3', name: 'Gamma'));

      final all = await service.getAllConnections();
      expect(all.length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // CRUD — getAllConnections
  // ---------------------------------------------------------------------------
  group('getAllConnections', () {
    test('returns empty list when no connections exist', () async {
      final all = await service.getAllConnections();
      expect(all, isEmpty);
    });

    test('returns connections ordered by name', () async {
      await service.saveConnection(makeConfig(id: 'c-3', name: 'Zulu'));
      await service.saveConnection(makeConfig(id: 'c-1', name: 'Alpha'));
      await service.saveConnection(makeConfig(id: 'c-2', name: 'Mike'));

      final all = await service.getAllConnections();
      expect(all.map((c) => c.name).toList(), ['Alpha', 'Mike', 'Zulu']);
    });
  });

  // ---------------------------------------------------------------------------
  // CRUD — getConnectionById
  // ---------------------------------------------------------------------------
  group('getConnectionById', () {
    test('returns the config when found', () async {
      await service.saveConnection(makeConfig(id: 'conn-1'));
      final result = await service.getConnectionById('conn-1');

      expect(result, isNotNull);
      expect(result!.id, 'conn-1');
    });

    test('returns null when not found', () async {
      final result = await service.getConnectionById('non-existent');
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // CRUD — updateConnection
  // ---------------------------------------------------------------------------
  group('updateConnection', () {
    test('updates fields and returns the updated config', () async {
      await service.saveConnection(makeConfig(id: 'conn-1', name: 'Old Name'));

      final updated = await service.updateConnection(
        makeConfig(id: 'conn-1', name: 'New Name', port: 5433),
      );

      expect(updated.name, 'New Name');
      expect(updated.port, 5433);
    });
  });

  // ---------------------------------------------------------------------------
  // CRUD — deleteConnection
  // ---------------------------------------------------------------------------
  group('deleteConnection', () {
    test('removes the connection config from the database', () async {
      await service.saveConnection(makeConfig(id: 'conn-1'));
      await service.deleteConnection('conn-1');

      final result = await service.getConnectionById('conn-1');
      expect(result, isNull);
    });

    test('clears status after deletion', () async {
      await service.saveConnection(makeConfig(id: 'conn-1'));
      await service.deleteConnection('conn-1');

      expect(service.getStatus('conn-1'), ConnectionStatus.disconnected);
    });
  });

  // ---------------------------------------------------------------------------
  // Connection State Management
  // ---------------------------------------------------------------------------
  group('connection state management', () {
    test('getStatus returns disconnected for unknown connection', () {
      expect(service.getStatus('unknown'), ConnectionStatus.disconnected);
    });

    test('isConnected returns false for unknown connection', () {
      expect(service.isConnected('unknown'), false);
    });

    test('getConnection returns null for unknown connection', () {
      expect(service.getConnection('unknown'), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Status Stream
  // ---------------------------------------------------------------------------
  group('statusStream', () {
    test('emits status changes', () async {
      await service.saveConnection(makeConfig(id: 'conn-1'));

      // Collect status stream events while attempting connect (which will fail
      // since there is no real PostgreSQL server).
      final events = <(String, ConnectionStatus)>[];
      final subscription = service.statusStream.listen(events.add);

      try {
        await service.connect('conn-1');
      } on Exception {
        // Expected — no real server.
      }

      // Allow microtasks to flush.
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      // Should have emitted CONNECTING then ERROR (no real server).
      expect(events, isNotEmpty);
      expect(events.first.$1, 'conn-1');
      expect(events.first.$2, ConnectionStatus.connecting);
      expect(events.last.$2, ConnectionStatus.error);
    });
  });

  // ---------------------------------------------------------------------------
  // connect — error handling
  // ---------------------------------------------------------------------------
  group('connect', () {
    test('throws StateError when config not found', () async {
      expect(
        () => service.connect('non-existent'),
        throwsA(isA<StateError>()),
      );
    });

    test('sets error status on connection failure', () async {
      await service.saveConnection(makeConfig(id: 'conn-1'));

      try {
        await service.connect('conn-1');
      } on Exception {
        // Expected — no real server.
      }

      expect(service.getStatus('conn-1'), ConnectionStatus.error);
    });
  });

  // ---------------------------------------------------------------------------
  // disconnect
  // ---------------------------------------------------------------------------
  group('disconnect', () {
    test('is a no-op for unknown connection', () async {
      // Should not throw.
      await service.disconnect('non-existent');
    });
  });

  // ---------------------------------------------------------------------------
  // disconnectAll
  // ---------------------------------------------------------------------------
  group('disconnectAll', () {
    test('completes without error when no active connections', () async {
      await service.disconnectAll();
    });
  });

  // ---------------------------------------------------------------------------
  // updateLastConnectedAt
  // ---------------------------------------------------------------------------
  group('updateLastConnectedAt', () {
    test('updates the lastConnectedAt timestamp', () async {
      await service.saveConnection(makeConfig(id: 'conn-1'));

      final before = await service.getConnectionById('conn-1');
      expect(before!.lastConnectedAt, isNull);

      await service.updateLastConnectedAt('conn-1');

      final after = await service.getConnectionById('conn-1');
      expect(after!.lastConnectedAt, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Server introspection — error handling
  // ---------------------------------------------------------------------------
  group('server introspection', () {
    test('getServerVersion throws when no active connection', () {
      expect(
        () => service.getServerVersion('conn-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('getCurrentDatabase throws when no active connection', () {
      expect(
        () => service.getCurrentDatabase('conn-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('getCurrentUser throws when no active connection', () {
      expect(
        () => service.getCurrentUser('conn-1'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // dispose
  // ---------------------------------------------------------------------------
  group('dispose', () {
    test('closes the status stream', () async {
      await service.dispose();
      expect(service.statusStream.isBroadcast, true);
      // Stream should be closed — adding a listener should get done immediately.
      final completer = Completer<void>();
      service.statusStream.listen(
        (_) {},
        onDone: completer.complete,
      );
      await completer.future;
    });
  });
}
