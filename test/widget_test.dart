// This is a basic Flutter widget test for the Advanced Calculator App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:advanced_calculator/main.dart';

void main() {
  testWidgets('App launches and shows calculator screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AdvancedCalculatorApp());
    await tester.pumpAndSettle();

    // Verify that the calculator screen is displayed
    expect(find.text('Advanced Calculator'), findsOneWidget);
  });
}
