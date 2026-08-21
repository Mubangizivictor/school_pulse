import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/profile/presentation/screens/help_center_screen.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeClassTeacherContextBloc extends Cubit<ClassTeacherContextState>
    implements ClassTeacherContextBloc {
  _FakeClassTeacherContextBloc(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUrlLauncher extends UrlLauncherPlatform {
  String? launchedUrl;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ActiveResponsibilityContext _classContext() => ActiveResponsibilityContext(
  schoolId: 'school-id',
  academicYearId: 'year-id',
  staffId: 'staff-id',
  userId: 'user-id',
  roleAssignmentId: 'assignment-id',
  roleType: StaffResponsibilityType.classTeacher,
  classId: 'class-id',
  assignmentStartDate: DateTime(2026, 1, 1),
);

Widget _harness(Brightness brightness) {
  final router = GoRouter(
    initialLocation: '/staff/more/help-center',
    routes: [
      GoRoute(
        path: '/staff/more/help-center',
        builder: (_, _) => const HelpCenterScreen(),
      ),
      for (final path in const [
        '/staff/more',
        '/staff/dashboard',
        '/staff/roll-call',
        '/staff/reports',
        '/staff/homework',
        '/staff/classes/:classId/performance',
      ])
        GoRoute(
          path: path,
          builder: (context, state) => Scaffold(body: Text(state.uri.path)),
        ),
    ],
  );

  return BlocProvider<ClassTeacherContextBloc>(
    create: (_) => _FakeClassTeacherContextBloc(
      ClassTeacherContextState(active: _classContext()),
    ),
    child: MaterialApp.router(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('renders without overflow in light and dark mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(_harness(brightness));
      await tester.pumpAndSettle();

      expect(find.text('Help Center'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Contact Support'), 300);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('opens every Class Teacher topic and returns to More', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final expectedRoutes = <String, String>{
      'Getting Started': '/staff/dashboard',
      'Using Class Performance': '/staff/classes/class-id/performance',
      'Taking Attendance': '/staff/roll-call',
      'Entering Marks': '/staff/reports',
      'Creating Homework': '/staff/homework',
      'Generating Reports': '/staff/reports',
    };

    for (final entry in expectedRoutes.entries) {
      await tester.pumpWidget(_harness(Brightness.light));
      await tester.pumpAndSettle();
      final topic = find.text(entry.key);
      await tester.tap(topic);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }

    await tester.pumpWidget(_harness(Brightness.dark));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('/staff/more'), findsOneWidget);
  });

  testWidgets('opens an email addressed to the configured support contact', (
    tester,
  ) async {
    final originalLauncher = UrlLauncherPlatform.instance;
    final launcher = _TestUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = originalLauncher);

    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_harness(Brightness.light));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Contact Support'), 300);
    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();

    final email = Uri.parse(launcher.launchedUrl!);
    expect(email.scheme, 'mailto');
    expect(email.path, 'mubangizivic@gmail.com');
    expect(email.queryParameters['subject'], 'School Pulse Support');
  });
}
