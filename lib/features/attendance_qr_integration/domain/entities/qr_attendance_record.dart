import 'package:equatable/equatable.dart';

enum QrAttendanceStatus { present, late, absent, excused }

class QrAttendanceRecord extends Equatable {
  final String id;
  final String studentUniqueId;
  final String studentName;
  final String className;
  final QrAttendanceStatus status;
  final DateTime timestamp;
  final String scannedBy;
  final String schoolId;
  final String module;
  final bool isSynced;

  const QrAttendanceRecord({
    required this.id,
    required this.studentUniqueId,
    required this.studentName,
    required this.className,
    required this.status,
    required this.timestamp,
    required this.scannedBy,
    required this.schoolId,
    required this.module,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
        id,
        studentUniqueId,
        studentName,
        className,
        status,
        timestamp,
        scannedBy,
        schoolId,
        module,
        isSynced,
      ];
}
