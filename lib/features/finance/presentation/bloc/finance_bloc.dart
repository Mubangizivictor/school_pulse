import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/printer/printer_service.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/services/finance_service.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository repository;
  final FinanceService financeService;
  final PrinterService printerService;

  FinanceBloc({
    required this.repository,
    required this.financeService,
    required this.printerService,
  }) : super(FinanceInitial()) {
    on<FetchFees>(_onFetchFees);
    on<LoadFinanceDashboard>(_onLoadFinanceDashboard);
    on<LoadStudentFinancialProfile>(_onLoadStudentFinancialProfile);
    on<RecordNewPayment>(_onRecordNewPayment);
    on<PrintReceipt>(_onPrintReceipt);
    on<VerifyFinanceReceipt>(_onVerifyFinanceReceipt);
    on<CheckStudentEligibility>(_onCheckStudentEligibility);
    on<LoadExpenditureRequests>(_onLoadExpenditureRequests);
    on<SubmitExpenditureRequest>(_onSubmitExpenditureRequest);
    on<UpdateExpenditureApproval>(_onUpdateExpenditureApproval);
    on<LoadBudgets>(_onLoadBudgets);
    on<SaveSchoolBudget>(_onSaveSchoolBudget);
    on<LoadFeeCategories>(_onLoadFeeCategories);
    on<SaveSchoolFeeCategory>(_onSaveSchoolFeeCategory);
    on<LoadFeeStructures>(_onLoadFeeStructures);
    on<SaveSchoolFeeStructure>(_onSaveSchoolFeeStructure);
  }

  Future<void> _onFetchFees(FetchFees event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final feesResult = await repository.getFees(event.studentId);
    final historyResult = await repository.getAllPaymentHistory();

    feesResult.fold(
      (failure) => emit(const FinanceError('Failed to load fees')),
      (fees) {
        final studentHistory = historyResult
            .getOrElse(() => [])
            .where((payment) => payment.studentId == event.studentId)
            .toList();
        emit(FinanceLoaded(fees: fees, paymentHistory: studentHistory));
      },
    );
  }

  Future<void> _onLoadFinanceDashboard(
    LoadFinanceDashboard event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final kpisResult = await repository.getFinancialDashboardKPIs(
      event.schoolId,
    );
    final transactionsResult = await repository.getSchoolPayments(
      event.schoolId,
    );
    final expendituresResult = await repository.getExpenditureRequests(
      event.schoolId,
    );

    kpisResult.fold(
      (failure) => emit(const FinanceError('Failed to load dashboard KPIs')),
      (kpis) {
        emit(
          FinanceDashboardLoaded(
            kpis: kpis,
            recentTransactions: transactionsResult.getOrElse(() => []),
            pendingApprovals: expendituresResult
                .getOrElse(() => [])
                .where((e) => e.status.name == 'pending')
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _onLoadStudentFinancialProfile(
    LoadStudentFinancialProfile event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final accountResult = await repository.getStudentFinancialAccount(
      event.studentId,
      event.schoolId,
    );
    final historyResult = await repository.getPaymentHistory(
      event.studentId,
      event.schoolId,
    );

    accountResult.fold(
      (failure) => emit(const FinanceError('Failed to load financial account')),
      (account) => emit(
        StudentFinancialProfileLoaded(
          account: account,
          paymentHistory: historyResult.getOrElse(() => []),
        ),
      ),
    );
  }

  Future<void> _onRecordNewPayment(
    RecordNewPayment event,
    Emitter<FinanceState> emit,
  ) async {
    final result = await repository.recordPayment(event.payment);
    result.fold(
      (failure) => emit(const FinanceError('Failed to record payment')),
      (receiptId) => emit(
        FinanceActionSuccess(
          'Payment recorded successfully. Receipt #: $receiptId',
        ),
      ),
    );
  }

  Future<void> _onPrintReceipt(
    PrintReceipt event,
    Emitter<FinanceState> emit,
  ) async {
    final success = await printerService.printFeeReceipt(
      event.payment,
      event.studentName,
      event.className,
    );
    if (!success) {
      emit(
        const FinanceError(
          'Failed to print receipt. Check printer connection.',
        ),
      );
    }
  }

  Future<void> _onVerifyFinanceReceipt(
    VerifyFinanceReceipt event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    // Format: PAY|schoolId|paymentId
    final parts = event.qrData.split('|');
    if (parts.length != 3 || parts[0] != 'PAY') {
      emit(const FinanceError('Invalid QR Code format.'));
      return;
    }

    final schoolId = parts[1];
    final paymentId = parts[2];

    final result = await financeService.verifyReceipt(
      paymentId: paymentId,
      schoolId: schoolId,
    );

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (payment) => emit(ReceiptVerified(payment)),
    );
  }

  Future<void> _onCheckStudentEligibility(
    CheckStudentEligibility event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final result = await financeService.checkEligibility(
      studentId: event.studentId,
      schoolId: event.schoolId,
      serviceType: event.serviceType,
    );

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (isEligible) => emit(
        EligibilityChecked(
          isEligible: isEligible,
          serviceType: event.serviceType,
          reason: isEligible
              ? null
              : 'Outstanding balance exceeds threshold for ${event.serviceType.toLowerCase()} access.',
        ),
      ),
    );
  }

  Future<void> _onLoadExpenditureRequests(
    LoadExpenditureRequests event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final result = await repository.getExpenditureRequests(event.schoolId);
    result.fold(
      (failure) => emit(const FinanceError('Failed to load expenditures')),
      (requests) => emit(ExpendituresLoaded(requests)),
    );
  }

  Future<void> _onSubmitExpenditureRequest(
    SubmitExpenditureRequest event,
    Emitter<FinanceState> emit,
  ) async {
    final result = await repository.createExpenditureRequest(event.request);
    result.fold(
      (failure) =>
          emit(const FinanceError('Failed to submit expenditure request')),
      (_) => emit(const FinanceActionSuccess('Expenditure request submitted')),
    );
  }

  Future<void> _onUpdateExpenditureApproval(
    UpdateExpenditureApproval event,
    Emitter<FinanceState> emit,
  ) async {
    final result = await repository.updateExpenditureStatus(
      event.schoolId,
      event.requestId,
      event.status,
      event.approverId,
      event.approverName,
      event.approverRole,
      event.comment,
    );
    result.fold(
      (failure) => emit(const FinanceError('Failed to update approval status')),
      (_) => emit(const FinanceActionSuccess('Approval status updated')),
    );
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final result = await repository.getBudgets(
      event.schoolId,
      event.academicYear,
      event.term,
    );
    result.fold(
      (failure) => emit(const FinanceError('Failed to load budgets')),
      (budgets) => emit(BudgetsLoaded(budgets)),
    );
  }

  Future<void> _onSaveSchoolBudget(
    SaveSchoolBudget event,
    Emitter<FinanceState> emit,
  ) async {
    final result = await repository.saveBudget(event.budget);
    result.fold(
      (failure) => emit(const FinanceError('Failed to save budget')),
      (_) => emit(const FinanceActionSuccess('Budget saved')),
    );
  }

  Future<void> _onLoadFeeCategories(
    LoadFeeCategories event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final categoriesResult = await repository.getFeeCategories(event.schoolId);
    categoriesResult.fold(
      (failure) => emit(const FinanceError('Failed to load fee categories')),
      (categories) => emit(
        FeeConfigurationLoaded(
          categories: categories,
          structures:
              const [], // Will be loaded by another event if needed or combined
        ),
      ),
    );
  }

  Future<void> _onSaveSchoolFeeCategory(
    SaveSchoolFeeCategory event,
    Emitter<FinanceState> emit,
  ) async {
    final result = await repository.saveFeeCategory(event.category);
    result.fold(
      (failure) => emit(const FinanceError('Failed to save fee category')),
      (_) => emit(const FinanceActionSuccess('Fee category saved')),
    );
  }

  Future<void> _onLoadFeeStructures(
    LoadFeeStructures event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    final structuresResult = await repository.getFeeStructures(event.schoolId);
    structuresResult.fold(
      (failure) => emit(const FinanceError('Failed to load fee structures')),
      (structures) => emit(
        FeeConfigurationLoaded(categories: const [], structures: structures),
      ),
    );
  }

  Future<void> _onSaveSchoolFeeStructure(
    SaveSchoolFeeStructure event,
    Emitter<FinanceState> emit,
  ) async {
    final result = await repository.saveFeeStructure(event.structure);
    result.fold(
      (failure) => emit(const FinanceError('Failed to save fee structure')),
      (_) => emit(const FinanceActionSuccess('Fee structure saved')),
    );
  }
}
