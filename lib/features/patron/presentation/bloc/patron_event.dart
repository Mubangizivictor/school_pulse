import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';

abstract class PatronEvent extends Equatable {
  const PatronEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatronDashboard extends PatronEvent {}

class WatchDormitories extends PatronEvent {}

class WatchBoardingStudents extends PatronEvent {
  final String? dormitoryId;
  const WatchBoardingStudents({this.dormitoryId});

  @override
  List<Object?> get props => [dormitoryId];
}

class AddDormitoryEvent extends PatronEvent {
  final Dormitory dormitory;
  const AddDormitoryEvent(this.dormitory);
}

class UpdateDormitoryEvent extends PatronEvent {
  final Dormitory dormitory;
  const UpdateDormitoryEvent(this.dormitory);
}

class DeleteDormitoryEvent extends PatronEvent {
  final String id;
  const DeleteDormitoryEvent(this.id);
}

class AllocateStudentEvent extends PatronEvent {
  final String studentId;
  final String dormitoryId;
  final String? bedNumber;
  const AllocateStudentEvent(this.studentId, this.dormitoryId, this.bedNumber);
}

class SetRoomLeaderEvent extends PatronEvent {
  final String dormitoryId;
  final String? studentId;
  const SetRoomLeaderEvent(this.dormitoryId, this.studentId);
}

class RecordAttendanceEvent extends PatronEvent {
  final BoardingAttendance attendance;
  const RecordAttendanceEvent(this.attendance);
}

class BulkRecordAttendanceEvent extends PatronEvent {
  final List<BoardingAttendance> records;
  const BulkRecordAttendanceEvent(this.records);
}

class WatchAttendance extends PatronEvent {
  final DateTime date;
  final String? dormitoryId;
  final String? type;
  const WatchAttendance({required this.date, this.dormitoryId, this.type});
}

class LogWelfareRecordEvent extends PatronEvent {
  final WelfareRecord record;
  const LogWelfareRecordEvent(this.record);
}

class WatchWelfareRecords extends PatronEvent {
  final String schoolId;
  final String? studentId;
  final bool publicOnly;
  const WatchWelfareRecords({
    required this.schoolId,
    this.studentId,
    this.publicOnly = false,
  });
}

class LogDisciplineIncidentEvent extends PatronEvent {
  final DisciplineIncident incident;
  const LogDisciplineIncidentEvent(this.incident);
}

class UpdateDisciplineStatusEvent extends PatronEvent {
  final String incidentId;
  final String status;
  final String actionTaken;
  const UpdateDisciplineStatusEvent(
    this.incidentId,
    this.status,
    this.actionTaken,
  );
}

class WatchDisciplineIncidents extends PatronEvent {
  final String? studentId;
  const WatchDisciplineIncidents({this.studentId});
}

class PostAnnouncementEvent extends PatronEvent {
  final BoardingAnnouncement announcement;
  const PostAnnouncementEvent(this.announcement);
}

class WatchAnnouncements extends PatronEvent {}
