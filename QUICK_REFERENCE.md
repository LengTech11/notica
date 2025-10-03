# Quick Reference Guide - iOS Push Notifications Without APNs

## 🚀 Quick Start

### For Developers (Testing Without Firebase)
```bash
# Clone and run
git clone <repo>
cd notica
flutter pub get
flutter run

# In app: Menu → "Push Notification Test" → Test Local Notification
```

### For Full Testing (With Firebase)
```bash
# 1. Setup Firebase project and download configs
# 2. Place config files:
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# 3. Run
flutter pub get
flutter run

# 4. Check logs for FCM token
# 5. Send test from Firebase Console to test_topic
```

## 📁 Files Changed (15 files, 1635+ lines)

### New Code Files
- `lib/services/firebase_messaging_service.dart` - FCM handling
- `lib/views/push_notification_test_view.dart` - Testing UI

### New Documentation
- `FIREBASE_SETUP.md` - Setup guide (190 lines)
- `TESTING_PUSH_NOTIFICATIONS.md` - Testing guide (215 lines)
- `IMPLEMENTATION_NOTES.md` - Architecture (248 lines)
- `ARCHITECTURE_DIAGRAMS.md` - Visual diagrams (352 lines)

### Configuration Files
- `android/app/google-services.json.example` - Android config template
- `ios/Runner/GoogleService-Info.plist.example` - iOS config template
- `.gitignore` - Updated to exclude Firebase configs

### Modified Files
- `lib/main.dart` - Initialize Firebase
- `lib/views/reminder_list_view.dart` - Add test menu
- `pubspec.yaml` - Add firebase_core & firebase_messaging
- `android/app/build.gradle.kts` - Google Services plugin
- `android/settings.gradle.kts` - Google Services version
- `README.md` - Updated with Firebase info

## 🎯 How It Works

### iOS (Without APNs Key)
```
FCM Message → FirebaseMessagingService 
  → Platform.isIOS? 
    → YES: NotificationService.showImmediateNotification()
    → flutter_local_notifications displays it
```

**Result:**
- ✅ Foreground: Works
- ✅ Background: Works
- ❌ Killed: Doesn't work (needs APNs)

### Android
```
FCM Message → Google Play Services → Native notification
```

**Result:**
- ✅ Foreground: Works
- ✅ Background: Works
- ✅ Killed: Works

## 🧪 Testing Checklist

- [ ] Local notification test works (Menu → Push Test → Test)
- [ ] Firebase configs in place
- [ ] App shows FCM token in logs
- [ ] Subscribed to test_topic
- [ ] Foreground message shows notification
- [ ] Background message shows notification
- [ ] Killed app on Android shows notification
- [ ] Killed app on iOS doesn't show (documented limitation)

## 📍 Important Locations

### Code
- **FCM Service**: `lib/services/firebase_messaging_service.dart`
- **Test UI**: `lib/views/push_notification_test_view.dart`
- **Initialization**: `lib/main.dart` (lines 30-42)

### Documentation
- **Setup**: `FIREBASE_SETUP.md`
- **Testing**: `TESTING_PUSH_NOTIFICATIONS.md`
- **Architecture**: `IMPLEMENTATION_NOTES.md`
- **Diagrams**: `ARCHITECTURE_DIAGRAMS.md`

### Access Test UI
App → Menu (⋮) → "Push Notification Test"

## ⚡ Key Features

1. **Auto-subscribes to test_topic** on app start
2. **Platform detection** - different behavior for iOS/Android
3. **FCM token display** - copy to clipboard for testing
4. **Activity logging** - see what's happening
5. **Topic management** - subscribe/unsubscribe
6. **Local notification testing** - works without Firebase

## 🔑 Code Snippets

### Send notification from code
```dart
await NotificationService().showImmediateNotification(
  'Title',
  'Body text'
);
```

### Get FCM token
```dart
final token = await FirebaseMessagingService().getToken();
```

### Subscribe to topic
```dart
await FirebaseMessagingService().subscribeToTopic('my_topic');
```

## 📨 Send Test Message

### Firebase Console
1. Cloud Messaging → New campaign
2. Title: "Test"
3. Body: "Hello"
4. Target: Topic → "test_topic"
5. Send

### curl Command
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/test_topic",
    "notification": {
      "title": "Test",
      "body": "Hello from curl"
    }
  }'
```

## 🐛 Troubleshooting

### No notifications on iOS
- Check permissions: Settings → Notica → Notifications
- Verify app is not killed (limitation)
- Check logs for "🔔 Notification sent successfully!"

### No FCM token
- Verify Firebase configs in place
- Check initialization errors in logs
- Rebuild after adding configs

### Android not working
- Ensure google-services.json in android/app/
- Rebuild: `flutter clean && flutter build apk`

## 📊 Stats

- **Lines of Code**: 509 (firebase_messaging_service.dart + push_notification_test_view.dart)
- **Lines of Documentation**: 1005+ across 4 guides
- **Test Coverage**: In-app testing UI + comprehensive docs
- **Platforms Supported**: iOS (partial), Android (full)
- **Dependencies Added**: 2 (firebase_core, firebase_messaging)

## 🎓 Learning Resources

- Read `FIREBASE_SETUP.md` for step-by-step setup
- Read `TESTING_PUSH_NOTIFICATIONS.md` for testing scenarios
- Read `ARCHITECTURE_DIAGRAMS.md` for visual understanding
- Use in-app test UI for hands-on exploration

## ✅ Requirements Met

All original issue requirements implemented:
1. ✅ flutter_local_notifications (already present)
2. ✅ LocalNotificationService helper
3. ✅ FCM message hooks (onMessage, onBackgroundMessage)
4. ✅ Auto-subscribe to test_topic
5. ✅ Notifications in foreground/background
6. ✅ Documented killed-app limitation

## 🎯 Next Steps

1. **Try it**: Test local notifications without Firebase
2. **Configure**: Add Firebase project and configs
3. **Test**: Send messages from Firebase Console
4. **Upgrade**: Add APNs key for full iOS support (optional)

---

**Quick Links:**
- Setup: `FIREBASE_SETUP.md`
- Testing: `TESTING_PUSH_NOTIFICATIONS.md`
- Architecture: `IMPLEMENTATION_NOTES.md` & `ARCHITECTURE_DIAGRAMS.md`
- In-app: Menu → "Push Notification Test"
