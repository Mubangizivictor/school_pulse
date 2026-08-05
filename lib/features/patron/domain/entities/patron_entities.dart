import 'package:equatable/equatable.dart';

/// A boys' dormitory. Lives in the shared `dormitories` Firestore collection
/// (also used by the Matron/girls module) scoped by [gender] - Patron always
/// reads/writes gender == 'Male' so the two wings never see each other's data.
class Dormitory extends Equatable {
  final String id;
  final String name;
  final String gender;
  final int capacity;
  final int occupantCount;
  final String? roomLeaderId;
  final String? roomLeaderName;
  final String? dormPrefectId;
  final String? dormPrefectName;
  final String? location;

  const Dormitory({
    required this.id,
    required this.name,
    this.gender = 'Male',
    required this.capacity,
    required this.occupantCount,
    this.roomLeaderId,
    this.roomLeaderName,
    this.dormPrefectId,
    this.dormPrefectName,
    this.location,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    gender,
    capacity,
    occupantCount,
    roomLeaderId,
    roomLeaderName,
    dormPrefectId,
    dormPrefectName,
    location,
  ];
}

/// An individual bed within a dormitory - dormitories/{dormId}/beds/{bedId}.
class Bed extends Equatable {
  final String id;
  final String dormitoryId;
  final String bedNumber;
  final bool occupied;
  final String? studentId;
  final String? studentName;

  const Bed({
    required this.id,
    required this.dormitoryId,
    required this.bedNumber,
    this.occupied = false,
    this.studentId,
    this.studentName,
  });

  @override
  List<Object?> get props => [
    id,
    dormitoryId,
    bedNumber,
    occupied,
    studentId,
    studentName,
  ];
}

/// A record of a student moving beds/dorms - bed_transfers collection.
class BedTransfer extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String? fromDormitoryId;
  final String? fromDormitoryName;
  final String? fromBedNumber;
  final String toDormitoryId;
  final String toDormitoryName;
  final String? toBedNumber;
  final DateTime date;
  final String transferredBy;
  final String? reason;

  const BedTransfer({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.fromDormitoryId,
    this.fromDormitoryName,
    this.fromBedNumber,
    required this.toDormitoryId,
    required this.toDormitoryName,
    this.toBedNumber,
    required this.date,
    required this.transferredBy,
    this.reason,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    fromDormitoryId,
    fromDormitoryName,
    fromBedNumber,
    toDormitoryId,
    toDormitoryName,
    toBedNumber,
    date,
    transferredBy,
    reason,
  ];
}

/// Kept field-for-field backward compatible with the pre-existing type so
/// lib/features/parent/boarding_screen.dart (which must not be modified)
/// keeps compiling and rendering the same data unchanged.
class BoardingStudent extends Equatable {
  final String id;
  final String name;
  final String? dormitoryId;
  final String? dormitoryName;
  final String? bedNumber;
  final String status; // 'Present', 'Leave', 'Sick', etc.
  final String? photoUrl;
  final String studentClass;
  final String gender;

  const BoardingStudent({
    required this.id,
    required this.name,
    this.dormitoryId,
    this.dormitoryName,
    this.bedNumber,
    this.status = 'Present',
    this.photoUrl,
    required this.studentClass,
    this.gender = 'Male',
  });

  @override
  List<Object?> get props => [
    id,
    name,
    dormitoryId,
    dormitoryName,
    bedNumber,
    status,
    photoUrl,
    studentClass,
    gender,
  ];
}

/// Roll-call / boarding attendance record. [type] now covers Morning,
/// Evening, Weekend, Holiday, Study and Activity sessions - all still a
/// plain string so this stays wire-compatible with existing records.
class BoardingAttendance extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String dormitoryId;
  final DateTime date;
  final String
  type; // 'Morning', 'Evening', 'Weekend', 'Holiday', 'Study', 'Activity'
  final String status; // 'Present', 'Absent', 'Late', 'Leave', 'Sick'
  final String? remarks;
  final String recordedBy;

  const BoardingAttendance({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.dormitoryId,
    required this.date,
    required this.type,
    required this.status,
    this.remarks,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    studentName,
    dormitoryId,
    date,
    type,
    status,
    remarks,
    recordedBy,
  ];
}

/// A student leave request with departure/return tracking. Overdue status is
/// computed client-side (status == 'out' && expectedReturnDate has passed),
/// mirroring how the library module treats overdue borrowings.
class LeaveRequest extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String dormitoryId;
  final String reason;
  final String? destination;
  final String requestedBy;
  final DateTime departureDate;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final String status; // 'Pending', 'Approved', 'Rejected', 'Out', 'Returned'
  final String? approvedBy;
  final String? notes;

