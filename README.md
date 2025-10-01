# Notica - Flutter Reminder & Notification App

A modern Flutter reminder and notification application built using the MVVM (Model-View-ViewModel) architecture pattern with Provider for state management, local notifications, and persistent storage.

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
- 🔍 **Smart filtering** - View upcoming, overdue, and today's reminders
- ⚡ **Real-time updates** with reactive state management

## Architecture

This app follows the **MVVM (Model-View-ViewModel)** pattern as recommended by Flutter's architecture guidelines:

### 📁 Project Structure

```
lib/
├── models/
│   ├── reminder.dart           # Reminder data model with enums
│   └── habit.dart              # Habit data model
├── viewmodels/
│   ├── reminder_viewmodel.dart # Business logic for reminders
│   └── habit_viewmodel.dart    # Business logic for habits
├── views/
│   ├── reminder_list_view.dart # Main reminders list screen
│   ├── add_reminder_view.dart  # Add/edit reminder screen
│   ├── habit_list_view.dart    # Habits list screen
│   └── add_habit_view.dart     # Add/edit habit screen
├── services/
│   ├── notification_service.dart       # Local notification handling
│   ├── reminder_storage_service.dart   # Reminder persistence
│   └── habit_storage_service.dart      # Habit persistence
└── main.dart                   # App entry point with Provider setup
```

### 🏗️ MVVM Architecture Components

Following Flutter's recommended patterns:

- **Model**: Data classes (`Reminder`, `Habit`) with business rules and serialization
  - Encapsulate data and domain logic
  - Include computed properties (e.g., `isCompletedToday`, `currentStreak`)
  - Support JSON serialization for persistence

- **ViewModel**: State management using Provider/ChangeNotifier
  - `ReminderViewModel` and `HabitViewModel` manage application state
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
  - `ReminderStorageService` and `HabitStorageService` manage data persistence
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
1. Tap the **"+"** floating action button on the reminders screen
2. Enter a **title** for your reminder (required)
3. Optionally add a **description**
4. Select a **scheduled date and time**
5. Choose a **frequency** (Once, Daily, Weekly, Weekdays, or Weekends)
6. Set a **priority level** (Low, Normal, or High)
7. Add **tags** to organize your reminders (optional)
8. Tap **"Create Reminder"**

#### Managing Reminders
- **View reminders**: See all reminders in the main list
- **Filter view**: Switch between All, Today, Upcoming, and Overdue
- **Complete a reminder**: Tap the checkbox to mark as completed
- **Edit a reminder**: Tap on a reminder to view details and edit
- **Delete a reminder**: Swipe left or use the delete option in the menu
- **Notifications**: Reminders trigger notifications at scheduled times

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
- Manage notification permissions in your device settings

## Key Features Explained

### Reminder System
- **Flexible Scheduling**: Create one-time or recurring reminders
- **Smart Filtering**: Automatically categorizes reminders by status
- **Priority Management**: Visual indicators for high-priority items
- **Tag Organization**: Group related reminders with custom tags
- **Persistence**: All data saved locally using SharedPreferences

### State Management with Provider
- Centralized state in `ReminderViewModel` and `HabitViewModel`
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
- **Intuitive navigation** with clear visual hierarchy
- **Accessibility features** following Flutter best practices

## Future Enhancements

- 💾 **Cloud sync** using Firebase or other backend services
- 📈 **Advanced analytics** with charts and insights
- 🎯 **Custom categories** for better organization
- 🔄 **Recurring patterns** (bi-weekly, monthly, custom intervals)
- 📱 **Home screen widgets** for quick access
- 🌍 **Multi-language support** with internationalization
- 🔊 **Custom notification sounds** and vibration patterns
- 📧 **Email/SMS reminders** for critical notifications
- 👥 **Shared reminders** for collaborative task management
- 🎨 **Customizable themes** and color schemes
- 📤 **Import/Export** functionality for backup and migration

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
