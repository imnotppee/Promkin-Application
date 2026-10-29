import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:promkin_app/core/constants/app_constants.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/core/services/firebase_service.dart';

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
      _monthlyBudget = PreferencesHelper.getMonthlyBudget();
      _dailyCalories = PreferencesHelper.getDailyCalories();
      _mealsPerDay = PreferencesHelper.getMealsPerDay();
      _isMealReminderEnabled = PreferencesHelper.isReminderEnabled();
      _isDarkMode = PreferencesHelper.isDarkMode();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadForUser(String userId) async {
    try {
      final profile = await FirebaseService.instance.getUserProfile(userId);
      final saved = profile?['settings'];
      if (saved is! Map) return;

      final dailyBudget = (saved['dailyBudget'] as num?)?.toDouble();
      final monthlyBudget = (saved['monthlyBudget'] as num?)?.toDouble();
      final dailyCalories = (saved['dailyCalories'] as num?)?.toInt();
      final mealsPerDay = (saved['mealsPerDay'] as num?)?.toInt();
      final isDarkMode = saved['isDarkMode'] as bool?;
      final reminderEnabled = saved['isMealReminderEnabled'] as bool?;
      final disliked = (saved['dislikedIngredients'] as List?)
          ?.map((item) => item.toString())
          .toList();
      final cuisines = (saved['favoriteCuisines'] as List?)
          ?.map((item) => item.toString())
          .toList();

      if (dailyBudget != null) _dailyBudget = dailyBudget;
      if (monthlyBudget != null) {
        _monthlyBudget = monthlyBudget;
      } else if (dailyBudget != null) {
        _monthlyBudget = dailyBudget * 30;
      }
      if (dailyCalories != null) _dailyCalories = dailyCalories;
      if (mealsPerDay != null) _mealsPerDay = mealsPerDay;
      if (isDarkMode != null) _isDarkMode = isDarkMode;
      if (reminderEnabled != null) _isMealReminderEnabled = reminderEnabled;
      if (disliked != null) {
        _dislikedIngredients
          ..clear()
          ..addAll(disliked);
      }
      if (cuisines != null) {
        _favoriteCuisines
          ..clear()
          ..addAll(cuisines);
      }

      await PreferencesHelper.setDailyBudget(_dailyBudget);
      await PreferencesHelper.setMonthlyBudget(_monthlyBudget);
      await PreferencesHelper.setDailyCalories(_dailyCalories);
      await PreferencesHelper.setMealsPerDay(_mealsPerDay);
      await PreferencesHelper.setDarkMode(_isDarkMode);
      await PreferencesHelper.setReminderEnabled(_isMealReminderEnabled);
      notifyListeners();
    } catch (error) {
      debugPrint('Could not load cloud settings for user $userId: $error');
    }
  }

  Future<void> _syncForCurrentUser() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || !FirebaseService.instance.isInitialized) return;
    try {
      await FirebaseService.instance.syncUserSettings(userId, {
        'dailyBudget': _dailyBudget,
        'monthlyBudget': _monthlyBudget,
        'dailyCalories': _dailyCalories,
        'mealsPerDay': _mealsPerDay,
        'isDarkMode': _isDarkMode,
        'isMealReminderEnabled': _isMealReminderEnabled,
        'dislikedIngredients': List<String>.from(_dislikedIngredients),
        'favoriteCuisines': List<String>.from(_favoriteCuisines),
      });
    } catch (error) {
      debugPrint('Could not sync settings to Firestore: $error');
    }
  }

  Future<void> updateBudget(double newBudget) async {
    _dailyBudget = newBudget;
    _monthlyBudget = newBudget * 30;
    await PreferencesHelper.setDailyBudget(newBudget);
    await PreferencesHelper.setMonthlyBudget(_monthlyBudget);
    await _syncForCurrentUser();
    notifyListeners();
  }

  Future<void> updateMonthlyBudget(double newMonthly) async {
    _monthlyBudget = newMonthly;
    _dailyBudget = (newMonthly / 30).roundToDouble();
    await PreferencesHelper.setDailyBudget(_dailyBudget);
    await PreferencesHelper.setMonthlyBudget(_monthlyBudget);
    await _syncForCurrentUser();
    notifyListeners();
  }

  Future<void> updateCalories(int newCalories) async {
    _dailyCalories = newCalories;
    await PreferencesHelper.setDailyCalories(newCalories);
    await _syncForCurrentUser();
    notifyListeners();
  }

  Future<void> updateMealsPerDay(int count) async {
    _mealsPerDay = count;
    await PreferencesHelper.setMealsPerDay(count);
    await _syncForCurrentUser();
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isMealReminderEnabled = value;
    await PreferencesHelper.setReminderEnabled(value);
    await _syncForCurrentUser();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await PreferencesHelper.setDarkMode(value);
    await _syncForCurrentUser();
    notifyListeners();
  }

  void addDislikedIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_dislikedIngredients.contains(ingredient)) {
      _dislikedIngredients.add(ingredient);
      _syncForCurrentUser();
      notifyListeners();
    }
  }

  void removeDislikedIngredient(String ingredient) {
    _dislikedIngredients.remove(ingredient);
    _syncForCurrentUser();
    notifyListeners();
  }

  void toggleFavoriteCuisine(String cuisine) {
    if (_favoriteCuisines.contains(cuisine)) {
      _favoriteCuisines.remove(cuisine);
    } else {
      _favoriteCuisines.add(cuisine);
    }
    _syncForCurrentUser();
    notifyListeners();
  }
}
