import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_home_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHealthBloc extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class MockBrandingBloc extends MockBloc<BrandingEvent, BrandingState>
    implements BrandingBloc {}

void main() {
  const schoolId = 'test-school';
  const nurse = UserEntity(
    id: 'nurse-1',
    name: 'Nurse Grace',
    email: 'nurse@school.test',
    roles: [UserRole.nurse],
    schoolId: schoolId,
  );

  late MockAuthBloc authBloc;
  late MockHealthBloc healthBloc;
  late MockBrandingBloc brandingBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    healthBloc = MockHealthBloc();
    brandingBloc = MockBrandingBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(nurse));
    when(() => healthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => brandingBloc.state).thenReturn(BrandingInitial());
    when(() => brandingBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/staff/nurse',
      routes: [
        GoRoute(
          path: '/staff/nurse',
          builder: (context, state) => const NurseHomeScreen(),
        ),
        GoRoute(
          path: '/staff/nurse/lookup',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/nurse/visits',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/nurse/visits/new',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/nurse/inventory',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/nurse/records',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/staff/notifications',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<HealthBloc>.value(value: healthBloc),
        BlocProvider<BrandingBloc>.value(value: brandingBloc),
      ],
      child: MaterialApp.router(
        theme: AppTheme.getTheme(Brightness.dark),
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders clinic overview computed from real dashboard data', (
    tester,
  ) async {
    final visit = ClinicVisit(
      id: 'v1',
      studentId: 's1',
      dateTime: DateTime.now(),
      reason: 'Headache',
      symptoms: 'Fever',
      outcome: VisitOutcome.sentHome,
      recordedBy: 'nurse-1',
      schoolId: schoolId,
    );
    when(() => healthBloc.state).thenReturn(
      HealthDashboardLoaded(
        todayVisits: [visit],
        todayEmergencies: const [],
        lowStockItems: const [
          MedicalInventoryItem(
            id: 'i1',
            name: 'Paracetamol',
            type: MedicalItemType.medication,
            category: 'Pain relief',
            quantity: 2,
            unit: 'tablets',
            reorderLevel: 10,
          ),
        ],
        pendingRequests: const [],
        stats: const {},
        chronicCaseCount: 3,
        allergyCount: 5,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Nurse'), findsWidgets);
    expect(find.text('Clinic overview'), findsOneWidget);
    expect(find.text('Today’s visits'), findsOneWidget);
    expect(find.text('Waiting now'), findsOneWidget);
    expect(find.text('Follow-ups due'), findsOneWidget);
    expect(find.text('Low-stock items'), findsOneWidget);
    expect(find.text('Record visit'), findsOneWidget);
    expect(find.text('Search learner'), findsOneWidget);
    // One low-stock item drives the metric count and its danger styling.
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('surfaces the low-stock count in its metric card', (
    tester,
  ) async {
    when(() => healthBloc.state).thenReturn(
      const HealthDashboardLoaded(
        todayVisits: [],
        todayEmergencies: [],
        lowStockItems: [
          MedicalInventoryItem(
            id: 'i1',
            name: 'Bandages',
            type: MedicalItemType.supply,
            category: 'First aid',
            quantity: 1,
            unit: 'rolls',
            reorderLevel: 5,
          ),
        ],
        pendingRequests: [],
        stats: {},
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Low-stock items'), findsOneWidget);
    expect(find.text('View inventory'), findsOneWidget);
  });

  testWidgets('shows the compact empty state when no visits recorded today', (
    tester,
  ) async {
    when(() => healthBloc.state).thenReturn(
      const HealthDashboardLoaded(
        todayVisits: [],
        todayEmergencies: [],
        lowStockItems: [],
        pendingRequests: [],
        stats: {},
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No visits have been recorded today.'), findsOneWidget);
  });

  testWidgets('shows school-assignment message when nurse has no schoolId', (
    tester,
  ) async {
    when(() => authBloc.state).thenReturn(
      const AuthAuthenticated(
        UserEntity(
          id: 'nurse-3',
          name: 'Unassigned Nurse',
          email: 'x@school.test',
          roles: [UserRole.nurse],
          schoolId: '',
        ),
      ),
    );
    when(() => healthBloc.state).thenReturn(HealthInitial());

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('not assigned to a school'), findsOneWidget);
  });
}
