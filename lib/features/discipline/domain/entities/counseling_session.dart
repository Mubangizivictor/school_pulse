import 'package:equatable/equatable.dart';

class CounselingSession extends Equatable {
  final String id;
  final String studentId;
  final String counselorId;
  final DateTime date;
  final String reason;
  final String notes;
  final String recommendations;
  final String? linkedIncidentId;

  const CounselingSession({
    required this.id,
    required this.studentId,
    required this.counselorId,
    required this.date,
    required this.reason,
    required this.notes,
    required this.recommendations,
    this.linkedIncidentId,
  });

  @override
  List<Object?> get props =>
      [id, studentId, counselorId, date, reason, notes, recommendations, linkedIncidentId];
}
