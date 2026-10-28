import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/widgets/meal_card.dart';

void main() {
  group('MealCard Widget Tests', () {
    testWidgets('renders meal information correctly', (
      WidgetTester tester,
    ) async {
      final meal = MealModel(
        id: '1',
        name: 'ข้าวผัดกระเพรา',
        mealType: 'มื้อกลางวัน',
        price: 55.0,
        calories: 520,
        protein: 25.0,
        carbs: 60.0,
        fat: 12.0,
        date: '2026-10-28',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MealCard(meal: meal)),
        ),
      );

      // Verify meal name, type, and calories display
      expect(find.text('ข้าวผัดกระเพรา'), findsOneWidget);
      expect(find.text('มื้อกลางวัน'), findsOneWidget);
      expect(find.text('฿55.00'), findsOneWidget);
      expect(find.text('520 kcal'), findsOneWidget);
    });

    testWidgets('calls onToggle callback when status button is clicked', (
      WidgetTester tester,
    ) async {
      bool toggled = false;
      final meal = MealModel(
        id: '1',
        name: 'สลัดผัก',
        mealType: 'มื้อเย็น',
        price: 45.0,
        calories: 180,
        date: '2026-10-28',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealCard(meal: meal, onToggle: () => toggled = true),
          ),
        ),
      );

      final iconBtn = find.byIcon(Icons.radio_button_unchecked);
      expect(iconBtn, findsOneWidget);

      await tester.tap(iconBtn);
      await tester.pump();

      expect(toggled, isTrue);
    });
  });
}
