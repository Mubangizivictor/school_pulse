import 'package:equatable/equatable.dart';
import '../../domain/entities/boarding_entities.dart';
import '../../domain/repositories/matron_repository.dart';

abstract class MatronState extends Equatable {
  const MatronState();

  @override
  List<Object?> get props => [];
}

class MatronInitial extends MatronState {}

class MatronLoading extends MatronState {}

class MatronDashboardLoaded extends MatronState {
  final BoardingDashboardData data;
  const MatronDashboardLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class DormitoriesLoaded extends MatronState {
  final List<Dormitory> dormitories;
  const DormitoriesLoaded(this.dormitories);

  @override
  List<Object?> get props => [dormitories];
}

class UnallocatedStudentsLoaded extends MatronState {
  final List<BoardingStudent> students;
  const UnallocatedStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class DormitoryStudentsLoaded extends MatronState {
  final List<BoardingStudent> students;
  const DormitoryStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class WelfareRecordsLoaded extends MatronState {
  final List<WelfareRecord> records;
  const WelfareRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class DisciplineCasesLoaded extends MatronState {
  final List<DisciplineCase> cases;
  const DisciplineCasesLoaded(this.cases);

  @override
  List<Object?> get props => [cases];
}

class HygieneChecksLoaded extends MatronState {
  final List<HygieneCheck> checks;
  const HygieneChecksLoaded(this.checks);

  @override
  List<Object?> get props => [checks];
}

class StudentsOnLeaveLoaded extends MatronState {
  final List<BoardingStudent> students;
  const StudentsOnLeaveLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class MatronSuccess extends MatronState {
  final String message;
  const MatronSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MatronError extends MatronState {
  final String message;
  const MatronError(this.message);

  @override
  List<Object?> get props => [message];
}
