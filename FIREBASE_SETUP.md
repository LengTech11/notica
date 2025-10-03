# Firebase Cloud Messaging (FCM) Setup for iOS Push Notifications

## Overview

This app implements Firebase Cloud Messaging (FCM) with a local notification fallback for iOS. This allows push notifications to work on iOS without requiring an APNs key, though with some limitations.

## How It Works

### Android
- FCM handles notifications natively
- Notifications work in all states: foreground, background, and killed

### iOS (Without APNs Key)
- **Foreground**: FCM messages trigger local notifications ✅
- **Background**: FCM messages trigger local notifications ✅
- **Killed/Terminated**: Notifications will NOT work ❌ (requires APNs configuration)

## Setup Instructions

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard

### 2. Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.notica` (or your actual package name from `android/app/build.gradle`)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 3. Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.example.notica` (or your actual bundle ID from `ios/Runner/Info.plist`)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Configure Android Build

Edit `android/app/build.gradle` and add:

```gradle
// At the top of the file
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id 'com.google.gms.google-services'  // Add this line
}
```

Edit `android/build.gradle` and add:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'  // Add this line
    }
}
```

### 5. Configure iOS (Optional - For Full Push Support)

**Note**: For testing without APNs, you can skip this section. The local notification fallback will work.

To enable killed-app notifications, you need to:

1. Get an APNs key from Apple Developer Account
2. Upload it to Firebase Console → Project Settings → Cloud Messaging → APNs Certificates
3. Add capabilities in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target → Signing & Capabilities
   - Click "+ Capability" → Push Notifications
   - Click "+ Capability" → Background Modes
   - Check "Background fetch" and "Remote notifications"

### 6. Install Dependencies

```bash
flutter pub get
```

### 7. Test Push Notifications

#### Using Firebase Console (Recommended for Testing)

1. Go to Firebase Console → Cloud Messaging → Send test message
2. Enter FCM token (shown in app logs when it starts)
3. Or send to topic: `test_topic` (app auto-subscribes on startup)

#### Using curl (Advanced)

```bash
# Get your server key from Firebase Console → Project Settings → Cloud Messaging

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/test_topic",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test from FCM"
    },
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "type": "test"
    }
  }'
```

## Testing Scenarios

### Scenario 1: App in Foreground
1. Open the app
2. Send a notification from Firebase Console to `test_topic`
3. **Expected**: Local notification appears on iOS, FCM notification on Android

### Scenario 2: App in Background
1. Open the app, then minimize it
2. Send a notification from Firebase Console to `test_topic`
3. **Expected**: Local notification appears on iOS, FCM notification on Android

### Scenario 3: App Killed (Terminated)
1. Force quit the app
2. Send a notification from Firebase Console to `test_topic`
3. **Expected**: 
   - Android: Notification appears ✅
   - iOS: No notification without APNs key ❌

## Implementation Details

### Auto-Subscription
The app automatically subscribes to `test_topic` on initialization for easy testing.

### Local Notification Fallback (iOS)
- `FirebaseMessagingService` listens to FCM messages
- When a message arrives (foreground or background), it calls `NotificationService.showImmediateNotification()`
- This displays a local notification using `flutter_local_notifications`
- Works without APNs key, but only when app is not killed

### Code Structure
- `/lib/services/firebase_messaging_service.dart` - FCM message handling
- `/lib/services/notification_service.dart` - Local notification display
- `/lib/main.dart` - Firebase initialization

## Troubleshooting

### No notifications on iOS
1. Check app logs for FCM token
2. Verify permissions are granted (check Settings → Notica → Notifications)
3. Try sending to specific token instead of topic
4. Ensure app is in foreground or background (not killed)

### No notifications on Android
1. Verify `google-services.json` is in correct location
2. Check Android notification settings are enabled
3. Rebuild the app after adding Firebase config

### FCM token not showing
1. Ensure Firebase is initialized correctly
2. Check for initialization errors in logs
3. Verify Firebase config files are valid

## Limitations

### iOS Without APNs Key
- ❌ Push notifications do NOT work when app is killed/terminated
- ✅ Push notifications work when app is in foreground
- ✅ Push notifications work when app is in background
- ❌ Cannot wake app from terminated state
- ❌ No notification badges in terminated state

### To Remove Limitations
Upload an APNs key to Firebase Console to enable full push notification support on iOS.

## Security Note

- Never commit `google-services.json` or `GoogleService-Info.plist` to public repositories
- Add them to `.gitignore`
- Provide `.example` files instead with placeholder values

## References

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [flutter_local_notifications Package](https://pub.dev/packages/flutter_local_notifications)
