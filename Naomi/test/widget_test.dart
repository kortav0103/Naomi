// This is a basic Flutter widget test for Naomi application.

import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/main.dart';

void main() {
  testWidgets('Naomi splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NaomiApp());

    // Verify that the title and readiness message exist.
    expect(find.text('NAOMI'), findsOneWidget);
    expect(find.text('Core Infrastructure Ready'), findsOneWidget);
  });
}
