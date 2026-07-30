import 'package:school_pulse/features/patron/data/sources/patron_remote_data_source.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';

class PatronRepositoryImpl implements PatronRepository {
  final PatronRemoteDataSource remoteDataSource;

  PatronRepositoryImpl({required this.remoteDataSource});

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
  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId) {
    return remoteDataSource.getBoardingStudents(dormitoryId);
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
    DateTime date,
    String? dormitoryId,
    String? type,
  ) {
    return remoteDataSource.getAttendance(date, dormitoryId, type);
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
  Stream<List<WelfareRecord>> getWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  }) {
    return remoteDataSource.getWelfareRecords(
      schoolId,
      studentId,
      publicOnly: publicOnly,
    );
  }

  @override
  Stream<List<WelfareRecord>> getAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  }) {
    return remoteDataSource.getAllWelfareRecords(
      schoolId,
      publicOnly: publicOnly,
    );
  }

  @override
  Future<void> logWelfareRecord(WelfareRecord record) {
    return remoteDataSource.logWelfareRecord(record);
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
