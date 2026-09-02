import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/plan_editor_page.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

void main() {
  const starter = SubscriptionPlan(
    id: 'starter',
    name: 'Starter',
    description: 'Everything a school needs to get started.',
    price: 350000,
    billingCycle: BillingCycle.termly,
    maxStudents: 500,
    maxStaff: 60,
    storageLimitGb: 10,
    includedFeatures: ['Email & SMS Support'],
    includedModules: ['attendance', 'reports'],
  );
  const archived = SubscriptionPlan(
    id: 'legacy',
    name: 'Legacy',
    description: 'Retired.',
    price: 100000,
    billingCycle: BillingCycle.termly,
    maxStudents: 100,
    maxStaff: 10,
    storageLimitGb: 5,
    includedFeatures: [],
    isArchived: true,
    isActive: false,
  );

  Widget subject(SubscriptionPlan? plan) => MaterialApp(
    home: PlanEditorPage(
      plan: plan,
      service: ManualPaymentService(functions: _MockFunctions()),
    ),
  );

  testWidgets('create mode shows an editable plan code field and no archive button', (
    tester,
  ) async {
    await tester.pumpWidget(subject(null));
    await tester.pumpAndSettle();

    expect(find.text('New plan'), findsOneWidget);
    expect(find.text('Archive plan'), findsNothing);
    expect(find.text('Reactivate plan'), findsNothing);

    final codeField = tester.widget<TextField>(
      find
          .descendant(
            of: find.widgetWithText(InputDecorator, 'Plan code'),
            matching: find.byType(TextField),
          )
          .first,
    );
    expect(codeField.enabled, isTrue);
  });

  testWidgets('edit mode shows read-only plan code and an archive button', (
    tester,
  ) async {
    await tester.pumpWidget(subject(starter));
    await tester.pumpAndSettle();

    expect(find.text('Edit plan'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Archive plan'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    expect(find.text('Archive plan'), findsOneWidget);
    expect(
      find.text("You can't delete a plan that is assigned to one or more schools."),
      findsOneWidget,
    );

    final codeField = tester.widget<TextField>(
      find
          .descendant(
            of: find.widgetWithText(InputDecorator, 'Plan code'),
            matching: find.byType(TextField),
          )
          .first,
    );
    expect(codeField.readOnly, isTrue);
  });

  testWidgets('included module chips reflect the plan and can be toggled', (
    tester,
  ) async {
    await tester.pumpWidget(subject(starter));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(FilterChip, 'Attendance'),
      200,
    );

    final attendanceChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Attendance'),
    );
    expect(attendanceChip.selected, isTrue);

    final financeChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Finance'),
    );
    expect(financeChip.selected, isFalse);

    await tester.tap(find.widgetWithText(FilterChip, 'Finance'));
    await tester.pumpAndSettle();

    final financeChipAfter = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Finance'),
    );
    expect(financeChipAfter.selected, isTrue);
  });

  testWidgets('archived plan shows reactivate button instead of archive', (
    tester,
  ) async {
    await tester.pumpWidget(subject(archived));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Reactivate plan'), 200);

    expect(find.text('Reactivate plan'), findsOneWidget);
    expect(find.text('Archive plan'), findsNothing);
  });
}
