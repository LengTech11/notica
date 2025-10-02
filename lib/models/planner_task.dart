import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  normal,
  high,
  urgent,
}

enum TaskStatus {
  notStarted,
  inProgress,
  completed,
  cancelled,
}

class PlannerTask {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay? scheduledTime;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? estimatedDuration; // in minutes
  final List<String> tags;
  final String? category;

  PlannerTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.scheduledTime,
    this.priority = TaskPriority.normal,
    this.status = TaskStatus.notStarted,
    required this.createdAt,
    this.completedAt,
    this.estimatedDuration,
    List<String>? tags,
    this.category,
  }) : tags = tags ?? [];

  /// Check if task is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (status == TaskStatus.completed || status == TaskStatus.cancelled) {
      return false;
    }
    return date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Check if task is completed
  bool get isCompleted {
    return status == TaskStatus.completed;
  }

  /// Get priority color
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.normal:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.grey;
    }
  }

  /// Get priority icon
  IconData get priorityIcon {
    switch (priority) {
      case TaskPriority.urgent:
        return Icons.error;
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.normal:
        return Icons.circle;
      case TaskPriority.low:
        return Icons.circle_outlined;
    }
  }

  /// Get status icon
  IconData get statusIcon {
    switch (status) {
      case TaskStatus.notStarted:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.access_time;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  /// Create a copy with updated fields
  PlannerTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? scheduledTime,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? estimatedDuration,
    List<String>? tags,
    String? category,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'scheduledTime': scheduledTime != null
          ? '${scheduledTime!.hour}:${scheduledTime!.minute}'
          : null,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'category': category,
    };
  }

  /// Create from JSON
  factory PlannerTask.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTimeOfDay(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return PlannerTask(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      scheduledTime: parseTimeOfDay(json['scheduledTime']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.normal,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.notStarted,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      estimatedDuration: json['estimatedDuration'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
    );
  }
}
