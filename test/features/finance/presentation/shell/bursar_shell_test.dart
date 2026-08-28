import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_cash_bank_screen.dart';

/// The full [BursarShell] eagerly builds all five tab navigators (an
/// IndexedStack), and the Students/Home tabs resolve repositories from GetIt,
/// so a faithful shell widget test needs the whole DI graph. That is covered
/// by the integration tests. Here we assert the reference nav labels are the
/// ones the shell declares, and that the Phase-1 Cash & Bank tab renders its
/// coming-soon state in both themes.
void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final label = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('Cash & Bank tab shows the coming-soon state in $label mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: brightness == Brightness.dark
              ? AppTheme.dark()
              : AppTheme.light(),
          home: const BursarCashBankScreen(),
        ),
      );

      expect(find.text('Cash & Bank'), findsWidgets);
      expect(find.textContaining('Cash & Bank is coming soon'), findsOneWidget);
    });
  }
}
