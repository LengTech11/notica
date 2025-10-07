import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/planner_viewmodel.dart';
import '../models/planner_task.dart';
import 'package:intl/intl.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  DateTime _selectedDate = DateTime.now();
  TaskPriority? _filterPriority;
  TaskStatus? _filterStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlannerViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: Icon(
              _filterPriority != null || _filterStatus != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Consumer<PlannerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildDateSelector(),
              if (_filterPriority != null || _filterStatus != null || _searchQuery.isNotEmpty)
                _buildActiveFiltersCard(),
              _buildProgressCard(viewModel),
              if (viewModel.overdueTasks.isNotEmpty)
                _buildOverdueSection(viewModel),
              Expanded(
                child: _buildTasksList(viewModel),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Filters',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterPriority = null;
                    _filterStatus = null;
                    _searchQuery = '';
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_searchQuery.isNotEmpty)
                Chip(
                  label: Text('Search: $_searchQuery'),
                  onDeleted: () => setState(() => _searchQuery = ''),
                  deleteIcon: const Icon(Icons.close, size: 18),
                ),
              if (_filterPriority != null)
                Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getPriorityColor(_filterPriority!),
                      ),
                      const SizedBox(width: 4),
                      Text('Priority: ${_filterPriority!.name.toUpperCase()}'),
                    ],
                  ),
                  onDeleted: () => setState(() => _filterPriority = null),
                  deleteIcon: const Icon(Icons.close, size: 18),
                ),
              if (_filterStatus != null)
                Chip(
                  label: Text('Status: ${_filterStatus!.name.replaceAll('_', ' ').toUpperCase()}'),
                  onDeleted: () => setState(() => _filterStatus = null),
                  deleteIcon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(PlannerViewModel viewModel) {
    final tasksForDate = viewModel.getTasksForDate(_selectedDate);
    final completedTasks = tasksForDate.where((t) => t.isCompleted).length;
    final totalTasks = tasksForDate.length;
    final percentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$completedTasks / $totalTasks tasks',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(0)}% Complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueSection(PlannerViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${viewModel.overdueTasks.length} overdue tasks',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showOverdueTasksDialog(context, viewModel),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(PlannerViewModel viewModel) {
    var tasksForDate = viewModel.getTasksForDate(_selectedDate);

    // Apply filters
    if (_filterPriority != null) {
      tasksForDate = tasksForDate.where((t) => t.priority == _filterPriority).toList();
    }
    if (_filterStatus != null) {
      tasksForDate = tasksForDate.where((t) => t.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      tasksForDate = tasksForDate.where((t) =>
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (tasksForDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _filterPriority != null || _filterStatus != null || _searchQuery.isNotEmpty
                  ? 'No tasks match your filters'
                  : 'No tasks planned for this day',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterPriority != null || _filterStatus != null || _searchQuery.isNotEmpty
                  ? 'Try adjusting your filters'
                  : 'Tap the + button to add a task',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    // Group tasks by status
    final notStarted = tasksForDate.where((t) => t.status == TaskStatus.notStarted).toList();
    final inProgress = tasksForDate.where((t) => t.status == TaskStatus.inProgress).toList();
    final completed = tasksForDate.where((t) => t.status == TaskStatus.completed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgress.isNotEmpty) ...[
          _buildSectionHeader('In Progress', inProgress.length, Colors.blue),
          ...inProgress.map((task) => _buildTaskCard(task, viewModel)),
          const SizedBox(height: 16),
        ],
        if (notStarted.isNotEmpty) ...[
          _buildSectionHeader('To Do', notStarted.length, Colors.orange),
          ...notStarted.map((task) => _buildTaskCard(task, viewModel)),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          _buildSectionHeader('Completed', completed.length, Colors.green),
          ...completed.map((task) => _buildTaskCard(task, viewModel)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(PlannerTask task, PlannerViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            viewModel.toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                Icon(
                  task.priorityIcon,
                  size: 16,
                  color: task.priorityColor,
                ),
                const SizedBox(width: 4),
                Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: task.priorityColor,
                  ),
                ),
                if (task.scheduledTime != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.scheduledTime!.format(context),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () => _showTaskDetailsDialog(context, task, viewModel),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: const ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            if (!task.isCompleted)
              PopupMenuItem(
                value: 'inProgress',
                child: const ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Start'),
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: const ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              _showEditTaskDialog(context, task);
            } else if (value == 'inProgress') {
              await viewModel.updateTaskStatus(task.id, TaskStatus.inProgress);
            } else if (value == 'delete') {
              await viewModel.deleteTask(task.id);
            }
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final viewModel = Provider.of<PlannerViewModel>(context, listen: false);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDate;
    TimeOfDay? selectedTime;
    TaskPriority selectedPriority = TaskPriority.normal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time (optional)'),
                  subtitle: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Not set',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => selectedTime = null);
                          },
                        ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getPriorityColor(priority),
                          ),
                          const SizedBox(width: 8),
                          Text(priority.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPriority = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                await viewModel.addTask(
                  title: titleController.text,
                  description: descriptionController.text,
                  date: selectedDate,
                  scheduledTime: selectedTime,
                  priority: selectedPriority,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
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

  void _showOverdueTasksDialog(BuildContext context, PlannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text('Overdue Tasks (${viewModel.overdueTasks.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: viewModel.overdueTasks.isEmpty
              ? const Center(child: Text('No overdue tasks'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: viewModel.overdueTasks.length,
                  itemBuilder: (context, index) {
                    final task = viewModel.overdueTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            viewModel.toggleTaskCompletion(task.id);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(task.date),
                          style: const TextStyle(color: Colors.red),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await viewModel.deleteTask(task.id);
                            if (viewModel.overdueTasks.isEmpty && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, PlannerTask task) {
    final viewModel = Provider.of<PlannerViewModel>(context, listen: false);
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.date;
    TimeOfDay? selectedTime = task.scheduledTime;
    TaskPriority selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time (optional)'),
                  subtitle: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Not set',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => selectedTime = null);
                          },
                        ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getPriorityColor(priority),
                          ),
                          const SizedBox(width: 8),
                          Text(priority.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPriority = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final updatedTask = task.copyWith(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  date: selectedDate,
                  scheduledTime: selectedTime,
                  priority: selectedPriority,
                );

                await viewModel.updateTask(updatedTask);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, PlannerTask task, PlannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(task.statusIcon, color: task.statusColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.description.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 16),
              ],
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                DateFormat('EEEE, MMM d, yyyy').format(task.date),
              ),
              if (task.scheduledTime != null)
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  task.scheduledTime!.format(context),
                ),
              _buildDetailRow(
                task.priorityIcon,
                'Priority',
                task.priority.name.toUpperCase(),
                color: task.priorityColor,
              ),
              _buildDetailRow(
                task.statusIcon,
                'Status',
                task.status.name.replaceAll('_', ' ').toUpperCase(),
                color: task.statusColor,
              ),
              if (task.estimatedDuration != null)
                _buildDetailRow(
                  Icons.timer,
                  'Estimated Duration',
                  '${task.estimatedDuration} minutes',
                ),
              if (task.category != null)
                _buildDetailRow(
                  Icons.category,
                  'Category',
                  task.category!,
                ),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tags',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: task.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ],
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.history,
                'Created',
                DateFormat('MMM d, yyyy - h:mm a').format(task.createdAt),
              ),
              if (task.completedAt != null)
                _buildDetailRow(
                  Icons.check_circle,
                  'Completed',
                  DateFormat('MMM d, yyyy - h:mm a').format(task.completedAt!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditTaskDialog(context, task);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(text: _searchQuery);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search by title or description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = '');
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _searchQuery = searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    TaskPriority? tempPriority = _filterPriority;
    TaskStatus? tempStatus = _filterStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Tasks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Priority',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: tempPriority == null,
                      onSelected: (selected) {
                        setDialogState(() => tempPriority = null);
                      },
                    ),
                    ...TaskPriority.values.map((priority) {
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: _getPriorityColor(priority),
                            ),
                            const SizedBox(width: 4),
                            Text(priority.name.toUpperCase()),
                          ],
                        ),
                        selected: tempPriority == priority,
                        onSelected: (selected) {
                          setDialogState(() =>
                              tempPriority = selected ? priority : null);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: tempStatus == null,
                      onSelected: (selected) {
                        setDialogState(() => tempStatus = null);
                      },
                    ),
                    ...TaskStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.name.replaceAll('_', ' ').toUpperCase()),
                        selected: tempStatus == status,
                        onSelected: (selected) {
                          setDialogState(() =>
                              tempStatus = selected ? status : null);
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (_filterPriority != null || _filterStatus != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterPriority = null;
                    _filterStatus = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterPriority = tempPriority;
                  _filterStatus = tempStatus;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
