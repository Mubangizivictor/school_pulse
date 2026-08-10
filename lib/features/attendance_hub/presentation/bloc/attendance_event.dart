import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadScopesRequested extends AttendanceEvent {
  final String schoolId;
  final AttendanceCategory category;
  final UserEntity operatorUser;

  const LoadScopesRequested({
    required this.schoolId,
    required this.category,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, category, operatorUser];
}

class LoadRosterRequested extends AttendanceEvent {
  final String schoolId;
  final AttendanceCategory category;
  final String scopeId;
  final UserEntity operatorUser;

  const LoadRosterRequested({
    required this.schoolId,
    required this.category,
    required this.scopeId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, category, scopeId, operatorUser];
}

class MarkAttendanceRequested extends AttendanceEvent {
  final AttendanceRecord record;
  final UserEntity operatorUser;

  const MarkAttendanceRequested({
    required this.record,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [record, operatorUser];
}

class MarkBatchAttendanceRequested extends AttendanceEvent {
  final List<AttendanceRecord> records;
  final UserEntity operatorUser;

  const MarkBatchAttendanceRequested({
    required this.records,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [records, operatorUser];
}

class LoadRecordsRequested extends AttendanceEvent {
  final String schoolId;
  final UserEntity operatorUser;
  final AttendanceCategory? category;
  final DateTime? from;
  final DateTime? to;
  final String? scopeId;

  const LoadRecordsRequested({
    required this.schoolId,
    required this.operatorUser,
    this.category,
    this.from,
    this.to,
    this.scopeId,
  });

  @override
  List<Object?> get props =>
      [schoolId, operatorUser, category, from, to, scopeId];
}
