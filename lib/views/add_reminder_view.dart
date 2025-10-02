import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'reminder_form.edit_title'.tr() : 'reminder_form.create_title'.tr()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReminder,
              tooltip: 'reminder_form.delete_tooltip'.tr(),
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
                labelText: 'reminder_form.title_label'.tr(),
                hintText: 'reminder_form.title_hint'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'reminder_form.title_required'.tr();
                }
                if (value.trim().length < 2) {
                  return 'reminder_form.title_min_length'.tr();
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
                labelText: 'reminder_form.description_label'.tr(),
                hintText: 'reminder_form.description_hint'.tr(),
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
                      isEditing ? 'reminder_form.save'.tr() : 'reminder_form.save'.tr(),
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
                  'When should we remind you?',
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
                  'How often?',
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
                  'Priority Level',
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
                  'Tags (Optional)',
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
              decoration: const InputDecoration(
                hintText: 'work, health, family (comma separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_offer),
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
    switch (frequency) {
      case ReminderFrequency.once:
        return 'frequency.once'.tr();
      case ReminderFrequency.daily:
        return 'frequency.daily'.tr();
      case ReminderFrequency.weekly:
        return 'frequency.weekly'.tr();
      case ReminderFrequency.weekdays:
        return 'Weekdays';
      case ReminderFrequency.weekends:
        return 'Weekends';
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
    switch (priority) {
      case ReminderPriority.low:
        return 'priority.low'.tr();
      case ReminderPriority.normal:
        return 'priority.normal'.tr();
      case ReminderPriority.high:
        return 'priority.high'.tr();
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selected = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == tomorrow) {
      return 'Tomorrow';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Reminder updated successfully!'
                  : 'Reminder created successfully!',
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reminder_form.delete_confirm_title'.tr()),
        content: Text(
          '${'reminder_form.delete_confirm_message'.tr()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
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
            const SnackBar(
              content: Text('Reminder deleted successfully!'),
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
