import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/home/presentation/screens/dashboard_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('th_TH', null);
  });

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders greeting, metrics cards, and week header', (
      WidgetTester tester,
    ) async {
      final repo = MealRepository();
      final mealProv = MealProvider(repository: repo, initDemoMeals: true);
      final settingsProv = SettingsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: mealProv),
            ChangeNotifierProvider.value(value: settingsProv),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check Brand in RichText
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('PROM KIN'),
        ),
        findsOneWidget,
      );

      // Check Greeting
      expect(find.text('สวัสดี, พิมพ์ชนก '), findsOneWidget);

      // Check 3 Metric Cards
      expect(find.text('งบอาหารเดือนนี้'), findsOneWidget);
      expect(find.text('มื้อที่วางแผนแล้ว'), findsOneWidget);
      expect(find.text('ค่าเฉลี่ยต่อมื้อ'), findsOneWidget);

      // Check Plan Header
      expect(find.text('แผนมื้ออาหาร'), findsOneWidget);
      expect(find.text('AI เมนูแนะนำ'), findsOneWidget);
      expect(find.text('โภชนาการวันนี้'), findsOneWidget);

      // Week day selector navigation using ‹ and ›
      await tester.tap(find.text('‹'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('›'));
      await tester.pumpAndSettle();
    });
  });
}
