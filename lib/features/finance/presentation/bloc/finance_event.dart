import 'package:equatable/equatable.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object> get props => [];
}

class FetchFees extends FinanceEvent {
  final String studentId;
  const FetchFees(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class FetchPaymentHistory extends FinanceEvent {
  final String studentId;
  const FetchPaymentHistory(this.studentId);

  @override
  List<Object> get props => [studentId];
}
