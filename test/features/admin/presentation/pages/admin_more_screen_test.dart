import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/presentation/screens/admin_more_screen.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_sync_service.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _MockSubjectSyncService extends Mock implements SubjectSyncService {}

class _LogoutPressedFake extends Fake implements AuthEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_LogoutPressedFake());
  });

  const schoolAdmin = UserEntity(
    id: 'admin-1',
    name: 'School Admin',
    email: 'admin@schoolpulse.com',
    schoolId: 'school-1',
    schoolName: "St. Mary's Academy",
    roles: [UserRole.schoolAdmin],
    isActive: true,
  );

  const bursar = UserEntity(
    id: 'bursar-1',
    name: 'Bursar Jane',
    email: 'bursar@schoolpulse.com',
    schoolId: 'school-1',
    roles: [UserRole.bursar],
  );

  late _MockAuthBloc mockAuthBloc;
  late _MockSubjectSyncService mockSyncService;

  setUp(() {
    mockAuthBloc = _MockAuthBloc();
    mockSyncService = _MockSubjectSyncService();
    when(() => mockSyncService.pending(schoolId: any(named: 'schoolId')))
        .thenAnswer((_) async => []);

    if (di.sl.isRegistered<SubjectSyncService>()) {
      di.sl.unregister<SubjectSyncService>();
    }
    di.sl.registerLazySingleton<SubjectSyncService>(() => mockSyncService);
  });

  Widget buildApp(UserEntity user, {Size size = const Size(390, 844)}) {
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user));
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const AdminMoreScreen(),
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (_) => const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }

  testWidgets('shows all admin tools for School Admin', (tester) async {
    await tester.pumpWidget(buildApp(schoolAdmin));
    await tester.pumpAndSettle();

    expect(find.text('School structure'), findsOneWidget);
    expect(find.text('Roles & access'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('School settings'), findsOneWidget);
  });

  testWidgets('hides admin tools for an unauthorized role', (tester) async {
    await tester.pumpWidget(buildApp(bursar));
    await tester.pumpAndSettle();

    expect(find.text('School structure'), findsNothing);
    expect(find.text('Roles & access'), findsNothing);
    expect(find.text('Reports'), findsNothing);
    expect(find.text('School settings'), findsNothing);
  });

  testWidgets('shows account identity and school name', (tester) async {
    await tester.pumpWidget(buildApp(schoolAdmin));
    await tester.pumpAndSettle();

    expect(find.text("St. Mary's Academy"), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('log out opens a confirmation dialog before signing out', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(schoolAdmin));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Log out'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    verifyNever(() => mockAuthBloc.add(any()));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => mockAuthBloc.add(any()));
  });

  testWidgets('renders two-column grid layout at desktop width', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(schoolAdmin, size: const Size(1280, 900)));
    await tester.pumpAndSettle();

    expect(find.text('School administration'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Personal'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    expect(find.text('Personal'), findsOneWidget);
  });

  final widths = <String, Size>{
    'compact mobile (360)': const Size(360, 780),
    'mobile (390)': const Size(390, 844),
    'large mobile (480)': const Size(480, 900),
    'tablet (600)': const Size(600, 900),
    'tablet (768)': const Size(768, 1024),
    'small desktop (1024)': const Size(1024, 800),
    'desktop (1280)': const Size(1280, 900),
    'large desktop (1440)': const Size(1440, 960),
  };

  for (final entry in widths.entries) {
    testWidgets('no overflow or render errors at ${entry.key}', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(schoolAdmin, size: entry.value));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('long name and school name do not overflow the account card', (
    tester,
  ) async {
    const longUser = UserEntity(
      id: 'admin-2',
      name: 'Nakato Elizabeth Mubangizi-Nantongo',
      email: 'admin2@schoolpulse.com',
      schoolId: 'school-1',
      schoolName:
          'St. Mary of the Immaculate Conception International Academy and Boarding School',
      roles: [UserRole.headTeacher],
      isActive: true,
    );
    for (final size in [const Size(360, 780), const Size(1280, 900)]) {
      await tester.pumpWidget(buildApp(longUser, size: size));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
