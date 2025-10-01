# Habit Tracker - Flutter MVVM App

A Flutter habit tracking application built using the MVVM (Model-View-ViewModel) architecture pattern with Provider for state management and local notifications for reminders.

## Features

- ✅ **Add new habits** with custom names and reminder times
- 📋 **View all habits** in an organized list
- ✔️ **Mark habits as completed** for the current day
- 🔔 **Local notifications** to remind you about your habits
- 📊 **Progress tracking** with daily completion percentage
- 🔥 **Streak counter** to track consecutive days
- ✏️ **Edit existing habits** (name and reminder time)
- 🗑️ **Delete habits** with confirmation dialog
- 🌙 **Dark mode support** (follows system preference)
- 🌍 **Multi-language support** - English and Khmer (ខ្មែរ)

## Architecture

This app follows the **MVVM (Model-View-ViewModel)** pattern:

### 📁 Project Structure

```
lib/
├── models/
│   └── habit.dart              # Habit data model
├── viewmodels/
│   └── habit_viewmodel.dart    # Business logic and state management
├── views/
│   ├── habit_list_view.dart    # Main habits list screen
│   └── add_habit_view.dart     # Add/edit habit screen
├── services/
│   └── notification_service.dart # Local notification handling
├── providers/
│   └── locale_provider.dart    # Language preference management
├── l10n/
│   ├── app_en.arb             # English translations
│   └── app_km.arb             # Khmer translations
└── main.dart                   # App entry point with Provider setup
```

### 🏗️ Architecture Components

- **Model**: `Habit` class with properties and business rules
- **ViewModel**: `HabitViewModel` manages state using Provider/ChangeNotifier
- **View**: UI components (`HabitListView`, `AddHabitView`) that observe ViewModel
- **Service**: `NotificationService` handles local notifications
- **Localization**: ARB files for multi-language support

## Multi-Language Support

The app supports the following languages:
- 🇬🇧 English (en)
- 🇰🇭 Khmer / ខ្មែរ (km)

### Changing Language

1. Open the app
2. Tap the menu button (⋮) in the top-right corner
3. Select "Language" / "ភាសា"
4. Choose your preferred language
5. The app will immediately switch to the selected language

The selected language preference is saved and will persist across app restarts.

## Dependencies

- **`provider`** (^6.1.2) - State management and dependency injection
- **`flutter_local_notifications`** (^17.2.2) - Local notifications
- **`flutter_localizations`** - Multi-language support
- **`permission_handler`** (^11.3.1) - Notification permissions
- **`intl`** (^0.19.0) - Date/time formatting utilities

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd flutter_good
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
- No additional setup required for basic functionality
- For notifications on Android 13+, the app automatically requests permissions

#### iOS
- Notification permissions are requested automatically
- The app supports both light and dark modes

## Usage

### Adding a New Habit

1. Tap the **"+"** floating action button
2. Enter a habit name (e.g., "Drink Water", "Exercise")
3. Set a reminder time using the time picker
4. Tap **"Create Habit"**

### Managing Habits

- **Complete a habit**: Tap the checkmark icon next to the habit
- **Undo completion**: Tap the undo icon if the habit is already completed
- **Edit a habit**: Tap the menu button (⋮) and select "Edit"
- **Delete a habit**: Tap the menu button (⋮) and select "Delete"

### Notifications

- The app schedules daily reminders at your chosen time
- Test notifications by tapping the bell icon in the app bar
- Notifications work even when the app is closed

## Key Features Explained

### Habit Model
- Tracks habit name, reminder time, creation date, and completion history
- Calculates current streak and today's completion status
- Supports JSON serialization for future local storage implementation

### State Management
- Uses Provider pattern with ChangeNotifier
- Centralized state management in HabitViewModel
- Reactive UI updates when state changes

### Notification System
- Singleton NotificationService for managing all notifications
- Platform-specific configuration for Android and iOS
- Automatic permission handling

### UI/UX
- Material Design 3 with dynamic theming
- Progress indicator showing daily completion percentage
- Streak counter with fire emoji for motivation
- Responsive design that works on various screen sizes

## Future Enhancements

- 💾 **Persistent storage** using SQLite or Hive
- 📈 **Advanced analytics** and habit insights
- 🎯 **Custom habit categories** and icons
- ⏰ **Multiple reminders** per habit
- 📱 **Widget support** for quick access
- 🔄 **Data backup** and synchronization
- 🏆 **Achievement system** and rewards

## Testing

Run the tests using:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code quality
flutter analyze
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the excellent framework
- Provider package maintainers for state management
- flutter_local_notifications plugin for notification support

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
