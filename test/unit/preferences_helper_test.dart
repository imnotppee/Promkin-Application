import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';

void main() {
  group('PreferencesHelper Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesHelper.init();
    });

    test('getters return defaults and setters persist values', () async {
      // Test default values
      expect(PreferencesHelper.getDailyBudget(), 300.0);
      expect(PreferencesHelper.getMonthlyBudget(), 9000.0);
      expect(PreferencesHelper.getDailyCalories(), 2000);
      expect(PreferencesHelper.getMealsPerDay(), 3);
      expect(PreferencesHelper.isDarkMode(), isFalse);
      expect(PreferencesHelper.isReminderEnabled(), isTrue);

      // Test updating values
      await PreferencesHelper.setDailyBudget(250.0);
      expect(PreferencesHelper.getDailyBudget(), 250.0);

      await PreferencesHelper.setMonthlyBudget(7500.0);
      expect(PreferencesHelper.getMonthlyBudget(), 7500.0);

      await PreferencesHelper.setDailyCalories(2500);
      expect(PreferencesHelper.getDailyCalories(), 2500);

      await PreferencesHelper.setMealsPerDay(4);
      expect(PreferencesHelper.getMealsPerDay(), 4);

      await PreferencesHelper.setDarkMode(true);
      expect(PreferencesHelper.isDarkMode(), isTrue);

      await PreferencesHelper.setReminderEnabled(false);
      expect(PreferencesHelper.isReminderEnabled(), isFalse);
    });
  });
}
