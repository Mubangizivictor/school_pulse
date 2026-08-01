import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';

/// Boarding dashboard summary counts - computed by the data source from the
/// underlying collections rather than stored, so it is always fresh.
class PatronDashboardOverview {
  final int totalStudents;
  final int studentsPresent;
  final int studentsAbsent;
  final int studentsOnLeave;
  final int studentsInClinic;
  final int missingStudentCount;
  final int totalBeds;
  final int occupiedBeds;
  final int pendingLeaveRequests;
  final int overdueLeaveCount;
  final int openDisciplineCases;
  final int pendingWelfareConcerns;

  const PatronDashboardOverview({
    required this.totalStudents,
    required this.studentsPresent,
    this.studentsAbsent = 0,
    required this.studentsOnLeave,
    this.studentsInClinic = 0,
    required this.missingStudentCount,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.pendingLeaveRequests,
    required this.overdueLeaveCount,
    required this.openDisciplineCases,
    required this.pendingWelfareConcerns,
  });

  /// Boarders unaccounted for at the last roll call - surfaced as the
  /// "Emergency" tile, since a missing boarder is the one state that needs
  /// immediate escalation rather than routine follow-up.
  int get emergencyCount => missingStudentCount;
}

abstract class PatronRepository {
  // Dashboard
  Stream<PatronDashboardOverview> watchDashboardOverview(String schoolId);

  // Dormitory Management
  Stream<List<Dormitory>> getDormitories();
  Future<void> addDormitory(Dormitory dormitory);
  Future<void> updateDormitory(Dormitory dormitory);
  Future<void> deleteDormitory(String id);
  Future<void> setDormLeadership(
    String dormitoryId, {
    String? roomLeaderId,
    String? dormPrefectId,
  });

  // Bed Management
  Stream<List<Bed>> getBeds(String dormitoryId);
  Future<void> addBed(String dormitoryId, String bedNumber);
  Future<void> removeBed(String dormitoryId, String bedId);
  Future<void> transferStudent({
    required String studentId,
    required String toDormitoryId,
    String? toBedNumber,
    required String transferredBy,
    String? reason,
  });
  Stream<List<BedTransfer>> getTransferHistory(String? studentId);

  // Student Allocation
  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId);
  Stream<List<BoardingStudent>> getUnallocatedStudents();
  Future<void> allocateStudentToDorm(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  );
  Future<void> updateStudentBed(String studentId, String? bedNumber);
  Future<void> setRoomLeader(String dormitoryId, String? studentId);

  // Attendance
  Stream<List<BoardingAttendance>> getAttendance(
    DateTime date,
    String? dormitoryId,
    String? type,
  );
  Future<void> recordAttendance(BoardingAttendance attendance);
  Future<void> bulkRecordAttendance(List<BoardingAttendance> records);

  // Leave Management
  Stream<List<LeaveRequest>> getLeaveRequests({String? status});
  Future<void> requestLeave(LeaveRequest request);
  Future<void> updateLeaveStatus(
    String requestId,
    String status, {
    String? approvedBy,
    DateTime? actualReturnDate,
    String? notes,
  });

  // Welfare
  Stream<List<WelfareRecord>> getWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  });
  Stream<List<WelfareRecord>> getAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  });
  Future<void> logWelfareRecord(WelfareRecord record);

  // Counseling Referrals
  Stream<List<CounselingReferral>> getCounselingReferrals(String? studentId);
  Future<void> logCounselingReferral(CounselingReferral referral);
  Future<void> updateReferralStatus(
    String referralId,
    String status, {
    String? followUpNotes,
  });

  // Behaviour Observations
  Stream<List<BehaviourObservation>> getBehaviourObservations(
    String? studentId,
  );
  Future<void> logBehaviourObservation(BehaviourObservation observation);

  // Discipline
  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId);
  Future<void> logDisciplineIncident(DisciplineIncident incident);
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  );

  // Communication
  Stream<List<BoardingAnnouncement>> getAnnouncements();
  Future<void> postAnnouncement(BoardingAnnouncement announcement);
}
