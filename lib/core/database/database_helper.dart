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
      onUpgrade: _upgradeDB,
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
        emoji TEXT NOT NULL DEFAULT '🍽️',
        time TEXT NOT NULL DEFAULT '12:00',
        tags TEXT NOT NULL DEFAULT '',
        imageUrl TEXT NOT NULL DEFAULT '',
        source TEXT NOT NULL DEFAULT 'ai',
        sourceId TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE meals ADD COLUMN emoji TEXT NOT NULL DEFAULT '🍽️'",
      );
      await db.execute(
        "ALTER TABLE meals ADD COLUMN time TEXT NOT NULL DEFAULT '12:00'",
      );
      await db.execute(
        "ALTER TABLE meals ADD COLUMN tags TEXT NOT NULL DEFAULT ''",
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE meals ADD COLUMN imageUrl TEXT NOT NULL DEFAULT ''",
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE meals ADD COLUMN source TEXT NOT NULL DEFAULT 'ai'",
      );
      await db.execute('ALTER TABLE meals ADD COLUMN sourceId TEXT');
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
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
