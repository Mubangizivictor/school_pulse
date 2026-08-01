import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/emergency_incident.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/nurse/nurse_dashboard.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockAuthRepository extends Mock implements AuthRepository {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHealthBloc extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

void main() {
  const schoolId = 'test-school';
  const nurse = UserEntity(
    id: 'nurse-1',
    name: 'Nurse Grace',
    email: 'nurse@school.test',
    roles: [UserRole.nurse],
    schoolId: schoolId,
  );
  const unassignedNurse = UserEntity(
    id: 'nurse-2',
    name: 'Nurse Without School',
    email: 'unassigned@school.test',
    roles: [UserRole.nurse],
    schoolId: '',
  );
  const emptyDashboard = HealthDashboardLoaded(
    todayVisits: [],
    todayEmergencies: [],
    lowStockItems: [],
    pendingRequests: [],
    stats: {},
  );

  late MockAuthRepository authRepository;
  late MockStudentRepository studentRepository;
  late MockAuthBloc authBloc;
  late MockHealthBloc healthBloc;
  late List<Student> students;
  late List<UserEntity> staff;

  Student student({
    String id = 'student-1',
    String name = 'Amina Okello',
    String className = 'P.5 Blue',
  }) {
    return Student(
      id: id,
      schoolId: schoolId,
      name: name,
      studentCode: 'SP-$id',
      admissionNumber: 'ADM-$id',
      dateOfBirth: DateTime(2014, 3, 12),
      gender: Gender.female,
      classId: className,
      academicYearId: '2026',
      status: StudentStatus.active,
      level: EducationLevel.primary,
    );
  }

  void stubAuth(UserEntity user) {
    when(() => authBloc.state).thenReturn(AuthAuthenticated(user));
  }

  void stubHealth(HealthState state) {
    when(() => healthBloc.state).thenReturn(state);
    when(
      () => healthBloc.stream,
    ).thenAnswer((_) => const Stream<HealthState>.empty());
  }

  Widget buildTestApp() {
    final router = GoRouter(
      initialLocation: '/staff/nurse',
      routes: [
        GoRoute(
          path: '/staff/nurse',
          builder: (context, state) => const NurseDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/messages',
          builder: (context, state) =>
              Scaffold(body: Text('MESSAGES:${state.uri}')),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<HealthBloc>.value(value: healthBloc),
      ],
      child: MaterialApp.router(routerConfig: router, theme: AppTheme.light()),
    );
  }

  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> selectStudent(WidgetTester tester) async {
    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();
    expect(find.text(students.first.name), findsOneWidget);
    await tester.tap(find.text(students.first.name));
    await tester.pumpAndSettle();
  }

  setUpAll(() {
    registerFallbackValue(const FetchHealthDashboardData('fallback-school'));
  });

  setUp(() {
    authRepository = MockAuthRepository();
    studentRepository = MockStudentRepository();
    authBloc = MockAuthBloc();
    healthBloc = MockHealthBloc();
    students = [student()];
    staff = const [];

    di.sl.registerLazySingleton<GetAllStudents>(
      () => GetAllStudents(studentRepository),
    );
    di.sl.registerLazySingleton<GetAllAccessCodes>(
      () => GetAllAccessCodes(studentRepository),
    );
    di.sl.registerLazySingleton<GetStaffMembers>(
      () => GetStaffMembers(authRepository),
    );

    when(
      () => studentRepository.getAllStudents(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => Right(students));
    when(
      () =>
          studentRepository.getAllAccessCodes(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => authRepository.getStaffMembers(),
    ).thenAnswer((_) async => Right(staff));

    stubAuth(nurse);
    stubHealth(emptyDashboard);
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('renders loaded dashboard data for the authenticated school', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final clinicVisit = ClinicVisit(
      id: 'visit-1',
      studentId: students.first.id,
      dateTime: DateTime(2026, 7, 30, 9),
      reason: 'Headache',
      symptoms: 'Mild fever',
      temperature: 37.8,
      diagnosis: 'Rest and fluids',
      outcome: VisitOutcome.sentBackToClass,
      recordedBy: nurse.id,
      schoolId: schoolId,
    );
    final emergency = EmergencyIncident(
      id: 'incident-1',
      studentId: students.first.id,
      dateTime: DateTime(2026, 7, 30, 10),
      incidentDetails: 'Fell during break time',
      firstAidGiven: 'Cleaned the scrape',
      ambulanceRequired: false,
      parentNotified: true,
      staffInvolved: const [],
      outcome: 'Stable',
      recordedBy: nurse.id,
      schoolId: schoolId,
    );
    const lowStockItem = MedicalInventoryItem(
      id: 'stock-1',
      name: 'Paracetamol',
      type: MedicalItemType.medication,
      category: 'Pain relief',
      quantity: 4,
      unit: 'tablets',
      reorderLevel: 10,
      schoolId: schoolId,
    );
    stubHealth(
      HealthDashboardLoaded(
        todayVisits: [clinicVisit],
        todayEmergencies: [emergency],
        lowStockItems: const [lowStockItem],
        pendingRequests: const [],
        stats: const {},
      ),
    );
    await pumpDashboard(tester);

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Visits Today'), findsOneWidget);
    expect(find.text("Today's Emergencies"), findsOneWidget);
    expect(find.text('Fell during break time'), findsOneWidget);
    expect(find.text('Recent Clinic Visits', skipOffstage: false), findsOneWidget);
    expect(find.text('Headache', skipOffstage: false), findsOneWidget);
    expect(find.text('Inventory Alerts', skipOffstage: false), findsOneWidget);
    expect(find.text('Paracetamol', skipOffstage: false), findsOneWidget);
    verify(
      () => healthBloc.add(const FetchHealthDashboardData(schoolId)),
    ).called(1);
    verify(
      () => studentRepository.getAllStudents(schoolId: schoolId),
    ).called(1);
    verify(
      () => studentRepository.getAllAccessCodes(schoolId: schoolId),
    ).called(1);
  });

  testWidgets('renders an empty dashboard without hiding its primary actions', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.text('Student Health', skipOffstage: false), findsOneWidget);
    // The quick action is labelled "Emergency"; "Report Incident" is the title
    // of the dialog it opens.
    expect(find.text('Emergency', skipOffstage: false), findsOneWidget);
    expect(find.text('All History', skipOffstage: false), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('No clinic visits recorded today.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No clinic visits recorded today.'), findsOneWidget);
    expect(
      find.byKey(const Key('nurse-new-visit-button'), skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('renders the load error and retry dispatches a scoped fetch', (
    tester,
  ) async {
    stubHealth(const HealthError('The clinic service is unavailable.'));
    await pumpDashboard(tester);
    clearInteractions(healthBloc);

    expect(find.text('Could not load health data'), findsOneWidget);
    expect(find.text('The clinic service is unavailable.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(
      () => healthBloc.add(const FetchHealthDashboardData(schoolId)),
    ).called(1);
  });

  testWidgets('renders the school-assignment empty state before health data', (
    tester,
  ) async {
    stubAuth(unassignedNurse);
    stubHealth(HealthLoading());

    await pumpDashboard(tester);

    expect(find.text('School assignment required'), findsOneWidget);
    expect(find.textContaining('not assigned to a school'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'contact sheet includes only active same-school leadership and store staff and deep-links',
    (tester) async {
      staff = const [
        UserEntity(
          id: 'head-1',
          name: 'Mrs. Amina',
          email: '',
          roles: [UserRole.headTeacher],
          schoolId: schoolId,
        ),
        UserEntity(
          id: 'director-1',
          name: 'Mr. Okwir',
          email: '',
          roles: [UserRole.director],
          schoolId: schoolId,
        ),
        UserEntity(
          id: 'store-1',
          name: 'Mr. Byaruhanga',
          email: '',
          roles: [UserRole.storeInventory],
          schoolId: schoolId,
        ),
        UserEntity(
          id: 'teacher-1',
          name: 'Ms. Nakato',
          email: '',
          roles: [UserRole.classTeacher],
          schoolId: schoolId,
        ),
        UserEntity(
          id: 'inactive-head',
          name: 'Inactive Head',
          email: '',
          roles: [UserRole.headTeacher],
          schoolId: schoolId,
          isActive: false,
        ),
        UserEntity(
          id: 'other-store',
          name: 'Other School Storekeeper',
          email: '',
          roles: [UserRole.storeInventory],
          schoolId: 'another-school',
        ),
      ];

      await pumpDashboard(tester);
      // "Support" sits at the end of the quick-action row, below the fold at
      // the default 800x600 test surface.
      await tester.ensureVisible(find.text('Support'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Support'));
      await tester.pumpAndSettle();

      expect(find.text('Mrs. Amina'), findsOneWidget);
      expect(find.text('Mr. Okwir'), findsOneWidget);
      expect(find.text('Mr. Byaruhanga'), findsOneWidget);
      expect(find.text('Ms. Nakato'), findsNothing);
      expect(find.text('Inactive Head'), findsNothing);
      expect(find.text('Other School Storekeeper'), findsNothing);

      await tester.tap(find.text('Mr. Byaruhanga'));
      await tester.pumpAndSettle();

      expect(find.textContaining('recipientId=store-1'), findsOneWidget);
      expect(find.textContaining('recipientRole=Storekeeper'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new visit shows required-field and temperature validation', (
    tester,
  ) async {
    await pumpDashboard(tester);
    clearInteractions(healthBloc);

    await tester.tap(find.byKey(const Key('nurse-new-visit-button')));
    await tester.pumpAndSettle();
    expect(find.text('New Clinic Visit'), findsOneWidget);

    await tester.tap(find.byKey(const Key('complete-visit-button')));
    await tester.pump();
    expect(find.text('Select a student.'), findsOneWidget);

    await selectStudent(tester);
    await tester.tap(find.byKey(const Key('complete-visit-button')));
    await tester.pump();
    expect(find.text('Enter the reason for the visit.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('visit-reason-field')),
      'Feeling unwell',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Temp (°C)'), '46.2');
    await tester.ensureVisible(find.byKey(const Key('complete-visit-button')));
    await tester.tap(find.byKey(const Key('complete-visit-button')));
    await tester.pump();

    expect(
      find.text('Enter a temperature between 30°C and 45°C.'),
      findsOneWidget,
    );
    verifyNever(() => healthBloc.add(any()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('new visit dispatches a tenant-scoped clinic visit', (
    tester,
  ) async {
    await pumpDashboard(tester);
    clearInteractions(healthBloc);

    await tester.tap(find.byKey(const Key('nurse-new-visit-button')));
    await tester.pumpAndSettle();
    await selectStudent(tester);
    await tester.enterText(
      find.byKey(const Key('visit-reason-field')),
      'Headache',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Symptoms'),
      'Tired and dizzy',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Temp (°C)'), '37.5');
    await tester.enterText(
      find.widgetWithText(TextField, 'Diagnosis / Notes'),
      'Rest and hydrate',
    );
    await tester.ensureVisible(find.byKey(const Key('complete-visit-button')));
    await tester.tap(find.byKey(const Key('complete-visit-button')));
    await tester.pumpAndSettle();

    final captured = verify(() => healthBloc.add(captureAny())).captured;
    expect(captured, hasLength(1));
    final event = captured.single as RecordNewClinicVisit;
    expect(event.visit.studentId, students.first.id);
    expect(event.visit.reason, 'Headache');
    expect(event.visit.symptoms, 'Tired and dizzy');
    expect(event.visit.temperature, 37.5);
    expect(event.visit.diagnosis, 'Rest and hydrate');
    expect(event.visit.outcome, VisitOutcome.sentBackToClass);
    expect(event.visit.recordedBy, nurse.id);
    expect(event.visit.schoolId, schoolId);
    expect(find.text('New Clinic Visit'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('emergency dialog validates and dispatches a scoped incident', (
    tester,
  ) async {
    await pumpDashboard(tester);
    clearInteractions(healthBloc);

    await tester.tap(find.text('Emergency'));
    await tester.pumpAndSettle();
    expect(find.text('Report Emergency Incident'), findsOneWidget);

    await tester.tap(find.byKey(const Key('record-emergency-button')));
    await tester.pump();
    expect(find.text('Select the student involved.'), findsOneWidget);

    await selectStudent(tester);
    await tester.tap(find.byKey(const Key('record-emergency-button')));
    await tester.pump();
    expect(find.text('Describe what happened.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('emergency-details-field')),
      'Fell on the playground',
    );
    await tester.tap(find.text('Ambulance required'));
    await tester.tap(find.text('Parent already notified'));
    await tester.ensureVisible(
      find.byKey(const Key('record-emergency-button')),
    );
    await tester.tap(find.byKey(const Key('record-emergency-button')));
    await tester.pumpAndSettle();

    final captured = verify(() => healthBloc.add(captureAny())).captured;
    expect(captured, hasLength(1));
    final event = captured.single as RecordNewEmergencyIncident;
    expect(event.incident.studentId, students.first.id);
    expect(event.incident.incidentDetails, 'Fell on the playground');
    expect(event.incident.ambulanceRequired, isTrue);
    expect(event.incident.parentNotified, isTrue);
    expect(event.incident.outcome, 'Pending assessment');
    expect(event.incident.recordedBy, nurse.id);
    expect(event.incident.schoolId, schoolId);
    expect(find.text('Report Emergency Incident'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard and new-visit sheet do not overflow a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    expect(find.text('Welcome back,'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nurse-new-visit-button')));
    await tester.pumpAndSettle();

    expect(find.text('New Clinic Visit'), findsOneWidget);
    expect(find.byKey(const Key('complete-visit-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
