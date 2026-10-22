import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_list_page.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_invitation.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _MockGetStaffMembers extends Mock implements GetStaffMembers {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  const schoolAdmin = UserEntity(
    id: 'admin-1',
    name: 'School Admin',
    email: 'admin@schoolpulse.com',
    schoolId: 'school-1',
    roles: [UserRole.schoolAdmin],
  );

  final staffList = [
    const UserEntity(
      id: 'u1',
      name: 'James Brown',
      email: 'james.brown@schoolpulse.com',
      schoolId: 'school-1',
      roles: [UserRole.subjectTeacher],
      isActive: true,
      employmentType: 'Full-time',
    ),
    const UserEntity(
      id: 'u2',
      name: 'Lisa Martinez',
      email: 'lisa.martinez@schoolpulse.com',
      schoolId: 'school-1',
      roles: [UserRole.guidanceDiscipline],
      isActive: false,
      employmentType: 'Part-time',
    ),
    const UserEntity(
      id: 'u3',
      name: 'Grace Miller',
      email: 'grace.miller@schoolpulse.com',
      schoolId: 'school-1',
      roles: [UserRole.schoolAdmin],
      isActive: true,
      invitationStatus: 'sent',
      invitationId: 'invite-u3',
      employmentType: 'Full-time',
    ),
  ];

  late _MockGetStaffMembers mockGetStaffMembers;
  late _MockAuthBloc mockAuthBloc;
  late _MockAuthRepository mockAuthRepository;

  setUp(() {
    mockGetStaffMembers = _MockGetStaffMembers();
    mockAuthBloc = _MockAuthBloc();
    mockAuthRepository = _MockAuthRepository();
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(schoolAdmin));
    when(
      () => mockAuthRepository.createStaffInvitation(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockAuthRepository.cancelStaffInvitation(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockAuthRepository.toggleStaffActiveStatus(
        any(),
        any(),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async => const Right(null));

    if (di.sl.isRegistered<GetStaffMembers>()) {
      di.sl.unregister<GetStaffMembers>();
    }
    di.sl.registerFactory<GetStaffMembers>(() => mockGetStaffMembers);

    if (di.sl.isRegistered<StructureBloc>()) {
      di.sl.unregister<StructureBloc>();
    }
    di.sl.registerFactory<StructureBloc>(() {
      final bloc = _MockStructureBloc();
      when(() => bloc.state).thenReturn(const StructureState());
      return bloc;
    });

    if (di.sl.isRegistered<CreateStaffInvitation>()) {
      di.sl.unregister<CreateStaffInvitation>();
    }
    di.sl.registerFactory<CreateStaffInvitation>(
      () => CreateStaffInvitation(mockAuthRepository),
    );

    if (di.sl.isRegistered<CancelStaffInvitation>()) {
      di.sl.unregister<CancelStaffInvitation>();
    }
    di.sl.registerFactory<CancelStaffInvitation>(
      () => CancelStaffInvitation(mockAuthRepository),
    );

    if (di.sl.isRegistered<ToggleStaffStatus>()) {
      di.sl.unregister<ToggleStaffStatus>();
    }
    di.sl.registerFactory<ToggleStaffStatus>(
      () => ToggleStaffStatus(mockAuthRepository),
    );
  });

  tearDown(() {
    if (di.sl.isRegistered<GetStaffMembers>()) {
      di.sl.unregister<GetStaffMembers>();
    }
    if (di.sl.isRegistered<StructureBloc>()) {
      di.sl.unregister<StructureBloc>();
    }
    if (di.sl.isRegistered<CreateStaffInvitation>()) {
      di.sl.unregister<CreateStaffInvitation>();
    }
    if (di.sl.isRegistered<CancelStaffInvitation>()) {
      di.sl.unregister<CancelStaffInvitation>();
    }
    if (di.sl.isRegistered<ToggleStaffStatus>()) {
      di.sl.unregister<ToggleStaffStatus>();
    }
  });

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/staff/admin/users',
      routes: [
        GoRoute(
          path: '/staff/admin/users',
          builder: (context, state) => const StaffListPage(),
        ),
        GoRoute(
          path: '/staff/admin/users/add-staff',
          builder: (context, state) =>
              const Scaffold(body: Text('Add Staff Wizard')),
        ),
        GoRoute(
          path: '/staff/admin/users/:id',
          builder: (context, state) =>
              Scaffold(body: Text('Detail ${state.pathParameters['id']}')),
        ),
      ],
    );
    return MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) =>
          BlocProvider<AuthBloc>.value(value: mockAuthBloc, child: child),
    );
  }

  testWidgets('shows loading then staff rows once loaded', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('James Brown'), findsOneWidget);
    expect(find.text('Lisa Martinez'), findsOneWidget);
    expect(find.text('3 staff members'), findsOneWidget);
  });

  testWidgets('search filters the staff list', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'James');
    await tester.pumpAndSettle();

    expect(find.text('James Brown'), findsOneWidget);
    expect(find.text('Lisa Martinez'), findsNothing);
  });

  testWidgets('status chip filters to active only', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(find.text('James Brown'), findsOneWidget);
    expect(find.text('Lisa Martinez'), findsNothing);
  });

  testWidgets('empty state shows Add Staff cta for admin role', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => const Right(<UserEntity>[]));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No staff yet'), findsOneWidget);
    expect(find.text('Add Staff'), findsOneWidget);
  });

  testWidgets('error state offers retry', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('offline')));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Couldn\'t load staff'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping a staff row navigates to staff detail', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('James Brown'));
    await tester.pumpAndSettle();

    expect(find.text('Detail u1'), findsOneWidget);
  });

  testWidgets('Add staff button hidden for a non-admin role', (tester) async {
    const teacherUser = UserEntity(
      id: 'teacher-1',
      name: 'Deputy Teacher',
      email: 'deputy@schoolpulse.com',
      schoolId: 'school-1',
      roles: [UserRole.subjectTeacher],
    );
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthAuthenticated(teacherUser));
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Add staff'), findsNothing);
  });

  testWidgets(
    'narrow phone width (320) shows no overflow and keeps Add staff reachable',
    (tester) async {
      when(
        () => mockGetStaffMembers(any()),
      ).thenAnswer((_) async => Right(staffList));

      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Add staff'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tablet width (768) still renders the compact card list, not the table',
    (tester) async {
      when(
        () => mockGetStaffMembers(any()),
      ).thenAnswer((_) async => Right(staffList));

      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('James Brown'), findsOneWidget);
      expect(find.byType(Table), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('desktop width (1440) renders the dense table with pagination', (
    tester,
  ) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byType(Table), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Add staff'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin-console role sees unmasked staff email', (tester) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('james.brown@schoolpulse.com'), findsOneWidget);
  });

  testWidgets('non-admin-console role sees masked staff email, never raw', (
    tester,
  ) async {
    const teacherUser = UserEntity(
      id: 'teacher-1',
      name: 'Deputy Teacher',
      email: 'deputy@schoolpulse.com',
      schoolId: 'school-1',
      roles: [UserRole.subjectTeacher],
    );
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthAuthenticated(teacherUser));
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('james.brown@schoolpulse.com'), findsNothing);
    expect(find.textContaining('*'), findsWidgets);
  });

  testWidgets('Clear filters only appears once a filter is active', (
    tester,
  ) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Clear filters'), findsNothing);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('Clear filters'), findsNothing);
    expect(find.text('Lisa Martinez'), findsOneWidget);
  });

  testWidgets('Invited chip filters to pending invitations only', (
    tester,
  ) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Invited'));
    await tester.pumpAndSettle();

    expect(find.text('Grace Miller'), findsOneWidget);
    expect(find.text('James Brown'), findsNothing);
    expect(find.text('Lisa Martinez'), findsNothing);
    expect(find.textContaining('INVITATION PENDING'), findsOneWidget);
  });

  testWidgets(
    'resending an invitation calls CreateStaffInvitation and refreshes',
    (tester) async {
      when(
        () => mockGetStaffMembers(any()),
      ).thenAnswer((_) async => Right(staffList));

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // Filter to Invited so Grace Miller's row is the only one, and its
      // actions menu is unambiguous.
      await tester.tap(find.text('Invited'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend invitation'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Resend'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.createStaffInvitation('u3')).called(1);
      expect(
        find.text('Invitation resent to grace.miller@schoolpulse.com.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('revoking an invitation calls CancelStaffInvitation', (
    tester,
  ) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Invited'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Revoke invitation'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
    await tester.pumpAndSettle();

    verify(() => mockAuthRepository.cancelStaffInvitation('u3')).called(1);
  });

  testWidgets('deactivating an active staff member calls ToggleStaffStatus', (
    tester,
  ) async {
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Filter to Active first so James Brown (u1) is the only row and its
    // actions menu is unambiguous.
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Deactivate'));
    await tester.pumpAndSettle();

    verify(
      () =>
          mockAuthRepository.toggleStaffActiveStatus('u1', false, reason: null),
    ).called(1);
  });

  testWidgets('row actions menu hidden for a non-admin role', (tester) async {
    const teacherUser = UserEntity(
      id: 'teacher-1',
      name: 'Deputy Teacher',
      email: 'deputy@schoolpulse.com',
      schoolId: 'school-1',
      roles: [UserRole.subjectTeacher],
    );
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthAuthenticated(teacherUser));
    when(
      () => mockGetStaffMembers(any()),
    ).thenAnswer((_) async => Right(staffList));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });
}
