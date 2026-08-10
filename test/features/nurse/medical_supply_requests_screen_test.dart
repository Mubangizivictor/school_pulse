import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/medical_supply_request.dart';
import 'package:school_pulse/features/health/domain/repositories/health_repository.dart';
import 'package:school_pulse/features/health/domain/usecases/health_usecases.dart';
import 'package:school_pulse/features/inventory/presentation/screens/medical_supply_requests_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHealthRepository extends Mock implements HealthRepository {}

void main() {
  late MockAuthBloc authBloc;
  late MockHealthRepository healthRepository;

  const storekeeper = UserEntity(
    id: 'store-1',
    name: 'Store Keeper',
    email: 'store@school.test',
    roles: [UserRole.storeInventory],
    schoolId: 'school-1',
  );

  final pendingRequest = MedicalSupplyRequest(
    id: 'request-1',
    itemName: 'Disposable gloves',
    quantity: 6,
    unit: 'boxes',
    requestedBy: 'nurse-1',
    requestDate: DateTime(2026, 7, 22),
    status: SupplyRequestStatus.pending,
    schoolId: 'school-1',
  );

  setUpAll(() {
    registerFallbackValue(SupplyRequestStatus.pending);
  });

  setUp(() async {
    await di.sl.reset();
    authBloc = MockAuthBloc();
    healthRepository = MockHealthRepository();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(storekeeper));
    when(
      () => healthRepository.getMedicalSupplyRequests(any()),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => healthRepository.updateSupplyRequestStatus(
        any(),
        any(),
        any(),
        reviewNotes: any(named: 'reviewNotes'),
        rejectionReason: any(named: 'rejectionReason'),
      ),
    ).thenAnswer((_) async => const Right(null));

    di.sl.registerLazySingleton<GetMedicalSupplyRequests>(
      () => GetMedicalSupplyRequests(healthRepository),
    );
    di.sl.registerLazySingleton<UpdateSupplyRequestStatus>(
      () => UpdateSupplyRequestStatus(healthRepository),
    );
  });

  tearDown(() async {
    await di.sl.reset();
  });

  Future<void> pumpScreen(WidgetTester tester, {bool settle = true}) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: MedicalSupplyRequestsScreen()),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('shows a loading indicator while Store requests are pending', (
    tester,
  ) async {
    final completer = Completer<Either<Failure, List<MedicalSupplyRequest>>>();
    when(
      () => healthRepository.getMedicalSupplyRequests('school-1'),
    ).thenAnswer((_) => completer.future);

    await pumpScreen(tester, settle: false);

    expect(find.byType(SchoolPulseLoader), findsOneWidget);
    verify(
      () => healthRepository.getMedicalSupplyRequests('school-1'),
    ).called(1);
  });

  testWidgets('shows the empty state when there are no medical requests', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('No medical requests'), findsOneWidget);
    expect(
      find.text('Requests submitted by the school nurse appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a load error and retries successfully', (tester) async {
    var loadCount = 0;
    when(
      () => healthRepository.getMedicalSupplyRequests('school-1'),
    ).thenAnswer((_) async {
      loadCount += 1;
      if (loadCount == 1) {
        return const Left(ServerFailure('Store service is offline'));
      }
      return const Right([]);
    });

    await pumpScreen(tester);
    expect(find.text('Could not load requests'), findsOneWidget);
    expect(find.text('Store service is offline'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('No medical requests'), findsOneWidget);
    verify(
      () => healthRepository.getMedicalSupplyRequests('school-1'),
    ).called(2);
  });

  testWidgets('renders a pending request and approves it', (tester) async {
    when(
      () => healthRepository.getMedicalSupplyRequests('school-1'),
    ).thenAnswer((_) async => Right([pendingRequest]));

    await pumpScreen(tester);
    expect(find.text('Disposable gloves'), findsOneWidget);
    expect(find.text('6 boxes'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    verify(
      () => healthRepository.updateSupplyRequestStatus(
        'request-1',
        'school-1',
        SupplyRequestStatus.approved,
        reviewNotes: null,
        rejectionReason: null,
      ),
    ).called(1);
  });

  testWidgets('requires a rejection reason and forwards the entered reason', (
    tester,
  ) async {
    when(
      () => healthRepository.getMedicalSupplyRequests('school-1'),
    ).thenAnswer((_) async => Right([pendingRequest]));

    await pumpScreen(tester);
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject request'));
    await tester.pump();

    expect(find.text('Enter a rejection reason.'), findsOneWidget);
    verifyNever(
      () => healthRepository.updateSupplyRequestStatus(
        any(),
        any(),
        any(),
        reviewNotes: any(named: 'reviewNotes'),
        rejectionReason: any(named: 'rejectionReason'),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Reason'),
      'Supplier stock is unavailable',
    );
    await tester.tap(find.text('Reject request'));
    await tester.pumpAndSettle();

    verify(
      () => healthRepository.updateSupplyRequestStatus(
        'request-1',
        'school-1',
        SupplyRequestStatus.rejected,
        reviewNotes: null,
        rejectionReason: 'Supplier stock is unavailable',
      ),
    ).called(1);
  });
}
