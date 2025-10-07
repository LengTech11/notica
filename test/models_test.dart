import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notica/models/event.dart';
import 'package:notica/models/planner_task.dart';

void main() {
  group('Event Model Tests', () {
    test('Event can be created with required fields', () {
      final event = Event(
        id: '1',
        title: 'Test Event',
        startTime: DateTime(2024, 1, 1, 10, 0),
        createdAt: DateTime.now(),
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.isAllDay, false);
      expect(event.isCompleted, false);
    });

    test('Event can be converted to and from JSON', () {
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startTime: DateTime(2024, 1, 1, 10, 0),
        category: EventCategory.work,
        type: EventType.meeting,
        createdAt: DateTime.now(),
      );

      final json = event.toJson();
      final reconstructed = Event.fromJson(json);

      expect(reconstructed.id, event.id);
      expect(reconstructed.title, event.title);
      expect(reconstructed.description, event.description);
      expect(reconstructed.category, event.category);
      expect(reconstructed.type, event.type);
    });

    test('Event isToday returns correct value', () {
      final today = DateTime.now();
      final todayEvent = Event(
        id: '1',
        title: 'Today Event',
        startTime: today,
        createdAt: DateTime.now(),
      );

      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayEvent = Event(
        id: '2',
        title: 'Yesterday Event',
        startTime: yesterday,
        createdAt: DateTime.now(),
      );

      expect(todayEvent.isToday, true);
      expect(yesterdayEvent.isToday, false);
    });
  });

  group('PlannerTask Model Tests', () {
    test('PlannerTask can be created with required fields', () {
      final task = PlannerTask(
        id: '1',
        title: 'Test Task',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime.now(),
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.priority, TaskPriority.normal);
      expect(task.status, TaskStatus.notStarted);
    });

    test('PlannerTask can be converted to and from JSON', () {
      final task = PlannerTask(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        date: DateTime(2024, 1, 1),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        createdAt: DateTime.now(),
      );

      final json = task.toJson();
      final reconstructed = PlannerTask.fromJson(json);

      expect(reconstructed.id, task.id);
      expect(reconstructed.title, task.title);
      expect(reconstructed.description, task.description);
      expect(reconstructed.priority, task.priority);
      expect(reconstructed.status, task.status);
    });

    test('PlannerTask isCompleted returns correct value', () {
      final completedTask = PlannerTask(
        id: '1',
        title: 'Completed Task',
        date: DateTime.now(),
        status: TaskStatus.completed,
        createdAt: DateTime.now(),
      );

      final notCompletedTask = PlannerTask(
        id: '2',
        title: 'Not Completed Task',
        date: DateTime.now(),
        status: TaskStatus.notStarted,
        createdAt: DateTime.now(),
      );

      expect(completedTask.isCompleted, true);
      expect(notCompletedTask.isCompleted, false);
    });

    test('PlannerTask isOverdue returns correct value for past date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final overdueTask = PlannerTask(
        id: '1',
        title: 'Overdue Task',
        date: yesterday,
        status: TaskStatus.notStarted,
        createdAt: DateTime.now(),
      );

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final futureTask = PlannerTask(
        id: '2',
        title: 'Future Task',
        date: tomorrow,
        status: TaskStatus.notStarted,
        createdAt: DateTime.now(),
      );

      expect(overdueTask.isOverdue, true);
      expect(futureTask.isOverdue, false);
    });

    test('Completed tasks are not overdue', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final completedTask = PlannerTask(
        id: '1',
        title: 'Completed Overdue Task',
        date: yesterday,
        status: TaskStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(completedTask.isOverdue, false);
    });

    test('PlannerTask copyWith creates a new instance with updated fields', () {
      final originalTask = PlannerTask(
        id: '1',
        title: 'Original Task',
        description: 'Original Description',
        date: DateTime(2024, 1, 1),
        priority: TaskPriority.normal,
        status: TaskStatus.notStarted,
        createdAt: DateTime.now(),
      );

      final updatedTask = originalTask.copyWith(
        title: 'Updated Task',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
      );

      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.priority, TaskPriority.high);
      expect(updatedTask.status, TaskStatus.inProgress);
      expect(updatedTask.description, 'Original Description'); // Unchanged
      expect(updatedTask.id, originalTask.id); // Same ID
    });

    test('PlannerTask priority color matches expected colors', () {
      final urgentTask = PlannerTask(
        id: '1',
        title: 'Urgent Task',
        date: DateTime.now(),
        priority: TaskPriority.urgent,
        createdAt: DateTime.now(),
      );

      final normalTask = PlannerTask(
        id: '2',
        title: 'Normal Task',
        date: DateTime.now(),
        priority: TaskPriority.normal,
        createdAt: DateTime.now(),
      );

      expect(urgentTask.priorityColor, Colors.red);
      expect(normalTask.priorityColor, Colors.blue);
    });

    test('PlannerTask status color matches expected colors', () {
      final completedTask = PlannerTask(
        id: '1',
        title: 'Completed Task',
        date: DateTime.now(),
        status: TaskStatus.completed,
        createdAt: DateTime.now(),
      );

      final inProgressTask = PlannerTask(
        id: '2',
        title: 'In Progress Task',
        date: DateTime.now(),
        status: TaskStatus.inProgress,
        createdAt: DateTime.now(),
      );

      expect(completedTask.statusColor, Colors.green);
      expect(inProgressTask.statusColor, Colors.blue);
    });
  });
}
