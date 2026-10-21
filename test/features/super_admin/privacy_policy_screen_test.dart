// Proves PrivacyPolicyScreen renders as a real, human-usable draft (not
// lorem ipsum) with all ten sections, and is explicitly labeled as an
// unreviewed draft rather than presented as final legal copy. This screen
// has no Firebase/bloc dependency, so it is rendered directly with
// pumpWidget rather than only source-inspected.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/privacy_policy_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester, ThemeData theme) async {
    await tester.pumpWidget(
      MaterialApp(theme: theme, home: const PrivacyPolicyScreen()),
    );
  }

  testWidgets(
    'renders the app bar title and all ten numbered sections when scrolled through',
    (tester) async {
      await pump(tester, AppTheme.light());

      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.textContaining('1. Introduction'), findsOneWidget);

      final titles = [
        '2. Information We Collect',
        '3. How We Use Information',
        '4. Data Retention',
        '5. Third-Party Sharing',
        '6. Your Rights',
        '7. Data Security',
        "8. Children",
        '9. Changes to This Policy',
        '10. Contact Us',
      ];
      final listFinder = find.byType(ListView);
      for (final title in titles) {
        await tester.scrollUntilVisible(
          find.textContaining(title),
          300,
          scrollable: find.descendant(
            of: listFinder,
            matching: find.byType(Scrollable),
          ),
        );
        expect(find.textContaining(title), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'explicitly discloses this is an unreviewed draft, not final legal copy',
    (tester) async {
      await pump(tester, AppTheme.light());

      expect(
        find.textContaining('has not yet undergone formal legal review'),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows a Last updated date', (tester) async {
    await pump(tester, AppTheme.light());

    expect(find.textContaining('Last updated:'), findsOneWidget);
  });

  testWidgets('renders under dark theme without an overflow error', (
    tester,
  ) async {
    await pump(tester, AppTheme.dark());

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
