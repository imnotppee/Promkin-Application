import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/nutrition/data/nutrition_model.dart';

void main() {
  group('NutritionSummary Unit Tests', () {
    test('calculates correct ratios when targets are positive', () {
      final summary = NutritionSummary(
        totalCalories: 1500,
        targetCalories: 2000,
        totalProtein: 60.0,
        targetProtein: 80.0,
        totalCarbs: 150.0,
        targetCarbs: 200.0,
        totalFat: 40.0,
        targetFat: 50.0,
      );

      expect(summary.caloriesRatio, closeTo(0.75, 0.01));
      expect(summary.proteinRatio, closeTo(0.75, 0.01));
      expect(summary.carbsRatio, closeTo(0.75, 0.01));
      expect(summary.fatRatio, closeTo(0.8, 0.01));
    });

    test('returns 0.0 when targets are zero or negative', () {
      final summary = NutritionSummary(
        totalCalories: 500,
        targetCalories: 0,
        totalProtein: 30.0,
        targetProtein: 0.0,
        totalCarbs: 50.0,
        targetCarbs: 0.0,
        totalFat: 20.0,
        targetFat: 0.0,
      );

      expect(summary.caloriesRatio, 0.0);
      expect(summary.proteinRatio, 0.0);
      expect(summary.carbsRatio, 0.0);
      expect(summary.fatRatio, 0.0);
    });

    test('clamps ratios to 1.0 when exceeding targets', () {
      final summary = NutritionSummary(
        totalCalories: 3000,
        targetCalories: 2000,
        totalProtein: 120.0,
        targetProtein: 80.0,
        totalCarbs: 300.0,
        targetCarbs: 200.0,
        totalFat: 100.0,
        targetFat: 50.0,
      );

      expect(summary.caloriesRatio, 1.0);
      expect(summary.proteinRatio, 1.0);
      expect(summary.carbsRatio, 1.0);
      expect(summary.fatRatio, 1.0);
    });
  });
}
