import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// The full [BursarShell] eagerly builds all five tab navigators and resolves
/// repositories from GetIt, so a faithful shell widget test needs the whole
/// DI graph (covered by integration tests). Here we assert the shared kit
/// primitives the shell/tabs are built from render in both themes.
void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final label = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('FinanceScaffold renders its title + body in $label mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme:
              brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
          home: const FinanceScaffold(
            title: 'Cash & Bank',
            body: Center(child: Text('cash-bank-body')),
          ),
        ),
      );

      expect(find.text('Cash & Bank'), findsOneWidget);
      expect(find.text('cash-bank-body'), findsOneWidget);
    });
  }
}
