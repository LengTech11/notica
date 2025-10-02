import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/reminder.dart';
import '../services/event_storage_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final EventStorageService _storageService = EventStorageService();

  // Private list of events
  final List<Event> _events = [];

  // Getters
  List<Event> get events => List.unmodifiable(_events);
  
  List<Event> get todayEvents {
    final today = DateTime.now();
    return _events.where((event) {
      return event.startTime.year == today.year &&
          event.startTime.month == today.month &&
          event.startTime.day == today.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) {
      return event.startTime.isAfter(now) &&
          event.startTime.difference(now).inDays <= 7;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize the view model
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _storageService.initialize();
      await _loadEventsFromStorage();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new event
  Future<void> addEvent({
    required String title,
    String description = '',
    required DateTime startTime,
    DateTime? endTime,
    EventType type = EventType.custom,
    EventCategory category = EventCategory.personal,
    bool isAllDay = false,
    Color? color,
    String? location,
    List<String>? tags,
    String? reminderId,
  }) async {
    if (title.trim().isEmpty) {
      _setError('Event title cannot be empty');
      return;
    }

    _clearError();

    try {
      final event = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim(),
        startTime: startTime,
        endTime: endTime,
        type: type,
        category: category,
        createdAt: DateTime.now(),
        isAllDay: isAllDay,
        color: color,
        location: location,
        tags: tags ?? [],
        reminderId: reminderId,
      );

      _events.add(event);
      await _storageService.saveEvent(event);

      notifyListeners();
      debugPrint('✅ Added event: ${event.title}');
    } catch (e) {
      _setError('Failed to add event: $e');
      debugPrint('❌ Error adding event: $e');
    }
  }

  /// Update an existing event
  Future<void> updateEvent(Event updatedEvent) async {
    _clearError();

    try {
      final index = _events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        _events[index] = updatedEvent;
        await _storageService.saveEvent(updatedEvent);

        notifyListeners();
        debugPrint('✅ Updated event: ${updatedEvent.title}');
      }
    } catch (e) {
      _setError('Failed to update event: $e');
      debugPrint('❌ Error updating event: $e');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    _clearError();

    try {
      _events.removeWhere((event) => event.id == eventId);
      await _storageService.deleteEvent(eventId);

      notifyListeners();
      debugPrint('✅ Deleted event');
    } catch (e) {
      _setError('Failed to delete event: $e');
      debugPrint('❌ Error deleting event: $e');
    }
  }

  /// Toggle event completion
  Future<void> toggleEventCompletion(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      final updatedEvent = event.copyWith(
        isCompleted: !event.isCompleted,
      );
      await updateEvent(updatedEvent);
    }
  }

  /// Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get events for a specific month
  List<Event> getEventsForMonth(int year, int month) {
    return _events.where((event) {
      return event.startTime.year == year && event.startTime.month == month;
    }).toList();
  }

  /// Create event from reminder
  Future<void> createEventFromReminder(Reminder reminder) async {
    await addEvent(
      title: reminder.title,
      description: reminder.description,
      startTime: reminder.scheduledTime,
      type: EventType.reminder,
      category: EventCategory.personal,
      tags: reminder.tags,
      reminderId: reminder.id,
    );
  }

  /// Load events from storage
  Future<void> _loadEventsFromStorage() async {
    try {
      final loadedEvents = await _storageService.loadEvents();
      _events.clear();
      _events.addAll(loadedEvents);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load events: $e');
    }
  }

  /// Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
