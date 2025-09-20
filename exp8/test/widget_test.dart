import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exp8/main.dart'; // Make sure this matches your app's main file

void main() {
  testWidgets('Fitness Tracker Widget Test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(FitnessTrackerApp());

    // Verify HomeSlide shows two buttons
    expect(find.text('View Daily Stats'), findsOneWidget);
    expect(find.text('Workout Plans'), findsOneWidget);

    // Tap 'View Daily Stats' and navigate to StatsSlide
    await tester.tap(find.text('View Daily Stats'));
    await tester.pumpAndSettle();

    // Verify StatsSlide elements
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Calories Burned'), findsOneWidget);
    expect(find.text('Water Intake'), findsOneWidget);

    // Verify progress values
    expect(find.text('7500 / 10000'), findsOneWidget);
    expect(find.text('450 / 600'), findsOneWidget);
    expect(find.text('5 / 8 glasses'), findsOneWidget);

    // Tap 'Back' button to return home
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    // Tap 'Workout Plans' and navigate to WorkoutSlide
    await tester.tap(find.text('Workout Plans'));
    await tester.pumpAndSettle();

    // Verify workouts list
    expect(find.text('Morning Yoga - 20 min'), findsOneWidget);
    expect(find.text('Cardio - 30 min'), findsOneWidget);
    expect(find.text('Strength Training - 25 min'), findsOneWidget);
    expect(find.text('Evening Walk - 15 min'), findsOneWidget);

    // Verify checkboxes exist
    expect(find.byType(CheckboxListTile), findsNWidgets(4));
  });
}
