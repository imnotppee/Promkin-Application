import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/home/presentation/screens/dashboard_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('th_TH', null);
  });

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders greeting, metrics cards, and week header', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MealRepository();
      final mealProv = MealProvider(repository: repo, initDemoMeals: true);
      final settingsProv = SettingsProvider();
      final authProv = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: mealProv),
            ChangeNotifierProvider.value(value: settingsProv),
            ChangeNotifierProvider.value(value: authProv),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check Greeting
      expect(find.text('สวัสดี, Promkin User ☀️'), findsOneWidget);

      // Check 3 Metric Cards
      expect(find.text('งบอาหารเดือนนี้'), findsOneWidget);
      expect(find.text('มื้อที่วางแผนแล้ว'), findsOneWidget);
      expect(find.text('ค่าเฉลี่ยต่อมื้อ'), findsOneWidget);

      // Check Sections
      expect(find.text('ตารางมื้ออาหารวันนี้'), findsOneWidget);
      expect(find.text('AI แนะนำเมนู'), findsOneWidget);

      // Week day selector navigation using chevron buttons
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
    });
  });
}
