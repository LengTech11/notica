import 'package:flutter/material.dart';
import '../services/reminder_storage_service.dart';

/// Provider for managing app theme (light/dark/system)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final ReminderStorageService _storageService = ReminderStorageService();

  ThemeMode get themeMode => _themeMode;

  /// Initialize theme from storage
  Future<void> initialize() async {
    await _storageService.initialize();
    final settings = await _storageService.loadSettings();
    final themeModeString = settings['theme_mode'] as String? ?? 'system';
    _themeMode = _themeModeFromString(themeModeString);
    notifyListeners();
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Persist to storage
    final settings = await _storageService.loadSettings();
    settings['theme_mode'] = _themeModeToString(mode);
    await _storageService.saveSettings(settings);
  }

  /// Convert ThemeMode to string for storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string from storage to ThemeMode
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Toggle between light and dark mode (skips system)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
