import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_governance_remote_data_source.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:school_pulse/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:school_pulse/features/finance/domain/entities/budget.dart';
import 'package:school_pulse/features/finance/domain/entities/expenditure.dart';

class _MockRemote extends Mock implements FinanceRemoteDataSource {}

class _MockGovernance extends Mock
    implements FinanceGovernanceRemoteDataSource {}

/// Audit area 2 — the repository routes budget + expenditure writes through
/// the callable data source (never `remoteDataSource`), maps the UI's
/// `ExpenditureStatus` decision to the callable verb, and turns a
/// `FirebaseFunctionsException` into the matching typed `Failure`.
void main() {
  late _MockRemote remote;
  late _MockGovernance gov;
  late FinanceRepositoryImpl repo;

  const budget = Budget(
    id: '',
    schoolId: 'school1',
    name: 'Transport',
    academicYear: '2026',
    term: 'Term 1',
    allocatedAmount: 500000,
  );

  final requisition = ExpenditureRequest(
    id: '',
    schoolId: 'school1',
    requesterId: 'u1',
    requesterName: 'Jane',
    description: 'Whiteboards',
    amount: 150000,
    budgetCategoryId: 'Supplies',
    status: ExpenditureStatus.pending,
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(budget);
    registerFallbackValue(requisition);
  });

  setUp(() {
    remote = _MockRemote();
    gov = _MockGovernance();
    repo = FinanceRepositoryImpl(remoteDataSource: remote, governance: gov);
  });

  group('saveBudget', () {
    test('delegates to the callable, not the Firestore data source', () async {
      when(
        () => gov.saveSchoolBudget(
          any(),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async => 'bdg_1');

      final result = await repo.saveBudget(budget);

      expect(result, const Right<Failure, void>(null));
      verify(() => gov.saveSchoolBudget(budget)).called(1);
    });

    test(
      'maps permission-denied to PermissionDeniedFailure with the server message',
      () async {
        when(
          () => gov.saveSchoolBudget(
            any(),
            clientRequestId: any(named: 'clientRequestId'),
          ),
        ).thenThrow(
          FirebaseFunctionsException(
            message: 'Not authorised to manage budget lines.',
            code: 'permission-denied',
          ),
        );

        final result = await repo.saveBudget(budget);

        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<PermissionDeniedFailure>());
          expect(f.message, contains('Not authorised'));
        }, (_) => fail('expected a failure'));
      },
    );

    test('maps invalid-argument to ValidationFailure', () async {
      when(
        () => gov.saveSchoolBudget(
          any(),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenThrow(
        FirebaseFunctionsException(
          message:
              'Allocated amount must be a whole number of UGX (0 or more).',
          code: 'invalid-argument',
        ),
      );

      final result = await repo.saveBudget(budget);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('createExpenditureRequest', () {
    test('delegates to submitExpenditure', () async {
      when(
        () => gov.submitExpenditure(
          any(),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async => 'req_1');

      final result = await repo.createExpenditureRequest(requisition);

      expect(result, const Right<Failure, void>(null));
      verify(() => gov.submitExpenditure(requisition)).called(1);
    });
  });

  group('updateExpenditureStatus', () {
    test('approved -> decision "approve"', () async {
      when(
        () => gov.decideExpenditure(
          schoolId: any(named: 'schoolId'),
          expenditureId: any(named: 'expenditureId'),
          decision: any(named: 'decision'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => 'approved');

      await repo.updateExpenditureStatus(
        'school1',
        'exp1',
        ExpenditureStatus.approved,
        'a1',
        'Amina',
        'headTeacher',
        null,
      );

      verify(
        () => gov.decideExpenditure(
          schoolId: 'school1',
          expenditureId: 'exp1',
          decision: 'approve',
          comment: null,
        ),
      ).called(1);
    });

    test('rejected -> decision "reject" and carries the comment', () async {
      when(
        () => gov.decideExpenditure(
          schoolId: any(named: 'schoolId'),
          expenditureId: any(named: 'expenditureId'),
          decision: any(named: 'decision'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => 'rejected');

      await repo.updateExpenditureStatus(
        'school1',
        'exp1',
        ExpenditureStatus.rejected,
        'a1',
        'Amina',
        'headTeacher',
        'over budget',
      );

      verify(
        () => gov.decideExpenditure(
          schoolId: 'school1',
          expenditureId: 'exp1',
          decision: 'reject',
          comment: 'over budget',
        ),
      ).called(1);
    });

    test('pending -> decision "return" (send back to requester)', () async {
      when(
        () => gov.decideExpenditure(
          schoolId: any(named: 'schoolId'),
          expenditureId: any(named: 'expenditureId'),
          decision: any(named: 'decision'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => 'pending');

      await repo.updateExpenditureStatus(
        'school1',
        'exp1',
        ExpenditureStatus.pending,
        'a1',
        'Amina',
        'headTeacher',
        'need a quote',
      );

      verify(
        () => gov.decideExpenditure(
          schoolId: 'school1',
          expenditureId: 'exp1',
          decision: 'return',
          comment: 'need a quote',
        ),
      ).called(1);
    });

    test(
      'a self-approval rejection from the server becomes PermissionDeniedFailure',
      () async {
        when(
          () => gov.decideExpenditure(
            schoolId: any(named: 'schoolId'),
            expenditureId: any(named: 'expenditureId'),
            decision: any(named: 'decision'),
            comment: any(named: 'comment'),
          ),
        ).thenThrow(
          FirebaseFunctionsException(
            message: 'You cannot decide a requisition you raised.',
            code: 'permission-denied',
          ),
        );

        final result = await repo.updateExpenditureStatus(
          'school1',
          'exp1',
          ExpenditureStatus.approved,
          'a1',
          'Amina',
          'bursar',
          null,
        );
        result.fold((f) {
          expect(f, isA<PermissionDeniedFailure>());
          expect(f.message, contains('cannot decide a requisition you raised'));
        }, (_) => fail('expected a failure'));
      },
    );
  });

  group('decisionFor mapping', () {
    test('covers every ExpenditureStatus', () {
      expect(
        FinanceGovernanceRemoteDataSource.decisionFor(
          ExpenditureStatus.approved,
        ),
        'approve',
      );
      expect(
        FinanceGovernanceRemoteDataSource.decisionFor(
          ExpenditureStatus.rejected,
        ),
        'reject',
      );
      expect(
        FinanceGovernanceRemoteDataSource.decisionFor(
          ExpenditureStatus.pending,
        ),
        'return',
      );
    });
  });

  test(
    'a repo built without governance throws on a write (misconfiguration guard)',
    () async {
      final noGov = FinanceRepositoryImpl(remoteDataSource: remote);
      await expectLater(
        () => noGov.saveBudget(budget),
        throwsA(isA<StateError>()),
      );
    },
  );
}
