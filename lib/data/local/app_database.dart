import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('promkin.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE USER_SETTINGS (
            user_id TEXT PRIMARY KEY,
            daily_budget REAL NOT NULL DEFAULT 100,
            meals_per_day INTEGER NOT NULL DEFAULT 3,
            calorie_target INTEGER,
            food_type TEXT,
            excluded_foods TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE MEAL_PLANS (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            plan_date TEXT NOT NULL,
            UNIQUE(user_id, plan_date),
            FOREIGN KEY (user_id)
              REFERENCES USER_SETTINGS(user_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE PLANNED_MEALS (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meal_plan_id INTEGER NOT NULL,
            recipe_id TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            scheduled_at TEXT,
            servings INTEGER NOT NULL DEFAULT 1,
            estimated_cost REAL,
            calories REAL,
            protein_g REAL,
            carbs_g REAL,
            fat_g REAL,
            FOREIGN KEY (meal_plan_id)
              REFERENCES MEAL_PLANS(id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    if (_database == null) return;

    await _database!.close();
    _database = null;
  }
}
