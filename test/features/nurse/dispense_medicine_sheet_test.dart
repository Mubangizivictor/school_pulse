import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_clinic_visits_screen.dart';

class MockHealthBloc extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _FakeHealthEvent extends Fake implements HealthEvent {}

void main() {
  late MockHealthBloc healthBloc;
  late MockAuthBloc authBloc;

  const nurse = UserEntity(
    id: 'nurse-1',
    name: 'Nurse Grace',
    email: 'n@s.test',
    roles: [UserRole.nurse],
    schoolId: 'school-1',
  );

  final visit = ClinicVisit(
    id: 'visit-1',
    studentId: 'student-1',
    dateTime: DateTime(2026, 7, 25, 10),
    reason: 'Headache',
    symptoms: 'Pain',
    outcome: VisitOutcome.sentBackToClass,
    recordedBy: 'nurse-1',
    schoolId: 'school-1',
  );

  const item = MedicalInventoryItem(
    id: 'item-1',
    name: 'Paracetamol',
    type: MedicalItemType.medication,
    category: 'Pain relief',
    quantity: 20,
    unit: 'tablets',
    reorderLevel: 5,
  );

  setUpAll(() => registerFallbackValue(_FakeHealthEvent()));

  setUp(() {
    healthBloc = MockHealthBloc();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(nurse));
  });

  Future<void> pump(WidgetTester tester, HealthState state) async {
    when(() => healthBloc.state).thenReturn(state);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HealthBloc>.value(value: healthBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: DispenseMedicineSheet(visit: visit, schoolId: 'school-1'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('fetches inventory on open, scoped to the school', (
    tester,
  ) async {
    await pump(tester, HealthLoading());
    verify(() => healthBloc.add(const FetchInventory('school-1'))).called(1);
  });

  testWidgets(
    'lists stock and dispatches a dispense with the visit id + student id',
    (tester) async {
      await pump(tester, const InventoryLoaded([item]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Paracetamol'), findsOneWidget);
      expect(find.text('Dispense for student-1'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '2');
      await tester.tap(find.widgetWithText(FilledButton, 'Dispense'));
      await tester.pump();

      final captured =
          verify(
                () => healthBloc.add(
                  captureAny(that: isA<DispenseMedicalItemEvent>()),
                ),
              ).captured.single
              as DispenseMedicalItemEvent;
      expect(captured.itemId, 'item-1');
      expect(captured.visitId, 'visit-1');
      expect(captured.studentId, 'student-1');
      expect(captured.quantity, 2);
      expect(captured.schoolId, 'school-1');
    },
  );

  testWidgets('a non-positive quantity does not dispatch', (tester) async {
    await pump(tester, const InventoryLoaded([item]));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '0');
    await tester.tap(find.widgetWithText(FilledButton, 'Dispense'));
    await tester.pump();

    verifyNever(
      () => healthBloc.add(any(that: isA<DispenseMedicalItemEvent>())),
    );
  });

  testWidgets('shows an empty state when there is no stock', (tester) async {
    await pump(tester, const InventoryLoaded([]));
    await tester.pumpAndSettle();
    expect(find.text('No stock'), findsOneWidget);
  });
}
