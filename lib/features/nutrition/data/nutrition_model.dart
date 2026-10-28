class NutritionSummary {
  final int totalCalories;
  final int targetCalories;
  final double totalProtein;
  final double targetProtein;
  final double totalCarbs;
  final double targetCarbs;
  final double totalFat;
  final double targetFat;

  NutritionSummary({
    required this.totalCalories,
    required this.targetCalories,
    required this.totalProtein,
    required this.targetProtein,
    required this.totalCarbs,
    required this.targetCarbs,
    required this.totalFat,
    required this.targetFat,
  });

  double get caloriesRatio => targetCalories > 0
      ? (totalCalories / targetCalories).clamp(0.0, 1.0)
      : 0.0;
  double get proteinRatio =>
      targetProtein > 0 ? (totalProtein / targetProtein).clamp(0.0, 1.0) : 0.0;
  double get carbsRatio =>
      targetCarbs > 0 ? (totalCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;
  double get fatRatio =>
      targetFat > 0 ? (totalFat / targetFat).clamp(0.0, 1.0) : 0.0;
}
