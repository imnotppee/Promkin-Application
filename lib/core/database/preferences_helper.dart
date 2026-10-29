import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Budget
  static double getDailyBudget() {
    return _prefs?.getDouble(AppConstants.keyDailyBudget) ??
        AppConstants.defaultDailyBudget;
  }

  static Future<bool> setDailyBudget(double budget) async {
    return await _prefs?.setDouble(AppConstants.keyDailyBudget, budget) ??
        false;
  }

  static double getMonthlyBudget() {
    return _prefs?.getDouble(AppConstants.keyMonthlyBudget) ??
        getDailyBudget() * 30;
  }

  static Future<bool> setMonthlyBudget(double budget) async {
    return await _prefs?.setDouble(AppConstants.keyMonthlyBudget, budget) ??
        false;
  }

  // Calories
  static int getDailyCalories() {
    return _prefs?.getInt(AppConstants.keyDailyCalories) ??
        AppConstants.defaultDailyCalories;
  }

  static Future<bool> setDailyCalories(int calories) async {
    return await _prefs?.setInt(AppConstants.keyDailyCalories, calories) ??
        false;
  }

  // Meals Per Day
  static int getMealsPerDay() {
    return _prefs?.getInt(AppConstants.keyMealsPerDay) ??
        AppConstants.defaultMealsPerDay;
  }

  static Future<bool> setMealsPerDay(int count) async {
    return await _prefs?.setInt(AppConstants.keyMealsPerDay, count) ?? false;
  }

  // Dark Mode
  static String getThemeMode() {
    final saved = _prefs?.getString(AppConstants.keyThemeMode);
    if (saved != null) return saved;
    final legacyDarkMode = _prefs?.getBool(AppConstants.keyDarkMode);
    if (legacyDarkMode == null) return 'system';
    return legacyDarkMode ? 'dark' : 'light';
  }

  static Future<bool> setThemeMode(String value) async {
    return await _prefs?.setString(AppConstants.keyThemeMode, value) ?? false;
  }

  static bool isDarkMode() {
    return getThemeMode() == 'dark';
  }

  static Future<bool> setDarkMode(bool value) async {
    return await _prefs?.setBool(AppConstants.keyDarkMode, value) ?? false;
  }

  // Reminder
  static bool isReminderEnabled() {
    return _prefs?.getBool(AppConstants.keyMealReminder) ?? false;
  }

  static Future<bool> setReminderEnabled(bool value) async {
    return await _prefs?.setBool(AppConstants.keyMealReminder, value) ?? false;
  }

  static bool hasHandledNotificationPrompt() {
    return _prefs?.getBool(AppConstants.keyNotificationPromptHandled) ?? false;
  }

  static Future<bool> setNotificationPromptHandled(bool value) async {
    return await _prefs?.setBool(
          AppConstants.keyNotificationPromptHandled,
          value,
        ) ??
        false;
  }
}
