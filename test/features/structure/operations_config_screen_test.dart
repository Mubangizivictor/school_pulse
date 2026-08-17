import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/operations_config_screen.dart';

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

/// One operational section is opened directly via the `section` query
/// parameter - the sequential Structure wizard never shows a tab selector.
Widget _wrap(StructureState structureState, {String section = 'timetable'}) {
  final authBloc = _MockAuthBloc();
  final structureBloc = _MockStructureBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  when(() => structureBloc.state).thenReturn(structureState);

  final router = GoRouter(
    initialLocation: '/operations?section=$section',
    routes: [
      GoRoute(
        path: '/operations',
        builder: (context, state) => const OperationsConfigScreen(),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<StructureBloc>.value(value: structureBloc),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoadStructureData('school-1'));
  });

  testWidgets('the timetable section opens directly with no tab selector', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const StructureState()));
    await tester.pumpAndSettle();

    expect(find.text('School Day & Periods'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('the school-day form reflects the persisted timetable config', (
    tester,
  ) async {
    final state = StructureState(
      timetableConfig: const TimetableConfig(
        teachingDays: ['Monday', 'Tuesday'],
        periodsPerDay: 8,
        schoolStartTime: '08:00',
        schoolEndTime: '16:00',
      ),
    );
    await tester.pumpWidget(_wrap(state));
    await tester.pumpAndSettle();

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('16:00'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('opens the requested section directly via the section param', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const StructureState(), section: 'attendance'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Attendance Configuration'), findsOneWidget);
    expect(find.text('Attendance Types'), findsOneWidget);
    expect(find.text('School Day & Periods'), findsNothing);
  });

  testWidgets('the communication section lists its category managers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const StructureState(), section: 'communication'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Announcement Categories'), findsOneWidget);
    expect(find.text('Notification Categories'), findsOneWidget);
    expect(find.text('Message Templates'), findsOneWidget);
  });

  testWidgets('the fees section shows the empty state with no categories', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const StructureState(), section: 'fees'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No fee categories defined yet'),
      findsOneWidget,
    );
  });
}
