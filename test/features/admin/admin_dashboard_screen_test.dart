import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/admin_dashboard_screen.dart';
import 'package:school_pulse/features/admin/domain/repositories/admin_attendance_repository.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notification_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _MockAdminDashboardBloc
    extends MockBloc<AdminDashboardEvent, AdminDashboardState>
    implements AdminDashboardBloc {}

class _MockMessagingBloc extends MockBloc<MessagingEvent, MessagingState>
    implements MessagingBloc {}

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  const schoolAdmin = UserEntity(
    id: 'admin-1',
    name: 'Victoria Smith',
    email: 'admin@schoolpulse.com',
    schoolId: 'school-1',
    schoolName: "St. Mary's Academy",
    roles: [UserRole.schoolAdmin],
  );

  const loadedStats = AdminDashboardStats(
    schoolId: 'school-1',
    activeStaffCount: 86,
    totalStudentsCount: 1248,
    visitorsTodayCount: 0,
    activeVisitorsCount: 0,
    systemHealth: 100,
    studentAttendancePercent: 0.94,
    todayAttendanceCounts: AttendanceCounts(
      present: 1173,
      late: 45,
      absent: 30,
      excused: 12,
    ),
    termFeesCollected: 18400000,
    currentPeriodLabel: 'Term 2 · 2025',
    pendingExpenditureRequestsCount: 4,
  );

  late _MockAuthBloc mockAuthBloc;
  late _MockAdminDashboardBloc mockDashboardBloc;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuthBloc = _MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(schoolAdmin));

    mockDashboardBloc = _MockAdminDashboardBloc();
    when(() => mockDashboardBloc.state)
        .thenReturn(const AdminDashboardLoaded(stats: loadedStats));
    whenListen(
      mockDashboardBloc,
      const Stream<AdminDashboardState>.empty(),
      initialState: const AdminDashboardLoaded(stats: loadedStats),
    );

    fakeFirestore = FakeFirebaseFirestore();

    if (di.sl.isRegistered<AdminDashboardBloc>()) {
      di.sl.unregister<AdminDashboardBloc>();
    }
    di.sl.registerFactory<AdminDashboardBloc>(() => mockDashboardBloc);

    if (di.sl.isRegistered<NotificationRepository>()) {
      di.sl.unregister<NotificationRepository>();
    }
    final mockNotificationRepository = _MockNotificationRepository();
    when(
      () => mockNotificationRepository.watchCounts(
        schoolId: any(named: 'schoolId'),
        recipientUserId: any(named: 'recipientUserId'),
      ),
    ).thenAnswer((_) => const Stream.empty());
    di.sl.registerLazySingleton<NotificationRepository>(
      () => mockNotificationRepository,
    );

    if (di.sl.isRegistered<MessagingBloc>()) {
      di.sl.unregister<MessagingBloc>();
    }
    final mockMessagingBloc = _MockMessagingBloc();
    when(() => mockMessagingBloc.state).thenReturn(const MessagingState());
    whenListen(
      mockMessagingBloc,
      const Stream<MessagingState>.empty(),
      initialState: const MessagingState(),
    );
    di.sl.registerLazySingleton<MessagingBloc>(() => mockMessagingBloc);
  });

  tearDown(() {
    if (di.sl.isRegistered<AdminDashboardBloc>()) {
      di.sl.unregister<AdminDashboardBloc>();
    }
    if (di.sl.isRegistered<NotificationRepository>()) {
      di.sl.unregister<NotificationRepository>();
    }
    if (di.sl.isRegistered<MessagingBloc>()) {
      di.sl.unregister<MessagingBloc>();
    }
  });

  Widget wrap({double width = 390}) {
    final router = GoRouter(
      initialLocation: '/staff/admin',
      routes: [
        GoRoute(
          path: '/staff/admin',
          builder: (context, state) =>
              AdminDashboardScreen(firestoreOverride: fakeFirestore),
        ),
        for (final path in [
          '/staff/admin/admissions/register',
          '/staff/attendance',
          '/staff/admin/users/add-staff',
          '/staff/admin/structure',
          '/staff/admin/approvals',
          '/staff/messages',
          '/staff/notifications',
          '/staff/bursar',
          '/staff/headteacher/report-approvals',
        ])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(body: Text('route:$path')),
          ),
      ],
    );
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
        builder: (context, child) => BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: child!,
        ),
      ),
    );
  }

  group('AdminDashboardScreen responsive layout', () {
    testWidgets('renders without overflow at phone width (390px)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(width: 390));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Active learners'), findsOneWidget);
      expect(find.text('Add learner'), findsOneWidget);
    });

    testWidgets('renders without overflow at tablet width (800px)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(width: 800));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at desktop width (1280px)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(width: 1280));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Active learners'), findsOneWidget);
    });
  });

  group('AdminDashboardScreen quick actions', () {
    testWidgets('Add learner navigates to direct registration route', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add learner'));
      await tester.tap(find.text('Add learner'));
      await tester.pumpAndSettle();

      expect(find.text('route:/staff/admin/admissions/register'), findsOneWidget);
    });

    testWidgets('Take attendance navigates to attendance route', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Take attendance'));
      await tester.tap(find.text('Take attendance'));
      await tester.pumpAndSettle();

      expect(find.text('route:/staff/attendance'), findsOneWidget);
    });

    testWidgets('Invite staff navigates to add-staff route', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Invite staff'));
      await tester.tap(find.text('Invite staff'));
      await tester.pumpAndSettle();

      expect(find.text('route:/staff/admin/users/add-staff'), findsOneWidget);
    });

    testWidgets('School structure navigates to structure route', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('School structure'));
      await tester.tap(find.text('School structure'));
      await tester.pumpAndSettle();

      expect(find.text('route:/staff/admin/structure'), findsOneWidget);
    });
  });

  group('AdminDashboardScreen needs attention', () {
    testWidgets('shows all-clear state when work queues are empty', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text("You're all caught up."), findsOneWidget);
    });

    testWidgets('hides zero-count categories and shows only pending work', (
      tester,
    ) async {
      await fakeFirestore
          .collection('schools')
          .doc('school-1')
          .collection('expenditures')
          .add({'status': 'pending'});

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.textContaining('fees exceptions'), findsOneWidget);
      expect(
        find.textContaining('report cards awaiting approval'),
        findsNothing,
      );
      expect(find.text("You're all caught up."), findsNothing);
    });
  });

  group('AdminDashboardScreen metrics', () {
    testWidgets('renders today\'s attendance percentage from counts', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // 1173 / (1173+45+30+12) = 1260 total, present 1173 -> 93%
      // Appears both in the metrics tile and the attendance summary stat.
      expect(find.text('93%'), findsNWidgets(2));
    });

    testWidgets('shows placeholder when today attendance is unavailable', (
      tester,
    ) async {
      when(() => mockDashboardBloc.state).thenReturn(
        const AdminDashboardLoaded(
          stats: AdminDashboardStats(
            activeStaffCount: 10,
            totalStudentsCount: 100,
            visitorsTodayCount: 0,
            activeVisitorsCount: 0,
            systemHealth: 100,
          ),
        ),
      );
      whenListen(
        mockDashboardBloc,
        const Stream<AdminDashboardState>.empty(),
        initialState: const AdminDashboardLoaded(
          stats: AdminDashboardStats(
            activeStaffCount: 10,
            totalStudentsCount: 100,
            visitorsTodayCount: 0,
            activeVisitorsCount: 0,
            systemHealth: 100,
          ),
        ),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('—'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('AdminDashboardScreen error and loading states', () {
    testWidgets('shows retry affordance on error state', (tester) async {
      when(() => mockDashboardBloc.state)
          .thenReturn(const AdminDashboardError('Network error'));
      whenListen(
        mockDashboardBloc,
        const Stream<AdminDashboardState>.empty(),
        initialState: const AdminDashboardError('Network error'),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsWidgets);
    });

    testWidgets('shows loading indicator while stats load', (tester) async {
      when(() => mockDashboardBloc.state)
          .thenReturn(AdminDashboardLoading());
      whenListen(
        mockDashboardBloc,
        const Stream<AdminDashboardState>.empty(),
        initialState: AdminDashboardLoading(),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('AdminDashboardScreen recent activity', () {
    testWidgets('shows empty state when there are no recent logs', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('No recent activity'), findsOneWidget);
    });
  });
}
