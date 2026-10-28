import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/widgets/add_to_plan_dialog.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('th_TH', null);
  });

  group('AddToPlanDialog Widget Tests', () {
    testWidgets('renders recipe name, emoji, and adds meal to provider', (
      WidgetTester tester,
    ) async {
      final repo = MealRepository();
      final mealProvider = MealProvider(repository: repo, initDemoMeals: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AddToPlanDialog.show(
                      context,
                      recipeName: 'สุกี้น้ำไก่',
                      emoji: '🍲',
                      price: 50.0,
                      calories: 360,
                      mealProvider: mealProvider,
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open Dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify Dialog UI
      expect(find.text('เพิ่มเมนูลงในแผน'), findsOneWidget);
      expect(find.text('สุกี้น้ำไก่ · ฿50'), findsOneWidget);
      expect(find.text('🍲'), findsOneWidget);

      // Confirm Addition
      final confirmBtn = find.text('เพิ่มในแผน');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('เพิ่มเมนูลงในแผน'), findsNothing);
    });
  });
}

