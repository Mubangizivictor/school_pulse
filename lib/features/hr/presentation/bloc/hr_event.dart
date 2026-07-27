import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';

abstract class HrEvent extends Equatable {
  const HrEvent();

  @override
  List<Object> get props => [];
}

class LoadPayrollRecords extends HrEvent {}

class GeneratePayroll extends HrEvent {
  final PayrollRecord record;
  const GeneratePayroll(this.record);

  @override
  List<Object> get props => [record];
}
