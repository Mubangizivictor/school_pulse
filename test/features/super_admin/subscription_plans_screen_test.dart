import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_event.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_state.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/subscription_plans_screen.dart';

class MockSuperAdminBloc extends MockBloc<SuperAdminEvent, SuperAdminState>
    implements SuperAdminBloc {}

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
  );
  const growth = SubscriptionPlan(
    id: 'growth',
    name: 'Growth',
    description: 'Advanced tools for growing schools.',
    price: 550000,
    billingCycle: BillingCycle.termly,
    maxStudents: 1500,
    maxStaff: 150,
    storageLimitGb: 30,
    includedFeatures: ['Priority support'],
    displayOrder: 1,
  );

  late MockSuperAdminBloc bloc;

  setUp(() {
    bloc = MockSuperAdminBloc();
    const state = SuperAdminState(
      status: SuperAdminStatus.success,
      plans: [starter, growth],
    );
    whenListen(bloc, Stream.value(state), initialState: state);
  });

  Widget subject() => MaterialApp(
    home: BlocProvider<SuperAdminBloc>.value(
      value: bloc,
      child: const SubscriptionPlansScreen(),
    ),
  );

  testWidgets('selecting a segment shows its real plan data', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('Starter Plan'), findsOneWidget);
    expect(find.text('UGX 350,000'), findsOneWidget);
    expect(find.text('Up to 500 Students'), findsOneWidget);

    await tester.tap(find.text('Growth').first);
    await tester.pumpAndSettle();

    expect(find.text('Growth Plan'), findsOneWidget);
    expect(find.text('UGX 550,000'), findsOneWidget);
    expect(find.text('Up to 1,500 Students'), findsOneWidget);
  });

  testWidgets('swiping keeps the selected plan in sync', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();

    expect(find.text('Growth Plan'), findsOneWidget);
    final selectedGrowth = tester.getSemantics(find.text('Growth').first);
    expect(selectedGrowth.flagsCollection.isSelected, Tristate.isTrue);

    expect(find.text('Edit Plan'), findsOneWidget);
  });
}
