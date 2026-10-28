import 'package:flutter/material.dart';
import 'package:promkin_app/features/nutrition/data/nutrition_model.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';

class NutritionProvider extends ChangeNotifier {
  NutritionSummary calculateSummary({
    required List<MealModel> meals,
    required int targetCalories,
  }) {
    final totalCalories = meals.fold(0, (sum, m) => sum + m.calories);
    final totalProtein = meals.fold(0.0, (sum, m) => sum + m.protein);
    final totalCarbs = meals.fold(0.0, (sum, m) => sum + m.carbs);
    final totalFat = meals.fold(0.0, (sum, m) => sum + m.fat);

    // Standard macronutrient distribution guideline
    final targetProtein = (targetCalories * 0.25) / 4; // 25% protein (4 kcal/g)
    final targetCarbs = (targetCalories * 0.50) / 4; // 50% carbs (4 kcal/g)
    final targetFat = (targetCalories * 0.25) / 9; // 25% fat (9 kcal/g)

    return NutritionSummary(
      totalCalories: totalCalories,
      targetCalories: targetCalories,
      totalProtein: totalProtein,
      targetProtein: targetProtein,
      totalCarbs: totalCarbs,
      targetCarbs: targetCarbs,
      totalFat: totalFat,
      targetFat: targetFat,
    );
  }
}
