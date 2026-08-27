import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:school_pulse/features/finance/domain/entities/budget.dart';
import 'package:school_pulse/features/finance/domain/entities/expenditure.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/finance/domain/services/finance_service.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';

class MockFinanceRepository extends Mock implements FinanceRepository {}

class MockPrinterService extends Mock implements PrinterService {}

void main() {
  late FinanceBloc bloc;
  late MockFinanceRepository mockRepository;

  final budget = const Budget(
    id: '',
    schoolId: 'school1',
    name: 'Transport',
    academicYear: '2026',
    term: 'Term 1',
    allocatedAmount: 500000,
  );

  final expenditureRequest = ExpenditureRequest(
    id: '',
    schoolId: 'school1',
    requesterId: 'user1',
    requesterName: 'Jane Doe',
    description: 'New whiteboards',
    amount: 150000,
    budgetCategoryId: 'Supplies',
    status: ExpenditureStatus.pending,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockFinanceRepository();
    bloc = FinanceBloc(
      repository: mockRepository,
      financeService: FinanceService(mockRepository),
      printerService: MockPrinterService(),
    );
  });

  tearDown(() => bloc.close());

  group('SaveSchoolBudget', () {
    blocTest<FinanceBloc, FinanceState>(
      'emits FinanceActionSuccess when the repository saves the budget '
      '(covers Budget Management "Add Budget" now dispatching a real event '
      'instead of doing nothing)',
      setUp: () {
        when(
          () => mockRepository.saveBudget(budget),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(SaveSchoolBudget(budget)),
      expect: () => [const FinanceActionSuccess('Budget saved')],
      verify: (_) {
        verify(() => mockRepository.saveBudget(budget)).called(1);
      },
    );

    blocTest<FinanceBloc, FinanceState>(
      'emits FinanceError when the repository fails to save the budget',
      setUp: () {
        when(() => mockRepository.saveBudget(budget)).thenAnswer(
          (_) async => Left(ServerFailure('boom')),
        );
      },
      build: () => bloc,
      act: (bloc) => bloc.add(SaveSchoolBudget(budget)),
      expect: () => [const FinanceError('Failed to save budget')],
    );
  });

  group('SubmitExpenditureRequest', () {
    blocTest<FinanceBloc, FinanceState>(
      'emits FinanceActionSuccess when the repository creates the request '
      '(covers Expenditure "Add" now dispatching a real event)',
      setUp: () {
        when(
          () => mockRepository.createExpenditureRequest(expenditureRequest),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(SubmitExpenditureRequest(expenditureRequest)),
      expect: () => [
        const FinanceActionSuccess('Expenditure request submitted'),
      ],
    );
  });

  group('UpdateExpenditureApproval', () {
    blocTest<FinanceBloc, FinanceState>(
      'emits FinanceActionSuccess when the repository updates approval '
      'status (covers the approve/reject dialog now dispatching a real '
      'event)',
      setUp: () {
        when(
          () => mockRepository.updateExpenditureStatus(
            'school1',
            'req1',
            ExpenditureStatus.approved,
            'approver1',
            'Head Teacher',
            'headTeacher',
            'Looks good',
          ),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(
        const UpdateExpenditureApproval(
          schoolId: 'school1',
          requestId: 'req1',
          status: ExpenditureStatus.approved,
          approverId: 'approver1',
          approverName: 'Head Teacher',
          approverRole: 'headTeacher',
          comment: 'Looks good',
        ),
      ),
      expect: () => [const FinanceActionSuccess('Approval status updated')],
    );
  });
}
