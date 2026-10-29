// coverage:ignore-file

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules local reminders for planned meals on the device.
class NotificationService {
  static final NotificationService instance = NotificationService._init();

  // A new channel ID makes Android recreate this channel with audible defaults
  // instead of retaining a previously muted channel configuration.
  static const _channelId = 'meal_reminders_sound_v2';
  static const _channelName = 'แจ้งเตือนมื้ออาหาร';
  static const _channelDescription =
      'แจ้งเตือนเมื่อถึงเวลามื้ออาหารที่วางแผนไว้';
  static const _reminderSound = RawResourceAndroidNotificationSound(
    'meal_reminder',
  );
  static const _timeZone = 'Asia/Bangkok';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._init();

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_timeZone));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
            playSound: true,
            sound: _reminderSound,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          ),
        );
      }
    } catch (error) {
      debugPrint('Local notifications could not initialize: $error');
    } finally {
      _initialized = true;
    }
  }

  Future<bool> requestPermissions() async {
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      try {
        if (android == null) return false;
        final alreadyEnabled = await android.areNotificationsEnabled();
        if (alreadyEnabled == true) return true;
        final granted = await android.requestNotificationsPermission();
        if (granted == true) return true;
        // Some Android/plugin versions return null even when the OS prompt was
        // accepted, so verify the actual app notification setting afterward.
        return await android.areNotificationsEnabled() ?? false;
      } catch (error) {
        debugPrint('Notification permission request failed: $error');
        return false;
      }
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      try {
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      } catch (error) {
        debugPrint('Notification permission request failed: $error');
        return false;
      }
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      try {
        return await android?.areNotificationsEnabled() ?? false;
      } catch (error) {
        debugPrint('Could not read notification permission: $error');
        return false;
      }
    }
    return true;
  }

  Future<bool> canScheduleExactReminders() async {
    await init();
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      return await android?.canScheduleExactNotifications() ?? false;
    } catch (error) {
      debugPrint('Could not check exact alarm access: $error');
      return false;
    }
  }

  /// Opens Android's special access page when exact alarm access is missing.
  Future<bool> requestExactReminderAccess() async {
    await init();
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    try {
      if (await android.canScheduleExactNotifications() == true) return true;
      final result = await android.requestExactAlarmsPermission();
      return result ?? await android.canScheduleExactNotifications() ?? false;
    } catch (error) {
      debugPrint('Exact alarm access request failed: $error');
      return false;
    }
  }

  Future<void> syncMealReminders(
    List<MealModel> meals, {
    required bool enabled,
  }) async {
    await init();
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('Could not clear old meal reminders: $error');
      return;
    }
    if (!enabled) return;

    final now = DateTime.now();
    final upcoming =
        meals.where((meal) {
            if (meal.isCompleted) return false;
            final scheduled = _scheduledTime(meal);
            return scheduled != null && scheduled.isAfter(now);
          }).toList()
          ..sort((a, b) => _scheduledTime(a)!.compareTo(_scheduledTime(b)!));

    // Keep the OS alarm queue bounded while covering the upcoming meal plan.
    for (final meal in upcoming.take(60)) {
      await scheduleMealReminder(
        mealName: meal.name,
        time: _scheduledTime(meal)!,
        message: '${meal.mealType} เวลา ${meal.time} น. ถึงเวลามื้ออาหารแล้ว',
        mealId: meal.id,
      );
    }
  }

  Future<void> scheduleMealReminder({
    required String mealName,
    required DateTime time,
    required String message,
    String? mealId,
  }) async {
    await init();
    if (!time.isAfter(DateTime.now())) return;

    final id = _notificationId(mealId ?? '$mealName-${time.toIso8601String()}');
    final scheduled = tz.TZDateTime(
      tz.local,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );
    final exactAlarmsAllowed = await canScheduleExactReminders();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        playSound: true,
        sound: _reminderSound,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        'ถึงเวลามื้ออาหาร',
        '$mealName — $message',
        scheduled,
        details,
        androidScheduleMode: exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: mealId,
      );
    } catch (error) {
      debugPrint('Could not schedule reminder for $mealName: $error');
    }
  }

  Future<void> cancelMealReminder(String mealId) async {
    await init();
    try {
      await _plugin.cancel(_notificationId(mealId));
    } catch (error) {
      debugPrint('Could not cancel reminder for meal $mealId: $error');
    }
  }

  Future<void> cancelAllReminders() async {
    await init();
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('Could not cancel all meal reminders: $error');
    }
  }

  DateTime? _scheduledTime(MealModel meal) {
    try {
      final dateParts = meal.date.split('-').map(int.parse).toList();
      final timeParts = meal.time.split(':').map(int.parse).toList();
      if (dateParts.length != 3 || timeParts.length < 2) return null;
      return DateTime(
        dateParts[0],
        dateParts[1],
        dateParts[2],
        timeParts[0],
        timeParts[1],
      );
    } catch (_) {
      return null;
    }
  }

  int _notificationId(String value) {
    // Stable across app launches so editing a meal replaces its prior alarm.
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash ^ codeUnit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Meal reminder opened for meal ${response.payload ?? ''}');
  }
}
