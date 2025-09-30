// Example implementation for persistent storage
// This shows how you could extend the HabitViewModel to use local storage

import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart'; // Add this dependency first
import '../models/habit.dart';

/// Example storage service - requires shared_preferences dependency
/// Add to pubspec.yaml: shared_preferences: ^2.2.2
class HabitStorageService {
  static const String _habitsKey = 'habits_storage_key';

  /// Save habits to local storage
  Future<void> saveHabits(List<Habit> habits) async {
    try {
      // Uncomment when shared_preferences is added
      // final prefs = await SharedPreferences.getInstance();
      final habitsJson = habits.map((habit) => habit.toJson()).toList();
      final jsonString = jsonEncode(habitsJson);
      // await prefs.setString(_habitsKey, jsonString);

      // For now, just print the JSON that would be saved
      print('Would save habits to key "$_habitsKey": $jsonString');
    } catch (e) {
      throw Exception('Failed to save habits: $e');
    }
  }

  /// Load habits from local storage
  Future<List<Habit>> loadHabits() async {
    try {
      // Uncomment when shared_preferences is added
      // final prefs = await SharedPreferences.getInstance();
      // final jsonString = prefs.getString(_habitsKey);

      // For now, return empty list
      const String? jsonString = null;

      if (jsonString == null) {
        return [];
      }

      final List<dynamic> habitsJson = jsonDecode(jsonString);
      return habitsJson.map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load habits: $e');
    }
  }

  /// Clear all stored habits
  Future<void> clearHabits() async {
    try {
      // Uncomment when shared_preferences is added
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove(_habitsKey);

      print('Would clear all habits from storage');
    } catch (e) {
      throw Exception('Failed to clear habits: $e');
    }
  }
}

// To use this service, add to pubspec.yaml:
// dependencies:
//   shared_preferences: ^2.2.2

// Then modify HabitViewModel to use this service:
// 1. Add HabitStorageService as a dependency
// 2. Replace _loadHabitsFromStorage() and _saveHabitsToStorage() 
//    methods to use the storage service
// 3. Handle loading states and errors appropriately