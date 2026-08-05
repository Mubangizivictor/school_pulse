import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_dashboard/subject_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/screens/subject_teacher_dashboard.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockContextBloc
    extends MockBloc<SubjectTeacherContextEvent, SubjectTeacherContextState>
    implements SubjectTeacherContextBloc {}

class _MockDashboardBloc
    extends MockBloc<SubjectTeacherDashboardEvent, SubjectTeacherDashboardState>
    implements SubjectTeacherDashboardBloc {}

const _user = UserEntity(
  id: 'user1',
  name: 'Grace Nakato',
  email: 'grace@school.test',
  schoolId: 'school1',
  roles: [UserRole.subjectTeacher],
);

StaffRoleAssignment _assignment({
  required String id,
  String subjectId = 'maths',
  String subjectName = 'Mathematics',
  String classId = 'g10a',
  String className = 'Grade 10',
  StaffResponsibilityType roleType = StaffResponsibilityType.subjectTeacher,
}) {
  return StaffRoleAssignment(
    id: id,
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: roleType,
    academicYearId: '2026',
    subjectId: subjectId,
    subjectName: subjectName,
    classId: classId,
    className: className,
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );
}

final _activeContext = ActiveResponsibilityContext.fromAssignment(
  _assignment(id: 'a1'),
  termId: 't2',
  termName: 'Term 2',
  academicYearName: '2025/2026',
);

void main() {
  late _MockAuthBloc authBloc;
  late _MockContextBloc contextBloc;
  late _MockDashboardBloc dashboardBloc;

  setUp(() {
    authBloc = _MockAuthBloc();
    contextBloc = _MockContextBloc();
    dashboardBloc = _MockDashboardBloc();
    when(() => authBloc.state).thenReturn(AuthAuthenticated(_user));
  });

  Future<void> pump(
    WidgetTester tester, {
    required SubjectTeacherContextState contextState,
    SubjectTeacherDashboardState dashboardState =
        const SubjectTeacherDashboardState(),
  }) async {
    when(() => contextBloc.state).thenReturn(contextState);
    when(() => dashboardBloc.state).thenReturn(dashboardState);

    // The dashboard is a long scroll and its slivers build lazily. A default
    // 600x800 surface stops before My Teaching, so the tabs would never be
    // constructed for the test to find.
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<SubjectTeacherContextBloc>.value(value: contextBloc),
            BlocProvider<SubjectTeacherDashboardBloc>.value(
              value: dashboardBloc,
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => const SubjectTeacherDashboard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('names the active subject, class and term from the context', (
    tester,
  ) async {
    await pump(
      tester,
      contextState: SubjectTeacherContextState(
        active: _activeContext,
        available: [_assignment(id: 'a1')],
      ),
    );

    // Named in the context card heading and again in the My Teaching row.
    expect(find.text('Mathematics'), findsNWidgets(2));
    expect(find.textContaining('Grade 10'), findsWidgets);
    expect(find.textContaining('Term 2'), findsOneWidget);
    expect(find.text('Subject Teacher • Mathematics'), findsOneWidget);
  });

  testWidgets('keeps exactly the three approved action cards', (tester) async {
    await pump(
      tester,
      contextState: SubjectTeacherContextState(
        active: _activeContext,
        available: [_assignment(id: 'a1')],
      ),
    );

    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Enter Marks'), findsOneWidget);
    expect(find.text('Lesson Notes'), findsOneWidget);
    // No Quick Actions heading was reinstated above them.
    expect(find.text('Quick Actions'), findsNothing);
  });

  testWidgets('shows a dash, not a zero, for figures it does not have yet', (
    tester,
  ) async {
    await pump(
      tester,
      contextState: SubjectTeacherContextState(
        active: _activeContext,
        available: [_assignment(id: 'a1')],
      ),
      dashboardState: const SubjectTeacherDashboardState(studentsEnrolled: 28),
    );

    expect(find.text('28'), findsOneWidget);
    // Present/Absent/Lessons have no source yet - a 0 there would read as
    // "nobody came" rather than "not recorded". Three counts plus the two
    // percentages under Present and Absent.
    expect(find.text('–'), findsNWidgets(5));
  });

  testWidgets('counts the teacher\'s own classes in the My Teaching tabs', (
    tester,
  ) async {
    await pump(
      tester,
      contextState: SubjectTeacherContextState(
        active: _activeContext,
        available: [
          _assignment(id: 'a1'),
          _assignment(id: 'a2', classId: 'g10b', className: 'Grade 10B'),
          _assignment(id: 'a3', subjectId: 'ict', subjectName: 'ICT'),
          _assignment(
            id: 'a4',
            roleType: StaffResponsibilityType.classTeacher,
            subjectName: '',
          ),
        ],
      ),
    );

    // Two Mathematics classes, one other subject.
    expect(find.text('Subject Classes (2)'), findsOneWidget);
    expect(find.text('Other Subjects (1)'), findsOneWidget);
  });

  testWidgets('explains an empty panel instead of showing a blank dashboard', (
    tester,
  ) async {
    await pump(
      tester,
      contextState: const SubjectTeacherContextState(
        unavailableReason: ContextUnavailableReason.noAssignments,
      ),
    );

    expect(find.text('No teaching assignments'), findsOneWidget);
    expect(find.text('Take Attendance'), findsNothing);
  });

  testWidgets(
    'says which academic year is missing rather than showing nothing',
    (tester) async {
      await pump(
        tester,
        contextState: const SubjectTeacherContextState(
          unavailableReason: ContextUnavailableReason.noAcademicYear,
        ),
      );

      expect(find.text('No academic year set'), findsOneWidget);
    },
  );

  testWidgets('opens the switcher listing every responsibility held', (
    tester,
  ) async {
    await pump(
      tester,
      contextState: SubjectTeacherContextState(
        active: _activeContext,
        available: [
          _assignment(id: 'a1'),
          _assignment(id: 'a3', subjectId: 'ict', subjectName: 'ICT'),
          _assignment(id: 'a4', roleType: StaffResponsibilityType.classTeacher),
        ],
      ),
    );

    await tester.tap(find.text('Change Class/Subject'));
    await tester.pumpAndSettle();

    expect(find.text('Switch responsibility'), findsOneWidget);
    expect(find.text('My subjects'.toUpperCase()), findsOneWidget);
    expect(find.text('ICT - Grade 10'), findsOneWidget);
    expect(find.text('Other responsibilities'.toUpperCase()), findsOneWidget);
  });

  testWidgets('switching from the sheet asks the context bloc to switch', (
    tester,
  ) async {
    await pump(
      tester,
      contextState: SubjectTeacherContextState(
        active: _activeContext,
        available: [
          _assignment(id: 'a1'),
          _assignment(id: 'a3', subjectId: 'ict', subjectName: 'ICT'),
        ],
      ),
    );

    await tester.tap(find.text('Change Class/Subject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ICT - Grade 10'));
    await tester.pumpAndSettle();

    verify(() => contextBloc.add(const ContextSwitched('a3'))).called(1);
  });
}
