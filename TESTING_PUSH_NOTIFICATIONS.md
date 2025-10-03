# Testing Push Notifications Without Full Firebase Setup

This guide shows how to verify the push notification implementation works, even before setting up a Firebase project.

## Quick Testing Without Firebase

Since Firebase requires a project setup, here's what you can verify locally:

### 1. Verify Local Notification System Works

The app uses `flutter_local_notifications` which doesn't require Firebase. Test it:

```dart
// This is already implemented in NotificationService
await NotificationService().showImmediateNotification(
  'Test Title',
  'Test Body'
);
```

### 2. Code Review Checklist

Verify the implementation is correct:

- ✅ `firebase_core` and `firebase_messaging` added to `pubspec.yaml`
- ✅ `FirebaseMessagingService` class created with:
  - `onMessage` handler for foreground messages
  - `onBackgroundMessage` handler for background messages
  - Auto-subscription to `test_topic`
  - Platform-specific handling (iOS uses local notifications)
- ✅ Firebase initialized in `main.dart` before app runs
- ✅ Android Gradle files configured for Google Services plugin
- ✅ `.gitignore` updated to exclude Firebase config files
- ✅ Example configuration files provided

### 3. Simulating FCM Message Handling

You can test the notification logic flow:

```dart
// In your test or development code
import 'package:firebase_messaging/firebase_messaging.dart';

// This simulates what happens when an FCM message arrives
void simulateFCMMessage() {
  final title = 'Test Notification';
  final body = 'This would come from FCM';
  
  // On iOS, this is what FirebaseMessagingService does:
  NotificationService().showImmediateNotification(title, body);
}
```

## Full Testing With Firebase

Once you've set up Firebase:

### Step 1: Add Configuration Files

1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`
3. Download `GoogleService-Info.plist` from Firebase Console  
4. Place in `ios/Runner/GoogleService-Info.plist`

### Step 2: Run the App

```bash
flutter pub get
flutter run
```

### Step 3: Check Logs

Look for these log messages:

```
🔥 Initializing Firebase Messaging...
🔥 Permission status: AuthorizationStatus.authorized
🔥 FCM Token: eyJhbGci...
🔥 ✅ Subscribed to topic: test_topic
🔥 Firebase Messaging initialized successfully
```

### Step 4: Send Test Message

#### Method A: Firebase Console (Easiest)

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message" or "New campaign"
3. Enter notification title and body
4. Add topic: `test_topic`
5. Send message

#### Method B: Using FCM REST API

```bash
# Get your Server Key from Firebase Console → Project Settings → Cloud Messaging

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/test_topic",
    "notification": {
      "title": "Test from API",
      "body": "Testing push notifications"
    },
    "data": {
      "type": "test",
      "timestamp": "2024-01-01T00:00:00Z"
    }
  }'
```

### Step 5: Verify Behavior

Test each scenario:

| App State | Android | iOS (No APNs) | iOS (With APNs) |
|-----------|---------|---------------|-----------------|
| Foreground | ✅ FCM notification | ✅ Local notification | ✅ FCM notification |
| Background | ✅ FCM notification | ✅ Local notification | ✅ FCM notification |
| Killed | ✅ FCM notification | ❌ No notification | ✅ FCM notification |

### Expected Log Output

**Foreground Message (iOS):**
```
🔥 Received foreground message: projects/xxx/messages/yyy
🔥 Notification: {title: Test, body: Message}
🔥 Data: {type: test}
🔔 Starting notification test...
🔔 Service initialized: true
🔔 Notification sent successfully!
🔥 iOS: Showed local notification for foreground message
```

**Background Message (iOS):**
```
🔥 Handling background message: projects/xxx/messages/yyy
🔔 Starting notification test...
🔔 Notification sent successfully!
🔥 iOS: Showed local notification for background message
```

## Troubleshooting

### No logs appear
- Verify Firebase is initialized: check for "🔥 Firebase initialized successfully"
- Check if FCM initialization failed: look for error messages

### Notifications not showing on iOS
1. Check notification permissions in Settings → Notica → Notifications
2. Verify the app is not killed (local notifications don't work when killed)
3. Look for "🔔 Notification sent successfully!" in logs

### Token not appearing
- Ensure Firebase config files are in correct locations
- Check for Firebase initialization errors
- Rebuild the app after adding config files

### Android notifications not showing
1. Verify `google-services.json` is in `android/app/`
2. Check notification permissions are enabled
3. Rebuild the app: `flutter clean && flutter build apk`

## Code Walkthrough

### Flow for iOS (Without APNs)

1. **App Starts**: 
   - `main.dart` initializes Firebase and NotificationService
   - `FirebaseMessagingService.initialize()` is called
   - App subscribes to `test_topic`

2. **Message Arrives (Foreground)**:
   - `FirebaseMessaging.onMessage` listener triggered
   - `Platform.isIOS` check passes
   - Calls `NotificationService().showImmediateNotification()`
   - Local notification appears

3. **Message Arrives (Background)**:
   - `_firebaseMessagingBackgroundHandler` called
   - `Platform.isIOS` check passes
   - Calls `NotificationService().showImmediateNotification()`
   - Local notification appears

4. **Message Arrives (Killed)**:
   - ❌ App is not running, can't handle FCM messages
   - Would require APNs key for iOS to wake the app

### Flow for Android

1. **App Starts**: Same as iOS

2. **Message Arrives (Any State)**:
   - FCM handles natively through Google Play Services
   - No local notification needed
   - ✅ Works in all states

## Next Steps

1. **Test locally**: Verify code structure and local notifications work
2. **Setup Firebase**: Create project and add config files
3. **Test foreground**: Send message while app is open
4. **Test background**: Minimize app and send message
5. **Test killed**: Close app completely (only works on Android without APNs)
6. **[Optional] Add APNs**: Upload APNs key to Firebase for full iOS support

## Resources

- [Firebase Console](https://console.firebase.google.com/)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [Main Setup Guide](FIREBASE_SETUP.md)
