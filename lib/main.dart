import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/core/services/firebase_service.dart';
import 'package:promkin_app/core/services/notification_service.dart';
import 'package:promkin_app/core/theme/app_theme.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/ai_provider.dart';
import 'package:promkin_app/features/nutrition/presentation/nutrition_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/login_screen.dart';
import 'package:promkin_app/features/home/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Thai Locale for Date & Time Formatting
  await initializeDateFormatting('th_TH', null);

  // Initialize SQLite FFI for Desktop platforms (Windows / macOS / Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Local Cache & Storage
  await PreferencesHelper.init();

  // Initialize Firebase (gracefully falls back if offline or unconfigured)
  await FirebaseService.instance.initialize();

  // Initialize notifications before widgets are created. Runtime permission
  // prompts must wait until the Android activity and first screen are ready.
  await NotificationService.instance.init();

  runApp(const PromkinApp());
}

class PromkinApp extends StatefulWidget {
  const PromkinApp({super.key});

  @override
  State<PromkinApp> createState() => _PromkinAppState();
}

class _PromkinAppState extends State<PromkinApp> {
  bool _startupReminderChecked = false;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context != null) _checkStartupReminders(context);
    });
  }

  Future<void> _checkStartupReminders(BuildContext context) async {
    if (_startupReminderChecked) return;
    _startupReminderChecked = true;
    final settings = context.read<SettingsProvider>();

    // Ask for notification opt-in only once. After the first answer, access is
    // managed explicitly from Meal plan settings.
    if (PreferencesHelper.hasHandledNotificationPrompt()) {
      if (!settings.isMealReminderEnabled) return;
      final permissionGranted = await NotificationService.instance
          .areNotificationsEnabled();
      if (permissionGranted) await settings.refreshMealReminders();
      return;
    }

    final permissionGranted = await NotificationService.instance
        .areNotificationsEnabled();

    if (!context.mounted) return;
    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined),
        title: const Text('แจ้งเตือนมื้ออาหาร'),
        content: Text(
          settings.isMealReminderEnabled
              ? 'การแจ้งเตือนมื้ออาหารเปิดอยู่ ต้องการซิงก์การเตือนของคุณตอนนี้ไหม? '
                    'ระบบจะขอสิทธิ์ตั้งปลุกเพื่อให้เตือนได้ตรงเวลา'
              : 'ต้องการให้ PromKin เตือนเมื่อถึงเวลามื้ออาหารที่วางแผนไว้ไหม? '
                    'ระบบจะขอสิทธิ์ตั้งปลุกเพื่อให้เตือนได้ตรงเวลา',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ไว้ก่อน'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('เปิดการแจ้งเตือน'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;

    // Persist either answer before requesting OS access so an app restart or
    // permission denial cannot make the same question appear again.
    await PreferencesHelper.setNotificationPromptHandled(true);

    // Wait until the dialog overlay has fully unmounted before a provider
    // notification rebuilds inherited widgets.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;

    if (enable != true) {
      await settings.disableReminderAfterPermissionDenied();
      return;
    }

    final allowed =
        permissionGranted ||
        await NotificationService.instance.requestPermissions();
    if (!context.mounted) return;
    if (!allowed) {
      await settings.disableReminderAfterPermissionDenied();
      return;
    }

    await NotificationService.instance.requestExactReminderAccess();
    if (settings.isMealReminderEnabled) {
      await settings.refreshMealReminders();
    } else {
      await settings.toggleReminder(true);
    }
  }

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
      child: Selector<SettingsProvider, ThemeMode>(
        selector: (context, settings) => settings.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Promkin - วางแผนมื้ออาหาร',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) => auth.isAuthenticated
                  ? const MainNavigationScreen()
                  : const LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}
