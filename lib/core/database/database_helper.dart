import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Local SQLite database table for Meals (Satisfies Course Criterion 4)
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        mealType TEXT NOT NULL,
        price REAL NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        emoji TEXT DEFAULT '🍛',
        time TEXT DEFAULT '12:00',
        tags TEXT DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          "ALTER TABLE meals ADD COLUMN emoji TEXT DEFAULT '🍛'",
        );
      } catch (_) {}
      try {
        await db.execute(
          "ALTER TABLE meals ADD COLUMN time TEXT DEFAULT '12:00'",
        );
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE meals ADD COLUMN tags TEXT DEFAULT ''");
      } catch (_) {}
    }
  }

  Future<int> insertMeal(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      'meals',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMealsByDate(String date) async {
    final db = await database;
    return await db.query(
      'meals',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC, id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllMeals() async {
    final db = await database;
    return await db.query('meals', orderBy: 'date DESC');
  }

  Future<int> updateMeal(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update('meals', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMeal(String id) async {
    final db = await database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllMeals() async {
    final db = await database;
    await db.delete('meals');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
