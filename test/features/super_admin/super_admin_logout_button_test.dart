import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/super_admin_logout_button.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, ThemeData theme) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => handleSuperAdminLogout(context),
                child: const Text('Logout'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
  }

  testWidgets('logout confirmation dialog renders under light theme', (
    tester,
  ) async {
    await pumpDialog(tester, AppTheme.light());

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.text('Stay signed in'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logout confirmation dialog renders under dark theme', (
    tester,
  ) async {
    await pumpDialog(tester, AppTheme.dark());

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.text('Stay signed in'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
