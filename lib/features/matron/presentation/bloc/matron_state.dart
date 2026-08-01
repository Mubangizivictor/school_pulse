import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';

abstract class MatronState extends Equatable {
  const MatronState();

  @override
  List<Object?> get props => [];
}

class MatronInitial extends MatronState {}

class MatronLoading extends MatronState {}

class MatronDashboardLoaded extends MatronState {
  final List<Dormitory> dormitories;
  final List<BoardingStudent> students;
  final List<BoardingAttendance> recentAttendance;
  final List<DisciplineIncident> recentIncidents;
  final List<WelfareRecord> recentWelfare;
  final List<BoardingAnnouncement> announcements;

  const MatronDashboardLoaded({
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

class DashboardOverviewLoaded extends MatronState {
  final MatronDashboardOverview overview;
  const DashboardOverviewLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

class DormitoriesLoaded extends MatronState {
  final List<Dormitory> dormitories;
  const DormitoriesLoaded(this.dormitories);

  @override
  List<Object?> get props => [dormitories];
}

class BoardingStudentsLoaded extends MatronState {
  final List<BoardingStudent> students;
  const BoardingStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class UnallocatedStudentsLoaded extends MatronState {
  final List<BoardingStudent> students;
  const UnallocatedStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class BedsLoaded extends MatronState {
  final List<Bed> beds;
  const BedsLoaded(this.beds);

  @override
  List<Object?> get props => [beds];
}

class TransferHistoryLoaded extends MatronState {
  final List<BedTransfer> transfers;
  const TransferHistoryLoaded(this.transfers);

  @override
  List<Object?> get props => [transfers];
}

class AttendanceLoaded extends MatronState {
  final List<BoardingAttendance> attendance;
  const AttendanceLoaded(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

class LeaveRequestsLoaded extends MatronState {
  final List<LeaveRequest> requests;
  const LeaveRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class WelfareRecordsLoaded extends MatronState {
  final List<WelfareRecord> records;
  const WelfareRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class CounselingReferralsLoaded extends MatronState {
  final List<CounselingReferral> referrals;
  const CounselingReferralsLoaded(this.referrals);

  @override
  List<Object?> get props => [referrals];
}

class BehaviourObservationsLoaded extends MatronState {
  final List<BehaviourObservation> observations;
  const BehaviourObservationsLoaded(this.observations);

  @override
  List<Object?> get props => [observations];
}

class DisciplineIncidentsLoaded extends MatronState {
  final List<DisciplineIncident> incidents;
  const DisciplineIncidentsLoaded(this.incidents);

  @override
  List<Object?> get props => [incidents];
}

class AnnouncementsLoaded extends MatronState {
  final List<BoardingAnnouncement> announcements;
  const AnnouncementsLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

class MatronError extends MatronState {
  final String message;
  const MatronError(this.message);

  @override
  List<Object?> get props => [message];
}

class MatronActionSuccess extends MatronState {
  final String message;
  const MatronActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
