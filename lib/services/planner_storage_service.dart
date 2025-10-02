import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/planner_task.dart';

class PlannerStorageService {
  static const String _tasksKey = 'notica_planner_tasks';

  static final PlannerStorageService _instance =
      PlannerStorageService._internal();
  factory PlannerStorageService() => _instance;
  PlannerStorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('📋 Planner storage service initialized');
  }

  /// Ensure initialized before operations
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save tasks to storage
  Future<void> saveTasks(List<PlannerTask> tasks) async {
    await _ensureInitialized();

    try {
      final List<Map<String, dynamic>> tasksList =
          tasks.map((task) => task.toJson()).toList();

      final String tasksJson = jsonEncode(tasksList);
      await _prefs!.setString(_tasksKey, tasksJson);

      debugPrint('📋 Saved ${tasks.length} tasks to storage');
    } catch (e) {
      debugPrint('📋 Error saving tasks: $e');
      rethrow;
    }
  }

  /// Load tasks from storage
  Future<List<PlannerTask>> loadTasks() async {
    await _ensureInitialized();

    try {
      final String? tasksJson = _prefs!.getString(_tasksKey);

      if (tasksJson == null || tasksJson.isEmpty) {
        debugPrint('📋 No tasks found in storage');
        return [];
      }

      final List<dynamic> tasksList = jsonDecode(tasksJson);
      final List<PlannerTask> tasks = tasksList
          .map((json) => PlannerTask.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📋 Loaded ${tasks.length} tasks from storage');
      return tasks;
    } catch (e) {
      debugPrint('📋 Error loading tasks: $e');
      return [];
    }
  }

  /// Save a single task
  Future<void> saveTask(PlannerTask task) async {
    final tasks = await loadTasks();

    // Find and replace existing task or add new one
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex != -1) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }

    await saveTasks(tasks);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
    debugPrint('📋 Deleted task with ID: $taskId');
  }

  /// Clear all tasks
  Future<void> clearAllTasks() async {
    await _ensureInitialized();
    await _prefs!.remove(_tasksKey);
    debugPrint('📋 Cleared all tasks');
  }
}
