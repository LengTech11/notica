# Notica - Flutter Calendar, Planner & Reminder App

A modern, completely free and ad-free Flutter application for calendar management, daily planning, and reminders. Built using the MVVM (Model-View-ViewModel) architecture pattern with Provider for state management, local notifications, and persistent storage.

## Features

### 🔔 Reminder Management
- ✅ **Create reminders** with title, description, and scheduled time
- 🔁 **Flexible scheduling** - Once, Daily, Weekly, Weekdays, or Weekends
- 🎯 **Priority levels** - Low, Normal, or High priority reminders
- 🏷️ **Tag system** for organizing reminders
- 📋 **View all reminders** in an organized list with filtering options
- ✔️ **Mark reminders as completed** with completion tracking
- 🔔 **Local notifications** that trigger at scheduled times
- ✏️ **Edit existing reminders** with full details modification
- 🗑️ **Delete reminders** with confirmation dialog
- 💾 **Persistent storage** using SharedPreferences

### 📅 Calendar View
- 📆 **Monthly calendar display** with intuitive date navigation
- 📍 **Event indicators** showing days with scheduled events
- 🎯 **Event management** - Create, view, and manage events
- 🏷️ **Event categories** - Personal, Work, Health, Social, Finance, Education, and more
- 🎨 **Color-coded events** by category for easy identification
- 📍 **Location tracking** for events (optional)
- ⏰ **All-day or timed events** with flexible scheduling
- ✅ **Mark events as completed** with visual feedback
- 🔗 **Link to reminders** - Create events from existing reminders

### 📋 Daily Planner
- 📝 **Task management** - Create, organize, and track daily tasks
- 📊 **Progress tracking** - Visual progress bar showing daily completion
- 🎯 **Priority levels** - Urgent, High, Normal, and Low priorities
- 📍 **Task status** - Not Started, In Progress, Completed, or Cancelled
- ⏰ **Time scheduling** - Set specific times for tasks (optional)
- ⚠️ **Overdue alerts** - Visual indicators for overdue tasks
- 📅 **Date navigation** - Easy navigation between different days
- ✅ **Quick completion** - Check off tasks as you complete them
- 🏷️ **Task grouping** by status for better organization
- ⏱️ **Estimated duration** - Track time estimates for tasks

### 📊 Habit Tracking
- ✅ **Create habits** with custom names and reminder times
- 📈 **Track habit completion** with daily progress
- 🔥 **Streak counter** to track consecutive days
- ✔️ **Mark habits as completed** for the current day
- 🔔 **Daily notifications** to remind you about your habits

### 🎨 User Experience
- 🌙 **Dark mode support** (follows system preference)
- 🌍 **Multi-language support** - English and Khmer (ខ្មែរ)
- 📱 **Material Design 3** with modern UI components
- 🔍 **Smart filtering** - View upcoming, overdue, and today's items
- ⚡ **Real-time updates** with reactive state management
- 🧭 **Bottom navigation** - Easy switching between Reminders, Calendar, and Planner
- 💯 **100% Free and Ad-free** - No advertisements or hidden costs

## Architecture

This app follows the **MVVM (Model-View-ViewModel)** pattern as recommended by Flutter's architecture guidelines:

### 📁 Project Structure

```
lib/
├── models/
│   ├── reminder.dart           # Reminder data model with enums
│   ├── event.dart              # Event data model for calendar
│   ├── planner_task.dart       # Task data model for daily planner
│   └── habit.dart              # Habit data model
├── viewmodels/
│   ├── reminder_viewmodel.dart # Business logic for reminders
│   ├── calendar_viewmodel.dart # Business logic for calendar
│   ├── planner_viewmodel.dart  # Business logic for planner
│   └── habit_viewmodel.dart    # Business logic for habits
├── views/
│   ├── reminder_list_view.dart # Main reminders list screen
│   ├── add_reminder_view.dart  # Add/edit reminder screen
│   ├── calendar_view.dart      # Calendar view with monthly display
│   ├── planner_view.dart       # Daily planner view
│   ├── habit_list_view.dart    # Habits list screen
│   └── add_habit_view.dart     # Add/edit habit screen
├── services/
│   ├── notification_service.dart       # Local notification handling
│   ├── reminder_storage_service.dart   # Reminder persistence
│   ├── event_storage_service.dart      # Event persistence
│   ├── planner_storage_service.dart    # Planner task persistence
│   └── habit_storage_service.dart      # Habit persistence
└── main.dart                   # App entry point with Provider setup
```

### 🏗️ MVVM Architecture Components

Following Flutter's recommended patterns:

- **Model**: Data classes (`Reminder`, `Event`, `PlannerTask`, `Habit`) with business rules and serialization
  - Encapsulate data and domain logic
  - Include computed properties (e.g., `isCompletedToday`, `currentStreak`)
  - Support JSON serialization for persistence

