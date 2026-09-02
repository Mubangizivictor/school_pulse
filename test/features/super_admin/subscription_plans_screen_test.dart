import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
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
  const archivedPlan = SubscriptionPlan(
    id: 'legacy',
    name: 'Legacy',
    description: 'Retired plan.',
    price: 100000,
    billingCycle: BillingCycle.termly,
    maxStudents: 100,
    maxStaff: 10,
    storageLimitGb: 5,
    includedFeatures: [],
    isArchived: true,
    isActive: false,
    displayOrder: 2,
  );

  final school = School(
    id: 'school-1',
    name: 'Test School',
    tenantId: 'school-1',
    address: '123 Main St',
    contactEmail: 'admin@test.school',
    contactPhone: '256700000000',
    subscriptionPlanId: 'starter',
    createdAt: DateTime(2025, 1, 1),
    subscriptionExpiry: DateTime(2030, 1, 1),
  );

  late MockSuperAdminBloc bloc;

  setUp(() {
    bloc = MockSuperAdminBloc();
    final state = SuperAdminState(
      status: SuperAdminStatus.success,
      plans: const [starter, growth, archivedPlan],
      schools: [school],
    );
    whenListen(bloc, Stream.value(state), initialState: state);
  });

  Widget subject() => MaterialApp(
    home: BlocProvider<SuperAdminBloc>.value(
      value: bloc,
      child: const SubscriptionPlansScreen(),
    ),
  );

  testWidgets('renders plan cards with name, price and school count', (
    tester,
  ) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.textContaining('UGX 350,000'), findsOneWidget);
    expect(find.text('1 school'), findsOneWidget);
    expect(find.text('0 schools'), findsWidgets);
  });

  testWidgets('search filters the visible plan list', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'growth');
    await tester.pumpAndSettle();

    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('Starter'), findsNothing);
  });

  testWidgets('filter menu narrows to archived plans only', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archived').last);
    await tester.pumpAndSettle();

    expect(find.text('Legacy'), findsOneWidget);
    expect(find.text('Starter'), findsNothing);
  });

  testWidgets('shows the info banner about existing subscriptions', (
    tester,
  ) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Existing schools keep their assigned plan'),
      findsOneWidget,
    );
  });

  testWidgets('empty state renders when there are no plans', (tester) async {
    final emptyState = const SuperAdminState(status: SuperAdminStatus.success);
    whenListen(bloc, Stream.value(emptyState), initialState: emptyState);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('No plans yet'), findsOneWidget);
    expect(find.text('Create first plan'), findsOneWidget);
  });
}
