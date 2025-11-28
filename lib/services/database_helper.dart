import 'package:fl_chart/fl_chart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const _dbName = 'ihealthy.db';
  static const _dbVersion = 6; // 🔥 NOVA VERSÃO COM MULTI-USUÁRIO

  Database? _database;

  // Usuário ativo (por padrão 1, mas você deve trocar quando logar)
  int _activeUserId = 1;

  void setActiveUser(int userId) {
    _activeUserId = userId;
  }

  int get activeUserId => _activeUserId;

  // ============================================================
  // Core
  // ============================================================

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
        // Cria tudo já com user_id
        await _createUserTable(db);
        await _createWaterTables(db);
        await _createExerciseTables(db);
        await _createHabitsTables(db);
        await _createAchievementsTables(db);
        await _seedAchievements(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Como está em desenvolvimento e mudamos o schema, o mais simples:
        // derrubar tabelas antigas e recriar.
        if (oldVersion < 6) {
          await db.execute('DROP TABLE IF EXISTS water_logs');
          await db.execute('DROP TABLE IF EXISTS water_settings');
          await db.execute('DROP TABLE IF EXISTS exercise_logs');
          await db.execute('DROP TABLE IF EXISTS exercise_settings');
          await db.execute('DROP TABLE IF EXISTS habit_logs');
          await db.execute('DROP TABLE IF EXISTS habits');
          await db.execute('DROP TABLE IF EXISTS achievements');
          // users eu mantenho, para não quebrar login
          // await db.execute('DROP TABLE IF EXISTS users');

          await _createWaterTables(db);
          await _createExerciseTables(db);
          await _createHabitsTables(db);
          await _createAchievementsTables(db);
          await _seedAchievements(db);
        }

        if (oldVersion < 1) await _createUserTable(db);
      },
    );
  }

  // ============================================================
  // USERS
  // ============================================================

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
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ============================================================
  // ÁGUA
  // ============================================================

  Future<void> _createWaterTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS water_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount_ml INTEGER NOT NULL,
        timestamp_ms INTEGER NOT NULL,
        user_id INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS water_settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        daily_goal_ml INTEGER NOT NULL
      )
    ''');
  }

  Future<int> addWater(int amountMl) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Garante que o usuário ativo tem meta configurada
    await _ensureWaterSettingsForUser(db);

    final id = await db.insert('water_logs', {
      'amount_ml': amountMl,
      'timestamp_ms': now,
      'user_id': _activeUserId,
    });

    // 🔥 CONQUISTAS
    await updateAchievementProgress("first_water", 1);
    await checkWater3DaysStreak();

    return id;
  }

  Future<void> _ensureWaterSettingsForUser(Database db) async {
    final res = await db.query(
      'water_settings',
      where: 'user_id = ?',
      whereArgs: [_activeUserId],
      limit: 1,
    );

    if (res.isEmpty) {
      await db.insert('water_settings', {
        'user_id': _activeUserId,
        'daily_goal_ml': 2000,
      });
    }
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
      where: 'timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?',
      whereArgs: [start, end, _activeUserId],
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
      '''
      SELECT SUM(amount_ml) as total FROM water_logs
      WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
      ''',
      [start, end, _activeUserId],
    );

    final value = res.first['total'] as int?;
    return value ?? 0;
  }

  Future<int> getDailyGoalMl() async {
    final db = await database;
    await _ensureWaterSettingsForUser(db);

    final res = await db.query(
      'water_settings',
      where: 'user_id = ?',
      whereArgs: [_activeUserId],
      limit: 1,
    );

    if (res.isNotEmpty) return res.first['daily_goal_ml'] as int;
    return 2000;
  }

  Future<void> setDailyGoalMl(int goalMl) async {
    final db = await database;
    await _ensureWaterSettingsForUser(db);

    await db.update(
      'water_settings',
      {'daily_goal_ml': goalMl},
      where: 'user_id = ?',
      whereArgs: [_activeUserId],
    );
  }

  // ============================================================
  // EXERCÍCIOS
  // ============================================================

  Future<void> _createExerciseTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercise_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        intensity TEXT NOT NULL,
        duration_min INTEGER NOT NULL,
        timestamp_ms INTEGER NOT NULL,
        user_id INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercise_settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        daily_goal_min INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _ensureExerciseSettingsForUser(Database db) async {
    final res = await db.query(
      'exercise_settings',
      where: 'user_id = ?',
      whereArgs: [_activeUserId],
      limit: 1,
    );

    if (res.isEmpty) {
      await db.insert('exercise_settings', {
        'user_id': _activeUserId,
        'daily_goal_min': 30,
      });
    }
  }

  Future<int> addExercise({
    required String type,
    required String intensity,
    required int durationMin,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await _ensureExerciseSettingsForUser(db);

    final id = await db.insert('exercise_logs', {
      'type': type,
      'intensity': intensity,
      'duration_min': durationMin,
      'timestamp_ms': now,
      'user_id': _activeUserId,
    });

    // 🔥 CONQUISTAS
    await updateAchievementProgress("first_exercise", 1);
    await updateAchievementProgress("exercise_5", 1);

    return id;
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
      where: 'timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?',
      whereArgs: [start, end, _activeUserId],
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
      '''
      SELECT SUM(duration_min) as total FROM exercise_logs
      WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
      ''',
      [start, end, _activeUserId],
    );

    final value = res.first['total'] as int?;
    return value ?? 0;
  }

  Future<int> getExerciseDailyGoalMin() async {
    final db = await database;
    await _ensureExerciseSettingsForUser(db);

    final res = await db.query(
      'exercise_settings',
      where: 'user_id = ?',
      whereArgs: [_activeUserId],
      limit: 1,
    );

    if (res.isNotEmpty) return res.first['daily_goal_min'] as int;
    return 30;
  }

  Future<void> setExerciseDailyGoalMin(int minutes) async {
    final db = await database;
    await _ensureExerciseSettingsForUser(db);

    await db.update(
      'exercise_settings',
      {'daily_goal_min': minutes},
      where: 'user_id = ?',
      whereArgs: [_activeUserId],
    );
  }

  // ============================================================
  // HÁBITOS
  // ============================================================

  Future<void> _createHabitsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        frequency TEXT NOT NULL,
        streak INTEGER NOT NULL DEFAULT 0,
        user_id INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS habit_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        timestamp_ms INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id)
      )
    ''');
  }

  Future<int> addHabit(Map<String, dynamic> habit) async {
    final db = await database;
    final data = {
      ...habit,
      'user_id': _activeUserId,
    };
    return await db.insert('habits', data);
  }

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;
    return await db.query(
      "habits",
      where: "user_id = ?",
      whereArgs: [_activeUserId],
    );
  }

  Future<void> toggleHabitDone(int habitId) async {
    final db = await database;

    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end =
        DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    final existToday = await db.query(
      "habit_logs",
      where:
          "habit_id = ? AND timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?",
      whereArgs: [habitId, start, end, _activeUserId],
    );

    if (existToday.isEmpty) {
      await db.insert("habit_logs", {
        'habit_id': habitId,
        'timestamp_ms': now.millisecondsSinceEpoch,
        'user_id': _activeUserId,
      });

      await db.rawUpdate(
        "UPDATE habits SET streak = streak + 1 WHERE id = ? AND user_id = ?",
        [habitId, _activeUserId],
      );
    }
  }

  Future<bool> isHabitDoneToday(int habitId) async {
    final db = await database;

    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end =
        DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    final res = await db.query(
      "habit_logs",
      where:
          "habit_id = ? AND timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?",
      whereArgs: [habitId, start, end, _activeUserId],
    );

    return res.isNotEmpty;
  }

  // ============================================================
  // PROGRESSO: Semana / Mês
  // ============================================================

  int _startOfWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day)
        .millisecondsSinceEpoch;
  }

  int _endOfWeek() {
    final start = _startOfWeek();
    return start + Duration(days: 7).inMilliseconds;
  }

  int _startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
  }

  int _endOfMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return nextMonth.millisecondsSinceEpoch;
  }

  // ---------------------- ÁGUA ----------------------

  Future<double> getWaterTotalWeek() async {
    final db = await database;

    final res = await db.rawQuery(
      '''
      SELECT SUM(amount_ml) AS total
      FROM water_logs
      WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
      ''',
      [_startOfWeek(), _endOfWeek(), _activeUserId],
    );

    final value = res.first['total'] as num?;
    return (value ?? 0) / 1000.0;
  }

  Future<double> getWaterTotalMonth() async {
    final db = await database;

    final res = await db.rawQuery(
      '''
      SELECT SUM(amount_ml) AS total
      FROM water_logs
      WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
      ''',
      [_startOfMonth(), _endOfMonth(), _activeUserId],
    );

    final value = res.first['total'] as num?;
    return (value ?? 0) / 1000.0;
  }

  // ---------------------- EXERCÍCIOS ----------------------

  Future<int> getExerciseTotalWeek() async {
    final db = await database;

    final res = await db.rawQuery(
      '''
      SELECT SUM(duration_min) AS total
      FROM exercise_logs
      WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
      ''',
      [_startOfWeek(), _endOfWeek(), _activeUserId],
    );

    return (res.first['total'] as int?) ?? 0;
  }

  Future<int> getExerciseTotalMonth() async {
    final db = await database;

    final res = await db.rawQuery(
      '''
      SELECT SUM(duration_min) AS total
      FROM exercise_logs
      WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
      ''',
      [_startOfMonth(), _endOfMonth(), _activeUserId],
    );

    return (res.first['total'] as int?) ?? 0;
  }

  // ---------------------- HÁBITOS MÉDIA ----------------------

  Future<double> getHabitsAverageWeek() async {
    final db = await database;

    final habits = await db.query(
      "habits",
      where: "user_id = ?",
      whereArgs: [_activeUserId],
    );
    if (habits.isEmpty) return 0;

    int completed = 0;

    for (var habit in habits) {
      final id = habit['id'];

      final res = await db.rawQuery(
        '''
        SELECT COUNT(*) AS total
        FROM habit_logs
        WHERE habit_id = ?
        AND timestamp_ms >= ?
        AND timestamp_ms < ?
        AND user_id = ?
        ''',
        [id, _startOfWeek(), _endOfWeek(), _activeUserId],
      );

      final count = (res.first['total'] as int?) ?? 0;
      if (count > 0) completed++;
    }

    return (completed / habits.length) * 100;
  }

  Future<double> getHabitsAverageMonth() async {
    final db = await database;

    final habits = await db.query(
      "habits",
      where: "user_id = ?",
      whereArgs: [_activeUserId],
    );
    if (habits.isEmpty) return 0;

    int completed = 0;

    for (var habit in habits) {
      final id = habit['id'];

      final res = await db.rawQuery(
        '''
        SELECT COUNT(*) AS total
        FROM habit_logs
        WHERE habit_id = ?
        AND timestamp_ms >= ?
        AND timestamp_ms < ?
        AND user_id = ?
        ''',
        [id, _startOfMonth(), _endOfMonth(), _activeUserId],
      );

      final count = (res.first['total'] as int?) ?? 0;
      if (count > 0) completed++;
    }

    return (completed / habits.length) * 100;
  }

  // ---------------------- CONSISTÊNCIA ----------------------

  Future<double> getConsistencyWeek() async {
    final db = await database;
    final goalWater = await getDailyGoalMl();
    final goalExercise = await getExerciseDailyGoalMin();

    int daysGood = 0;

    final start = DateTime.fromMillisecondsSinceEpoch(_startOfWeek());
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));

      final dayStart =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final dayEnd = dayStart + Duration(days: 1).inMilliseconds;

      final water = await db.rawQuery(
        '''
        SELECT SUM(amount_ml) AS total FROM water_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [dayStart, dayEnd, _activeUserId],
      );

      final ex = await db.rawQuery(
        '''
        SELECT SUM(duration_min) AS total FROM exercise_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [dayStart, dayEnd, _activeUserId],
      );

      final waterOk = ((water.first['total'] as int?) ?? 0) >= goalWater;
      final exOk = ((ex.first['total'] as int?) ?? 0) >= goalExercise;

      if (waterOk || exOk) daysGood++;
    }

    return (daysGood / 7) * 100;
  }

  Future<double> getConsistencyMonth() async {
    final db = await database;
    final goalWater = await getDailyGoalMl();
    final goalExercise = await getExerciseDailyGoalMin();

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    int daysGood = 0;

    final start = DateTime(now.year, now.month, 1);

    for (int i = 0; i < daysInMonth; i++) {
      final day = start.add(Duration(days: i));

      final dayStart =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final dayEnd = dayStart + Duration(days: 1).inMilliseconds;

      final water = await db.rawQuery(
        '''
        SELECT SUM(amount_ml) AS total FROM water_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [dayStart, dayEnd, _activeUserId],
      );

      final ex = await db.rawQuery(
        '''
        SELECT SUM(duration_min) AS total FROM exercise_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [dayStart, dayEnd, _activeUserId],
      );

      final waterOk = ((water.first['total'] as int?) ?? 0) >= goalWater;
      final exOk = ((ex.first['total'] as int?) ?? 0) >= goalExercise;

      if (waterOk || exOk) daysGood++;
    }

    return (daysGood / daysInMonth) * 100;
  }

  // ---------------------- GRÁFICO HIDRATAÇÃO ----------------------

  Future<List<FlSpot>> getHydrationChartWeek() async {
    final db = await database;
    List<FlSpot> points = [];

    final start = DateTime.fromMillisecondsSinceEpoch(_startOfWeek());

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));

      final dayStart =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final dayEnd = dayStart + Duration(days: 1).inMilliseconds;

      final result = await db.rawQuery(
        '''
        SELECT SUM(amount_ml) AS total FROM water_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [dayStart, dayEnd, _activeUserId],
      );

      final value = (result.first['total'] as int?) ?? 0;
      points.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    return points;
  }

  Future<List<FlSpot>> getHydrationChartMonth() async {
    final db = await database;
    List<FlSpot> points = [];

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      final dayStart =
          DateTime(now.year, now.month, i).millisecondsSinceEpoch;
      final dayEnd = dayStart + Duration(days: 1).inMilliseconds;

      final result = await db.rawQuery(
        '''
        SELECT SUM(amount_ml) AS total FROM water_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [dayStart, dayEnd, _activeUserId],
      );

      final value = (result.first['total'] as int?) ?? 0;
      points.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    return points;
  }

  // ============================================================
  // CONQUISTAS (global por enquanto, não por usuário)
  // ============================================================

  Future<void> _createAchievementsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        unlocked INTEGER NOT NULL DEFAULT 0,
        progress INTEGER NOT NULL DEFAULT 0,
        goal INTEGER NOT NULL DEFAULT 1,
        unlocked_date TEXT
      )
    ''');
  }

  Future<void> _seedAchievements(Database db) async {
    final data = [
      {
        'code': 'first_water',
        'title': 'Primeira Gota',
        'description': 'Registrou sua primeira ingestão de água',
        'icon': 'water_drop',
        'color': 'blue',
        'goal': 1,
      },
      {
        'code': 'water_3_days',
        'title': 'Hidratado',
        'description': 'Atingiu a meta de água por 3 dias seguidos',
        'icon': 'water_drop',
        'color': 'cyan',
        'goal': 3,
      },
      {
        'code': 'first_exercise',
        'title': 'Atleta Iniciante',
        'description': 'Registrou seu primeiro exercício',
        'icon': 'directions_run',
        'color': 'pink',
        'goal': 1,
      },
      {
        'code': 'exercise_5',
        'title': 'Atleta Intermediário',
        'description': 'Completou 5 treinos no app',
        'icon': 'directions_run',
        'color': 'orange',
        'goal': 5,
      },
    ];

    for (var a in data) {
      await db.insert(
        "achievements",
        a,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> unlockAchievement(String code) async {
    final db = await database;

    await db.update(
      "achievements",
      {
        "unlocked": 1,
        "unlocked_date": DateTime.now().toIso8601String(),
      },
      where: "code = ?",
      whereArgs: [code],
    );
  }

  Future<void> updateAchievementProgress(String code, int add) async {
    final db = await database;

    final res = await db.query(
      "achievements",
      where: "code = ?",
      whereArgs: [code],
    );

    if (res.isEmpty) return;

    final row = res.first;
    final current = row['progress'] as int;
    final goal = row['goal'] as int;

    final newProgress = current + add;

    await db.update(
      "achievements",
      {"progress": newProgress},
      where: "code = ?",
      whereArgs: [code],
    );

    if (newProgress >= goal) {
      await unlockAchievement(code);
    }
  }

  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final db = await database;
    return await db.query(
      "achievements",
      orderBy: "unlocked DESC, progress DESC",
    );
  }

  // ============================================================
  // REGRAS AUTOMÁTICAS DE CONQUISTAS
  // ============================================================

  Future<void> checkWater3DaysStreak() async {
    final db = await database;
    final goal = await getDailyGoalMl();

    int streak = 0;

    for (int i = 0; i < 3; i++) {
      final day = DateTime.now().subtract(Duration(days: i));

      final start =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final end = start + Duration(days: 1).inMilliseconds;

      final data = await db.rawQuery(
        '''
        SELECT SUM(amount_ml) as total
        FROM water_logs
        WHERE timestamp_ms >= ? AND timestamp_ms < ? AND user_id = ?
        ''',
        [start, end, _activeUserId],
      );

      final total = (data.first["total"] as int?) ?? 0;

      if (total >= goal) streak++;
    }

    await updateAchievementProgress("water_3_days", streak);
  }
}