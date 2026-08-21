import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/theme/branding_theme_engine.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/teacher_student_list_screen.dart';

class _FakeAuthBloc extends Cubit<AuthState> implements AuthBloc {
  _FakeAuthBloc() : super(AuthInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeClassTeacherContextBloc extends Cubit<ClassTeacherContextState>
    implements ClassTeacherContextBloc {
  _FakeClassTeacherContextBloc(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Always inactive: this screen's role branch reads it to decide whether to
/// show the Subject Teacher roster instead, and these tests are exercising
/// the Class Teacher path.
class _FakeSubjectTeacherContextBloc extends Cubit<SubjectTeacherContextState>
    implements SubjectTeacherContextBloc {
  _FakeSubjectTeacherContextBloc()
    : super(const SubjectTeacherContextState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeClassStudentsBloc extends Cubit<ClassStudentsState>
    implements ClassStudentsBloc {
  _FakeClassStudentsBloc(super.initialState);

  @override
  void add(ClassStudentsEvent event) {
    if (event is ClassStudentsFiltered) {
      emit(state.copyWith(filter: event.filter));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ActiveResponsibilityContext _context() => ActiveResponsibilityContext(
  schoolId: 'school1',
  academicYearId: '2026',
  staffId: 'staff1',
  userId: 'user1',
  roleAssignmentId: 'ra1',
  roleType: StaffResponsibilityType.classTeacher,
  className: 'Primary 5',
  streamName: 'East',
  assignmentStartDate: DateTime(2026, 1, 1),
);

List<ClassStudentSummary> _roster() => [
  ClassStudentSummary(
    studentId: 's1',
    schoolId: 'school1',
    name: 'Abalo Peter',
    admissionNumber: '2021/PE/010',
    classId: 'p5',
    className: 'P5',
    academicYearId: '2026',
  ),
  ClassStudentSummary(
    studentId: 's2',
    schoolId: 'school1',
    name: 'Adong Grace',
    admissionNumber: '2021/PE/011',
    classId: 'p5',
    className: 'P5',
    academicYearId: '2026',
  ),
];

Widget _harness({
  required Brightness brightness,
  required ClassStudentsState studentsState,
}) {
  final router = GoRouter(
    initialLocation: '/staff/students',
    routes: [
      GoRoute(
        path: '/staff/students',
        builder: (context, state) => const TeacherStudentListScreen(),
      ),
      GoRoute(
        path: '/staff/students/:id',
        builder: (context, state) => const Scaffold(body: Text('profile')),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(create: (_) => _FakeAuthBloc()),
      BlocProvider<ClassTeacherContextBloc>(
        create: (_) => _FakeClassTeacherContextBloc(
          ClassTeacherContextState(active: _context()),
        ),
      ),
      BlocProvider<SubjectTeacherContextBloc>(
        create: (_) => _FakeSubjectTeacherContextBloc(),
      ),
      BlocProvider<ClassStudentsBloc>(
        create: (_) => _FakeClassStudentsBloc(studentsState),
      ),
    ],
    child: MaterialApp.router(
      theme: BrandingThemeEngine.createTheme(null, brightness),
      routerConfig: router,
    ),
  );
}

List<ClassStudentSummary> _largeRoster(int count) => List.generate(
  count,
  (i) => ClassStudentSummary(
    studentId: 's$i',
    schoolId: 'school1',
    name: 'Student Number $i',
    admissionNumber: '2021/PE/0$i',
    classId: 'p5',
    className: 'P5',
    academicYearId: '2026',
  ),
);

void main() {
  testWidgets(
    'keeps stats, search and quick filters on screen without overflow '
    'when the roster is long, on a small device size',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _harness(
          brightness: Brightness.light,
          studentsState: ClassStudentsState(students: _largeRoster(30)),
        ),
      );
      await tester.pumpAndSettle();

      // Chrome that must stay visible without the user scrolling for it.
      expect(find.text('Total Students'), findsOneWidget);
      expect(find.text('Students List'), findsNothing);
      expect(find.text('Quick Filters'), findsOneWidget);
      expect(find.text('Student Number 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders populated roster with stats in light mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        brightness: Brightness.light,
        studentsState: ClassStudentsState(
          students: _roster(),
          attendance: const {
            's1': LessonAttendanceStatus.present,
            's2': LessonAttendanceStatus.late,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Students'), findsWidgets);
    expect(find.text('Abalo Peter'), findsOneWidget);
    expect(find.text('Adong Grace'), findsOneWidget);
    expect(find.text('Total Students'), findsOneWidget);
    expect(find.text('Present Today'), findsOneWidget);
    expect(find.text('Absent Today'), findsOneWidget);
    expect(find.text('Late Today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders populated roster with stats in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        brightness: Brightness.dark,
        studentsState: ClassStudentsState(
          students: _roster(),
          attendance: const {'s1': LessonAttendanceStatus.absent},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Abalo Peter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows empty state when class has no students', (tester) async {
    await tester.pumpWidget(
      _harness(
        brightness: Brightness.light,
        studentsState: const ClassStudentsState(students: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No students found'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick filter chips reflect selection and dispatch events', (
    tester,
  ) async {
    final bloc = _FakeClassStudentsBloc(
      ClassStudentsState(students: _roster()),
    );

    final router = GoRouter(
      initialLocation: '/staff/students',
      routes: [
        GoRoute(
          path: '/staff/students',
          builder: (context, state) => const TeacherStudentListScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => _FakeAuthBloc()),
          BlocProvider<ClassTeacherContextBloc>(
            create: (_) => _FakeClassTeacherContextBloc(
              ClassTeacherContextState(active: _context()),
            ),
          ),
          BlocProvider<SubjectTeacherContextBloc>(
            create: (_) => _FakeSubjectTeacherContextBloc(),
          ),
          BlocProvider<ClassStudentsBloc>(create: (_) => bloc),
        ],
        child: MaterialApp.router(
          theme: BrandingThemeEngine.createTheme(null, Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Late'), findsOneWidget);
    await tester.tap(find.text('Late'));
    await tester.pump();

    expect(bloc.state.filter, isNot(ClassRosterFilter.all));
  });
}
