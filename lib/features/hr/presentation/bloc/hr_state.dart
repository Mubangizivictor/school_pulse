import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';

abstract class HrState extends Equatable {
  const HrState();

  @override
  List<Object> get props => [];
}

class HrInitial extends HrState {}

class HrLoading extends HrState {}

class PayrollRecordsLoaded extends HrState {
  final List<PayrollRecord> records;
  const PayrollRecordsLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class HrError extends HrState {
  final String message;
  const HrError(this.message);

  @override
  List<Object> get props => [message];
}

class PayrollGenerated extends HrState {}
