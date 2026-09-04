import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_bloc.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_event.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_directory_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _FakeAuthBloc extends Cubit<AuthState> implements AuthBloc {
  _FakeAuthBloc(super.initialState);

  @override
  void add(AuthEvent event) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStructureBloc extends Cubit<StructureState> implements StructureBloc {
  _FakeStructureBloc(super.initialState);

  @override
  void add(StructureEvent event) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStudentsBloc extends Cubit<StudentsState> implements StudentsBloc {
  _FakeStudentsBloc(super.initialState);

  final List<StudentsEvent> events = [];

  @override
  void add(StudentsEvent event) {
    events.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAttendanceBloc extends Cubit<AttendanceState> implements AttendanceBloc {
  _FakeAttendanceBloc(super.initialState);

  @override
  void add(AttendanceEvent event) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _user = UserEntity(
  id: 'admin-1',
  name: 'Test Admin',
  email: 'admin@example.com',
  schoolId: 'school-123',
  roles: [UserRole.schoolAdmin],
);

Student _student({
  required String id,
  required String name,
  String admissionNumber = 'ADM-0001',
  String classId = 'class-1',
  String? streamId = 'stream-1',
  StudentStatus status = StudentStatus.enrolled,
  StudentBoardingType? boardingType = StudentBoardingType.day,
}) => Student(
  id: id,
  schoolId: 'school-123',
  name: name,
  studentCode: 'SC-$id',
  admissionNumber: admissionNumber,
  dateOfBirth: DateTime(2010, 1, 1),
  gender: Gender.male,
  classId: classId,
  streamId: streamId,
  academicYearId: 'year-1',
  status: status,
  emergencyContacts: const [],
  parentIds: const [],
  documents: const {},
  level: EducationLevel.secondary,
  boardingType: boardingType,
);

final _structureState = StructureState(
  isLoading: false,
  academicYears: [
    AcademicYear(
      id: 'year-1',
      schoolId: 'school-123',
      name: '2026',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
    ),
  ],
  classes: const [
    SchoolClass(id: 'class-1', schoolId: 'school-123', name: '10-A'),
  ],
  streams: const [
    ClassStream(
      id: 'stream-1',
      schoolId: 'school-123',
      name: 'Science',
      classId: 'class-1',
    ),
  ],
);

AttendanceRecord _record(String personId, AttendanceStatus status) =>
    AttendanceRecord(
      id: 'rec-$personId',
      schoolId: 'school-123',
      category: AttendanceCategory.students,
      scopeId: 'class-1',
      scopeName: '10-A',
      sessionType: 'daily',
      date: DateTime.now(),
      personId: personId,
      personName: 'Learner $personId',
      status: status,
      method: AttendanceMethod.manual,
      markedBy: 'admin-1',
      operatorId: 'admin-1',
      deviceId: 'device-1',
      syncStatus: AttendanceSyncStatus.synced,
      createdAt: DateTime.now(),
    );

void main() {
  late _FakeAuthBloc authBloc;
  late _FakeStructureBloc structureBloc;
  late _FakeStudentsBloc studentsBloc;
  late _FakeAttendanceBloc attendanceBloc;

  setUp(() {
    authBloc = _FakeAuthBloc(const AuthAuthenticated(_user));
    structureBloc = _FakeStructureBloc(_structureState);
    studentsBloc = _FakeStudentsBloc(StudentsLoading());
    attendanceBloc = _FakeAttendanceBloc(AttendanceInitial());

    if (di.sl.isRegistered<StudentsBloc>()) {
      di.sl.unregister<StudentsBloc>();
    }
    di.sl.registerFactory<StudentsBloc>(() => studentsBloc);

    if (di.sl.isRegistered<AttendanceBloc>()) {
      di.sl.unregister<AttendanceBloc>();
    }
    di.sl.registerFactory<AttendanceBloc>(() => attendanceBloc);
  });

  tearDown(() {
    if (di.sl.isRegistered<StudentsBloc>()) di.sl.unregister<StudentsBloc>();
    if (di.sl.isRegistered<AttendanceBloc>()) di.sl.unregister<AttendanceBloc>();
  });

  Widget buildSubject({Size size = const Size(390, 844)}) {
    final router = GoRouter(
      initialLocation: '/students',
      routes: [
        GoRoute(
          path: '/students',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<StructureBloc>.value(value: structureBloc),
            ],
            child: const AdminStudentDirectoryScreen(),
          ),
        ),
        GoRoute(
          path: '/staff/admin/students/:id',
          builder: (context, state) =>
              Scaffold(body: Text('profile-${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/staff/admin/admissions/register',
          builder: (context, state) => const Scaffold(body: Text('enrol')),
        ),
        GoRoute(
          path: '/staff/attendance',
          builder: (context, state) =>
              const Scaffold(body: Text('attendance-hub')),
        ),
      ],
    );

    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
  }

  group('loading / error / empty states', () {
    testWidgets('shows loading skeleton while StudentsLoading', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('shows error state with retry on StudentsError', (tester) async {
      studentsBloc.emit(const StudentsError('network down'));
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Could not load learners'), findsOneWidget);
      expect(find.text('network down'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(studentsBloc.events, contains(isA<LoadSchoolStudents>()));
    });

    testWidgets('shows empty state offering Add learner when no students exist', (
      tester,
    ) async {
      studentsBloc.emit(const StudentsLoaded([]));
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No students found'), findsOneWidget);
      expect(find.text('Add learner'), findsWidgets);
    });

    testWidgets('empty state offers Clear filters when filters applied', (
      tester,
    ) async {
      studentsBloc.emit(StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]));
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'zzz-no-match');
      await tester.pumpAndSettle();

      expect(find.text('No students found'), findsOneWidget);
      expect(find.text('Clear filters'), findsWidgets);
    });
  });

  group('directory content', () {
    testWidgets('renders learner rows with name, admission no. and class/stream', (
      tester,
    ) async {
      studentsBloc.emit(
        StudentsLoaded([
          _student(id: 's1', name: 'Aarav Sharma', admissionNumber: 'ADM-2025-0001'),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.textContaining('ADM-2025-0001'), findsWidgets);
      expect(find.textContaining('10-A'), findsWidgets);
    });

    testWidgets('search filters the learner list', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([
          _student(id: 's1', name: 'Aarav Sharma'),
          _student(id: 's2', name: 'Priya Singh'),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Priya Singh'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Priya');
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsNothing);
      expect(find.text('Priya Singh'), findsOneWidget);
    });

    testWidgets('sort toggles to Name A-Z', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([
          _student(id: 's1', name: 'Zara Khan'),
          _student(id: 's2', name: 'Aarav Sharma'),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recently added'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name A–Z').last);
      await tester.pumpAndSettle();

      final aaravPos = tester.getTopLeft(find.text('Aarav Sharma'));
      final zaraPos = tester.getTopLeft(find.text('Zara Khan'));
      expect(aaravPos.dy, lessThan(zaraPos.dy));
    });

    testWidgets('pagination shows "Show more" button beyond page size', (
      tester,
    ) async {
      studentsBloc.emit(
        StudentsLoaded(
          List.generate(
            45,
            (i) => _student(id: 's$i', name: 'Learner $i'),
          ),
        ),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Show more'), findsOneWidget);
    });

    testWidgets('tapping a learner row navigates to profile route', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aarav Sharma'));
      await tester.pumpAndSettle();

      expect(find.text('profile-s1'), findsOneWidget);
    });

    testWidgets('Add learner navigates to admissions register route', (
      tester,
    ) async {
      studentsBloc.emit(const StudentsLoaded([]));
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add learner').first);
      await tester.pumpAndSettle();

      expect(find.text('enrol'), findsOneWidget);
    });
  });

  group('attendance strip', () {
    testWidgets('hides when no attendance data is available', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining("Today's attendance"), findsNothing);
    });

    testWidgets('shows present percentage/count and links to attendance', (
      tester,
    ) async {
      studentsBloc.emit(
        StudentsLoaded([
          _student(id: 's1', name: 'Aarav Sharma'),
          _student(id: 's2', name: 'Priya Singh'),
        ]),
      );
      attendanceBloc.emit(
        RecordsLoaded([
          _record('s1', AttendanceStatus.present),
          _record('s2', AttendanceStatus.absent),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('50% present'), findsOneWidget);
      expect(find.text('View attendance'), findsOneWidget);

      await tester.tap(find.text('View attendance'));
      await tester.pumpAndSettle();
      expect(find.text('attendance-hub'), findsOneWidget);
    });

    testWidgets('shows retry banner on attendance error', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]),
      );
      attendanceBloc.emit(const AttendanceError('offline'));
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Could not load today'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('responsiveness', () {
    testWidgets('uses mobile list layout under smallDesktop breakpoint', (
      tester,
    ) async {
      studentsBloc.emit(
        StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]),
      );
      await tester.pumpWidget(buildSubject(size: const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('uses dense table layout at desktop widths', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]),
      );
      await tester.pumpWidget(buildSubject(size: const Size(1440, 900)));
      await tester.pumpAndSettle();

      expect(find.text('Admission no.'), findsOneWidget);
      expect(find.text('Learner'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
    });

    testWidgets('tablet width renders without overflow', (tester) async {
      studentsBloc.emit(
        StudentsLoaded([_student(id: 's1', name: 'Aarav Sharma')]),
      );
      await tester.pumpWidget(buildSubject(size: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('filters', () {
    testWidgets('active filter count badge appears once a filter is applied', (
      tester,
    ) async {
      studentsBloc.emit(
        StudentsLoaded([
          _student(id: 's1', name: 'Aarav Sharma', status: StudentStatus.enrolled),
          _student(id: 's2', name: 'Priya Singh', status: StudentStatus.withdrawn),
        ]),
      );
      await tester.pumpWidget(buildSubject(size: const Size(1440, 900)));
      await tester.pumpAndSettle();

      expect(find.text('Clear filters'), findsNothing);

      // Desktop pill: open status filter and select "Withdrawn".
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Withdrawn').last);
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsNothing);
      expect(find.text('Priya Singh'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });
  });
}
