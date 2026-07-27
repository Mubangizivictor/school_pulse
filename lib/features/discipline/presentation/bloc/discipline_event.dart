// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import '../../domain/entities/discipline_incident.dart';

abstract class DisciplineEvent extends Equatable {
  const DisciplineEvent();

  @override
  List<Object?> get props => [];
}

class LoadDisciplineIncidents extends DisciplineEvent {
  final String studentId;

  const LoadDisciplineIncidents(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class LoadRecentIncidents extends DisciplineEvent {}

class LogIncidentRequested extends DisciplineEvent {
  final String studentId;
  final String description;
  final Severity severity;
  final String punishment;

  const LogIncidentRequested({
    required this.studentId,
    required this.description,
    required this.severity,
    this.punishment = '',
  });

  @override
  List<Object> get props => [studentId, description, severity, punishment];
}

class LoadCounselingSessions extends DisciplineEvent {}

class LogCounselingSessionRequested extends DisciplineEvent {
  final String studentId;
  final String counselorId;
  final String reason;
  final String notes;
  final String recommendations;
  final String? linkedIncidentId;

  const LogCounselingSessionRequested({
    required this.studentId,
    required this.counselorId,
    required this.reason,
    required this.notes,
    required this.recommendations,
    this.linkedIncidentId,
  });

  @override
  List<Object?> get props => [studentId, counselorId, reason, notes, recommendations, linkedIncidentId];
}
