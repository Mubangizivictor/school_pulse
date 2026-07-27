import 'package:equatable/equatable.dart';

enum Severity { info, success, warning, error }

class DisciplineIncident extends Equatable {
  final String id;
  final String studentId;
  final DateTime date;
  final String description;
  final Severity severity;
  final String resolution;
  final String counselingNotes;
  final String punishment;

  const DisciplineIncident({
    required this.id,
    required this.studentId,
    required this.date,
    required this.description,
    required this.severity,
    required this.resolution,
    required this.counselingNotes,
    this.punishment = '',
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        date,
        description,
        severity,
        resolution,
        counselingNotes,
        punishment,
      ];
}
