import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/app_role_session_service.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/shared/shell_screen.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockBrandingBloc extends MockBloc<BrandingEvent, BrandingState>
    implements BrandingBloc {}

class _MockSubjectTeacherContextBloc
    extends
        MockBloc<
          SubjectTeacherContextEvent,
          SubjectTeacherContextState
        >
    implements SubjectTeacherContextBloc {}

class _FakeAppRoleSessionService extends Fake
    implements AppRoleSessionService {
  _FakeAppRoleSessionService(this._current);
  final UserRole? _current;

  @override
  UserRole? get current => _current;

  @override
  Stream<UserRole?> get changes => const Stream.empty();
}

const admin = UserEntity(
  id: 'admin-1',
  name: 'School Admin',
  email: 'admin@schoolpulse.com',
  schoolId: 'school-1',
  roles: [UserRole.schoolAdmin],
);

Widget _wrap({required String initialLocation}) {
  final authBloc = _MockAuthBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(admin));

  final brandingBloc = _MockBrandingBloc();
  when(() => brandingBloc.state).thenReturn(BrandingInitial());

  final subjectTeacherBloc = _MockSubjectTeacherContextBloc();
  when(
    () => subjectTeacherBloc.state,
  ).thenReturn(const SubjectTeacherContextState.initial());

  final roleSessionCubit = AppRoleSessionCubit(
    service: _FakeAppRoleSessionService(UserRole.schoolAdmin),
  );

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: '/staff/dashboard',
            builder: (context, state) =>
                const Scaffold(body: Text('Home body')),
          ),
          GoRoute(
            path: '/staff/admin/students',
            builder: (context, state) =>
                const Scaffold(body: Text('Students body')),
          ),
          GoRoute(
            path: '/staff/admin/users',
            builder: (context, state) =>
                const Scaffold(body: Text('Staff body')),
          ),
          GoRoute(
            path: '/staff/admin/parents',
            builder: (context, state) =>
                const Scaffold(body: Text('Parents body')),
          ),
          GoRoute(
            path: '/staff/admin/staff-attendance',
            builder: (context, state) =>
                const Scaffold(body: Text('Attendance body')),
          ),
          GoRoute(
            path: '/staff/admin/communication-center',
            builder: (context, state) =>
                const Scaffold(body: Text('Communications body')),
          ),
          GoRoute(
            path: '/staff/bursar',
            builder: (context, state) =>
                const Scaffold(body: Text('Finance body')),
          ),
          GoRoute(
            path: '/staff/admin/reports',
            builder: (context, state) =>
                const Scaffold(body: Text('Reports body')),
          ),
          GoRoute(
            path: '/staff/admin/school-setup',
            builder: (context, state) =>
                const Scaffold(body: Text('Settings body')),
          ),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    theme: AppTheme.light(),
    routerConfig: router,
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<BrandingBloc>.value(value: brandingBloc),
        BlocProvider<SubjectTeacherContextBloc>.value(
          value: subjectTeacherBloc,
        ),
        BlocProvider<AppRoleSessionCubit>.value(value: roleSessionCubit),
      ],
      child: child!,
    ),
  );
}

Future<void> _setViewSize(WidgetTester tester, double width, double height) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets(
    'desktop admin rail shows all 9 sections, Staff selected on /staff/admin/users',
    (tester) async {
      await _setViewSize(tester, 1440, 900);
      await tester.pumpWidget(
        _wrap(initialLocation: '/staff/admin/users'),
      );
      await tester.pumpAndSettle();

      for (final label in const [
        'Home',
        'Students',
        'Staff',
        'Parents',
        'Attendance',
        'Communications',
        'Finance',
        'Reports',
        'Settings',
      ]) {
        expect(
          find.text(label),
          findsOneWidget,
          reason: 'Expected a "$label" rail destination on desktop',
        );
      }

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Staff body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tapping Finance in the desktop rail navigates to /staff/bursar', (
    tester,
  ) async {
    await _setViewSize(tester, 1440, 900);
    await tester.pumpWidget(
      _wrap(initialLocation: '/staff/admin/users'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finance'));
    await tester.pumpAndSettle();

    expect(find.text('Finance body'), findsOneWidget);
  });

  testWidgets('mobile keeps the original 5-item bottom nav for admin', (
    tester,
  ) async {
    await _setViewSize(tester, 390, 900);
    await tester.pumpWidget(
      _wrap(initialLocation: '/staff/admin/users'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    for (final label in const ['Home', 'Students', 'Staff', 'Parents', 'More']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Attendance'), findsNothing);
    expect(find.text('Finance'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
