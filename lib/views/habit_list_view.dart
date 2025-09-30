import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/habit.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../services/notification_service.dart';
import 'add_habit_view.dart';

class HabitListView extends StatelessWidget {
  const HabitListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _testNotification(context),
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: Consumer<HabitViewModel>(
        builder: (context, habitViewModel, child) {
          if (habitViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (habitViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    habitViewModel.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => habitViewModel.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final habits = habitViewModel.activeHabits;

          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.track_changes_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start building good habits by tapping the + button',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressCard(context, habitViewModel),

              // Habits list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return _buildHabitCard(context, habit, habitViewModel);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabit(context),
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    HabitViewModel habitViewModel,
  ) {
    final completionPercentage = habitViewModel.todayCompletionPercentage;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completionPercentage,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(completionPercentage * 100).toInt()}% completed',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    Habit habit,
    HabitViewModel habitViewModel,
  ) {
    final isCompleted = habit.isCompletedToday;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            isCompleted ? Icons.check : Icons.track_changes,
            color: isCompleted
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder: ${_formatTime(habit.reminderTime)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (habit.currentStreak > 0)
              Text(
                '🔥 ${habit.currentStreak} day streak',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted)
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: () => habitViewModel.uncompleteHabit(habit.id),
                tooltip: 'Undo completion',
              )
            else
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => habitViewModel.completeHabit(habit.id),
                tooltip: 'Mark as completed',
              ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(context, habit, value, habitViewModel),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _handleMenuAction(
    BuildContext context,
    Habit habit,
    String action,
    HabitViewModel habitViewModel,
  ) {
    switch (action) {
      case 'edit':
        _editHabit(context, habit, habitViewModel);
        break;
      case 'delete':
        _deleteHabit(context, habit, habitViewModel);
        break;
    }
  }

  void _editHabit(
    BuildContext context,
    Habit habit,
    HabitViewModel habitViewModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHabitView(habitToEdit: habit)),
    );
  }

  void _deleteHabit(
    BuildContext context,
    Habit habit,
    HabitViewModel habitViewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              habitViewModel.deleteHabit(habit.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitView()),
    );
  }

  void _testNotification(BuildContext context) async {
    final notificationService = NotificationService();

    try {
      // Run comprehensive diagnostic
      await notificationService.runNotificationDiagnostic();

      // Show immediate notification and 5-second delayed notification
      await notificationService.showImmediateNotification(
        'Test Notification (Immediate)',
        'This is an immediate test notification!',
      );

      await notificationService.showTestNotificationIn5Seconds();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '🔔 Diagnostic complete! Check console output and device for notifications.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showPermissionDialog(context, e.toString());
      }
    }
  }

  void _showPermissionDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_off, size: 48),
        title: const Text('Notifications Disabled'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error.contains('permanently')
                  ? 'Notification permissions have been permanently denied. To receive habit reminders, please:'
                  : 'Notifications are currently disabled. To receive habit reminders:',
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Go to device Settings\n'
              '2. Find this app\n'
              '3. Enable Notifications\n'
              '4. Return to the app',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Try to open settings
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
