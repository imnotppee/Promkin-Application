// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:promkin_app/data/local/app_database.dart';
import 'package:promkin_app/data/local/user_settings_dao.dart';
import 'package:promkin_app/models/user_settings.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await AppDatabase.instance.database;

    // ล้างข้อมูลทดสอบก่อนเริ่มแต่ละครั้ง
    await db.delete('PLANNED_MEALS');
    await db.delete('MEAL_PLANS');
    await db.delete('USER_SETTINGS');
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  test('บันทึกและอ่านการตั้งค่าผู้ใช้', () async {
    const settings = UserSettings(
      userId: 'test-user-001',
      dailyBudget: 150,
      mealsPerDay: 3,
      calorieTarget: 2000,
      foodType: 'ทั่วไป',
      excludedFoods: 'กุ้ง, ถั่ว',
    );

    await UserSettingsDao.instance.save(settings);

    final result = await UserSettingsDao.instance.getByUserId('test-user-001');

    expect(result, isNotNull);
    expect(result!.dailyBudget, 150);
    expect(result.mealsPerDay, 3);
    expect(result.calorieTarget, 2000);
    expect(result.foodType, 'ทั่วไป');
    expect(result.excludedFoods, 'กุ้ง, ถั่ว');

    print('บันทึกและอ่านข้อมูลสำเร็จ');
  });

  test('แก้ไขงบประมาณของผู้ใช้', () async {
    await UserSettingsDao.instance.save(
      const UserSettings(userId: 'test-user-002', dailyBudget: 100),
    );

    final updatedRows = await UserSettingsDao.instance.update(
      const UserSettings(userId: 'test-user-002', dailyBudget: 200),
    );

    final result = await UserSettingsDao.instance.getByUserId('test-user-002');

    expect(updatedRows, 1);
    expect(result!.dailyBudget, 200);

    print('แก้ไขข้อมูลสำเร็จ');
  });

  test('ลบข้อมูลผู้ใช้', () async {
    await UserSettingsDao.instance.save(
      const UserSettings(userId: 'test-user-003'),
    );

    final deletedRows = await UserSettingsDao.instance.delete('test-user-003');

    final result = await UserSettingsDao.instance.getByUserId('test-user-003');

    expect(deletedRows, 1);
    expect(result, isNull);

    print('ลบข้อมูลสำเร็จ');
  });
}
