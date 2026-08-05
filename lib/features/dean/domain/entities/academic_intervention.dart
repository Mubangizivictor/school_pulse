import 'package:equatable/equatable.dart';

enum InterventionType {
  remedial,
  counseling,
  parentMeeting,
  teacherMeeting,
  targetSetting,
}

enum InterventionStatus { pending, inProgress, completed, cancelled }

class AcademicIntervention extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String reason;
  final InterventionType type;
  final List<String> assignedTo; // Staff IDs
  final DateTime startDate;
  final DateTime? targetDate;
  final InterventionStatus status;
  final String outcomes;

  const AcademicIntervention({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.reason,
    required this.type,
    required this.assignedTo,
    required this.startDate,
    this.targetDate,
    required this.status,
    required this.outcomes,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    reason,
    type,
    assignedTo,
    startDate,
    targetDate,
    status,
    outcomes,
  ];
}
