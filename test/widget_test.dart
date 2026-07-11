import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SchoolPulseApp(),
      ),
    );

    // Verify that we are on the login screen (initial route)
    expect(find.text('Login Screen'), findsOneWidget);
  });
}
