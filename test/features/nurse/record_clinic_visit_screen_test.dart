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
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/health/presentation/screens/record_clinic_visit_screen.dart';

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
    email: 'nurse@school.test',
    roles: [UserRole.nurse],
    schoolId: 'school-1',
  );

  setUpAll(() => registerFallbackValue(_FakeHealthEvent()));

  setUp(() {
    healthBloc = MockHealthBloc();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(nurse));
    when(() => healthBloc.state).thenReturn(HealthInitial());
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(390, 900),
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/new',
      routes: [
        GoRoute(
          path: '/new',
          builder: (context, state) =>
              const RecordClinicVisitScreen(studentId: 'student-77'),
        ),
        GoRoute(path: '/back', builder: (context, state) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HealthBloc>.value(value: healthBloc),
        ],
        child: MaterialApp.router(theme: theme, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the learner id read-only and the key form sections', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('student-77'), findsOneWidget);
    expect(find.text('Presenting concern'), findsOneWidget);
    expect(find.text('Vitals'), findsOneWidget);
    expect(find.text('Follow-up required'), findsOneWidget);
    expect(find.text('Complete visit'), findsOneWidget);
  });

  testWidgets('a blank presenting concern blocks submission', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Complete visit'));
    await tester.pumpAndSettle();
    verifyNever(() => healthBloc.add(any(that: isA<RecordNewClinicVisit>())));
    expect(find.textContaining('Required'), findsWidgets);
  });

  testWidgets('an out-of-range temperature is rejected with a range hint', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Select or enter concern'),
      'Headache',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Temp (°C)'),
      '55',
    );
    await tester.tap(find.text('Complete visit'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter 30'), findsOneWidget);
    verifyNever(() => healthBloc.add(any(that: isA<RecordNewClinicVisit>())));
  });

  testWidgets(
    'a valid form dispatches a school-scoped, nurse-attributed clinic visit',
    (tester) async {
      await pump(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Select or enter concern'),
        'Severe headache',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Temp (°C)'),
        '37.2',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'HR (bpm)'),
        '88',
      );
      await tester.tap(find.text('Follow-up required'));
      await tester.pump();
      await tester.tap(find.text('Complete visit'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => healthBloc.add(
                  captureAny(that: isA<RecordNewClinicVisit>()),
                ),
              ).captured.single
              as RecordNewClinicVisit;
      final ClinicVisit v = captured.visit;
      expect(v.studentId, 'student-77');
      expect(v.reason, 'Severe headache');
      expect(v.temperature, 37.2);
      expect(v.pulseRate, 88);
      expect(v.followUpRequired, isTrue);
      expect(v.recordedBy, 'nurse-1');
      expect(v.schoolId, 'school-1');
    },
  );

  testWidgets('Save draft only surfaces the local-only notice, no dispatch', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Save draft'));
    await tester.pump();
    expect(
      find.textContaining('Drafts stay local until authorised secure sync'),
      findsOneWidget,
    );
    verifyNever(() => healthBloc.add(any(that: isA<RecordNewClinicVisit>())));
  });

  testWidgets('an error state shows a snackbar and keeps the form open', (
    tester,
  ) async {
    whenListen(
      healthBloc,
      Stream<HealthState>.fromIterable([
        const HealthError('Clinic service is offline'),
      ]),
      initialState: HealthInitial(),
    );
    await pump(tester);
    await tester.pump();
    expect(find.text('Clinic service is offline'), findsOneWidget);
    expect(find.text('Complete visit'), findsOneWidget);
  });

  // The vitals card stacks four labelled inputs in a Row-per-line layout;
  // narrow phones and wide desktops are where it clips or overflows.
  for (final size in const [
    Size(320, 720),
    Size(390, 900),
    Size(834, 1112),
    Size(1440, 900),
  ]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.text('Complete visit'), findsOneWidget);
    });
  }

  testWidgets('renders in dark mode without exceptions', (tester) async {
    await pump(tester, theme: ThemeData.dark());
    expect(tester.takeException(), isNull);
    expect(find.text('Record clinic visit'), findsOneWidget);
  });
}
