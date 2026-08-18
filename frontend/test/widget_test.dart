// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart'; // Make sure this matches your project name

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampusCleaningApp());
  });
}