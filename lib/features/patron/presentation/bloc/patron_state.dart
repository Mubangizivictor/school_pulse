import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';

abstract class PatronState extends Equatable {
  const PatronState();

  @override
  List<Object?> get props => [];
}

class PatronInitial extends PatronState {}

class PatronLoading extends PatronState {}

class PatronDashboardLoaded extends PatronState {
  final List<Dormitory> dormitories;
  final List<BoardingStudent> students;
  final List<BoardingAttendance> recentAttendance;
  final List<DisciplineIncident> recentIncidents;
  final List<WelfareRecord> recentWelfare;
  final List<BoardingAnnouncement> announcements;

  const PatronDashboardLoaded({
    required this.dormitories,
    required this.students,
    required this.recentAttendance,
    required this.recentIncidents,
    required this.recentWelfare,
    required this.announcements,
  });

  @override
  List<Object?> get props => [dormitories, students, recentAttendance, recentIncidents, recentWelfare, announcements];
}

class DormitoriesLoaded extends PatronState {
  final List<Dormitory> dormitories;
  const DormitoriesLoaded(this.dormitories);

  @override
  List<Object?> get props => [dormitories];
}

class BoardingStudentsLoaded extends PatronState {
  final List<BoardingStudent> students;
  const BoardingStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class AttendanceLoaded extends PatronState {
  final List<BoardingAttendance> attendance;
  const AttendanceLoaded(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

class WelfareRecordsLoaded extends PatronState {
  final List<WelfareRecord> records;
  const WelfareRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class DisciplineIncidentsLoaded extends PatronState {
  final List<DisciplineIncident> incidents;
  const DisciplineIncidentsLoaded(this.incidents);

  @override
  List<Object?> get props => [incidents];
}

class AnnouncementsLoaded extends PatronState {
  final List<BoardingAnnouncement> announcements;
  const AnnouncementsLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

class PatronError extends PatronState {
  final String message;
  const PatronError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatronActionSuccess extends PatronState {
  final String message;
  const PatronActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
