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
  static bool isDarkMode() {
    return _prefs?.getBool(AppConstants.keyDarkMode) ?? false;
  }

  static Future<bool> setDarkMode(bool value) async {
    return await _prefs?.setBool(AppConstants.keyDarkMode, value) ?? false;
  }

  // Reminder
  static bool isReminderEnabled() {
    return _prefs?.getBool(AppConstants.keyMealReminder) ?? true;
  }

  static Future<bool> setReminderEnabled(bool value) async {
    return await _prefs?.setBool(AppConstants.keyMealReminder, value) ?? false;
  }
}
