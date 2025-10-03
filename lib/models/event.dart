import 'package:flutter/material.dart';

enum EventType {
  reminder,
  appointment,
  meeting,
  task,
  custom,
}

enum EventCategory {
  personal,
  work,
  health,
  social,
  finance,
  education,
  other,
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final EventType type;
  final EventCategory category;
  final DateTime createdAt;
  final bool isAllDay;
  final bool isCompleted;
  final Color? color;
  final String? location;
  final List<String> tags;
  final String? reminderId; // Link to reminder if created from one

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    this.endTime,
    this.type = EventType.custom,
    this.category = EventCategory.personal,
    required this.createdAt,
    this.isAllDay = false,
    this.isCompleted = false,
    this.color,
    this.location,
    List<String>? tags,
    this.reminderId,
  }) : tags = tags ?? [];

  /// Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// Check if event is in the past
  bool get isPast {
    return startTime.isBefore(DateTime.now());
  }

  /// Check if event is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return startTime.isAfter(now) &&
        startTime.difference(now).inDays <= 7;
  }

  /// Get duration in minutes
  int? get durationInMinutes {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  /// Get category color
  Color get categoryColor {
    switch (category) {
      case EventCategory.work:
        return Colors.blue;
      case EventCategory.personal:
        return Colors.purple;
      case EventCategory.health:
        return Colors.green;
      case EventCategory.social:
        return Colors.orange;
      case EventCategory.finance:
        return Colors.teal;
      case EventCategory.education:
        return Colors.indigo;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  /// Get type icon
  IconData get typeIcon {
    switch (type) {
      case EventType.reminder:
        return Icons.notifications;
      case EventType.appointment:
        return Icons.calendar_today;
      case EventType.meeting:
        return Icons.people;
      case EventType.task:
        return Icons.check_box;
      case EventType.custom:
        return Icons.event;
    }
  }

  /// Create a copy with updated fields
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    EventCategory? category,
    DateTime? createdAt,
    bool? isAllDay,
    bool? isCompleted,
    Color? color,
    String? location,
    List<String>? tags,
    String? reminderId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isAllDay: isAllDay ?? this.isAllDay,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      reminderId: reminderId ?? this.reminderId,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'type': type.name,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'isAllDay': isAllDay,
      'isCompleted': isCompleted,
      'color': color?.value,
      'location': location,
      'tags': tags,
      'reminderId': reminderId,
    };
  }

  /// Create from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.custom,
      ),
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.personal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isAllDay: json['isAllDay'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      color: json['color'] != null ? Color(json['color']) : null,
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      reminderId: json['reminderId'],
    );
  }
}
