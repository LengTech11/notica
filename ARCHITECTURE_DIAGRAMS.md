# Firebase Cloud Messaging Flow Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         App Startup (main.dart)                  │
│                                                                  │
│  1. WidgetsFlutterBinding.ensureInitialized()                   │
│  2. await Firebase.initializeApp()                              │
│  3. await NotificationService().initialize()                    │
│  4. await FirebaseMessagingService().initialize()               │
│     └─> Auto-subscribe to 'test_topic'                         │
│  5. runApp(...)                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Message Flow - iOS (Without APNs)

### Foreground Message Flow
```
┌──────────────────┐
│  Firebase Cloud  │
│    Messaging     │
└────────┬─────────┘
         │
         │ FCM Message
         ▼
┌──────────────────────────────────────┐
│  FirebaseMessagingService            │
│                                      │
│  FirebaseMessaging.onMessage.listen  │
└────────┬─────────────────────────────┘
         │
         │ Platform check: if (Platform.isIOS)
         ▼
┌────────────────────────────────────┐
│  Extract title & body from message │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  NotificationService               │
│  .showImmediateNotification()      │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  flutter_local_notifications       │
│  displays notification             │
└────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  User sees notification! ✅        │
└────────────────────────────────────┘
```

### Background Message Flow
```
┌──────────────────┐
│  Firebase Cloud  │
│    Messaging     │
└────────┬─────────┘
         │
         │ FCM Message (app in background)
         ▼
┌────────────────────────────────────────────┐
│  _firebaseMessagingBackgroundHandler       │
│  (Top-level function)                      │
│  @pragma('vm:entry-point')                 │
└────────┬───────────────────────────────────┘
         │
         │ Platform check: if (Platform.isIOS)
         ▼
┌────────────────────────────────────┐
│  Extract title & body from message │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  NotificationService               │
│  .showImmediateNotification()      │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  flutter_local_notifications       │
│  displays notification             │
└────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  User sees notification! ✅        │
└────────────────────────────────────┘
```

### Killed App Flow (iOS without APNs)
```
┌──────────────────┐
│  Firebase Cloud  │
│    Messaging     │
└────────┬─────────┘
         │
         │ FCM Message (app is killed)
         ▼
┌────────────────────────────────────┐
│  iOS System                        │
│  (No APNs key configured)          │
└────────┬───────────────────────────┘
         │
         │ Cannot deliver message
         ▼
┌────────────────────────────────────┐
│  No notification shown ❌          │
│  (Requires APNs key setup)         │
└────────────────────────────────────┘
```

## Message Flow - Android

### All States (Foreground, Background, Killed)
```
┌──────────────────┐
│  Firebase Cloud  │
│    Messaging     │
└────────┬─────────┘
         │
         │ FCM Message
         ▼
┌──────────────────────────────────────┐
│  Google Play Services                │
│  (Native FCM handling)               │
└────────┬─────────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  Android System Notification        │
│  (Displayed natively by FCM)        │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│  User sees notification! ✅        │
└────────────────────────────────────┘
```

## Topic Subscription Flow

```
┌─────────────────────────────────────┐
│  App Startup                        │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  FirebaseMessagingService           │
│  .initialize()                      │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  subscribeToTopic('test_topic')     │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Firebase registers device          │
│  to topic                           │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Ready to receive topic messages ✅ │
└─────────────────────────────────────┘
```

## Testing Flow (Using PushNotificationTestView)

