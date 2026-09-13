import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'encryption_service.dart';

/// Offline-first SQLite store. Sensitive rows hold AES-256 ciphertext only.
class LocalDatabase {
  LocalDatabase(this._encryption);

  /// V1: `kv` + `encrypted_events` (workout logs). V2 adds gamification + library.
  static const int schemaVersion = 2;

  final EncryptionService _encryption;
  Database? _db;

  String encryptJson(Map<String, dynamic> payload) => _encryption.encryptJson(payload);
  Map<String, dynamic> decryptJson(String blob) => _encryption.decryptJson(blob);

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'fitpro_encrypted.db');
    _db = await openDatabase(
      path,
      version: schemaVersion,
      onCreate: (db, _) async {
        await _createV1Tables(db);
        await _createV2Tables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // sqflite does not wrap onUpgrade in a transaction — do it ourselves
        // so a crash cannot leave a half-applied V2 schema.
        await db.transaction((txn) async {
          if (oldVersion < 2) {
            await _createV2Tables(txn);
          }
        });
      },
    );
    return _db!;
  }

  /// Existing V1 tables. Never DROP / ALTER / recreate these during upgrades.
  Future<void> _createV1Tables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kv (
        k TEXT PRIMARY KEY,
        v TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS encrypted_events (
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        ciphertext TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_events_kind_created ON encrypted_events(kind, created_at DESC)',
    );
  }

  Future<void> _createV2Tables(DatabaseExecutor db) async {
    await _createGamificationTables(db);
    await _createExerciseTables(db);
  }

  Future<void> _createGamificationTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_quests (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER NOT NULL DEFAULT 0,
        quest_type TEXT NOT NULL,
        completed_at INTEGER,
        created_at INTEGER NOT NULL,
        ciphertext TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_quests_completed ON daily_quests(completed_at DESC)',
    );
  }

  Future<void> _createExerciseTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        muscle_groups TEXT NOT NULL,
        equipment TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        is_premium INTEGER NOT NULL DEFAULT 0,
        media_url TEXT,
        instructions TEXT,
        ciphertext TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        is_premium INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        ciphertext TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routine_exercises (
        routine_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        ciphertext TEXT NOT NULL,
        PRIMARY KEY (routine_id, exercise_id),
        FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_routine_exercises_order ON routine_exercises(routine_id, order_index)',
    );
  }

  Future<void> putKv(String key, Map<String, dynamic> value) async {
    final db = await database;
    await db.insert(
      'kv',
      {'k': key, 'v': _encryption.encryptJson(value)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getKv(String key) async {
    final db = await database;
    final rows = await db.query('kv', where: 'k = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return _encryption.decryptJson(rows.first['v'] as String);
  }

  Future<void> insertEvent({
    required String id,
    required String kind,
    required DateTime createdAt,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert(
      'encrypted_events',
      {
        'id': id,
        'kind': kind,
        'created_at': createdAt.millisecondsSinceEpoch,
        'ciphertext': _encryption.encryptJson(payload),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> eventsByKind(String kind) async {
    final db = await database;
    final rows = await db.query(
      'encrypted_events',
      where: 'kind = ?',
      whereArgs: [kind],
      orderBy: 'created_at DESC',
    );
    return [
      for (final row in rows)
        {
          'id': row['id'],
          'created_at': row['created_at'],
          ..._encryption.decryptJson(row['ciphertext'] as String),
        },
    ];
  }

  Future<String> exportEncryptedBundle() async {
    final db = await database;
    final events = await db.query('encrypted_events', orderBy: 'created_at DESC');
    final profile = await getKv('profile');
    return _encryption.encryptJson({
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'zero_data_selling': true,
      'profile': profile,
      'event_count': events.length,
      'events': events,
    });
  }
}
