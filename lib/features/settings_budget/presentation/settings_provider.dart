import 'package:flutter/material.dart';
import 'package:promkin_app/core/constants/app_constants.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';

class SettingsProvider extends ChangeNotifier {
  double _dailyBudget = AppConstants.defaultDailyBudget;
  double _monthlyBudget = 3800.0;
  int _dailyCalories = AppConstants.defaultDailyCalories;
  int _mealsPerDay = AppConstants.defaultMealsPerDay;
  bool _isMealReminderEnabled = true;
  bool _isDarkMode = false;
  final List<String> _dislikedIngredients = ['ถั่วลิสง'];
  final List<String> _favoriteCuisines = ['อาหารไทย', 'มังสวิรัติ'];

  double get dailyBudget => _dailyBudget;
  double get monthlyBudget => _monthlyBudget;
  int get dailyCalories => _dailyCalories;
  int get mealsPerDay => _mealsPerDay;
  bool get isMealReminderEnabled => _isMealReminderEnabled;
  bool get isDarkMode => _isDarkMode;
  List<String> get dislikedIngredients => _dislikedIngredients;
  List<String> get favoriteCuisines => _favoriteCuisines;

  SettingsProvider() {
    _loadFromPreferences();
  }

  void _loadFromPreferences() {
    try {
      _dailyBudget = PreferencesHelper.getDailyBudget();
      _monthlyBudget = _dailyBudget * 30;
      _dailyCalories = PreferencesHelper.getDailyCalories();
      _mealsPerDay = PreferencesHelper.getMealsPerDay();
      _isMealReminderEnabled = PreferencesHelper.isReminderEnabled();
      _isDarkMode = PreferencesHelper.isDarkMode();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateBudget(double newBudget) async {
    _dailyBudget = newBudget;
    _monthlyBudget = newBudget * 30;
    await PreferencesHelper.setDailyBudget(newBudget);
    notifyListeners();
  }

  Future<void> updateMonthlyBudget(double newMonthly) async {
    _monthlyBudget = newMonthly;
    _dailyBudget = (newMonthly / 30).roundToDouble();
    await PreferencesHelper.setDailyBudget(_dailyBudget);
    notifyListeners();
  }

  Future<void> updateCalories(int newCalories) async {
    _dailyCalories = newCalories;
    await PreferencesHelper.setDailyCalories(newCalories);
    notifyListeners();
  }

  Future<void> updateMealsPerDay(int count) async {
    _mealsPerDay = count;
    await PreferencesHelper.setMealsPerDay(count);
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isMealReminderEnabled = value;
    await PreferencesHelper.setReminderEnabled(value);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await PreferencesHelper.setDarkMode(value);
    notifyListeners();
  }

  void addDislikedIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_dislikedIngredients.contains(ingredient)) {
      _dislikedIngredients.add(ingredient);
      notifyListeners();
    }
  }

  void removeDislikedIngredient(String ingredient) {
    _dislikedIngredients.remove(ingredient);
    notifyListeners();
  }

  void toggleFavoriteCuisine(String cuisine) {
    if (_favoriteCuisines.contains(cuisine)) {
      _favoriteCuisines.remove(cuisine);
    } else {
      _favoriteCuisines.add(cuisine);
    }
    notifyListeners();
  }
}
