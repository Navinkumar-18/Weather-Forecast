import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather/main.dart';

void main() {
  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    // Load a mock environment value
    dotenv.loadFromString(envString: 'OPEN_WEATHER_API_KEY=test_key');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds and displays the main app structure
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
