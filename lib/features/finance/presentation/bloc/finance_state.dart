import 'package:equatable/equatable.dart';
import '../../domain/entities/fee_item.dart';
import '../../domain/entities/payment_record.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<FeeItem> fees;
  final List<PaymentRecord> paymentHistory;

  const FinanceLoaded({
    required this.fees,
    required this.paymentHistory,
  });

  @override
  List<Object> get props => [fees, paymentHistory];
}

class FinanceError extends FinanceState {
  final String message;
  const FinanceError(this.message);

  @override
  List<Object> get props => [message];
}
