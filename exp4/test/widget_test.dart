import 'package:flutter_test/flutter_test.dart';
import 'package:exp4/main.dart';

void main() {
  testWidgets('Calculator starts at 0 and increments on button press',
      (WidgetTester tester) async {
    // Build CalculatorApp
    await tester.pumpWidget(const CalculatorApp());

    // Verify that it starts with 0
    expect(find.text('0'), findsOneWidget);

    // Tap the "1" button
    await tester.tap(find.text('1'));
    await tester.pump();

    // Now the input should contain "1"
    expect(find.text('1'), findsNWidgets(2)); // input + button
  });
}
