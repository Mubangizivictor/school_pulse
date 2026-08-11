import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/class_dashboard_summary.dart';

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

  Future<ClassAttendanceSession?> getAttendanceDraft(String sessionId);

  Future<void> saveAttendanceDraft(ClassAttendanceSession session);

  Future<void> clear({String? schoolId});
}
