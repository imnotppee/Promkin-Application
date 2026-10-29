import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';

void main() {
  group('MealProvider Unit Tests', () {
    test(
      'initializes, adds meals, calculates macros, toggles and removes meals',
      () async {
        final repo = MealRepository();
        final provider = MealProvider(repository: repo, initDemoMeals: false);

        final now = DateTime.now();
        provider.setSelectedDate(now);
        expect(provider.selectedDate.year, now.year);

        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        final testMeal = MealModel(
          id: 'test_m1',
          name: 'ข้าวผัดอกไก่',
          mealType: 'มื้อกลางวัน',
          date: dateStr,
          time: '12:00',
          price: 55.0,
          calories: 420,
          protein: 30.0,
          carbs: 50.0,
          fat: 10.0,
        );

        // Add meal
        await provider.addMeal(testMeal);
        expect(provider.meals.length, 1);
        expect(provider.allMeals.length, 1);
        expect(provider.meals.first.name, 'ข้าวผัดอกไก่');
        expect(provider.totalSpentToday, 55.0);
        expect(provider.totalCaloriesToday, 420);
        expect(provider.totalProteinToday, 30.0);
        expect(provider.totalCarbsToday, 50.0);
        expect(provider.totalFatToday, 10.0);

        // Toggle completion
        await provider.toggleMealCompletion(testMeal);
        expect(provider.meals.first.isCompleted, isTrue);

        // Remove meal
        await provider.removeMeal('test_m1');
        expect(provider.meals.isEmpty, isTrue);
        expect(provider.totalSpentToday, 0.0);
        expect(provider.totalCaloriesToday, 0);

        // Dispose
        provider.dispose();
      },
    );
  });
}
