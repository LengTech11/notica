import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

class ReminderStorageService {
  static const String _remindersKey = 'notica_reminders';
  static const String _settingsKey = 'notica_settings';

  static final ReminderStorageService _instance =
      ReminderStorageService._internal();
  factory ReminderStorageService() => _instance;
  ReminderStorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('📦 Storage service initialized');
  }

  /// Save reminders to storage
  Future<void> saveReminders(List<Reminder> reminders) async {
    await _ensureInitialized();

    try {
      final List<Map<String, dynamic>> remindersList =
          reminders.map((reminder) => reminder.toJson()).toList();

      final String remindersJson = jsonEncode(remindersList);
      await _prefs!.setString(_remindersKey, remindersJson);

      debugPrint('📦 Saved ${reminders.length} reminders to storage');
    } catch (e) {
      debugPrint('📦 Error saving reminders: $e');
      rethrow;
    }
  }

  /// Load reminders from storage
  Future<List<Reminder>> loadReminders() async {
    await _ensureInitialized();

    try {
      final String? remindersJson = _prefs!.getString(_remindersKey);

      if (remindersJson == null || remindersJson.isEmpty) {
        debugPrint('📦 No reminders found in storage');
        return [];
      }

      final List<dynamic> remindersList = jsonDecode(remindersJson);
      final List<Reminder> reminders = remindersList
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📦 Loaded ${reminders.length} reminders from storage');
      return reminders;
    } catch (e) {
      debugPrint('📦 Error loading reminders: $e');
      return [];
    }
  }

  /// Save a single reminder
  Future<void> saveReminder(Reminder reminder) async {
    final reminders = await loadReminders();

    // Find and replace existing reminder or add new one
    final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);
    if (existingIndex != -1) {
      reminders[existingIndex] = reminder;
    } else {
      reminders.add(reminder);
    }

    await saveReminders(reminders);
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    final reminders = await loadReminders();
    reminders.removeWhere((reminder) => reminder.id == reminderId);
    await saveReminders(reminders);
    debugPrint('📦 Deleted reminder with ID: $reminderId');
  }

  /// Migrate legacy habit data to reminders
  Future<List<Reminder>> migrateLegacyHabits() async {
    await _ensureInitialized();

    try {
      // Check for legacy habit data
      final String? habitsJson = _prefs!.getString('habits_data');
      if (habitsJson == null) {
        return [];
      }

      final List<dynamic> habitsList = jsonDecode(habitsJson);
      final List<Reminder> migratedReminders = [];

      for (final habitData in habitsList) {
        try {
          final reminder =
              Reminder.fromHabit(habitData as Map<String, dynamic>);
          migratedReminders.add(reminder);
        } catch (e) {
          debugPrint('📦 Error migrating habit: $e');
        }
      }

      if (migratedReminders.isNotEmpty) {
        // Save migrated reminders
        await saveReminders(migratedReminders);

        // Remove legacy data
        await _prefs!.remove('habits_data');

        debugPrint(
            '📦 Migrated ${migratedReminders.length} habits to reminders');
      }

      return migratedReminders;
    } catch (e) {
      debugPrint('📦 Error during migration: $e');
      return [];
    }
  }

  /// Save app settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();

    try {
      final String settingsJson = jsonEncode(settings);
      await _prefs!.setString(_settingsKey, settingsJson);
      debugPrint('📦 Settings saved');
    } catch (e) {
      debugPrint('📦 Error saving settings: $e');
    }
  }

  /// Load app settings
  Future<Map<String, dynamic>> loadSettings() async {
    await _ensureInitialized();

    try {
      final String? settingsJson = _prefs!.getString(_settingsKey);

      if (settingsJson == null) {
        return _getDefaultSettings();
      }

      final Map<String, dynamic> settings = jsonDecode(settingsJson);
      return {..._getDefaultSettings(), ...settings};
    } catch (e) {
      debugPrint('📦 Error loading settings: $e');
      return _getDefaultSettings();
    }
  }

  /// Get default app settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'notifications_enabled': true,
      'sound_enabled': true,
      'vibration_enabled': true,
      'theme_mode': 'system', // 'light', 'dark', 'system'
      'default_reminder_priority': 'normal',
      'default_snooze_duration': 15, // minutes
      'show_completion_streaks': true,
      'first_launch': true,
    };
  }

  /// Clear all data (for debugging or reset)
  Future<void> clearAllData() async {
    await _ensureInitialized();

    await _prefs!.remove(_remindersKey);
    await _prefs!.remove(_settingsKey);
    debugPrint('📦 All data cleared');
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();

    final reminders = await loadReminders();
    final settings = await loadSettings();

    return {
      'total_reminders': reminders.length,
      'active_reminders': reminders.where((r) => r.isActive).length,
      'completed_reminders': reminders.where((r) => r.isCompleted).length,
      'due_reminders': reminders.where((r) => r.isDue).length,
      'high_priority_reminders':
          reminders.where((r) => r.priority == ReminderPriority.high).length,
      'recurring_reminders':
          reminders.where((r) => r.frequency != ReminderFrequency.once).length,
      'storage_size_kb': _estimateStorageSize(reminders, settings),
    };
  }

  /// Estimate storage size in KB
  int _estimateStorageSize(
      List<Reminder> reminders, Map<String, dynamic> settings) {
    try {
      final remindersJson =
          jsonEncode(reminders.map((r) => r.toJson()).toList());
      final settingsJson = jsonEncode(settings);
      return (remindersJson.length + settingsJson.length) ~/ 1024;
    } catch (e) {
      return 0;
    }
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  /// Export data for backup
  Future<Map<String, dynamic>> exportData() async {
    final reminders = await loadReminders();
    final settings = await loadSettings();

    return {
      'version': '1.0',
      'export_date': DateTime.now().toIso8601String(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'settings': settings,
    };
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data['version'] != '1.0') {
        throw Exception('Unsupported backup version');
      }

      // Import reminders
      final List<dynamic> remindersData = data['reminders'] ?? [];
      final List<Reminder> reminders = remindersData
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();

      await saveReminders(reminders);

      // Import settings
      final Map<String, dynamic> settings = data['settings'] ?? {};
      await saveSettings(settings);

      debugPrint(
          '📦 Data imported successfully: ${reminders.length} reminders');
    } catch (e) {
      debugPrint('📦 Error importing data: $e');
      rethrow;
    }
  }
}
