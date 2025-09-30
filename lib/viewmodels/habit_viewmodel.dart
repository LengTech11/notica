import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';

class HabitViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // Private list of habits
  final List<Habit> _habits = [];

  // Getters
  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get activeHabits =>
      _habits.where((habit) => habit.isActive).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize the view model
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _notificationService.initialize();
      // In a real app, you would load habits from local storage here
      await _loadHabitsFromStorage();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new habit
  Future<void> addHabit({
    required String name,
    required TimeOfDay reminderTime,
  }) async {
    if (name.trim().isEmpty) {
      _setError('Habit name cannot be empty');
      return;
    }

    _clearError();

    try {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        reminderTime: reminderTime,
        createdAt: DateTime.now(),
      );

      _habits.add(habit);

      // Schedule notification for the new habit
      await _notificationService.scheduleHabitNotification(habit);

      // Save to local storage (in a real app)
      await _saveHabitsToStorage();

      notifyListeners();
    } catch (e) {
      _setError('Failed to add habit: $e');
    }
  }

  /// Mark a habit as completed for today
  Future<void> completeHabit(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        _setError('Habit not found');
        return;
      }

      final habit = _habits[habitIndex];

      // Check if already completed today
      if (habit.isCompletedToday) {
        _setError('Habit already completed today');
        return;
      }

      // Add today's completion
      final updatedCompletedDates = List<DateTime>.from(habit.completedDates);
      updatedCompletedDates.add(DateTime.now());

      // Update the habit
      _habits[habitIndex] = habit.copyWith(
        completedDates: updatedCompletedDates,
      );

      // Save to local storage
      await _saveHabitsToStorage();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete habit: $e');
    }
  }

  /// Undo habit completion for today
  Future<void> uncompleteHabit(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        _setError('Habit not found');
        return;
      }

      final habit = _habits[habitIndex];

      // Remove today's completion if it exists
      final today = DateTime.now();
      final updatedCompletedDates = habit.completedDates
          .where(
            (date) =>
                !(date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day),
          )
          .toList();

      // Update the habit
      _habits[habitIndex] = habit.copyWith(
        completedDates: updatedCompletedDates,
      );

      // Save to local storage
      await _saveHabitsToStorage();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to uncomplete habit: $e');
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        _setError('Habit not found');
        return;
      }

      // Cancel notifications for this habit
      await _notificationService.cancelHabitNotifications(habitId);

      // Remove the habit
      _habits.removeAt(habitIndex);

      // Save to local storage
      await _saveHabitsToStorage();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete habit: $e');
    }
  }

  /// Update habit details
  Future<void> updateHabit({
    required String habitId,
    String? name,
    TimeOfDay? reminderTime,
    bool? isActive,
  }) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        _setError('Habit not found');
        return;
      }

      final habit = _habits[habitIndex];

      // Update the habit
      _habits[habitIndex] = habit.copyWith(
        name: name,
        reminderTime: reminderTime,
        isActive: isActive,
      );

      // If reminder time changed, reschedule notification
      if (reminderTime != null) {
        await _notificationService.scheduleHabitNotification(
          _habits[habitIndex],
        );
      }

      // Save to local storage
      await _saveHabitsToStorage();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update habit: $e');
    }
  }

  /// Get completion percentage for today
  double get todayCompletionPercentage {
    if (_habits.isEmpty) return 0.0;

    final activeHabits = _habits.where((h) => h.isActive).toList();
    if (activeHabits.isEmpty) return 0.0;

    final completedToday = activeHabits.where((h) => h.isCompletedToday).length;
    return completedToday / activeHabits.length;
  }

  /// Get habit by ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  /// Test notification (for debugging)
  Future<void> testNotification() async {
    try {
      debugPrint('🎯 HabitViewModel: Testing notification...');
      await _notificationService.showImmediateNotification(
        'Test Notification',
        'This is a test notification from your Habit Tracker!',
      );
      debugPrint('🎯 HabitViewModel: Test notification completed');
      _clearError(); // Clear any previous errors on success
    } catch (e) {
      debugPrint('🎯 HabitViewModel: Test notification failed: $e');
      _setError('Failed to send test notification: $e');
      rethrow; // Rethrow so the UI can handle it
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('HabitViewModel Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load habits from local storage (mock implementation)
  Future<void> _loadHabitsFromStorage() async {
    // In a real app, you would load from SharedPreferences, SQLite, etc.
    // For now, we'll add some sample data
    await Future.delayed(const Duration(milliseconds: 500));

    // Add sample habits for demonstration
    if (_habits.isEmpty) {
      _habits.addAll([
        Habit(
          id: '1',
          name: 'Drink Water',
          reminderTime: const TimeOfDay(hour: 8, minute: 0),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          completedDates: [
            DateTime.now().subtract(const Duration(days: 2)),
            DateTime.now().subtract(const Duration(days: 1)),
          ],
        ),
        Habit(
          id: '2',
          name: 'Exercise',
          reminderTime: const TimeOfDay(hour: 7, minute: 30),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedDates: [DateTime.now().subtract(const Duration(days: 1))],
        ),
        Habit(
          id: '3',
          name: 'Read Books',
          reminderTime: const TimeOfDay(hour: 21, minute: 0),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);

      // Schedule notifications for all habits
      for (final habit in _habits) {
        await _notificationService.scheduleHabitNotification(habit);
      }
    }
  }

  /// Save habits to local storage (mock implementation)
  Future<void> _saveHabitsToStorage() async {
    // In a real app, you would save to SharedPreferences, SQLite, etc.
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('Habits saved to storage');
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
