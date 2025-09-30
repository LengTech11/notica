import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialized in the `main` function
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

/// Initialize the global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  // For mobile platforms, we'll use the system's local timezone
  tz.setLocalLocation(tz.local);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  int id = 0;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔔 Notification service already initialized');
      return;
    }

    try {
      debugPrint('🔔 Initializing notification service...');

      await _configureLocalTimeZone();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');

      final List<DarwinNotificationCategory> darwinNotificationCategories =
          <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          darwinNotificationCategoryText,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text(
              'text_1',
              'Action 1',
              buttonTitle: 'Send',
              placeholder: 'Placeholder',
            ),
          ],
        ),
        DarwinNotificationCategory(
          darwinNotificationCategoryPlain,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2 (destructive)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              navigationActionId,
              'Action 3 (foreground)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
        )
      ];

      /// Request permissions during initialization for better UX
      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBanner: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
        notificationCategories: darwinNotificationCategories,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: selectNotificationStream.add,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      debugPrint('🔔 Plugin initialized');

      // Check if app was launched from notification
      await _checkNotificationLaunchDetails();

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('🔔 Notification service fully initialized');
    } catch (e) {
      debugPrint('🔔 Error initializing notification service: $e');
      rethrow;
    }
  }

  /// Check if the app was launched from a notification
  Future<void> _checkNotificationLaunchDetails() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      debugPrint(
          '🔔 App launched from notification with payload: $selectedNotificationPayload');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      debugPrint(
          '🔔 Android notification permission granted: $grantedNotificationPermission');
    }
  }

  /// Schedule a notification for a reminder
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel any existing notification for this reminder
    await cancelNotification(reminder.id.hashCode);

    // Don't schedule if reminder is not active or already completed
    if (!reminder.isActive || reminder.isCompleted) {
      return;
    }

    // Create notification details based on priority
    final importance = reminder.priority == ReminderPriority.high
        ? Importance.max
        : reminder.priority == ReminderPriority.normal
            ? Importance.high
            : Importance.defaultImportance;

    final priority = reminder.priority == ReminderPriority.high
        ? Priority.max
        : reminder.priority == ReminderPriority.normal
            ? Priority.high
            : Priority.defaultPriority;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_notifications',
      'Reminders',
      channelDescription: 'Notica reminder notifications',
      importance: importance,
      priority: priority,
      showWhen: true,
      styleInformation: BigTextStyleInformation(
        reminder.description.isNotEmpty
            ? reminder.description
            : 'Tap to view reminder details',
        contentTitle: reminder.title,
      ),
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Convert to TZDateTime for proper scheduling
    final tzScheduledDate =
        tz.TZDateTime.from(reminder.scheduledTime, tz.local);

    // Create notification content
    String notificationBody = reminder.description.isNotEmpty
        ? reminder.description
        : 'Reminder: ${reminder.title}';

    if (reminder.frequency != ReminderFrequency.once) {
      notificationBody += ' • ${reminder.frequencyText}';
    }

    DateTimeComponents? dateTimeComponents;
    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        dateTimeComponents = DateTimeComponents.time;
        break;
      case ReminderFrequency.weekly:
        dateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
      default:
        dateTimeComponents = null; // One-time notification
        break;
    }

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      '${reminder.priorityIcon.toString().contains('high') ? '🚨 ' : '🔔 '}${reminder.title}',
      notificationBody,
      tzScheduledDate,
      platformChannelSpecifics,
      payload: reminder.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: dateTimeComponents,
    );

    final timeString =
        '${reminder.scheduledTime.hour.toString().padLeft(2, '0')}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}';
    debugPrint(
      'Scheduled notification for reminder: ${reminder.title} at $timeString (${reminder.frequencyText})',
    );
  }

  /// Legacy method for backward compatibility
  Future<void> scheduleHabitNotification(dynamic habit) async {
    // Convert habit to reminder and schedule
    debugPrint(
        '⚠️ Using legacy scheduleHabitNotification - consider migrating to scheduleReminderNotification');

    if (habit != null) {
      final reminder = Reminder(
        id: habit.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: habit.name ?? 'Reminder',
        scheduledTime: DateTime.now().add(Duration(
          hours: habit.reminderTime?.hour ?? 9,
          minutes: habit.reminderTime?.minute ?? 0,
        )),
        frequency: ReminderFrequency.daily,
        createdAt: DateTime.now(),
      );

      await scheduleReminderNotification(reminder);
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  /// Cancel all notifications for a reminder
  Future<void> cancelReminderNotifications(String reminderId) async {
    await cancelNotification(reminderId.hashCode);
  }

  /// Legacy method for backward compatibility
  Future<void> cancelHabitNotifications(String habitId) async {
    await cancelNotification(habitId.hashCode);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Check if notifications are enabled using native iOS method
  Future<bool> areNotificationsEnabled() async {
    try {
      // Use iOS native permission checking
      final iOSImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSImplementation != null) {
        final hasPermissions = await iOSImplementation.checkPermissions();
        debugPrint('🔔 iOS Native permission check: $hasPermissions');

        // Check if any of the main permissions are granted
        final isEnabled = hasPermissions?.isEnabled == true;
        debugPrint('🔔 Notifications enabled (native): $isEnabled');
        return isEnabled;
      }

      // For Android, check using the plugin
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final enabled = await androidImplementation.areNotificationsEnabled();
        debugPrint('🔔 Android notifications enabled: $enabled');
        return enabled ?? false;
      }

      return false;
    } catch (e) {
      debugPrint('🔔 Error checking permissions: $e');
      return false;
    }
  }

  /// Open app settings for user to manually enable notifications
  Future<void> openNotificationSettings() async {
    // Platform-specific implementation would be needed here
    // For now, we'll just log
    debugPrint(
        '🔔 Open notification settings (implement platform-specific code)');
  }

  /// Comprehensive notification diagnostic
  Future<void> runNotificationDiagnostic() async {
    debugPrint('🔔 🔍 NOTIFICATION DIAGNOSTIC STARTING...');
    debugPrint('🔔 ================================================');

    try {
      // Check initialization
      debugPrint('🔔 1️⃣ Initialization Status: $_isInitialized');

      if (!_isInitialized) {
        debugPrint('🔔 🔄 Initializing service...');
        await initialize();
        debugPrint('🔔 ✅ Service initialized: $_isInitialized');
      }

      // Check permissions
      debugPrint('🔔 2️⃣ Checking Permissions...');
      final hasPermissions = await areNotificationsEnabled();
      debugPrint('🔔 📋 Permission Status: $hasPermissions');

      if (Platform.isIOS) {
        final iOSImplementation = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iOSImplementation != null) {
          final permissions = await iOSImplementation.checkPermissions();
          debugPrint('🔔 📱 iOS Detailed Permissions:');
          debugPrint('🔔    - Enabled: ${permissions?.isEnabled}');
          debugPrint('🔔    - All permissions: $permissions');
        }
      }

      // Check pending notifications
      debugPrint('🔔 3️⃣ Checking Pending Notifications...');
      final pending = await getPendingNotifications();
      debugPrint('🔔 📅 Pending Notifications: ${pending.length}');
      for (final notification in pending) {
        debugPrint(
            '🔔    - ID: ${notification.id}, Title: ${notification.title}');
      }

      // Test immediate notification
      debugPrint('🔔 4️⃣ Testing Immediate Notification...');
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'diagnostic_channel',
        'Diagnostic Notifications',
        channelDescription: 'Diagnostic test notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final testId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await flutterLocalNotificationsPlugin.show(
        testId,
        '🔍 DIAGNOSTIC TEST',
        'If you see this, notifications are working! ✅',
        details,
        payload: 'diagnostic_test',
      );

      debugPrint('🔔 ✅ Diagnostic notification sent with ID: $testId');
      debugPrint('🔔 ================================================');
      debugPrint(
          '🔔 🔍 DIAGNOSTIC COMPLETE - Check your device for the test notification!');
    } catch (e) {
      debugPrint('🔔 ❌ DIAGNOSTIC ERROR: $e');
      debugPrint('🔔 ================================================');
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body) async {
    try {
      debugPrint('🔔 Starting notification test...');
      debugPrint('🔔 📱 Forcing real notification in emulator...');

      if (!_isInitialized) {
        debugPrint('🔔 Initializing notification service...');
        await initialize();
      }

      debugPrint('🔔 Service initialized: $_isInitialized');

      // Force refresh permissions - don't rely on cached status
      debugPrint('🔔 🔄 Refreshing permission status...');
      final hasPermission = await areNotificationsEnabled();
      debugPrint('🔔 Fresh permission check: $hasPermission');

      if (!hasPermission) {
        debugPrint('🔔 ⚠️ Permissions appear disabled - but sending anyway');
        debugPrint(
            '🔔 💡 If you enabled notifications in Settings, they should work');
      } else {
        debugPrint(
            '🔔 ✅ Permissions confirmed - notifications should work perfectly!');
      }
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'test_notifications',
        'Test Notifications',
        channelDescription: 'Test notifications for debugging',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true, // Force banner even when app is open
        presentSound: true, // Enable sound
        presentBadge: true, // Enable badge
        threadIdentifier: 'habit_tracker',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
            100000,
          );
      debugPrint('🔔 Sending notification with ID: $notificationId');

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
      );

      debugPrint('🔔 Notification sent successfully!');
    } catch (e) {
      debugPrint('🔔 Error sending notification: $e');
      rethrow;
    }
  }

  /// Show plain notification with payload
  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  /// Test notification that should appear in 5 seconds
  Future<void> showTestNotificationIn5Seconds() async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications for debugging',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    debugPrint('🔔 Scheduling test notification for: $scheduledTime');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999, // Test notification ID
      '🧪 Test Notification',
      'This notification was scheduled 5 seconds ago! If you see this, notifications work! 🎉',
      scheduledTime,
      notificationDetails,
      payload: 'test_notification',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('🔔 Test notification scheduled successfully!');
  }

  /// Show a highly visible test notification (forces foreground display)
  Future<void> showVisibleTestNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'test_visible',
      'Visible Test Notifications',
      channelDescription: 'Highly visible test notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      autoCancel: false, // Don't auto-dismiss
      ongoing: false,
      fullScreenIntent: false,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.active, // Active interruption
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    debugPrint(
        '🔔 💥 Showing HIGHLY VISIBLE notification with ID: $notificationId');

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      '🚨 TEST NOTIFICATION 🚨',
      'This should definitely be visible! Tap me! 📱',
      notificationDetails,
      payload: 'visible_test',
    );

    debugPrint('🔔 ✅ Highly visible notification sent!');
  }

  /// Schedule notification to appear in 5 seconds based on local time zone
  Future<void> zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  /// Check pending notifications
  Future<void> checkPendingNotificationRequests(BuildContext context) async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content:
            Text('${pendingNotificationRequests.length} pending notification '
                'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Request permissions with critical alert (iOS/macOS)
  Future<void> requestPermissionsWithCriticalAlert() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    }
  }
}
