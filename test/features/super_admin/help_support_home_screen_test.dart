// Proves HelpSupportHomeScreen shows the five real, backed rows (Help
// Center, Contact Support, FAQs, Report a Problem, Submit a Request) and
// deliberately omits "Video Guides" and "System Status" since no real
// video content or platform-status backend exists to back them
// (fabricating one would be dishonest UI). Also covers the sibling
// SupportHelpCenterScreen (maintained local guide topics) and
// SupportFaqsScreen (maintained local FAQ data), both defined in the same
// file. None of these depend on Firebase/bloc, so they are rendered
// directly with pumpWidget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/data/support_faq_data.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/help_support_home_screen.dart';

void main() {
  testWidgets(
    'renders the five real support rows and omits Video Guides/System Status',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpSupportHomeScreen()));

      expect(find.text('Help & Support'), findsWidgets);
      expect(find.text('Help Center'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(find.text('FAQs'), findsOneWidget);
      expect(find.text('Report a Problem'), findsOneWidget);
      expect(find.text('Submit a Request'), findsOneWidget);

      // Deliberately omitted rows - fabricating either would be dishonest UI
      // per this screen's own documented reasoning.
      expect(find.text('Video Guides'), findsNothing);
      expect(find.text('System Status'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'SupportHelpCenterScreen renders all maintained guide topics when scrolled through',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SupportHelpCenterScreen()),
      );

      expect(find.text('Help Center'), findsWidgets);
      const titles = [
        'Owner Console Overview',
        'Reviewing School Applications',
        'Configuring Manual Payment Methods',
        'Reviewing Submitted Payments',
        'Platform Notifications',
        'Audit Logs',
      ];
      for (final title in titles) {
        await tester.scrollUntilVisible(find.text(title), 300);
        expect(find.text(title), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'SupportFaqsScreen renders every FAQ from the maintained data source, collapsed by default',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SupportFaqsScreen()));

      expect(find.text('FAQs'), findsWidgets);
      for (final faq in kSuperAdminSupportFaqs) {
        await tester.scrollUntilVisible(find.text(faq.question), 300);
        expect(find.text(faq.question), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tapping a FAQ expands it to reveal the answer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SupportFaqsScreen()));
    if (kSuperAdminSupportFaqs.isEmpty) return;

    final first = kSuperAdminSupportFaqs.first;
    expect(find.text(first.answer), findsNothing);

    await tester.tap(find.text(first.question));
    await tester.pumpAndSettle();

    expect(find.text(first.answer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
