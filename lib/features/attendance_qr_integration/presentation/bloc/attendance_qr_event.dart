import 'package:equatable/equatable.dart';
import '../../domain/entities/qr_attendance_record.dart';

abstract class AttendanceQrEvent extends Equatable {
  const AttendanceQrEvent();

  @override
  List<Object?> get props => [];
}

class ScanStudentQrEvent extends AttendanceQrEvent {
  final String uniqueSystemId;
  const ScanStudentQrEvent(this.uniqueSystemId);

  @override
  List<Object?> get props => [uniqueSystemId];
}

class MarkAttendanceEvent extends AttendanceQrEvent {
  final String studentUniqueId;
  final String studentName;
  final String className;
  final QrAttendanceStatus status;
  final String scannedBy;
  final String schoolId;
  final String module;

  const MarkAttendanceEvent({
    required this.studentUniqueId,
    required this.studentName,
    required this.className,
    required this.status,
    required this.scannedBy,
    required this.schoolId,
    required this.module,
  });

  @override
  List<Object?> get props => [
    studentUniqueId,
    studentName,
    className,
    status,
    scannedBy,
    schoolId,
    module,
  ];
}

class SyncAttendanceEvent extends AttendanceQrEvent {}
