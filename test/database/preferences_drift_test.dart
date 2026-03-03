// Tests for UserPreferencesTable Drift CRUD operations.
//
// Verifies insert, query, upsert, and delete operations on the
// UserPreferencesTable using an in-memory database.
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/database/database.dart';

void main() {
  late CodeOpsDatabase db;

  setUp(() {
    db = CodeOpsDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('UserPreferencesTable', () {
    test('insert and query a preference', () async {
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('theme'),
              value: const Value('dark'),
              updatedAt: Value(DateTime.now()),
            ),
          );

      final rows = await db.select(db.userPreferencesTable).get();

      expect(rows.length, 1);
      expect(rows.first.key, 'theme');
      expect(rows.first.value, 'dark');
    });

    test('upsert replaces existing value', () async {
      final now = DateTime.now();
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('accent'),
              value: const Value('#6C63FF'),
              updatedAt: Value(now),
            ),
          );

      await db.into(db.userPreferencesTable).insertOnConflictUpdate(
            UserPreferencesTableCompanion(
              key: const Value('accent'),
              value: const Value('#3B82F6'),
              updatedAt: Value(now),
            ),
          );

      final rows = await db.select(db.userPreferencesTable).get();

      expect(rows.length, 1);
      expect(rows.first.value, '#3B82F6');
    });

    test('delete removes a preference', () async {
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('fontSize'),
              value: const Value('medium'),
              updatedAt: Value(DateTime.now()),
            ),
          );

      await (db.delete(db.userPreferencesTable)
            ..where((t) => t.key.equals('fontSize')))
          .go();

      final rows = await db.select(db.userPreferencesTable).get();

      expect(rows, isEmpty);
    });

    test('multiple preferences can coexist', () async {
      final now = DateTime.now();
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('theme'),
              value: const Value('dark'),
              updatedAt: Value(now),
            ),
          );
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('accent'),
              value: const Value('#6C63FF'),
              updatedAt: Value(now),
            ),
          );
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('fontSize'),
              value: const Value('large'),
              updatedAt: Value(now),
            ),
          );

      final rows = await db.select(db.userPreferencesTable).get();

      expect(rows.length, 3);
    });

    test('primary key is the key column', () async {
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              key: const Value('dup'),
              value: const Value('first'),
              updatedAt: Value(DateTime.now()),
            ),
          );

      // Inserting a duplicate key should fail with standard insert.
      expect(
        () => db.into(db.userPreferencesTable).insert(
              UserPreferencesTableCompanion(
                key: const Value('dup'),
                value: const Value('second'),
                updatedAt: Value(DateTime.now()),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
