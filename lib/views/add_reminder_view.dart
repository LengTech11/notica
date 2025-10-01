import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../viewmodels/reminder_viewmodel.dart';

class AddReminderView extends StatefulWidget {
  final Reminder? reminderToEdit;

  const AddReminderView({super.key, this.reminderToEdit});

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  ReminderFrequency _selectedFrequency = ReminderFrequency.once;
  ReminderPriority _selectedPriority = ReminderPriority.normal;
  bool _isLoading = false;

  bool get isEditing => widget.reminderToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final reminder = widget.reminderToEdit!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description;
      _selectedDateTime = reminder.scheduledTime;
      _selectedFrequency = reminder.frequency;
      _selectedPriority = reminder.priority;
      _tagsController.text = reminder.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editReminder : l10n.createReminder),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReminder,
              tooltip: l10n.deleteReminder,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.reminderTitle,
                hintText: l10n.reminderTitleHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTitle;
                }
                if (value.trim().length < 2) {
                  return l10n.titleTooShort;
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
            ),

            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Date and Time section
            _buildDateTimeSection(),

            const SizedBox(height: 24),

            // Frequency section
            _buildFrequencySection(),

            const SizedBox(height: 24),

            // Priority section
            _buildPrioritySection(),

            const SizedBox(height: 24),

            // Tags section
            _buildTagsSection(),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEditing ? l10n.saveReminder : l10n.createReminderButton,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 32),

            // Help section
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.whenRemindYou,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_selectedDateTime),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Time picker
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(_selectedDateTime),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.howOften,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderFrequency.values.map((frequency) {
                final isSelected = _selectedFrequency == frequency;
                return FilterChip(
                  label: Text(_getFrequencyDisplayText(frequency)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFrequency = frequency;
                      });
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            if (_selectedFrequency != ReminderFrequency.once) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFrequencyDescription(_selectedFrequency),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.priority,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: ReminderPriority.values.map((priority) {
                return RadioListTile<ReminderPriority>(
                  title: Text(_getPriorityDisplayText(priority)),
                  subtitle: Text(_getPriorityDescription(priority)),
                  value: priority,
                  groupValue: _selectedPriority,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                  secondary: Icon(
                    _getPriorityIcon(priority),
                    color: _getPriorityColor(priority),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tag,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.tags,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Add tags to organize your reminders',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: l10n.tagsHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_offer),
              ),
              maxLength: 100,
            ),

            // Common tags suggestions
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: ['work', 'health', 'family', 'personal', 'urgent']
                  .map((tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () => _addTag(tag),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reminder Tips',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Use clear, specific titles for your reminders\n'
            '• Set priority to High for urgent or important tasks\n'
            '• Use tags to group related reminders\n'
            '• Daily reminders are great for habits\n'
            '• Test notifications to ensure they work',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getFrequencyDisplayText(ReminderFrequency frequency) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (frequency) {
      case ReminderFrequency.once:
        return l10n.frequencyOnce;
      case ReminderFrequency.daily:
        return l10n.frequencyDaily;
      case ReminderFrequency.weekly:
        return l10n.frequencyWeekly;
      case ReminderFrequency.weekdays:
        return l10n.frequencyWeekdays;
      case ReminderFrequency.weekends:
        return l10n.frequencyWeekends;
    }
  }

  String _getFrequencyDescription(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.daily:
        return 'Repeat every day at the same time';
      case ReminderFrequency.weekly:
        return 'Repeat every week on the same day and time';
      case ReminderFrequency.weekdays:
        return 'Repeat Monday through Friday';
      case ReminderFrequency.weekends:
        return 'Repeat on Saturday and Sunday';
      case ReminderFrequency.once:
        return '';
    }
  }

  String _getPriorityDisplayText(ReminderPriority priority) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (priority) {
      case ReminderPriority.low:
        return l10n.priorityLow;
      case ReminderPriority.normal:
        return l10n.priorityNormal;
      case ReminderPriority.high:
        return l10n.priorityHigh;
    }
  }

  String _getPriorityDescription(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return 'Standard notification, less intrusive';
      case ReminderPriority.normal:
        return 'Regular notification with sound';
      case ReminderPriority.high:
        return 'Urgent notification with maximum visibility';
    }
  }

  IconData _getPriorityIcon(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Icons.notifications_none;
      case ReminderPriority.normal:
        return Icons.notifications;
      case ReminderPriority.high:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.grey;
      case ReminderPriority.normal:
        return Colors.blue;
      case ReminderPriority.high:
        return Colors.red;
    }
  }

  void _addTag(String tag) {
    final currentTags = _tagsController.text;
    if (currentTags.isEmpty) {
      _tagsController.text = tag;
    } else if (!currentTags.contains(tag)) {
      _tagsController.text = '$currentTags, $tag';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selected = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (selected == today) {
      return l10n.today;
    } else if (selected == tomorrow) {
      return l10n.tomorrow;
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that the selected time is in the future for one-time reminders
    if (_selectedFrequency == ReminderFrequency.once &&
        _selectedDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select a future date and time for one-time reminders'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reminderViewModel = Provider.of<ReminderViewModel>(
        context,
        listen: false,
      );

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (isEditing) {
        await reminderViewModel.updateReminder(
          reminderId: widget.reminderToEdit!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: _selectedDateTime,
          frequency: _selectedFrequency,
          priority: _selectedPriority,
          tags: tags,
        );
      } else {
        await reminderViewModel.addReminder(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: _selectedDateTime,
          frequency: _selectedFrequency,
          priority: _selectedPriority,
          tags: tags,
        );
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? l10n.reminderUpdated
                  : l10n.reminderCreated,
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReminder() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReminder),
        content: Text(
          l10n.deleteReminderConfirm(widget.reminderToEdit!.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      setState(() {
        _isLoading = true;
      });

      try {
        final reminderViewModel = Provider.of<ReminderViewModel>(
          context,
          listen: false,
        );
        await reminderViewModel.deleteReminder(widget.reminderToEdit!.id);

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n.reminderDeleted),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting reminder: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
