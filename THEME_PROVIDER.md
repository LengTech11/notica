# Theme Provider Implementation

This implementation adds dark/light mode theme switching capability to the Notica app.

## Features

- **Three Theme Modes**: Light, Dark, and System (follows device settings)
- **Persistent Storage**: Theme preference is saved and restored across app restarts
- **User-Friendly UI**: Theme selector accessible via the menu in the app bar
- **State Management**: Uses Provider pattern for reactive theme updates

## Architecture

### ThemeProvider (`lib/providers/theme_provider.dart`)
- Extends `ChangeNotifier` for state management
- Integrates with `ReminderStorageService` for persistence
- Provides methods:
  - `initialize()`: Loads theme preference from storage
  - `setThemeMode(ThemeMode)`: Changes and persists theme
  - `toggleTheme()`: Quick toggle between light and dark
  - `themeMode`: Getter for current theme

### Integration Points

1. **main.dart**: 
   - Uses `MultiProvider` to inject both `ReminderViewModel` and `ThemeProvider`
   - `Consumer<ThemeProvider>` wraps `MaterialApp` to react to theme changes
   - ThemeProvider initialized on app start

2. **reminder_list_view.dart**:
   - Theme menu option in PopupMenuButton
   - Theme selection dialog with radio buttons
   - Shows current theme in the menu subtitle

3. **Storage**:
   - Theme preference stored in SharedPreferences via `ReminderStorageService`
   - Key: `theme_mode`
   - Values: `'light'`, `'dark'`, `'system'`

## Usage

Users can change the theme by:
1. Tapping the menu button (three dots) in the app bar
2. Selecting "Theme" option
3. Choosing from Light, Dark, or System options
4. Theme changes immediately and persists across app restarts

## Testing

Unit tests are provided in `test/theme_provider_test.dart` covering:
- Initial state
- Theme mode changes
- Theme toggling
- Persistence behavior
