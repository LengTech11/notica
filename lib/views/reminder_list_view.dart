import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/reminder.dart';
import '../viewmodels/reminder_viewmodel.dart';
import '../services/notification_service.dart';
import '../providers/theme_provider.dart';
import 'add_reminder_view.dart';
import 'onboarding_view.dart';
import 'push_notification_test_view.dart';

class ReminderListView extends StatelessWidget {
  const ReminderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text('app_name'.tr()),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => _testNotification(context),
            tooltip: 'menu.test_notification'.tr(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'push_test',
                child: ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Push Notification Test'),
                ),
              ),
              PopupMenuItem(
                value: 'language',
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('menu.language'.tr()),
                  subtitle: Text(context.locale.languageCode == 'km' ? 'ខ្មែរ' : 'English'),
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text('menu.theme'.tr()),
                  subtitle: Text(_getThemeModeText(context)),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text('menu.settings'.tr()),
                ),
              ),
              PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('menu.about'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ReminderViewModel>(
        builder: (context, reminderViewModel, child) {
          if (reminderViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reminderViewModel.errorMessage != null) {
            return _buildErrorView(context, reminderViewModel);
          }

          final reminders = reminderViewModel.activeReminders;

          if (reminders.isEmpty) {
            return _buildEmptyView(context);
          }

          return Column(
            children: [
              // Progress and stats card
              _buildStatsCard(context, reminderViewModel),

              // Due reminders section
              if (reminderViewModel.dueReminders.isNotEmpty)
                _buildDueRemindersSection(context, reminderViewModel),

              // All reminders list
              Expanded(
                child: _buildRemindersList(context, reminderViewModel),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddReminder(context),
        tooltip: 'reminder_form.create_title'.tr(),
        icon: const Icon(Icons.add),
        label: Text('reminder_list.new_reminder'.tr()),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ReminderViewModel viewModel) {
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
            viewModel.errorMessage!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.initialize(),
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'reminder_list.no_reminders'.tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'reminder_list.start_message'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddReminder(context),
            icon: const Icon(Icons.add),
            label: Text('reminder_list.create_first'.tr()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ReminderViewModel viewModel) {
    final todaysReminders = viewModel.todaysReminders;
    final completionPercentage = viewModel.todayCompletionPercentage;
    final dueCount = viewModel.dueReminders.length;
    final upcomingCount = viewModel.upcomingReminders.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            if (todaysReminders.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${(completionPercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completionPercentage,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.schedule,
                    dueCount.toString(),
                    'Due Now',
                    dueCount > 0 ? Colors.red : Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.upcoming,
                    upcomingCount.toString(),
                    'Upcoming',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.calendar_today,
                    todaysReminders.length.toString(),
                    'Today',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDueRemindersSection(
    BuildContext context,
    ReminderViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reminders Due Now',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60, // Further reduced height from 80 to 60
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.dueReminders.length,
              itemBuilder: (context, index) {
                final reminder = viewModel.dueReminders[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildDueReminderCard(context, reminder, viewModel),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDueReminderCard(
    BuildContext context,
    Reminder reminder,
    ReminderViewModel viewModel,
  ) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(4), // Further reduced padding from 8 to 4
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row with icon - more compact
            Row(
              children: [
                Icon(
                  reminder.priorityIcon,
                  size: 12, // Even smaller icon
                  color: Colors.red,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    reminder.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11, // Smaller title font
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Skip description to save space - only show in tooltip or expanded view
            const SizedBox(height: 2), // Minimal spacing

            // Ultra-compact buttons row
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => viewModel.snoozeReminder(
                      reminder.id,
                      const Duration(minutes: 15),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 0),
                      minimumSize: const Size(0, 18), // Much smaller height
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Snooze', style: TextStyle(fontSize: 9)),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => viewModel.completeReminder(reminder.id),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 0),
                      minimumSize: const Size(0, 18), // Much smaller height
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Done', style: TextStyle(fontSize: 9)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(
    BuildContext context,
    ReminderViewModel viewModel,
  ) {
    final reminders = viewModel.activeReminders;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          8, 8, 8, 100), // Added large bottom buffer (100px)
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(context, reminder, viewModel);
      },
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Reminder reminder,
    ReminderViewModel viewModel,
  ) {
    final isCompleted = reminder.isCompletedToday;
    final isDue = reminder.isDue;
    final isUpcoming = reminder.isUpcoming;

    Color? cardColor;
    if (isDue) cardColor = Colors.red.withValues(alpha: 0.1);
    if (isUpcoming) cardColor = Colors.orange.withValues(alpha: 0.1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? Colors.green
              : isDue
                  ? Colors.red
                  : isUpcoming
                      ? Colors.orange
                      : Theme.of(context).colorScheme.primary,
          child: Icon(
            isCompleted
                ? Icons.check
                : isDue
                    ? Icons.warning
                    : reminder.priorityIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                : null,
            fontWeight: isDue ? FontWeight.bold : null,
          ),
        ),
        subtitle: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reminder.description.isNotEmpty)
                  Text(
                    reminder.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                // Time and frequency info
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatDateTime(reminder.scheduledTime),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: reminder.priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reminder.frequencyText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: reminder.priorityColor,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                ),
                if (reminder.tags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: reminder.tags
                        .take(3)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$tag',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                    ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            );
          },
        ),
        trailing: Container(
          width: 120, // Fixed width to prevent overflow
          padding: const EdgeInsets.symmetric(
              vertical: 4), // Add vertical padding to prevent overflow
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDue && !isCompleted) ...[
                // Snooze button for due reminders
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Material(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        16), // Reduced radius for smaller height
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          _showSnoozeOptions(context, reminder, viewModel),
                      child: Container(
                        padding: const EdgeInsets.all(6), // Reduced padding
                        child: Icon(
                          Icons.snooze,
                          color: Colors.orange,
                          size: 18, // Slightly smaller icon
                        ),
                      ),
                    ),
                  ),
                ),
                // Complete button for due reminders
                _buildCompletionButton(
                    context, reminder, viewModel, isCompleted),
              ] else ...[
                // Regular completion button
                _buildCompletionButton(
                    context, reminder, viewModel, isCompleted),
              ],
              PopupMenuButton<String>(
                onSelected: (value) => _handleReminderMenuAction(
                  context,
                  reminder,
                  value,
                  viewModel,
                ),
                padding: const EdgeInsets.all(6), // Reduced padding
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  if (!isCompleted)
                    const PopupMenuItem(
                      value: 'snooze',
                      child: ListTile(
                        leading: Icon(Icons.snooze),
                        title: Text('Snooze'),
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
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateText;
    if (reminderDate == today) {
      dateText = 'Today';
    } else if (reminderDate == tomorrow) {
      dateText = 'Tomorrow';
    } else if (reminderDate.isBefore(today)) {
      final daysPast = today.difference(reminderDate).inDays;
      dateText = '$daysPast ${daysPast == 1 ? 'day' : 'days'} ago';
    } else {
      final daysAhead = reminderDate.difference(today).inDays;
      if (daysAhead <= 7) {
        dateText = 'in $daysAhead ${daysAhead == 1 ? 'day' : 'days'}';
      } else {
        dateText = '${dateTime.day}/${dateTime.month}';
      }
    }

    final timeText =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateText at $timeText';
  }

  void _showSnoozeOptions(
    BuildContext context,
    Reminder reminder,
    ReminderViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Snooze Reminder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('15 minutes'),
              onTap: () {
                Navigator.pop(context);
                viewModel.snoozeReminder(
                    reminder.id, const Duration(minutes: 15));
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('1 hour'),
              onTap: () {
                Navigator.pop(context);
                viewModel.snoozeReminder(reminder.id, const Duration(hours: 1));
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Tomorrow'),
              onTap: () {
                Navigator.pop(context);
                viewModel.snoozeReminder(reminder.id, const Duration(days: 1));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleReminderMenuAction(
    BuildContext context,
    Reminder reminder,
    String action,
    ReminderViewModel viewModel,
  ) {
    switch (action) {
      case 'edit':
        _editReminder(context, reminder);
        break;
      case 'snooze':
        _showSnoozeOptions(context, reminder, viewModel);
        break;
      case 'delete':
        _deleteReminder(context, reminder, viewModel);
        break;
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'push_test':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PushNotificationTestView(),
          ),
        );
        break;
      case 'language':
        _showLanguageDialog(context);
        break;
      case 'theme':
        _showThemeDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'about':
        _showAboutDialog(context);
        break;
    }
  }

  String _getThemeModeText(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        return 'theme.light'.tr();
      case ThemeMode.dark:
        return 'theme.dark'.tr();
      case ThemeMode.system:
        return 'theme.system'.tr();
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('theme.choose_theme'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text('theme.light'.tr()),
              subtitle: Text('theme.light_description'.tr()),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('theme.dark'.tr()),
              subtitle: Text('theme.dark_description'.tr()),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('theme.system'.tr()),
              subtitle: Text('theme.system_description'.tr()),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('menu.language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('English'),
              value: const Locale('en'),
              groupValue: context.locale,
              onChanged: (Locale? value) {
                if (value != null) {
                  context.setLocale(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<Locale>(
              title: const Text('ខ្មែរ (Khmer)'),
              value: const Locale('km'),
              groupValue: context.locale,
              onChanged: (Locale? value) {
                if (value != null) {
                  context.setLocale(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: Text('settings.onboarding'.tr()),
              subtitle: Text('settings.onboarding_description'.tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingView(),
                  ),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'settings.more_settings'.tr(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('settings.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Notica',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 32,
          ),
        ),
        children: const [
          Text(
              'A modern reminder and notification app designed to help you stay organized and never miss important tasks.'),
        ],
      ),
    );
  }

  void _editReminder(BuildContext context, Reminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderView(reminderToEdit: reminder),
      ),
    );
  }

  void _deleteReminder(
    BuildContext context,
    Reminder reminder,
    ReminderViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteReminder(reminder.id);
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

  void _navigateToAddReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderView()),
    );
  }

  void _testNotification(BuildContext context) async {
    final notificationService = NotificationService();

    try {
      await notificationService.runNotificationDiagnostic();
      await notificationService.showImmediateNotification(
        '🔔 Notica Test',
        'This is a test notification from Notica!',
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

  Widget _buildCompletionButton(
    BuildContext context,
    Reminder reminder,
    ReminderViewModel viewModel,
    bool isCompleted,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(left: 4),
      constraints: const BoxConstraints(
        maxWidth: 36,
        maxHeight: 36,
      ),
      child: Material(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16), // Reduced radius
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isCompleted && reminder.frequency != ReminderFrequency.once) {
              // Undo completion for recurring reminders
              _undoCompletion(context, reminder, viewModel);
            } else {
              // Complete the reminder
              viewModel.completeReminder(reminder.id);
              // Show completion feedback
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"${reminder.title}" completed! 🎉',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6), // Reduced padding
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isCompleted
                    ? (reminder.frequency != ReminderFrequency.once
                        ? Icons.refresh
                        : Icons.check_circle)
                    : Icons.radio_button_unchecked,
                key: ValueKey(isCompleted),
                color: isCompleted ? Colors.green : Colors.grey,
                size: 20, // Reduced icon size
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _undoCompletion(
      BuildContext context, Reminder reminder, ReminderViewModel viewModel) {
    // Use the new undo method from the viewmodel
    viewModel.undoCompletion(reminder.id);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.undo, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"${reminder.title}" unmarked as completed',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
                  ? 'Notification permissions have been permanently denied. To receive reminders, please:'
                  : 'Notifications are currently disabled. To receive reminders:',
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Go to device Settings\n'
              '2. Find Notica app\n'
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
            onPressed: () async {
              Navigator.pop(context);
              await Permission.notification.request();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
