import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const _dbName = 'ihealthy.db';
  static const _dbVersion = 3; // 👈 SUBI A VERSÃO PARA 3

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createUserTable(db);
        await _createWaterTables(db);
        await _createExerciseTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          await _createUserTable(db);
        }
        if (oldVersion < 2) {
          await _createWaterTables(db);
        }
        if (oldVersion < 3) {
          await _createExerciseTables(db);
        }
      },
    );
  }

  // =============================
  // USERS
  // =============================
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final res =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty ? res.first : null;
  }

  // =============================
  // ÁGUA
  // =============================
  Future<void> _createWaterTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS water_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount_ml INTEGER NOT NULL,
        timestamp_ms INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS water_settings(
        id INTEGER PRIMARY KEY,
        daily_goal_ml INTEGER NOT NULL
      )
    ''');

    // meta padrão 2000ml
    await db.insert(
      'water_settings',
      {'id': 1, 'daily_goal_ml': 2000},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> addWater(int amountMl) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('water_logs', {
      'amount_ml': amountMl,
      'timestamp_ms': now,
    });
  }

  Future<List<Map<String, dynamic>>> getTodayWaterLogsRaw() async {
    final db = await database;
    final now = DateTime.now();

    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end =
        DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    return await db.query(
      'water_logs',
      where: 'timestamp_ms >= ? AND timestamp_ms < ?',
      whereArgs: [start, end],
      orderBy: 'timestamp_ms DESC',
    );
  }

  Future<int> getTodayTotalMl() async {
    final db = await database;
    final now = DateTime.now();

    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end =
        DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    final res = await db.rawQuery(
      'SELECT SUM(amount_ml) as total FROM water_logs '
      'WHERE timestamp_ms >= ? AND timestamp_ms < ?',
      [start, end],
    );

    final value = res.first['total'] as int?;
    return value ?? 0;
  }

  Future<int> getDailyGoalMl() async {
    final db = await database;
    final res =
        await db.query('water_settings', where: 'id = 1', limit: 1);

    if (res.isNotEmpty) {
      return res.first['daily_goal_ml'] as int;
    }
    return 2000;
  }

  Future<void> setDailyGoalMl(int goalMl) async {
    final db = await database;
    await db.insert(
      'water_settings',
      {'id': 1, 'daily_goal_ml': goalMl},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =========================
//  EXERCÍCIOS
// =========================

Future<void> _createExerciseTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_logs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      intensity TEXT NOT NULL,
      duration_min INTEGER NOT NULL,
      timestamp_ms INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_settings(
      id INTEGER PRIMARY KEY,
      daily_goal_min INTEGER NOT NULL
    )
  ''');

  // Meta padrão = 30 min
  await db.insert(
    'exercise_settings',
    {'id': 1, 'daily_goal_min': 30},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}


 Future<int> addExercise({
  required String type,
  required String intensity,
  required int durationMin,
}) async {
  final db = await database;
  final now = DateTime.now().millisecondsSinceEpoch;
  return await db.insert('exercise_logs', {
    'type': type,
    'intensity': intensity,
    'duration_min': durationMin,
    'timestamp_ms': now,
  });
}

  Future<List<Map<String, dynamic>>> getTodayExercisesRaw() async {
    final db = await database;
    final now = DateTime.now();

    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end =
        DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    return await db.query(
      'exercise_logs',
      where: 'timestamp_ms >= ? AND timestamp_ms < ?',
      whereArgs: [start, end],
      orderBy: 'timestamp_ms DESC',
    );
  }

  Future<int> getTodayTotalExerciseMin() async {
    final db = await database;
    final now = DateTime.now();

    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end =
        DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    final res = await db.rawQuery(
      'SELECT SUM(duration_min) as total FROM exercise_logs '
      'WHERE timestamp_ms >= ? AND timestamp_ms < ?',
      [start, end],
    );

    final value = res.first['total'] as int?;
    return value ?? 0;
  }

  Future<int> getExerciseDailyGoalMin() async {
    final db = await database;
    final res =
        await db.query('exercise_settings', where: 'id = 1', limit: 1);

    if (res.isNotEmpty) {
      return res.first['daily_goal_min'] as int;
    }
    return 30;
  }

  Future<void> setExerciseDailyGoalMin(int minutes) async {
    final db = await database;
    await db.insert(
      'exercise_settings',
      {'id': 1, 'daily_goal_min': minutes},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  
}
