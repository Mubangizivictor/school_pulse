import 'package:school_pulse/features/matron/data/sources/matron_remote_data_source.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';

class MatronRepositoryImpl implements MatronRepository {
  final MatronRemoteDataSource remoteDataSource;

  MatronRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<MatronDashboardOverview> watchDashboardOverview(String schoolId) {
    return remoteDataSource.watchDashboardOverview(schoolId);
  }

  @override
  Stream<List<Dormitory>> getDormitories() {
    return remoteDataSource.getDormitories();
  }

  @override
  Future<void> addDormitory(Dormitory dormitory) {
    return remoteDataSource.addDormitory(dormitory);
  }

  @override
  Future<void> updateDormitory(Dormitory dormitory) {
    return remoteDataSource.updateDormitory(dormitory);
  }

  @override
  Future<void> deleteDormitory(String id) {
    return remoteDataSource.deleteDormitory(id);
  }

  @override
  Future<void> setDormLeadership(
    String dormitoryId, {
    String? roomLeaderId,
    String? dormPrefectId,
  }) {
    return remoteDataSource.setDormLeadership(
      dormitoryId,
      roomLeaderId: roomLeaderId,
      dormPrefectId: dormPrefectId,
    );
  }

  @override
  Stream<List<Bed>> getBeds(String dormitoryId) {
    return remoteDataSource.getBeds(dormitoryId);
  }

  @override
  Future<void> addBed(String dormitoryId, String bedNumber) {
    return remoteDataSource.addBed(dormitoryId, bedNumber);
  }

  @override
  Future<void> removeBed(String dormitoryId, String bedId) {
    return remoteDataSource.removeBed(dormitoryId, bedId);
  }

  @override
  Future<void> transferStudent({
    required String studentId,
    required String toDormitoryId,
    String? toBedNumber,
    required String transferredBy,
    String? reason,
  }) {
    return remoteDataSource.transferStudent(
      studentId: studentId,
      toDormitoryId: toDormitoryId,
      toBedNumber: toBedNumber,
      transferredBy: transferredBy,
      reason: reason,
    );
  }

  @override
  Stream<List<BedTransfer>> getTransferHistory(String? studentId) {
    return remoteDataSource.getTransferHistory(studentId);
  }

  @override
  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId) {
    return remoteDataSource.getBoardingStudents(dormitoryId);
  }

  @override
  Stream<List<BoardingStudent>> getUnallocatedStudents() {
    return remoteDataSource.getUnallocatedStudents();
  }

  @override
  Future<void> allocateStudentToDorm(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  ) {
    return remoteDataSource.allocateStudentToDorm(
      studentId,
      dormitoryId,
      bedNumber,
    );
  }

  @override
  Future<void> updateStudentBed(String studentId, String? bedNumber) {
    return remoteDataSource.updateStudentBed(studentId, bedNumber);
  }

  @override
  Future<void> setRoomLeader(String dormitoryId, String? studentId) {
    return remoteDataSource.setRoomLeader(dormitoryId, studentId);
  }

  @override
  Stream<List<BoardingAttendance>> getAttendance(
    String schoolId,
    DateTime date,
    String? dormitoryId,
    String? type,
  ) {
    return remoteDataSource.getAttendance(schoolId, date, dormitoryId, type);
  }

  @override
  Future<void> recordAttendance(BoardingAttendance attendance) {
    return remoteDataSource.recordAttendance(attendance);
  }

  @override
  Future<void> bulkRecordAttendance(List<BoardingAttendance> records) {
    return remoteDataSource.bulkRecordAttendance(records);
  }

  @override
  Stream<List<LeaveRequest>> getLeaveRequests({String? status}) {
    return remoteDataSource.getLeaveRequests(status: status);
  }

  @override
  Future<void> requestLeave(LeaveRequest request) {
    return remoteDataSource.requestLeave(request);
  }

  @override
  Future<void> updateLeaveStatus(
    String requestId,
    String status, {
    String? approvedBy,
    DateTime? actualReturnDate,
    String? notes,
  }) {
    return remoteDataSource.updateLeaveStatus(
      requestId,
      status,
      approvedBy: approvedBy,
      actualReturnDate: actualReturnDate,
      notes: notes,
    );
  }

  @override
  Stream<List<WelfareRecord>> watchWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  }) {
    return remoteDataSource.watchWelfareRecords(
      schoolId,
      studentId,
      publicOnly: publicOnly,
    );
  }

  @override
  Stream<List<WelfareRecord>> watchAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  }) {
    return remoteDataSource.watchAllWelfareRecords(
      schoolId,
      publicOnly: publicOnly,
    );
  }

  @override
  Future<void> logWelfareRecord(WelfareRecord record) {
    return remoteDataSource.logWelfareRecord(record);
  }

  @override
  Stream<List<CounselingReferral>> getCounselingReferrals(String? studentId) {
    return remoteDataSource.getCounselingReferrals(studentId);
  }

  @override
  Future<void> logCounselingReferral(CounselingReferral referral) {
    return remoteDataSource.logCounselingReferral(referral);
  }

  @override
  Future<void> updateReferralStatus(
    String referralId,
    String status, {
    String? followUpNotes,
  }) {
    return remoteDataSource.updateReferralStatus(
      referralId,
      status,
      followUpNotes: followUpNotes,
    );
  }

  @override
  Stream<List<BehaviourObservation>> getBehaviourObservations(String? studentId) {
    return remoteDataSource.getBehaviourObservations(studentId);
  }

  @override
  Future<void> logBehaviourObservation(BehaviourObservation observation) {
    return remoteDataSource.logBehaviourObservation(observation);
  }

  @override
  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId) {
    return remoteDataSource.getDisciplineIncidents(studentId);
  }

  @override
  Future<void> logDisciplineIncident(DisciplineIncident incident) {
    return remoteDataSource.logDisciplineIncident(incident);
  }

  @override
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  ) {
    return remoteDataSource.updateDisciplineStatus(
      incidentId,
      status,
      actionTaken,
    );
  }

  @override
  Stream<List<BoardingAnnouncement>> getAnnouncements() {
    return remoteDataSource.getAnnouncements();
  }

  @override
  Future<void> postAnnouncement(BoardingAnnouncement announcement) {
    return remoteDataSource.postAnnouncement(announcement);
  }
}
