import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';

abstract class PatronRepository {
  // Dormitory Management
  Stream<List<Dormitory>> getDormitories();
  Future<void> addDormitory(Dormitory dormitory);
  Future<void> updateDormitory(Dormitory dormitory);
  Future<void> deleteDormitory(String id);

  // Student Allocation
  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId);
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

  // Discipline
  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId);
  Future<void> logDisciplineIncident(DisciplineIncident incident);
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  );

  // Announcements
  Stream<List<BoardingAnnouncement>> getAnnouncements();
  Future<void> postAnnouncement(BoardingAnnouncement announcement);
}
