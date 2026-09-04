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
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _MockGetStaffMembers extends Mock implements GetStaffMembers {}

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
  ];

  late _MockGetStaffMembers mockGetStaffMembers;
  late _MockAuthBloc mockAuthBloc;

  setUp(() {
    mockGetStaffMembers = _MockGetStaffMembers();
    mockAuthBloc = _MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(schoolAdmin));

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
  });

  tearDown(() {
    if (di.sl.isRegistered<GetStaffMembers>()) {
      di.sl.unregister<GetStaffMembers>();
    }
    if (di.sl.isRegistered<StructureBloc>()) {
      di.sl.unregister<StructureBloc>();
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
      builder: (context, child) => BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: child,
      ),
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
    expect(find.text('2 staff members'), findsOneWidget);
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

  testWidgets('empty state shows Add Staff cta for admin role', (
    tester,
  ) async {
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

  testWidgets('tapping a staff row navigates to staff detail', (
    tester,
  ) async {
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

    expect(find.widgetWithText(FilledButton, 'Add staff'), findsNothing);
  });

  testWidgets(
    'narrow phone width collapses Add staff to an icon button with no overflow',
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

      expect(find.widgetWithText(FilledButton, 'Add staff'), findsNothing);
      expect(find.widgetWithIcon(IconButton, Icons.add), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tablet width (768) renders the dense table, not the card list', (
    tester,
  ) async {
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
    expect(find.byType(Table), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    expect(find.widgetWithText(FilledButton, 'Add staff'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
