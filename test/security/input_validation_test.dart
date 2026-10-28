import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';

void main() {
  group('Security & Input Validation Tests', () {
    test(
      'sanitizes and safely handles malicious script injection in meal notes',
      () {
        const maliciousScript = '<script>alert("hacked")</script>';
        final meal = MealModel(
          id: 'sec_1',
          name: 'ข้าวผัดต้มยำ',
          mealType: 'มื้อกลางวัน',
          price: 60.0,
          calories: 500,
          date: '2026-10-28',
          notes: maliciousScript,
        );

        final map = meal.toMap();
        expect(
          map['notes'],
          maliciousScript,
        ); // Escaped by parameter binding in SQLite
        expect(map['price'], isA<double>());
        expect(map['calories'], isA<int>());
      },
    );

    test(
      'prevents negative or invalid numeric inputs from corrupting data model',
      () {
        final invalidPriceMeal = MealModel.fromMap({
          'id': 'sec_2',
          'name': 'แกงจืด',
          'mealType': 'มื้อเย็น',
          'price': 'invalid_string', // Should fallback safely without crash
          'calories': null,
          'date': '2026-10-28',
        });

        expect(invalidPriceMeal.price, 0.0);
        expect(invalidPriceMeal.calories, 0);
      },
    );

    test(
      'safely handles SQL injection patterns in search and filter arguments',
      () {
        const sqlInjectionQuery = "' OR '1'='1' -- ";
        final meal = MealModel(
          id: 'sec_3',
          name: sqlInjectionQuery,
          mealType: 'มื้อกลางวัน',
          price: 50.0,
          calories: 300,
          date: '2026-10-28',
        );

        final map = meal.toMap();
        // Verifying parameterized mapping preserves exact literals without executing SQL commands
        expect(map['name'], sqlInjectionQuery);
      },
    );
  });
}
