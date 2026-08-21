import '../../domain/entities/class_announcement.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_behaviour.dart';
import '../../domain/entities/class_homework.dart';
import '../../domain/entities/class_performance.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/class_task.dart';

/// No Isar/isar-model import here on purpose - see
/// class_teacher_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// class_teacher_local_data_source_factory.dart's conditional import.
///
/// Roster/dashboard caching is a pure Firestore-mirroring cache on mobile.
/// getAttendanceDraft/saveAttendanceDraft is different: the register is
/// written locally *before* the network, so a teacher's marks survive the
/// app being killed mid-lesson. Web has no offline-drafting story - reads
/// and writes for the draft go straight to Firestore instead, so a web
/// teacher does not get the same "survives app kill" protection (documented
/// difference, not a bug).
abstract class ClassTeacherLocalDataSource {
  Future<List<ClassStudentSummary>> getClassStudents({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<ClassStudentSummary?> getClassStudent(String studentId);

  Future<void> cacheClassStudents(
    List<ClassStudentSummary> students, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<ClassDashboardSummary?> getDashboard({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<void> cacheDashboard(
    ClassDashboardSummary dashboard, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<ClassAttendanceSession?> getAttendanceDraft(
    String sessionId, {
    required String schoolId,
  });

  Future<void> saveAttendanceDraft(ClassAttendanceSession session);

  Future<List<ClassTask>> getTasks({
    required String schoolId,
    required String ownerUserId,
  });

  Future<ClassTask?> getTask(String taskId);

  Future<void> cacheTasks(
    List<ClassTask> tasks, {
    required String schoolId,
    required String ownerUserId,
  });

  Future<void> saveTaskLocal(ClassTask task);

  Future<void> deleteTaskLocal(String taskId);

  Future<List<ClassHomework>> getHomework({
    required String schoolId,
    required String classId,
  });

  Future<ClassHomework?> getHomeworkItem(String homeworkId);

  Future<void> cacheHomework(
    List<ClassHomework> homework, {
    required String schoolId,
    required String classId,
  });

  Future<void> saveHomeworkLocal(ClassHomework homework);

  Future<List<ClassBehaviourRecord>> getBehaviourRecords({
    required String schoolId,
    required String classId,
  });

  Future<ClassBehaviourRecord?> getBehaviourRecord(String recordId);

  Future<void> cacheBehaviourRecords(
    List<ClassBehaviourRecord> records, {
    required String schoolId,
    required String classId,
  });

  Future<void> saveBehaviourRecordLocal(ClassBehaviourRecord record);

  Future<List<ClassAnnouncement>> getAnnouncements({
    required String schoolId,
    required String classId,
  });

  Future<ClassAnnouncement?> getAnnouncement(String announcementId);

  Future<void> cacheAnnouncements(
    List<ClassAnnouncement> announcements, {
    required String schoolId,
    required String classId,
  });

  Future<void> saveAnnouncementLocal(ClassAnnouncement announcement);

  Future<ClassPerformanceSummary?> getPerformance({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    String? streamId,
  });

  Future<void> cachePerformance(
    ClassPerformanceSummary summary, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    String? streamId,
  });

  Future<void> clear({String? schoolId});
}
