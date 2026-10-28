import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/preferences_helper.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/meal_planner/presentation/meal_provider.dart';
import 'features/ai_recommendation/presentation/ai_provider.dart';
import 'features/nutrition/presentation/nutrition_provider.dart';
import 'features/settings_budget/presentation/settings_provider.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Cache & Storage
  await PreferencesHelper.init();

  // Initialize Firebase (gracefully falls back if offline or unconfigured)
  await FirebaseService.instance.initialize();

  runApp(const PromkinApp());
}

class PromkinApp extends StatelessWidget {
  const PromkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Promkin - วางแผนมื้ออาหาร',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
