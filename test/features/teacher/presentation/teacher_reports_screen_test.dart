import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/screens/more/teacher_reports_screen.dart';

class _MockContextBloc
    extends MockBloc<ClassTeacherContextEvent, ClassTeacherContextState>
    implements ClassTeacherContextBloc {}

class _MockPerformanceBloc
    extends MockBloc<ClassPerformanceEvent, ClassPerformanceState>
    implements ClassPerformanceBloc {}

class _MockReportsBloc extends MockBloc<ClassReportsEvent, ClassReportsState>
    implements ClassReportsBloc {}

StaffRoleAssignment _classAssignment() {
  return StaffRoleAssignment(
    id: 'ct1',
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: StaffResponsibilityType.classTeacher,
    academicYearId: '2026',
    classId: 'p5',
    className: 'Primary 5',
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

void main() {
  late _MockContextBloc contextBloc;
  late _MockPerformanceBloc performanceBloc;
  late _MockReportsBloc reportsBloc;

  setUp(() {
    contextBloc = _MockContextBloc();
    performanceBloc = _MockPerformanceBloc();
    reportsBloc = _MockReportsBloc();
    when(() => contextBloc.state).thenReturn(
      ClassTeacherContextState(
        active: _activeContext,
        available: [_classAssignment()],
      ),
    );
    when(
      () => performanceBloc.state,
    ).thenReturn(const ClassPerformanceState());

    // The screen resolves its own blocs from GetIt in initState rather than
    // via BlocProvider.of, matching how the router wires it in production.
    if (di.sl.isRegistered<ClassPerformanceBloc>()) {
      di.sl.unregister<ClassPerformanceBloc>();
    }
    if (di.sl.isRegistered<ClassReportsBloc>()) {
      di.sl.unregister<ClassReportsBloc>();
    }
    di.sl.registerFactory<ClassPerformanceBloc>(() => performanceBloc);
    di.sl.registerFactory<ClassReportsBloc>(() => reportsBloc);
  });

  tearDown(() {
    di.sl.unregister<ClassPerformanceBloc>();
    di.sl.unregister<ClassReportsBloc>();
  });

  Future<void> pump(
    WidgetTester tester, {
    required ClassReportsState reportsState,
    Brightness brightness = Brightness.light,
  }) async {
    when(() => reportsBloc.state).thenReturn(reportsState);

    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<ClassTeacherContextBloc>.value(
        value: contextBloc,
        child: MaterialApp.router(
          theme: brightness == Brightness.light
              ? AppTheme.light()
              : AppTheme.dark(),
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const TeacherReportsScreen(),
              ),
              GoRoute(
                path: '/staff/attendance/history',
                builder: (_, _) => const Scaffold(body: Text('Attendance')),
              ),
              GoRoute(
                path: '/staff/classes/:classId/performance',
                builder: (_, _) => const Scaffold(body: Text('Performance')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('rendering', () {
    testWidgets('renders quick report tiles in light mode', (tester) async {
      await pump(tester, reportsState: const ClassReportsState());

      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Class Attendance'), findsOneWidget);
      expect(find.text('Academic Performance'), findsOneWidget);
      expect(find.text('Assessment Reports'), findsOneWidget);
      expect(find.text('Student Progress'), findsOneWidget);
    });

    testWidgets('renders without error in dark mode', (tester) async {
      await pump(
        tester,
        reportsState: const ClassReportsState(),
        brightness: Brightness.dark,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('shows real class report entries, not mock data', (
      tester,
    ) async {
      await pump(
        tester,
        reportsState: ClassReportsState(
          context: _activeContext,
          entries: [
            ClassReportEntry(
              id: 'r1',
              schoolId: 'school1',
              classId: 'p5',
              academicYearId: '2026',
              termId: 't2',
              studentId: 's1',
              studentName: 'Amara Okoye',
              status: ReportEntryStatus.submittedForReview,
              submittedAt: DateTime(2026, 5, 16),
            ),
          ],
        ),
      );

      expect(find.text('Amara Okoye'), findsOneWidget);
      expect(find.text('Submitted for review'), findsOneWidget);
    });

    testWidgets('shows empty state when there are no report entries', (
      tester,
    ) async {
      await pump(tester, reportsState: const ClassReportsState());

      expect(find.textContaining('No reports yet'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('tapping Class Attendance navigates to attendance history', (
      tester,
    ) async {
      await pump(tester, reportsState: const ClassReportsState());

      await tester.tap(find.text('Class Attendance'));
      await tester.pumpAndSettle();

      expect(find.text('Attendance'), findsOneWidget);
    });

    testWidgets(
      'tapping Academic Performance navigates to the class performance screen',
      (tester) async {
        await pump(tester, reportsState: const ClassReportsState());

        await tester.tap(find.text('Academic Performance'));
        await tester.pumpAndSettle();

        expect(find.text('Performance'), findsOneWidget);
      },
    );
  });
}
