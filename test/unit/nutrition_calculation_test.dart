import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/nutrition/presentation/nutrition_provider.dart';

void main() {
  group('Nutrition Calculation Unit Tests', () {
    final provider = NutritionProvider();

    test('correctly calculates total calories and macros from meals list', () {
      final meals = [
        MealModel(
          id: '1',
          name: 'มื้อ 1',
          mealType: 'มื้อเช้า',
          price: 50,
          calories: 400,
          protein: 20,
          carbs: 50,
          fat: 10,
          date: '2026-10-28',
        ),
        MealModel(
          id: '2',
          name: 'มื้อ 2',
          mealType: 'มื้อกลางวัน',
          price: 60,
          calories: 600,
          protein: 30,
          carbs: 70,
          fat: 15,
          date: '2026-10-28',
        ),
      ];

      final summary = provider.calculateSummary(
        meals: meals,
        targetCalories: 2000,
      );

      expect(summary.totalCalories, 1000);
      expect(summary.totalProtein, 50.0);
      expect(summary.totalCarbs, 120.0);
      expect(summary.totalFat, 25.0);
      expect(summary.caloriesRatio, 0.5); // 1000 / 2000 = 50%
    });
  });
}
