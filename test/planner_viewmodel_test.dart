import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notica/models/planner_task.dart';
import 'package:notica/viewmodels/planner_viewmodel.dart';

void main() {
  group('PlannerViewModel Tests', () {
    late PlannerViewModel viewModel;

    setUp(() {
      viewModel = PlannerViewModel();
    });

    test('PlannerViewModel initializes with empty task list', () {
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.todayTasks, isEmpty);
      expect(viewModel.overdueTasks, isEmpty);
    });

    test('addTask adds a new task to the list', () async {
      await viewModel.addTask(
        title: 'Test Task',
        description: 'Test Description',
        date: DateTime.now(),
        priority: TaskPriority.high,
      );

      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.title, 'Test Task');
      expect(viewModel.tasks.first.priority, TaskPriority.high);
    });

    test('updateTask updates an existing task', () async {
      await viewModel.addTask(
        title: 'Original Task',
        date: DateTime.now(),
      );

      final task = viewModel.tasks.first;
      final updatedTask = task.copyWith(
        title: 'Updated Task',
        priority: TaskPriority.urgent,
      );

      await viewModel.updateTask(updatedTask);

      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.title, 'Updated Task');
      expect(viewModel.tasks.first.priority, TaskPriority.urgent);
    });

    test('deleteTask removes a task from the list', () async {
      await viewModel.addTask(
        title: 'Task to Delete',
        date: DateTime.now(),
      );

      expect(viewModel.tasks.length, 1);
      final taskId = viewModel.tasks.first.id;

      await viewModel.deleteTask(taskId);

      expect(viewModel.tasks.length, 0);
    });

    test('toggleTaskCompletion toggles task status', () async {
      await viewModel.addTask(
        title: 'Task to Complete',
        date: DateTime.now(),
      );

      final taskId = viewModel.tasks.first.id;
      expect(viewModel.tasks.first.status, TaskStatus.notStarted);

      await viewModel.toggleTaskCompletion(taskId);

      expect(viewModel.tasks.first.status, TaskStatus.completed);
      expect(viewModel.tasks.first.completedAt, isNotNull);

      await viewModel.toggleTaskCompletion(taskId);

      expect(viewModel.tasks.first.status, TaskStatus.notStarted);
    });

    test('getTasksForDate returns tasks for specific date', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      await viewModel.addTask(title: 'Today Task', date: today);
      await viewModel.addTask(title: 'Tomorrow Task', date: tomorrow);

      final todayTasks = viewModel.getTasksForDate(today);
      final tomorrowTasks = viewModel.getTasksForDate(tomorrow);

      expect(todayTasks.length, 1);
      expect(todayTasks.first.title, 'Today Task');
      expect(tomorrowTasks.length, 1);
      expect(tomorrowTasks.first.title, 'Tomorrow Task');
    });

    test('getTasksByPriority filters tasks by priority', () async {
      await viewModel.addTask(
        title: 'High Priority Task',
        date: DateTime.now(),
        priority: TaskPriority.high,
      );
      await viewModel.addTask(
        title: 'Normal Priority Task',
        date: DateTime.now(),
        priority: TaskPriority.normal,
      );

      final highPriorityTasks = viewModel.getTasksByPriority(TaskPriority.high);
      final normalPriorityTasks = viewModel.getTasksByPriority(TaskPriority.normal);

      expect(highPriorityTasks.length, 1);
      expect(highPriorityTasks.first.title, 'High Priority Task');
      expect(normalPriorityTasks.length, 1);
      expect(normalPriorityTasks.first.title, 'Normal Priority Task');
    });

    test('getTasksByStatus filters tasks by status', () async {
      await viewModel.addTask(
        title: 'Task 1',
        date: DateTime.now(),
      );
      await viewModel.addTask(
        title: 'Task 2',
        date: DateTime.now(),
      );

      final taskId = viewModel.tasks.first.id;
      await viewModel.updateTaskStatus(taskId, TaskStatus.inProgress);

      final notStartedTasks = viewModel.getTasksByStatus(TaskStatus.notStarted);
      final inProgressTasks = viewModel.getTasksByStatus(TaskStatus.inProgress);

      expect(notStartedTasks.length, 1);
      expect(inProgressTasks.length, 1);
      expect(inProgressTasks.first.status, TaskStatus.inProgress);
    });

    test('overdueTasks returns only overdue tasks', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      await viewModel.addTask(
        title: 'Overdue Task',
        date: yesterday,
      );
      await viewModel.addTask(
        title: 'Future Task',
        date: tomorrow,
      );

      expect(viewModel.overdueTasks.length, 1);
      expect(viewModel.overdueTasks.first.title, 'Overdue Task');
    });

    test('todayCompletionPercentage calculates correctly', () async {
      final today = DateTime.now();

      await viewModel.addTask(title: 'Task 1', date: today);
      await viewModel.addTask(title: 'Task 2', date: today);
      await viewModel.addTask(title: 'Task 3', date: today);

      expect(viewModel.todayCompletionPercentage, 0.0);

      await viewModel.toggleTaskCompletion(viewModel.todayTasks[0].id);

      expect(viewModel.todayCompletionPercentage, closeTo(33.33, 0.1));

      await viewModel.toggleTaskCompletion(viewModel.todayTasks[1].id);
      await viewModel.toggleTaskCompletion(viewModel.todayTasks[2].id);

      expect(viewModel.todayCompletionPercentage, 100.0);
    });

    test('empty task title is rejected', () async {
      await viewModel.addTask(
        title: '',
        date: DateTime.now(),
      );

      expect(viewModel.tasks.length, 0);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('trimmed task title is stored', () async {
      await viewModel.addTask(
        title: '  Task with spaces  ',
        description: '  Description with spaces  ',
        date: DateTime.now(),
      );

      expect(viewModel.tasks.first.title, 'Task with spaces');
      expect(viewModel.tasks.first.description, 'Description with spaces');
    });
  });
}
