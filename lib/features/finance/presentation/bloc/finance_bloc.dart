import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/fee_item.dart';
import '../../domain/usecases/get_fees.dart';
import '../../domain/usecases/get_payment_history.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final GetFees getFees;
  final GetPaymentHistory getPaymentHistory;

  FinanceBloc({
    required this.getFees,
    required this.getPaymentHistory,
  }) : super(FinanceInitial()) {
    on<FetchFees>(_onFetchFees);
    on<FetchPaymentHistory>(_onFetchPaymentHistory);
  }

  Future<void> _onFetchFees(FetchFees event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final feesResult = await getFees(event.studentId);
    final historyResult = await getPaymentHistory(event.studentId);
    
    feesResult.fold(
      (failure) => emit(const FinanceError('Server Failure')),
      (fees) => historyResult.fold(
        (failure) => emit(const FinanceError('Server Failure')),
        (history) => emit(FinanceLoaded(fees: fees, paymentHistory: history)),
      ),
    );
  }

  Future<void> _onFetchPaymentHistory(FetchPaymentHistory event, Emitter<FinanceState> emit) async {
    // This is now redundant if we fetch both in FetchFees, 
    // but good to have for specific updates.
    final currentState = state;
    List<FeeItem> currentFees = [];
    
    if (currentState is FinanceLoaded) {
      currentFees = currentState.fees;
    }

    final result = await getPaymentHistory(event.studentId);
    
    result.fold(
      (failure) => emit(const FinanceError('Server Failure')),
      (history) => emit(FinanceLoaded(fees: currentFees, paymentHistory: history)),
    );
  }
}
