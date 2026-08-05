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

  const LoadScopesRequested({required this.schoolId, required this.category});

  @override
  List<Object?> get props => [schoolId, category];
}

class LoadRosterRequested extends AttendanceEvent {
  final String schoolId;
  final AttendanceCategory category;
  final String scopeId;

  const LoadRosterRequested({
    required this.schoolId,
    required this.category,
    required this.scopeId,
  });

  @override
  List<Object?> get props => [schoolId, category, scopeId];
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
  final AttendanceCategory? category;
  final DateTime? from;
  final DateTime? to;
  final String? scopeId;

  const LoadRecordsRequested({
    required this.schoolId,
    this.category,
    this.from,
    this.to,
    this.scopeId,
  });

  @override
  List<Object?> get props => [schoolId, category, from, to, scopeId];
}
