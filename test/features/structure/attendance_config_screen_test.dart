import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/attendance_config_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [],
);

Widget _wrap(Widget child, {required StructureState structureState}) {
  final authBloc = _MockAuthBloc();
  final structureBloc = _MockStructureBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  when(() => structureBloc.state).thenReturn(structureState);
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StructureBloc>.value(value: structureBloc),
      ],
      child: child,
    ),
  );
}

void main() {
  testWidgets('renders card-style configuration actions and the types view', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AttendanceConfigScreen(),
        structureState: const StructureState(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Attendance types'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(
      find.textContaining('No attendance types defined yet'),
      findsOneWidget,
    );
  });

  testWidgets('renders a row for each attendance type', (tester) async {
    final state = StructureState(
      attendanceTypes: [
        const AttendanceTypeDef(
          id: 't1',
          schoolId: 'school-1',
          name: 'Present',
        ),
      ],
    );
    await tester.pumpWidget(
      _wrap(const AttendanceConfigScreen(), structureState: state),
    );
    await tester.pumpAndSettle();

    expect(find.text('Present'), findsOneWidget);
  });

  testWidgets('tapping the FAB opens the add-type form sheet', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AttendanceConfigScreen(),
        structureState: const StructureState(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Type'));
    await tester.pumpAndSettle();

    expect(find.text('Add Attendance Type'), findsOneWidget);
  });
}
