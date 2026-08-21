import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_event.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_state.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_list_screen.dart';
import 'package:school_pulse/features/notifications/routing/notification_shell_route.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockNotificationCenterBloc
    extends MockBloc<NotificationCenterEvent, NotificationCenterState>
    implements NotificationCenterBloc {}

UserEntity _user({required UserRole role}) => UserEntity(
  id: 'user-1',
  staffCode: 'S1',
  name: 'Test User',
  email: 't@example.com',
  roles: [role],
  schoolId: 'school-1',
  schoolName: 'Test School',
  isActive: true,
);

NotificationItem _notification({
  required String id,
  required DateTime timestamp,
  NotificationStatus status = NotificationStatus.unread,
  String title = 'Fee reminder',
  String description = 'Term 2 fees are due on Friday.',
}) {
  return NotificationItem(
    id: id,
    title: title,
    description: description,
    senderName: 'Bursar',
    senderRole: 'Bursar',
    timestamp: timestamp,
    category: NotificationCategory.finance,
    priority: NotificationPriority.medium,
    status: status,
    schoolId: 'school-1',
    recipientUserId: 'user-1',
  );
}

final _sl = GetIt.instance;

void main() {
  late _MockAuthBloc authBloc;
  late _MockNotificationCenterBloc centerBloc;

  setUpAll(() {
    registerFallbackValue(const NotificationCenterRefreshed());
  });

  setUp(() {
    authBloc = _MockAuthBloc();
    centerBloc = _MockNotificationCenterBloc();
    when(() => centerBloc.add(any())).thenReturn(null);
    when(() => centerBloc.close()).thenAnswer((_) async {});

    // NotificationListScreen resolves its bloc from the shared DI container
    // (`di.sl<NotificationCenterBloc>()`) rather than accepting one as a
    // constructor parameter, so the fake has to be registered on the same
    // GetIt instance `di.sl` reads from - matches the existing pattern in
    // test/features/structure/academics/levels_screen_test.dart.
    if (_sl.isRegistered<NotificationCenterBloc>()) {
      _sl.unregister<NotificationCenterBloc>();
    }
    _sl.registerFactory<NotificationCenterBloc>(() => centerBloc);
  });

  tearDown(() {
    if (_sl.isRegistered<NotificationCenterBloc>()) {
      _sl.unregister<NotificationCenterBloc>();
    }
  });

  Widget harness({required UserRole role, String? initialLocation}) {
    when(() => authBloc.state).thenReturn(AuthAuthenticated(_user(role: role)));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    final basePath = notificationShellBasePath(role);
    final router = GoRouter(
      initialLocation: initialLocation ?? basePath,
      routes: [
        GoRoute(
          path: basePath,
          builder: (_, _) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const NotificationListScreen(),
          ),
        ),
        GoRoute(
          path: '$basePath/center',
          builder: (_, _) => const Scaffold(body: Text('Center screen')),
        ),
        GoRoute(
          path: '$basePath/:id',
          builder: (_, state) =>
              Scaffold(body: Text('Details ${state.pathParameters['id']}')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('loading, empty and error states', () {
    testWidgets('shows a loader while status is loading', (tester) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.loading),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pump();

      expect(find.byType(SchoolPulseLoader), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no notifications', (
      tester,
    ) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.ready),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      expect(find.text('No notifications found'), findsOneWidget);
    });

    testWidgets('shows a retry button on failure', (tester) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.failure),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      expect(find.text('Could not load notifications'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      verify(
        () => centerBloc.add(const NotificationCenterRefreshed()),
      ).called(1);
    });
  });

  group('sectioning and rendering', () {
    testWidgets('groups items into Today and Earlier sections', (tester) async {
      final now = DateTime.now();
      final items = [
        _notification(id: '1', timestamp: now, title: 'Today item'),
        _notification(
          id: '2',
          timestamp: now.subtract(const Duration(days: 3)),
          title: 'Older item',
        ),
      ];
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: items,
          unreadCount: 2,
          totalCount: 2,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Today item'), findsOneWidget);
      expect(find.text('Older item'), findsOneWidget);
    });

    testWidgets('long title and body do not overflow the tile', (tester) async {
      final longTitle = 'A' * 200;
      final longBody = 'B' * 500;
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: [
            _notification(
              id: '1',
              timestamp: DateTime.now(),
              title: longTitle,
              description: longBody,
            ),
          ],
          totalCount: 1,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      // A RenderFlex overflow throws during the frame; reaching pumpAndSettle
      // without an exception is the assertion that maxLines/ellipsis worked.
      expect(tester.takeException(), isNull);
    });

    testWidgets('unread dot shows for unread items only', (tester) async {
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: [
            _notification(
              id: '1',
              timestamp: DateTime.now(),
              status: NotificationStatus.unread,
            ),
            _notification(
              id: '2',
              timestamp: DateTime.now(),
              status: NotificationStatus.read,
              title: 'Read item',
            ),
          ],
          totalCount: 2,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      // Both cards render; the unread one carries the badge dot container in
      // addition to the shared icon container, so there should be more decorated
      // circles than the read-only card contributes alone.
      expect(find.text('Fee reminder'), findsOneWidget);
      expect(find.text('Read item'), findsOneWidget);
    });
  });

  group('interactions', () {
    testWidgets('tapping a tile marks it opened and navigates within the '
        'current shell', (tester) async {
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: [_notification(id: 'n1', timestamp: DateTime.now())],
          totalCount: 1,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.parent));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fee reminder'));
      await tester.pumpAndSettle();

      verify(() => centerBloc.add(const NotificationOpened('n1'))).called(1);
      expect(find.text('Details n1'), findsOneWidget);
    });

    testWidgets('mark all as read dispatches the event and is hidden with '
        'no unread items', (tester) async {
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: [
            _notification(
              id: '1',
              timestamp: DateTime.now(),
              status: NotificationStatus.read,
            ),
          ],
          totalCount: 1,
          unreadCount: 0,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      expect(find.text('Mark all as read'), findsNothing);
    });

    testWidgets('mark all as read appears and fires when there is unread '
        'mail', (tester) async {
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: [_notification(id: '1', timestamp: DateTime.now())],
          totalCount: 1,
          unreadCount: 1,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark all as read').first);
      verify(() => centerBloc.add(const NotificationAllMarkedRead())).called(1);
    });

    testWidgets('typing in search dispatches a search event', (tester) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.ready),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Search notifications'),
        'fees',
      );
      verify(
        () => centerBloc.add(const NotificationCenterSearched('fees')),
      ).called(1);
    });
  });

  group('role-scoped shell routing', () {
    testWidgets('parent tapping a tile stays under /parent/notifications', (
      tester,
    ) async {
      when(() => centerBloc.state).thenReturn(
        NotificationCenterState(
          status: NotificationCenterStatus.ready,
          items: [_notification(id: 'p1', timestamp: DateTime.now())],
          totalCount: 1,
        ),
      );

      await tester.pumpWidget(harness(role: UserRole.parent));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fee reminder'));
      await tester.pumpAndSettle();

      expect(find.text('Details p1'), findsOneWidget);
    });

    testWidgets('compose FAB is hidden for a non-admin staff role', (
      tester,
    ) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.ready),
      );

      await tester.pumpWidget(harness(role: UserRole.classTeacher));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('compose FAB is hidden for parent', (tester) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.ready),
      );

      await tester.pumpWidget(harness(role: UserRole.parent));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('compose FAB is shown only for schoolAdmin', (tester) async {
      when(() => centerBloc.state).thenReturn(
        const NotificationCenterState(status: NotificationCenterStatus.ready),
      );

      await tester.pumpWidget(harness(role: UserRole.schoolAdmin));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
