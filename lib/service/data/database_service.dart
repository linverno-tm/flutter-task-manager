import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../models/task_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        deadline TEXT,
        isCompleted INTEGER NOT NULL,
        category TEXT,
        priority INTEGER,
        userId TEXT NOT NULL,
        isSynced INTEGER NOT NULL
      )
    ''');
  }

  // Task qo'shish
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Barcha tasklar
  Future<List<Task>> getAllTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Bugungi tasklar
  Future<List<Task>> getTodayTasks(String userId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND deadline >= ? AND deadline <= ?',
      whereArgs: [
        userId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Task yangilash
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Task o'chirish
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  // Sync bo'lmagan tasklar
  Future<List<Task>> getUnsyncedTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND isSynced = ?',
      whereArgs: [userId, 0],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Bajarilgan tasklar soni
  Future<int> getCompletedTasksCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE userId = ? AND isCompleted = 1',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Barcha tasklar soni
  Future<int> getTotalTasksCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Barcha ma'lumotlarni o'chirish
  Future<void> clearAllTasks(String userId) async {
    final db = await database;
    await db.delete('tasks', where: 'userId = ?', whereArgs: [userId]);
  }

  // Database'ni butunlay o'chirish
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
