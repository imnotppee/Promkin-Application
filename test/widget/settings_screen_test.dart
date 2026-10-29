import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/screens/settings_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
  });

  testWidgets(
    'SettingsScreen renders profile, budget, and preference toggles',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final settingsProvider = SettingsProvider();
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Promkin User'), findsWidgets);

      // Select dark mode from the theme mode dialog.
      final themeField = find.text('ตามอุปกรณ์ (System default)');
      expect(themeField, findsOneWidget);
      await tester.tap(themeField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('โหมดมืด (Dark)'));
      await tester.pumpAndSettle();
      expect(settingsProvider.isDarkMode, isTrue);

      // Switch to meal preferences tab
      await tester.tap(find.text('แผนอาหาร'));
      await tester.pumpAndSettle();
      expect(find.text('งบประมาณรายวัน'), findsWidgets);

      // Switch back to account tab and tap edit to navigate to ProfileScreen
      await tester.tap(find.text('แอป & บัญชี'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.text('โปรไฟล์ผู้ใช้'), findsOneWidget);
    },
  );

  testWidgets('saving a numeric setting closes its dialog safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settingsProvider = SettingsProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('แผนอาหาร'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('งบประมาณรายวัน'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '250');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    expect(settingsProvider.dailyBudget, 250);
    expect(find.text('บันทึกค่าเรียบร้อย'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
