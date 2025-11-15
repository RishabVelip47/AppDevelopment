import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App loads MaterialApp without crashing', (WidgetTester tester) async {
    // Load only the widget tree
    await tester.pumpWidget(const MyApp());

    // Allow initial frames to render but no infinite wait
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
