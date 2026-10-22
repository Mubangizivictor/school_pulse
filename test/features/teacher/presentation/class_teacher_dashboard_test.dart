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
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/teacher/dashboard_screen.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_dashboard_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockContextBloc
    extends MockBloc<ClassTeacherContextEvent, ClassTeacherContextState>
    implements ClassTeacherContextBloc {}

class _MockDashboardBloc
    extends MockBloc<ClassTeacherDashboardEvent, ClassTeacherDashboardState>
    implements ClassTeacherDashboardBloc {}

/// The shared staff dashboard header watches BrandingBloc for the school
/// badge; without it the header cannot lay out and the whole dashboard
/// overflows.
class _MockBrandingBloc extends MockBloc<BrandingEvent, BrandingState>
    implements BrandingBloc {}

const _user = UserEntity(
  id: 'user1',
  name: 'Grace Nakato',
  email: 'grace@school.test',
  schoolId: 'school1',
  schoolName: 'Kabale Campus',
  roles: [UserRole.classTeacher],
);

StaffRoleAssignment _classAssignment() {
  return StaffRoleAssignment(
    id: 'ct1',
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: StaffResponsibilityType.classTeacher,
    academicYearId: '2026',
    classId: 'p5',
    className: 'P5',
    streamId: 'east',
    streamName: 'East',
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );
}

final _activeContext = ActiveResponsibilityContext.fromAssignment(
  _classAssignment(),
  termId: 't2',
  termName: 'Term 2',
  academicYearName: '2025/2026',
);

Lesson _lesson({
  String id = 'l1',
  String subjectName = 'Mathematics',
  LessonStatus status = LessonStatus.ongoing,
  int hour = 8,
}) {
  return Lesson(
    id: id,
    schoolId: 'school1',
    academicYearId: '2026',
    subjectId: 'maths',
    subjectName: subjectName,
    classId: 'p5',
    className: 'P5',
    streamId: 'east',
    streamName: 'East',
    teacherStaffId: 'staff2',
    room: 'Room 4',
    scheduledStart: DateTime(2026, 6, 1, hour, 30),
    scheduledEnd: DateTime(2026, 6, 1, hour + 1, 15),
    status: status,
  );
}

