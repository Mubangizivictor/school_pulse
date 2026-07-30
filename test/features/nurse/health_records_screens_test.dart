import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/emergency_incident.dart';
import 'package:school_pulse/features/health/domain/entities/student_health_profile.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/health/presentation/screens/health_history_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/incident_details_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/student_health_profile_screen.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockHealthBloc extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  late MockHealthBloc healthBloc;
  late MockAuthBloc authBloc;
  late MockStudentRepository studentRepository;

  const nurse = UserEntity(
    id: 'nurse-1',
    name: 'Nurse Grace',
    email: 'nurse@school.test',
    roles: [UserRole.nurse],
    schoolId: 'school-1',
  );

  final student = Student(
    id: 'student-1',
    schoolId: 'school-1',
    name: 'Amina Kato',
    studentCode: 'SP001',
    admissionNumber: 'ADM001',
    dateOfBirth: DateTime(2014, 3, 2),
    gender: Gender.female,
    classId: 'P.6 East',
    academicYearId: '2026',
    status: StudentStatus.active,
    level: EducationLevel.primary,
  );

  final visit = ClinicVisit(
    id: 'visit-1',
    studentId: 'student-1',
    dateTime: DateTime(2026, 7, 25, 10),
    reason: 'Severe headache',
    symptoms: 'Head pain',
    outcome: VisitOutcome.sentBackToClass,
    recordedBy: 'nurse-1',
    schoolId: 'school-1',
  );

  final incident = EmergencyIncident(
    id: 'incident-1',
    studentId: 'student-1',
    dateTime: DateTime(2026, 7, 26, 11),
    incidentDetails: 'Fell during athletics practice',
    firstAidGiven: 'Cleaned and dressed the wound',
    ambulanceRequired: false,
    parentNotified: true,
    staffInvolved: const ['nurse-1'],
    outcome: 'Returned to class after observation',
    recordedBy: 'nurse-1',
    schoolId: 'school-1',
  );

  const profile = StudentHealthProfile(
    studentId: 'student-1',
    schoolId: 'school-1',
    bloodGroup: 'O',
    rhesusFactor: '+',
    height: 151,
    weight: 42,
    bmi: 18.4,
    allergies: ['Penicillin'],
    chronicIllnesses: ['Asthma'],
    currentMedications: ['Inhaler'],
    emergencyContactName: 'Sarah Kato',
    emergencyContactPhone: '+256700000001',
  );

  setUpAll(() {
    registerFallbackValue(const FetchInventory('fallback-school'));
  });

  setUp(() async {
    await di.sl.reset();
    healthBloc = MockHealthBloc();
    authBloc = MockAuthBloc();
    studentRepository = MockStudentRepository();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(nurse));
    when(
      () => studentRepository.getAllStudents(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => Right([student]));
    di.sl.registerLazySingleton<GetAllStudents>(
      () => GetAllStudents(studentRepository),
    );
  });

  tearDown(() async {
    await di.sl.reset();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required Widget screen,
    required HealthState state,
  }) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => healthBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HealthBloc>.value(value: healthBloc),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HealthHistoryScreen', () {
    testWidgets('loads student names, renders visits, and filters by reason', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        screen: const HealthHistoryScreen(),
        state: ClinicVisitsLoaded([visit]),
      );

      expect(find.text('Amina Kato'), findsOneWidget);
      expect(find.text('Severe headache'), findsOneWidget);
      verify(
        () => healthBloc.add(const FetchClinicVisits(schoolId: 'school-1')),
      ).called(1);

      await tester.enterText(find.byType(TextField), 'stomach ache');
      await tester.pump();
      expect(find.text('No matching records found.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'headache');
      await tester.pump();
      expect(find.text('Severe headache'), findsOneWidget);
    });

    testWidgets('shows an empty result when there are no visits', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        screen: const HealthHistoryScreen(),
        state: const ClinicVisitsLoaded([]),
      );

      expect(find.text('No matching records found.'), findsOneWidget);
    });

    testWidgets('shows a load error and retries', (tester) async {
      await pumpScreen(
        tester,
        screen: const HealthHistoryScreen(),
        state: const HealthError('Clinic service is offline'),
      );

      expect(find.text('Could not load clinic history'), findsOneWidget);
      expect(find.text('Clinic service is offline'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(
        () => healthBloc.add(const FetchClinicVisits(schoolId: 'school-1')),
      ).called(2);
    });
  });

  group('StudentHealthProfileScreen', () {
    testWidgets('renders the profile and adds a validated allergy', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        screen: const StudentHealthProfileScreen(studentId: 'student-1'),
        state: StudentHealthProfileLoaded(
          profile: profile,
          visitHistory: [visit],
          incidentHistory: [incident],
        ),
      );

      expect(find.text('Amina Kato'), findsWidgets);
      expect(find.text('O+'), findsOneWidget);
      expect(find.textContaining('Penicillin'), findsOneWidget);
      expect(find.text('Sarah Kato'), findsOneWidget);
      verify(
        () => healthBloc.add(
          const FetchStudentHealthProfile('student-1', 'school-1'),
        ),
      ).called(1);

      final addAllergy = find.byIcon(Icons.add_alert_outlined);
      await tester.ensureVisible(addAllergy);
      await tester.tap(addAllergy);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Add allergy or sensitivity'), findsOneWidget);
      verifyNever(() => healthBloc.add(any(that: isA<UpdateHealthProfile>())));

      await tester.enterText(
        find.widgetWithText(TextField, 'Allergen'),
        'Peanuts',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final event =
          verify(
                () => healthBloc.add(
                  captureAny(that: isA<UpdateHealthProfile>()),
                ),
              ).captured.single
              as UpdateHealthProfile;
      expect(event.schoolId, 'school-1');
      expect(event.profile.allergies, ['Penicillin', 'Peanuts']);
    });

    testWidgets('shows an error and retries the same student profile', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        screen: const StudentHealthProfileScreen(studentId: 'student-1'),
        state: const HealthError('Profile could not be read'),
      );

      expect(find.text('Could not load health profile'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(
        () => healthBloc.add(
          const FetchStudentHealthProfile('student-1', 'school-1'),
        ),
      ).called(2);
    });
  });

  group('IncidentDetailsScreen', () {
    testWidgets('renders the matched incident and resolved student details', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        screen: const IncidentDetailsScreen(incidentId: 'incident-1'),
        state: EmergencyIncidentsLoaded([incident]),
      );

      expect(find.text('EMERGENCY REPORT'), findsOneWidget);
      expect(find.text('Amina Kato'), findsOneWidget);
      expect(find.text('Class: P.6 East'), findsOneWidget);
      expect(find.text('Fell during athletics practice'), findsOneWidget);
      expect(find.text('Cleaned and dressed the wound'), findsOneWidget);
      expect(find.text('Parent Notified'), findsOneWidget);
      verify(
        () =>
            healthBloc.add(const FetchEmergencyIncidents(schoolId: 'school-1')),
      ).called(1);
    });

    testWidgets('shows not found when the incident id is absent', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        screen: const IncidentDetailsScreen(incidentId: 'missing'),
        state: EmergencyIncidentsLoaded([incident]),
      );

      expect(find.text('Incident not found.'), findsOneWidget);
      verifyNever(
        () =>
            studentRepository.getAllStudents(schoolId: any(named: 'schoolId')),
      );
    });

    testWidgets('shows an error and retries incident loading', (tester) async {
      await pumpScreen(
        tester,
        screen: const IncidentDetailsScreen(incidentId: 'incident-1'),
        state: const HealthError('Incident service is unavailable'),
      );

      expect(find.text('Could not load incident'), findsOneWidget);
      expect(find.text('Incident service is unavailable'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(
        () =>
            healthBloc.add(const FetchEmergencyIncidents(schoolId: 'school-1')),
      ).called(2);
    });
  });
}