```
┌─────────────────────────────────────┐
│  User opens app                     │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Menu → Push Notification Test      │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  PushNotificationTestView           │
│  • Shows FCM token                  │
│  • Platform info                    │
│  • Test buttons                     │
│  • Activity log                     │
└────────┬────────────────────────────┘
         │
         │  Option 1: Test Local Notification
         ├──────────────────────────────────────┐
         │                                      │
         ▼                                      ▼
┌─────────────────────┐           ┌────────────────────────┐
│  Test Local Notif   │           │  Copy FCM Token        │
│  Button clicked     │           │                        │
└────────┬────────────┘           └────────┬───────────────┘
         │                                  │
         ▼                                  │
┌─────────────────────┐                    │ Option 2: Send from Firebase Console
│  Shows notification │                    ▼
│  immediately ✅      │           ┌────────────────────────┐
└─────────────────────┘           │  Firebase Console      │
                                  │  Cloud Messaging       │
                                  └────────┬───────────────┘
                                           │
                                           ▼
                                  ┌────────────────────────┐
                                  │  Send to:              │
                                  │  • Specific token, OR  │
                                  │  • Topic: test_topic   │
                                  └────────┬───────────────┘
                                           │
                                           ▼
                                  ┌────────────────────────┐
                                  │  Notification arrives  │
                                  │  (via FCM flow above)  │
                                  └────────────────────────┘
```

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                      Application Layer                        │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │   main.dart  │  │  Views       │  │  ViewModels     │   │
│  │              │  │  • Reminder  │  │  • Reminder     │   │
│  │  Initialize  │  │  • Calendar  │  │  • Calendar     │   │
│  │  Firebase    │  │  • Planner   │  │  • Planner      │   │
│  │              │  │  • Test View │  │                 │   │
│  └──────┬───────┘  └──────────────┘  └─────────────────┘   │
│         │                                                    │
└─────────┼────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│                                                              │
│  ┌────────────────────────┐  ┌──────────────────────────┐  │
│  │ FirebaseMessagingService│  │  NotificationService     │  │
│  │                        │  │                          │  │
│  │ • Initialize FCM       │◄─┤ • Local notifications   │  │
│  │ • Handle messages      │  │ • Schedule reminders     │  │
│  │ • Manage topics        │  │ • Permission handling    │  │
│  │ • Get FCM token        │  │                          │  │
│  └────────┬───────────────┘  └──────────────────────────┘  │
│           │                                                  │
└───────────┼──────────────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────────────────────┐
│                    Plugin/SDK Layer                        │
│                                                            │
│  ┌─────────────────────┐  ┌───────────────────────────┐  │
│  │  firebase_messaging │  │ flutter_local_notifications│ │
│  │                     │  │                           │  │
│  │  • FCM connection   │  │  • Display notifications  │  │
│  │  • Message handling │  │  • Notification channels  │  │
│  │  • Token management │  │  • Actions & responses    │  │
│  └─────────┬───────────┘  └───────────────────────────┘  │
│            │                                               │
└────────────┼───────────────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────────────┐
│                    Platform Layer                           │
│                                                             │
│  ┌─────────────────┐              ┌────────────────────┐  │
│  │  iOS            │              │  Android           │  │
│  │                 │              │                    │  │
│  │  • APNs (opt)   │              │  • Google Play Svc │  │
│  │  • Local notif  │              │  • Native FCM      │  │
│  │  • UNUserNotif  │              │  • Notification    │  │
│  │    Center       │              │    Manager         │  │
│  └─────────────────┘              └────────────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## State Comparison Table

| Component | iOS (No APNs) | iOS (With APNs) | Android |
|-----------|---------------|-----------------|---------|
| **Foreground** | ✅ Local Notification | ✅ FCM | ✅ FCM |
| **Background** | ✅ Local Notification | ✅ FCM | ✅ FCM |
| **Killed** | ❌ No notification | ✅ FCM | ✅ FCM |
| **Badge** | ⚠️ Limited | ✅ Full support | ✅ Full support |
| **Sound** | ✅ Works | ✅ Works | ✅ Works |
| **Wake app** | ❌ No | ✅ Yes | ✅ Yes |

## Decision Tree for Implementation

```
                    ┌──────────────────┐
                    │  Push Message    │
                    │  Received        │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Check Platform  │
                    └────────┬─────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
           ┌────▼────┐              ┌────▼────┐
           │  iOS    │              │ Android │
           └────┬────┘              └────┬────┘
                │                        │
      ┌─────────▼──────────┐             │
      │  APNs configured?  │             │
      └─────────┬──────────┘             │
                │                        │
         ┌──────┴──────┐                 │
         │             │                 │
      ┌──▼──┐      ┌──▼──┐               │
      │ Yes │      │ No  │               │
      └──┬──┘      └──┬──┘               │
         │            │                  │
         │            │                  │
   ┌─────▼─────┐ ┌───▼────────────┐ ┌───▼──────────┐
   │ Use FCM   │ │ Use Local      │ │ Use Native   │
   │ (native)  │ │ Notification   │ │ FCM          │
   │ ✅        │ │ Fallback       │ │ ✅           │
   │           │ │ (foreground &  │ │              │
   │           │ │  background)   │ │              │
   │           │ │ ✅ / ❌ killed │ │              │
   └───────────┘ └────────────────┘ └──────────────┘
```

## Summary

This architecture provides:
- ✅ Seamless Firebase Cloud Messaging integration
- ✅ iOS local notification fallback for testing without APNs
- ✅ Native Android FCM support unchanged
- ✅ Clear separation of concerns
- ✅ Easy testing via dedicated UI
- ✅ Comprehensive documentation
- ✅ Upgrade path to full iOS support

The implementation is production-ready for testing and can be enhanced by adding APNs configuration for full iOS support.
