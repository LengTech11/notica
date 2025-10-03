import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventStorageService {
  static const String _eventsKey = 'notica_events';

  static final EventStorageService _instance =
      EventStorageService._internal();
  factory EventStorageService() => _instance;
  EventStorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('📅 Event storage service initialized');
  }

  /// Ensure initialized before operations
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save events to storage
  Future<void> saveEvents(List<Event> events) async {
    await _ensureInitialized();

    try {
      final List<Map<String, dynamic>> eventsList =
          events.map((event) => event.toJson()).toList();

      final String eventsJson = jsonEncode(eventsList);
      await _prefs!.setString(_eventsKey, eventsJson);

      debugPrint('📅 Saved ${events.length} events to storage');
    } catch (e) {
      debugPrint('📅 Error saving events: $e');
      rethrow;
    }
  }

  /// Load events from storage
  Future<List<Event>> loadEvents() async {
    await _ensureInitialized();

    try {
      final String? eventsJson = _prefs!.getString(_eventsKey);

      if (eventsJson == null || eventsJson.isEmpty) {
        debugPrint('📅 No events found in storage');
        return [];
      }

      final List<dynamic> eventsList = jsonDecode(eventsJson);
      final List<Event> events = eventsList
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📅 Loaded ${events.length} events from storage');
      return events;
    } catch (e) {
      debugPrint('📅 Error loading events: $e');
      return [];
    }
  }

  /// Save a single event
  Future<void> saveEvent(Event event) async {
    final events = await loadEvents();

    // Find and replace existing event or add new one
    final existingIndex = events.indexWhere((e) => e.id == event.id);
    if (existingIndex != -1) {
      events[existingIndex] = event;
    } else {
      events.add(event);
    }

    await saveEvents(events);
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    final events = await loadEvents();
    events.removeWhere((event) => event.id == eventId);
    await saveEvents(events);
    debugPrint('📅 Deleted event with ID: $eventId');
  }

  /// Clear all events
  Future<void> clearAllEvents() async {
    await _ensureInitialized();
    await _prefs!.remove(_eventsKey);
    debugPrint('📅 Cleared all events');
  }
}
