import 'package:flutter/material.dart';
import '../models/planner_task.dart';
import '../services/planner_storage_service.dart';

class PlannerViewModel extends ChangeNotifier {
  final PlannerStorageService _storageService = PlannerStorageService();

  // Private list of tasks
  final List<PlannerTask> _tasks = [];

  // Getters
  List<PlannerTask> get tasks => List.unmodifiable(_tasks);
  
  List<PlannerTask> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.date.year == today.year &&
          task.date.month == today.month &&
          task.date.day == today.day;
    }).toList()
      ..sort((a, b) {
        // Sort by priority first, then by scheduled time
        final priorityComparison = b.priority.index.compareTo(a.priority.index);
        if (priorityComparison != 0) return priorityComparison;
        
        if (a.scheduledTime != null && b.scheduledTime != null) {
          final aMinutes = a.scheduledTime!.hour * 60 + a.scheduledTime!.minute;
          final bMinutes = b.scheduledTime!.hour * 60 + b.scheduledTime!.minute;
          return aMinutes.compareTo(bMinutes);
        }
        return 0;
      });
  }

  List<PlannerTask> get overdueTasks {
    return _tasks.where((task) => task.isOverdue).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<PlannerTask> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  int get todayCompletedCount {
    return todayTasks.where((task) => task.isCompleted).length;
  }

  int get todayTotalCount {
    return todayTasks.length;
  }

  double get todayCompletionPercentage {
    if (todayTotalCount == 0) return 0.0;
    return (todayCompletedCount / todayTotalCount) * 100;
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
      await _loadTasksFromStorage();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new task
  Future<void> addTask({
    required String title,
    String description = '',
    required DateTime date,
    TimeOfDay? scheduledTime,
    TaskPriority priority = TaskPriority.normal,
    int? estimatedDuration,
    List<String>? tags,
    String? category,
  }) async {
    if (title.trim().isEmpty) {
      _setError('Task title cannot be empty');
      return;
    }

    _clearError();

    try {
      final task = PlannerTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim(),
        date: date,
        scheduledTime: scheduledTime,
        priority: priority,
        createdAt: DateTime.now(),
        estimatedDuration: estimatedDuration,
        tags: tags ?? [],
        category: category,
      );

      _tasks.add(task);
      await _storageService.saveTask(task);

      notifyListeners();
      debugPrint('✅ Added task: ${task.title}');
    } catch (e) {
      _setError('Failed to add task: $e');
      debugPrint('❌ Error adding task: $e');
    }
  }

  /// Update an existing task
  Future<void> updateTask(PlannerTask updatedTask) async {
    _clearError();

    try {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        await _storageService.saveTask(updatedTask);

        notifyListeners();
        debugPrint('✅ Updated task: ${updatedTask.title}');
      }
    } catch (e) {
      _setError('Failed to update task: $e');
      debugPrint('❌ Error updating task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    _clearError();

    try {
      _tasks.removeWhere((task) => task.id == taskId);
      await _storageService.deleteTask(taskId);

      notifyListeners();
      debugPrint('✅ Deleted task');
    } catch (e) {
      _setError('Failed to delete task: $e');
      debugPrint('❌ Error deleting task: $e');
    }
  }

  /// Update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(
        status: status,
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      );
      await updateTask(updatedTask);
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = task.status == TaskStatus.completed
          ? TaskStatus.notStarted
          : TaskStatus.completed;
      await updateTaskStatus(taskId, newStatus);
    }
  }

  /// Get tasks for a specific date
  List<PlannerTask> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  /// Get tasks by priority
  List<PlannerTask> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((t) => t.priority == priority).toList();
  }

  /// Get tasks by status
  List<PlannerTask> getTasksByStatus(TaskStatus status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  /// Load tasks from storage
  Future<void> _loadTasksFromStorage() async {
    try {
      final loadedTasks = await _storageService.loadTasks();
      _tasks.clear();
      _tasks.addAll(loadedTasks);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: $e');
    }
  }

  /// Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
