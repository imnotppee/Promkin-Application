import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/add_meal_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
  });

  testWidgets('AddMealScreen renders form fields and saves a meal', (
    tester,
  ) async {
    final mealProvider = MealProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<MealProvider>.value(
        value: mealProvider,
        child: MaterialApp(home: AddMealScreen(date: DateTime(2026, 10, 28))),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('เพิ่มมื้ออาหาร'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);

    // Enter meal details
    await tester.enterText(find.byType(TextFormField).at(0), 'ข้าวผัดกุ้ง');
    await tester.enterText(find.byType(TextFormField).at(1), '65');
    await tester.enterText(find.byType(TextFormField).at(2), '550');

    // Scroll to save button and tap
    final saveButton = find.text('บันทึกมื้ออาหาร');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(mealProvider.meals.any((m) => m.name == 'ข้าวผัดกุ้ง'), isTrue);
  });
}
