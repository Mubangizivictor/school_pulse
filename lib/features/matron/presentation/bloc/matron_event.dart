import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';

abstract class MatronEvent extends Equatable {
  const MatronEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatronDashboardScreen extends MatronEvent {}

class WatchDashboardOverview extends MatronEvent {
  final String schoolId;
  const WatchDashboardOverview(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class WatchDormitories extends MatronEvent {}

class WatchBoardingStudents extends MatronEvent {
  final String? dormitoryId;
  const WatchBoardingStudents({this.dormitoryId});

  @override
  List<Object?> get props => [dormitoryId];
}

class WatchUnallocatedStudents extends MatronEvent {}

class AddDormitoryEvent extends MatronEvent {
  final Dormitory dormitory;
  const AddDormitoryEvent(this.dormitory);
}

class UpdateDormitoryEvent extends MatronEvent {
  final Dormitory dormitory;
  const UpdateDormitoryEvent(this.dormitory);
}

class DeleteDormitoryEvent extends MatronEvent {
  final String id;
  const DeleteDormitoryEvent(this.id);
}

class SetDormLeadershipEvent extends MatronEvent {
  final String dormitoryId;
  final String? roomLeaderId;
  final String? dormPrefectId;
  const SetDormLeadershipEvent(
    this.dormitoryId, {
    this.roomLeaderId,
    this.dormPrefectId,
  });
}

class AllocateStudentEvent extends MatronEvent {
  final String studentId;
  final String dormitoryId;
  final String? bedNumber;
  const AllocateStudentEvent(this.studentId, this.dormitoryId, this.bedNumber);
}

class SetRoomLeaderEvent extends MatronEvent {
  final String dormitoryId;
  final String? studentId;
  const SetRoomLeaderEvent(this.dormitoryId, this.studentId);
}

// ---- Bed Management ----

class WatchBeds extends MatronEvent {
  final String dormitoryId;
  const WatchBeds(this.dormitoryId);

  @override
  List<Object?> get props => [dormitoryId];
}

class AddBedEvent extends MatronEvent {
  final String dormitoryId;
  final String bedNumber;
  const AddBedEvent(this.dormitoryId, this.bedNumber);
}

class RemoveBedEvent extends MatronEvent {
  final String dormitoryId;
  final String bedId;
  const RemoveBedEvent(this.dormitoryId, this.bedId);
}

class TransferStudentEvent extends MatronEvent {
  final String studentId;
  final String toDormitoryId;
  final String? toBedNumber;
  final String transferredBy;
  final String? reason;
  const TransferStudentEvent({
    required this.studentId,
    required this.toDormitoryId,
    this.toBedNumber,
    required this.transferredBy,
    this.reason,
  });
}

class WatchTransferHistory extends MatronEvent {
  final String? studentId;
  const WatchTransferHistory({this.studentId});

  @override
  List<Object?> get props => [studentId];
}

// ---- Attendance ----

class RecordAttendanceEvent extends MatronEvent {
  final BoardingAttendance attendance;
  const RecordAttendanceEvent(this.attendance);
}

class BulkRecordAttendanceEvent extends MatronEvent {
  final List<BoardingAttendance> records;
  const BulkRecordAttendanceEvent(this.records);
}

class WatchAttendance extends MatronEvent {
  final DateTime date;
  final String? dormitoryId;
  final String? type;
  const WatchAttendance({required this.date, this.dormitoryId, this.type});
}

// ---- Leave Management ----

class WatchLeaveRequests extends MatronEvent {
  final String? status;
  const WatchLeaveRequests({this.status});

  @override
  List<Object?> get props => [status];
}

class RequestLeaveEvent extends MatronEvent {
  final LeaveRequest request;
  const RequestLeaveEvent(this.request);
}

class UpdateLeaveStatusEvent extends MatronEvent {
  final String requestId;
  final String status;
  final String? approvedBy;
  final DateTime? actualReturnDate;
  final String? notes;
  const UpdateLeaveStatusEvent(
    this.requestId,
    this.status, {
    this.approvedBy,
    this.actualReturnDate,
    this.notes,
  });
}

// ---- Welfare ----

class LogWelfareRecordEvent extends MatronEvent {
  final WelfareRecord record;
  const LogWelfareRecordEvent(this.record);
}

class WatchWelfareRecords extends MatronEvent {
  final String schoolId;
  final String? studentId;
  final bool publicOnly;
  const WatchWelfareRecords({
    required this.schoolId,
    this.studentId,
    this.publicOnly = false,
  });
}

// ---- Counseling Referrals ----

class WatchCounselingReferrals extends MatronEvent {
  final String? studentId;
  const WatchCounselingReferrals({this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class LogCounselingReferralEvent extends MatronEvent {
  final CounselingReferral referral;
  const LogCounselingReferralEvent(this.referral);
}

class UpdateReferralStatusEvent extends MatronEvent {
  final String referralId;
  final String status;
  final String? followUpNotes;
  const UpdateReferralStatusEvent(
    this.referralId,
    this.status, {
    this.followUpNotes,
  });
}

// ---- Behaviour Observations ----

class WatchBehaviourObservations extends MatronEvent {
  final String? studentId;
  const WatchBehaviourObservations({this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class LogBehaviourObservationEvent extends MatronEvent {
  final BehaviourObservation observation;
  const LogBehaviourObservationEvent(this.observation);
}

// ---- Discipline ----

class LogDisciplineIncidentEvent extends MatronEvent {
  final DisciplineIncident incident;
  const LogDisciplineIncidentEvent(this.incident);
}

class UpdateDisciplineStatusEvent extends MatronEvent {
  final String incidentId;
  final String status;
  final String actionTaken;
  const UpdateDisciplineStatusEvent(
    this.incidentId,
    this.status,
    this.actionTaken,
  );
}

class WatchDisciplineIncidents extends MatronEvent {
  final String? studentId;
  const WatchDisciplineIncidents({this.studentId});
}

// ---- Communication ----

class PostAnnouncementEvent extends MatronEvent {
  final BoardingAnnouncement announcement;
  const PostAnnouncementEvent(this.announcement);
}

class WatchAnnouncements extends MatronEvent {}