- **ViewModel**: State management using Provider/ChangeNotifier
  - `ReminderViewModel`, `CalendarViewModel`, `PlannerViewModel`, and `HabitViewModel` manage application state
  - Handle business logic and data operations
  - Communicate with services for persistence and notifications
  - Notify views of state changes through `notifyListeners()`

- **View**: UI components built with Flutter widgets
  - Observe ViewModel state using `Consumer` or `Provider.of()`
  - Respond to user interactions
  - Display data provided by ViewModels
  - Remain stateless or minimal state when possible

- **Services**: Platform and infrastructure concerns
  - `NotificationService` handles local notifications and permissions
  - `ReminderStorageService`, `EventStorageService`, `PlannerStorageService`, and `HabitStorageService` manage data persistence
  - Keep platform-specific logic separate from business logic

## Dependencies

This project uses the following Flutter packages:

- **`provider`** (^6.1.2) - State management and dependency injection
- **`flutter_local_notifications`** (^19.4.2) - Local notifications for Android and iOS
- **`permission_handler`** (^12.0.1) - Runtime permission handling
- **`intl`** (^0.20.2) - Internationalization and date/time formatting
- **`timezone`** (^0.10.1) - Timezone support for scheduled notifications
- **`shared_preferences`** (^2.3.2) - Local data persistence
- **`easy_localization`** (^3.0.7) - Multi-language support
- **`cupertino_icons`** (^1.0.8) - iOS-style icons

## Getting Started

### Prerequisites

- **Flutter SDK** (3.24.0 or higher)
- **Dart SDK** (3.5.0 or higher)
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/LengTech11/notica.git
   cd notica
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK version: 21 (Android 5.0)
- Target SDK version: 34
- For notifications on Android 13+, runtime permissions are requested automatically
- Notification channels are configured in the app

#### iOS
- Minimum deployment target: iOS 12.0
- Notification permissions are requested at runtime
- Background execution modes configured for notifications
- Supports both light and dark modes

## Usage

### Working with Reminders

#### Creating a Reminder
1. Navigate to the **Reminders** tab (first tab in bottom navigation)
2. Tap the **"+"** floating action button on the reminders screen
3. Enter a **title** for your reminder (required)
4. Optionally add a **description**
5. Select a **scheduled date and time**
6. Choose a **frequency** (Once, Daily, Weekly, Weekdays, or Weekends)
7. Set a **priority level** (Low, Normal, or High)
8. Add **tags** to organize your reminders (optional)
9. Tap **"Create Reminder"**

#### Managing Reminders
- **View reminders**: See all reminders in the main list
- **Filter view**: Switch between All, Today, Upcoming, and Overdue
- **Complete a reminder**: Tap the checkbox to mark as completed
- **Edit a reminder**: Tap on a reminder to view details and edit
- **Delete a reminder**: Swipe left or use the delete option in the menu
- **Notifications**: Reminders trigger notifications at scheduled times

### Working with Calendar

#### Creating Events
1. Navigate to the **Calendar** tab (second tab in bottom navigation)
2. Tap the **"+"** floating action button
3. Enter an **event title** (required)
4. Optionally add a **description**
5. Select the **date** for your event
6. Choose if it's an **all-day event** or set specific **time**
7. Select an **event category** (Personal, Work, Health, Social, etc.)
8. Tap **"Add"** to create the event

#### Viewing Events
- **Navigate months**: Use left/right arrows to change months
- **Select dates**: Tap on any date to view events for that day
- **View today**: Tap the calendar icon to jump to today
- **Event indicators**: Small dots show days with scheduled events
- **Mark complete**: Use the menu to mark events as completed
- **Delete events**: Use the menu to remove events

### Working with Daily Planner

#### Creating Tasks
1. Navigate to the **Planner** tab (third tab in bottom navigation)
2. Tap the **"+"** floating action button
3. Enter a **task title** (required)
4. Optionally add a **description**
5. Select the **date** for your task
6. Optionally set a **specific time**
7. Choose **priority level** (Urgent, High, Normal, or Low)
8. Tap **"Add"** to create the task

#### Managing Tasks
- **Navigate dates**: Use left/right arrows or tap the date to select
- **Track progress**: View daily completion percentage
- **Check off tasks**: Tap the checkbox to mark as completed
- **Start tasks**: Use the menu to mark tasks as "In Progress"
- **View by status**: Tasks are grouped by status (In Progress, To Do, Completed)
- **Overdue alerts**: See warnings for overdue tasks
- **Delete tasks**: Use the menu to remove tasks

### Working with Habits

#### Creating a Habit
1. Navigate to the Habits section
2. Tap the **"+"** floating action button
3. Enter a **habit name** (e.g., "Drink Water", "Exercise")
4. Set a **reminder time** using the time picker
5. Tap **"Create Habit"**

