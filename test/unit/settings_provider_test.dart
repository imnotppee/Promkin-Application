import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promkin_app/core/constants/app_constants.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesHelper.init();
    });

    test('should update daily and monthly budget correctly', () async {
      final provider = SettingsProvider();

      expect(provider.dailyBudget, AppConstants.defaultDailyBudget);

      await provider.updateBudget(200.0);
      expect(provider.dailyBudget, 200.0);
      expect(provider.monthlyBudget, 6000.0);

      await provider.updateMonthlyBudget(4500.0);
      expect(provider.monthlyBudget, 4500.0);
      expect(provider.dailyBudget, 150.0);
    });

    test('should update calories and meals per day correctly', () async {
      final provider = SettingsProvider();

      await provider.updateCalories(2200);
      expect(provider.dailyCalories, 2200);

      await provider.updateMealsPerDay(4);
      expect(provider.mealsPerDay, 4);

      provider.toggleFavoriteCuisine('อาหารญี่ปุ่น');
      expect(provider.favoriteCuisines, contains('อาหารญี่ปุ่น'));
      provider.toggleFavoriteCuisine('อาหารญี่ปุ่น');
      expect(provider.favoriteCuisines, isNot(contains('อาหารญี่ปุ่น')));
    });

    test('should add and remove disliked ingredients correctly', () {
      final provider = SettingsProvider();

      provider.addDislikedIngredient('กุ้ง');
      expect(provider.dislikedIngredients, contains('กุ้ง'));

      provider.removeDislikedIngredient('กุ้ง');
      expect(provider.dislikedIngredients, isNot(contains('กุ้ง')));
    });

    test('should toggle dark mode and reminder flags', () async {
      final provider = SettingsProvider();

      await provider.toggleDarkMode(true);
      expect(provider.isDarkMode, isTrue);

      await provider.toggleReminder(false);
      expect(provider.isMealReminderEnabled, isFalse);
    });
  });
}
