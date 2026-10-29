import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';

void main() {
  group('MealModel Unit Tests', () {
    test('should correctly convert to and from Map', () {
      final meal = MealModel(
        id: 'test_1',
        name: 'ข้าวผัดปู',
        mealType: 'มื้อกลางวัน',
        price: 80.0,
        calories: 550,
        protein: 22.0,
        carbs: 65.0,
        fat: 14.0,
        date: '2026-10-28',
        isCompleted: true,
        notes: 'ไม่ใส่ผักชี',
      );

      final map = meal.toMap();
      final recreated = MealModel.fromMap(map);

      expect(recreated.id, 'test_1');
      expect(recreated.name, 'ข้าวผัดปู');
      expect(recreated.mealType, 'มื้อกลางวัน');
      expect(recreated.price, 80.0);
      expect(recreated.calories, 550);
      expect(recreated.protein, 22.0);
      expect(recreated.carbs, 65.0);
      expect(recreated.fat, 14.0);
      expect(recreated.date, '2026-10-28');
      expect(recreated.isCompleted, isTrue);
      expect(recreated.notes, 'ไม่ใส่ผักชี');
    });

    test('copyWith should properly update fields', () {
      final meal = MealModel(
        id: '1',
        name: 'ต้มยำกุ้ง',
        mealType: 'มื้อเย็น',
        price: 120.0,
        calories: 300,
        date: '2026-10-28',
      );

      final updated = meal.copyWith(isCompleted: true, price: 150.0);

      expect(updated.id, '1');
      expect(updated.name, 'ต้มยำกุ้ง');
      expect(updated.price, 150.0);
      expect(updated.isCompleted, isTrue);
    });

    test('toFirestoreMap should correctly map fields and meal types', () {
      final types = [
        'มื้อเช้า',
        'มื้อกลางวัน',
        'มื้อเย็น',
        'ของว่าง',
        'custom',
      ];
      final expectedTypes = ['breakfast', 'lunch', 'dinner', 'snack', 'custom'];

      for (int i = 0; i < types.length; i++) {
        final meal = MealModel(
          id: 'meal_$i',
          name: 'เมนู $i',
          mealType: types[i],
          price: 50.0,
          calories: 400,
          date: '2026-10-29',
          time: '08:30',
        );

        final firestoreMap = meal.toFirestoreMap(
          mealPlanId: 'plan_123',
          source: 'manual',
          sourceId: 'src_456',
        );

        expect(firestoreMap['meal_plan_id'], 'plan_123');
        expect(firestoreMap['source'], 'manual');
        expect(firestoreMap['source_id'], 'src_456');
        expect(firestoreMap['recipe_name'], 'เมนู $i');
        expect(firestoreMap['meal_type'], expectedTypes[i]);
        expect(firestoreMap['estimated_cost'], 50.0);
        expect(firestoreMap['calories'], 400);
      }
    });
  });
}
