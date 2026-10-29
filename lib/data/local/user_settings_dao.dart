import 'package:sqflite/sqflite.dart';

import '../../models/user_settings.dart';
import 'app_database.dart';

class UserSettingsDao {
  UserSettingsDao._();

  static final UserSettingsDao instance = UserSettingsDao._();

  // เพิ่มหรือบันทึกการตั้งค่าผู้ใช้
  Future<void> save(UserSettings settings) async {
    final Database db = await AppDatabase.instance.database;

    await db.insert(
      'USER_SETTINGS',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // อ่านการตั้งค่าจาก user_id
  Future<UserSettings?> getByUserId(String userId) async {
    final Database db = await AppDatabase.instance.database;

    final result = await db.query(
      'USER_SETTINGS',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return UserSettings.fromMap(result.first);
  }

  // แก้ไขการตั้งค่า
  Future<int> update(UserSettings settings) async {
    final Database db = await AppDatabase.instance.database;

    return db.update(
      'USER_SETTINGS',
      settings.toMap(),
      where: 'user_id = ?',
      whereArgs: [settings.userId],
    );
  }

  // ลบการตั้งค่า
  Future<int> delete(String userId) async {
    final Database db = await AppDatabase.instance.database;

    return db.delete(
      'USER_SETTINGS',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
