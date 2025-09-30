import 'package:flutter/material.dart';

enum ReminderFrequency {
  once,
  daily,
  weekly,
  weekdays,
  weekends,
}

enum ReminderPriority {
  low,
  normal,
  high,
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final ReminderFrequency frequency;
  final ReminderPriority priority;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final bool isActive;
  final bool isCompleted;
  final List<String> tags;

  Reminder({
    required this.id,
    required this.title,
    this.description = '',
    required this.scheduledTime,
    this.frequency = ReminderFrequency.once,
    this.priority = ReminderPriority.normal,
    required this.createdAt,
    List<DateTime>? completedDates,
    this.isActive = true,
    this.isCompleted = false,
    List<String>? tags,
  })  : completedDates = completedDates ?? [],
        tags = tags ?? [];

  /// Check if the reminder is completed for today
  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );
  }

  /// Get the completion streak (consecutive days) for daily reminders
  int get currentStreak {
    if (completedDates.isEmpty || frequency != ReminderFrequency.daily) {
      return 0;
    }

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

  /// Check if reminder is due now
  bool get isDue {
    final now = DateTime.now();
    return scheduledTime.isBefore(now) && !isCompleted && isActive;
  }

  /// Check if reminder is upcoming (within next hour)
  bool get isUpcoming {
    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));
    return scheduledTime.isAfter(now) &&
        scheduledTime.isBefore(oneHourFromNow) &&
        !isCompleted &&
        isActive;
  }

  /// Get time of day for the reminder
  TimeOfDay get timeOfDay {
    return TimeOfDay(hour: scheduledTime.hour, minute: scheduledTime.minute);
  }

  /// Get priority icon
  IconData get priorityIcon {
    switch (priority) {
      case ReminderPriority.high:
        return Icons.priority_high;
      case ReminderPriority.normal:
        return Icons.notifications;
      case ReminderPriority.low:
        return Icons.notifications_none;
    }
  }

  /// Get priority color
  Color get priorityColor {
    switch (priority) {
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.normal:
        return Colors.blue;
      case ReminderPriority.low:
        return Colors.grey;
    }
  }

  /// Get frequency display text
  String get frequencyText {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'One time';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.weekdays:
        return 'Weekdays';
      case ReminderFrequency.weekends:
        return 'Weekends';
    }
  }

  /// Create a copy of the reminder with updated fields
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    ReminderFrequency? frequency,
    ReminderPriority? priority,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    bool? isActive,
    bool? isCompleted,
    List<String>? tags,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? this.tags,
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'frequency': frequency.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'completedDates':
          completedDates.map((date) => date.toIso8601String()).toList(),
      'isActive': isActive,
      'isCompleted': isCompleted,
      'tags': tags,
    };
  }

  /// Create from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime']),
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ReminderFrequency.once,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ReminderPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedDates: (json['completedDates'] as List?)
              ?.map((dateString) => DateTime.parse(dateString))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Create from legacy Habit model for migration
  factory Reminder.fromHabit(Map<String, dynamic> habitJson) {
    final timeString = habitJson['reminderTime'] as String;
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final createdAt = DateTime.parse(habitJson['createdAt']);
    final scheduledTime = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
      hour,
      minute,
    );

    return Reminder(
      id: habitJson['id'],
      title: habitJson['name'],
      description: 'Migrated from habit tracker',
      scheduledTime: scheduledTime,
      frequency: ReminderFrequency.daily,
      priority: ReminderPriority.normal,
      createdAt: createdAt,
      completedDates: (habitJson['completedDates'] as List?)
              ?.map((dateString) => DateTime.parse(dateString))
              .toList() ??
          [],
      isActive: habitJson['isActive'] ?? true,
      tags: ['habit', 'migrated'],
    );
  }
}