#### Managing Habits
- **Complete a habit**: Tap the checkmark icon next to the habit
- **Undo completion**: Tap the undo icon if already completed
- **Track streaks**: View your consecutive completion days
- **Edit a habit**: Tap the menu button (⋮) and select "Edit"
- **Delete a habit**: Tap the menu button (⋮) and select "Delete"

### Notifications

- The app schedules notifications based on your reminder times
- Notifications work even when the app is closed
- Test notifications using the bell icon in the app bar

### Language Settings

Notica supports multiple languages:

1. **Switch languages**: Tap the menu icon (⋮) → Select "Language" / "ភាសា"
2. **Available languages**:
   - 🇬🇧 English
   - 🇰🇭 ខ្មែរ (Khmer)
3. Your language preference is saved automatically

For more details on localization, see [LOCALIZATION.md](LOCALIZATION.md)

## Key Features Explained

### Calendar System
- **Monthly View**: Intuitive calendar grid showing the entire month
- **Event Management**: Create and manage events with categories
- **Visual Indicators**: Small dots on dates show scheduled events
- **Category Colors**: Events color-coded by category for quick identification
- **All-day or Timed**: Support for both all-day and specific time events
- **Location Tracking**: Optional location field for events

### Daily Planner
- **Task Organization**: Create and organize daily tasks
- **Priority Management**: Four priority levels (Urgent, High, Normal, Low)
- **Status Tracking**: Track task status (Not Started, In Progress, Completed, Cancelled)
- **Progress Visualization**: Daily progress bar showing completion percentage
- **Overdue Alerts**: Visual warnings for tasks that are overdue
- **Time Scheduling**: Optional time scheduling for tasks

### Reminder System
- **Flexible Scheduling**: Create one-time or recurring reminders
- **Smart Filtering**: Automatically categorizes reminders by status
- **Priority Management**: Visual indicators for high-priority items
- **Tag Organization**: Group related reminders with custom tags
- **Persistence**: All data saved locally using SharedPreferences

### State Management with Provider
- Centralized state in `ReminderViewModel`, `CalendarViewModel`, `PlannerViewModel`, and `HabitViewModel`
- Uses `ChangeNotifier` for reactive updates
- Efficient rebuilds with `Consumer` widgets
- Follows Flutter's recommended state management patterns

### Notification System
- Singleton `NotificationService` manages all notifications
- Platform-specific configuration for Android and iOS
- Automatic permission handling with user-friendly prompts
- Scheduled notifications using timezone-aware scheduling
- Notification channels for better user control (Android)

### Data Persistence
- `SharedPreferences` for lightweight local storage
- JSON serialization for models
- Automatic save on data changes
- Load data on app initialization

### UI/UX Design
- **Material Design 3** with dynamic color schemes
- **System theme support** (light/dark mode)
- **Responsive layouts** that adapt to different screen sizes
- **Intuitive navigation** with bottom navigation bar
- **Accessibility features** following Flutter best practices
- **No Ads**: Completely ad-free experience focusing on user productivity

## Future Enhancements

- 💾 **Cloud sync** using Firebase or other backend services
- 📈 **Advanced analytics** with charts and insights for productivity tracking
- 🎯 **Custom categories** for better organization across all features
- 🔄 **Recurring patterns** (bi-weekly, monthly, custom intervals)
- 📱 **Home screen widgets** for quick access to today's tasks and events
- 🔊 **Custom notification sounds** and vibration patterns
- 📧 **Email/SMS reminders** for critical notifications
- 👥 **Shared calendars and tasks** for collaborative planning
- 🎨 **Customizable themes** and color schemes
- 📤 **Import/Export** functionality for backup and migration
- 🔗 **Integration with calendar apps** (Google Calendar, Apple Calendar)
- 📍 **Location-based reminders** using geofencing
- 🎙️ **Voice input** for quick task and event creation
- 📊 **Weekly/monthly reports** showing productivity statistics

## Testing

Run the tests using:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code quality
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing code style and architecture patterns
4. Write tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request with a clear description

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Format code with `dart format .`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/) - The excellent framework for building beautiful apps
- [Provider](https://pub.dev/packages/provider) - Recommended state management solution
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) - Comprehensive notification support
- The Flutter community for continuous support and inspiration

## Resources

For those new to Flutter or MVVM architecture:

- [Flutter Documentation](https://docs.flutter.dev/) - Official Flutter docs
- [Provider Documentation](https://pub.dev/documentation/provider/latest/) - State management guide
- [Flutter Architecture Samples](https://fluttersamples.com/) - Various architecture patterns
- [Effective Dart](https://dart.dev/guides/language/effective-dart) - Dart best practices
- [Material Design 3](https://m3.material.io/) - Design system guidelines
