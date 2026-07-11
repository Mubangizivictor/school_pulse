import 'package:equatable/equatable.dart';

enum StudentStatus { present, absent, late }

class AttendanceRecord extends Equatable {
  final String studentId;
  final DateTime date;
  final StudentStatus status;
  final String note;

  const AttendanceRecord({
    required this.studentId,
    required this.date,
    required this.status,
    this.note = '',
  });

  @override
  List<Object?> get props => [studentId, date, status, note];
}
