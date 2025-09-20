import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exp7/main.dart'; // adjust if your package name is different

void main() {
  testWidgets('Registration form UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const RegistrationApp());

    // Verify that the "Register" title is present
    expect(find.text('Register'), findsOneWidget);

    // Verify that all main fields are present
    expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone Number'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);

    // Verify gender options exist
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);

    // Verify dropdown for country
    expect(find.text('India'), findsOneWidget);

    // Verify Sign Up button is present
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);

    // Tap Sign Up (without filling form, still should trigger SnackBar if no validators)
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    // Check for SnackBar
    expect(find.text('Form Submitted'), findsOneWidget);
  });
}
