class AppConstants {
  // Database
  static const String databaseName = 'promkin.db';
  static const int databaseVersion = 1;

  // Defaults
  static const double defaultDailyBudget = 300.0; // 300 THB/day
  static const int defaultDailyCalories = 2000; // 2000 kcal
  static const int defaultMealsPerDay = 3;

  // Shared Preferences Keys
  static const String keyDailyBudget = 'pref_daily_budget';
  static const String keyDailyCalories = 'pref_daily_calories';
  static const String keyMealsPerDay = 'pref_meals_per_day';
  static const String keyDarkMode = 'pref_dark_mode';
  static const String keyMealReminder = 'pref_meal_reminder';
  static const String keyDietaryPreferences = 'pref_dietary_preferences';
  static const String keyDislikedIngredients = 'pref_disliked_ingredients';
}
