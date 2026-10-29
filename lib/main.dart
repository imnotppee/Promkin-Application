import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final permissionGranted = await NotificationService.instance
        .areNotificationsEnabled();

    // Ask in-app on every launch. Android versions below 13 do not show a
    // system notification permission prompt, so this is the visible opt-in.
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
    if (enable != true) {
      if (settings.isMealReminderEnabled) {
        await settings.refreshMealReminders();
      }
      return;
    }
      final allowed = permissionGranted || await NotificationService.instance
          .requestPermissions();
      if (!context.mounted) return;
      if (allowed) {
        if (settings.isMealReminderEnabled) {
          await NotificationService.instance.requestExactReminderAccess();
          await settings.refreshMealReminders();
        } else {
          await settings.toggleReminder(true);
        }
      } else {
        await _showNotificationSettingsDialog(context, settings);
      }
  }

  Future<void> _showNotificationSettingsDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.notifications_off_outlined),
        title: const Text('เปิดการแจ้งเตือน'),
        content: const Text(
          'PromKin ยังไม่ได้รับอนุญาตให้ส่งการแจ้งเตือน '
          'กรุณาอนุญาตในการตั้งค่าอุปกรณ์ แล้วเปิดแจ้งเตือนมื้ออาหารในแอป',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ไว้ก่อน'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await const MethodChannel('promkin/notifications')
                    .invokeMethod<void>('openNotificationSettings');
              } on PlatformException catch (error) {
                debugPrint('Could not open notification settings: $error');
              }
              // If the OS settings page is not needed (e.g. Android 12), enable
              // reminders directly after the user explicitly opted in.
              final isAllowed = await NotificationService.instance
                  .areNotificationsEnabled();
              if (isAllowed) await settings.toggleReminder(true);
            },
            child: const Text('ไปตั้งค่า'),
          ),
        ],
      ),
    );
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
