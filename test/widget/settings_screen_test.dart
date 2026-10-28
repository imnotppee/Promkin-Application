import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/screens/settings_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
  });

  testWidgets('SettingsScreen renders profile, budget, and preference toggles', (tester) async {
    final settingsProvider = SettingsProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ตั้งค่าระบบ & งบประมาณ'), findsOneWidget);
    expect(find.text('คุณพิมพ์ชนก'), findsOneWidget);
    expect(find.text('งบประมาณต่อเดือน'), findsOneWidget);
    expect(find.text('เป้าหมายแคลอรีต่อวัน'), findsOneWidget);

    final darkTile = find.widgetWithText(SwitchListTile, 'โหมดมืด (Dark Mode)');
    await tester.dragUntilVisible(
      darkTile,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    await tester.tap(darkTile);
    await tester.pumpAndSettle();

    expect(settingsProvider.isDarkMode, isTrue);
  });
}

