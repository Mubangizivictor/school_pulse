import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/domain/entities/medical_supply_request.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/nurse/presentation/screens/medicine_inventory_screen.dart';

class MockHealthBloc extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockHealthBloc healthBloc;
  late MockAuthBloc authBloc;

  const nurse = UserEntity(
    id: 'nurse-1',
    name: 'Nurse Grace',
    email: 'nurse@school.test',
    roles: [UserRole.nurse],
    schoolId: 'school-1',
  );

  setUpAll(() {
    registerFallbackValue(const FetchInventory('fallback-school'));
  });

  setUp(() {
    healthBloc = MockHealthBloc();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(nurse));
  });

  Future<void> pumpScreen(WidgetTester tester, HealthState state) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => healthBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HealthBloc>.value(value: healthBloc),
        ],
        child: const MaterialApp(home: MedicineInventoryScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows loading and fetches inventory for the signed-in school', (
    tester,
  ) async {
    await pumpScreen(tester, HealthLoading());

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    verify(() => healthBloc.add(const FetchInventory('school-1'))).called(1);
  });

  testWidgets('shows the empty and error states and retries the inventory', (
    tester,
  ) async {
    await pumpScreen(tester, const InventoryLoaded([]));
    expect(find.text('Inventory is empty'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    clearInteractions(healthBloc);

    await pumpScreen(tester, const HealthError('Inventory is unavailable'));
    expect(find.text('Inventory is unavailable'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => healthBloc.add(const FetchInventory('school-1'))).called(2);
  });

  testWidgets('renders stock warnings and validates a stock update', (
    tester,
  ) async {
    final item = MedicalInventoryItem(
      id: 'item-1',
      schoolId: 'school-1',
      name: 'Paracetamol',
      type: MedicalItemType.medication,
      category: 'Pain relief',
      quantity: 2,
      unit: 'boxes',
      reorderLevel: 5,
      batchNumber: 'B-22',
      expiryDate: DateTime(2020),
    );
    await pumpScreen(tester, InventoryLoaded([item]));

    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.text('LOW STOCK'), findsOneWidget);
    expect(find.text('EXPIRED'), findsOneWidget);

    await tester.tap(find.text('Paracetamol'));
    await tester.pumpAndSettle();
    final quantityField = find.widgetWithText(TextField, 'Current Quantity');
    await tester.enterText(quantityField, '-1');
    await tester.tap(find.text('Update'));
    await tester.pump();

    expect(find.text('Enter a valid non-negative quantity.'), findsOneWidget);
    verifyNever(
      () => healthBloc.add(any(that: isA<UpdateInventoryItemEvent>())),
    );

    await tester.enterText(quantityField, '12');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    final event =
        verify(
              () => healthBloc.add(
                captureAny(that: isA<UpdateInventoryItemEvent>()),
              ),
            ).captured.single
            as UpdateInventoryItemEvent;
    expect(event.item.id, 'item-1');
    expect(event.item.quantity, 12);
    expect(event.item.schoolId, 'school-1');
  });

  testWidgets('validates and submits a new inventory item', (tester) async {
    await pumpScreen(tester, const InventoryLoaded([]));

    await tester.tap(find.byTooltip('Add Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-inventory-item-button')));
    await tester.pump();

    expect(
      find.byKey(const Key('inventory-item-validation-error')),
      findsOneWidget,
    );
    verifyNever(
      () => healthBloc.add(any(that: isA<UpdateInventoryItemEvent>())),
    );

    await tester.enterText(
      find.byKey(const Key('inventory-item-name-field')),
      'Sterile gauze',
    );
    await tester.tap(find.byKey(const Key('add-inventory-item-button')));
    await tester.pumpAndSettle();

    final event =
        verify(
              () => healthBloc.add(
                captureAny(that: isA<UpdateInventoryItemEvent>()),
              ),
            ).captured.single
            as UpdateInventoryItemEvent;
    expect(event.item.name, 'Sterile gauze');
    expect(event.item.quantity, 0);
    expect(event.item.schoolId, 'school-1');
  });

  testWidgets('switches to supply requests and renders request status', (
    tester,
  ) async {
    final request = MedicalSupplyRequest(
      id: 'request-1',
      itemName: 'Disposable gloves',
      quantity: 4,
      unit: 'boxes',
      requestedBy: 'nurse-1',
      requestDate: DateTime(2026, 7, 20),
      status: SupplyRequestStatus.approved,
      schoolId: 'school-1',
    );
    await pumpScreen(tester, SupplyRequestsLoaded([request]));

    await tester.tap(find.text('Supply Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Disposable gloves'), findsOneWidget);
    expect(find.text('APPROVED'), findsOneWidget);
    verify(
      () => healthBloc.add(const FetchSupplyRequests('school-1')),
    ).called(greaterThanOrEqualTo(1));
  });

  testWidgets('validates and submits a medical supply request', (tester) async {
    await pumpScreen(tester, const InventoryLoaded([]));

    await tester.tap(find.text('Request Supplies'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit-supply-request-button')));
    await tester.pump();

    expect(
      find.byKey(const Key('supply-request-validation-error')),
      findsOneWidget,
    );
    verifyNever(() => healthBloc.add(any(that: isA<CreateNewSupplyRequest>())));

    await tester.enterText(
      find.widgetWithText(TextField, 'Item Name'),
      'First aid tape',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '3');
    await tester.tap(find.byKey(const Key('submit-supply-request-button')));
    await tester.pumpAndSettle();

    final event =
        verify(
              () => healthBloc.add(
                captureAny(that: isA<CreateNewSupplyRequest>()),
              ),
            ).captured.single
            as CreateNewSupplyRequest;
    expect(event.request.itemName, 'First aid tape');
    expect(event.request.quantity, 3);
    expect(event.request.requestedBy, 'nurse-1');
    expect(event.request.schoolId, 'school-1');
  });
}
