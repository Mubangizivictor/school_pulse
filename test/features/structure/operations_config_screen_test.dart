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
import 'package:school_pulse/features/structure/domain/entities/attendance_defaults_config.dart';
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

Widget _wrap(StructureState structureState, {int initialTab = 0}) {
  final authBloc = _MockAuthBloc();
  final structureBloc = _MockStructureBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  when(() => structureBloc.state).thenReturn(structureState);

  final router = GoRouter(
    initialLocation: '/operations',
    routes: [
      GoRoute(
        path: '/operations',
        builder: (context, state) =>
            OperationsConfigScreen(initialTab: initialTab),
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

  group('Timetable overview', () {
    testWidgets('shows the empty state when no timetable is configured', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const StructureState()));
      await tester.pumpAndSettle();

      expect(find.text('No timetable configured yet.'), findsOneWidget);
      expect(find.text('Add Timetable'), findsOneWidget);
    });

    testWidgets('shows configured summary when a timetable exists', (
      tester,
    ) async {
      final state = StructureState(
        timetableConfig: const TimetableConfig(
          teachingDays: ['Monday', 'Tuesday'],
          weekendDays: ['Saturday', 'Sunday'],
          periodsPerDay: 8,
          schoolStartTime: '08:00',
          schoolEndTime: '16:00',
        ),
      );
      await tester.pumpWidget(_wrap(state));
      await tester.pumpAndSettle();

      expect(find.text('Monday, Tuesday'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Edit Timetable'), 200);
      expect(find.text('Edit Timetable'), findsOneWidget);
    });
  });

  testWidgets('opens the requested operation directly without a tab selector', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const StructureState(), initialTab: 1));
    await tester.pumpAndSettle();

    expect(find.text('Attendance Defaults'), findsOneWidget);
    expect(find.text('Timetable'), findsNothing);
  });

  group('Manage time slots', () {
    testWidgets('filters slots by type', (tester) async {
      final state = StructureState(
        timetableConfig: const TimetableConfig(
          teachingDays: ['Monday'],
          periodsPerDay: 1,
          schoolStartTime: '08:00',
          schoolEndTime: '16:00',
          slots: [
            TimetableSlot(
              name: 'Period 1',
              startTime: '08:00',
              endTime: '08:45',
              type: 'period',
              displayOrder: 1,
            ),
            TimetableSlot(
              name: 'Short Break',
              startTime: '08:45',
              endTime: '09:00',
              type: 'break',
              displayOrder: 2,
            ),
          ],
        ),
      );
      await tester.pumpWidget(_wrap(state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manage Time Slots'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Period 1'), findsOneWidget);
      expect(find.textContaining('Short Break'), findsOneWidget);

      await tester.tap(find.text('Breaks'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Period 1'), findsNothing);
      expect(find.textContaining('Short Break'), findsOneWidget);
    });
  });

  group('Attendance defaults', () {
    testWidgets('reflects persisted values and dispatches save', (
      tester,
    ) async {
      final structureBloc = _MockStructureBloc();
      when(() => structureBloc.state).thenReturn(
        const StructureState(
          attendanceDefaultsConfig: AttendanceDefaultsConfig(
            allowBackdatedAttendance: true,
          ),
        ),
      );
      final authBloc = _MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));

      final router = GoRouter(
        initialLocation: '/operations',
        routes: [
          GoRoute(
            path: '/operations',
            builder: (context, state) =>
                const OperationsConfigScreen(initialTab: 1),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<StructureBloc>.value(value: structureBloc),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Attendance Defaults'), findsWidgets);

      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();

      verify(
        () => structureBloc.add(
          any(that: isA<UpdateAttendanceDefaultsConfigRequested>()),
        ),
      ).called(1);
    });
  });

  group('Communication defaults', () {
    testWidgets('shows unimplemented channels as disabled', (tester) async {
      await tester.pumpWidget(_wrap(const StructureState(), initialTab: 2));
      await tester.pumpAndSettle();

      expect(find.text('App Notification'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.textContaining('Not connected yet'), findsNWidgets(2));
    });
  });

  group('Owned modules', () {
    testWidgets('Academic Calendar redirects to the shared calendar notice', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const StructureState(), initialTab: 3));
      await tester.pumpAndSettle();

      expect(find.text('Academic Calendar'), findsWidgets);
      expect(find.text('Open School Calendar'), findsOneWidget);
    });

    testWidgets(
      'Exam Configuration redirects to the assessment configuration notice',
      (tester) async {
        await tester.pumpWidget(_wrap(const StructureState(), initialTab: 4));
        await tester.pumpAndSettle();

        expect(find.text('Exam Configuration'), findsWidgets);
        expect(find.text('Open Assessment Configuration'), findsOneWidget);
      },
    );
  });
}
