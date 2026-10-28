class BudgetSettingsModel {
  final double dailyBudget;
  final int dailyCalories;
  final int mealsPerDay;
  final bool isMealReminderEnabled;
  final List<String> dislikedIngredients;

  BudgetSettingsModel({
    required this.dailyBudget,
    required this.dailyCalories,
    required this.mealsPerDay,
    required this.isMealReminderEnabled,
    this.dislikedIngredients = const [],
  });
}
