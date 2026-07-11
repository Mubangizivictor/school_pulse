import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const SchoolPulseApp(),
      ),
    );

    // Verify that we are on the login screen (initial route)
    expect(find.text('School Pulse'), findsOneWidget);
  });
}
