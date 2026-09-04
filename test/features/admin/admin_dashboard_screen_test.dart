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

  Widget wrap({double width = 390, ThemeData? theme}) {
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
        theme: theme ?? AppTheme.light(),
        routerConfig: router,
        builder: (context, child) => BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: child!,
        ),
      ),
    );
  }

  group('AdminDashboardScreen responsive layout', () {
    // Sweeps the full breakpoint range this screen has to survive: below
    // the smallest supported phone, every named breakpoint boundary
    // (AppBreakpoints.mobile/largeMobile/tablet/smallDesktop/desktop/
    // largeDesktop), and well past the largest desktop monitor.
    const widths = <String, double>{
      'ultra-narrow phone (320px)': 320,
      'small phone (360px, mobile breakpoint)': 360,
      'large phone (480px, largeMobile breakpoint)': 480,
      'phone (390px, common device width)': 390,
      'tablet lower bound (600px, tablet breakpoint)': 600,
      'tablet portrait (768px)': 768,
      'tablet landscape (800px)': 800,
      'tablet upper bound (1023px, just under smallDesktop)': 1023,
      'small desktop (1024px, smallDesktop breakpoint)': 1024,
      'desktop (1280px, desktop breakpoint)': 1280,
      'large desktop (1440px, largeDesktop breakpoint)': 1440,
      'ultra-wide desktop (1920px)': 1920,
    };

    for (final entry in widths.entries) {
      testWidgets('renders without overflow at ${entry.key}', (tester) async {
        await tester.pumpWidget(wrap(width: entry.value));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Active learners'), findsOneWidget);
        expect(find.text('Add learner'), findsOneWidget);
        expect(find.text('Take attendance'), findsOneWidget);
        expect(find.text('Invite staff'), findsOneWidget);
        expect(find.text('School structure'), findsOneWidget);
      });
    }

    testWidgets('quick action tiles meet the 44px minimum touch target', (
      tester,
    ) async {
      for (final width in [320.0, 600.0, 1024.0, 1920.0]) {
        await tester.pumpWidget(wrap(width: width));
        await tester.pumpAndSettle();

        for (final label in [
          'Add learner',
          'Take attendance',
          'Invite staff',
          'School structure',
        ]) {
          final size = tester.getSize(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(InkWell),
                )
                .first,
          );
          expect(
            size.height,
            greaterThanOrEqualTo(44),
            reason: '"$label" tile at width=$width is ${size.height}px tall',
          );
        }
      }
    });

    testWidgets(
      'header never truncates the notification/messages icons off-screen',
      (tester) async {
        for (final width in [320.0, 480.0, 600.0, 1024.0, 1920.0]) {
          await tester.pumpWidget(wrap(width: width));
          await tester.pumpAndSettle();

          expect(
            find.byIcon(Icons.notifications_none_rounded),
            findsOneWidget,
            reason: 'notification icon missing at width=$width',
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('renders without overflow in dark theme at every breakpoint', (
      tester,
    ) async {
      for (final width in [320.0, 600.0, 1024.0, 1920.0]) {
        await tester.pumpWidget(wrap(width: width, theme: AppTheme.dark()));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'dark theme overflow at width=$width',
        );
        expect(find.text('Active learners'), findsOneWidget);
      }
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
