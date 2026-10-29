// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:promkin_app/data/local/app_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('SQLite creates all required tables', () async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' ORDER BY name",
    );

    final tables = result.map((row) => row['name'] as String).toList();

    expect(tables, contains('USER_SETTINGS'));
    expect(tables, contains('MEAL_PLANS'));
    expect(tables, contains('PLANNED_MEALS'));

    print('Tables found: $tables');

    await AppDatabase.instance.close();
  });
}
