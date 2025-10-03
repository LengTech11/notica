import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

/// Top-level function for handling background messages
/// Must be a top-level function or static method
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔥 Handling background message: ${message.messageId}');
  
  // On iOS, show local notification since APNs is not configured
  if (Platform.isIOS) {
    final title = message.notification?.title ?? message.data['title'] ?? 'New Message';
    final body = message.notification?.body ?? message.data['body'] ?? 'You have a new notification';
    
    await NotificationService().showImmediateNotification(title, body);
    debugPrint('🔥 iOS: Showed local notification for background message');
  }
  // On Android, FCM handles notifications automatically
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔥 Firebase Messaging already initialized');
      return;
    }

    try {
      debugPrint('🔥 Initializing Firebase Messaging...');

      // Request permissions (especially important for iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔥 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('🔥 User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('🔥 User granted provisional permission');
      } else {
        debugPrint('🔥 User declined or has not accepted permission');
      }

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      debugPrint('🔥 FCM Token: $token');

      // Subscribe to test topic for testing
      await subscribeToTopic('test_topic');

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔥 Received foreground message: ${message.messageId}');
        debugPrint('🔥 Notification: ${message.notification?.toMap()}');
        debugPrint('🔥 Data: ${message.data}');

        // On iOS, show local notification as FCM won't display it without APNs
        if (Platform.isIOS) {
          final title = message.notification?.title ?? message.data['title'] ?? 'New Message';
          final body = message.notification?.body ?? message.data['body'] ?? 'You have a new notification';
          
          NotificationService().showImmediateNotification(title, body);
          debugPrint('🔥 iOS: Showed local notification for foreground message');
        }
        // On Android, we can optionally show a local notification too
        // but FCM typically handles this automatically
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔥 Notification tapped (app in background): ${message.messageId}');
        // Handle navigation based on message data
        _handleNotificationTap(message);
      });

      // Check if the app was opened from a terminated state via notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔥 App opened from terminated state via notification: ${initialMessage.messageId}');
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('🔥 Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('🔥 Error initializing Firebase Messaging: $e');
      rethrow;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('🔥 ✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('🔥 ❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('🔥 ✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('🔥 ❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Get the FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔥 Handling notification tap for message: ${message.messageId}');
    // Add custom navigation logic here based on message.data
    // For example:
    // if (message.data['type'] == 'reminder') {
    //   // Navigate to reminder details
    // }
  }
}
