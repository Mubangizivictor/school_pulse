import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';

abstract class HrEvent extends Equatable {
  const HrEvent();

  @override
  List<Object> get props => [];
}

class LoadPayrollRecords extends HrEvent {
  final String schoolId;
  const LoadPayrollRecords(this.schoolId);

  @override
  List<Object> get props => [schoolId];
}

class GeneratePayroll extends HrEvent {
  final PayrollRecord record;
  const GeneratePayroll(this.record);

  @override
  List<Object> get props => [record];
}
