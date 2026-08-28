import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_content.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

Widget _wrap(Widget child, {required Brightness brightness}) => MaterialApp(
  theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  group('FinanceScaffold constrainWidth', () {
    testWidgets('off by default - body is not width-capped', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FinanceScaffold(title: 'Budget', body: Text('b')),
          brightness: Brightness.light,
        ),
      );
      expect(find.byType(AppResponsiveContent), findsNothing);
    });

    testWidgets('on - wraps the body in AppResponsiveContent', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FinanceScaffold(
            title: 'Budget',
            constrainWidth: true,
            body: Text('b'),
          ),
          brightness: Brightness.light,
        ),
      );
      expect(find.byType(AppResponsiveContent), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });
  });

  group('FinanceStatusChip.forStatus', () {
    test('maps settled statuses to a positive tone', () {
      for (final s in ['Paid', 'compliant', 'Released', 'approved']) {
        expect(FinanceStatusChip.forStatus(s).tone, FinanceStatusTone.positive);
      }
    });

    test('maps problem statuses to a negative tone', () {
      for (final s in ['Overdue', 'rejected', 'Unmatched', 'high risk']) {
        expect(FinanceStatusChip.forStatus(s).tone, FinanceStatusTone.negative);
      }
    });

    test('maps anything else to a neutral tone', () {
      for (final s in ['pending', 'partial', 'draft', 'reviewed']) {
        expect(FinanceStatusChip.forStatus(s).tone, FinanceStatusTone.neutral);
      }
    });
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    final label = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('FinanceScaffold renders title + body in $label mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const FinanceScaffold(
            title: 'Receipt',
            body: Center(child: Text('body-content')),
          ),
          brightness: brightness,
        ),
      );
      expect(find.text('Receipt'), findsOneWidget);
      expect(find.text('body-content'), findsOneWidget);
    });

    testWidgets('MoneyText formats UGX in $label mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const MoneyText(1250000), brightness: brightness),
      );
      expect(find.textContaining('1,250,000'), findsOneWidget);
    });

    testWidgets(
      'FinanceStates.comingSoon shows the feature name in $label mode',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) =>
                  FinanceStates.comingSoon(context, feature: 'Cash & Bank'),
            ),
            brightness: brightness,
          ),
        );
        expect(find.textContaining('Cash & Bank'), findsOneWidget);
      },
    );

    testWidgets('MethodSegments marks the selected method in $label mode', (
      tester,
    ) async {
      var picked = 'cash';
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => MethodSegments(
              options: const [
                (value: 'cash', label: 'Cash'),
                (value: 'mobile_money', label: 'Mobile Money'),
                (value: 'bank_transfer', label: 'Bank'),
              ],
              selected: picked,
              onChanged: (v) => setState(() => picked = v),
            ),
          ),
          brightness: brightness,
        ),
      );
      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();
      expect(picked, 'bank_transfer');
    });
  }
}
