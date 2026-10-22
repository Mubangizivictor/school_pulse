import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/patron/presentation/screens/discipline_management_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockPatronBloc extends MockBloc<PatronEvent, PatronState>
    implements PatronBloc {}

void main() {
  const patron = UserEntity(
    id: 'patron-1',
    name: 'Patron Victor',
    email: 'patron@school.test',
    roles: [UserRole.boardingPatron],
    schoolId: 'test-school',
  );

  late MockAuthBloc authBloc;
  late MockPatronBloc patronBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    patronBloc = MockPatronBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(patron));
    when(() => patronBloc.close()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<PatronBloc>.value(value: patronBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const DisciplineManagementScreen(),
      ),
    );
  }

  final incident = DisciplineIncident(
    id: 'inc-1',
    studentId: 's1',
    studentName: 'Aiden Mwangi',
    description: 'Noise violation in dorm after lights out.',
    category: 'Disruptive Behaviour',
    actionTaken: 'Verbal warning',
    date: DateTime(2026, 5, 18),
    status: 'Pending',
    recordedBy: 'Patron Victor',
    severity: 'Medium',
  );

  testWidgets('renders an open incident with its severity badge', (
    tester,
  ) async {
    whenListen(
      patronBloc,
      Stream<PatronState>.fromIterable([
        DisciplineIncidentsLoaded([incident]),
      ]),
      initialState: DisciplineIncidentsLoaded([incident]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Aiden Mwangi'), findsOneWidget);
    expect(find.textContaining('MEDIUM'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no incidents', (
    tester,
  ) async {
    whenListen(
      patronBloc,
      Stream<PatronState>.fromIterable([const DisciplineIncidentsLoaded([])]),
      initialState: const DisciplineIncidentsLoaded([]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Aiden Mwangi'), findsNothing);
  });
}
