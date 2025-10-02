# Notica App Structure

## Visual Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Notica App                            │
│                 (Calendar, Planner & Reminders)              │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│  Reminders   │      │   Calendar   │      │   Planner    │
│     Tab      │      │     Tab      │      │     Tab      │
└──────────────┘      └──────────────┘      └──────────────┘
        │                     │                     │
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│ Reminder     │      │ Calendar     │      │  Planner     │
│ ViewModel    │      │ ViewModel    │      │ ViewModel    │
└──────────────┘      └──────────────┘      └──────────────┘
        │                     │                     │
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│ Reminder     │      │    Event     │      │ PlannerTask  │
│   Model      │      │    Model     │      │    Model     │
└──────────────┘      └──────────────┘      └──────────────┘
        │                     │                     │
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│ Reminder     │      │    Event     │      │  Planner     │
│  Storage     │      │   Storage    │      │  Storage     │
└──────────────┘      └──────────────┘      └──────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ SharedPreferences│
                    │  (Local Storage) │
                    └──────────────────┘
```

## Feature Breakdown

### 🔔 Reminders (Existing + Enhanced)
```
┌───────────────────────────────────────────┐
│         Reminder Management               │
├───────────────────────────────────────────┤
│ • Create/Edit/Delete reminders            │
│ • Schedule: Once, Daily, Weekly, etc.     │
│ • Priority levels: Low, Normal, High      │
│ • Tags for organization                   │
│ • Local notifications                     │
│ • Completion tracking                     │
│ • Smart filtering (Today, Upcoming, Due)  │
└───────────────────────────────────────────┘
```

### 📅 Calendar (NEW)
```
┌───────────────────────────────────────────┐
│         Calendar & Events                 │
├───────────────────────────────────────────┤
│ • Monthly calendar grid view              │
│ • Visual indicators for events            │
│ • Create/Edit/Delete events               │
│ • Event categories & colors               │
│ • All-day or timed events                 │
│ • Location tracking                       │
│ • Event completion tracking               │
│ • Date navigation                         │
└───────────────────────────────────────────┘
```

### 📋 Planner (NEW)
```
┌───────────────────────────────────────────┐
│         Daily Planner & Tasks             │
├───────────────────────────────────────────┤
│ • Daily task organization                 │
│ • Priority: Urgent, High, Normal, Low     │
│ • Status: Not Started, In Progress, etc.  │
│ • Progress tracking with percentage       │
│ • Overdue alerts                          │
│ • Time scheduling                         │
│ • Task grouping by status                 │
│ • Date navigation                         │
└───────────────────────────────────────────┘
```

## User Flow

### Creating a Reminder
```
Open App → Reminders Tab → Tap "+" → Fill Form → Save
                                           ↓
                                    Notification Service
                                           ↓
                                    Scheduled Alert
```

### Creating an Event
```
Open App → Calendar Tab → Select Date → Tap "+" → Fill Form → Save
                              ↓
                        View on Calendar
                              ↓
                      Visual Indicator
```

### Creating a Task
```
Open App → Planner Tab → Select Date → Tap "+" → Fill Form → Save
                              ↓
                        View in Day View
                              ↓
                    Track Progress/Complete
```

## Data Flow

```
┌─────────────┐
│    User     │
│  Interface  │
└──────┬──────┘
       │
       │ User Action
       ▼
┌─────────────┐
│  ViewModel  │ ← State Management (Provider)
└──────┬──────┘
       │
       │ Business Logic
       ▼
┌─────────────┐
│   Service   │ ← Storage/Notifications
└──────┬──────┘
       │
       │ Persistence
       ▼
┌─────────────┐
│   Storage   │ ← SharedPreferences (Local)
└─────────────┘
```

## Technology Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Material Design 3** - Modern UI components
- **Provider** - State management

### Storage
- **SharedPreferences** - Local data persistence
- **JSON Serialization** - Data conversion

### Notifications
- **flutter_local_notifications** - Local notifications
- **timezone** - Timezone support

### Localization
- **easy_localization** - Multi-language support
- **intl** - Date/time formatting

## Key Principles

### 🎯 User-Focused
- **Simplicity**: Clean, intuitive interface
- **Reliability**: Stable local storage
- **Privacy**: No data collection
- **Freedom**: No ads, no costs

### 🏗️ Developer-Focused
- **MVVM Architecture**: Clean separation of concerns
- **Testable**: Unit tests for models and logic
- **Maintainable**: Consistent code patterns
- **Extensible**: Easy to add new features

### 🔒 Privacy-Focused
- **Local-Only**: All data stays on device
- **No Tracking**: No analytics or telemetry
- **Transparent**: Open about data handling
- **Secure**: No external data transmission

## Navigation Structure

```
                  ┌─────────────────┐
                  │   Bottom Nav    │
                  └────────┬────────┘
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐       ┌────▼────┐      ┌────▼────┐
    │Reminders│       │Calendar │      │ Planner │
    │  View   │       │  View   │      │  View   │
    └─────────┘       └─────────┘      └─────────┘
         │                 │                 │
    ┌────▼────┐       ┌────▼────┐      ┌────▼────┐
    │   Add   │       │   Add   │      │   Add   │
    │Reminder │       │  Event  │      │  Task   │
    └─────────┘       └─────────┘      └─────────┘
```

## File Organization

```
lib/
├── models/              # Data models
│   ├── reminder.dart    # ✅ Existing
│   ├── event.dart       # 🆕 NEW
│   ├── planner_task.dart# 🆕 NEW
│   └── habit.dart       # ✅ Existing
│
├── viewmodels/          # Business logic
│   ├── reminder_viewmodel.dart    # ✅ Existing
│   ├── calendar_viewmodel.dart    # 🆕 NEW
│   ├── planner_viewmodel.dart     # 🆕 NEW
│   └── habit_viewmodel.dart       # ✅ Existing
│
├── views/               # UI components
│   ├── reminder_list_view.dart    # ✅ Existing
│   ├── calendar_view.dart         # 🆕 NEW
│   ├── planner_view.dart          # 🆕 NEW
│   └── add_reminder_view.dart     # ✅ Existing
│
├── services/            # Infrastructure
│   ├── reminder_storage_service.dart   # ✅ Existing
│   ├── event_storage_service.dart      # 🆕 NEW
│   ├── planner_storage_service.dart    # 🆕 NEW
│   └── notification_service.dart       # ✅ Existing
│
└── main.dart            # 🔄 Modified (Navigation)
```

## Summary

The Notica app now provides a **complete productivity suite** with:
- 🔔 **Reminders** - Never forget important tasks
- 📅 **Calendar** - Visualize your schedule
- 📋 **Planner** - Organize your daily tasks

All wrapped in a **100% free, ad-free** experience that respects your privacy and keeps your data local.
