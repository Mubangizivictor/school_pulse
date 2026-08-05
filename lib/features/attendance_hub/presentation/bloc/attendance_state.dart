import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class ScopesLoaded extends AttendanceState {
  final List<AttendanceScope> scopes;
  const ScopesLoaded(this.scopes);

  @override
  List<Object?> get props => [scopes];
}

class RosterLoaded extends AttendanceState {
  final List<AttendancePerson> roster;
  const RosterLoaded(this.roster);

  @override
  List<Object?> get props => [roster];
}

class RecordsLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  const RecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class AttendanceMarkSuccess extends AttendanceState {
  final AttendanceRecord record;
  const AttendanceMarkSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class AttendanceBatchMarkSuccess extends AttendanceState {
  final List<AttendanceRecord> records;
  const AttendanceBatchMarkSuccess(this.records);

  @override
  List<Object?> get props => [records];
}

class AttendanceDuplicate extends AttendanceState {
  final String message;
  const AttendanceDuplicate(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceActionDenied extends AttendanceState {
  final String message;
  const AttendanceActionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
