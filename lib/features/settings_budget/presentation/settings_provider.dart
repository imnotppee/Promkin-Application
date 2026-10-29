import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:promkin_app/core/constants/app_constants.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/core/services/firebase_service.dart';
import 'package:promkin_app/core/services/notification_service.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';

class SettingsProvider extends ChangeNotifier {
  double _dailyBudget = AppConstants.defaultDailyBudget;
  double _monthlyBudget = 3800.0;
  int _dailyCalories = AppConstants.defaultDailyCalories;
  int _mealsPerDay = AppConstants.defaultMealsPerDay;
  bool _isMealReminderEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  final List<String> _dislikedIngredients = ['ถั่วลิสง'];
  final List<String> _favoriteCuisines = ['อาหารไทย', 'มังสวิรัติ'];

  double get dailyBudget => _dailyBudget;
  double get monthlyBudget => _monthlyBudget;
  int get dailyCalories => _dailyCalories;
  int get mealsPerDay => _mealsPerDay;
  bool get isMealReminderEnabled => _isMealReminderEnabled;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
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
      _themeMode = _themeModeFromString(PreferencesHelper.getThemeMode());
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadForUser(String userId) async {
    if (!FirebaseService.instance.isInitialized) return;
    try {
      final profile = await FirebaseService.instance.getUserProfile(userId);
      final saved = profile?['settings'];
      if (saved is! Map) return;

      final dailyBudget = (saved['dailyBudget'] as num?)?.toDouble();
      final monthlyBudget = (saved['monthlyBudget'] as num?)?.toDouble();
      final dailyCalories = (saved['dailyCalories'] as num?)?.toInt();
      final mealsPerDay = (saved['mealsPerDay'] as num?)?.toInt();
      final isDarkMode = saved['isDarkMode'] as bool?;
      final cloudThemeMode = saved['themeMode'] as String?;
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
      if (cloudThemeMode != null) {
        _themeMode = _themeModeFromString(cloudThemeMode);
      } else if (isDarkMode != null) {
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      }
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
      await PreferencesHelper.setThemeMode(_themeMode.name);
      await PreferencesHelper.setReminderEnabled(_isMealReminderEnabled);
      await _syncMealReminders();
      notifyListeners();
    } catch (error) {
      debugPrint('Could not load cloud settings for user $userId: $error');
    }
  }

  Future<void> _syncForCurrentUser() async {
    if (!FirebaseService.instance.isInitialized) return;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      await FirebaseService.instance.syncUserSettings(userId, {
        'dailyBudget': _dailyBudget,
        'monthlyBudget': _monthlyBudget,
        'dailyCalories': _dailyCalories,
        'mealsPerDay': _mealsPerDay,
        'isDarkMode': isDarkMode,
        'themeMode': _themeMode.name,
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

  Future<bool> toggleReminder(bool value) async {
    if (value) {
      final allowed = await NotificationService.instance.requestPermissions();
      if (!allowed) return false;
      // Exact alarms prevent Android from batching a meal reminder until later.
      // If the user declines this special access, reminders still fall back to
      // the inexact schedule mode.
      await NotificationService.instance.requestExactReminderAccess();
    }
    _isMealReminderEnabled = value;
    await PreferencesHelper.setReminderEnabled(value);
    await _syncMealReminders();
    await _syncForCurrentUser();
    notifyListeners();
    return true;
  }

  /// Rebuilds OS alarms after startup or after notification permission changes.
  Future<void> refreshMealReminders() => _syncMealReminders();

  Future<void> disableReminderAfterPermissionDenied() async {
    _isMealReminderEnabled = false;
    await PreferencesHelper.setReminderEnabled(false);
    await NotificationService.instance.cancelAllReminders();
    await _syncForCurrentUser();
    notifyListeners();
  }

  Future<void> _syncMealReminders() async {
    final meals = await MealRepository().getAllMeals();
    await NotificationService.instance.syncMealReminders(
      meals,
      enabled: _isMealReminderEnabled,
    );
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    await PreferencesHelper.setThemeMode(value.name);
    await PreferencesHelper.setDarkMode(value == ThemeMode.dark);
    await _syncForCurrentUser();
    notifyListeners();
  }

  // Keep the previous settings API available to older callers.
  Future<void> toggleDarkMode(bool value) =>
      setThemeMode(value ? ThemeMode.dark : ThemeMode.light);

  ThemeMode _themeModeFromString(String value) => switch (value) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

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
