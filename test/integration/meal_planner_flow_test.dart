import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/nutrition/presentation/nutrition_provider.dart';

void main() {
  group('Meal Planner Flow Integration Tests', () {
    test(
      'End-to-End Meal Addition -> Budget Spent -> Nutrition Recalculation Flow',
      () async {
        // 1. Initialize repository and providers with clean test state
        final repository = MealRepository();
        final mealProvider = MealProvider(
          repository: repository,
          initDemoMeals: false,
        );
        final nutritionProvider = NutritionProvider();

        final testDate = DateTime(2026, 10, 28);
        mealProvider.setSelectedDate(testDate);

        // 2. Add Breakfast
        final breakfast = MealModel(
          id: 'flow_1',
          name: 'ข้าวไข่เจียวหมูสับ',
          mealType: 'มื้อเช้า',
          price: 45.0,
          calories: 420,
          protein: 15.0,
          carbs: 45.0,
          fat: 18.0,
          date: '2026-10-28',
        );
        await mealProvider.addMeal(breakfast);

        // 3. Add Lunch
        final lunch = MealModel(
          id: 'flow_2',
          name: 'สุกี้น้ำไก่',
          mealType: 'มื้อกลางวัน',
          price: 55.0,
          calories: 350,
          protein: 26.0,
          carbs: 35.0,
          fat: 8.0,
          date: '2026-10-28',
        );
        await mealProvider.addMeal(lunch);

        // 4. Verify Total Spent Calculation
        expect(mealProvider.totalSpentToday, 100.0);
        expect(mealProvider.totalCaloriesToday, 770);
        expect(mealProvider.meals.length, 2);

        // 5. Verify Nutrition Summary Flow
        final summary = nutritionProvider.calculateSummary(
          meals: mealProvider.meals,
          targetCalories: 2000,
        );
        expect(summary.totalCalories, 770);
        expect(summary.totalProtein, 41.0);
        expect(summary.totalCarbs, 80.0);
        expect(summary.totalFat, 26.0);

        // 6. Complete Breakfast and verify state change
        await mealProvider.toggleMealCompletion(breakfast);
        final updatedBreakfast = mealProvider.meals.firstWhere(
          (m) => m.id == 'flow_1',
        );
        expect(updatedBreakfast.isCompleted, isTrue);

        // 7. Remove Lunch
        await mealProvider.removeMeal('flow_2');
        expect(mealProvider.meals.length, 1);
        expect(mealProvider.totalSpentToday, 45.0);
      },
    );
  });
}
