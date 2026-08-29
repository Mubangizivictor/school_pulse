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
import 'package:school_pulse/features/health/presentation/screens/nurse_clinic_visits_screen.dart';

class MockHealthBloc extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

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

  ClinicVisit visit({
    String id = 'v1',
    String studentId = 'student-1',
    String reason = 'Severe headache',
    bool followUp = false,
  }) => ClinicVisit(
    id: id,
    studentId: studentId,
    dateTime: DateTime(2026, 7, 25, 10, 15),
    reason: reason,
    symptoms: 'Head pain',
    outcome: VisitOutcome.sentBackToClass,
    followUpRequired: followUp,
    recordedBy: 'nurse-1',
    schoolId: 'school-1',
  );

  setUpAll(() {
    registerFallbackValue(const FetchClinicVisits(schoolId: 'fallback'));
  });

  setUp(() {
    healthBloc = MockHealthBloc();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(nurse));
  });

  Future<void> pump(
    WidgetTester tester, {
    required HealthState state,
    Size size = const Size(390, 844),
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => healthBloc.state).thenReturn(state);

    final router = GoRouter(
      initialLocation: '/staff/nurse/visits',
      routes: [
        GoRoute(
          path: '/staff/nurse/visits',
          builder: (context, state) => const NurseClinicVisitsScreen(),
        ),
        GoRoute(
          path: '/staff/nurse/lookup',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/nurse/profile/:id',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HealthBloc>.value(value: healthBloc),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('fetches visits scoped to the nurse school on first build', (
    tester,
  ) async {
    await pump(tester, state: const ClinicVisitsLoaded([]));
    verify(
      () => healthBloc.add(const FetchClinicVisits(schoolId: 'school-1')),
    ).called(1);
  });

  testWidgets('renders a visit card with reason and completed status', (
    tester,
  ) async {
    await pump(tester, state: ClinicVisitsLoaded([visit()]));
    expect(find.text('Clinic visits'), findsOneWidget);
    expect(find.text('Severe headache'), findsOneWidget);
    expect(find.text('student-1'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('marks a follow-up visit distinctly', (tester) async {
    await pump(
      tester,
      state: ClinicVisitsLoaded([
        visit(reason: 'Sprained ankle', followUp: true),
      ]),
    );
    expect(find.text('Follow-up'), findsOneWidget);
    expect(find.text('Follow-up required'), findsOneWidget);
  });

  testWidgets('search filters the list by reason and shows the empty state', (
    tester,
  ) async {
    await pump(
      tester,
      state: ClinicVisitsLoaded([
        visit(id: 'v1', reason: 'Severe headache'),
        visit(id: 'v2', studentId: 'student-2', reason: 'Stomach ache'),
      ]),
    );
    expect(find.text('Severe headache'), findsOneWidget);
    expect(find.text('Stomach ache'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'stomach');
    await tester.pump();
    expect(find.text('Severe headache'), findsNothing);
    expect(find.text('Stomach ache'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nothing-matches');
    await tester.pump();
    expect(find.text('No matching visits'), findsOneWidget);
  });

  testWidgets('follow-up filter toggle narrows to follow-up visits only', (
    tester,
  ) async {
    await pump(
      tester,
      state: ClinicVisitsLoaded([
        visit(id: 'v1', reason: 'Routine check'),
        visit(id: 'v2', reason: 'Deep cut', followUp: true),
      ]),
    );
    expect(find.text('Routine check'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Filter'));
    await tester.pump();
    expect(find.text('Routine check'), findsNothing);
    expect(find.text('Deep cut'), findsOneWidget);
  });

  testWidgets('shows the loading spinner for HealthLoading', (tester) async {
    await pump(tester, state: HealthLoading(), settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('empty state shown when there are no visits at all', (
    tester,
  ) async {
    await pump(tester, state: const ClinicVisitsLoaded([]));
    expect(find.text('No matching visits'), findsOneWidget);
  });

  testWidgets('new-visit FAB routes to the student lookup', (tester) async {
    await pump(tester, state: const ClinicVisitsLoaded([]));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    // A successful push to /staff/nurse/lookup unmounts the visits title.
    expect(find.text('Clinic visits'), findsNothing);
  });

  // Responsive: the visit card packs a time column, an icon, a long student
  // id, a status pill and a chevron into one Row — the layout that most
  // easily overflows on a narrow phone and clips on a wide desktop.
  for (final size in const [
    Size(320, 640), // small phone
    Size(390, 844), // typical phone
    Size(768, 1024), // tablet portrait
    Size(1280, 900), // desktop / web
  ]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pump(
        tester,
        size: size,
        state: ClinicVisitsLoaded([
          visit(
            id: 'v1',
            studentId: 'a-very-long-student-identifier-000000001',
            reason:
                'Persistent headache since morning assembly with mild fever and '
                'light sensitivity, sent to sick bay for observation',
            followUp: true,
          ),
          visit(id: 'v2', reason: 'Routine dressing change'),
        ]),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Clinic visits'), findsOneWidget);
    });
  }

  testWidgets('renders correctly in dark mode without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => healthBloc.state).thenReturn(ClinicVisitsLoaded([visit()]));

    final router = GoRouter(
      initialLocation: '/staff/nurse/visits',
      routes: [
        GoRoute(
          path: '/staff/nurse/visits',
          builder: (context, state) => const NurseClinicVisitsScreen(),
        ),
        GoRoute(
          path: '/staff/nurse/lookup',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/nurse/profile/:id',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HealthBloc>.value(value: healthBloc),
        ],
        child: MaterialApp.router(
          theme: ThemeData.dark(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Severe headache'), findsOneWidget);
  });
}
