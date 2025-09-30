import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final TimeOfDay reminderTime;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final bool isActive;

  Habit({
    required this.id,
    required this.name,
    required this.reminderTime,
    required this.createdAt,
    List<DateTime>? completedDates,
    this.isActive = true,
  }) : completedDates = completedDates ?? [];

  /// Check if the habit is completed for today
  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );
  }

  /// Get the completion streak (consecutive days)
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    var currentDate = DateTime(today.year, today.month, today.day);

    for (final completedDate in sortedDates) {
      final completed = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      if (completed == currentDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (completed == currentDate.add(const Duration(days: 1))) {
        // If today is not completed but yesterday is
        currentDate = completed.subtract(const Duration(days: 1));
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Create a copy of the habit with updated fields
  Habit copyWith({
    String? id,
    String? name,
    TimeOfDay? reminderTime,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON (for local storage if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates
          .map((date) => date.toIso8601String())
          .toList(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    final timeString = json['reminderTime'] as String;
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return Habit(
      id: json['id'],
      name: json['name'],
      reminderTime: TimeOfDay(hour: hour, minute: minute),
      createdAt: DateTime.parse(json['createdAt']),
      completedDates: (json['completedDates'] as List)
          .map((dateString) => DateTime.parse(dateString))
          .toList(),
      isActive: json['isActive'] ?? true,
    );
  }
}
