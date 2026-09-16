import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import using your actual project package name: willow_app
import 'package:willow_app/main.dart';

void main() {
  testWidgets('App renders without crashing smoke test',
      (WidgetTester tester) async {
    // Build the Willow app and trigger a frame
    await tester.pumpWidget(const WillowApp());

    // Verify WillowApp renders
    expect(find.byType(WillowApp), findsOneWidget);
  });
}
