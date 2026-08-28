import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/expenditure.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockFinanceBloc extends MockBloc<FinanceEvent, FinanceState>
    implements FinanceBloc {}

void main() {
  const bursar = UserEntity(
    id: 'bursar-1',
    name: 'Bursar Ben',
    email: 'bursar@school.test',
    roles: [UserRole.bursar],
    schoolId: 'school-1',
  );

  final pending = ExpenditureRequest(
    id: 'e1',
    schoolId: 'school-1',
    requesterId: 'u9',
    requesterName: 'Peter Odongo',
    description: 'Supplier payment — Office World Ltd',
    amount: 4950000,
    budgetCategoryId: '2135',
    supplierName: 'Office World Ltd',
    status: ExpenditureStatus.pending,
    createdAt: DateTime(2024, 5, 23),
  );
  final decided = ExpenditureRequest(
    id: 'e2',
    schoolId: 'school-1',
    requesterId: 'u4',
    requesterName: 'Jane Nakato',
    description: 'Computer accessories',
    amount: 275000,
    budgetCategoryId: '2140',
    status: ExpenditureStatus.approved,
    createdAt: DateTime(2024, 5, 23),
  );

  late _MockAuthBloc authBloc;
  late _MockFinanceBloc financeBloc;

  setUpAll(() {
    registerFallbackValue(const LoadExpenditureRequests('school-1'));
  });

  setUp(() {
    authBloc = _MockAuthBloc();
    financeBloc = _MockFinanceBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(bursar));
    when(
      () => financeBloc.state,
    ).thenReturn(ExpendituresLoaded([pending, decided]));
  });

  Widget buildApp(Brightness brightness) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<FinanceBloc>.value(value: financeBloc),
    ],
    child: MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      home: const BursarApprovalsScreen(),
    ),
  );

  for (final brightness in [Brightness.light, Brightness.dark]) {
    final label = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets(
      'Pending tab lists pending requests with amount in $label mode',
      (tester) async {
        await tester.pumpWidget(buildApp(brightness));
        await tester.pump();

        expect(find.text('Approvals'), findsOneWidget);
        expect(
          find.text('Supplier payment — Office World Ltd'),
          findsOneWidget,
        );
        expect(find.textContaining('4,950,000'), findsWidgets);
        // A >= 3,000,000 spend is flagged high-risk per the reference chip.
        expect(find.text('High risk'), findsOneWidget);
        // The already-approved request is on the History tab, not Pending.
        expect(find.text('Computer accessories'), findsNothing);
      },
    );

    testWidgets('bursar sees Approve / Reject actions in $label mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(brightness));
      await tester.pump();

      expect(find.widgetWithText(FilledButton, 'Approve'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Reject'), findsOneWidget);
    });
  }

  testWidgets('loads expenditure requests on first build', (tester) async {
    final added = <FinanceEvent>[];
    when(() => financeBloc.add(any())).thenAnswer((inv) {
      added.add(inv.positionalArguments.first as FinanceEvent);
    });

    await tester.pumpWidget(buildApp(Brightness.light));
    await tester.pump();

    expect(added.whereType<LoadExpenditureRequests>(), isNotEmpty);
  });

  testWidgets('a non-approver role sees no decision buttons', (tester) async {
    const clerk = UserEntity(
      id: 'clerk-1',
      name: 'Clerk',
      email: 'clerk@school.test',
      roles: [UserRole.receptionist],
      schoolId: 'school-1',
    );
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(clerk));

    await tester.pumpWidget(buildApp(Brightness.light));
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Reject'), findsNothing);
  });
}
