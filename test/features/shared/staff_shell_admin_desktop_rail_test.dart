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
          // Routes AdminShell owns end-to-end (home/students/staff/parents/
          // attendance/fees/appointments/approvals) - StaffShell must render
          // these bare, since AdminShell supplies its own full responsive
          // shell (sidebar on desktop/tablet, bottom nav on mobile).
          GoRoute(
            path: '/staff/admin',
            builder: (context, state) =>
                const Scaffold(body: Text('AdminShell home body')),
          ),
          GoRoute(
            path: '/staff/admin/students',
            builder: (context, state) =>
                const Scaffold(body: Text('AdminShell students body')),
          ),
          GoRoute(
            path: '/staff/admin/users',
            builder: (context, state) =>
                const Scaffold(body: Text('AdminShell staff body')),
          ),
          GoRoute(
            path: '/staff/bursar',
            builder: (context, state) =>
                const Scaffold(body: Text('Finance body')),
          ),
          // Sibling admin routes that are NOT part of AdminShell - these
          // are standalone screens and must keep StaffShell's own chrome.
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
  // Regression coverage for a real bug: AdminShell (home/students/staff/
  // parents/attendance/fees/appointments/approvals) owns a full responsive
  // shell of its own, identical in spirit to BursarShell. StaffShell must
  // never wrap those routes in its own rail/bottom-nav too, or every admin
  // screen renders two sidebars on desktop and two bottom navs on mobile.
  testWidgets(
    'StaffShell renders AdminShell-owned routes bare, with no rail of its own, on desktop',
    (tester) async {
      await _setViewSize(tester, 1440, 900);
      await tester.pumpWidget(
        _wrap(initialLocation: '/staff/admin/users'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('AdminShell staff body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'StaffShell renders AdminShell-owned routes bare, with no bottom nav of its own, on mobile',
    (tester) async {
      await _setViewSize(tester, 390, 900);
      await tester.pumpWidget(
        _wrap(initialLocation: '/staff/admin/users'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('AdminShell staff body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'StaffShell still renders its own chrome for sibling admin routes AdminShell does not own',
    (tester) async {
      await _setViewSize(tester, 1440, 900);
      await tester.pumpWidget(
        _wrap(initialLocation: '/staff/admin/school-setup'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Settings body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Bursar routes are also rendered bare by StaffShell', (
    tester,
  ) async {
    await _setViewSize(tester, 1440, 900);
    await tester.pumpWidget(_wrap(initialLocation: '/staff/bursar'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Finance body'), findsOneWidget);
  });

  // Regression test: NavigationRail lays out every destination at its
  // natural height with no built-in scrolling, so a short window (a small
  // laptop viewport, or heavy browser zoom) previously overflowed past the
  // available rail height instead of scrolling.
  testWidgets(
    'StaffShell rail scrolls instead of overflowing on a short window',
    (tester) async {
      await _setViewSize(tester, 1440, 420);
      await tester.pumpWidget(
        _wrap(initialLocation: '/staff/admin/school-setup'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
