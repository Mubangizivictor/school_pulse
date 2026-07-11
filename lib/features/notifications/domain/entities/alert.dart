import 'package:equatable/equatable.dart';

enum AlertSeverity { info, success, warning, error }

class Alert extends Equatable {
  final String id;
  final String studentId;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const Alert({
    required this.id,
    required this.studentId,
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
