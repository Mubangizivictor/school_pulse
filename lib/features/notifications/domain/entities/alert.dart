import 'package:equatable/equatable.dart';

enum AlertSeverity { info, success, warning, error }

class Alert extends Equatable {
  final String id;
  // Null for a school-wide/class broadcast (BroadcastSmsScreen), which
  // isn't scoped to a single student.
  final String? studentId;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const Alert({
    required this.id,
    this.studentId,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    title,
    message,
    severity,
    timestamp,
  ];
}
