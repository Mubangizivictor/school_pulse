import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/finance/data/datasources/clearance_policy_remote_data_source.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_catalogue_item.dart';
import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_catalogue_repository.dart';
import 'package:school_pulse/features/finance/presentation/bloc/clearance_policy/clearance_policy_bloc.dart';

class MockDs extends Mock implements ClearancePolicyRemoteDataSource {}

class MockCatalogue extends Mock implements FeeCatalogueRepository {}

void main() {
  late ClearancePolicyBloc bloc;
  late MockDs ds;
  late MockCatalogue catalogue;

  setUpAll(() {
    registerFallbackValue(const FinancialClearancePolicy());
  });

  setUp(() {
    ds = MockDs();
    catalogue = MockCatalogue();
    bloc = ClearancePolicyBloc(
      dataSource: ds,
      feeCatalogueRepository: catalogue,
    );
    when(() => catalogue.watchCatalogue(any())).thenAnswer(
      (_) => Stream.value(const [
        FeeCatalogueItem(id: 'tuition', schoolId: 'schoolA', name: 'Tuition'),
      ]),
    );
  });

  tearDown(() => bloc.close());

  blocTest<ClearancePolicyBloc, ClearancePolicyState>(
    'loads the policy + fee catalogue',
    build: () => bloc,
    setUp: () {
      when(() => ds.getPolicy()).thenAnswer(
        (_) async => (
          policy: const FinancialClearancePolicy(
            mode: ClearanceMode.minimumPercentage,
            minimumPercentagePaid: 60,
          ),
          meta: const ClearancePolicyMeta(configured: true),
        ),
      );
    },
    act: (b) => b.add(const ClearancePolicyLoaded('schoolA')),
    expect: () => [
      isA<ClearancePolicyState>().having(
        (s) => s.status,
        'status',
        ClearancePolicyStatus.loading,
      ),
      isA<ClearancePolicyState>()
          .having((s) => s.status, 'status', ClearancePolicyStatus.ready)
          .having((s) => s.draft.mode, 'mode', ClearanceMode.minimumPercentage)
          .having((s) => s.feeCatalogue.length, 'catalogue', 1)
          .having((s) => s.isDirty, 'dirty', false),
    ],
  );

  blocTest<ClearancePolicyBloc, ClearancePolicyState>(
    'editing the draft marks the state dirty',
    build: () => bloc,
    seed: () => const ClearancePolicyState(status: ClearancePolicyStatus.ready),
    act: (b) => b.add(
      ClearancePolicyDraftChanged(
        const FinancialClearancePolicy(mode: ClearanceMode.selectedCategories),
      ),
    ),
    expect: () => [
      isA<ClearancePolicyState>().having((s) => s.isDirty, 'dirty', true),
    ],
  );

  blocTest<ClearancePolicyBloc, ClearancePolicyState>(
    'saving reports how many report periods were re-evaluated',
    build: () => bloc,
    seed: () => ClearancePolicyState(
      status: ClearancePolicyStatus.ready,
      draft: const FinancialClearancePolicy(
        mode: ClearanceMode.minimumPercentage,
        minimumPercentagePaid: 80,
      ),
    ),
    setUp: () {
      when(() => ds.savePolicy(any())).thenAnswer(
        (_) async => (
          policy: const FinancialClearancePolicy(
            mode: ClearanceMode.minimumPercentage,
            minimumPercentagePaid: 80,
          ),
          reMaterialisedPeriods: 7,
        ),
      );
    },
    act: (b) => b.add(const ClearancePolicySaved()),
    expect: () => [
      isA<ClearancePolicyState>().having(
        (s) => s.status,
        'status',
        ClearancePolicyStatus.saving,
      ),
      isA<ClearancePolicyState>()
          .having((s) => s.status, 'status', ClearancePolicyStatus.ready)
          .having((s) => s.isDirty, 'dirty', false)
          .having(
            (s) => s.successMessage,
            'msg',
            contains('7 report period(s)'),
          )
          .having((s) => s.meta.effectiveFrom, 'effectiveFrom', isNotNull),
    ],
  );

  blocTest<ClearancePolicyBloc, ClearancePolicyState>(
    'an unauthorised save surfaces a friendly message',
    build: () => bloc,
    seed: () => const ClearancePolicyState(status: ClearancePolicyStatus.ready),
    setUp: () {
      when(
        () => ds.savePolicy(any()),
      ).thenThrow(Exception('permission-denied: not authorised'));
    },
    act: (b) => b.add(const ClearancePolicySaved()),
    expect: () => [
      isA<ClearancePolicyState>().having(
        (s) => s.status,
        'status',
        ClearancePolicyStatus.saving,
      ),
      isA<ClearancePolicyState>()
          .having((s) => s.status, 'status', ClearancePolicyStatus.ready)
          .having((s) => s.errorMessage, 'error', contains('not authorised')),
    ],
  );
}
