import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';

void main() {
  group('MealRepository Unit Tests', () {
    test(
      'saveMeal, getMealsByDate, getAllMeals and deleteMeal work with in-memory store',
      () async {
        final repo = MealRepository();

        final meal1 = MealModel(
          id: 'm1',
          name: 'ข้าวผัดไข่',
          mealType: 'มื้อเช้า',
          date: '2026-10-29',
          time: '08:00',
          calories: 350,
          price: 40.0,
        );

        final meal2 = MealModel(
          id: 'm2',
          name: 'ต้มยำกุ้ง',
          mealType: 'มื้อกลางวัน',
          date: '2026-10-29',
          time: '12:30',
          calories: 280,
          price: 80.0,
        );

        final meal3 = MealModel(
          id: 'm3',
          name: 'สลัดอกไก่',
          mealType: 'มื้อเย็น',
          date: '2026-10-30',
          time: '18:00',
          calories: 220,
          price: 55.0,
        );

        // Save meals
        await repo.saveMeal(meal1);
        await repo.saveMeal(meal2);
        await repo.saveMeal(meal3);

        // Get meals for date 2026-10-29
        final mealsToday = await repo.getMealsByDate('2026-10-29');
        expect(mealsToday.length, 2);
        expect(mealsToday.any((m) => m.name == 'ข้าวผัดไข่'), isTrue);
        expect(mealsToday.any((m) => m.name == 'ต้มยำกุ้ง'), isTrue);

        // Get all meals
        final allMeals = await repo.getAllMeals();
        expect(allMeals.length, 3);

        // Delete meal1
        await repo.deleteMeal('m1');
        final mealsAfterDelete = await repo.getMealsByDate('2026-10-29');
        expect(mealsAfterDelete.length, 1);
        expect(mealsAfterDelete.first.name, 'ต้มยำกุ้ง');

        final allAfterDelete = await repo.getAllMeals();
        expect(allAfterDelete.length, 2);
      },
    );
  });
}
