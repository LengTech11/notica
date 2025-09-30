import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/reminder_storage_service.dart';

class ReminderViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final ReminderStorageService _storageService = ReminderStorageService();

  // Private list of reminders
  final List<Reminder> _reminders = [];

  // Getters
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<Reminder> get activeReminders =>
      _reminders.where((reminder) => reminder.isActive).toList();
  List<Reminder> get dueReminders =>
      _reminders.where((reminder) => reminder.isDue).toList();
  List<Reminder> get upcomingReminders =>
      _reminders.where((reminder) => reminder.isUpcoming).toList();
  List<Reminder> get todaysReminders {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _reminders.where((reminder) {
      if (!reminder.isActive) return false;

      // For recurring reminders, check if they should occur today
      if (reminder.frequency != ReminderFrequency.once) {
        switch (reminder.frequency) {
          case ReminderFrequency.daily:
            return true; // Daily reminders occur every day
          case ReminderFrequency.weekly:
            final daysSinceCreated =
                today.difference(reminder.createdAt).inDays;
            return daysSinceCreated % 7 == 0;
          case ReminderFrequency.weekdays:
            return today.weekday >= 1 && today.weekday <= 5;
          case ReminderFrequency.weekends:
            return today.weekday == 6 || today.weekday == 7;
          case ReminderFrequency.once:
            break;
        }
      }

      // For one-time reminders, check if scheduled for today
      final reminderDate = reminder.scheduledTime;
      return reminderDate.isAfter(todayStart) &&
          reminderDate.isBefore(todayEnd);
    }).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize the view model
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _storageService.initialize();
      await _notificationService.initialize();
      await _loadRemindersFromStorage();
      _scheduleAllActiveReminders();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new reminder
  Future<void> addReminder({
    required String title,
    String description = '',
    required DateTime scheduledTime,
    ReminderFrequency frequency = ReminderFrequency.once,
    ReminderPriority priority = ReminderPriority.normal,
    List<String>? tags,
  }) async {
    if (title.trim().isEmpty) {
      _setError('Reminder title cannot be empty');
      return;
    }

    _clearError();

    try {
      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim(),
        scheduledTime: scheduledTime,
        frequency: frequency,
        priority: priority,
        createdAt: DateTime.now(),
        tags: tags ?? [],
      );

      _reminders.add(reminder);

      // Schedule notification for the new reminder
      await _notificationService.scheduleReminderNotification(reminder);

      // Save to local storage
      await _storageService.saveReminders(_reminders);

      notifyListeners();
    } catch (e) {
      _setError('Failed to add reminder: $e');
    }
  }

  /// Undo completion for a reminder (remove today's completion)
  Future<void> undoCompletion(String reminderId) async {
    try {
      final reminderIndex = _reminders.indexWhere((r) => r.id == reminderId);
      if (reminderIndex == -1) {
        _setError('Reminder not found');
        return;
      }

      final reminder = _reminders[reminderIndex];

      // Remove today's completion from the list
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      final updatedCompletedDates = reminder.completedDates.where((date) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        return normalizedDate != normalizedToday;
      }).toList();

      _reminders[reminderIndex] = reminder.copyWith(
        completedDates: updatedCompletedDates,
      );

      // Save to local storage
      await _storageService.saveReminders(_reminders);

      _clearError();
      notifyListeners();

      debugPrint('Reminder "${reminder.title}" completion undone');
    } catch (e) {
      _setError('Failed to undo completion: $e');
    }
  }

  /// Mark a reminder as completed
  Future<void> completeReminder(String reminderId) async {
    try {
      final reminderIndex = _reminders.indexWhere((r) => r.id == reminderId);
      if (reminderIndex == -1) {
        _setError('Reminder not found');
        return;
      }

      final reminder = _reminders[reminderIndex];

      // Check if already completed today to prevent duplicates
      if (reminder.isCompletedToday &&
          reminder.frequency != ReminderFrequency.once) {
        _setError('Reminder already completed today');
        return;
      }

      // For recurring reminders, add to completed dates
      if (reminder.frequency != ReminderFrequency.once) {
        final updatedCompletedDates =
            List<DateTime>.from(reminder.completedDates);

        // Add today's completion with normalized date (no time component)
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        updatedCompletedDates.add(normalizedToday);

        _reminders[reminderIndex] = reminder.copyWith(
          completedDates: updatedCompletedDates,
        );

        // Reschedule for next occurrence only once
        await _scheduleNextOccurrence(_reminders[reminderIndex]);
      } else {
        // For one-time reminders, mark as completed
        _reminders[reminderIndex] = reminder.copyWith(isCompleted: true);

        // Cancel notification for completed one-time reminder
        await _notificationService.cancelReminderNotifications(reminderId);
      }

      // Save to local storage
      await _storageService.saveReminders(_reminders);

      _clearError();
      notifyListeners();

      debugPrint('Reminder "${reminder.title}" completed successfully');
    } catch (e) {
      _setError('Failed to complete reminder: $e');
    }
  }

  /// Snooze a reminder (reschedule for later)
  Future<void> snoozeReminder(
      String reminderId, Duration snoozeDuration) async {
    try {
      final reminderIndex = _reminders.indexWhere((r) => r.id == reminderId);
      if (reminderIndex == -1) {
        _setError('Reminder not found');
        return;
      }

      final reminder = _reminders[reminderIndex];
      final newScheduledTime = DateTime.now().add(snoozeDuration);

      _reminders[reminderIndex] = reminder.copyWith(
        scheduledTime: newScheduledTime,
      );

      // Reschedule notification
      await _notificationService
          .scheduleReminderNotification(_reminders[reminderIndex]);

      // Save to local storage
      await _storageService.saveReminders(_reminders);

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to snooze reminder: $e');
    }
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      final reminderIndex = _reminders.indexWhere((r) => r.id == reminderId);
      if (reminderIndex == -1) {
        _setError('Reminder not found');
        return;
      }

      // Cancel notifications for this reminder
      await _notificationService.cancelReminderNotifications(reminderId);

      // Remove the reminder
      _reminders.removeAt(reminderIndex);

      // Save to local storage
      await _storageService.saveReminders(_reminders);

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete reminder: $e');
    }
  }

  /// Update reminder details
  Future<void> updateReminder({
    required String reminderId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    ReminderFrequency? frequency,
    ReminderPriority? priority,
    bool? isActive,
    List<String>? tags,
  }) async {
    try {
      final reminderIndex = _reminders.indexWhere((r) => r.id == reminderId);
      if (reminderIndex == -1) {
        _setError('Reminder not found');
        return;
      }

      final reminder = _reminders[reminderIndex];

      // Update the reminder
      _reminders[reminderIndex] = reminder.copyWith(
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        frequency: frequency,
        priority: priority,
        isActive: isActive,
        tags: tags,
      );

      // Reschedule notification if time or status changed
      if (scheduledTime != null || isActive != null) {
        if (_reminders[reminderIndex].isActive) {
          await _notificationService.scheduleReminderNotification(
            _reminders[reminderIndex],
          );
        } else {
          await _notificationService.cancelReminderNotifications(reminderId);
        }
      }

      // Save to local storage
      await _storageService.saveReminders(_reminders);

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update reminder: $e');
    }
  }

  /// Get completion percentage for today's reminders
  double get todayCompletionPercentage {
    final todaysActiveReminders = todaysReminders;
    if (todaysActiveReminders.isEmpty) return 0.0;

    final completedToday = todaysActiveReminders.where((reminder) {
      final isCompleted = reminder.frequency == ReminderFrequency.once
          ? reminder.isCompleted
          : reminder.isCompletedToday;
      debugPrint(
          'Reminder "${reminder.title}": isCompleted=$isCompleted, frequency=${reminder.frequency.name}');
      return isCompleted;
    }).length;

    final percentage = completedToday / todaysActiveReminders.length;
    debugPrint(
        'Progress: $completedToday/${todaysActiveReminders.length} = ${(percentage * 100).toInt()}%');
    debugPrint(
        'Today\'s reminders: ${todaysActiveReminders.map((r) => r.title).join(", ")}');
    return percentage;
  }

  /// Get reminder by ID
  Reminder? getReminderById(String reminderId) {
    try {
      return _reminders.firstWhere((r) => r.id == reminderId);
    } catch (e) {
      return null;
    }
  }

  /// Get reminders by priority
  List<Reminder> getRemindersByPriority(ReminderPriority priority) {
    return _reminders
        .where((r) => r.priority == priority && r.isActive)
        .toList();
  }

  /// Get reminders by tag
  List<Reminder> getRemindersByTag(String tag) {
    return _reminders.where((r) => r.tags.contains(tag) && r.isActive).toList();
  }

  /// Test notification (for debugging)
  Future<void> testNotification() async {
    try {
      debugPrint('Testing notification...');
      await _notificationService.showImmediateNotification(
        'Notica Test',
        'This is a test notification from Notica!',
      );
      debugPrint('Test notification completed');
      _clearError();
    } catch (e) {
      debugPrint('Test notification failed: $e');
      _setError('Failed to send test notification: $e');
      rethrow;
    }
  }

  /// Schedule next occurrence for recurring reminders
  Future<void> _scheduleNextOccurrence(Reminder reminder) async {
    if (reminder.frequency == ReminderFrequency.once) return;

    DateTime nextScheduledTime;
    final currentTime = reminder.scheduledTime;
    final now = DateTime.now();

    // Calculate next occurrence based on current time, not scheduled time
    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        // Next day at the same time
        nextScheduledTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          currentTime.hour,
          currentTime.minute,
        );
        break;
      case ReminderFrequency.weekly:
        nextScheduledTime = DateTime(
          now.year,
          now.month,
          now.day + 7,
          currentTime.hour,
          currentTime.minute,
        );
        break;
      case ReminderFrequency.weekdays:
        nextScheduledTime = _getNextWeekday(currentTime);
        break;
      case ReminderFrequency.weekends:
        nextScheduledTime = _getNextWeekend(currentTime);
        break;
      case ReminderFrequency.once:
        return;
    }

    // Update the reminder with new scheduled time
    final reminderIndex = _reminders.indexWhere((r) => r.id == reminder.id);
    if (reminderIndex != -1) {
      // Cancel existing notification first to prevent duplicates
      await _notificationService.cancelReminderNotifications(reminder.id);

      _reminders[reminderIndex] = reminder.copyWith(
        scheduledTime: nextScheduledTime,
      );

      // Schedule the new notification
      await _notificationService
          .scheduleReminderNotification(_reminders[reminderIndex]);

      debugPrint(
          'Rescheduled "${reminder.title}" for ${nextScheduledTime.toString()}');
    }
  }

  /// Get next weekday occurrence
  DateTime _getNextWeekday(DateTime current) {
    DateTime next = current.add(const Duration(days: 1));
    while (
        next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Get next weekend occurrence
  DateTime _getNextWeekend(DateTime current) {
    DateTime next = current.add(const Duration(days: 1));
    while (
        next.weekday != DateTime.saturday && next.weekday != DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Schedule notifications for all active reminders
  Future<void> _scheduleAllActiveReminders() async {
    for (final reminder in _reminders) {
      if (reminder.isActive && !reminder.isCompleted) {
        await _notificationService.scheduleReminderNotification(reminder);
      }
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('ReminderViewModel Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load reminders from local storage (enhanced with migration support)
  Future<void> _loadRemindersFromStorage() async {
    try {
      // Try to load existing reminders
      final loadedReminders = await _storageService.loadReminders();

      if (loadedReminders.isNotEmpty) {
        _reminders.clear();
        _reminders.addAll(loadedReminders);
        debugPrint('Loaded ${loadedReminders.length} reminders from storage');
        return;
      }

      // Migration: Check for existing habits and convert them
      final migratedReminders = await _storageService.migrateLegacyHabits();
      if (migratedReminders.isNotEmpty) {
        _reminders.clear();
        _reminders.addAll(migratedReminders);
        debugPrint('Migrated ${migratedReminders.length} habits to reminders');
        return;
      }

      // Add sample reminders for first-time users
      _reminders.addAll([
        Reminder(
          id: '1',
          title: 'Drink Water',
          description: 'Stay hydrated! Drink a glass of water',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: ReminderFrequency.daily,
          priority: ReminderPriority.normal,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          tags: ['health', 'daily'],
        ),
        Reminder(
          id: '2',
          title: 'Morning Exercise',
          description: 'Start your day with 30 minutes of exercise',
          scheduledTime: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            7,
            30,
          ),
          frequency: ReminderFrequency.weekdays,
          priority: ReminderPriority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          tags: ['fitness', 'morning'],
        ),
        Reminder(
          id: '3',
          title: 'Read Before Bed',
          description: 'Relax with 20 minutes of reading',
          scheduledTime: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            21,
            0,
          ),
          frequency: ReminderFrequency.daily,
          priority: ReminderPriority.normal,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['learning', 'evening'],
        ),
        Reminder(
          id: '4',
          title: 'Family Call',
          description: 'Call family to catch up',
          scheduledTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
          frequency: ReminderFrequency.weekly,
          priority: ReminderPriority.high,
          createdAt: DateTime.now(),
          tags: ['family', 'social'],
        ),
      ]);

      // Save sample reminders
      await _storageService.saveReminders(_reminders);
      debugPrint('Created sample reminders for new user');
    } catch (e) {
      debugPrint('Error loading reminders: $e');
    }
  }
}
