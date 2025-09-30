// This is a basic Flutter widget test for the Habit Tracker app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_good/main.dart';

void main() {
  testWidgets('Habit Tracker app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HabitTrackerApp());

    // Verify that our app title is shown.
    expect(find.text('Habit Tracker'), findsOneWidget);

    // Verify that the floating action button is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
