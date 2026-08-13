import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics_landing_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [UserRole.schoolAdmin],
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
  testWidgets('renders a navigation card for every academic subsection', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AcademicsLandingScreen(),
        structureState: const StructureState(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Years & Terms'), findsOneWidget);
    expect(find.text('Classes & Streams'), findsOneWidget);
    expect(find.text('Subjects'), findsOneWidget);
    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Grading Systems'), findsOneWidget);
    expect(find.text('Assessment Types'), findsOneWidget);
  });
}
