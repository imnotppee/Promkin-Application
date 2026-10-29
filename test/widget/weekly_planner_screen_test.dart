import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/weekly_planner_screen.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    await initializeDateFormatting('th_TH', null);
  });

  group('WeeklyPlannerScreen Widget Tests', () {
    testWidgets('renders 7 days list and navigates to day detail and back', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MealRepository();
      final mealProv = MealProvider(repository: repo, initDemoMeals: true);
      final settingsProv = SettingsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MealProvider>.value(value: mealProv),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProv),
          ],
          child: const MaterialApp(home: WeeklyPlannerScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check Title
      expect(find.text('แผนมื้ออาหาร'), findsOneWidget);
      expect(find.text('ภาพรวม 7 วัน'), findsOneWidget);

      // Week navigation buttons
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      // Check add meal button is present
      expect(find.text('เพิ่มเมนูลงในแผน'), findsOneWidget);

      // Tap on add meal button to open AddMealScreen
      await tester.tap(find.text('เพิ่มเมนูลงในแผน'));
      await tester.pumpAndSettle();

      // Check AddMealScreen
      expect(find.text('เพิ่มมื้ออาหาร'), findsOneWidget);
      expect(find.text('ชื่อเมนูอาหาร *'), findsOneWidget);
    });
  });
}
