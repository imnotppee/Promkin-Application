import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/weekly_planner_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('th_TH', null);
  });

  group('WeeklyPlannerScreen Widget Tests', () {
    testWidgets('renders 7 days list and navigates to day detail and back', (
      WidgetTester tester,
    ) async {
      final repo = MealRepository();
      final mealProv = MealProvider(repository: repo, initDemoMeals: true);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mealProv,
          child: const MaterialApp(home: WeeklyPlannerScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check App Bar Title
      expect(find.text('วางแผนมื้ออาหาร'), findsOneWidget);

      // Week navigation buttons
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Check 'ดูมื้ออาหาร' button is present
      final viewMealsBtns = find.text('ดูมื้ออาหาร');
      expect(viewMealsBtns, findsWidgets);

      // Tap on first 'ดูมื้ออาหาร'
      await tester.tap(viewMealsBtns.first);
      await tester.pumpAndSettle();

      // Check Day Detail screen
      expect(find.text('สรุปของวันนี้'), findsOneWidget);
      expect(find.text('＋ เพิ่มเมนูในวันนี้'), findsOneWidget);

      // Navigate back
      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('วางแผนมื้ออาหาร'), findsOneWidget);
    });
  });
}