  const LeaveRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.dormitoryId,
    required this.reason,
    this.destination,
    required this.requestedBy,
    required this.departureDate,
    required this.expectedReturnDate,
    this.actualReturnDate,
    this.status = 'Pending',
    this.approvedBy,
    this.notes,
  });

  bool get isOverdue =>
      status == 'Out' && DateTime.now().isAfter(expectedReturnDate);

  LeaveRequest copyWith({
    String? status,
    String? approvedBy,
    DateTime? actualReturnDate,
    String? notes,
  }) {
    return LeaveRequest(
      id: id,
      studentId: studentId,
      studentName: studentName,
      dormitoryId: dormitoryId,
      reason: reason,
      destination: destination,
      requestedBy: requestedBy,
      departureDate: departureDate,
      expectedReturnDate: expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    dormitoryId,
    reason,
    destination,
    requestedBy,
    departureDate,
    expectedReturnDate,
    actualReturnDate,
    status,
    approvedBy,
    notes,
  ];
}

/// Kept field-for-field backward compatible with the pre-existing type -
/// consumed as-is by lib/features/parent/boarding_screen.dart via
/// WatchWelfareRecords. New welfare categories (Check-in, Counseling
/// Referral, Behaviour: Positive/Concern) are plain string values, so no
/// schema change was needed to support them.
class WelfareRecord extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String
  category; // 'Concern', 'Check-in', 'Counseling Referral', 'Behaviour: Positive', 'Behaviour: Concern', ...
  final String note;
  final DateTime date;
  final String recordedBy;
  final bool isPrivate;
  final DateTime? followUpDate;

  const WelfareRecord({
    required this.id,
    this.schoolId = '',
    required this.studentId,
    required this.studentName,
    required this.category,
    required this.note,
    required this.date,
    required this.recordedBy,
    this.isPrivate = false,
    this.followUpDate,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    studentName,
    category,
    note,
    date,
    recordedBy,
    isPrivate,
    followUpDate,
  ];
}

/// A referral to counseling, tracked distinctly from a general welfare note
/// so referrals/appointments/follow-ups can be tracked to completion.
class CounselingReferral extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String reason;
  final String referredBy;
  final String? referredTo;
  final DateTime referralDate;
  final DateTime? appointmentDate;
  final String status; // 'Pending', 'Scheduled', 'Completed', 'Declined'
  final String? followUpNotes;

  const CounselingReferral({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.reason,
    required this.referredBy,
    this.referredTo,
    required this.referralDate,
    this.appointmentDate,
    this.status = 'Pending',
    this.followUpNotes,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    reason,
    referredBy,
    referredTo,
    referralDate,
    appointmentDate,
    status,
    followUpNotes,
  ];
}

/// A discrete positive or concerning behaviour note, distinct from a formal
/// discipline incident - used to track patterns/progress over time.
class BehaviourObservation extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String type; // 'Positive', 'Concern'
  final String description;
  final DateTime date;
  final String recordedBy;

  const BehaviourObservation({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.description,
    required this.date,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    type,
    description,
    date,
    recordedBy,
  ];
}

/// Kept field-for-field backward compatible with the pre-existing type -
/// consumed as-is by lib/features/parent/boarding_screen.dart via
/// WatchDisciplineIncidents. New fields are additive/optional. [isPrivate]
/// defaults to true (hidden from parents/students) since the spec is
/// explicit that discipline notes are staff-only unless a patron chooses to
/// share a summary - enforced server-side in firestore.rules, not just here.
class DisciplineIncident extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String description;
  final String category;
  final String actionTaken;
  final DateTime date;
  final String status; // 'Pending', 'Resolved', 'Follow-up'
  final String recordedBy;
  final String? location;
  final List<String> witnesses;
  final String severity; // 'Low', 'Medium', 'High'
  final bool parentNotified;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final bool isPrivate;

  const DisciplineIncident({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.description,
    required this.category,
    required this.actionTaken,
    required this.date,
    required this.status,
    required this.recordedBy,
    this.location,
    this.witnesses = const [],
    this.severity = 'Low',
    this.parentNotified = false,
    this.followUpRequired = false,
    this.followUpDate,
    this.isPrivate = true,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    description,
    category,
    actionTaken,
    date,
    status,
    recordedBy,
    location,
    witnesses,
    severity,
    parentNotified,
    followUpRequired,
    followUpDate,
    isPrivate,
  ];
}

/// Kept field-for-field backward compatible with the pre-existing type -
/// consumed as-is by lib/features/parent/boarding_screen.dart via
/// WatchAnnouncements.
class BoardingAnnouncement extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String authorName;
  final String? targetDormitoryId; // Optional: specific dorm or all
  final List<String> targetGroups; // e.g. ['Patrons (Boys)', 'Parents']

  const BoardingAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.authorName,
    this.targetDormitoryId,
    this.targetGroups = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    date,
    authorName,
    targetDormitoryId,
    targetGroups,
  ];
}
