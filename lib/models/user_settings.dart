class UserSettings {
  final String userId;
  final double dailyBudget;
  final int mealsPerDay;
  final int? calorieTarget;
  final String? foodType;
  final String? excludedFoods;

  const UserSettings({
    required this.userId,
    this.dailyBudget = 100,
    this.mealsPerDay = 3,
    this.calorieTarget,
    this.foodType,
    this.excludedFoods,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'daily_budget': dailyBudget,
      'meals_per_day': mealsPerDay,
      'calorie_target': calorieTarget,
      'food_type': foodType,
      'excluded_foods': excludedFoods,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['user_id'] as String,
      dailyBudget: (map['daily_budget'] as num).toDouble(),
      mealsPerDay: map['meals_per_day'] as int,
      calorieTarget: map['calorie_target'] as int?,
      foodType: map['food_type'] as String?,
      excludedFoods: map['excluded_foods'] as String?,
    );
  }
}