void main() {
  late _MockAuthBloc authBloc;
  late _MockContextBloc contextBloc;
  late _MockDashboardBloc dashboardBloc;
  late _MockBrandingBloc brandingBloc;

  setUp(() {
    authBloc = _MockAuthBloc();
    contextBloc = _MockContextBloc();
    dashboardBloc = _MockDashboardBloc();
    brandingBloc = _MockBrandingBloc();
    when(() => brandingBloc.state).thenReturn(const BrandingLoaded(null));
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  });

  Future<void> pump(
    WidgetTester tester, {
    required ClassTeacherContextState contextState,
    ClassTeacherDashboardState dashboardState =
        const ClassTeacherDashboardState(),
  }) async {
    when(() => contextBloc.state).thenReturn(contextState);
    when(() => dashboardBloc.state).thenReturn(dashboardState);

    // The dashboard is a long scroll built lazily; a default 600x800 surface
    // stops before Recent Activities, so those rows would never be built for
    // the test to find.
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ClassTeacherContextBloc>.value(value: contextBloc),
            BlocProvider<ClassTeacherDashboardBloc>.value(value: dashboardBloc),
            BlocProvider<BrandingBloc>.value(value: brandingBloc),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => const TeacherDashboardScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('class identity', () {
    testWidgets('names the assigned class rather than a placeholder', (
      tester,
    ) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(
          active: _activeContext,
          available: [_classAssignment()],
        ),
        dashboardState: const ClassTeacherDashboardState(
          summary: ClassDashboardSummary(totalStudents: 32),
        ),
      );

      // 43ceddc5 header: a first-name greeting, then the responsibility
      // switcher naming the class and stream, then term + date.
      expect(find.textContaining(', Grace'), findsOneWidget);
      expect(find.textContaining('Nakato'), findsNothing);
      expect(find.text('Class Teacher • P5 • East'), findsOneWidget);
      expect(find.textContaining('Term 2 • '), findsOneWidget);
      // The hardcoded stand-in the panel used to ship with must be gone.
      expect(find.textContaining('Grade 10A'), findsNothing);
      expect(find.textContaining('North Campus'), findsNothing);
    });
  });

  group('figures', () {
    testWidgets('shows the roster count from the class summary', (
      tester,
    ) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: const ClassTeacherDashboardState(
          summary: ClassDashboardSummary(
            totalStudents: 32,
            attendance: ClassAttendanceToday(
              hasSession: true,
              isSubmitted: true,
              presentCount: 30,
              absentCount: 2,
            ),
          ),
        ),
      );

      // Total / Present / Absent / Late counts; no percentage tile.
      expect(find.text('32'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget);
      expect(find.text('View register'), findsOneWidget);
    });

    testWidgets('says the register is not taken rather than showing 0%', (
      tester,
    ) async {
      // A class with nobody marked and a class with nobody present are
      // different facts; the tile must not present the first as the second.
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: const ClassTeacherDashboardState(
          summary: ClassDashboardSummary(totalStudents: 32),
        ),
      );

      expect(find.text('Not taken'), findsOneWidget);
      // Present/Absent/Late show a dash, not 0.
      expect(find.text('—'), findsNWidgets(3));
      expect(find.text('0'), findsNothing);
      expect(find.text('0.0%'), findsNothing);
    });
  });

  group("today's schedule", () {
    testWidgets('lists the class timetable, not a hardcoded pair of lessons', (
      tester,
    ) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: ClassTeacherDashboardState(
          summary: ClassDashboardSummary(
            totalStudents: 32,
            todaysSchedule: [
              _lesson(subjectName: 'Mathematics', hour: 8),
              _lesson(
                id: 'l2',
                subjectName: 'Kiswahili',
                status: LessonStatus.scheduled,
                hour: 10,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Kiswahili'), findsOneWidget);
      expect(find.text('08:30 - 09:15'), findsOneWidget);
      // StatusBadge uppercases its label.
      expect(find.text('ONGOING'), findsOneWidget);
      expect(find.text('SCHEDULED'), findsOneWidget);
      // The stand-ins the approved layout shipped with.
      expect(find.text('English Literature'), findsNothing);
    });

    testWidgets('hides an empty timetable section completely', (tester) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: const ClassTeacherDashboardState(
          summary: ClassDashboardSummary(totalStudents: 32),
        ),
      );

      expect(find.text("Today's Schedule"), findsNothing);
      expect(find.text('View All'), findsNothing);
      expect(
        find.text('No lessons scheduled for your class today.'),
        findsNothing,
      );
    });
  });

  group('recent activity', () {
    testWidgets('renders audit rows for this class', (tester) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: ClassTeacherDashboardState(
          summary: ClassDashboardSummary(
            totalStudents: 32,
            recentActivities: [
              ClassActivityEntry(
                id: 'a1',
                action: 'attendance.submitted',
                title: 'Attendance Logged',
                description: 'Register submitted for P5 East.',
                occurredAt: DateTime.now(),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Attendance Logged'), findsOneWidget);
      expect(find.text('Register submitted for P5 East.'), findsOneWidget);
    });

    testWidgets('hides an empty activity section completely', (tester) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: const ClassTeacherDashboardState(
          summary: ClassDashboardSummary(totalStudents: 32),
        ),
      );

      expect(find.text('Recent Activities'), findsNothing);
      expect(find.text('View All'), findsNothing);
      expect(
        find.text('Nothing has happened in your class yet.'),
        findsNothing,
      );
    });
  });

  group('quick actions', () {
    testWidgets('shows the 43ceddc5 action set', (tester) async {
      await pump(
        tester,
        contextState: ClassTeacherContextState(active: _activeContext),
        dashboardState: const ClassTeacherDashboardState(
          summary: ClassDashboardSummary(totalStudents: 32),
        ),
      );

      // 'Take attendance' is both a quick action and the attendance card's
      // CTA while the register is not taken.
      expect(find.text('Take attendance'), findsNWidgets(2));
      expect(find.text('Add class note'), findsOneWidget);
      expect(find.text('Message parents'), findsOneWidget);
      expect(find.text('Roll Call'), findsNothing);
      expect(find.text('Submit Marks'), findsNothing);
    });
  });

  group('states with no class', () {
    testWidgets('explains an account with no class assignment', (tester) async {
      await pump(
        tester,
        contextState: const ClassTeacherContextState(
          unavailableReason: ClassContextUnavailableReason.noClassAssignment,
        ),
      );

      expect(find.text('No class assigned'), findsOneWidget);
      expect(find.textContaining('administrator'), findsOneWidget);
    });

    testWidgets('distinguishes a suspended assignment from a missing one', (
      tester,
    ) async {
      await pump(
        tester,
        contextState: const ClassTeacherContextState(
          unavailableReason: ClassContextUnavailableReason.assignmentSuspended,
        ),
      );

      expect(find.text('Class responsibility suspended'), findsOneWidget);
    });

    testWidgets(
      'says which academic year is missing rather than showing nothing',
      (tester) async {
        await pump(
          tester,
          contextState: const ClassTeacherContextState(
            unavailableReason: ClassContextUnavailableReason.noAcademicYear,
          ),
        );

        expect(find.text('No academic year set'), findsOneWidget);
      },
    );

    testWidgets('offers a retry when the class could not be loaded', (
      tester,
    ) async {
      await pump(
        tester,
        contextState: const ClassTeacherContextState(
          unavailableReason: ClassContextUnavailableReason.loadFailed,
          errorMessage: 'Could not load your class. Pull down to retry.',
        ),
      );

      expect(find.text('Could not load your class'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
